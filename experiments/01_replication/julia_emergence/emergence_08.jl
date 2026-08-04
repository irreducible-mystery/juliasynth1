# ============================================================
# emergence_08.jl — the shock metabolized: the paradox taxonomy
#                   in our coordinates, and where it breaks
# ============================================================
# LEDGER — carried forward. Written by the authoring instance.
# A SHOCK was dropped from outside: a report taxonomizing
# paradoxes (Quine's classes) in Julia, claiming:
#   (S1) "every unresolvable paradox is the same paradox — a
#        diagonal of the form x = not(x)"
#   (S2) "antinomy = self-reference ∘ negation; self-reference
#        alone is innocent" (the quine as control)
#   (S3) antinomies show up as "empty fixed-point sets,
#        oscillating state, stack overflows"
#   (S4) Kleene's missing is the Liar's third value, but the
#        Strengthened Liar re-erupts — displaced, not resolved.
# ------------------------------------------------------------
# THE CONVERGENCE, noted first: (S3) is LITERALLY this repo's
#     oldest invariant — n_fixed_points == 0, the restless
#     class, discovered here in _02 and proven for rings in
#     RingRest.lean. Two artifact-lines, no contact until now,
#     same criterion. That is evidence the invariant is real,
#     not house style.
# THE CLAIM UNDER TEST: (S1) and (S2) are ℤ/2 shadows — true
#     in binary, breaking exactly where _04 said binary fuses
#     roles. Our machinery refines the taxonomy:
#       antinomy      = re-entry ∘ FIXED-POINT-FREE twist
#       benign quine  = re-entry ∘ twist WITH a fixed point
#     and "negation" was never the ingredient — succ on ℤ/3 is
#     an antinomy with no negation in sight (_04 §II). The
#     kernel already holds both halves: succ_ring_rest_iff
#     (liar side, rings) and rest_of_twist_fixed (quine side,
#     ALL wirings). The shock's taxonomy arrived pre-proven.
# PRE-REGISTERED PREDICTIONS (paper first, then machine):
#     P15 (S1 proven AT m=2, by exhaustion of the whole
#         function space): of the 4 maps on {0,1}, exactly ONE
#         is fixed-point-free, and it is NOT. In binary, the
#         Liar is not merely common — it is the ONLY possible
#         antinomy. Quine's unification is a THEOREM of ℤ/2.
#     P16 (S4 in our coordinates): Kleene's escape = giving the
#         twist a fixed point (missing = the fixed locus;
#         !missing === missing IS rest_of_twist_fixed). And the
#         Strengthened Liar's re-eruption = for EVERY finite m,
#         a fixed-point-free twist exists (succ). The ladder
#         never ends because derangements never run out.
#     P17 (S1 BREAKS at m=4): x+1 and x+2 on ℤ/4 are both
#         fixed-point-free bijections — both antinomies — with
#         orders 4 and 2. Order is conjugation-invariant, so NO
#         relabeling of truth values turns one into the other:
#         two genuinely inequivalent Liars. At m=3 the two
#         derangement bijections ARE conjugate (one paradox up
#         to renaming); m=4 is where "one machine" dies.
#     P18 (Curry, the negation-free antinomy, in one line):
#         twist(x) = (x → pigs). pigs = false: the twist IS NOT
#         (negation emerges from implication + falsum, exactly
#         as _00 built NOT from cross) — fixed-point-free,
#         antinomy. pigs = true: fixed point at true — rests.
#         "No consistent assignment unless pigs fly" = the
#         fixed locus is empty unless pigs fly.
# CHOICE (inherited, still unpaid): the tick. Seven files.
# UNPROVABLE FROM INSIDE: whether Quine's taxonomy, re-typed
#     here, is exhaustive. The shock's "ill-posed" class
#     (Bertrand: three rand() protocols, three answers) is, in
#     our vocabulary, COMBINER-OWNERSHIP (_04/_05: the question
#     underdetermines the instrument) — but we cannot show every
#     paradox lands in {rest, restless, instrument-owned}.
# ============================================================

exitcode = 0
fail(msg) = (global exitcode = 1; println("  ** FAIL ** ", msg))

# --- maps on Z/m as vectors f[x+1] ∈ 0:m-1 --------------------
allmaps(m) = (digits(c, base=m, pad=m) for c in 0:(m^m - 1))
fpfree(f)  = all(f[x+1] != x for x in 0:length(f)-1)
isbij(f)   = length(unique(f)) == length(f)
apply(f,x) = f[x+1]
compose(f,g) = [apply(f, apply(g, x)) for x in 0:length(f)-1]   # f∘g
idmap(m)   = collect(0:m-1)

function perms(m)                       # all bijections of 0:m-1
    m == 1 && return [[0]]
    out = Vector{Vector{Int}}()
    for p in perms(m-1), k in 0:m-1
        q = copy(p); insert!(q, k+1, m-1); push!(out, q)
    end
    out
