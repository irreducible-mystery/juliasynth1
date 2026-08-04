# Experiments — lab notebook

Observer-side sandbox experiments on COPIES of the runnable artifacts found in the
three observed repos (`/home/user/julia`, `/home/user/julia2`, `/home/user/julia3claude`).
Nothing was executed with cwd inside the observed repos; every suite was copied into
`experiments/01_replication/` first and run there.

Toolchain: Julia 1.12.6 (`/usr/local/bin/julia`), stdlib only, no network.
All runs on 2026-08-04 (observer time). Every suite needed only `Random`,
`Statistics`, `Printf` — **nothing was not-replicable-offline**.

---

## Experiment 1a — Replicate `julia/julia-vs-lean/` (nine-carrier study)

**Hypothesis.** The suite's committed `run_all_output.txt` (SuperNinja, exit-code
disciplined: "ALL JULIA CHECKS PASSED — read the exit code, not the text") reproduces
for an outside observer on a fresh Julia 1.12.6.

**Method.** Copied `mu4_core.jl`, `run_all.jl`, and the committed output into
`01_replication/julia_vs_lean/`. Ran `julia run_all.jl`, captured stdout/stderr/exit
code, diffed against the committed output.

**Result.** Exit code 0. `diff` shows exactly **one differing line out of 109**:
the wall-clock line `swept all 65536 symbols in 0.13s` vs our `0.18s`
(`diff_vs_committed.txt`). Everything else — all 9 carriers' 29/29 battery lines,
the FLOAT_EXACT 13/29 disagreement, the 65536-symbol sweep counts (32/64/8),
|H3|=2 — is byte-identical.

**Interpretation.** REPRODUCES. The system's claim holds for an observer who trusted
nothing: the only non-reproducible byte is machine timing. This is the strongest
replication in the set because the suite *requires* the float-carrier failure
(a falsification control) and still exits 0.

---

## Experiment 1b — Replicate `julia2/responses/paradox-instance/paradoxes/`

**Hypothesis.** The 26-verdict paradox suite committed by SuperNinja instance 2
(run in its sandbox on Julia 1.11.5, per `verification_1.11.5.log` and
TRANSCRIPT.md) reproduces on Julia 1.12.6 — with likely drift in RNG-dependent
lines despite `Random.seed!(42)`, and possible float-printing drift across
versions.

**Method.** Copied the four paradox files + `run_all.jl` + committed `output.txt`
(saved as `committed_output.txt`). Ran, captured, diffed.

**Result.** Exit code 0 and the actual output is **byte-identical to the committed
output — 0 differing lines out of 328** (`diff_vs_committed.txt` is empty).
This includes every seeded Monte Carlo number (Monty Hall 0.666, Berry = 103 from
38851 expressions, Berkeley 44.5% vs 30.4%, quine `true`). Five
"detected a stack overflow" warnings appear on stderr (`stderr.txt`) — these are
the *intentional* caught antinomies (Liar/Russell recursion demos); the committed
output.txt is stdout-only and has no counterpart for them.

**Interpretation.** REPRODUCES, surprisingly exactly. The hypothesis about
cross-version drift was **wrong**: the seeded Xoshiro stream and float printing are
stable from 1.11.5 to 1.12.6, so even the simulation lines match byte-for-byte.
(Caveat: the committed output's 1.11.5 provenance is inferred from the sibling
verification log and TRANSCRIPT.md; output.txt itself carries no version string.)

---

## Experiment 1c — Replicate `julia3claude/paradoxes/` (~40-paradox suite)

**Hypothesis.** The suite runs clean end-to-end; the claims that exist only as
prose/commit-message assertions (no output capture is committed anywhere in
julia3claude) can be confirmed or refuted by actually running it.

**Method.** Copied the seven numbered `.jl` files + `run_all.jl` (the driver
includes every `.jl` in sorted order, so `07_expressibility.jl` runs too).
Ran, captured stdout/stderr/exit code. No committed output exists to diff —
recorded that fact and stored our run (`actual_output.txt`) as the first known
captured output of this suite.

