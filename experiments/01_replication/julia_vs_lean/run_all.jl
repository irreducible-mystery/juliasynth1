# run_all.jl — evaluate the C6 theorem battery in every Julia carrier,
# report agreement/disagreement with the 66 kernel-verified Lean theorems,
# then run what Lean could not.
include("mu4_core.jl")
using .Mu4
using Printf

exitcode = 0
fail(msg) = (global exitcode = 1; println("  ** FAIL ** ", msg))

println("="^78)
println(" PART A — one Lean object, many Julia carriers")
println("="^78)

for r in REPS
    println("\n--- ", r.name)
    iso = iso_report(r)
    println("  bridge to canonical Z/4 (Lean needed theorems toGZ_*): ",
        iso.ok ? "hom+σ+inv+one+injective ALL HOLD" : "BROKEN $(iso)")
    iso.ok || fail("iso $(r.name)")
    checks = battery(r)
    bad = [n for (n,v) in checks if v != Mu4.ORACLE]
    if isempty(bad)
        println("  battery: $(length(checks))/$(length(checks)) agree with the Lean kernel")
    else
        fail("$(r.name): disagreements: $(bad)")
    end
end

println("\n", "="^78)
println(" PART B — same carrier, different EQUALITY: where Julia disagrees")
println("="^78)

for r in (FLOAT_EXACT, FLOAT_APPROX)
    println("\n--- ", r.name)
    checks = battery(r)
    bad = [n for (n,v) in checks if v != Mu4.ORACLE]
    if isempty(bad)
        println("  battery: all $(length(checks)) agree")
    else
        println("  DISAGREES with the Lean kernel on $(length(bad))/$(length(checks)) lines:")
        for n in bad; println("     x ", n); end
        z = r.els[2] * r.els[2]        # i*i in floating point
        @printf("     because e.g. i*i = %.17g %+.17gim  (≠ -1 exactly)\n", real(z), imag(z))
    end
end
# floating exact == MUST disagree somewhere, otherwise this demo is broken:
any(v != Mu4.ORACLE for (_,v) in battery(FLOAT_EXACT)) ||
    fail("FLOAT_EXACT unexpectedly agreed everywhere")
all(v == Mu4.ORACLE for (_,v) in battery(FLOAT_APPROX)) ||
    fail("FLOAT_APPROX should agree everywhere")

println("\n", "="^78)
println(" PART C — hexagon/braiding battery over three exact rings (free generality)")
println("="^78)
for (nm, one_, mk) in hex_carriers()
    checks = hexagon_battery(one_, mk)
    bad = [n for (n,v) in checks if !v]
    println("  ", rpad(nm, 28), isempty(bad) ? "all $(length(checks)) agree with Lean" :
        "FAIL $(bad)")
    isempty(bad) || fail("hexagon $(nm)")
end

println("\n", "="^78)
println(" PART D — C6_Gap.lean: the Z/n sweep, re-derived")
println("="^78)

negm(n,x) = mod(n - mod(x,n), n)
actk(n,k,a,x) = a ? mod(k*x, n) : mod(x, n)
gi3(a,b,c) = 4a+2b+c+1; gi2(a,b) = 2a+b+1
d3k(n,k,F,a,b,c,d) = mod(actk(n,k,a==1,F[gi3(b,c,d)]) + negm(n,F[gi3(xor(a,b),c,d)]) +
    F[gi3(a,xor(b,c),d)] + negm(n,F[gi3(a,b,xor(c,d))]) + F[gi3(a,b,c)], n)
d2k(n,k,g,a,b,c) = mod(actk(n,k,a==1,g[gi2(b,c)]) + negm(n,g[gi2(xor(a,b),c)]) +
    g[gi2(a,xor(b,c))] + negm(n,g[gi2(a,b)]), n)
iscocN(n,k,F) = all(d3k(n,k,F,a,b,c,d) == 0 for a in 0:1, b in 0:1, c in 0:1, d in 0:1)
iscobOf(n,k,g,F) = all(d2k(n,k,g,a,b,c) == mod(F[gi3(a,b,c)], n) for a in 0:1, b in 0:1, c in 0:1)
topN(u) = [ (i == gi3(1,1,1)) ? u : 0 for i in 1:8 ]
gge4(g00,g01,g10,g11) = [g00,g01,g10,g11]
sqrtsOfOne(n) = [k for k in 0:n-1 if mod(k*k, n) == mod(1, n)]