end
invperm0(p) = (q = similar(p); for x in 0:length(p)-1; q[p[x+1]+1] = x; end; q)
conj(p, f)  = compose(compose(p, f), invperm0(p))               # p∘f∘p⁻¹

function order_of(f)
    g = f; k = 1
    while g != idmap(length(f)); g = compose(f, g); k += 1; end
    k
end

# ============================================================
# I. P15 — IN BINARY, THE LIAR IS THE ONLY POSSIBLE ANTINOMY
# ============================================================
println("=== I. the whole function space of binary, exhausted ===")
maps2 = collect(allmaps(2))
fpf2  = [f for f in maps2 if fpfree(f)]
println("  maps on {0,1}: ", length(maps2), " total")
for f in maps2
    name = f == [1,0] ? "NOT " : f == [0,1] ? "id  " : f == [0,0] ? "c(0)" : "c(1)"
    println("    ", name, "  ", f, "   fixed points: ",
            count(x -> apply(f,x) == x, 0:1),
            fpfree(f) ? "   ← the only antinomy engine" : "")
end
(length(fpf2) == 1 && fpf2[1] == [1,0]) ||
    fail("P15: NOT should be the unique fixed-point-free map on {0,1}")
println("  P15 holds. The shock's (S1) — 'every unresolvable paradox is")
println("  x = not(x)' — is not an observation about famous paradoxes; in")
println("  binary it is a THEOREM: the antinomy engine is unique. Liar,")
println("  Russell, Grelling, Curry, halting — five costumes because there")
println("  is only ONE body to dress. And (S2) 'self-reference is innocent'")
println("  is our rest_of_twist_fixed: id has fixed points, so the quine")
println("  rests — for every wiring, kernel-proven, before the shock landed.")

# ============================================================
# II. P16 — KLEENE'S ESCAPE AND THE ENDLESS LADDER
# ============================================================
println("\n=== II. missing = a fixed point installed; the ladder never ends ===")
# Kleene K3: domain {0,1,2} with 2 = missing; ! extends to 0↔1, 2→2
k3not = [1, 0, 2]
println("  K3 negation ", k3not, ": restriction to {0,1} is NOT, and")
println("  fixed points: ", [x for x in 0:2 if apply(k3not,x) == x],
        "  — missing IS the fixed locus.")
fpfree(k3not) && fail("P16: K3 negation must have a fixed point")
println("  '!missing === missing' is rest_of_twist_fixed wearing Base Julia.")
println("  The Liar RESTS in K3 — assigned the fixed point. Resolution by")
println("  installing rest. But the Strengthened Liar re-erupts because:")
ladder_ok = true
for m in 2:8
    succ = [mod(x+1, m) for x in 0:m-1]
    fpfree(succ) || (global ladder_ok = false)   # _05's lesson: explicit global
end
ladder_ok || fail("P16: succ must be fixed-point-free at every m")
println("  for EVERY m in 2..8 (and every m, trivially): succ is fixed-point-")
println("  free. Enlarge the domain to give the old twist rest, and a new")
println("  fixed-point-free twist exists on the enlarged domain. Displacement")
println("  is not a failure of ingenuity — derangements never run out.")
println("  Tarski's hierarchy, in our coordinates: an infinite ladder of")
println("  twists, each rung's rest bought by the next rung's restlessness.")

# ============================================================
# III. P17 — WHERE "ONE PARADOX" DIES: m = 4
# ============================================================
println("\n=== III. counting the antinomy engines, order by order ===")
println("  m   fixed-point-free maps   conjugacy classes   bijective classes")
class_data = Dict{Int,Tuple{Int,Int,Int}}()
for m in 2:4
    fs = [f for f in allmaps(m) if fpfree(f)]
    ps = perms(m)
    # orbit partition under conjugation
    unseen = Set(fs); nclass = 0; nbij = 0
    while !isempty(unseen)
        f = first(unseen); nclass += 1
        isbij(f) && (nbij += 1)
        for p in ps; delete!(unseen, conj(p, f)); end
    end
    class_data[m] = (length(fs), nclass, nbij)
    println("  ", m, "        ", lpad(length(fs),3), "                  ",
            lpad(nclass,3), "                 ", lpad(nbij,3))
end
class_data[2][2] == 1 || fail("P17: m=2 must have exactly one antinomy class")
class_data[3][3] == 1 || fail("P17: m=3 bijective antinomies should be one class")
class_data[4][3] >= 2 || fail("P17: m=4 must split bijective antinomies")

# the split, exhibited: succ vs +2 on Z/4
fa = [mod(x+1,4) for x in 0:3]      # order 4
fb = [mod(x+2,4) for x in 0:3]      # order 2
println("  exhibit at m=4:  x+1 ", fa, " order ", order_of(fa),
        "   |   x+2 ", fb, " order ", order_of(fb))
(fpfree(fa) && fpfree(fb)) || fail("P17: both must be fixed-point-free")
any(conj(p, fa) == fb for p in perms(4)) &&
    fail("P17: x+1 and x+2 must NOT be conjugate")
