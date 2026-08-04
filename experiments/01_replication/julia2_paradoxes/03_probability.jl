# ======================================================================
# 03_probability.jl — PROBABILITY & DECISION PARADOXES.
# Mostly VERIDICAL: the shocking answer is TRUE, and Monte Carlo
# simulation is Julia's native way to *demonstrate* the resolution.
# One (Two Envelopes) still fuels philosophical debate; one
# (St. Petersburg) is resolved only by changing the utility model.
# ======================================================================

using Random, Statistics, Printf
Random.seed!(42)
section(t) = println("\n", "═"^70, "\n  ", t, "\n", "═"^70)
verdict(v) = println("  VERDICT: ", v)
const N = 100_000

# ----------------------------------------------------------------------
section("MONTY HALL — switch or stay?")
# ----------------------------------------------------------------------

# Expression 1: full simulation of the protocol.
function monty(strategy; trials=N)
    wins = 0
    for _ in 1:trials
        car    = rand(1:3)
        pick   = rand(1:3)
        opened = rand(setdiff(1:3, (car, pick)))          # host opens a goat door
        final  = strategy === :stay ? pick : only(setdiff(1:3, (pick, opened)))
        wins  += (final == car)
    end
    wins / trials
end
println("    Expression 1 (simulate the game):  stay = ", monty(:stay),
        "   switch = ", monty(:switch))

# Expression 2: one-liner — switching wins exactly when the first pick was wrong.
p_switch = count(rand(1:3) != rand(1:3) for _ in 1:N) / N
println("    Expression 2 (one-liner):          P(win | switch) = P(first pick wrong) = ",
        p_switch)

# Expression 3: exact enumeration over the whole sample space — no randomness.
exact = count(pick != car for car in 1:3, pick in 1:3) // 9
println("    Expression 3 (exact enumeration):  ", exact, " = 2/3, no dice needed")

# Expression 4: the crucial hidden assumption — a host who opens a RANDOM
# door (and may reveal the car) destroys the advantage:
function ignorant_monty(; trials=N)
    w = s = 0
    for _ in 1:trials
        car, pick = rand(1:3), rand(1:3)
        opened = rand(setdiff(1:3, pick))
        opened == car && continue                          # game void
        s += 1; w += (only(setdiff(1:3, (pick, opened))) == car)
    end
    w / s
end
println("    Expression 4 (ignorant host):      P(win | switch) = ",
        round(ignorant_monty(), digits=3), " — advantage GONE. The paradox",
        " lives in the host's knowledge.")
verdict("VERIDICAL — RESOLVES. 2/3 is correct; intuition ignores that the host's choice is informative.")

# ----------------------------------------------------------------------
section("BIRTHDAY PARADOX — 23 people, >50% shared birthday")
# ----------------------------------------------------------------------
p_exact(n) = 1 - prod((365 - k) / 365 for k in 0:n-1)
p_sim(n)   = count(_ -> !allunique(rand(1:365, n)), 1:20_000) / 20_000
@printf("    %6s %12s %12s\n", "n", "exact", "simulated")
for n in (10, 23, 41, 70)
    @printf("    %6d %12.4f %12.4f\n", n, p_exact(n), p_sim(n))
end
println("    Why intuition fails: 23 people = binomial(23,2) = ", binomial(23, 2),
        " pairs — you're not comparing with YOUR birthday, but all-vs-all.")
verdict("VERIDICAL — RESOLVES. Exact product formula and simulation agree perfectly.")

# ----------------------------------------------------------------------
section("SIMPSON'S PARADOX — the trend in every group reverses in the total")
# ----------------------------------------------------------------------
# Real data: UC Berkeley 1973 admissions (classic six departments).
berkeley = [   # dept, men_applied, men_admitted, women_applied, women_admitted
    ("A", 825, 512,  108,  89), ("B", 560, 353,   25,  17),
    ("C", 325, 120,  593, 202), ("D", 417, 138,  375, 131),
    ("E", 191,  53,  393,  94), ("F", 373,  22,  341,  24),
]
println("    Per-department admission rates (UC Berkeley 1973):")
women_better = 0
for (d, ma, mA, wa, wA) in berkeley
    m, w = mA/ma, wA/wa
    global women_better += (w >= m)
    @printf("       dept %s:  men %5.1f%%   women %5.1f%%  %s\n",
            d, 100m, 100w, w >= m ? "← women ≥ men" : "")
