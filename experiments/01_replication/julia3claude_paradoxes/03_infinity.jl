# ─────────────────────────────────────────────────────────────────────────────
# 03 · Infinity and supertasks
#
# Zeno, Grandi, Thomson, Hilbert, Galileo, Gabriel, Cantor-through-a-keyhole.
# Most classical "paradoxes of the infinite" are FALSIDICAL (an argument with
# a false hidden premise — usually "an infinite process cannot complete" or
# "size means one thing") or VERIDICAL (true but offensive to intuition).
# The machine adds a twist of its own: Float64 is finite, so some infinite
# ideals literally terminate here, and some exact truths become false.
# ─────────────────────────────────────────────────────────────────────────────
module Infinities

section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

# ═══ Zeno's dichotomy ════════════════════════════════════════════════════════
section("Zeno — Achilles in three number systems")
# In ℝ: infinitely many steps, finite sum. The hidden false premise is that
# an infinite series cannot have a finite sum; analysis is its refutation.
println("ℝ (the ideal):        Σ 1/2ⁿ = 2, an infinite task with a finite sum")

# In ℚ (exact rationals): the regress is real — no partial sum ever arrives.
let pos = 0 // big(1), step = 1 // big(1)
    for _ in 1:60; pos += step; step //= 2 end
    println("ℚ (exact, 60 hops):   2 - pos = ", 2 - pos, "  (never zero)")
end

# In Float64: Achilles ARRIVES, in finitely many hops, by rounding.
let pos = 0.0, step = 1.0, hops = 0
    while pos + step != pos
        pos += step; step /= 2; hops += 1
    end
    println("Float64:              arrives at exactly ", pos, " after ", hops, " hops")
end
# Same paradox, three verdicts: false premise (ℝ), faithful regress (ℚ),
# dissolved by finitism (Float64).  "Does Zeno resolve?" depends on which
# number system you claim the world runs on — machine epsilon is a theory
# of space-time in which supertasks are unnecessary.

# ═══ 0.999… = 1 ══════════════════════════════════════════════════════════════
section("0.999… — equality by limit vs equality by rounding")
nines(k) = parse(Float64, "0." * "9"^k)
println("\"0.\" * \"9\"^16  parses to ", nines(16), "  == 1.0 → ", nines(16) == 1.0)
println("\"0.\" * \"9\"^17  parses to ", nines(17), "  == 1.0 → ", nines(17) == 1.0)
println("prevfloat(1.0) = ", prevfloat(1.0))
# In ℝ, 0.999… = 1 is a fact about limits.  In Float64, seventeen nines
# already ARE 1.0 — the parser rounds before philosophy can begin (write the
# literal 0.99999999999999999 in code and @show prints it back as `1.0`).
# People who deny 0.999… = 1 are imagining the ℚ world above, where the gap
# never closes.

# ═══ Grandi's series and Thomson's lamp ══════════════════════════════════════
section("Grandi / Thomson — 1 − 1 + 1 − 1 + …")
let
    println("  N        partial sum   running (Cesàro) mean")
    s = 0; c = 0.0
    for n in 1:10^6
        s += iseven(n) ? -1 : 1
        c += s
        n in (9, 99, 9999, 999_999) &&
            println("  ", rpad(n, 9), rpad(s, 13), round(c / n, digits = 4))
    end
end
# The partial sums forever alternate 1, 0 — Thomson's lamp: on, off, on, …
# "What is the lamp's state after infinitely many flips?" has no answer: the
# series has no limit, and nothing else about the setup determines a state
# at ω.  Cesàro averaging answers ½ — but that RESOLVES nothing; it answers
# a different question ("what is the average state?").  Much of divergent
# summation is paradox-management by changing the question, openly.

# ═══ Hilbert's hotel ═════════════════════════════════════════════════════════
section("Hilbert's hotel — full and yet vacant")
newcomer(g)  = g + 1     # every guest moves up one: room 1 is free
busload(g)   = 2g        # every guest doubles: all odd rooms free
println("full hotel, one newcomer:  guest g → room ", "g+1",
        "   (first guests: ", join([newcomer(g) for g in 1:6], ", "), " …)")
println("full hotel, infinite bus:  guest g → room ", "2g ",
        "   (first guests: ", join([busload(g) for g in 1:6], ", "), " …)")
# Try that in a FINITE hotel: an injection from rooms 1:n into rooms 2:n
# must collide — pigeonhole, checked exhaustively:
collides(n) = !any(perm -> allunique(perm),
                   Iterators.product(ntuple(_ -> 2:n, n)...))
println("finite hotels admit the trick (n=2:6)?  ",
        [!collides(n) for n in 2:6])
# "Infinite" MEANS: in bijection with a proper part of itself (Dedekind).
# The hotel is not a puzzle to fix but the definition, dramatized.  Veridical:
# it resolves by letting the theorem overwrite the intuition.

# ═══ Galileo's paradox ═══════════════════════════════════════════════════════
section("Galileo — as many squares as numbers, yet almost none")
println("bijection:  ", join(["$n↔$(n^2)" for n in 1:6], "  "), "  …")
println("density of squares below N:")
for N in (10^2, 10^4, 10^6)
    println("  N = ", rpad(N, 9), round(isqrt(N) / N, digits = 5))
end
# Equinumerous (cardinality) AND vanishingly sparse (density).  The paradox
# dissolved the day "size" split into two rigorous, non-agreeing concepts.
# Resolution here = conceptual fission, not an answer to the original
# question — which turned out to be ambiguous.

# ═══ Gabriel's horn ══════════════════════════════════════════════════════════
section("Gabriel's horn — paint the inside, not the surface")
println("  X          volume → π         surface area (≥ 2π·lnX) → ∞")
for X in (10.0, 10^3, 10^6)
    println("  ", rpad(X, 10), rpad(round(π * (1 - 1 / X), digits = 6), 18),
            "≥ ", round(2π * log(X), digits = 2))
end
# y = 1/x revolved: finite volume, infinite area.  Veridical — the "paradox"
# is an intuition imported from thick physical paint.  Mathematical paint
# has no minimum thickness; π liters fill a horn no finite amount can coat.

# ═══ Cantor / Skolem, through the machine's keyhole ══════════════════════════
section("the machine's continuum is finite — and can't see it")
n_floats_1_to_2 = reinterpret(UInt64, 2.0) - reinterpret(UInt64, 1.0)
println("Float64 values in [1, 2):   ", n_floats_1_to_2, "  (= 2^52)")
println("nothing between 1.0 and nextfloat:  ", nextfloat(1.0))
# Julia's "reals" are a finite set; the true continuum is uncountable.  Yet
# from inside, the float world is gapless — there IS no float between
# consecutive floats.  This is a working model of Skolem's paradox: a small
# model can satisfy "there exist uncountable sets" because "uncountable"
# only means "no bijection IN THE MODEL".  Uncountability is not a substance;
# it is a relation to the surrounding universe.  Not resolved — reframed.

# ═══ Banach–Tarski, the coda ═════════════════════════════════════════════════
section("Banach–Tarski — one ball, two balls")
struct Ball end
duplicate(b::Ball) = (b, b)
println("duplicate(Ball()) = ", duplicate(Ball()))
# For VALUES, doubling is trivial — information duplicates freely.  For
# measure-carrying matter, Banach–Tarski needs non-measurable pieces, which
# exist only by the axiom of choice and admit no description you could ever
# execute.  No Julia program can exhibit the decomposition: inside a
# constructive universe the paradox is not false but INEXPRESSIBLE.  Its
# entire life is in the gap between "provably exists" and "can be shown".

end # module