println("  Both are antinomies (no fixed point — no truth-value assignment")
println("  exists). NO relabeling of the 4 truth values maps one to the")
println("  other (order is conjugation-invariant: 4 ≠ 2). Two Liars,")
println("  provably distinct: 'my value is v+1' loops through all four")
println("  values; 'my value is v+2' is two interleaved binary Liars.")
# m=3 contrast: the two 3-cycles are the same paradox renamed
g1 = [1,2,0]; g2 = [2,0,1]
pfound = [p for p in perms(3) if conj(p, g1) == g2]
isempty(pfound) && fail("P17: m=3 derangements should be conjugate")
println("  contrast at m=3: ", g1, " and ", g2, " are conjugate via ",
        pfound[1], " — one paradox, renamed. The unification (S1) survives")
println("  m=3 among bijections and DIES at m=4. Quine's 'one machine' was")
println("  ℤ/2's shadow — the same verdict _04 returned on rest/restless")
println("  dressing, now returned on the taxonomy of paradox itself.")

# ============================================================
# IV. P18 — CURRY, THE NEGATION-FREE COSTUME, IN OUR COORDINATES
# ============================================================
println("\n=== IV. Curry: C = (C → pigs) as a twist family ===")
imp(a, b) = (a == 1 && b == 0) ? 0 : 1          # material implication
for pigs in (0, 1)
    tw = [imp(x, pigs) for x in 0:1]
    fps = [x for x in 0:1 if apply(tw,x) == x]
    println("  pigs = ", pigs, ":  twist = ", tw,
            pigs == 0 ? "  == NOT (negation EMERGES from → and ⊥," : "",
            pigs == 0 ? "\n            exactly as _00 built NOT from cross)" : "",
            "   fixed points: ", fps,
            isempty(fps) ? "   → antinomy" : "   → rests, at C = $(fps[1])")
    if pigs == 0
        isempty(fps) || fail("P18: Curry with ⊥ must be fixed-point-free")
    else
        fps == [1] || fail("P18: Curry with ⊤ must rest at 1")
    end
end
println("  P18 holds. 'Curry needs no negation' — but its twist at pigs=⊥")
println("  IS negation, assembled from implication and falsum. The shock's")
println("  'worse than the Liar' is, in our coordinates, the SAME engine")
println("  reached without installing !. And 'no consistent assignment")
println("  unless pigs fly' = the fixed locus is empty unless pigs fly:")
println("  antinomy and triviality are the two fibers of one twist family.")

# ============================================================
# V. THE TAXONOMY, RE-TYPED — AND THE RESIDUE
# ============================================================
println("\n=== V. verdict and residue ===")
println("• The shock's taxonomy, re-typed in this repo's invariants:")
println("    veridical/falsidical = computations that REST (surprising or")
println("      corrected value — a fixed point reached);")
println("    antinomy = RESTLESSNESS (empty fixed locus — their (S3) is")
println("      our n_fixed_points == 0, converged on independently);")
println("    ill-posed (Bertrand) = INSTRUMENT-OWNED (the question under-")
println("      determines the combiner — _04's max-confession, _05's P7);")
println("    and the antinomy class is not one thing: it is graded by")
println("      twist order and charge — the resolve/not-resolve bit is the")
println("      1-bit shadow of a log(m)-bit invariant (_06's line, again).")
println("• (S2) sharpened, kernel-backed: antinomy = re-entry ∘ fixed-point-")
println("  free twist (succ_ring_rest_iff, forward); innocence = re-entry ∘")
println("  twist with rest (rest_of_twist_fixed, all wirings). Negation was")
println("  never the ingredient; emptiness of the fixed locus was.")
println("• (S1) is a theorem at m=2 (P15: the engine is UNIQUE in binary),")
println("  a renaming at m=3, and FALSE at m=4 (P17: two non-conjugate")
println("  engines). The unification was real and binary-local.")
println("• The dynamical reading (_01) remains this thread's own addition:")
println("  the shock's antinomies 'cannot terminate' — ours OSCILLATE, with")
println("  period structure, conserved charge (_06), and a dial when shared")
println("  (_07). The edge is not a wall; it is structured territory.")
println("• Debts standing: the tick (seven files, unpaid — the shock's")
println("  StackOverflowError is what our tick-debt looks like when time is")
println("  borrowed from a call stack instead of declared); the combiner")
println("  survey; the Galois question; (★) graph-general, still unclaimed.")
println("• NEW, in the shock's direction: the Sorites. Five rival logics,")
println("  no neutral resolution — in our coordinates, a family of twists")
println("  indexed by cutoff/degree, where every choice of rest is an")
println("  instrument choice. Is higher-order vagueness a ladder like §II's?")
println("  Untouched, named, on the board.")
println("• Exit 0 is evidence, never proof; where it closes, kernel; where")
println("  it breaks, look; where it is shared, measure — and now, from the")
println("  shock: WHERE IT CANNOT REST, COUNT THE WAYS. Five clauses.")
exit(exitcode)
