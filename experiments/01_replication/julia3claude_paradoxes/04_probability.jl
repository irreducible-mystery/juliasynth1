# ─────────────────────────────────────────────────────────────────────────────
# 04 · Probability and statistics
#
# This is the happiest hunting ground: most probability "paradoxes" are
# either VERIDICAL (true; simulation beats intuition into shape) or
# ILL-POSED (the words underdetermine the experiment; the paradox evaporates
# the moment you are forced to write the sampling procedure).  Julia's role
# here is honest broker: code cannot leave the protocol ambiguous.
# ─────────────────────────────────────────────────────────────────────────────
module Chance

using Random, Statistics
Random.seed!(20260804)
const N = 1_000_000
section(t) = println("\n── ", t, " ", "─"^max(0, 64 - length(t)))

# ═══ Monty Hall ══════════════════════════════════════════════════════════════
section("Monty Hall — veridical; simulation is the cure")
let stay = 0, switch = 0
    for _ in 1:N
        car, pick = rand(1:3), rand(1:3)
        stay   += (pick == car)
        switch += (pick != car)      # switching wins exactly when first pick was wrong
    end
    println("P(win | stay)   ≈ ", stay / N, "    P(win | switch) ≈ ", switch / N)
end

# ═══ Bertrand's chord — an ill-posed question, three honest answers ══════════
section("Bertrand — «a random chord of a circle»")
long(c) = c > sqrt(3)                       # longer than the inscribed triangle's side
let n = 200_000
    a = count(_ -> long(2sin(abs(rand() - rand()) * π)), 1:n) / n   # random endpoints
    b = count(_ -> long(2sqrt(1 - rand()^2)), 1:n) / n              # random radial midpoint
    c = count(_ -> (x = sqrt(rand()); long(2sqrt(1 - x^2))), 1:n) / n # midpoint uniform in disk
    println("random endpoints:        P ≈ ", round(a, digits = 3), "   (exactly 1/3)")
    println("random distance:         P ≈ ", round(b, digits = 3), "   (exactly 1/2)")
    println("random midpoint in disk: P ≈ ", round(c, digits = 3), "   (exactly 1/4)")
end
# Three procedures, three answers, no contradiction: "random chord" names no
# unique distribution.  "Resolve" is the wrong frame — the question, once
# disambiguated, was never one question.  Writing the sampler IS the
# disambiguation; you cannot type this paradox into Julia and keep it.

# ═══ The boy-or-girl family ══════════════════════════════════════════════════
section("two children — the answer lives in the protocol")
let n = 2_000_000
    fam() = (rand(Bool), rand(Bool))                       # true = boy
    # protocol A: among families with ≥1 boy, P(two boys)?
    a = let hits = 0, tot = 0
        for _ in 1:n; (x, y) = fam(); (x | y) && (tot += 1; hits += x & y) end
        hits / tot
    end
    # protocol B: a random child of the family walks in, and is a boy.
    b = let hits = 0, tot = 0
        for _ in 1:n
            (x, y) = fam(); shown = rand(Bool) ? x : y
            shown && (tot += 1; hits += x & y)
        end
        hits / tot
    end
    # protocol C: among families with ≥1 boy BORN ON A TUESDAY, P(two boys)?
    c = let hits = 0, tot = 0
        for _ in 1:n
            (x, y) = fam(); dx, dy = rand(1:7), rand(1:7)
            ((x && dx == 2) || (y && dy == 2)) && (tot += 1; hits += x & y)
        end
        hits / tot
    end
    println("≥1 boy (filtered):        P(both boys) ≈ ", round(a, digits = 3), "  (1/3)")
    println("a random child is a boy:  P(both boys) ≈ ", round(b, digits = 3), "  (1/2)")
    println("≥1 Tuesday-boy:           P(both boys) ≈ ", round(c, digits = 3), "  (13/27 ≈ 0.481)")
end
# The infamous Tuesday: an irrelevant-looking detail moves the answer,
# because it changes WHICH families survive the filter.  Same lesson as
# Bertrand: the paradox is an under-specified experiment, and the code
# refuses to let it stay under-specified.

# ═══ Sleeping Beauty ═════════════════════════════════════════════════════════
section("Sleeping Beauty — halfer and thirder are both right")
let n = 400_000, headsW = 0, wakes = 0, headsE = 0
    for _ in 1:n
        h = rand(Bool)
        headsE += h
        w = h ? 1 : 2                 # heads: one awakening; tails: two
        wakes  += w
        headsW += h ? 1 : 0
    end
    println("P(heads | sampled per-experiment) ≈ ", round(headsE / n, digits = 3))
    println("P(heads | sampled per-awakening)  ≈ ", round(headsW / wakes, digits = 3))
end
# One simulated world, two denominators, ½ and ⅓.  The dispute dissolves the
# moment "credence" is cashed out as a bet: paid once per experiment → ½;
# paid at every awakening → ⅓.  Twenty years of literature is two reference
# classes wearing one word.

# ═══ The two envelopes ═══════════════════════════════════════════════════════
section("two envelopes — where the 1.25·y argument breaks")
let n = N, keep = 0.0, swap = 0.0
    for _ in 1:n
        x = rand(1:100); pair = (x, 2x); i = rand(1:2)
        keep += pair[i]; swap += pair[3 - i]
    end
    println("E[keep] ≈ ", keep / n, "    E[always switch] ≈ ", swap / n)
