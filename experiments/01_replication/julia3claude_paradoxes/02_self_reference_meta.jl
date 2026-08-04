# ─────────────────────────────────────────────────────────────────────────────
# 02 · Self-reference that WORKS — and the limits it buys
#
# Gödel's deepest trick was noticing that self-reference is not itself
# paradoxical: a sentence can talk about itself and be plainly true.
# A quine is the executable proof.  This file collects benign self-reference
# (the quine), stratified self-reference (world age), self-defeating
# definition (Berry, the interesting numbers), and the theorem that
# self-reference wields against computation itself (halting), ending with
# Lewis Carroll's regress and how a machine grounds it.
# ─────────────────────────────────────────────────────────────────────────────
module SelfRefMeta

section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

# ═══ The quine: self-reference without paradox ═══════════════════════════════
section("a quine — a program that asserts exactly itself")
let
    line2   = "print(\"q = \", repr(q), \"\\n\", q)"
    content = "q = " * repr(line2) * "\n" * line2
    path    = joinpath(mktempdir(), "quine.jl")
    write(path, content)
    out = read(`$(Base.julia_cmd()) --startup-file=no $path`, String)
    println(content)
    println("output == source:  ", out == content)
end
# The liar says "this sentence is false" and has no model; the quine says
# "this sentence is this sentence" and is verified by diff.  Gödel's sentence
# sits between them: "this sentence is unprovable" — self-reference aimed at
# provability instead of truth, which is why it wounds rather than explodes.

# ═══ World age: the omnipotence paradox, stratified ══════════════════════════
section("world age — can Julia make a stone it cannot lift?")
function create_stone()
    @eval stone() = "lifted!"
    try
        stone()                       # our world predates the stone
    catch e
        e
    end
end
err = create_stone()
println("inside its creating world:  ", typeof(err))
println("one world later:            ", stone())
function create_and_lift()
    @eval stone2() = "lifted anyway"
    Base.invokelatest(stone2)         # a licensed peek at the newest world
end
println("with invokelatest:          ", create_and_lift())
# Yes — Julia makes a stone it cannot lift, and then lifts it a moment later.
# Self-modification is legal; *seeing* your own modification requires moving
# to a later stratum.  This is Tarski's hierarchy of metalanguages implemented
# as a scheduler: time does the stratifying, and `invokelatest` is the
# explicitly-marked truth predicate.  (Julia 1.12 WARNS about the very
# access pattern and promises a future error: the tower's rules are being
# tightened release by release — stratification winning the argument.)

# ═══ Berry's paradox, actually enumerated ════════════════════════════════════
section("Berry — the least integer not definable in ≤ 5 characters")
const ALPHABET = collect("0123456789+*^")
function berry(maxlen; limit = 2_000_000)
    definable = falses(limit)
    for len in 1:maxlen
        for tup in Iterators.product(ntuple(_ -> ALPHABET, len)...)
            s = String(collect(tup))
            (isdigit(s[1]) && isdigit(s[end])) || continue
            occursin(r"[+*^]{2}", s) && continue
            ex = try Meta.parse(s) catch; continue end
            ex isa Expr && ex.head in (:error, :incomplete) && continue
            v = try Core.eval(@__MODULE__, ex) catch; continue end
            v isa Int && 1 <= v <= limit && (definable[v] = true)
        end
    end
    findfirst(==(false), definable)
end
t = @elapsed (b5 = berry(5))
println("object language: digits and + * ^, up to 5 characters")
println("berry(5) = ", b5, "   (found in ", round(t, digits=1), "s)")
println("…which the 8-character expression \"berry(5)\" just defined.")
# There it is: an integer "not definable in five characters", defined in
# eight.  No contradiction — because `berry` is not IN the object language it
# quantifies over.  Add "berry" to ALPHABET and the definition must consult
# its own value before it has one: ungrounded, like the liar.  Berry's
# paradox is the collapse of a language hierarchy, and the fix is the
# hierarchy.  (Richard's and König's paradoxes are this same knot tied in
# the reals and the ordinals.)

# ═══ The interesting-number "paradox" — a predicate that won't sit still ═════
section("interesting numbers — a self-undermining predicate")
issquare(n)  = isqrt(n)^2 == n
istriangle(n)= issquare(8n + 1)
isprime_(n)  = n > 1 && all(n % d != 0 for d in 2:isqrt(n))
ispalin(n)   = (s = string(n); s == reverse(s))
fibs         = Set(let f = [1, 1]
    while f[end] < 500
        push!(f, f[end] + f[end-1])
    end
    f
end)
facts        = Set([1, 2, 6, 24, 120])
interesting(n, special) =
    issquare(n) || istriangle(n) || isprime_(n) || ispalin(n) ||
    n in fibs || n in facts || ispow2(n) || haskey(special, n)
let special = Dict{Int,String}()
    for round in 1:5
        u = findfirst(n -> !interesting(n, special), 1:500)
        println("round $round: smallest uninteresting number = $u — which is a ",
                "distinction, so it's now interesting")
        special[u] = "smallest uninteresting, round $round"
    end
end
# Not a contradiction but an instability: "interesting" quantifies over its
# own extension, so the extension moves every time you point at it.  The
# frame of "resolving" doesn't apply — the predicate is indefinitely
# extensible, like "ordinal" and "nameable".  (This is Berry played for
# laughs.)

# ═══ The halting problem: self-reference as a weapon ═════════════════════════
section("halting — the diagonal argument, one branch run live")
oracle_no(f) = false            # a candidate total oracle: "nothing halts"
d_no() = oracle_no(d_no) ? (while true end) : "…and yet I halt. oracle_no is wrong about me."
println(d_no())
println("""
For the opposite oracle —  oracle_yes(f) = true  — the diagonal program
    d_yes() = oracle_yes(d_yes) ? (while true end) : "halt"
loops forever, refuting IT (we reason; we don't run).  Every candidate
`halts` you write, the diagonal defeats: not by contradiction in Julia but
by construction.  Turing's price for a language expressive enough to state
`halts` is that the liar's schema compiles.""")

# What survives: halting is SEMI-decidable, and the third value returns.
function collatz_steps(n, fuel)
    k = 0
    while n != 1
        fuel -= 1
        fuel < 0 && return missing
        n = iseven(n) ? n ÷ 2 : 3n + 1
        k += 1
    end
    k
end
println("collatz_steps(27, fuel=50)  = ", repr(collatz_steps(27, 50)))
println("collatz_steps(27, fuel=200) = ", repr(collatz_steps(27, 200)))
# `missing` is exactly the epistemic state a bounded verifier is entitled to.

# ═══ Lewis Carroll's tortoise: the regress of rules ══════════════════════════
section("what the Tortoise said to Achilles")
license(k) = "to apply rule $k you must first accept rule $(k + 1)"
for k in 1:4; println("  ", license(k)); end
println("  …")
apply(f, x) = f(x)                       # not a premise — an ACT
println("  apply(x -> x + 1, 41) = ", apply(x -> x + 1, 41))
# If modus ponens is data, using it needs a meta-rule, forever.  The machine
# ends the regress the only way it can be ended: at some level inference is
# not asserted but EXECUTED.  Julia's function call is where Achilles stops
# writing in the notebook and puts his foot down.

end # module