gapchecks = Pair{String,Bool}[
  "seal_mu4_trivial_action"  => iscocN(4,1,topN(2)) && !iscocN(4,1,topN(1)),
  "seal_mu4_inversion"       => iscocN(4,3,topN(1)) && iscocN(4,3,topN(2)),
  "seal_fermion_trivialised" => iscobOf(4,3,gge4(3,3,1,2),topN(2)),
  "seal_i_is_cocycle"        => iscocN(4,3,topN(1)),
  "pinch_odd_not_cocycles"   => all(!iscocN(8,3,topN(u)) for u in (1,3,5,7)),
  "pinch_all_cocycles_are_coboundaries" =>
        iscocN(8,3,topN(0)) && iscobOf(8,3,gge4(7,7,5,5),topN(0)) &&
        iscocN(8,3,topN(2)) && iscobOf(8,3,gge4(7,7,5,6),topN(2)) &&
        iscocN(8,3,topN(4)) && iscobOf(8,3,gge4(7,7,5,7),topN(4)) &&
        iscocN(8,3,topN(6)) && iscobOf(8,3,gge4(7,7,5,4),topN(6)),
  "no_pinch_at_inversion"    => iscocN(8,7,topN(1)) &&
        all(!iscobOf(8,7,gge4(a,b,c,d),topN(1)) for a in 0:1, b in 0:1, c in 0:1, d in 0:1),
  "two_actions_at_mu4"       => sqrtsOfOne(4) == [1,3],
  "four_actions_at_mu8"      => sqrtsOfOne(8) == [1,3,5,7],
  "four_actions_at_mu12"     => sqrtsOfOne(12) == [1,5,7,11],
  "definite_article_accident"=> length(sqrtsOfOne(4)) == 2 && length(sqrtsOfOne(8)) == 4,
  "mu3_trivial_only_zero"    => iscocN(3,1,topN(0)) && !iscocN(3,1,topN(1)) && !iscocN(3,1,topN(2)),
  "mu3_inversion_total_pinch"=> all(iscocN(3,2,topN(u)) for u in 0:2) &&
        iscobOf(3,2,gge4(2,2,1,1),topN(0)) && iscobOf(3,2,gge4(2,2,1,2),topN(1)) &&
        iscobOf(3,2,gge4(2,2,1,0),topN(2)),
  "mu5_inversion_total_pinch"=> all(iscocN(5,4,topN(u)) for u in 0:4) &&
        iscobOf(5,4,gge4(4,4,1,1),topN(0)) && iscobOf(5,4,gge4(4,4,1,3),topN(1)) &&
        iscobOf(5,4,gge4(4,4,1,0),topN(2)) && iscobOf(5,4,gge4(4,4,1,2),topN(3)) &&
        iscobOf(5,4,gge4(4,4,1,4),topN(4)),
  "odd_asymmetry"            => !iscocN(5,1,topN(1)) && iscocN(5,4,topN(1)) &&
                                !iscocN(3,1,topN(1)) && iscocN(3,2,topN(1)),
]
for (n,v) in gapchecks
    println("  ", v ? "ok   " : "FAIL ", n); v || fail("gap $(n)")
end

println("\n", "="^78)
println(" PART E — where Julia's defaults silently DISAGREE: machine integers")
println("="^78)
# Lean's Nat/Int are arbitrary precision INSIDE THE LOGIC. Julia's default Int64 wraps.
big_val = big(2)^63 - 1
println("  Lean-Nat-style (BigInt):  (2^63-1)+1 = ", big_val + 1)
println("  Julia default  (Int64):   typemax+1  = ", typemax(Int64) + 1, "   <-- silent wrap")
println("  A 'theorem' ∀-checked over Int64 quantifies over a RING Z/2^64, not Z.")
(typemax(Int64) + 1 == typemin(Int64)) || fail("expected wraparound")

println("\n", "="^78)
println(" PART F — THE EXTENSION: the 4^8 = 65536-symbol sweep Lean could NOT decide")
println(" (NOT-PROVED.md §1: two kernel runs died; #eval-only numbers were 32/64/8)")
println("="^78)

