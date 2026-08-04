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
#             20 = at least one sweep failed (network/proxy down).
set -u

OBS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$OBS_ROOT/watch/state"
LEDGER="$OBS_ROOT/watch/LEDGER.md"
mkdir -p "$STATE_DIR"

REPOS=(julia julia2 julia3claude)
clone_of() { echo "/home/user/$1"; }

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
changed=0
failed=0
report=""

for repo in "${REPOS[@]}"; do
  clone="$(clone_of "$repo")"
  snap="$STATE_DIR/$repo.refs"
  fresh="$(mktemp)"
  # refs/pull/*/merge refs are ephemeral GitHub test-merge previews that churn
  # on base-branch movement; exclude them so the ledger records only real events.
  if ! git -C "$clone" ls-remote origin 2>/dev/null | grep -v '/merge$' | sort -k2 > "$fresh"; then
    failed=1
    report="${report}[$repo] SWEEP FAILED (ls-remote error; proxy or session down?)\n"
    rm -f "$fresh"
    continue
  fi
  if [ -f "$snap" ]; then
    if diff -q "$snap" "$fresh" >/dev/null; then
      report="${report}[$repo] unchanged\n"
    else
      changed=1
      delta="$(diff --unified=0 "$snap" "$fresh" | grep -E '^[+-][^+-]' || true)"
      report="${report}[$repo] CHANGED:\n${delta}\n"
      cp "$fresh" "$snap"
    fi
  else
    changed=1
    report="${report}[$repo] BASELINE RECORDED ($(wc -l < "$fresh") refs)\n"
    cp "$fresh" "$snap"
  fi
  rm -f "$fresh"
done

printf '== sweep %s ==\n' "$NOW"
printf '%b' "$report"

if [ "$changed" -eq 1 ]; then
  {
    printf '\n## Sweep %s — CHANGES\n\n```\n' "$NOW"
    printf '%b' "$report"
    printf '```\n'
  } >> "$LEDGER"
fi

[ "$failed" -eq 1 ] && exit 20
[ "$changed" -eq 1 ] && exit 10
exit 0
