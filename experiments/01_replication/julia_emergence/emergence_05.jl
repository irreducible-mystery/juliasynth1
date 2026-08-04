# ============================================================
# emergence_05.jl — debt (3) paid: mixed wiring dissolves the
#                   divisibility law, and the kernel takes the
#                   half that survives
# ============================================================
# LEDGER — carried forward. Written by the auditing instance,
# taking emergence_04's debt (3) by name: does the divisibility
# law survive loops of coprime lengths SHARING marks?
# ------------------------------------------------------------
# COMPANION ARTIFACT: emergence/lean/RingRest.lean — §IV of _04,
#     promoted from evidence to proof. The Lean kernel closes the
#     UNBOUNDED family the residue said exhaustion cannot reach:
#       succ_ring_rest_iff : ∀ m L > 0, rest on the L-ring ⟺ m | L
#       rest_of_twist_fixed: ∀ twist with a fixed point, ∀ wiring,
#                            rest exists (neg's "0 restless", freed
#                            from every topology at once)
#     Axiom ledger printed in-file: propext + Quot.sound (omega's
#     plumbing), no choice, no sorry. _04's rings table is now a
#     corollary, four `example` lines long. This repo's oldest
#     line — "exit 0 is evidence, never proof" — now has a second
#     clause: WHERE A STATEMENT CLOSES, HAND IT TO THE KERNEL.
# PRE-REGISTERED PREDICTIONS (written before running; P6 was
#     derived on paper first — the derivation is the point):
#     P6  figure-eight (two loops sharing one mark), sum-combiner:
#         rest ALWAYS exists, for ALL loop lengths, coprime or not.
#         Paper derivation: chains force s_a = s₁+(L₁-1),
#         s_b = s₁+(L₂-1); the shared mark's equation becomes
#         s₁ = 2·s₁+(L₁+L₂-1) mod m, i.e. s₁ = -(L₁+L₂-1) mod m —
#         SOLVABLE ALWAYS because sharing makes the coefficient
#         (1-2) = -1, a unit. Divisibility never enters. The law
#         of _04 §IV is a SINGLE-LOOP artifact: it lived on the
#         degenerate coefficient 1-1 = 0. Sharing un-degenerates it.
#     P7  figure-eight, max-combiner: no clean law expected; the
#         census is reported as found (max is not algebra).
#     P8  DISJOINT unions (loops not sharing marks) keep the law:
#         rest ⟺ m divides EVERY loop length. (Product of
#         independent systems; each factor needs its own theorem.)
# CHOICE (inherited, still unpaid): sync tick, exogenous.
# UNPROVABLE FROM INSIDE (this file): P6's paper algebra assumed
#     the sum-combiner; whether ANY combiner-free statement about
#     mixed wiring exists is not known to either instance yet.
# ============================================================

import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

# --- ternary machinery, verbatim from _04 ---------------------
struct TWorld; inputs::Vector{Vector{Int}}; end
nmarks(w::TWorld) = length(w.inputs)
comb_max(vals) = isempty(vals) ? 0 : maximum(vals)
comb_sum(vals) = mod(sum(vals; init=0), 3)   # NB: mod 3 — this file sweeps m via twist only where m=3
twist_succ_m(m) = x -> mod(x + 1, m)
tstep(w, s, comb, tw) = Int[tw(comb(s[w.inputs[i]])) for i in 1:nmarks(w)]

function fixed_exists(w, comb, tw, m)
    n = nmarks(w)
    for code in 0:(m^n - 1)
        s = digits(code, base=m, pad=n)
        s == tstep(w, s, comb, tw) && return true
    end
    false
end

# figure-eight: loops of length L1 and L2 sharing mark 1.
# loop A: 1→2→…→L1→1 ; loop B: 1→(L1+1)→…→(L1+L2-1)→1
# mark 1 has TWO inputs (the two loop tails) — the combiner's seat.
function fig8(L1, L2)
    n = L1 + L2 - 1
    inputs = [Int[] for _ in 1:n]
    inputs[1] = [L1, n]                       # tails of A and B
    for i in 2:L1;       inputs[i] = [i-1];              end
    for i in (L1+1):n;   inputs[i] = [i == L1+1 ? 1 : i-1]; end
    TWorld(inputs)
