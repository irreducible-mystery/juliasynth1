# mu4_core.jl — the object Lean fixed as `inductive U | u1 | ui | um1 | umi`,
# realised in MANY Julia carriers, with the cochain machinery of C6_Twist.lean
# written ONCE, generically over the carrier.
#
# Lean had exactly one representation and had to PROVE a bridge (toGZ_mul,
# toGZ_conj, toGZ_inj, is_unit) to relate it to a second one.
# Julia expresses "same group, different carrier" as a value: a rep is data.
#
# Canonical labelling everywhere: k ∈ 0:3 stands for i^k  (0=1, 1=i, 2=-1, 3=-i)

module Mu4

export REPS, FLOAT_EXACT, FLOAT_APPROX, battery, ORACLE, iso_report,
       hexagon_battery, hex_carriers, topcell, gd3

# ======================================================================
# CARRIER 1 — enum + literal Cayley table: the closest mirror of Lean's
# `inductive U` with its `match`-arm multiplication. Nominal type, no meaning.
@enum UEnum u1=0 ui=1 um1=2 umi=3
const MUL_TAB = [u1  ui  um1 umi;
                 ui  um1 umi u1 ;
                 um1 umi u1  ui ;
                 umi u1  ui  um1]          # transcribed from Lean's match arms
const CONJ_TAB = [u1, umi, um1, ui]        # Lean: conj | u1=>u1 | ui=>umi | ...
const INV_TAB  = [u1, umi, um1, ui]        # Lean: inv  (same arms — that IS conj_eq_inv)

rep_enum = (name = "enum + Cayley table  (literal mirror of Lean's inductive U)",
    els = [u1, ui, um1, umi], one = u1,
    mul = (x,y) -> MUL_TAB[Int(x)+1, Int(y)+1],
    inv = x -> INV_TAB[Int(x)+1],
    sig = x -> CONJ_TAB[Int(x)+1],
    eq  = (x,y) -> x === y)

# ======================================================================
# CARRIER 2 — Complex{Int}: native Gaussian integers. Lean built `structure GZ`
# and its `mul`/`conj` BY HAND; Julia ships the whole ring in Base.
const CI = Complex{Int}
gauss_inv(z::CI) = conj(z)                 # on units; independently checked below
rep_gauss = (name = "Complex{Int}  (Julia-native Gaussian integers — Lean built GZ by hand)",
    els = CI[1, im, -1, -im], one = CI(1),
    mul = *, inv = gauss_inv, sig = conj,
    eq  = ==)

# ======================================================================
# CARRIER 3 — additive log form: μ4 ≅ Z/4, k ↔ i^k. Multiplication becomes
# ADDITION; σ becomes NEGATION. Here `conj_eq_inv` is not a theorem but a
# definitional identity — both are `x -> mod(-x,4)`.
rep_log = (name = "Int mod 4  (log form: mul is +, σ is negation — conj_eq_inv is definitional)",
    els = [0,1,2,3], one = 0,
    mul = (x,y) -> mod(x+y,4),
    inv = x -> mod(-x,4),
    sig = x -> mod(-x,4),
    eq  = ==)

# ======================================================================
# CARRIER 4 — 2×2 integer matrices ⟨J⟩, J = [0 -1; 1 0] (rotation by π/2).
# σ is TRANSPOSE — complex conjugation acquires a linear-algebra meaning.
# inv is the adjugate (det = 1). Stored as NTuple{4,Int} row-major (a,b,c,d).
mat_mul(x,y) = (x[1]*y[1]+x[2]*y[3], x[1]*y[2]+x[2]*y[4],
                x[3]*y[1]+x[4]*y[3], x[3]*y[2]+x[4]*y[4])
rep_mat = (name = "2x2 integer matrices <J>  (σ = transpose, inv = adjugate)",
    els = [(1,0,0,1), (0,-1,1,0), (-1,0,0,-1), (0,1,-1,0)], one = (1,0,0,1),
    mul = mat_mul,
    inv = x -> (x[4], -x[2], -x[3], x[1]),
    sig = x -> (x[1], x[3], x[2], x[4]),
    eq  = ==)

