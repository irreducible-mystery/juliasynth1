# ======================================================================
# 02_mathematical.jl — MATHEMATICAL PARADOXES THAT RESOLVE.
# Falsidical paradoxes (a hidden error) and veridical ones (true but
# astonishing). Julia's rich numeric tower — Rational, BigFloat,
# Irrational, Inf, iterators — lets each resolution be *computed*.
# ======================================================================

using Printf
section(t) = println("\n", "═"^70, "\n  ", t, "\n", "═"^70)
verdict(v) = println("  VERDICT: ", v)

# ----------------------------------------------------------------------
section("ZENO'S DICHOTOMY — «motion requires completing infinitely many steps»")
# ----------------------------------------------------------------------

# Expression 1: exact rational partial sums — Julia's Rational type shows
# the sum approaching, never exceeding, 1.
s = 0//1
println("    Expression 1 (exact rationals):")
for k in 1:10
    global s += 1//2^k
    k <= 5 && println("       after step $k: distance covered = $s")
end
println("       after step 10: $s   (= 1 - 1/2¹⁰, forever short but bounded)")

# Expression 2: the limit, as an infinite-series evaluation.
println("    Expression 2 (limit): sum(0.5^k for k in 1:53) = ",
        sum(0.5^k for k in 1:53), "  → converges to 1")