# full sweep over all U-valued symbols using the log-form carrier (Z/4, fast)
function full_sweep()
    # symbol = 8 base-4 digits
    conj4(x) = mod(-x, 4)
    function d3full(tw, F, a,b,c,d)
        lead = F[gi3(b,c,d)]
        lead = (tw && a==1) ? conj4(lead) : lead
        mod(lead - F[gi3(xor(a,b),c,d)] + F[gi3(a,xor(b,c),d)] -
            F[gi3(a,b,xor(c,d))] + F[gi3(a,b,c)], 4)
    end
    pent(F) = all(mod(F[gi3(a,b,c)] + F[gi3(a,xor(b,c),d)] + F[gi3(b,c,d)] -
                      F[gi3(xor(a,b),c,d)] - F[gi3(a,b,xor(c,d))], 4) == 0
                  for a in 0:1, b in 0:1, c in 0:1, d in 0:1)
    coc(tw,F) = all(d3full(tw,F,a,b,c,d) == 0 for a in 0:1, b in 0:1, c in 0:1, d in 0:1)
    zU = 0; zT = 0; shared = 0; pentagon_iff_untwisted = true
    F = zeros(Int, 8)
    for code in 0:(4^8 - 1)
        cc = code
        for i in 1:8
            F[i] = cc & 3; cc >>= 2
        end
        cu = coc(false, F); ct = coc(true, F); p = pent(F)
        zU += cu; zT += ct; shared += (cu && ct)
        (p == cu) || (pentagon_iff_untwisted = false)
    end
    (zU=zU, zT=zT, shared=shared, piff=pentagon_iff_untwisted)
end

t = @elapsed s = full_sweep()
@printf("  swept all 65536 symbols in %.2fs\n", t)
println("  |Z3| untwisted           = ", s.zU,     "   (claimed, unproved in Lean: 32)")
println("  |Z3| conjugation-twisted = ", s.zT,     "   (claimed, unproved in Lean: 64)")
println("  shared                   = ", s.shared, "   (claimed, unproved in Lean: 8)")
println("  pentagon <-> untwisted-cocycle over ALL 65536: ", s.piff)
(s.zU == 32 && s.zT == 64 && s.shared == 8 && s.piff) ||
    fail("full sweep does not match the #eval-claimed numbers")

# and the quotient the Lean artifact never states:
println("  => H3 sizes (|Z3|/|B3|): untwisted ", s.zU, "/16 = ", div(s.zU,16),
        ";  twisted ", s.zT, "/32 = ", div(s.zT,32),
        "  (kernel-checked in Lean only as B3 counts)")

println("\n", "="^78)
println(" PART G — the generic gd3, duck-typed (Lean's ∀ M : Type, as dispatch)")
println("="^78)
# instantiate Lean's fully generic theorem statement on a carrier Lean never named:
# STRINGS under concatenation-of-rotations... no — honestly: Z/6, never mentioned anywhere.
mul6(x,y) = mod(x+y,6); inv6(x) = mod(-x,6); sig6(x) = mod(-x,6)
fixed_ok = true
for m in (0, 3)                       # fixed locus of negation mod 6: {0,3}
    F(a,b,c) = m
    for a in (false,true), b in (false,true), c in (false,true), d in (false,true)
        gd3(mul6,inv6,sig6,true,F,a,b,c,d) == gd3(mul6,inv6,sig6,false,F,a,b,c,d) ||
            (global fixed_ok = false)
    end
end
println("  twist_invisible_on_fixed instantiated at Z/6 (untouched by Lean): ",
    fixed_ok ? "holds" : "FAILS")
fixed_ok || fail("gd3 Z/6")
# sharpness: off the fixed locus they differ
F1(a,b,c) = 1
differs = any(gd3(mul6,inv6,sig6,true,F1,a,b,c,d) != gd3(mul6,inv6,sig6,false,F1,a,b,c,d)
    for a in (false,true), b in (false,true), c in (false,true), d in (false,true))
println("  and off the fixed locus (m=1) the readings differ: ", differs)
differs || fail("sharpness Z/6")

println("\n", "="^78)
println(exitcode == 0 ? " ALL JULIA CHECKS PASSED — read the exit code, not the text" :
                        " SOMETHING FAILED")
println("="^78)
exit(exitcode)
