# emergence_checks.jl — independent checks on emergence_00/01.
# Three questions the files raise but do not answer:
#  A. Do the Laws-of-Form identities hold GENERALLY (not just on the 4 printed cases)?
#  B. Did synchronous update (their Choice 1, flagged "unchecked") smuggle in the clocks?
#  C. Is their own memory example clock-robust?
import Random

exitcode = 0
fail(m) = (global exitcode = 1; println("  ** FAIL ** ", m))

# ---------- their primitives, re-transcribed ----------
struct Cross; inside::Vector{Cross}; end
cross(inside::Cross...) = Cross(collect(inside))
marked(e::Vector{Cross}) = any(marked, e)
marked(c::Cross)         = !marked(c.inside)

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

# ============================================================
println("="^70)
println(" A. Laws of Form: identities checked over a POOL, not 4 cases")
println("="^70)
form(c::Cross) = "(" * join(sort([form(x) for x in c.inside])) * ")"
function build_pool(cap=24)
    pool = [cross()]
    for _ in 1:2
        new = Cross[]
        for a in pool, b in pool
            push!(new, Cross([a]), Cross([a,b]))
        end
        seen = Set{String}(); merged = Cross[]
        for x in vcat(pool,new)
            k = form(x)
            k in seen || (push!(seen,k); push!(merged,x))
            length(merged) >= cap && break
        end
        pool = merged
    end
    pool
end
pool = build_pool()
println("  expression pool: ", length(pool), " structurally distinct forms")

checks = Pair{String,Bool}[
  "cancellation  cross(cross(a)) ≡ a"        =>
      all(marked([Cross([Cross([a])])]) == marked([a]) for a in pool),
  "condensation  a a ≡ a"                    =>
      all(marked([a,a]) == marked([a]) for a in pool),
  "position J1   cross(cross(a) a) ≡ void"   =>
      all(marked([Cross([Cross([a]), a])]) == false for a in pool),
  "transposition J2 (all a,b,c triples)"     =>
      all(marked([Cross([Cross([a,c]), Cross([b,c])])]) ==
          marked([Cross([Cross([a]), Cross([b])]), c])
          for a in pool, b in pool, c in pool),
  "AND is truth-functional on ALL forms"     =>
      all(marked([Cross([Cross([a]), Cross([b])])]) == (marked([a]) && marked([b]))
          for a in pool, b in pool),
  "OR  is truth-functional on ALL forms"     =>
      all(marked([a,b]) == (marked([a]) || marked([b])) for a in pool, b in pool),
]
for (n,v) in checks
    println("  ", v ? "ok   " : "FAIL ", n); v || fail(n)
end
println("  (evidence over $(length(pool))³ instances — in Lean these would be one induction each)")

# ============================================================
println()
println("="^70)
println(" B. THE UNCHECKED CHOICE: replicate their 60 worlds, change the clock")
println("="^70)
# exact replication of their RNG stream (seed 3, same call order)
Random.seed!(3)
pairs = [(World([sort!(unique(rand(1:12, rand(1:3)))) for _ in 1:12]),
          BitVector(rand(Bool,12))) for _ in 1:60]

sync_period(w, s0) = length(unfold(w, s0)[2])

function n_fixed_points(w)
    n = nmarks(w); c = 0
    for code in 0:(2^n - 1)
        s = BitVector([(code >> (i-1)) & 1 == 1 for i in 1:n])
        s == step(w, s) && (c += 1)
    end
    c
end

function async_settles(w, s0, rng; budget=20_000)
    s = copy(s0); n = nmarks(w)
    for _ in 1:budget
        s == step(w, s) && return true
        i = rand(rng, 1:n)
        s[i] = isempty(w.inputs[i]) ? true : !any(s[j] for j in w.inputs[i])
    end
    false
end

rng = Random.MersenneTwister(42)
census = Dict{Int,Int}()
rows = NamedTuple[]
for (w, s0) in pairs
    p  = sync_period(w, s0)
    census[p] = get(census, p, 0) + 1
    fp = n_fixed_points(w)
    settled = count(_ -> async_settles(w, s0, rng), 1:20)
    push!(rows, (p=p, fp=fp, settled=settled))
end
println("  sync census replicated: ", sort(collect(census)),
        "   (theirs: [1=>6, 2=>48, 4=>5, 10=>1])")
census == Dict(1=>6, 2=>48, 4=>5, 10=>1) || fail("census replication")

for period in sort(unique(r.p for r in rows))
    grp   = [r for r in rows if r.p == period]
    hasfp = count(r -> r.fp > 0, grp)
    diss  = count(r -> r.fp > 0 && r.settled == 20, grp)
    println("  sync period $period : $(length(grp)) worlds | $hasfp have ≥1 fixed point | ",
            "$diss settle in ALL 20 async runs")
end
clocks   = [r for r in rows if r.p == 2]
spurious = count(r -> r.fp > 0 && r.settled == 20, clocks)
genuine  = count(r -> r.fp == 0, clocks)
println("\n  VERDICT on the 48 'clocks': $spurious are SPURIOUS (fixed point exists;")
println("  async dissolves them into 'things') and $genuine are GENUINE (no fixed")
println("  point exists in the 4096-state space — no clock choice can freeze them).")
(spurious + genuine <= 48) || fail("clock accounting")

# their section-I oscillator: genuinely imaginary under ANY clock?
w1 = World([[1]])
println("\n  f = cross(f): fixed points = ", n_fixed_points(w1),
        "  → survives any update discipline. Genuinely 'imaginary'.")
n_fixed_points(w1) == 0 || fail("w1 should have no fixed point")

# note on their halting-problem line:
println("  NOTE: for FIXED n=12, settling is decidable — I just decided it by")
println("  4096-state exhaustion. Undecidability needs the unbounded family.")

# ============================================================
println()
println("="^70)
println(" C. Their own memory, raced: SET+RESET together, then release")
println("="^70)
w2 = World([[2,3],[1,4],Int[],Int[]])
clamp_step(s, clamps) = (s2 = step(w2, s); for (i,v) in clamps; s2[i]=v; end; s2)

s = BitVector([false,false,false,false])
for _ in 1:8; global s = clamp_step(s, [3=>true, 4=>true]); end     # forbidden input
seq = String[]
for _ in 1:6
    global s = clamp_step(s, [3=>false, 4=>false])                  # release both
    push!(seq, join([b ? "▮" : "·" for b in s[1:2]]))
end
println("  synchronous release:  ", join(seq, " → "), "   ← METASTABLE oscillation")
(seq[1] != seq[2] && seq[1] == seq[3]) || fail("expected sync metastability")

outcomes = Dict{String,Int}()
for _ in 1:200
    st = BitVector([false,false,false,false])
    for _ in 1:1000
        i = rand(rng, 1:2)
        st[i] = !any(st[j] for j in w2.inputs[i])
        st[1] == !(st[2]|st[3]) && st[2] == !(st[1]|st[4]) && break
    end
    k = join([b ? "▮" : "·" for b in st[1:2]])
    outcomes[k] = get(outcomes, k, 0) + 1
end
println("  asynchronous release: ", join(["$k×$v" for (k,v) in sort(collect(outcomes))], ", "),
        "   ← resolves, nondeterministically")
(length(outcomes) == 2 && !haskey(outcomes, "··") && !haskey(outcomes, "▮▮")) ||
    fail("async should resolve to one of the two memory states")

println()
println("="^70)
println(exitcode == 0 ? " ALL CHECKS PASSED — read the exit code, not the text" : " SOMETHING FAILED")
println("="^70)
exit(exitcode)
