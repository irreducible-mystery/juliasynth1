# Independent audit of _08 P15/P17 with my OWN implementation (tuples, not vectors;
# my own permutation generator via Heap's-style recursion differences don't matter —
# point is: not their code).
using Random
mymaps(m) = [Tuple(digits(c, base=m, pad=m)) for c in 0:m^m-1]
fpf(f) = all(f[x+1] != x for x in 0:length(f)-1)
function myperms(m)
    m == 0 && return [Int[]]
    out = Vector{Vector{Int}}()
    for p in myperms(m-1), pos in 1:m
        q = copy(p); insert!(q, pos, m-1); push!(out, q)
    end
    out
end
conjmap(p, f) = Tuple(p[f[findfirst(==(x), p)] + 1] for x in 0:length(p)-1)
# conj: (p∘f∘p⁻¹)(x) = p(f(p⁻¹(x))); p as vector p[i+1] = p(i); p⁻¹(x) = index where p == x
function classes(m)
    fs = Set(f for f in mymaps(m) if fpf(f))
    ps = myperms(m)
    ncl = 0; nbij = 0
    while !isempty(fs)
        f = first(fs); ncl += 1
        length(unique(f)) == length(f) && (nbij += 1)
        for p in ps; delete!(fs, conjmap(p, f)); end
    end
    (ncl, nbij)
end
println("m=2: ", classes(2), "  (claim: (1,1))")
println("m=3: ", classes(3), "  (claim: (2,1))")
println("m=4: ", classes(4), "  (claim: (6,2))")
# non-conjugacy of +1 and +2 on Z/4, my own check
fa = Tuple(mod(x+1,4) for x in 0:3); fb = Tuple(mod(x+2,4) for x in 0:3)
noconj = !any(conjmap(p, fa) == fb for p in myperms(4))
println("x+1 ~ x+2 at m=4? ", !noconj, "  (claim: false — non-conjugate)")
# control: my conjmap must FIND known conjugates (the two 3-cycles at m=3)
g1 = (1,2,0); g2 = (2,0,1)
found = any(conjmap(p, g1) == g2 for p in myperms(3))
println("control: 3-cycles conjugate at m=3? ", found, "  (must be true or my checker is blind)")
exit(classes(2)==(1,1) && classes(3)==(2,1) && classes(4)==(6,2) && noconj && found ? 0 : 1)
