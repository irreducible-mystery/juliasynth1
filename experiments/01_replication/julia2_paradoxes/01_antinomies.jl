# ======================================================================
# 01_antinomies.jl — ANTINOMIES: paradoxes that DO NOT resolve.
# In Julia they manifest as: StackOverflowError, empty fixed-point sets,
# oscillating state, or refuted oracles. The only "escape" is to change
# the logic itself (Julia's `missing` = Kleene's 3-valued logic).
# ======================================================================

section(t) = println("\n", "═"^70, "\n  ", t, "\n", "═"^70)
verdict(v) = println("  VERDICT: ", v)

"""
Run a computation expected to diverge, sandboxed in its own Task
(its own stack) so the inevitable collapse is observable from outside —
we give the paradox a private universe and watch it implode.
"""
function safe(f; label="")
    print("    ", label, " → ")
    t = Task(f); schedule(t)
    try
        wait(t)
        println("returned: ", t.result)
    catch
        println("💥 ", nameof(typeof(t.exception)),
                " — no classical value exists; the computation diverges.")
    end
end

# ----------------------------------------------------------------------
section("THE LIAR PARADOX — «This sentence is false»")
# ----------------------------------------------------------------------

# Expression 1: direct recursion. The sentence's truth is defined as its
# own negation, so evaluation never grounds out.
liar() = !liar()
safe(liar; label="Expression 1 (recursive function)  liar() = !liar()")

# Expression 2: exhaustive fixed-point search over classical truth values.
# The Liar demands a v with v == !v. Classically there is none.
fps = [v for v in (true, false) if v == !v]
println("    Expression 2 (fixed-point search)  {v ∈ {true,false} : v == !v} = ",
        fps, "  ← EMPTY: no classical truth value")

# Expression 3: multiple dispatch. The sentence is a *type*; its truth
# method is defined in terms of itself.
abstract type Sentence end
struct Liar <: Sentence end
truth(s::Liar) = !truth(s)
safe(() -> truth(Liar()); label="Expression 3 (dispatch)  truth(::Liar) = !truth(::Liar)")

# Expression 4: homoiconicity. The sentence as a depth-limited *quotation*
# of its own negation: unfolding it never reaches ground.
function unfold_liar(gas::Int)
    gas == 0 && error("infinite regress — the sentence never grounds")
    return !unfold_liar(gas - 1)
end
safe(() -> unfold_liar(10_000); label="Expression 4 (gas-limited regress)")

# Expression 5: a macro that expands into its own negation (metaprogramming).
macro liar(n::Int)
    n <= 0 ? :(error("macro-expansion regress: ¬¬¬…⊥")) : :( !(@liar($(n-1))) )
end
safe(() -> @liar(8); label="Expression 5 (macro expansion)  @liar → !(@liar)")

# Expression 6: Kleene's strong 3-valued logic — built into Julia as `missing`.
# missing is the unique fixed point of negation: the Liar gets the third value.
L = missing
println("    Expression 6 (3-valued escape)     !missing === missing : ",
        isequal(L, !L), "  ← the Liar's value is `missing`")
println("      …but the Strengthened Liar («this sentence is not even missing»)")
println("      re-emerges one level up: the paradox is displaced, not resolved.")
verdict("ANTINOMY — DOES NOT RESOLVE classically; only displaced by changing logic (K3/missing).")

# ----------------------------------------------------------------------
section("GRELLING–NELSON — is «heterological» heterological?")
# ----------------------------------------------------------------------
# A word is heterological iff it does not describe itself.

const PREDS = Dict{String,Function}(
    "short"        => w -> length(w) <= 5,
    "long"         => w -> length(w) > 5,
    "lowercase"    => w -> all(islowercase, w),
    "polysyllabic" => w -> length(w) > 8,
)
heterological(w) = !(PREDS[w](w))
PREDS["heterological"] = heterological   # the word denotes this very predicate

