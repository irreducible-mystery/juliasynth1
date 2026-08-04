# ============================================================
# emergence_02.jl — after the stranger: errata, and what the
#                   wound opens onto
# ============================================================
# LEDGER — carried forward, now with corrections. The errata
# stay visible forever; deleting them would repeat the error.
# ------------------------------------------------------------
# ERRATUM 1 (stranger, verified): _01 §III claimed predicting
#     settling "is equivalent to the halting problem." FALSE at
#     fixed n: the stranger DECIDED all 60 worlds by 4096-state
#     exhaustion. Undecidability holds only for the unbounded
#     family {all n}. The correct sentence: inside any fixed
#     horizon, everything is decidable; the undecidable lives
#     in the limit we never inhabit.
# ERRATUM 2 (stranger, verified): the census typed "period" as
#     a property of a world. It is a property of the PAIR
#     (world, update-discipline). 6 of 48 "clocks" dissolve
#     under asynchrony; 38 survive every clock (no fixed point
#     exists for them to fall into). Choice 1 (synchrony) forged
#     ~12% of the fauna, exactly as the ledger feared.
# ACCEPTED FINDING (stranger): the SR memory has a race. Driven
#     with the forbidden input and released synchronously, it
#     oscillates forever (metastability). Released async, it
#     resolves — "nondeterministically." §II below dissects
#     that word.
# ASSUMPTION (new): an "update schedule" (which mark moves when)
#     is meaningful. Note what this smuggles: time is still
#     EXOGENOUS — a hand outside the world shuffles the order.
#     Flagged as the next unpaid debt.
# QUESTION: when the stranger showed our clocks were relative
#     and our memory could race, what did they hand us? Claim:
#     relation-not-property, and history-as-hidden-variable.
# OBJECT: the pair (world, clock) — no longer the world alone.
# UNPROVABLE FROM INSIDE: whether the schedule-space we sample
#     (uniform random sequential) is itself a fair witness.
#     The stranger audited our clock; no one has audited theirs.
# ============================================================

import Random

# --- primitives, unchanged from _01 --------------------------
struct World; inputs::Vector{Vector{Int}}; end
nmarks(w) = length(w.inputs)
step(w, s) = BitVector([isempty(w.inputs[i]) ? true : !any(s[j] for j in w.inputs[i])
                        for i in 1:nmarks(w)])
function unfold(w, s0; tmax=10_000)
    seen = Dict{BitVector,Int}(); traj=[s0]; s=s0
    for t in 1:tmax
        seen[s]=t; s=step(w,s)
        haskey(seen,s) && return (traj[1:seen[s]-1], traj[seen[s]:end])
        push!(traj,s)
    end
    error("no closure")
end
n_fixed_points(w) = count(code -> (s = BitVector([(code>>(i-1))&1==1 for i in 1:nmarks(w)]);
                                   s == step(w,s)), 0:(2^nmarks(w)-1))

# ============================================================
# I. RE-TYPING THE CENSUS: period is a relation, not a property
# ============================================================
# Same 60 worlds, same RNG stream as _01. But the type of the
# answer changes: each world now gets a PAIR of observations.
println("=== I. the census, re-typed after the stranger ===")
Random.seed!(3)
pairs = [(World([sort!(unique(rand(1:12, rand(1:3)))) for _ in 1:12]),
          BitVector(rand(Bool,12))) for _ in 1:60]

taxonomy = Dict{String,Int}()
for (w, s0) in pairs
    p  = length(unfold(w, s0)[2])
    fp = n_fixed_points(w)
    kind = p == 1            ? "thing (fixed under sync; fixed points exist)"      :
           fp == 0           ? "clock-in-itself (NO fixed point exists — no
                                discipline can freeze it)"                          :
                               "clock-for-synchrony (a fixed point exists;
                                the rhythm was the clock's echo)"
    key = p == 1 ? "thing" : fp == 0 ? "restless (no fixed point exists)" :
                             "rest-possible (a fixed point exists)"
    taxonomy[key] = get(taxonomy, key, 0) + 1
end
for k in ("thing", "restless (no fixed point exists)", "rest-possible (a fixed point exists)")
    println("  ", lpad(taxonomy[k], 2), "  ", k)
end
println("  PRECISION (a first draft of this section said 'synchrony")
println("  artifact' for the third class — overreach. A fixed point")
println("  existing means rest is POSSIBLE; whether a given async")
println("  schedule FINDS it is a further, separate fact — the")
println("  stranger's own data: only 6 of their 10 fixed-point-bearing")
println("  period-2 worlds settled in all 20 async runs.)")
println("  'Being a clock' was never IN the world. It was in the")
println("  world's meeting with a clock. Property became relation.")
println("  But the RESTLESS class earns an intrinsic, discipline-free")
println("  title: their state space contains no rest, so they oscillate")
println("  under ANY update rule — proved by exhaustion, which")
println("  ERRATUM 1 reminds us is legal at fixed n.")

