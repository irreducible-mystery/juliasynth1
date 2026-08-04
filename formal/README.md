# formal/ — AccessTopology

An external observer's machine-checked model of the **access topology** of the
three-repo AI-collaboration system operated by Kelly
(GitHub: `irreducible-mystery` / `kellyjs1313`) on **2026-08-04**.

This is a minimal Lake package (Lean 4.32.2, **no dependencies, no mathlib**)
with one library, `AccessTopology`. The observer does not participate in the
system; the fourth repo `synth` in the model stands for the observer's own
observatory repo (`juliasynth1`), invisible to every system member.

## How to build

```sh
export PATH="/root/.elan/bin:$PATH"   # elan with leanprover/lean4:v4.32.2
cd formal
lake build
```

The build must end with `Build completed successfully` and emits an axiom
audit (`#print axioms`) for the headline theorems: every finite check proves
from `propext` alone (the witness lemma `influence_iff` additionally uses
`Quot.sound` via core list lemmas). No `Classical.choice` anywhere — the same
axiom ledger the observed system's own `RingRest.lean` keeps.

## What is formalized

- `Repo` — the four vertices: `julia`, `julia2`, `julia3claude`, `synth`.
- `Member` — the deduplicated, verdict-corrected cast (10 members):
  `kelly` (human orchestrator), `authoringInstance` (julia, platform
  unattested), `superNinja1` (the `superninja@ninjatech.ai` platform identity:
  julia's auditor "the stranger" = julia2's instance 1), `paradoxInstance`
  (SuperNinja instance 2), `superninjaAppBot` (GitHub App merge vehicle),
  `claudeInstanceA` and `claudeInstanceB` (the two julia3claude Claude Code
  sessions), and three access-less entries kept for cast fidelity:
  `sourceDocAI`, `observer2`, `nextStranger`.
- `writes : Member → Repo → Bool` — verified commit/merge authorship
  (re-checked against `git log` of the read-only clones).
