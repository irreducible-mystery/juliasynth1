# ─────────────────────────────────────────────────────────────────────────────
# 01 · The liar and its family — antinomies of self-reference
#
# An antinomy is not a puzzle with a hidden answer; it is a proof that some
# set of background commitments cannot all be kept.  A running language
# cannot host a contradiction — nothing makes Julia return both `true` and
# `false` for the same call.  So every antinomy, translated into Julia,
# is forced into one of four shapes:
#
#   no model       — exhaustive search over a finite domain comes back empty
#   divergence     — the definition is legal, the call never returns
#   a third value  — `missing` (Kleene's K3) gives the liar a fixed point
#   an error       — the runtime refuses a violation of stratification
#
# "Resolving" the liar is precisely choosing which of these prices to pay.
# This file renders the liar as many ways as the language allows.
# ─────────────────────────────────────────────────────────────────────────────
module LiarAndFriends

section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

# ═══ Rendering 1: the liar as a fixed-point equation ═════════════════════════
# "This sentence is false" is the equation  L == !L.
# "This sentence is true" (the truth-teller) is  T == T.
fixpoints(f, dom) = [x for x in dom if isequal(f(x), x)]

section("1 · fixed-point search (model theory)")
println("x == !x  over Bool:                  ", fixpoints(!, (false, true)))
println("x == x   over Bool:                  ", fixpoints(identity, (false, true)))
# The liar is OVERdetermined (no model); the truth-teller is UNDERdetermined
# (two models). Both are defective — in opposite directions.
println("x == !x  over Kleene {F, •, T}:      ", fixpoints(!, (false, true, missing)))
println("x == x   over Kleene {F, •, T}:      ", fixpoints(identity, (false, true, missing)))
# Julia's `missing` obeys !missing === missing — Kleene's strong three-valued
# logic, the semantics Kripke used for his fixed-point theory of truth.
# The liar has no classical truth value but exactly one *ungrounded* one.
# Julia ships the resolution as a first-class value.

# ═══ Rendering 2: the liar as recursion ══════════════════════════════════════
section("2 · direct self-reference (recursion)")
liar() = !liar()
caught = try liar() catch e; e end
println("liar() = !liar()  evaluates to…      ", typeof(caught))
# In logic the liar explodes the theory; in a running language it exhausts
# the stack.  Divergence is the computational shadow of inconsistency:
# Julia stays consistent by letting the paradox never return.

# ═══ Rendering 3: use vs mention (quote and eval) ════════════════════════════
section("3 · quotation — Tarski's object/meta distinction")
liar_expr = :( Core.eval(@__MODULE__, liar_expr) == false )
println("mentioned (quoted), it is inert:     ", liar_expr)
used = try Core.eval(@__MODULE__, liar_expr) catch e; e isa LoadError ? e.error : e end
println("used (evaluated), it diverges:       ", typeof(used))
# You may *talk about* the liar sentence all day (an Expr is just data);
# only *asserting* it — collapsing mention into use — diverges.  Tarski's
# hierarchy of languages is the quote operator, taken as law.

# ═══ Rendering 4: the stratified liar (a macro with fuel) ════════════════════
section("4 · stratification — the liar with fuel")
macro liar(fuel::Int)
    fuel <= 0 ? :(missing) : :( !(@liar($(fuel - 1))) )
end
println("@liar(1)  = ", repr(@liar(1)))
println("@liar(10) = ", repr(@liar(10)))
# A fuel-less version — macro liar() = :( !(@liar()) ) — would expand forever;
# the compiler is the enforcer.  Give self-reference a depth budget and every
# level bottoms out in `missing`: stratify the liar and you find it was
# never grounded in anything.

# ═══ Rendering 5: type-level liar (dispatch) ═════════════════════════════════
section("5 · the same emptiness, in the type system")
struct TrueT end; struct FalseT end
neg(::TrueT) = FalseT(); neg(::FalseT) = TrueT()
println("solutions of neg(x) == x in {TrueT,FalseT}:  ",
        [x for x in (TrueT(), FalseT()) if neg(x) == x])