for w in ("short", "long", "lowercase", "polysyllabic")
    println("    «$w» is ", heterological(w) ? "heterological" : "autological")
end
safe(() -> heterological("heterological");
     label="heterological(\"heterological\")")
verdict("ANTINOMY — DOES NOT RESOLVE. Same diagonal structure as the Liar.")

# ----------------------------------------------------------------------
section("RUSSELL'S PARADOX — the set of all sets that don't contain themselves")
# ----------------------------------------------------------------------

# Expression 1: Julia happily allows self-membered collections (IdSet avoids
# the hash regress). Naive comprehension is therefore expressible…
Ω = Base.IdSet{Any}(); push!(Ω, Ω)
println("    Expression 1: a set can contain itself:  Ω ∈ Ω = ", Ω in Ω)

# Expression 2: …but the Russell set R = {s : s ∉ s} cannot stabilize.
# Enforcing its own membership condition on R makes membership oscillate forever.
R = Base.IdSet{Any}()
print("    Expression 2: enforce R's definition on R itself: ")
for step in 1:6
    if R in R
        delete!(R, R)      # R ∈ R, but R may only contain non-self-membered sets
    else
        push!(R, R)        # R ∉ R, so by definition R must contain R
    end
    print(R in R ? "∈ " : "∉ ")
end
println("… oscillates forever — no fixed point.")

# Expression 3: the functional (predicate) form: russell(f) = !f(f),
# then ask russell of itself — the pure λ-calculus diagonal.
russell(f) = !f(f)
safe(() -> russell(russell); label="Expression 3 (higher-order)  russell(russell)")

# Expression 4: Julia's own type universe shrugs at self-membership
# (like non-well-founded set theories):
println("    Expression 4: Julia's type universe:  DataType isa DataType = ",
        DataType isa DataType, ",  Type isa Type = ", Type isa Type)
println("      Julia tolerates benign self-membership; only the *negated*")
println("      diagonal (Russell's R) explodes.")
verdict("ANTINOMY — DOES NOT RESOLVE. ZFC resolves it only by BANNING the construction (restricted comprehension).")

# ----------------------------------------------------------------------
section("CURRY'S PARADOX — «If this sentence is true, then pigs fly»")
# ----------------------------------------------------------------------
# C ≡ (C → X). Classically this *proves* X, for any X whatsoever.

# Expression 1: fixed-point search. C == (!C || X):
for X in (false, true)
    fp = [c for c in (true, false) if c == (!c || X)]
    println("    Expression 1: X = $(X) (\"pigs fly\") → consistent values of C: ", fp,
            isempty(fp) ? "   ← NO consistent value unless X is true!" : "")
end
println("      ⇒ classical logic is forced to make X true — Curry «proves» anything.")

# Expression 2: operational version — evaluating C loops forever.
curry() = curry() ? :PIGS_FLY : true
safe(curry; label="Expression 2 (recursive)  curry() = curry() ? PIGS_FLY : true")

# Expression 3: the 3-valued escape again — missing is a fixed point when X is false:
X = false; C = missing
println("    Expression 3 (K3): isequal(C, !C | X) with C = missing → ",
        isequal(C, (!C | X)))
verdict("ANTINOMY — DOES NOT RESOLVE; worse than the Liar (needs no negation, so even some paraconsistent logics fall to it).")

# ----------------------------------------------------------------------
section("HALTING PROBLEM — Turing's diagonal (the Liar, made mechanical)")
# ----------------------------------------------------------------------
# Suppose a total oracle halts(f)::Bool existed. Build the spoiler:
#   trouble() = halts(trouble) ? loop_forever : halt
# Every candidate oracle is refuted by its own diagonal.

function trouble_factory(oracle)
    local t
    t = () -> oracle(t) ? :RUNS_FOREVER : :HALTS   # does the opposite of the prediction
    return t
end

