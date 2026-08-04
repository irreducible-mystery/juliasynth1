# ─────────────────────────────────────────────────────────────────────────────
# 06 · Identity and vagueness
#
# The Ship of Theseus and the Sorites are not puzzles WITH answers but
# demands FOR a decision.  Julia is unusually honest about this: it ships
# three equality operators (three theories of identity), a third truth value
# (a home for borderline cases), and a number type whose "paradoxes" are all
# violated expectations about which axioms survive finite representation.
# ─────────────────────────────────────────────────────────────────────────────
module IdentityVague

section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

# ═══ The Ship of Theseus ═════════════════════════════════════════════════════
section("Theseus — four theories of «the same ship»")
mutable struct Ship
    planks::Vector{Symbol}
    log::Vector{String}
end
Base.:(==)(a::Ship, b::Ship) = a.planks == b.planks     # qualitative identity

theseus  = Ship([Symbol("oak", i) for i in 1:5], ["built in Athens"])
original = copy(theseus.planks)
harbor_ship = theseus                                    # a second name, same object
salvage = Symbol[]
for i in 1:5                                             # replace every plank
    push!(salvage, theseus.planks[i])
    theseus.planks[i] = Symbol("pine", i)
    push!(theseus.log, "replaced plank $i")
end
scavenger = Ship(salvage, ["reassembled from the discarded planks"])

println("numeric identity   harbor_ship === theseus:      ", harbor_ship === theseus)
println("qualitative        theseus == Ship(original,[]):  ", theseus == Ship(original, String[]))
println("qualitative        scavenger == Ship(original,[]):", scavenger == Ship(original, String[]))
println("material overlap   theseus:   ", length(intersect(theseus.planks, original)), "/5 original planks")
println("material overlap   scavenger: ", length(intersect(scavenger.planks, original)), "/5 original planks")
println("causal history     theseus.log has ", length(theseus.log), " entries; scavenger.log has ", length(scavenger.log))
# Which is "the" ship?  Julia refuses to let you ask without choosing an
# operator: `===` (continuity of reference) crowns the repaired ship;
# structural `==` and material overlap crown the scavenger's; the log —
# causal history — tells a story for each.  Natural language lets "same"
# stay ambiguous; a programming language makes the ambiguity a compile-time
# decision.  The paradox does not resolve.  It was never one question.

# Heraclitus, one line: same river, different water —
let river = [:water1]; r2 = river; push!(river, :water2)
    println("Heraclitus:        r2 === river: ", r2 === river,
            "  (same identity, changed content — identity through change IS mutation)")
end

# ═══ Equality is relation-relative even for numbers ══════════════════════════
section("three equalities, four awkward customers")
pairs_ = [(NaN, NaN), (0.0, -0.0), (1, 1.0), (missing, missing)]
println(rpad("pair", 22), rpad("==", 10), rpad("===", 10), "isequal")
for (a, b) in pairs_
    println(rpad("($(repr(a)), $(repr(b)))", 22),
            rpad(repr(a == b), 10), rpad(repr(a === b), 10), repr(isequal(a, b)))
end
# NaN ≠ NaN: a thing not equal to itself — the liar of arithmetic, standard-
# ized by IEEE-754 (it marks "no value" pretending to be a value).  0.0 and
# -0.0: equal but distinguishable.  1 and 1.0: equal across types.  missing:
# equality itself goes missing.  There is no one relation "equality"; there
# are purposes.

# ═══ Kleene's tables — the logic where the liar lives ════════════════════════
section("missing — Julia's native three-valued logic")
sym(x) = x === missing ? "•" : x ? "T" : "F"
vals = (false, missing, true)
for (name, op) in (("AND", &), ("OR", |))
    println("  ", name, ":   ", join((sym(v) for v in vals), "  "))
    for a in vals
        println("   ", sym(a), "    ", join((sym(op(a, b)) for b in vals), "  "))
    end
end
println("  NOT:  ", join((sym(!(v)) for v in vals), "  "), "   ← !• = • : the liar's fixed point")
# This is Kleene's strong K3 — the semantics in which Kripke found the liar
# a stable (ungrounded) home.  Julia adopted it for data; it is equally a
# theory of truth-value gaps.

# ═══ The Sorites ═════════════════════════════════════════════════════════════
section("sorites — one grain at a time, four ways out")
# The classical forced march: heap(1_000_000), and ∀n heap(n) → heap(n-1):
println("classical: heap(10⁶) ∧ (heap(n)→heap(n-1))  ⊢  heap(0)   — absurd,")
println("           so classical logic must reject a premise it cannot point to.")
# 1 · Epistemicism: there IS a sharp boundary; you just can't know it.
secret = 1000 + hash("sorites") % 9000          # determinate, arbitrary, unknowable-in-spirit
println("epistemicist:      heap(n) ⟺ n ≥ ", "⟨a fact you cannot inspect⟩",
        "   (here: some n* ∈ [1000, 10000])")
println("                   heap(", secret + 1, ") = true, heap(", secret, ") = false — says who?")
# 2 · Supervaluation: a gap, honestly reported.
sv_heap(n) = n >= 10_000 ? true : n <= 100 ? false : missing
println("supervaluationist: heap(50000)=", sv_heap(50000), "  heap(5000)=", repr(sv_heap(5000)),
        "  heap(3)=", sv_heap(3))
# 3 · Fuzzy: membership comes in degrees.
fz_heap(n) = clamp((log10(max(n, 1)) - 2) / 2, 0.0, 1.0)
println("fuzzy:             ", join(("heap($n)=$(round(fz_heap(n), digits=2))"
                                     for n in (10, 500, 5_000, 100_000)), "  "))
# 4 · The engineer: pick a threshold, document it, move on (every codebase
#     that ever branched on `n > LIMIT` is an applied theory of vagueness).
# The march is FALSIDICAL in each formalism (some premise fails: tolerance,
# bivalence, or crisp membership) — but which formalism is right is not a
# theorem.  Vagueness doesn't resolve; it gets managed, per-application.

# ═══ Floating point — the paradoxes of finite arithmetic ═════════════════════
section("floats — familiar axioms, quietly repealed")
@show 0.1 + 0.2 == 0.3
@show (0.1 + 0.2) + 0.3 == 0.1 + (0.2 + 0.3)
@show sum(fill(0.1, 10)) == 1.0
@show 0.1 + 0.2 ≈ 0.3
# Falsidical paradoxes, all: the hidden false premise is "these are the real
# numbers".  They are 64-bit fractions with a rounding rule; associativity
# did not survive the trip.  `≈` (isapprox) is the honest repair — change
# the question from identity to proximity, which is all measurement ever
# gave anyone anyway.

end # module
