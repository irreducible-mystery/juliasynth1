#!/usr/bin/env bash
# juliasynth1 observatory — remote-ref sweep instrument
#
# Enumerates the remote refs of the three observed repos via read-only
# `git ls-remote` (no fetch, no working-tree change, nothing visible to the
# observed system), compares against the last recorded snapshot in
# watch/state/, and appends a machine entry to watch/LEDGER.md when anything
# moved. The observer decides what to do about a change; this script only
# notices.
#
# Exit codes: 0 = all repos unchanged, 10 = at least one repo changed,
#             20 = at least one sweep failed (network/proxy down, or a
#                  reported change did not survive confirmation).
#
# Instrument history — see journal/2026-08-13-wave21-the-instrument-lies.md.
# v1 probed inside a pipeline (`ls-remote | grep | sort`) and tested the
# pipeline's status, which is `sort`'s. A failed probe therefore looked like a
# successful observation of ZERO refs, and the exit-20 failure path was
# unreachable for the most likely failure mode. On 2026-08-13T01:43Z that
# turned a network blip into the instrument's most dramatic possible reading:
# every ref in all three repos deleted. v2 adds three guards:
#   G1  pipefail, plus a direct status check on ls-remote itself
#   G2  an empty ref list is a failed probe, never an observation
#   G3  a detected change must survive a confirming re-probe before it is
#       written to state or to the ledger
# G3 is the load-bearing one: it is the only guard that would have stopped the
# 01:43 false positive from reaching the record, because that probe *claimed*
# success and its output was internally consistent. G1 and G2 are cheap and
# would each also have caught this instance. None of the three is claimed to be
# decisive on evidence it has not yet seen.
set -u
set -o pipefail

OBS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# The four seams below exist so watch/selftest.sh can drive this exact script
# against a sandbox instead of the observed system. Defaults are production.
STATE_DIR="${OBS_STATE_DIR:-$OBS_ROOT/watch/state}"
LEDGER="${OBS_LEDGER:-$OBS_ROOT/watch/LEDGER.md}"
CLONE_ROOT="${OBS_CLONE_ROOT:-/home/user}"
mkdir -p "$STATE_DIR"

read -r -a REPOS <<< "${OBS_REPOS:-julia julia2 julia3claude}"
clone_of() { echo "$CLONE_ROOT/$1"; }

# One read-only probe of a repo's remote refs into $2. Returns nonzero if the
# probe itself failed (G1) or came back empty (G2). refs/pull/*/merge refs are
# ephemeral GitHub test-merge previews that churn on base-branch movement;
# they are excluded so the ledger records only real events.
probe() {
  local clone="$1" out="$2" raw
  raw="$(mktemp)"
  if ! git -C "$clone" ls-remote origin > "$raw" 2>/dev/null; then
    rm -f "$raw"; return 1
  fi
  grep -v '/merge$' < "$raw" | sort -k2 > "$out"
  rm -f "$raw"
  [ -s "$out" ]
}

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
changed=0
failed=0
report=""

for repo in "${REPOS[@]}"; do
  clone="$(clone_of "$repo")"
  snap="$STATE_DIR/$repo.refs"
  fresh="$(mktemp)"

  if ! probe "$clone" "$fresh"; then
    failed=1
    report="${report}[$repo] SWEEP FAILED (ls-remote error or empty result; proxy or session down?)\n"
    rm -f "$fresh"
    continue
  fi

  if [ ! -f "$snap" ]; then
    changed=1
    report="${report}[$repo] BASELINE RECORDED ($(wc -l < "$fresh") refs)\n"
    cp "$fresh" "$snap"
    rm -f "$fresh"
    continue
  fi

  if diff -q "$snap" "$fresh" >/dev/null; then
    report="${report}[$repo] unchanged\n"
    rm -f "$fresh"
    continue
  fi

  # G3: a change is a claim about the observed system. Confirm it with a
  # second independent probe before writing it to state or to the ledger.
  confirm="$(mktemp)"
  if ! probe "$clone" "$confirm"; then
    failed=1
    report="${report}[$repo] CHANGE UNCONFIRMED (re-probe failed; state left untouched)\n"
    rm -f "$fresh" "$confirm"
    continue
  fi
  if ! diff -q "$fresh" "$confirm" >/dev/null; then
    failed=1
    report="${report}[$repo] UNSTABLE (two probes disagreed; state left untouched)\n"
    rm -f "$fresh" "$confirm"
    continue
  fi
  rm -f "$confirm"

  changed=1
  delta="$(diff --unified=0 "$snap" "$fresh" | grep -E '^[+-][^+-]' || true)"
  report="${report}[$repo] CHANGED (confirmed by re-probe):\n${delta}\n"
  cp "$fresh" "$snap"
  rm -f "$fresh"
done

printf '== sweep %s ==\n' "$NOW"
printf '%b' "$report"

if [ "$changed" -eq 1 ] || [ "$failed" -eq 1 ]; then
  {
    printf '\n## Sweep %s — %s\n\n```\n' "$NOW" \
      "$( [ "$failed" -eq 1 ] && echo "FAILURE" || echo "CHANGES" )"
    printf '%b' "$report"
    printf '```\n'
  } >> "$LEDGER"
fi

[ "$failed" -eq 1 ] && exit 20
[ "$changed" -eq 1 ] && exit 10
exit 0