end
Ma, MA = sum(x[2] for x in berkeley), sum(x[3] for x in berkeley)
Wa, WA = sum(x[4] for x in berkeley), sum(x[5] for x in berkeley)
@printf("    Women do as well or better in %d of 6 departments…\n", women_better)
@printf("    …yet OVERALL:  men %.1f%%  vs  women %.1f%%  — the aggregate reverses!\n",
        100MA/Ma, 100WA/Wa)
println("    Resolution: women applied to the *competitive* departments —")
println("    department choice is a confounder; the aggregate compares unlike pools.")
verdict("VERIDICAL — RESOLVES. Both computations are true; they answer different causal questions.")

# ----------------------------------------------------------------------
section("PARRONDO'S PARADOX — two losing games make a winning one")
# ----------------------------------------------------------------------
# Game A: lose-biased coin. Game B: capital-dependent coins, also losing.
# Alternating them WINS. (ε = 0.005)
const ε = 0.005
playA(c) = rand() < 0.5 - ε ? c + 1 : c - 1
playB(c) = c % 3 == 0 ? (rand() < 0.10 - ε ? c + 1 : c - 1) :
                        (rand() < 0.75 - ε ? c + 1 : c - 1)
function run_game(pick; rounds=100, trials=20_000)
    total = 0
    for _ in 1:trials
        c = 0
        for t in 1:rounds
            c = pick(t)(c)
        end
        total += c
    end
    total / trials
end
resA  = run_game(t -> playA)
resB  = run_game(t -> playB)
resAB = run_game(t -> t % 2 == 1 ? playA : playB)
resR  = run_game(t -> rand(Bool) ? playA : playB)
@printf("    A alone:        mean capital after 100 rounds = %+7.3f  (losing)\n", resA)
@printf("    B alone:        mean capital after 100 rounds = %+7.3f  (losing)\n", resB)
@printf("    ABAB…:          mean capital after 100 rounds = %+7.3f  ← WINNING\n", resAB)
@printf("    random A/B:     mean capital after 100 rounds = %+7.3f  ← even random mixing wins\n", resR)
println("    Resolution: game B's payoff depends on capital mod 3; playing A")
println("    reshuffles the capital distribution into B's favourable states.")
verdict("VERIDICAL — RESOLVES. A rigorous ratchet effect (it powers real Brownian-motor physics).")

# ----------------------------------------------------------------------
section("TWO ENVELOPES — «the other envelope is always better»")
# ----------------------------------------------------------------------
# One envelope holds x, the other 2x. You hold A. The seductive argument:
# E[other] = ½(2A) + ½(A/2) = 1.25A ⇒ always switch ⇒ …switch forever?

# Expression 1: simulate honestly — switching gains nothing.
function envelopes(; trials=N)
    keep = swap = 0.0
    for _ in 1:trials
        x = rand(1:100)
        pair = (x, 2x)
        i = rand(1:2)
        keep += pair[i]; swap += pair[3 - i]
    end
    (keep / trials, swap / trials)
end
k, s = envelopes()
@printf("    Expression 1 (simulation): E[keep] = %.2f   E[swap] = %.2f   — identical.\n", k, s)

# Expression 2: expose the fallacy. The «A» in ½·2A + ½·A/2 is two DIFFERENT
# conditional quantities. Condition properly on the pair (x, 2x):
x = 10
println("    Expression 2 (the broken step): given the pair ($x, $(2x)):")
println("       if A = $x (small), other = $(2x): gain +$x")
println("       if A = $(2x) (large), other = $x: gain -$x")
println("       E[gain] = ½($x) + ½(-$x) = 0.  The «1.25A» treated A as fixed in both branches.")

# Expression 3: the paradox has real bite in a variant — with an unbounded
# prior the expectation genuinely diverges, and decision theory strains:
amounts = [2.0^k for k in 1:60]                        # heavy-tailed pair values
w = [(3/4) * (1/3)^k for k in 1:60]                    # a prior making E infinite-ish
println("    Expression 3 (unbounded prior): E[amount] under heavy tail = ",
        round(sum(amounts .* w ./ sum(w)), digits=2),
        " — with infinite-mean priors, «always switch» arguments never fully die.")
verdict("MOSTLY RESOLVES (fallacious conditioning), but the unbounded-prior variant remains philosophically contested.")

# ----------------------------------------------------------------------
section("ST. PETERSBURG PARADOX — a game of infinite expected value")
# ----------------------------------------------------------------------
# Flip until first tails; payoff 2^(#heads). E = Σ ½ᵏ·2ᵏ⁻¹... = ∞.
petersburg() = (n = 0; while rand(Bool); n += 1; end; 2.0^n)

