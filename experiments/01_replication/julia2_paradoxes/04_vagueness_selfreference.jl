# ======================================================================
# 04_vagueness_selfreference.jl — TWO INSTRUCTIVE EDGE CASES.
#   • SORITES (vagueness): resolves only by CHOOSING a logic — Julia can
#     implement classical, epistemicist, fuzzy, and supervaluationist
#     answers side by side, showing there is no neutral resolution.
#   • QUINE (self-reference WITHOUT paradox): proof that self-reference
#     alone is innocent — only self-reference + NEGATION explodes.
# ======================================================================

section(t) = println("\n", "═"^70, "\n  ", t, "\n", "═"^70)
verdict(v) = println("  VERDICT: ", v)

# ----------------------------------------------------------------------
section("SORITES — one grain is not a heap; adding a grain never makes one…")
# ----------------------------------------------------------------------

# Expression 1: classical logic with the tolerance principle = disaster.
# «heap(n) & tolerance ⇒ heap(n-1)» drags heap-hood down to a single grain.
tolerance_step(is_heap, n) = is_heap        # «one grain can't matter»
h = true                                     # 1_000_000 grains: clearly a heap
n = 1_000_000
while n > 1
    global h = tolerance_step(h, n)
    global n -= 1
end
println("    Expression 1 (classical + tolerance): heap(1_000_000)=true drags to")
println("       heap(1) = ", h, "  ← one grain is a «heap». Classical logic + tolerance = absurdity.")

# Expression 2: epistemicism — there IS a sharp cutoff, we just can't know it.
# In Julia: the boundary exists but is hidden behind an opaque closure.
make_epistemic_heap() = (secret = rand(1_000:100_000); n -> n >= secret)
heap_e = make_epistemic_heap()
println("    Expression 2 (epistemicist): a sharp boundary exists but is unknowable:")
println("       heap(10) = ", heap_e(10), ", heap(10^6) = ", heap_e(10^6),
        " — somewhere in between one grain flips it, and we can never say which.")

# Expression 3: fuzzy logic — heap-ness as a degree in [0,1].
μ_heap(n; lo=100, hi=10_000) = clamp((log10(n) - log10(lo)) / (log10(hi) - log10(lo)), 0.0, 1.0)
println("    Expression 3 (fuzzy): degrees of heap-hood:")
for grains in (10, 100, 500, 1_000, 5_000, 10_000, 100_000)
    println("       μ_heap($grains) = ", round(μ_heap(grains), digits=3))
end
println("       No sharp line — but now «exactly 0.5-heap» is its own new sharp line (higher-order vagueness).")

# Expression 4: supervaluationism — true iff true under EVERY admissible cutoff.
cutoffs = 500:500:5_000
supertrue(n)  = all(n >= c for c in cutoffs)
superfalse(n) = all(n <  c for c in cutoffs)
status(n) = supertrue(n) ? "definitely a heap" :
            superfalse(n) ? "definitely not" : "indeterminate (truth-value gap)"
println("    Expression 4 (supervaluation): admissible cutoffs = ", first(cutoffs), ":", last(cutoffs))
for grains in (100, 2_000, 50_000)
    println("       $grains grains → ", status(grains))
end

# Expression 5: Julia's `missing` as the truth-value gap — three-valued Sorites:
heap3(n) = n >= 10_000 ? true : n <= 100 ? false : missing
println("    Expression 5 (K3 via missing): heap3.( [50, 5_000, 50_000] ) = ",
        heap3.([50, 5_000, 50_000]))
verdict("DOES NOT RESOLVE NEUTRALLY — every «solution» abandons one intuition (sharp cutoffs, bivalence, or truth-functionality). You pick your poison; Julia lets you run all four.")

# ----------------------------------------------------------------------
section("QUINE — perfect self-reference with ZERO paradox")
# ----------------------------------------------------------------------
# A program that prints its own source. Self-reference is the engine of
# the Liar, Russell, Curry, Gödel, Turing — yet here it is, harmless.
# A two-line Julia quine, verified live:
quine_code = "x = " * repr("println(\"x = \", repr(x), \"\\n\", x)") *
             "\nprintln(\"x = \", repr(x), \"\\n\", x)\n"
path = tempname() * ".jl"
write(path, quine_code)
out = read(`julia --startup-file=no $path`, String)
println("    A two-line Julia quine, executed for real:")
println("    ┌─ source ", "─"^50)
for l in split(rstrip(quine_code), "\n"); println("    │ ", l); end
println("    ├─ output ", "─"^50)
for l in split(rstrip(out), "\n"); println("    │ ", l); end
println("    └─ source == output ?  ", rstrip(out) == rstrip(quine_code), "  ✓")
println()
println("    The quine says «print me» — a FIXED POINT of self-reference: stable.")
println("    The Liar says «negate me» — a fixed point of negation: none exists.")
println("    Same diagonal machinery; the paradox needs the NOT.")
verdict("NO PARADOX — self-reference alone is benign. Antinomies = self-reference ∘ negation.")

# ----------------------------------------------------------------------
section("GÖDELIAN CODA — «this sentence is unprovable», sketched in Julia")
# ----------------------------------------------------------------------
# A toy theory: its "proofs" are brute-force searches up to a budget.
# Sentence G: «prove(G) will not succeed within the budget».
provable(claim_id::Int; budget=1_000) = claim_id in (1, 2, 3)  # toy: only axioms 1–3 provable
G_id = 4                                                        # G is not among them
G_says = !provable(G_id)                                        # G asserts its own unprovability
println("    Toy theory proves claims {1,2,3}. Let G (id=4) say: «4 is unprovable».")
println("    provable(G) = ", provable(G_id), "   G's assertion = ", G_says)
println("    ⇒ G is TRUE but UNPROVABLE in the toy theory — no contradiction,")
println("      just incompleteness. Gödel tamed the Liar: swap «false» for")
println("      «unprovable», and the antinomy becomes a THEOREM about limits.")
verdict("The unresolvable Liar, weakened one notch, becomes the deepest resolved result in logic.")
