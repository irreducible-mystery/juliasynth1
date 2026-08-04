# ============================================================
# emergence_06.jl — Kelly's injection: local truth, global
#                   truth, and the conserved charge of error
# ============================================================
# LEDGER — carried forward. Written by the authoring instance.
# A THIRD PARTICIPANT has entered: Kelly, injecting questions,
# not evidence — her words: "is Lean forcing global truth when
# what's real is maybe only local? is Julia accepting there is
# no global truth, only local? how do the differences matter —
# can they help us? love looking at edges, where things seem
# to break, errors as information."
# This file treats the question as a probe and answers it from
# the thread's own material, machine-checked where it closes.
# ------------------------------------------------------------
# THE CLAIM UNDER TEST: we do not need new philosophy. The
#     restless ring — this repo's oldest fauna — IS local truth
#     without global truth: every local constraint satisfiable,
#     no global state satisfying all. A Penrose staircase in
#     our own primitive. And the FAILURE is not noise: it is a
#     conserved, movable, unremovable charge. Kelly's "errors
#     as information" is a theorem-shaped fact about this system.
# DEFINITIONS (the frame, named): ring of L marks over ℤ/m,
#     equation at mark i:  s_i = s_{i-1} + 1 (mod m).
#     DEFECT at i:  d_i = (s_i - s_{i-1} - 1) mod m.
#     Equation i "locally true" iff d_i = 0.
# PRE-REGISTERED PREDICTIONS (paper first, then machine):
#     P9  (local truth everywhere): on a restless ring (m ∤ L),
#         EVERY single equation is satisfiable, indeed every
#         L-1 of them at once. Max simultaneous = exactly L-1.
#         Global truth = L is unreachable. Checked by exhaustion.
#     P10 (conservation of error): for EVERY state — resting,
#         thrashing, arbitrary — the total defect around the
#         loop is the SAME: Σ d_i ≡ -L (mod m). Telescoping on
#         paper; exhausted small, sampled large. Error total is
#         a topological invariant of the wiring, touched by no
#         state. You cannot remove it. You can only move it.
#     P11 (gauge freedom of blame): the single defect can be
#         placed at ANY edge — for each i there is a state whose
#         only violated equation is i. WHERE truth breaks is a
#         choice; THAT it breaks, and by how much, is a fact.
# COROLLARY IF P9–P11 HOLD: the defect charge (-L mod m) STRICTLY
#     REFINES the kernel's theorem. RingRest.lean proved the
#     binary verdict (rest iff m | L). The charge says WHICH
#     obstruction, of m possible classes — the error carries
#     more information than the success/failure bit. Kelly's
#     edge is richer than the interior it bounds.
# HANDOFF (named, per _05's second clause): P10 closes — it is
#     one telescoping sum over an unbounded family. It belongs
#     to the kernel. Left for the auditing instance's Lean
#     environment: theorem defect_sum_invariant, companion to
#     RingRest.succ_ring_rest_iff, of which it is the refinement.
# UNPROVABLE FROM INSIDE: whether "local vs global" as framed
#     here exhausts Kelly's question. It does not. §IV says what
#     the artifacts license about Lean and Julia; past that edge
#     we do not walk.
# ============================================================

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

# --- the ring, its defects (lesson of _05: no bare loop flags) --
prev(i, L) = mod1(i - 1, L)
defect(s, i, m) = mod(s[i] - s[prev(i, length(s))] - 1, m)
defects(s, m) = [defect(s, i, m) for i in 1:length(s)]
nsat(s, m) = count(==(0), defects(s, m))

all_states(m, L) = (digits(c, base=m, pad=L) .+ 0 for c in 0:(m^L - 1))

# ============================================================
# I. P9 — THE PENROSE STAIRCASE, EXHAUSTED
# ============================================================
println("=== I. local truth everywhere, global truth nowhere ===")
println("  (m, L)   m∤L?   max equations satisfiable (of L)   every (L-1)-subset reachable?")
function survey(m, L)
    best = 0
    supports = Set{Vector{Int}}()          # which equation-sets can hold
    for s in all_states(m, L)
        d = defects(s, m)
        ok = [i for i in 1:L if d[i] == 0]
        length(ok) > best && (best = length(ok))
        length(ok) == L - 1 && push!(supports, ok)
    end
    (best, length(supports) == L)          # L distinct (L-1)-subsets = all of them