# ======================================================================
# CARRIER 5 — permutations (regular representation): k ↦ (j ↦ j+k mod 4).
# mul is COMPOSITION. σ has NO intrinsic meaning here except as permutation
# inversion — which only works because conj = inv on the units. The carrier
# itself exposes that theorem.
perm_inv(p) = ntuple(i -> findfirst(==(i-1), p) - 1, 4)
rep_perm = (name = "permutations of 4 points  (regular rep: mul = composition, σ = perm inverse)",
    els = [ntuple(j -> mod(j-1+k,4), 4) for k in 0:3], one = (0,1,2,3),
    mul = (p,q) -> ntuple(j -> p[q[j]+1], 4),
    inv = perm_inv,
    sig = perm_inv,
    eq  = ==)

# ======================================================================
# CARRIER 6 — one-hot bit masks in a UInt8 nibble: k ↦ 1 << k.
# mul is a bit shift; σ swaps bits 1 and 3 by XOR with 0x0A.
bitk(x::UInt8) = trailing_zeros(x)
rep_bits = (name = "one-hot UInt8 bitmasks  (mul = bit rotation, σ = xor-swap 0x0A)",
    els = UInt8[0x01, 0x02, 0x04, 0x08], one = 0x01,
    mul = (x,y) -> UInt8(0x01) << mod(bitk(x)+bitk(y), 4),
    inv = x -> (x == 0x02 || x == 0x08) ? xor(x, 0x0a) : x,
    sig = x -> (x == 0x02 || x == 0x08) ? xor(x, 0x0a) : x,
    eq  = ==)

