# ============================================================
# emergence_01.jl — re-entry: self-reference forces dynamics
# ============================================================
# LEDGER — read before running. Carried forward from _00.
# ------------------------------------------------------------
# ASSUMPTION 1 (inherited): inscription is collapse. "That" is
#     not in this file. Only traces.
# ASSUMPTION 2 (inherited): Julia is our host formal system;
#     by Gödel it cannot certify itself; neither can this ledger.
# ASSUMPTION 3 (new): a paradoxical equation may be read as a
#     PROCESS instead of a contradiction. marked(f) = !marked(f)
#     is not falsehood; it is an update rule awaiting a clock.
#     This is Spencer-Brown's re-entry, Varela's autonomy.
#     It is a reading CHOICE, not a discovered truth.
# CHOICE 1 (new, and it bites): time is discrete + SYNCHRONOUS.
#     All marks update together on a shared tick. An asynchronous
#     or continuous choice would yield different attractors.
#     We cannot see, from inside this choice, what it hides.
# CHOICE 2 (new): a mark's value is the crossing of its inputs:
#     next(i) = NOT( ANY(inputs of i) )   — i.e. NOR.
#     Self-loops permitted: a mark may be its own input.
# QUESTION: when a distinction is allowed to distinguish itself,
#     what arises that neither statics nor hierarchy could hold?
# OBJECT: the re-entrant form — the loop, not the node.
# UNPROVABLE FROM INSIDE: which forms stabilize, in general,
#     without running them (halting problem, wearing a new coat);
#     and whether synchrony (Choice 1) smuggled in the results.
# ============================================================

# --- A world of marks that may point at themselves -----------

struct World
    inputs::Vector{Vector{Int}}     # inputs[i] = who mark i crosses over
end

nmarks(w::World) = length(w.inputs)

# next(i) = NOT(ANY(inputs))  — empty inputs: a bare cross, constantly marked
step(w::World, s::BitVector) =
    BitVector([ isempty(w.inputs[i]) ? true : !any(s[j] for j in w.inputs[i])
                for i in 1:nmarks(w) ])

# run until the trajectory bites its own tail; return (transient, cycle)
function unfold(w::World, s0::BitVector; tmax=10_000)
    seen = Dict{BitVector,Int}(); traj = [s0]; s = s0
    for t in 1:tmax
        seen[s] = t
        s = step(w, s)
        haskey(seen, s) && return (traj[1:seen[s]-1], traj[seen[s]:end])
        push!(traj, s)
    end
    error("no closure within tmax — undecided from inside, as warned")
end

show_states(v) = join([join([b ? "▮" : "·" for b in s]) for s in v], " → ")

# ============================================================
# I. THE FIRST RE-ENTRY: f = cross(f). Time is extruded.
# ============================================================
println("=== I. f = cross(f): the paradox that ticks ===")
w1 = World([[1]])                              # mark 1 crosses itself
for init in (BitVector([false]), BitVector([true]))
    tr, cy = unfold(w1, init)
    println("  start ", show_states([init]), "  →  cycle: ", show_states(cy),
            "  (period ", length(cy), ")")
end
println("  Statically: contradiction. Dynamically: an oscillator.")
println("  Neither marked nor unmarked — a value that IS its own")
println("  alternation. Spencer-Brown called this imaginary, as √-1")
println("  is to the reals: not in the old space, orthogonal to it.")

# ============================================================
# II. TWO RE-ENTRIES, CROSSED: MEMORY. The first "thing".
# ============================================================
# Marks 1,2 cross each other (mutual re-entry); 3,4 are external
# hands we hold constant per epoch. This is Spencer-Brown's
# memory form — engineers met it independently as the SR latch.
println("\n=== II. mutual re-entry: memory emerges, uninvited ===")
w2 = World([[2,3], [1,4], Int[], Int[]])       # 3,4 clamp via override below

function clamp_run(w, s, clamps; ticks=8)
    for _ in 1:ticks
        s = step(w, s)
        for (i,v) in clamps; s[i] = v; end
    end
    s
end

s = BitVector([false,false,false,false])
s = clamp_run(w2, s, [3=>true,  4=>false]); a = s[1:2]
println("  press SET    → held state: ", show_states([a]))
s = clamp_run(w2, s, [3=>false, 4=>false]); b = s[1:2]
println("  release all  → held state: ", show_states([b]),
        b == a ? "   (it REMEMBERS)" : "   (it forgot)")
s = clamp_run(w2, s, [3=>false, 4=>true ]); c = s[1:2]
println("  press RESET  → held state: ", show_states([c]))
s = clamp_run(w2, s, [3=>false, 4=>false]); d = s[1:2]
println("  release all  → held state: ", show_states([d]),
        d == c ? "   (it REMEMBERS)" : "   (it forgot)")
println("  Persistence — the first candidate for 'thing' — is not")
println("  a substance. It is a loop that keeps re-entering itself.")

# ============================================================
# III. MANY RE-ENTRIES: a fauna of attractors
# ============================================================
# Random worlds of self- and mutually-referential marks.
# We do not design outcomes. We census what stabilizes.
println("\n=== III. an ecology of self-reference (n=12, 60 worlds) ===")
import Random; Random.seed!(3)                  # CHOICE: fixed seed, honesty over mystique
census = Dict{Int,Int}()
for trial in 1:60
    n = 12
    w = World([sort!(unique(rand(1:n, rand(1:3)))) for _ in 1:n])
    _, cy = unfold(w, BitVector(rand(Bool, n)))
    census[length(cy)] = get(census, length(cy), 0) + 1
end
for p in sort(collect(keys(census)))
    kind = p == 1 ? "fixed points  — 'things', frozen re-entry" :
           p == 2 ? "period 2      — 'clocks', bare oscillation" :
                    "period $p      — longer rhythms, proto-process"
    println("  ", census[p], " worlds settled into ", kind)
end
println("  NOR is logically universal: this fauna is not decorative.")
println("  Given size, such worlds can compute anything computable —")
println("  therefore predicting their settling is, in general,")
println("  equivalent to the halting problem. We must LIVE the")
println("  dynamics to know it. No view from outside time is sold here.")

# ============================================================
# IV. THE LOOP EATS THE LEDGER (residue)
# ============================================================
println("\n=== IV. residue ===")
println("• Time appeared as the resolution of a paradox we chose")
println("  not to forbid. Different clock choices (Choice 1) may")
println("  dissolve or breed different attractors. Unchecked here.")
println("• 'Things' arrived as fixed points, 'memory' as bistable")
println("  loops, 'process' as cycles — all from one move: letting")
println("  a distinction re-enter its own form.")
println("• This ledger is itself a re-entrant form: a text that")
println("  describes the system that includes the text. Its fixed")
println("  point, if any, is not computable from inside. Stop here,")
println("  at the edge we can see, knowing there are edges we cannot.")