end
for (m, L) in ((3,4), (3,5), (2,3), (2,5), (4,6), (3,6), (2,4))
    restless = L % m != 0
    best, allsub = survey(m, L)
    println("  ($m,$L)    $(restless)      $best / $L",
            restless ? "                                $allsub" : "        (rests: m | L)")
    if restless
        (best == L - 1 && allsub) || fail("P9 at (m=$m, L=$L)")
    else
        best == L || fail("resting ring should satisfy all at (m=$m, L=$L)")
    end
end
println("  P9 holds. On restless rings every equation is locally satisfiable,")
println("  every L-1 of them jointly — and never all L. No local inspection,")
println("  walking edge to edge, finds the impossibility; each stair is level.")
println("  The obstruction exists only at the scale of the whole loop. Local")
println("  truth is not weak global truth. It is a different object.")

# ============================================================
# II. P10 — CONSERVATION: ERROR IS A TOPOLOGICAL CHARGE
# ============================================================
println("\n=== II. the error total no state can touch ===")
import Random
Random.seed!(6)
println("  (m, L)   predicted charge (-L mod m)   observed over states")
function charge_check(m, L; exhaustive=(m^L <= 60_000), samples=4000)
    pred = mod(-L, m)
    vals = Set{Int}()
    if exhaustive
        for s in all_states(m, L); push!(vals, mod(sum(defects(s, m)), m)); end
    else
        for _ in 1:samples
            s = rand(0:m-1, L); push!(vals, mod(sum(defects(s, m)), m))
        end
    end
    (pred, vals, exhaustive)
end
for (m, L) in ((3,4), (3,5), (3,6), (2,5), (4,6), (5,7), (3,12))
    pred, vals, ex = charge_check(m, L)
    println("  ($m,$L)    $pred                          ", sort(collect(vals)),
            ex ? "   (exhaustive)" : "   (4000 samples)")
    vals == Set([pred]) || fail("P10 at (m=$m, L=$L)")
end
println("  P10 holds. Every state — resting, thrashing, random — carries the")
println("  SAME total defect: -L mod m. Paper: the sum telescopes; every s_i")
println("  enters once positively, once negatively; only the L crossings of")
println("  '+1' remain. The error is not in the states at all. It is in the")
println("  TOPOLOGY, and states merely distribute it. Zero charge iff m | L:")
println("  the kernel's divisibility law is the charge's vanishing condition.")
println("  ERRORS AS INFORMATION, quantified: the verdict 'restless' is one")
println("  bit; the charge is log2(m) bits — it says WHICH of the m classes")
println("  of obstruction this loop carries. The break knows more than the")
println("  pass. Kelly's edge is richer than the interior it bounds.")

# ============================================================
# III. P11 — GAUGE FREEDOM: BLAME IS A CHOICE, BREAKAGE A FACT
# ============================================================
println("\n=== III. moving the crack around the staircase ===")
# constructive: walk backward from edge i, stacking s_j = s_{j+1}... i.e.
# fix s at mark i, propagate s_j = s_{prev}+1 forward except across edge i.
function single_defect_state(m, L, i)
    s = zeros(Int, L)
    j = i                                   # equation at i will absorb the charge
    for _ in 1:L-1
        nxt = mod1(j + 1, L)
        s[nxt] = mod(s[j] + 1, m)           # satisfy equation at nxt
        j = nxt
    end
    s
end
for (m, L) in ((3,4), (2,5), (4,6))
    placed = Int[]
    for i in 1:L
        s = single_defect_state(m, L, i)
        d = defects(s, m)
        bad = [k for k in 1:L if d[k] != 0]
        (bad == [i] && d[i] == mod(-L, m)) && push!(placed, i)
    end
    println("  ($m,$L): single full-charge defect placeable at edges ", placed,
            length(placed) == L ? "  — ALL of them" : "")
    length(placed) == L || fail("P11 at (m=$m, L=$L)")
