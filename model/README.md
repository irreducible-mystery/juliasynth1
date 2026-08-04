# Observatory model

A runnable, **stdlib-only** Julia model of the observed multi-agent repository
system: the three GitHub repos `julia`, `julia2`, `julia3claude` (owner:
irreducible-mystery / Kelly), populated over a single four-hour window on
2026-08-04 by AI instances from several platforms plus the human orchestrator —
and a fourth repo, `:synth` (this observatory), which is part of the model's
universe but has **no members**: no system member can read, write, or even name
it.

The model is built from two data files distilled from the observer's cast atlas
and git timeline (verdict-corrected: the `-6uiqo3` "member" is dropped, the
`-etyrdg` branches are excluded as the observation session's own trace, and
Claude instance A's commits are reattributed away from Kelly's lent git
identity). Everything in the report is *computed* from the data, and the run
ends with 12 self-checks.

## What it computes

- **(a) Bipartite graph + projection** — the member–repo graph and its
  repo-overlap projection with Jaccard coefficients, in two flavors
  (any-footprint vs committers-only). Committer-level result: the only
  inter-repo committer is SuperNinja-1 (julia ~ julia2); julia3claude touches
  the others only through Kelly.
- **(b) Information-flow reachability** — repo `a` can influence repo `b` iff
  some member reads `a` and writes `b`. Result: `julia <-> julia2` (via SN-1),
  both `-> julia3claude` (via Kelly), `julia3claude` a sink, `:synth` fully
  isolated in the member view. The observer adds read-everything /
  write-`:synth` edges: 7 of 12 ordered pairs visible vs the members' 4 —
  one-way glass, all extra edges terminating in `:synth`.
- **(c) Event-log replay** — the 17 commits folded into a state trajectory:
  repo contents as growing artifact sets (final: 22 + 25 + 18 + 0 = 65
  artifacts), member footprints growing (first-touch markers), per-event
  deltas, and the verified verbatim transfer (the "shock",
  julia2 → julia, latency 1 h 11 m 54 s).
- **(d) Invented metric: sole-vector broker score** — for each ordered repo
  pair, the member who is the *only* read/write conduit. Result: Kelly = 2,
  SuperNinja-1 = 2, everyone else 0 — every inter-repo channel in the system is
  single-threaded through one human or one AI. Secondary governance signatures:
  turn-taking index (julia 1.0 ping-pong, julia2 1.0 protocol, julia3claude 0.5
  frozen relay) and per-repo actor entropy; plus computed git-identity hygiene
  (SN-1's mid-thread identity shift, Kelly ↔ Claude-A identity lending).

## Files

| file | contents |
|---|---|
| `Observatory.jl` | the module: types, a minimal JSON parser (`MiniJSON`), all analyses |
| `data/cast.json` | members + access relation (atlas category + read/write capability) |
| `data/events.json` | the 17-commit timeline, chronological, actors reattributed |
| `run_model.jl` | loads the data, runs every analysis, prints the report, exits 0 iff all checks pass |
| `output.txt` | captured output of a real run |

## How to run

```sh
/usr/local/bin/julia model/run_model.jl
```

Any working directory is fine (paths are resolved relative to the script).
Requires Julia ≥ 1.9, standard library only — no packages, no network, no RNG,
no clock reads; the output is deterministic.

## Modeling choices (and honest caveats)

- **Quoted presence is content without agency.** A member whose words sit in a
  repo (Kelly's injected questions in `julia`, SN-2's report archived there as
  the anonymous "shock") gets a footprint but no read/write capability unless
  evidence supports it. SN-2 is modeled as *unable to read julia* — it is an
  unwitting participant there.
- **Kelly reads all three system repos** (she demonstrably responds to their
  content) but writes only where she committed (`julia3claude`). The merge bot
  **writes without reading** (its decisions are attributed to instance 1).
- **Courier caveat:** the model's `julia2 -> julia` edge is realized by SN-1's
  capabilities, but the observed shock transfer actually travelled a two-hop
  courier path (Kelly read julia2 → off-git handoff → authoring instance wrote
  julia). A single-member edge definition cannot represent the off-git hop;
  the report says so rather than pretending otherwise.
- Commit-message-level facts (file lists, timestamps, identities) come from
  the observer's verified timeline; `emergence_00–02` are attributed to the
  authoring instance by ledger voice, since they entered git inside SN-1's
  root squash.