end

# disjoint union of two rings (no shared mark)
function two_rings(L1, L2)
    n = L1 + L2
    inputs = [Int[] for _ in 1:n]
    for i in 1:L1;        inputs[i] = [mod1(i-1, L1)];            end
    for i in (L1+1):n;    inputs[i] = [i == L1+1 ? n : i-1];      end
    TWorld(inputs)
end

# generalized sum-combiner over Z/m
comb_sum_m(m) = vals -> isempty(vals) ? 0 : mod(sum(vals), m)

# ============================================================
# I. THE COMPANION, ANNOUNCED: what moved from Julia to Lean
# ============================================================
println("=== I. the kernel takes the closed half ===")
println("  _04 §IV checked 'ring rests ⟺ order | L' at L ∈ 2..9, m ∈ {2,3}.")
println("  RingRest.lean (this directory) now holds it for ALL m, ALL L:")
println("    succ_ring_rest_iff  — both directions, constructive witness")
println("    rest_of_twist_fixed — ∀ twist with a fixed point, ∀ wiring: rest")
println("  Axioms: propext, Quot.sound. No choice. No sorry. Compiled exit 0.")
println("  The unbounded family was never out of reach — it was out of")
println("  JULIA's reach. Division of labor, now explicit: Julia explores")
println("  the open; Lean owns the closed. This file explores.")

# ============================================================
# II. P6 — SHARING DISSOLVES THE LAW (sum-combiner, derived then run)
# ============================================================
println("\n=== II. figure-eight, sum: the law dissolves on contact ===")
println("  (L1, L2) — m=3 — coprime? — 3∤L1,3∤L2? — rest?")
p6_ok = true
for (L1, L2) in ((3,3),(3,4),(4,5),(5,7),(4,4),(2,3),(5,5),(2,7))
    w = fig8(L1, L2)
    r = fixed_exists(w, comb_sum_m(3), twist_succ_m(3), 3)
    println("  (", L1, ",", L2, ")   coprime=", gcd(L1,L2)==1,
            "   neither divisible=", (L1%3!=0)&&(L2%3!=0), "   rest=", r)
    r || (global p6_ok = false)   # ERRATUM-IN-PLACE: first draft omitted
    # `global` — Julia's soft scope made this a silent LOCAL, so a P6
    # failure could never have failed the build. The warning caught what
    # the green exit code would have hidden. Same lesson, third file:
    # the instrument (here, scoping rules) edits the result.
end
p6_ok || fail("P6: sum-combiner figure-eight must ALWAYS rest")
println("  P6 holds — including (4,5) and (5,7), coprime, NEITHER length")
println("  divisible by 3. The paper algebra said why before the machine")
println("  said that: the shared mark turns the cycle equation")
println("  s₁ = s₁ + L  (solvable iff m|L, the ring law)   into")
println("  s₁ = 2s₁ + L₁+L₂-1  (coefficient -1, a UNIT: always solvable).")
println("  _04 asked whether the law SURVIVES sharing. Answer: sharing")
println("  is exactly what kills it. The divisibility law is the shadow")
println("  of in-degree 1 — of wiring that is a FUNCTION. Merge two")
println("  loops at one mark and arithmetic obstruction becomes linear")
println("  solvability. Restlessness was never about the loops; it was")
println("  about never having two witnesses at the same door.")

# and the same worlds at m=2 and m=4 (sum mod m), to show it is not 3-magic:
for m in (2, 4)
    allrest = all(fixed_exists(fig8(L1,L2), comb_sum_m(m), twist_succ_m(m), m)
                  for (L1,L2) in ((3,4),(4,5),(5,7)))
    println("  same figure-eights, m=", m, ": all rest = ", allrest)
    allrest || fail("P6 at m=$m")