end
println("E[other | you hold y]  (prior: x uniform on 1:100):")
for y in (7, 50, 200)
    worlds = Float64[]
    y <= 100          && push!(worlds, 2y)      # y was the smaller envelope
    iseven(y) && y <= 200 && push!(worlds, y / 2)   # y was the larger
    println("  y = ", rpad(y, 5), "E[other] = ", rpad(mean(worlds), 7),
            "  ratio = ", round(mean(worlds) / y, digits = 3))
end
# Switching gains nothing overall — yet the seductive argument said E[other]
# = 1.25y ALWAYS.  The table shows 1.25 holds only mid-prior: small y must be
# the smaller envelope (ratio 2), large y must be the larger (ratio 0.5).
# The fallacy assumed P(smaller | y) = ½ for EVERY y, which no proper prior
# can deliver.  Falsidical: the paradox dies where the bug is found.

# ═══ St. Petersburg ══════════════════════════════════════════════════════════
section("St. Petersburg — infinite mean, modest life")
let s = 0.0, marks = Set([10^k for k in 1:7])
    payoff() = (k = 1; while rand(Bool); k += 1 end; 2.0^(k - 1))
    println("  n           running mean of the game")
    for i in 1:10^7
        s += payoff()
        i in marks && println("  ", rpad(i, 12), round(s / i, digits = 2))
    end
end
bank(K) = sum(2.0^(k - 1) * 2.0^-k for k in 1:K) + 2.0^K * 2.0^-K
println("EV against a bank capped at 2^40:  ", bank(40))
# The expectation is infinite, and the running mean duly creeps upward
# forever (≈ log₂n/2) — but any FINITE bank makes the fair price a few
# dozen coins.  The paradox is veridical about the ideal and irrelevant to
# any world with a budget; expected value, not the gambler, was the
# defective instrument (enter utility, enter medians).

# ═══ Simpson's paradox ═══════════════════════════════════════════════════════
section("Simpson — better in every subgroup, worse overall")
kidney = (small = (A = (81, 87),  B = (234, 270)),
          large = (A = (192, 263), B = (55, 80)))
pct(t) = round(100t[1] / t[2], digits = 1)
for (g, d) in pairs(kidney)
    println("  ", rpad(g, 7), "A: ", pct(d.A), "%   B: ", pct(d.B), "%   → A wins")
end
tot(x, y) = (x[1] + y[1], x[2] + y[2])
println("  ", rpad("ALL", 7), "A: ", pct(tot(kidney.small.A, kidney.large.A)),
        "%   B: ", pct(tot(kidney.small.B, kidney.large.B)), "%   → B wins")
# (Real kidney-stone data.)  Doctors gave treatment A the hard cases; the
# aggregate compares apples to case-mix.  Veridical arithmetic — but which
# number you should ACT on is a causal question, not a statistical one.
# The paradox resolved only when the graph (confounding) entered the frame.

# ═══ Berkson's paradox ═══════════════════════════════════════════════════════
section("Berkson — selection invents correlation")
let n = 200_000
    talent, looks = randn(n), randn(n)
    sel = talent .+ looks .> 1.5
    println("cor(talent, looks) everywhere:   ", round(cor(talent, looks), digits = 3))
    println("cor(talent, looks) | admitted:   ",
            round(cor(talent[sel], looks[sel]), digits = 3))
end
# Independent traits, negatively correlated among the selected — condition
# on a collider and its causes trade off.  Veridical; resolves into a rule:
# "who got into your sample?" is part of every correlation.

# ═══ Will Rogers ═════════════════════════════════════════════════════════════
section("Will Rogers — one move raises both averages")
let A = [1.0, 2, 3, 4], B = [5.0, 6, 7, 8, 9]
    println("before:  mean(A) = ", mean(A), "   mean(B) = ", mean(B))
    x = popfirst!(B); push!(A, x)
    println("move ", x, ":  mean(A) = ", mean(A), "   mean(B) = ", mean(B), "   — both rose")
end
# «When the Okies left Oklahoma for California, they raised the average
# intelligence of both states.»  Stage-migration in medicine: relabel
# borderline patients and every cohort's survival "improves" while no one
# lives a day longer.  Veridical, and a live source of statistical fraud.

# ═══ Parrondo ════════════════════════════════════════════════════════════════
section("Parrondo — two losing games make a winning one")
let steps = 2_000_000, ε = 0.005
    function play(choose)
        c = 0
        for t in 1:steps
            p = choose(t, c) == :A ? 0.5 - ε :
                (c % 3 == 0 ? 0.1 - ε : 0.75 - ε)
            c += rand() < p ? 1 : -1
        end
        c / steps
    end
    println("game A alone:    drift ≈ ", round(play((t, c) -> :A), digits = 4))
    println("game B alone:    drift ≈ ", round(play((t, c) -> :B), digits = 4))
    println("random mixture:  drift ≈ ", round(play((t, c) -> rand(Bool) ? :A : :B), digits = 4))
end
# Both games lose; flipping between them wins — game A's noise keeps game
# B's capital off its bad residues.  Veridical (it's a ratchet), and the
# intuition it violates ("losing + losing = losing") was never a theorem.

# ═══ The potato paradox ══════════════════════════════════════════════════════
section("potato — 99% water, dried to 98%")
let total = 100.0, dry = total * 0.01
    println("dry mass ", dry, " kg must become 2% of the total → total = ",
            dry / 0.02, " kg")
end
# 100 kg of potatoes lose one point of water content and half their weight.
# Veridical: percentages are ratios, and the denominator moved.  The
# humblest member of the family, and the purest: one line of arithmetic
# ends it.

end # module