# Expression 3: geometric closed form — the resolution in one line.
geom(r) = r / (1 - r)                       # Σ_{k≥1} r^k
println("    Expression 3 (closed form): Σ (1/2)ᵏ = geom(1/2) = ", geom(1//2))

# Expression 4: Zeno in *time* — infinitely many steps take FINITE time.
total_time = sum(big(1)//big(2)^k for k in 1:1000)
println("    Expression 4: time for 1000 Zeno-steps at unit speed = ",
        Float64(total_time), " → the runner arrives at t = 1.")

# Expression 5: Achilles & the tortoise as a lazy infinite iterator.
achilles = Iterators.accumulate(+, (100.0 * (0.1)^k for k in 0:20))
println("    Expression 5 (Achilles, head start 100, speed ratio 10):")
println("       meeting point = lim = ", last(collect(achilles)),
        "  (= 1000/9 = ", Float64(1000//9), ")")
verdict("FALSIDICAL — RESOLVES. The error: assuming infinitely many terms ⇒ infinite sum. Convergence refutes it.")

# ----------------------------------------------------------------------
section("GRANDI'S SERIES — 1 − 1 + 1 − 1 + ⋯ = 0? 1? ½?")
# ----------------------------------------------------------------------
g(n) = sum((-1)^k for k in 0:n-1)
println("    Partial sums:        ", [g(n) for n in 1:8], " … oscillate, never converge")
println("    Grouped (1-1)+(1-1): ", sum(fill(0, 4)), "        ← «proof» it's 0")
println("    Grouped 1+(-1+1)+…:  ", 1 + sum(fill(0, 4)), "        ← «proof» it's 1")
cesaro = [sum(g(n) for n in 1:N) / N for N in (10, 1000, 100_000)]
println("    Cesàro means:        ", round.(cesaro, digits=4), " → ½ under a *different* definition of sum")
verdict("FALSIDICAL — RESOLVES. The error: regrouping a non-convergent series. Each answer belongs to a different summation method.")

# ----------------------------------------------------------------------
section("GABRIEL'S HORN — finite volume, infinite surface area")
# ----------------------------------------------------------------------
# Rotate y = 1/x (x ≥ 1). Volume = π∫x⁻²dx = π. Area ≥ 2π∫x⁻¹dx = ∞.
horn_volume(X)  = π * sum(1/x^2 * 0.001 for x in 1:0.001:X)
horn_area_lb(X) = 2π * sum(1/x * 0.001 for x in 1:0.001:X)
@printf("    %12s %18s %22s\n", "length X", "volume → π", "surface (lower bd) → ∞")
for X in (10, 100, 1000, 10_000)
    @printf("    %12d %18.5f %22.2f\n", X, horn_volume(X), horn_area_lb(X))
end
println("    volume → π = ", Float64(π), "  while surface grows like 2π·log(X) without bound.")
println("    «Fill it with paint, yet you can't paint it» — resolved: mathematical")
println("    paint has zero thickness; physical paint doesn't.")
verdict("VERIDICAL — RESOLVES (it's simply TRUE). The astonishment, not the math, was the illusion.")

# ----------------------------------------------------------------------
section("HILBERT'S GRAND HOTEL — a full hotel with room for more")
# ----------------------------------------------------------------------
# Julia's lazy infinite iterators are a natural language for countable infinity.
rooms = Iterators.countfrom(1)                     # ℕ — every room occupied

# Expression 1: one new guest — shift everyone up.
shifted = Iterators.map(n -> n + 1, rooms)
println("    Expression 1: guest n moves to room n+1 → rooms taken: ",
        collect(Iterators.take(shifted, 8)), " … room 1 is now FREE")

# Expression 2: infinitely many new guests — evens for old, odds for new.
old = Iterators.map(n -> 2n, rooms)
println("    Expression 2: old guest n → room 2n: ",
        collect(Iterators.take(old, 6)), " … ALL odd rooms free (infinitely many)")

# Expression 3: infinitely many buses of infinitely many guests — pairing ℕ×ℕ → ℕ.
cantor(b, s) = (b + s) * (b + s + 1) ÷ 2 + s + 1
println("    Expression 3: bus b, seat s → room (b+s)(b+s+1)/2 + s + 1")
for b in 0:2, s in 0:2
    print("       (bus $b, seat $s)→room ", cantor(b, s), " ")
end
assigned = [cantor(b, s) for b in 0:99 for s in 0:99]
println("\n       10 000 guests, 10 000 distinct rooms, no collisions: ",
        length(unique(assigned)) == 10_000)
verdict("VERIDICAL — RESOLVES. ∞ + 1 = ∞ is genuinely true for countable sets; only intuition objects.")

# ----------------------------------------------------------------------
section("«1 = 2» AND FRIENDS — algebraic falsidical paradoxes, caught by Julia")
# ----------------------------------------------------------------------
# The classic proof: a=b ⇒ … ⇒ 1=2, hiding a division by (a−b) = 0.
a, b = 1, 1
println("    Expression 1: the hidden step is (a²−ab)/(a−b): Julia says ",
        "(a^2-a*b) = ", a^2 - a*b, ", (a-b) = ", a - b)
try
    (a^2 - a*b) ÷ (a - b)
catch e
    println("       integer division: 💥 ", nameof(typeof(e)), " — the «proof» divides by zero.")
end
println("       float division 0/0 = ", (a^2 - a*b) / (a - b),
        " — NaN, the honest answer for an undefined form.")

# √(x²) = x? Only for x ≥ 0 — the error behind many −1 = 1 «proofs»:
x = -5.0
println("    Expression 2: sqrt(x^2) == x for x = -5?  ", sqrt(x^2) == x,
        "   (sqrt(25) = ", sqrt(x^2), " = |x|, not x)")

# (-1)^(1/2) — Julia refuses the sloppy real-number step and demands you
# say what you mean:
print("    Expression 3: sqrt(-1.0) → ")
try sqrt(-1.0) catch e; println("💥 DomainError — «take it to ℂ *explicitly*»") end
println("       sqrt(complex(-1.0)) = ", sqrt(complex(-1.0)),
        "  and √(ab)=√a·√b now FAILS: √((-1)(-1)) = ", sqrt(complex(-1*-1)),
        " but √(-1)·√(-1) = ", sqrt(complex(-1))*sqrt(complex(-1)))
verdict("FALSIDICAL — RESOLVE. Julia's domain errors and NaN are the fallacy-detectors built into the type system.")

# ----------------------------------------------------------------------
section("MACHINE-ARITHMETIC PARADOXES — «paradoxes» Julia itself creates")
# ----------------------------------------------------------------------
println("    0.1 + 0.2 == 0.3 ?              ", 0.1 + 0.2 == 0.3,
        "     (0.1+0.2 = ", 0.1 + 0.2, ")")
println("    resolved by exact types:         1//10 + 2//10 == 3//10 → ",
        1//10 + 2//10 == 3//10)
println("    (a+b)+c == a+(b+c) for floats?   ",
        (0.1 + 0.2) + 0.3 == 0.1 + (0.2 + 0.3), "     — addition isn't associative!")
println("    typemax(Int64) + 1 = ", typemax(Int64) + 1, "  < 0 (!)")
println("    resolved by BigInt:  big(typemax(Int64)) + 1 = ", big(typemax(Int64)) + 1)
println("    NaN == NaN ?                     ", NaN == NaN,
        "   — a value not equal to itself, by design (IEEE-754)")
println("    x = NaN is the ONLY float with x != x: isequal restores identity: ",
        isequal(NaN, NaN))
verdict("FALSIDICAL — RESOLVE. The «error» is expecting ℝ from 64 bits; Rational/BigInt/isequal are the resolutions.")

# ----------------------------------------------------------------------
section("THE POTATO PARADOX — trivial arithmetic, screaming intuition")
# ----------------------------------------------------------------------
# 100 kg of potatoes, 99% water. They dry to 98% water. New weight?
dry = 100 * (1 - 0.99)                 # 1 kg of solids, unchanged
new_weight = dry / (1 - 0.98)
println("    solids = $dry kg; at 98% water, weight = solids/(1-0.98) = $new_weight kg")
println("    Halving the *non-water fraction's complement* halves nothing —")
println("    doubling the solid fraction (1%→2%) HALVES the total: 100 → 50 kg.")
verdict("VERIDICAL — RESOLVES. Three lines of arithmetic; the paradox lives only in intuition.")

# ----------------------------------------------------------------------
section("THE WHEEL OF ARISTOTLE — two circles, one journey")
# ----------------------------------------------------------------------
# Concentric wheels of radius R and r < R roll together through one turn;
# both «trace» the same horizontal distance 2πR. Does the small wheel
# have the same circumference?! No: the small wheel SLIPS — its contact
# point translates *and* rotates. Julia: compute the cycloid speeds.
R, r = 2.0, 1.0
distance = 2π * R
slip = distance - 2π * r
println("    Big wheel rolls (no slip): distance = 2πR = ", round(distance, digits=4))
println("    Small wheel's own rolling would cover 2πr = ", round(2π*r, digits=4))
println("    ⇒ the small wheel is DRAGGED an extra ", round(slip, digits=4),
        " — rolling *with slipping*.")
verdict("FALSIDICAL — RESOLVES. Hidden assumption: «traces the same distance ⇒ rolls without slipping». It doesn't.")