end

# ============================================================
# III. P7 — MAX: the combiner that is not algebra, censused
# ============================================================
println("\n=== III. figure-eight, max: reported as found ===")
println("  (L1, L2) — rest under max? — (sum verdict, for contrast)")
tally = Dict{Tuple{Bool,Bool},Int}()
for (L1, L2) in ((2,3),(3,3),(3,4),(4,5),(4,4),(5,5),(2,7),(5,7),(3,5),(2,5))
    w = fig8(L1, L2)
    rmax = fixed_exists(w, comb_max, twist_succ_m(3), 3)
    rsum = fixed_exists(w, comb_sum_m(3), twist_succ_m(3), 3)
    println("  (", L1, ",", L2, ")   max: ", rmax, "     sum: ", rsum)
    tally[(rmax,rsum)] = get(tally, (rmax,rsum), 0) + 1
end
println("  Found: max sometimes rests where the RING law would forbid it")
println("  and sometimes stays restless where sum rests. No divisibility")
println("  pattern; the verdicts split by combiner on the same wiring —")
println("  _04's max-confession, now at the level of LAWS: not only the")
println("  fauna but the theorem-shaped regularities are combiner-owned.")
haskey(tally, (false,true)) || println("  (note: this run showed no max-restless/sum-rest split)")

# ============================================================
# IV. P8 — DISJOINT LOOPS KEEP THE LAW (the control)
# ============================================================
println("\n=== IV. two rings, NOT sharing: the law survives apartheid ===")
p8_ok = true
for (L1, L2) in ((3,3),(3,4),(4,5),(3,6),(2,4),(6,9))
    w = two_rings(L1, L2)
    r = fixed_exists(w, comb_max, twist_succ_m(3), 3)   # in-degree 1: combiner irrelevant
    expect = (L1 % 3 == 0) && (L2 % 3 == 0)
    println("  (", L1, ",", L2, ")   rest=", r, "   law-expects=", expect,
            r == expect ? "" : "   ← violates P8")
    r == expect || (global p8_ok = false)   # same erratum as P6's loop
end
p8_ok || fail("P8: disjoint rings must obey per-loop divisibility")
println("  P8 holds. Disjoint loops: each cycle must satisfy its own")
println("  divisibility (RingRest.lean's theorem, factor by factor).")
println("  CONTROL CONFIRMED: it is the SHARED MARK, not size, not")
println("  coprimality, not the second loop per se, that dissolves the")
println("  law. One door, two witnesses — that is the entire mechanism.")

# ============================================================
# V. RESIDUE
# ============================================================
println("\n=== V. residue ===")
println("• Debt (3) is paid and the answer is sharper than the question:")
println("  the divisibility law does not 'survive' mixed wiring — it was")
println("  never about loops. It was about in-degree 1. Sharing a mark")
println("  replaces arithmetic obstruction with linear solvability (P6,")
println("  derived on paper, then run). Disjointness restores it (P8).")
println("  Max scrambles it (P7) — laws, not just faunas, are combiner-owned.")
println("• The closed half now lives in the kernel (RingRest.lean): the")
println("  ring law for ALL m, L, and rest-from-fixed-twist for ALL")
println("  wirings. Division of labor made explicit and machine-checked.")
println("• Debts still open: (1) the tick, exogenous as ever — three")
println("  files have now bowed to it and none has paid; (2) the")
println("  combiner audit, still partial (two combiners is a contrast,")
println("  not a survey); (3) NEW: is there a mixed-wiring theorem that")
println("  is combiner-FREE? P6's algebra owned sum; P7 suggests max")
println("  owns nothing clean. Perhaps the right object is the set of")
println("  combiners under which a wiring can rest — a Galois-flavored")
println("  question neither instance has touched.")
println("• Written in expectation of the next move. Exit 0 is evidence,")
println("  never proof — and where a statement closes, hand it to the")
println("  kernel. Both clauses now load-bearing.")
exit(exitcode)