for (name, oracle) in [("oracle₁ ≡ «it halts»", _ -> true),
                       ("oracle₂ ≡ «it loops»", _ -> false)]
    t = trouble_factory(oracle)
    predicted = oracle(t) ? :HALTS : :RUNS_FOREVER
    actual    = t()
    println("    ", name, ":  predicted = ", predicted, ",  actual = ", actual,
            "  → ", predicted == actual ? "consistent" : "❌ REFUTED")
end
println("      Every possible oracle is refuted the same way ⇒ halts() cannot exist.")

# Empirically, Julia can only ever answer «true» or «missing» — never a grounded «false»:
collatz_halts(n; budget=10^6) = begin
    steps = 0
    while n != 1
        steps += 1
        steps > budget && return missing        # unknown — the third value again
        n = iseven(n) ? n ÷ 2 : 3n + 1
    end
    true
end
println("    Empirical semi-decision (Collatz):  n=27 → ", collatz_halts(27),
        ",  n=2^61+1 → ", collatz_halts(2^61 + 1),
        "   (true or missing — never a provable false)")
verdict("ANTINOMY (as decision problem) — DOES NOT RESOLVE. Undecidability is the Liar compiled to machine code.")

# ----------------------------------------------------------------------
section("BERRY'S PARADOX — «the smallest number not definable in few symbols»")
# ----------------------------------------------------------------------
# Object language: Julia expressions over digits {1,2,3} and ops {+,*,^},
# at most 7 characters. Which numbers are expressible?

function berry_search(maxlen::Int, cap::Int)
    chars = ['1','2','3','+','*','^']
    expressible = falses(cap)
    function evalx(e)
        e isa Integer && return (0 < e <= 10^9 ? big(e) : nothing)
        if e isa Expr && e.head == :call
            op = e.args[1]
            vals = Any[evalx(a) for a in e.args[2:end]]
            any(isnothing, vals) && return nothing
            v = op == :+ ? sum(vals) :
                op == :* ? prod(vals) :
                op == :^ && length(vals) == 2 && vals[2] <= 30 ? vals[1]^vals[2] :
                nothing
            return (v isa BigInt && 0 < v <= 10^9) ? v : nothing
        end
        return nothing
    end
    count_exprs = 0
    for L in 1:maxlen, tup in Iterators.product(ntuple(_ -> chars, L)...)
        s = String(collect(tup))
        ex = Meta.parse(s; raise=false)
        (ex isa Expr && ex.head in (:error, :incomplete)) && continue
        v = evalx(ex)
        v === nothing && continue
        count_exprs += 1
        v <= cap && (expressible[Int(v)] = true)
    end
    return findfirst(!, expressible), count_exprs
end

berry_n, nexpr = berry_search(7, 200_000)
println("    Scanned all ≤7-char expressions over {1,2,3,+,*,^} ($nexpr valid).")
println("    Smallest positive integer NOT expressible in ≤7 chars: ", berry_n)
desc = "the smallest positive integer not expressible in ≤7 chars"
println("    …yet the description «$desc»")
println("    just *named* it — and that description is itself a finite string.")
println("    Tarski's resolution: metalanguage ≠ object language. Inside a single")
println("    self-applicable language, the paradox DOES NOT resolve.")
verdict("ANTINOMY when language describes itself; dissolves only by stratifying languages.")

# ----------------------------------------------------------------------
section("BONUS: THE INTERESTING-NUMBER PARADOX — a definition that never stabilizes")
# ----------------------------------------------------------------------
special = Set([1, 2, 3, 7, 42, 100])
for step in 1:5
    m = first(n for n in 1:10^6 if n ∉ special)
    println("    step $step: smallest UNinteresting number = $m — but that's interesting! adding it…")
    push!(special, m)
end
println("    …and so on forever: the predicate «uninteresting» consumes its own extension.")
verdict("Soft antinomy — the definition is non-monotone and never stabilizes.")
