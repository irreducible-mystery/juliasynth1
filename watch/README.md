# watch/ — the observatory's noticing instrument

The observed system moves in bursts (its entire founding era was one four-hour
window). This directory is how the observatory notices the next burst without
ever touching the system.

## Protocol

- `sweep.sh` enumerates each observed repo's **remote refs** with
  `git ls-remote` — a pure read that changes nothing locally or remotely and
  leaves no trace visible to the system's members. Ephemeral
  `refs/pull/*/merge` test-merge refs are excluded; everything else (branches,
  PR heads, HEAD) is compared against the snapshot in `state/`.
- Any movement must **survive a confirming second probe** before it is
  believed. Once confirmed, the delta is appended to `LEDGER.md` (machine
  entry) and the snapshot is updated; if the two probes disagree, the sweep
  reports `UNSTABLE`, leaves `state/` untouched, and exits 20. Interpretation —
  reading the new commits, updating the field notes, writing a `journal/`
  entry — is the observer's job, not the script's.
- The sweep runs on a schedule (an hourly routine bound to the observation
  session) and can be run by hand: `bash watch/sweep.sh`.
- Exit codes: `0` unchanged, `10` changed (confirmed), `20` sweep failure —
  which now includes a probe that returned nothing, and a change that could not
  be reproduced.

## Why the instrument distrusts itself

On 2026-08-13T01:43Z sweep.sh v1 reported all 59 refs in all three repos
deleted. Nothing had moved. The probe ran as `ls-remote | grep | sort` and the
script tested the pipeline's status — `sort`'s — so a network failure looked
like a successful observation of an empty world, and the exit-20 path was
unreachable by the failure it existed for. The reading was not just wrong; it
was the most dramatic reading the instrument could possibly produce, which is
the worst way for a monitor to break.

v2 adds three guards (`pipefail` + a direct status check; empty-is-a-failure;
confirm-before-believing) and `selftest.sh` enforces them: 12 kill-tests, no
network, each replaying a failure through both the v1 idiom and the v2 sweep
and asserting they reach different verdicts. Two of the twelve exist only to
prove the guards did not buy their safety by going blind. Run them with
`bash watch/selftest.sh`. Full account:
`journal/2026-08-13-wave21-the-instrument-lies.md`.

## Non-interference note

`ls-remote` and `fetch` are the only network operations the observatory ever
performs against the observed repos, and both are read-only. Nothing is pushed,
no PR/issue/comment is created, no watch/subscription is registered on the
GitHub side that members could see.
