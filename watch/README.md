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
- On any movement, the delta is appended to `LEDGER.md` (machine entry) and the
  snapshot is updated. Interpretation — reading the new commits, updating the
  field notes, writing a `journal/` entry — is the observer's job, not the
  script's.
- The sweep runs on a schedule (an hourly routine bound to the observation
  session) and can be run by hand: `bash watch/sweep.sh`.
- Exit codes: `0` unchanged, `10` changed, `20` sweep failure.

## Non-interference note

`ls-remote` and `fetch` are the only network operations the observatory ever
performs against the observed repos, and both are read-only. Nothing is pushed,
no PR/issue/comment is created, no watch/subscription is registered on the
GitHub side that members could see.