# ======================================================================
# CARRIER 7 — exact rational angles: k ↦ k//4 of a full turn, mod 1.
# The "unit circle" made exact. σ = angle negation.
rep_rat = (name = "Rational angles mod 1  (k//4 of a turn — the unit circle, exact)",
    els = [0//1, 1//4, 1//2, 3//4], one = 0//1,
    mul = (x,y) -> mod(x+y, 1//1),
    inv = x -> mod(-x, 1//1),
    sig = x -> mod(-x, 1//1),
    eq  = ==)

const REPS = [rep_enum, rep_gauss, rep_log, rep_mat, rep_perm, rep_bits, rep_rat]

# ======================================================================
# CARRIER 8 — the SAME carrier, TWO equalities. ComplexF64 points e^{ikπ/2}.
# Lean has one propositional =. Julia has ==, ===, isapprox, isequal.
# With exact == this carrier BREAKS theorems (that is the point).
const F64els = ComplexF64[exp(k*im*pi/2) for k in 0:3]   # carries 6.1e-17 dirt
FLOAT_EXACT  = (name = "ComplexF64 with exact ==   (floating unit circle — DISAGREES)",
    els = F64els, one = ComplexF64(1),
    mul = *, inv = conj, sig = conj, eq = ==)
FLOAT_APPROX = (name = "ComplexF64 with isapprox   (same carrier, tolerant equality — agrees)",
    els = F64els, one = ComplexF64(1),
    mul = *, inv = conj, sig = conj,
    eq  = (x,y) -> isapprox(x, y; atol = 1e-9))

# ======================================================================
# THE MACHINERY — written once, generic over the carrier `r`.
# Transcribed 1:1 from C6_Twist.lean.

i3(a,b,c)  = 4*Int(a) + 2*Int(b) + Int(c) + 1     # Sym: 8 cells
i2(a,b)    = 2*Int(a) + Int(b) + 1                # Gge: 4 cells
const BOOLS = (false, true)

act(r, tw, a, x) = (tw && a) ? r.sig(x) : x

# Lean: d3 tw F a b c d =
#   mul (mul (mul (mul (act tw a (F b c d)) (inv (F (a^b) c d))) (F a (b^c) d))
#       (inv (F a b (c^d)))) (F a b c)
d3(r, tw, F, a,b,c,d) =
    r.mul(r.mul(r.mul(r.mul(act(r,tw,a,F[i3(b,c,d)]),
        r.inv(F[i3(xor(a,b),c,d)])), F[i3(a,xor(b,c),d)]),
        r.inv(F[i3(a,b,xor(c,d))])), F[i3(a,b,c)])

d2(r, tw, g, a,b,c) =
    r.mul(r.mul(act(r,tw,a,g[i2(b,c)]), r.inv(g[i2(xor(a,b),c)])),
          r.mul(g[i2(a,xor(b,c))], r.inv(g[i2(a,b)])))

iscocycle(r, tw, F) = all(r.eq(d3(r,tw,F,a,b,c,d), r.one)
    for a in BOOLS, b in BOOLS, c in BOOLS, d in BOOLS)

# Lean: pentagon F = ∀ a b c d, (F a b c)(F a (b^c) d)(F b c d) = (F (a^b) c d)(F a b (c^d))
pentagon(r, F) = all(r.eq(
        r.mul(r.mul(F[i3(a,b,c)], F[i3(a,xor(b,c),d)]), F[i3(b,c,d)]),
        r.mul(F[i3(xor(a,b),c,d)], F[i3(a,b,xor(c,d))]))
    for a in BOOLS, b in BOOLS, c in BOOLS, d in BOOLS)

# Lean's gauge enumeration gge n, weights 1/4/16/64, digits via decU
gauge(r, n) = [ r.els[mod(div(n, w), 4) + 1] for w in (1, 4, 16, 64) ]  # cells (F,F),(F,T),(T,F),(T,T)

function d2image(r, tw, g)
    out = Vector{typeof(r.one)}(undef, 8)
    for a in BOOLS, b in BOOLS, c in BOOLS
        out[i3(a,b,c)] = d2(r,tw,g,a,b,c)
    end
    out
end

symeq(r, F, G) = all(r.eq(F[i], G[i]) for i in 1:8)

iscoboundary(r, tw, F) = any(symeq(r, d2image(r,tw,gauge(r,n)), F) for n in 0:255)

function countB(r, tw)                     # Lean: countB — distinct coboundary images
    imgs = [d2image(r,tw,gauge(r,n)) for n in 0:255]
    reps = Vector{eltype(imgs)}()
    for im_ in imgs
        any(symeq(r, im_, s) for s in reps) || push!(reps, im_)
    end
    length(reps)
end

countKer(r, tw) = count(n -> symeq(r, d2image(r,tw,gauge(r,n)), fill(r.one, 8)), 0:255)

cobAreCocycles(r, tw) = all(iscocycle(r, tw, d2image(r,tw,gauge(r,n))) for n in 0:255)

# the named symbols
topcell(r, u) = [ (i == i3(true,true,true)) ? u : r.one for i in 1:8 ]
boson(r)        = topcell(r, r.els[1])
sliceI(r)       = topcell(r, r.els[2])
fermion(r)      = topcell(r, r.els[3])
topumi(r)       = topcell(r, r.els[4])
function twistedBoson(r)
    F = fill(r.one, 8)
    for a in BOOLS, b in BOOLS, c in BOOLS
        F[i3(a,b,c)] = c ? (b ? r.els[2] : r.els[4]) : r.els[1]
    end
    F
end
function fakeCocycle(r)
    F = fill(r.one, 8)
    for a in BOOLS, b in BOOLS, c in BOOLS
        F[i3(a,b,c)] = (!a && !b && c) ? r.els[2] : r.els[1]
    end
    F
end
gFermion(r) = [ (a && b) ? r.els[2] : r.els[1] for a in BOOLS for b in BOOLS ] |>
    v -> [ (a && b) ? r.els[2] : r.els[1] for a in BOOLS, b in BOOLS ] |> vec
function gFermionG(r)
    g = fill(r.one, 4)
    for a in BOOLS, b in BOOLS
        g[i2(a,b)] = (a && b) ? r.els[2] : r.els[1]
    end
    g
end

isrealel(r, x) = r.eq(x, r.els[1]) || r.eq(x, r.els[3])

# all 2^8 = 256 symbols valued in {1,-1}: Lean proved twist_vanishes_on_reals
# by a term for EVERY such F; Julia enumerates every instance in this carrier.
function twist_vanishes_on_reals(r)
    for code in 0:255
        F = [ ((code >> (i-1)) & 1) == 1 ? r.els[3] : r.els[1] for i in 1:8 ]
        for a in BOOLS, b in BOOLS, c in BOOLS, d in BOOLS
            r.eq(d3(r,true,F,a,b,c,d), d3(r,false,F,a,b,c,d)) || return false
        end
    end
    true
end

# ======================================================================
# THE BATTERY — the C6_Twist theorem list, evaluated in carrier r.
function battery(r)
    B, S, I, M, N = boson(r), sliceI(r), fermion(r), topumi(r), twistedBoson(r)
    K = fakeCocycle(r); gF = gFermionG(r)
    checks = Pair{String,Bool}[
      "conj_eq_inv"              => all(r.eq(r.sig(x), r.inv(x)) for x in r.els),
      "conj_is_the_inverse"      => all(r.eq(r.mul(x, r.sig(x)), r.one) for x in r.els),
      "sigma_ne_id"              => any(!r.eq(r.sig(x), x) for x in r.els),
      "row_one_untwisted"        => iscocycle(r,false,B) && iscoboundary(r,false,B),
      "row_one_twisted"          => iscocycle(r,true, B) && iscoboundary(r,true, B),
      "row_i_untwisted"          => !iscocycle(r,false,S),
      "row_i_twisted"            => iscocycle(r,true, S) && !iscoboundary(r,true, S),
      "row_neg1_untwisted"       => iscocycle(r,false,I) && !iscoboundary(r,false,I),
      "row_neg1_twisted"         => iscocycle(r,true, I) && iscoboundary(r,true, I),
      "row_negi_untwisted"       => !iscocycle(r,false,M),
      "row_negi_twisted"         => iscocycle(r,true, M) && !iscoboundary(r,true, M),
      "fermion_is_sigma_coboundary" => symeq(r, d2image(r,true,gF), I),
      "fermion_not_untwisted_cob"   => !iscoboundary(r,false,I),
      "twistedBoson_pentagon"        => pentagon(r, N),
      "twistedBoson_not_sigma_cocycle" => !iscocycle(r,true,N),
      "twistedBoson_untwisted_cocycle" => iscocycle(r,false,N),
      "twistedBoson_gauge_trivial"     => iscoboundary(r,false,N),
      "sliceI_fails_pentagon"     => !pentagon(r,S),
      "sliceI_is_sigma_cocycle"   => iscocycle(r,true,S),
      "sliceI_not_sigma_coboundary" => !iscoboundary(r,true,S),
      "fakeCocycle_fails_both"    => !pentagon(r,K) && !iscocycle(r,true,K),
      "conj_fixes_reals"          => all(!isrealel(r,x) || r.eq(r.sig(x),x) for x in r.els),
      "twist_vanishes_on_reals(256 F)" => twist_vanishes_on_reals(r),
      "B3_untwisted == 16"        => countB(r,false) == 16,
      "B3_twisted == 32"          => countB(r,true)  == 32,
      "ker_untwisted == 16"       => countKer(r,false) == 16,
      "ker_twisted == 8"          => countKer(r,true)  == 8,
      "cob_subset_cocycles_untw"  => cobAreCocycles(r,false),
      "cob_subset_cocycles_tw"    => cobAreCocycles(r,true),
    ]
    checks
end

const ORACLE = true   # every battery line is a kernel-verified Lean theorem => expected true

# ======================================================================
# ISOMORPHISM REPORT — where Lean needed theorems toGZ_mul/toGZ_conj/toGZ_inj/
# is_unit to bridge TWO representations, Julia checks all bridges by running.
function iso_report(r)
    phi = r.els                                   # canonical k ↦ els[k+1]
    hom  = all(r.eq(phi[mod(x+y,4)+1], r.mul(phi[x+1], phi[y+1])) for x in 0:3, y in 0:3)
    sigk = [0,3,2,1]                              # canonical conj in log form
    sg   = all(r.eq(phi[sigk[x+1]+1], r.sig(phi[x+1])) for x in 0:3)
    iv   = all(r.eq(phi[mod(-x,4)+1], r.inv(phi[x+1])) for x in 0:3)
    un   = r.eq(phi[1], r.one)
    inj  = all(!r.eq(phi[i], phi[j]) for i in 1:4 for j in 1:4 if i != j)
    (hom=hom, sig=sg, inv=iv, one=un, inj=inj, ok = hom && sg && iv && un && inj)
end

# ======================================================================
# HEXAGON (braiding) — Lean did this over its hand-built GZ. Julia can run the
# SAME verbatim definitions over any complex-like ring: Complex{Int},
# Complex{Rational{BigInt}}, Complex{BigInt}... free generality from parametric types.
function hexagon_battery(one_, mk)     # mk(re,im) builds a ring element
    z(re,im_) = mk(re,im_)
    zero_, i_, mi_, m1_ = z(0,0), z(0,1), z(0,-1), z(-1,0)
    Fs(f,a,b,c,d,x,y) = (x == mod(a+b,2) && y == mod(b+c,2) && d == mod(a+b+c,2)) ?
        ((a==1 && b==1 && c==1) ? f : one_) : zero_
    Rs(R,x,y) = (x==1 && y==1) ? R : one_
    hexL(f,R,a,b,c,d) = (e = mod(a+b,2); zz = mod(a+c,2);
        Rs(R,e,c) * Fs(f,c,a,b,d,zz,e))
    hexR(f,R,a,b,c,d) = (e = mod(a+b,2); zz = mod(a+c,2); g = mod(b+c,2);
        ((Fs(f,a,b,c,d,e,g) * Rs(R,b,c)) * Fs(f,a,c,b,d,zz,g)) * Rs(R,a,c))
    hexB(f,R) = all(
        (d != mod(mod(a+b,2)+c,2) || d != mod(mod(a+c,2)+b,2)) ||
        hexL(f,R,a,b,c,d) == hexR(f,R,a,b,c,d)
        for a in 0:1, b in 0:1, c in 0:1, d in 0:1)
    selfinv(R) = R*R == one_
    Pair{String,Bool}[
      "boson_braids_real"        => hexB(one_, one_) && hexB(one_, m1_) &&
                                    !hexB(one_, i_) && !hexB(one_, mi_),
      "fermion_braids_imaginary" => hexB(m1_, i_) && hexB(m1_, mi_) &&
                                    !hexB(m1_, one_) && !hexB(m1_, m1_),
      "sigma_fixes_boson_braidings"  => conj(one_) == one_ && conj(m1_) == m1_,
      "sigma_swaps_fermion_braidings"=> conj(i_) == mi_ && conj(mi_) == i_ &&
                                        conj(i_) != i_ && conj(mi_) != mi_,
      "edict_boson"              => selfinv(one_) && selfinv(m1_),
      "edict_fermion_fails"      => !selfinv(i_) && !selfinv(mi_),
    ]
end

hex_carriers() = [
    ("Complex{Int}",              Complex{Int}(1),           (a,b)->Complex{Int}(a,b)),
    ("Complex{BigInt}",           Complex{BigInt}(1),        (a,b)->Complex{BigInt}(a,b)),
    ("Complex{Rational{BigInt}}", Complex{Rational{BigInt}}(1), (a,b)->Complex{Rational{BigInt}}(a,b)),
]

# ======================================================================
# gd3 — Lean's fully generic form (C6_Gap section 1), as a higher-order function.
# Lean quantifies over ALL types M by a proof term. Julia quantifies by
# duck-typing: ANY carrier with mul/inv/σ can be passed in — but each call is
# one instance of evidence, never a proof over all types.
gd3(mul, inv, sig, tw, F, a,b,c,d) =
    mul(mul(mul(mul((tw && a) ? sig(F(b,c,d)) : F(b,c,d),
        inv(F(xor(a,b),c,d))), F(a,xor(b,c),d)),
        inv(F(a,b,xor(c,d)))), F(a,b,c))

end # module