# ═══ Curry's paradox: «if this sentence is true, then 0 == 1» ════════════════
section("Curry — the liar without negation")
curry_models(X) = [c for c in (false, true) if c == (!c | X)]   # C ↔ (C → X)
println("models of C ↔ (C → 0==1):            ", curry_models(false))
println("models of C ↔ (C → 0==0):            ", curry_models(true))
# With a false consequent the sentence is unsatisfiable — same shape as the
# liar, achieved without `!`.  In a logic with a naive truth predicate you
# can't reject the sentence, so it *proves* 0 == 1; model search instead
# just reports "no model".  The operational rendering diverges like the liar:
curry() = curry() ? (0 == 1) : true
println("curry() evaluates to…                ", typeof(try curry() catch e; e end))

# ═══ Grelling–Nelson: is "heterological" heterological? ══════════════════════
section("Grelling — heterological words")
const LEXICON = Dict{String,Function}(
    "short"         => w -> length(w) < 6,
    "polysyllabic"  => w -> length(w) > 8,
    "capitalized"   => w -> !isempty(w) && isuppercase(w[1]),
)
heterological(w) = !(LEXICON[w](w))
for w in ("short", "polysyllabic", "capitalized")
    println(rpad("\"$w\"", 16), heterological(w) ? "heterological" : "autological")
end
LEXICON["heterological"] = heterological          # the fatal dictionary entry
g = try heterological("heterological") catch e; e end
println(rpad("\"heterological\"", 16), typeof(g))
# The predicate is harmless on every word except the one that names it.
# Adding it to its own lexicon is the exact move naive comprehension makes.

# ═══ Russell's paradox ═══════════════════════════════════════════════════════
section("Russell — the predicate of all predicates that don't apply to themselves")
russell(p) = !p(p)
println("russell(russell) evaluates to…       ", typeof(try russell(russell) catch e; e end))

# Julia's heap is non-well-founded: a collection can contain itself.
Ω = Any[]; push!(Ω, Ω)
println("Ω := [Ω];  Ω[1] === Ω:               ", Ω[1] === Ω)
println("asking Ω == Ω structurally:          ", typeof(try Ω == Ω catch e; e end))
# Identity (===) handles self-membership fine; *structural* equality — which
# must look inside — falls into the well.  Aczel's anti-founded sets live
# happily in the heap, but only intensionally.

# ZFC's cure, enacted by the language: comprehension is only ever *Separation* —
# you filter a collection you already have, never "all collections whatsoever".
universe = Any[Any[1], Any[2, 3], Ω]
R = [a for a in universe if !any(x -> x === a, a)]   # Russell set, relativized
println("R = {a ∈ universe : a ∉ a} has ", length(R), " members;  R ∈ R?  ",
        any(x -> x === R, R))
# R is a fresh array, not in `universe`, so no contradiction: exactly why
# Separation is safe where naive comprehension explodes.  Julia has no
# first-class "set of all heap objects" to comprehend over — the proper
# class is unreachable by design.

# ═══ The barber — same schema, different verdict ═════════════════════════════
section("the barber of Seville")
println("b == !b (does the barber shave himself?):  ",
        [b for b in (false, true) if b == !b])
# Empty — and that is a RESOLUTION: there is no such barber.  The identical
# schema is an antinomy for Russell only because naive set theory *promised*
# the set exists.  Nothing promised the barber.  Whether a paradox "resolves"
# is relative to which background guarantee you refuse to give up.

# ═══ Self-membership the type system happily allows ══════════════════════════
section("Julia's universe is non-well-founded and doesn't mind")
@show DataType isa DataType
@show Type isa Type
@show Any isa Any
@show Union{} <: Int
@show all(isodd, Int[]) && all(iseven, Int[])
# The type of all types is one of its own instances; the universal type Any
# contains itself; the empty type Union{} is a subtype of everything (ex falso
# quodlibet); and every claim about the empty collection is true (vacuous
# truth — all my unicorns are green, and also not green).  Russell's paradox
# needed unrestricted *comprehension*, not self-membership; deny the former
# and the latter is harmless furniture.

end # module