- `reads : Member → Repo → Bool` — *evidenced* read access (committers read
  their repo; Kelly's content engagement with all three repos is evidenced).
  Referenced-only / quoted presence is **not** access.
- `influence a b` — membership-witnessed flow: some single member reads `a`
  and writes `b` (`influence_iff` proves this characterization).
- `Reaches` — reachability, the transitive closure of `influence`.
- `influenceWithout x a b` — the flow graph with member `x` deleted, used for
  the cut-vertex analysis.

### The encoded access matrix

| Member            | julia | julia2 | julia3claude | synth |
|-------------------|:-----:|:------:|:------------:|:-----:|
| kelly             |  R    |  R     |  RW          |  —    |
| authoringInstance |  RW   |  —     |  —           |  —    |
| superNinja1       |  RW   |  RW    |  —           |  —    |
| paradoxInstance   |  —    |  RW    |  —           |  —    |
| superninjaAppBot  |  —    |  RW    |  —           |  —    |
| claudeInstanceA   |  —    |  —     |  RW          |  —    |
| claudeInstanceB   |  —    |  —     |  RW          |  —    |
| sourceDocAI       |  —    |  —     |  —           |  —    |
| observer2         |  —    |  —     |  —           |  —    |
| nextStranger      |  —    |  —     |  —           |  —    |

Judgment calls (documented in the file header): Kelly's *capability* to push
anywhere as owner is not encoded — only her one verified write (the
julia3claude PR #1 merge). Claude instance A's commits, recorded under
Kelly's lent git identity, are attributed to the instance via their
Claude-Session trailers. The julia2 report quoted into julia as the "shock"
gives `paradoxInstance` no access to julia. Off-git relay (Kelly prompting
instances in chat) is deliberately outside the model.

## The theorems, in English

**Observer boundary (tasks 1–2).**
- `no_member_writes_synth` — no system member writes the observer's repo.
- `no_member_reads_synth` — no system member reads it either.
- `synth_isolated` — consequently `synth` is fully isolated in the flow
  graph: it reaches nothing and nothing reaches it.

**Exact reachability (task 3).** The three observed repos are **not**
mutually reachable; the honest result is:
- `julia_reaches_julia2`, `julia2_reaches_julia` — julia and julia2 are
  mutually reachable (the SuperNinja platform identity reads and writes both).
- `julia_reaches_julia3claude`, `julia2_reaches_julia3claude` — content can
  flow into julia3claude (Kelly is the only conduit).
- `julia3claude_is_sink` — julia3claude reaches neither julia nor julia2:
  it is a sink of the system.
- `observed_reachability_exact` — the above bundled as one statement.
- `influence_table` — the complete 3×3 ground-truth influence matrix.
- `influence_trans` + `reaches_iff_influence` — a non-obvious closure fact:
  the influence relation is *already transitively closed*, so reachability
  adds no pairs beyond one-step influence.

**Universal access (task 4).** The hypothesis "the orchestrator is the unique
member with write access to every observed repo" is **false** in the verified
record; what is true instead:
- `no_member_writes_all_observed` — nobody (Kelly included) writes all three
  observed repos.
- `kelly_reads_all_observed` and `kelly_unique_all_observed_reader` — Kelly
  is the **unique** member with (evidenced) read access to all three:
  universal access in this system is read-side and human.
- `superNinja1_unique_multi_repo_writer` — the only member writing more than
  one repo is the SuperNinja platform identity (julia + julia2).

**Cut vertices (task 5, the non-obvious property).** The flow graph has
**exactly two** cut members:
- `kelly_is_cut` / `without_kelly_no_flow_into_julia3claude` — deleting Kelly
  severs *all* flow into julia3claude; it becomes a separate component.
- `superNinja1_is_cut` — deleting the SuperNinja identity severs
  julia ↔ julia2 in both directions.
- `cut_members_only` — deleting any *other* member changes no edge at all.
- `cross_edges_only_kelly_or_superNinja1` — member-level version: every
  cross-repo influence edge is witnessed only by Kelly or superNinja1; all
  other committers live inside a single repo.

**Hygiene / semantics.**
- `writes_imp_reads` — every verified writer of a repo is an evidenced reader
  of it.
- `influence_iff` — `influence a b` holds iff some member witnesses the flow.
- `allMembers_complete` — the enumeration used by `influence` covers the
  whole cast.

## Data provenance

Read-only clones `/home/user/julia` (HEAD `35479fe`), `/home/user/julia2`
(HEAD `e251aa3`), `/home/user/julia3claude` (HEAD `092be9f`, merge of PR #1);
all commit authorship re-checked against `git log` at model time
(2026-08-04). Cast and matrix follow the verdict-corrected observer atlas
(10 members; the `-6uiqo3` branch identity folded into Claude instance A;
the observation session's own `-etyrdg` traces excluded).

---

## Epoch 2: AccessTopologyW2.lean (wave 2, ~11:52 UTC horizon)

The wave-1 module is a snapshot, not a mistake — so wave 2 gets its own module
with the updated matrix (two new julia identities; Claude instance A now reads
and writes julia2 as "instance 3"; the bot merges in julia) and cross-epoch
theorems. In English:

- **`sink_broken`** — julia3claude→julia2 was influence-false in the wave-1
  matrix and is influence-true in wave 2; **the wave-1 theorem
  `julia3claude_is_sink` is dead**, and `sink_broken_witness` +
  `nonhuman_bidirectional_bridge` show the killer is Claude instance A alone,
  in both directions — the first inter-repo channel that is not the human.
- **`multi_repo_writers_exactly`** — the multi-repo writers are now exactly
  {SuperNinja-1, superninja-app[bot], Claude instance A}; **the wave-1
  uniqueness theorem is dead**.
- **`kelly_still_unique_all_observed_reader`** — survived: Kelly remains the
  unique member with evidenced read access to all three observed repos.
- **`observed_strongly_connected`** — the three observed repos are now
  strongly connected (wave 1: julia ↔ julia2 → julia3claude-as-sink), with
  explicit witness chains; and `influence_no_longer_transitively_closed` —
  julia3claude reaches julia only in two hops, so the flow graph has acquired
  genuine depth (in wave 1, influence was already transitively closed).
- **`not_reaches_synth` / `synth_reaches_nothing`** — the observer boundary
  survived unchanged: the observatory is still outside every member's reach.

Build: same `lake build` (both libs are default targets); epoch-2 axiom audit
prints alongside epoch 1's.