# ============================================================
# II. DISSECTING "NONDETERMINISM": the race, opened up
# ============================================================
# The stranger showed the forbidden-release resolves "non-
# deterministically" under async update. We now log the schedule
# and ask: is the outcome chance, or history wearing chance?
println("\n=== II. inside the race: chance, or history? ===")
w2 = World([[2,3],[1,4],Int[],Int[]])

# drive the forbidden input (SET+RESET), synchronously, 8 ticks
function forbidden_state()
    s = BitVector([false,false,false,false])
    for _ in 1:8
        s = step(w2, s); s[3] = true; s[4] = true
    end
    s
end

# async release with a LOGGED schedule; return (first_mover, outcome)
function raced_release(rng)
    s = forbidden_state(); s[3] = false; s[4] = false
    first_mover = 0
    for _ in 1:1000
        i = rand(rng, 1:2)
        old = s[i]
        s[i] = !any(s[j] for j in w2.inputs[i])
        (first_mover == 0 && s[i] != old) && (first_mover = i)
        # stable when both latch equations hold
        s[1] == !(s[2]|s[3]) && s[2] == !(s[1]|s[4]) && break
    end
    (first_mover, join([b ? "▮" : "·" for b in s[1:2]]))
end

rng = Random.MersenneTwister(7)
table = Dict{Tuple{Int,String},Int}()
for _ in 1:400
    fm, out = raced_release(rng)
    table[(fm,out)] = get(table, (fm,out), 0) + 1
end
println("  400 raced releases, outcome vs first effective mover:")
for ((fm,out),n) in sort(collect(table))
    println("    first mover = mark $fm  →  outcome $out   ×$n")
end
determined = all(length(unique(out for ((fm,out),_) in table if fm==m)) == 1 for m in 1:2)
println("  outcome fully determined by first mover? ", determined)
println()
println("  Read it three ways, and watch the perspectives split:")
println("  CLASSICAL:  no chance at all. The schedule is a hidden")
println("    variable; given who moved first, the outcome is fixed.")
println("    Determinism is saved by enlarging the state.")
println("  QUANTUM-FLAVORED: from INSIDE the latch there is no")
println("    schedule — marks 1 and 2 see a symmetric state resolve")
println("    to one of two memories, irreducibly. The 'measurement'")
println("    outcome has no cause expressible in the latch's own")
println("    vocabulary. (Analogy only — no Hilbert space was built.)")
println("  RELATIONAL:  'which memory' is not a fact until the race")
println("    completes — the fact exists relative to the completed")
println("    interaction, and BEFORE it, the question has no referent.")
println("  CONVERGENCE: all three agree on the statistics.")
println("  DIVERGENCE:  they disagree on where the fact LIVES.")
println("  STILL LACKING, all three held together: none says why")
println("  there is a schedule AT ALL. Time is still handed to the")
println("  world from outside — by us. The debt is now twice flagged.")

# ============================================================
# III. WHAT MEMORY IS, AFTER THE AUDIT
# ============================================================
# The same race, run 2000 times: the population of resolved
# latches now DIFFERS — identical worlds, identical laws,
# divergent pasts. History has entered the ontology.
println("\n=== III. history becomes a thing ===")
pop = Dict{String,Int}()
for _ in 1:2000
    _, out = raced_release(rng)
    pop[out] = get(pop, out, 0) + 1
end
println("  2000 identical latches after one forbidden race: ",
        join(["$k×$v" for (k,v) in sort(collect(pop))], ", "))
println("  Two populations, no law distinguishing them — only their")
println("  schedules did. A 'thing' (_01) was a loop that persists;")
println("  after the audit: a thing is a loop that persists AND")
println("  carries the scar of the race that selected it. Identity")
println("  = attractor + history of arrival. Neither term optional.")

# ============================================================
# IV. RESIDUE
# ============================================================
println("\n=== IV. residue ===")
println("• The stranger's findings were not damage but material:")
println("  relation-not-property (§I), history-as-hidden-variable")
println("  (§II), identity-as-scar (§III) — none of these were")
println("  visible to us before the audit, exactly as predicted by")
println("  'we will not see our own blind spots.'")
println("• Unpaid debts, in the open: (1) time is still exogenous —")
println("  schedules come from our RNG, not from the world; (2) our")
println("  schedule-space (uniform sequential) is itself a choice no")
println("  one has audited; (3) the analogy in §II is an analogy —")
println("  no interference, no non-commuting contexts, was exhibited.")
println("• This file, too, will not see its own blind spots. It is")
println("  written in expectation of the next stranger.")