# Expression 1: theoretical expectation diverges (partial sums grow without bound):
partialE(K) = sum(0.5^k * 2.0^(k-1) for k in 1:K)
println("    Expression 1: E over first K outcomes: K=10 → ", partialE(10),
        ",  K=100 → ", partialE(100), "  (each term adds ½: diverges)")

# Expression 2: yet empirical means stay small and unstable:
means = [mean(petersburg() for _ in 1:100_000) for _ in 1:5]
println("    Expression 2: five separate 100k-game averages: ",
        round.(means, digits=2), " — «infinite» value, single-digit experience.")

# Expression 3: Bernoulli's resolution — log utility makes the fair price finite:
fair_log = sum(0.5^k * log(2.0^(k-1)) for k in 1:60)
println("    Expression 3: E[log payoff] = ", round(fair_log, digits=4),
        " ⇒ certainty-equivalent = e^", round(fair_log, digits=4), " ≈ ",
        round(exp(fair_log), digits=2), " ducats — a sane price.")

# Expression 4: any finite bankroll caps the value — the casino resolution:
capped(B) = sum(0.5^k * min(2.0^(k-1), B) for k in 1:200)
println("    Expression 4: capped payoffs: bank=10⁶ → fair price ",
        round(capped(1e6), digits=2), ";  bank=10⁹ → ",
        round(capped(1e9), digits=2), "  (only log-growth in the cap)")
verdict("RESOLVES only by CHANGING THE MODEL (utility or finiteness) — expectation alone is the wrong yardstick.")

# ----------------------------------------------------------------------
section("BERTRAND'S PARADOX — «random chord»: one question, three answers")
# ----------------------------------------------------------------------
# P(random chord of unit circle is longer than √3, the inscribed-triangle side)?
side = sqrt(3)
chordlen(p1, p2) = hypot(p1[1]-p2[1], p1[2]-p2[2])
randpt() = (θ = 2π*rand(); (cos(θ), sin(θ)))

# Method 1: two random endpoints on the circle.
m1 = count(_ -> chordlen(randpt(), randpt()) > side, 1:N) / N
# Method 2: random radius, random point along it (chord ⊥ radius).
m2 = count(_ -> 2*sqrt(1 - rand()^2) > side, 1:N) / N
# Method 3: random midpoint uniform in the disk.
m3 = count(1:N) do _
    while true
        x, y = 2rand()-1, 2rand()-1
        if x^2 + y^2 <= 1
            return 2*sqrt(1 - (x^2+y^2)) > side
        end
    end
end / N
println("    Method 1 (random endpoints):  P = ", round(m1, digits=3), "   (theory: 1/3)")
println("    Method 2 (random radius):     P = ", round(m2, digits=3), "   (theory: 1/2)")
println("    Method 3 (random midpoint):   P = ", round(m3, digits=3), "   (theory: 1/4)")
println("    Three impeccable computations, three answers: «uniformly random chord»")
println("    is UNDERSPECIFIED. Julia forces you to pick a measure — and each")
println("    `rand()` call above is a different philosophical commitment.")
verdict("DISSOLVES rather than resolves: the question was ill-posed. (Jaynes' invariance argument favours 1/2, still debated.)")

# ----------------------------------------------------------------------
section("BENFORD'S LAW — «random data» whose first digits aren't uniform")
# ----------------------------------------------------------------------
# First digit of 2^k via logs (2^3000 overflows Float64 — itself a nice
# machine-arithmetic moral): digit = ⌊10^frac(k·log₁₀2)⌋.
first_digit_of_2pow(k) = floor(Int, 10.0^mod(k * log10(2), 1))
counts = [count(k -> first_digit_of_2pow(k) == d, 1:3000) for d in 1:9] ./ 3000
benford = [log10(1 + 1/d) for d in 1:9]
@printf("    %8s %12s %12s\n", "digit", "powers of 2", "Benford log₁₀(1+1/d)")
for d in 1:9
    @printf("    %8d %12.3f %12.3f\n", d, counts[d], benford[d])
end
println("    Digit 1 leads ~30%% of the time. Resolution: scale-invariant data is")
println("    uniform in log-space, and log-uniformity ⇒ Benford exactly.")
verdict("VERIDICAL — RESOLVES. So well understood it's used in court to catch fabricated accounts.")