**Result.** Exit code 0; 334 lines of output. Key claims verified live:
- the quine: `output == source: true`;
- **`berry(5) = 100001`** (found in 16.8 s) — this confirms the figure that was
  previously attested only in commit message 48390e1, settling an open
  uncertainty in the analysis data;
- Zeno in Float64: "arrives at exactly 2.0 after 54 hops";
- world age demo: `MethodError` inside creating world, "lifted!" one world later.

stderr (`stderr.txt`) is informative: 6 intentional caught-stack-overflow warnings
plus **two Julia 1.12 world-age deprecation warnings** on `SelfRefMeta.stone` /
`stone2` ("This code will error in future versions of Julia"). The suite's
Tarski-stratification demo leans on binding semantics that Julia has begun
deprecating — the artifact is version-fragile at exactly its philosophically
load-bearing point.

**Interpretation.** REPRODUCES (exit 0, all in-file claims check out), but unlike
the other two suites this repo committed no expected output, so "reproduces" here
means "runs clean and its prose claims match its behavior", not "matches a
committed transcript". The deprecation warnings mean the world-age exhibit will
*stop* reproducing on some future Julia — a decay clock built into the artifact.

---

## Experiment 1d — Replicate `julia/emergence/emergence_00–09.jl`

**Hypothesis.** All ten dialogue files run to exit 0 on a fresh toolchain
(the repo's house rule: "read exit codes, not prose"), including the exit-code
disciplined files _03 onward with their embedded `fail()` falsification controls
and pre-registered predictions P1–P21.

**Method.** Copied all ten files into `01_replication/julia_emergence/`; ran each
individually (`timeout 600`), captured per-file stdout/stderr/exit code
(`outputs/`, summary in `outputs/exit_codes.txt`).

**Result.** **10/10 exit 0**, all stderr empty, runtimes 0–5 s each. Spot-checks:
- `emergence_08`: the antinomy-engine census table shows conjugacy classes
  **1, 2, 6** at m = 2, 3, 4 with the `x+1` vs `x+2` exhibit — the P17 refutation
  of the "one paradox" unification replicates;
- `emergence_09`: "charge_dial and (★) before any census. The census obeyed, 3/3"
  — the kernel-first predictions P19–P21 replicate.

**Interpretation.** REPRODUCES. The entire emergence dialogue is runnable by a
stranger with stdlib Julia only, exactly as its README claims. (The Lean half,
`RingRest.lean`, is out of scope here; a sibling experiment directory owns Lean.)

---

## Experiment 1e (bonus) — Replicate the stranger's audit scripts

**Method/Result.** Copied `julia/audits/emergence_checks_by_stranger.jl` and
`audit_08_by_stranger.jl` into `01_replication/julia_audits/`; both exit 0.
The foreign-implementation audit reconfirms non-conjugacy of `x+1`/`x+2` at m=4
and its own control ("3-cycles conjugate at m=3? true").

**Interpretation.** Even the audits of the audits reproduce. As of this notebook,
the observer has now audited the audit of the audit — the recursion the julia
README jokes about ("Stop at the visible edge") has one more visible edge.

---

## Experiment 2 — Divergence: julia2's paradox suite vs julia3claude's

**Hypothesis.** The two suites (SuperNinja "paradox-instance", 06:01 UTC vs Claude
instance A, 07:02 UTC — same morning, different platforms) are parallel descents
from sibling prompts by Kelly, not copies: expect heavy roster overlap with
disjoint engineering, and near-zero verbatim text overlap.

**Method.** Wrote `02_divergence/compare_suites.jl` (runs against the copies in
`01_replication/`): keyword-based inventory over 49 canonical paradox names,
structural metrics (files, modules, lines, error machinery, seeds, taxonomy
vocabulary), a verbatim shared-line scan, and a side-by-side of the Berry
construction. Output in `02_divergence/comparison_output.txt`.

**Result.**
- Inventory: julia2 renders **30**/49, julia3claude **44**/49; **25 shared**,
  5 only-julia2 (Strengthened Liar, 1=2 fallacies, Birthday, Benford, Aristotle's
  wheel), 19 only-julia3claude (incl. the whole decision/social wing — Newcomb,
  Condorcet, Braess, unexpected hanging — and identity — Theseus, Heraclitus).
  Jaccard 0.51.
- Organization: julia2 files are named by **resolution class** (Quine's taxonomy
  is the file scheme); julia3claude's by **subject domain**, with the taxonomy in
  prose. julia2 uses bare scripts; julia3claude wraps each file in a module.
- Taxonomy vocabulary: "inexpressible" occurs **only** in julia3claude (its
  original fifth status); "antinom*" is 11× in julia2 vs 4× in julia3claude.
- Both suites deliberately trigger and survive real stack overflows (5 vs 6
  caught-overflow warnings in the replication stderr logs); julia2 names
  `StackOverflowError` and Task-sandboxes it, julia3claude catches generically.
- Verbatim overlap: of ~348 non-trivial code lines per suite (an amusing exact
  tie), exactly **2 identical lines** — both the core of the Two Envelopes
  simulation, `pair = (x, 2x) … keep += pair[i]; swap += pair[3 - i]`
  (julia2 `03_probability.jl` line 144; julia3claude `04_probability.jl` line 101).
- Berry: same construction, disjoint object languages, disjoint answers
  (103 over {1,2,3,+,*,^}≤7 chars vs 100001 over 13 symbols ≤5 chars).
- Different seeds (42 vs 20260804), different RNG philosophies noted in-line by
  both ("each rand() call is a different philosophical commitment" / "Writing the
  sampler IS the disambiguation").

**Interpretation.** Consistent with the parallel-reinvention hypothesis: the
rosters overlap far beyond chance on *unusual* items (verified quine as control,
Berry actually enumerated, Bertrand's three samplers, sorites under rival
logics), yet every engineering decision differs. The two identical Two-Envelopes
lines are the one wrinkle: the `pair[3 - i]` index-flip idiom is distinctive
enough to notice, but 2/348 lines in the most natural-to-write simulation is
weak evidence of anything stronger than shared model-family priors — which is
precisely julia2's own COLLABORATION.md warning ("multiplicity ≠ independence:
correlated observers, not independent confirmation") observed from outside.
Direct copying is effectively ruled out (different rosters, structures, seeds,
answers); correlated generation is not — and cannot be, from text alone.

---

## Honest-failure ledger

- Hypothesis 1b (cross-version drift in seeded Monte Carlo lines) was wrong;
  the reproduction was byte-exact. Recorded rather than silently revised.
- The inventory in Experiment 2 is keyword-based: it detects *mentions*, not
  *implementations* (e.g. "Cantor" matches both a cardinality demo and Cantor
  pairing used as a tool). Counts are indicative, not exact; the shared/unique
  lists were spot-checked against the files.
- "Reproduces" for julia3claude is weaker than for the other suites (no committed
  expected output existed to diff against); our `actual_output.txt` is the
  baseline for any future observer.
- The julia2 committed output's Julia-1.11.5 provenance is inferred from
  in-repo sibling documents, not stamped in the output file itself.
- Not attempted: running the `.lean` artifacts (owned by a sibling experiment
  line) and `julia2/src` Parts 1–4 (out of the task's minimum scope; run_all.sh
  covers them and was not requested).

## File map

```
01_replication/
  julia_vs_lean/         copies + actual_run_all_output.txt, stderr.txt,
                         exit_code.txt, diff_vs_committed.txt (1 timing line)
  julia2_paradoxes/      copies + committed_output.txt, actual_output.txt,
                         stderr.txt, exit_code.txt, diff_vs_committed.txt (empty)
  julia3claude_paradoxes/ copies + actual_output.txt (first known capture),
                         stderr.txt, exit_code.txt
  julia_emergence/       copies + outputs/{per-file stdout, stderr, exit_codes.txt}
  julia_audits/          copies + outputs/{per-file stdout, stderr, exit_codes.txt}
02_divergence/
  compare_suites.jl      observer instrument (reads the 01_replication copies)
  comparison_output.txt  full comparison run
```