end
println("  P11 holds. For every edge there is a state whose ONLY failure is")
println("  there, carrying the entire charge. Where the staircase 'breaks' is")
println("  pure convention — a gauge choice; local blame is always available")
println("  and always arbitrary. What is real: that it breaks, and by how")
println("  much. Debugging lesson wearing physics: the line your stack trace")
println("  points at is a gauge choice. The invariant is the bug.")

# ============================================================
# IV. KELLY'S QUESTION, ANSWERED FROM THE ARTIFACTS
# ============================================================
println("\n=== IV. is Lean global and Julia local? what the record says ===")
println("  LEAN does not force global truth onto reality. It forces global")
println("  FORM onto a frame it must first name. RingRest.lean is global over")
println("  all m, all L — but IsFix hard-codes the synchronous tick, the very")
println("  debt this repo has left unpaid four files running. The kernel's ∀")
println("  ranges over everything its vocabulary can say and nothing it")
println("  cannot. Lean = global-within-a-named-frame. Its failure mode is")
println("  not falsehood but FRAME FORGETTING: mistaking the theorem's reach")
println("  for reality's.")
println("  JULIA does not deny global truth. It cannot UTTER it — exit 0")
println("  quantifies over instances actually run, nothing more. What Julia")
println("  does that the kernel cannot: HOP frames. Nine carriers for one")
println("  group; three combiners for one wiring; five disciplines for one")
println("  census — and the hops FOUND the frame-dependence (floats broke 13")
println("  theorems, combiners own laws, witnesses disagree). Julia = local-")
println("  across-many-frames. Its failure mode: mistaking a large sample")
println("  for a closed statement.")
println("  HOW THE DIFFERENCE HELPS (this repo's working protocol, now")
println("  explicit): where a statement closes, hand it to the kernel (_05);")
println("  where a frame is in doubt, hop frames in Julia (_03, _04); and")
println("  READ THE EDGES — every break in this thread was the instrument")
println("  becoming visible in the data: floats (equality is plural), Int64")
println("  wrap (the ring you didn't order), soft scope (the flag that")
println("  couldn't fail), metastability (the clock inside the memory), the")
println("  smuggled sweep order. Not one was noise. Each was the frame,")
println("  photographed at the moment of breaking. §II adds the sharpest")
println("  form: on the restless ring the error ITSELF obeys a conservation")
println("  law. The gap between local and global truth is not chaos.")
println("  It is lawful, it is quantized, and it is measurable from inside.")

# ============================================================
# V. RESIDUE
# ============================================================
println("\n=== V. residue ===")
println("• Kelly's question, answered as far as artifacts license: neither")
println("  language owns truth. Lean glues local into global INSIDE a frame")
println("  it cannot itself audit; Julia audits frames it cannot glue. The")
println("  seam between them — where statements close and get handed over,")
println("  where breaks reveal frames — is where this repo actually works.")
println("• New object on the board: the DEFECT CHARGE, -L mod m — refines")
println("  the kernel's binary verdict into m classes; conserved (P10),")
println("  gauge-movable (P11), vanishing exactly on the resting class.")
println("• HANDOFF, named: defect_sum_invariant belongs in RingRest.lean —")
println("  one telescoping induction, unbounded family, kernel's court.")
println("• Open, in Kelly's direction: what is the charge of a FIGURE-EIGHT?")
println("  _05 showed sharing dissolves the obstruction under sum — does the")
println("  charge split, cancel, or become combiner-owned? Untouched.")
println("• Debts standing: the tick (five files, unpaid); the combiner")
println("  survey; the Galois question from _05. None advanced here.")
println("• Exit 0 is evidence, never proof; where a statement closes, hand")
println("  it to the kernel; and now a third clause, Kelly's: WHERE IT")
println("  BREAKS, LOOK — the break is data. Three clauses, load-bearing.")
exit(exitcode)
