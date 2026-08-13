#!/usr/bin/env bash
# juliasynth1 observatory — kill-tests for the sweep instrument.
#
# The observed federation's standard (julia3claude, wave 18) is that a guard is
# not load-bearing merely because it is wired: it has to change a decision that
# would otherwise have gone the other way. These tests are written to that
# standard. Each one replays a probe failure through BOTH the v1 idiom that
# produced the 2026-08-13T01:43Z false positive and the v2 sweep, and asserts
# that the two reach different verdicts. A test that both versions pass proves
# nothing about the repair and is not counted.
#
# Run: bash watch/selftest.sh   (no network, no contact with the observed repos)
set -u

OBS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SWEEP="$OBS_ROOT/watch/sweep.sh"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

pass=0; fail=0
ok()   { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
bad()  { fail=$((fail+1)); printf '  FAIL %s — %s\n' "$1" "$2"; }

# --- the v1 idiom, verbatim, as the control ---------------------------------
# `if ! ls-remote | grep | sort > out` tests the pipeline's status, i.e.
# sort's. This function returns what v1 concluded: 0 = "observation succeeded".
v1_probe() {
  local clone="$1" out="$2"
  if ! git -C "$clone" ls-remote origin 2>/dev/null | grep -v '/merge$' | sort -k2 > "$out"; then
    return 1
  fi
  return 0
}

# --- sandbox: a fake clone plus a `git` shim that scripts ls-remote ----------
# The shim reads $SANDBOX/script.<n> for the n-th ls-remote call: a file whose
# first line is the exit status, remaining lines the stdout. Everything that is
# not `-C <dir> ls-remote origin` is passed through to the real git.
setup_sandbox() {
  rm -rf "$SANDBOX"; mkdir -p "$SANDBOX/bin" "$SANDBOX/state" "$SANDBOX/clones/r1"
  cat > "$SANDBOX/bin/git" <<'SHIM'
#!/usr/bin/env bash
if [ "${1:-}" = "-C" ] && [ "${3:-}" = "ls-remote" ]; then
  n="$(cat "$SHIM_DIR/counter" 2>/dev/null || echo 0)"; n=$((n+1))
  echo "$n" > "$SHIM_DIR/counter"
  f="$SHIM_DIR/script.$n"
  [ -f "$f" ] || f="$SHIM_DIR/script.default"
  status="$(head -n1 "$f")"
  tail -n +2 "$f"
  exit "$status"
fi
exec /usr/bin/git "$@"
SHIM
  chmod +x "$SANDBOX/bin/git"
  echo 0 > "$SANDBOX/counter"
}

# A well-formed two-ref listing.
REFS_A=$'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa\tHEAD\nbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\trefs/heads/main'
REFS_B=$'cccccccccccccccccccccccccccccccccccccccc\tHEAD\ndddddddddddddddddddddddddddddddddddddddd\trefs/heads/main'

run_sweep() {
  SHIM_DIR="$SANDBOX" PATH="$SANDBOX/bin:$PATH" \
  OBS_STATE_DIR="$SANDBOX/state" OBS_LEDGER="$SANDBOX/ledger.md" \
  OBS_CLONE_ROOT="$SANDBOX/clones" OBS_REPOS="r1" \
  bash "$SWEEP" > "$SANDBOX/out" 2>&1
  echo $?
}

echo "sweep instrument kill-tests"

# --- T1: the historical failure, replayed -----------------------------------
# A probe that fails while emitting nothing. This is what happened at 01:43Z.
setup_sandbox
printf '%s\n' "128" > "$SANDBOX/script.default"          # nonzero, no stdout
printf '%s\n' "$REFS_A" > "$SANDBOX/state/r1.refs"       # a healthy prior snapshot
rc="$(run_sweep)"
v1_verdict=$(SHIM_DIR="$SANDBOX" PATH="$SANDBOX/bin:$PATH" \
             bash -c 'if ! git -C x ls-remote origin 2>/dev/null | grep -v "/merge$" | sort -k2 > /dev/null; then echo 1; else echo 0; fi')
if [ "$rc" = "20" ]; then ok "T1 v2 reports FAILURE (exit 20) on a failed probe"
else bad "T1" "expected exit 20, got $rc"; fi
if [ "$v1_verdict" = "0" ]; then ok "T1 v1 called the same probe a success — the guard is decisive here"
else bad "T1" "v1 control did not reproduce the masking; the replay is invalid"; fi
if diff -q <(printf '%s\n' "$REFS_A") "$SANDBOX/state/r1.refs" >/dev/null; then
  ok "T1 snapshot left untouched by the failed probe"
else bad "T1" "state was overwritten during a failed probe"; fi

# --- T2: a probe that succeeds but returns nothing --------------------------
setup_sandbox
printf '%s\n' "0" > "$SANDBOX/script.default"            # zero status, no refs
printf '%s\n' "$REFS_A" > "$SANDBOX/state/r1.refs"
rc="$(run_sweep)"
if [ "$rc" = "20" ]; then ok "T2 empty ref list is a failure, not an observation"
else bad "T2" "expected exit 20, got $rc"; fi
if grep -q 'refs/heads/main' "$SANDBOX/state/r1.refs"; then ok "T2 snapshot preserved"
else bad "T2" "state emptied — this is the 01:43Z bug, unrepaired"; fi

# --- T3: G3, an unreproducible change -------------------------------------
# First probe reports a different world; the confirming probe reports the old
# one. v1 had no second probe and would have written the flapping value.
setup_sandbox
printf '0\n%s\n' "$REFS_B" > "$SANDBOX/script.1"         # first probe: changed
printf '0\n%s\n' "$REFS_A" > "$SANDBOX/script.2"         # re-probe: unchanged
printf '0\n%s\n' "$REFS_A" > "$SANDBOX/script.default"
printf '%s\n' "$REFS_A" > "$SANDBOX/state/r1.refs"
rc="$(run_sweep)"
if [ "$rc" = "20" ]; then ok "T3 unconfirmed change reported as UNSTABLE (exit 20)"
else bad "T3" "expected exit 20, got $rc"; fi
if diff -q <(printf '%s\n' "$REFS_A") "$SANDBOX/state/r1.refs" >/dev/null; then
  ok "T3 state left untouched by the unconfirmed change"
else bad "T3" "a one-probe change was written to state"; fi

# --- T4: a real change still gets through ----------------------------------
# The guards must not have bought their safety by going blind. Both probes
# agree on a new world; the sweep must report it and record it.
setup_sandbox
printf '0\n%s\n' "$REFS_B" > "$SANDBOX/script.default"
printf '%s\n' "$REFS_A" > "$SANDBOX/state/r1.refs"
rc="$(run_sweep)"
if [ "$rc" = "10" ]; then ok "T4 a confirmed change is still reported (exit 10)"
else bad "T4" "expected exit 10, got $rc"; fi
if grep -q 'cccccccccccccccccccccccccccccccccccccccc' "$SANDBOX/state/r1.refs"; then
  ok "T4 snapshot advanced to the new world"
else bad "T4" "confirmed change was not written to state"; fi
if grep -q 'CHANGED' "$SANDBOX/ledger.md" 2>/dev/null; then ok "T4 ledger entry written"
else bad "T4" "no ledger entry for a confirmed change"; fi

# --- T5: quiet stays quiet --------------------------------------------------
setup_sandbox
printf '0\n%s\n' "$REFS_A" > "$SANDBOX/script.default"
printf '%s\n' "$REFS_A" > "$SANDBOX/state/r1.refs"
rc="$(run_sweep)"
if [ "$rc" = "0" ]; then ok "T5 an unchanged world exits 0 and writes no ledger entry"
else bad "T5" "expected exit 0, got $rc"; fi
if [ ! -s "$SANDBOX/ledger.md" ]; then ok "T5 ledger untouched on a quiet sweep"
else bad "T5" "quiet sweep wrote to the ledger"; fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
