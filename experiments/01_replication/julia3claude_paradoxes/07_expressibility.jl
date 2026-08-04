# ─────────────────────────────────────────────────────────────────────────────
# 07 · The limits of the sayable — runnable exhibits
#
# Companion to EXPRESSIBILITY.md.  Every philosophical claim there that CAN
# be demonstrated is demonstrated here; the ones that can't are the point.
# ─────────────────────────────────────────────────────────────────────────────
module Expressibility

section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

# ═══ Julia has no sentences — only evaluations ═══════════════════════════════
section("no assertion force")
println("2 + 2 == 5  evaluates to ", 2 + 2 == 5, " — and nothing happened.")
println("An English speaker who says «2+2=5» has ASSERTED and is wrong.")
println("Julia computed a value; it did not claim, so it cannot lie.")
asserted = try @assert 2 + 2 == 5 catch e; typeof(e) end
println("@assert turns the value into an act, and the act into ", asserted, ".")
# The nearest thing Julia has to assertion is the error: commitment enforced,
# not undertaken.  Sincerity, testimony, fiction, and lying all live in the
# gap between saying and checking — a gap this language does not have.

# ═══ The universal quantifier is not in the language ═════════════════════════
section("Goldbach — a search is not a sentence")
function isprime_(n)
    n < 2 && return false
    for d in 2:isqrt(n); n % d == 0 && return false end
    true
end
goldbach_pair(n) = findfirst(p -> isprime_(p) && isprime_(n - p), 2:(n ÷ 2))
holds_below(N) = all(!isnothing(goldbach_pair(n)) for n in 4:2:N)
println("every even 4 ≤ n ≤ 10⁵ is a sum of two primes:  ", holds_below(100_000))
println("«every even n IS a sum of two primes»:          ⟨not expressible⟩")
# Julia can refute Goldbach (find the counterexample and halt) but cannot
# STATE it: there is no expression whose value is the universally quantified
# proposition.  `all` over an infinite iterator is not a sentence — it is a
# promise to keep checking.  In Lean, `∀ n, Even n → ...` is a first-class
# object whether or not anyone proves it.  Julia's whole propositional
# universe is the decidable fragment: here, meaning IS verification method,
# so the unverifiable is unsayable.  (Verificationism, not as a philosophy
# but as a compiler constraint.)

# ═══ Extensional function equality — «same function» is unsayable ════════════
section("two functions that are the same function, and no way to say so")
f = x -> x + x
g = x -> 2x
println("agree on 10⁴ random Ints:    ", all(f(x) == g(x) for x in rand(Int, 10_000)))
# (Over Int these agree everywhere, overflow included.  Amusingly, over
# Int16 they do NOT — x + x wraps in Int16 while 2x promotes to Int64: the
# formalism refuted this file's first draft, which had called them "the
# same function" on English intuition.  Exhibit A for the whole essay.)
println("f == g:                      ", f == g)
println("(x -> x + 1) == (x -> x + 1):  ", (x -> x + 1) == (x -> x + 1))
# Even two syntactically identical lambdas are unequal: Julia's `==` on
# functions is identity of code objects, because pointwise equality over an
# infinite domain is undecidable (Rice's theorem).  English says "f and g
# compute the same thing" effortlessly; Julia cannot say it at all — it can
# only fail to falsify it.  What Julia CAN express, which English cannot,
# is the exact intension: the code object itself, inspectable to the bit.

# ═══ Kripkenstein — plus, quus, and the fact of the matter ═══════════════════
section("quus — the rule-following paradox has no foothold here")
quus(x, y) = (x < 57 && y < 57) ? x + y : 5
past_usage = [(a, b) for a in 0:56, b in 0:56]         # every sum "you" ever did
println("quus agrees with + on all past usage:  ",
        all(quus(a, b) == a + b for (a, b) in past_usage))
println("but 68 + 57 = ", 68 + 57, "   while  quus(68, 57) = ", quus(68, 57))
println("and they were never the same object:   (+) === quus  is  ", (+) === quus)
# Kripke's skeptic: no fact about your past use of "plus" determines that
# you meant plus rather than quus, so English rule-meaning is indeterminate.
# In Julia the skeptic starves: `+` and `quus` are distinct method tables,
# and what a rule demands on the case nobody has tried is already a fact —
# stored, inspectable, executable.  Julia expresses DETERMINATE rules;
# English, per the paradox, cannot.

# ═══ Carroll again, from the other side ══════════════════════════════════════
section("an instruction that interprets itself")
println("English: «add one to forty-one» — requires a reader who already")
println("         knows how to follow instructions (and off we regress).")
println("Julia:   (x -> x + 1)(41) = ", (x -> x + 1)(41), " — no reader required.")
# An English sentence cannot execute itself; every one waits for a mind.
# A Julia expression is a meaning whose interpretation-regress terminates
# in physics.  This is the one mode of expression natural language
# constitutively lacks: the self-applying kind.

# ═══ Counterfactuals, closed and cheap ═══════════════════════════════════════
section("a pure function is a completed bundle of counterfactuals")
tax(income) = income ≤ 50_000 ? 0.2income : 10_000 + 0.4(income - 50_000)
println("actual:        tax(60_000)  = ", tax(60_000))
println("counterfactual: tax(45_000) = ", tax(45_000), "   (evaluated, not speculated)")
# «What would your tax have been, had you earned less?» — English handles
# would-have-beens with possible-world metaphysics and two centuries of
# dispute about dispositions.  A pure function simply CONTAINS its
# counterfactuals: the unasked cases are as determinate as the asked one.
# Julia expresses dispositions exactly; English only alludes to them.

# ═══ The needed distinctions English doesn't natively have ═══════════════════
section("distinctions the formalism discovered")
println("0.0 == -0.0: ", 0.0 == -0.0, "   1/0.0 = ", 1/0.0, "   1/-0.0 = ", 1/-0.0)
println("«same number, different direction of approach» — English has one")
println("word for equality; this system needed three (==, ===, isequal) and")
println("a signed zero, and found out only by being forced to decide.")

# ═══ What cannot appear here at all ══════════════════════════════════════════
section("the census of the missing")
println("""
  · Chaitin's Ω — a specific, English-nameable real number; no Julia
    expression evaluates to it (nor to almost any real: countably many
    programs, uncountably many reals)
  · a Vitali set / Banach–Tarski piece — exists by choice, admits no
    defining description at all
  · ℕ as a completed totality — only ever a rule here (countfrom), never
    the finished thing
  · a truth predicate for Julia, in Julia — eval is truth for the decidable
    fragment; Tarski forbids the whole (see world age, file 02)
  · an ambiguous expression — parsing is a function; one AST wins; Julia
    cannot say the underdetermined thing «a random chord» says in English
  · a vague predicate AS vague — file 06 offers four precise theories of
    «heap»; the vagueness itself stayed in English
  · a contradiction AS content — asserting P ∧ ¬P is beyond a language in
    which asserting is running (it becomes ∅, ⊥, or missing — file 01)
  · an obligation — no expression means «you ought to»; code does or
    doesn't, and the ought stays with the humans""")

end # module
