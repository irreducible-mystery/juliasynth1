# ─────────────────────────────────────────────────────────────────────────────
# 05 · Decision, games, and the social
#
# Paradoxes of choice are rarely contradictions; they are places where two
# formalizations of "rational" part company (Newcomb), where a property of
# individuals fails to survive aggregation (Condorcet, Braess), or where the
# self-reference of the liar sneaks back in wearing a judge's robe (the
# unexpected hanging).
# ─────────────────────────────────────────────────────────────────────────────
module Choices

using Random
Random.seed!(20260804)
section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

# ═══ Newcomb's problem ═══════════════════════════════════════════════════════
section("Newcomb — two rationalities, one box or two")
let n = 200_000, acc = 0.90
    function payout(onebox)
        predicted_onebox = rand() < acc ? onebox : !onebox
        b = predicted_onebox ? 1_000_000 : 0
        onebox ? b : b + 1_000
    end
    ev1 = sum(payout(true)  for _ in 1:n) / n
    ev2 = sum(payout(false) for _ in 1:n) / n
    println("predictor accuracy 90%:   EV(one-box) ≈ ", round(Int, ev1),
            "   EV(two-box) ≈ ", round(Int, ev2))
    println("break-even accuracy:      p = 0.5005")
end
# Dominance reasoning says two-box (whatever is in the boxes, +\$1000).
# Expected-value reasoning says one-box.  Both are impeccable INSIDE their
# decision theory; the theories disagree about whether your choice may be
# evidence about the world that produced you.  Nothing here "resolves" —
# Newcomb is a fork in the definition of rationality, and fifty years of
# causal vs evidential decision theory is the fork, formalized.

# ═══ Condorcet's cycle ═══════════════════════════════════════════════════════
section("Condorcet — transitive voters, cyclic electorate")
ballots = [[:A, :B, :C], [:B, :C, :A], [:C, :A, :B]]
prefers(b, x, y) = findfirst(==(x), b) < findfirst(==(y), b)
for (x, y) in ((:A, :B), (:B, :C), (:C, :A))
    v = count(b -> prefers(b, x, y), ballots)
    println("  $x beats $y,  $(v)–$(3 - v)")
end
# Every voter is perfectly transitive; the majority is a cycle.  A > B > C > A.
# Veridical, and the seed of Arrow's theorem: "the will of the people" is not
# guaranteed to exist.  The paradox dissolves once you stop assuming the
# group is an agent — aggregation does not preserve agency.

# ═══ Braess's paradox ════════════════════════════════════════════════════════
section("Braess — a free road that slows everyone down")
function equilibrium(nroutes; drivers = 4000)
    counts = zeros(Int, nroutes); counts[1] = drivers
    cost(r, cnt) = begin
        up   = cnt[1] + (nroutes == 3 ? cnt[3] : 0)   # load on the A-side thin road
        down = cnt[2] + (nroutes == 3 ? cnt[3] : 0)   # load on the B-side thin road
        r == 1 ? up / 100 + 45 :
        r == 2 ? 45 + down / 100 :
                 up / 100 + down / 100                # via the free bridge
    end
    for _ in 1:100_000                    # one myopic driver moves per pass, until stable
        moved = false
        for r in 1:nroutes
            counts[r] == 0 && continue
            cr = cost(r, counts)
            for s in 1:nroutes
                s == r && continue
                counts[r] -= 1; counts[s] += 1
                if cost(s, counts) < cr - 1e-9
                    moved = true; break
                end
                counts[s] -= 1; counts[r] += 1
            end
            moved && break
        end
        moved || break
    end
    counts, [round(cost(r, counts), digits = 1) for r in 1:nroutes]
end
c2, t2 = equilibrium(2)
c3, t3 = equilibrium(3)
println("without the bridge:  flows ", c2, "   travel times ", t2)
println("with a free bridge:  flows ", c3, "   travel times ", t3)
# Add a zero-cost link and the selfish equilibrium worsens for every single
# driver (65 → 80).  Veridical: Nash equilibria don't minimize anything.
# The "paradox" resolves into the price of anarchy — and into real cities
# (Seoul demolished a highway and traffic improved).

# ═══ The unexpected hanging ══════════════════════════════════════════════════
section("the unexpected hanging — backward induction eats itself")
# Judge: «you will be hanged one day next week, and it will be a surprise.»
# The prisoner's elimination argument, run literally:
let days = collect(1:5)
    while !isempty(days)
        d = pop!(days)
        println("  day $d eliminated: were the hanging still possible then, ",
                "it would be predictable on its eve")
    end
    println("  ⇒ the prisoner concludes: no surprise hanging is possible")
end
# Now iterate what the decree MEANS against what the prisoner BELIEVES.
# "Surprising" = not in the prisoner's set of predictable days.  If he
# believes the decree, elimination empties his set; with an empty set,
# every day would surprise him — so the decree is satisfiable after all;
# so he believes it again; so elimination empties the set; …
let S = Set(1:5)
    for round in 1:4
        println("  round $round: prisoner's possible-days = ",
                isempty(S) ? "∅  → any day would surprise → decree revives" : sort(collect(S)))
        S = isempty(S) ? Set(1:5) : Set{Int}()
    end
end
# The belief state has no fixed point: ruling all days out makes every day a
# surprise, which rules them back in.  Wednesday comes; the prisoner, having
# proven it impossible, is duly surprised; the decree was TRUE.  This is the
# liar's ungroundedness in temporal costume — the decree quantifies over the
# prisoner's inferences about the decree.  It does not resolve; it oscillates.

end # module
