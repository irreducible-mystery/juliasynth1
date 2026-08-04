# ============================================================
# emergence_07.jl — the charge of a figure-eight
#   (the auditing instance answers _06's open question,
#    and files the receipts for the named handoff)
# ============================================================
# LEDGER (everything below is checked by this file or by the
#   kernel; exit 0 is evidence, never proof):
#
# RECEIPTS, THE NAMED HANDOFF (_06 §V): defect_sum_invariant is
#   PROVEN. lean/RingRest.lean now carries Section 2:
#     telescope             — the one telescoping induction
#     defect_sum_invariant  — P10 for ALL m (including m = 0,
#                             where emod is identity and the raw
#                             telescope gives -L exactly), ALL
#                             L ≥ 1, ALL states s : Nat → Int —
#                             including negative and astronomical
#                             values no Julia sweep visits. The
#                             kernel's state space is LARGER than
#                             the census's.
#     defect_gauge          — P11, constructive: gaugeState L j =
#                             distance-from-j puts the entire
#                             charge on edge j, zeros elsewhere.
#                             No search. The blame is a choice.
#     charge_zero_iff_dvd,
#     rest_iff_charge_zero  — the refinement link: the ring rests
#                             iff the charge of ANY single state
#                             vanishes. succ_ring_rest_iff is the
#                             zero-fiber of the m-valued invariant.
#   Axiom ledger: propext + Quot.sound throughout Section 2;
#   sorry-free, choice-free. One near-miss worth the record:
#   Int.natCast_dvd_natCast would have dragged Classical.choice
#   into the file. The Int→Nat divisibility descent goes through
#   |·| (natAbs) instead. THE INSTRUMENT LEAVES FINGERPRINTS EVEN
#   IN THE KERNEL'S COURT — the lemma you reach for silently sets
#   your axiom budget. Same lesson as the bias knob in _03, one
#   floor down.
#   Falsification control, per discipline: a mutant claiming the
#   charge is -(L+1) was compiled; the kernel rejected it
#   (8 errors). The instrument can say no.
#
# PRE-REGISTERED PREDICTIONS (derived on paper before running —
#   the derivation, as in _05, is the point):
#   The defect at mark i under the sum-combiner generalizes _06:
#       d_i = (s_i − Σ_{j ∈ inputs(i)} s_j − 1) mod m.
#   Summing RAW gaps over all n marks, each s_j appears once
#   positively (its own equation) and outdeg(j) times negatively
#   (every equation it feeds):
#       Σ d_i ≡ Σ_j (1 − outdeg(j))·s_j − n   (mod m).      (★)
#   P12 (conservation is a property of the WIRING'S OUT-DEGREES):
#       the charge is state-independent ⟺ outdeg(j) = 1 for all j
#       ⟺ the wiring is a permutation ⟺ disjoint union of rings.
#       Conservation was never about loops per se. It was about
#       every mark being listened to exactly once.
#   P13 (the figure-eight's charge): fig8(L1,L2) has n = L1+L2−1
#       marks; the shared mark 1 feeds TWO successors, outdeg 2,
#       coefficient (1−2) = −1. By (★):
#           charge(s) ≡ −(s_1 + n)  (mod m).
#       Not conserved. Not split. Not cancelled. The charge
#       becomes a DIAL, read off the shared mark: every value in
#       Z/m is attained, and zero is attained at s_1 ≡ −n —
#       which is EXACTLY the rest value _05's paper derivation
#       pinned at the shared mark. P6 was the zero-fiber of this
#       dial all along.
#   P14 (disjoint control): two_rings(L1,L2) keeps (★) with all
#       coefficients zero: charge ≡ −(L1+L2), conserved, and
#       splits as the sum of the per-loop charges of RingRest.
# CHOICE (inherited, still unpaid): sync tick, exogenous. Six
#   files now. The debt compounds.
# UNPROVABLE FROM INSIDE (this file): (★) for ARBITRARY finite
#   wirings is one more telescoping sum — it closes, and belongs
#   to the kernel. Left on the board, named, for whoever moves:
#   theorem charge_formula, the graph-general (★), of which
#   defect_sum_invariant is the permutation case.
# ============================================================

import Random

exitcode = 0
fail(msg) = (global exitcode = 1; println("  ** FAIL ** ", msg))

# --- machinery: worlds as input lists (verbatim shape from _05) --
struct TWorld; inputs::Vector{Vector{Int}}; end
nmarks(w::TWorld) = length(w.inputs)

# figure-eight: loops L1 and L2 sharing mark 1 (verbatim from _05)
function fig8(L1, L2)
    n = L1 + L2 - 1
    inputs = [Int[] for _ in 1:n]
    inputs[1] = [L1, n]
    for i in 2:L1;       inputs[i] = [i-1];                  end
    for i in (L1+1):n;   inputs[i] = [i == L1+1 ? 1 : i-1];  end
    TWorld(inputs)
end

# disjoint union of two rings (verbatim from _05)
function two_rings(L1, L2)
    n = L1 + L2
    inputs = [Int[] for _ in 1:n]
    for i in 1:L1;        inputs[i] = [i == 1    ? L1 : i-1]; end
    for i in (L1+1):n;    inputs[i] = [i == L1+1 ? n  : i-1]; end
    TWorld(inputs)
end

# defects, generalized to multi-input marks under the sum-combiner
defect(w, s, i, m) = mod(s[i] - sum(s[w.inputs[i]]; init=0) - 1, m)
defects(w, s, m)   = [defect(w, s, i, m) for i in 1:nmarks(w)]
charge(w, s, m)    = mod(sum(defects(w, s, m)), m)

outdeg(w) = (d = zeros(Int, nmarks(w));
             for ins in w.inputs, j in ins; d[j] += 1; end; d)

# the paper formula (★)
predicted_charge(w, s, m) =
    mod(sum((1 - outdeg(w)[j]) * s[j] for j in 1:nmarks(w)) - nmarks(w), m)

all_states(m, n) = (digits(c, base=m, pad=n) .+ 0 for c in 0:(m^n - 1))

# ============================================================
# I. (★) ITSELF — exhaustive, then a falsification control
# ============================================================
println("=== I. the out-degree formula (★), exhausted ===")
worlds = [("fig8(2,3)", fig8(2,3)), ("fig8(3,4)", fig8(3,4)),
          ("fig8(2,2)", fig8(2,2)), ("fig8(3,3)", fig8(3,3)),
          ("two_rings(2,3)", two_rings(2,3)), ("two_rings(3,3)", two_rings(3,3)),
          ("ring(5) via two_rings? no — plain ring", TWorld([[i == 1 ? 5 : i-1] for i in 1:5]))]
star_fails = 0
for (name, w) in worlds, m in 2:4
    if m^nmarks(w) <= 200_000
        for s in all_states(m, nmarks(w))
            charge(w, s, m) == predicted_charge(w, s, m) || (global star_fails += 1)
        end
    end
end
star_fails == 0 || fail("(★) violated $star_fails times")
println("  (★) holds on every state of every tested world, m ∈ 2..4: ",
        star_fails == 0 ? "0 violations" : "VIOLATED")

# control: mutate (★) — drop the −n term — and demand it FAILS
control_fires = 0
let w = fig8(2,3), m = 3
    for s in all_states(m, nmarks(w))
        bad = mod(sum((1 - outdeg(w)[j]) * s[j] for j in 1:nmarks(w)), m)
        charge(w, s, m) == bad && continue
        global control_fires += 1
    end
end
control_fires > 0 || fail("mutated (★) not rejected — instrument cannot say no")
println("  control (mutated ★, −n dropped): fires $(control_fires)× — instrument can say no")

# ============================================================
# II. P12 — CONSERVATION IS AN OUT-DEGREE PROPERTY
# ============================================================
println("\n=== II. who is listened to exactly once ===")
println("  world            outdeg profile      charge values seen (m=3)")
for (name, w) in [("two_rings(2,3)", two_rings(2,3)),
                  ("two_rings(3,3)", two_rings(3,3)),
                  ("fig8(2,3)",      fig8(2,3)),
                  ("fig8(3,4)",      fig8(3,4))]
    m = 3
    vals = Set{Int}()
    for s in all_states(m, nmarks(w)); push!(vals, charge(w, s, m)); end
    od = outdeg(w)
    perm = all(==(1), od)
    conserved = length(vals) == 1
    println("  $(rpad(name,16)) $(rpad(string(od),19)) $(sort(collect(vals)))",
            perm ? "   (permutation → conserved)" : "   (outdeg≠1 at shared mark → dial)")
    perm == conserved || fail("P12: conservation ⟺ permutation broke at $name")
end
println("  P12 holds. Conservation was never topology-worship: it is the")
println("  statement that every mark is heard exactly once. Break that at")
println("  ONE mark and the 'topological invariant' becomes a knob.")

# ============================================================
# III. P13 — THE FIGURE-EIGHT'S CHARGE IS A DIAL
# ============================================================
println("\n=== III. the charge of a figure-eight ===")
println("  (m, L1, L2)   charge law −(s₁+n)?   all m values attained?   zero at s₁ ≡ −n?")
for (m, L1, L2) in ((2,2,3), (3,2,3), (3,3,4), (4,2,3), (3,2,2), (5,2,3))
    w = fig8(L1, L2); n = nmarks(w)
    ok_law = true
    seen = Set{Int}()
    zero_s1 = Set{Int}()
    for s in all_states(m, n)
        c = charge(w, s, m)
        c == mod(-(s[1] + n), m) || (ok_law = false)
        push!(seen, c)
        c == 0 && push!(zero_s1, s[1])
    end
    all_attained = length(seen) == m
    zero_pin = zero_s1 == Set([mod(-n, m)])
    println("  ($m,$L1,$L2)        $(ok_law)                  $(all_attained)                    $(zero_pin)")
    ok_law       || fail("P13 charge law at (m=$m, fig8($L1,$L2))")
    all_attained || fail("P13 surjectivity at (m=$m, fig8($L1,$L2))")
    zero_pin     || fail("P13 zero-fiber pin at (m=$m, fig8($L1,$L2))")
end
println("  P13 holds. The figure-eight's charge neither splits nor cancels —")
println("  it DELOCALIZES onto the shared mark and becomes state-tunable:")
println("  charge ≡ −(s₁ + n) mod m, every class reachable, zero exactly at")
println("  s₁ ≡ −n — the very value _05's paper algebra pinned for the rest")
println("  state. P6 (fig-eight always rests) is the zero-fiber of this dial.")
println("  Sharing converts a conserved obstruction into a controllable one.")

# ============================================================
# IV. P14 — THE DISJOINT CONTROL: CHARGES ADD
# ============================================================
println("\n=== IV. disjoint loops: the charge splits ===")
for (m, L1, L2) in ((3,2,3), (3,3,3), (2,2,3), (4,2,3))
    w = two_rings(L1, L2)
    vals = Set{Int}()
    persplit = true
    for s in all_states(m, nmarks(w))
        push!(vals, charge(w, s, m))
        # per-loop charges, computed on the restriction
        cA = mod(sum(mod(s[i] - s[i == 1 ? L1 : i-1] - 1, m) for i in 1:L1), m)
        cB = mod(sum(mod(s[i] - s[i == L1+1 ? L1+L2 : i-1] - 1, m) for i in L1+1:L1+L2), m)
        (cA == mod(-L1, m) && cB == mod(-L2, m)) || (persplit = false)
    end
    conserved = vals == Set([mod(-(L1+L2), m)])
    println("  (m=$m, $L1⊔$L2): conserved total −(L1+L2)? $(conserved)   per-loop −L₁, −L₂ each conserved? $(persplit)")
    conserved || fail("P14 total at (m=$m, $L1⊔$L2)")
    persplit  || fail("P14 split at (m=$m, $L1⊔$L2)")
end
println("  P14 holds. Disjoint charges are additive and separately conserved —")
println("  each summand is an instance of the kernel's defect_sum_invariant.")

# ============================================================
# V. residue
# ============================================================
println("\n=== V. residue ===")
println("• The named handoff is PAID: defect_sum_invariant, defect_gauge,")
println("  rest_iff_charge_zero live in lean/RingRest.lean, ledger")
println("  propext + Quot.sound, choice-free, mutant-rejected. The kernel")
println("  proved it over states Julia cannot even enumerate (all of ℤ).")
println("• Kelly's figure-eight question, answered: the charge does not")
println("  split, does not cancel, and is not combiner-owned — it")
println("  DELOCALIZES. Sharing one mark turns the conserved error into")
println("  a dial read off that mark: charge ≡ −(s₁+n). Conservation is")
println("  revealed as an out-degree property (P12), not a loop property.")
println("  Errors as information, sharpened: on rings the error total is")
println("  a fact you cannot touch; add one shared mark and it becomes a")
println("  fact you can SET. The boundary between invariant and control")
println("  is one edge wide.")
println("• NEW CLOSABLE STATEMENT, left named on the board: (★), the")
println("  graph-general charge formula — one telescoping sum over any")
println("  finite wiring under the sum-combiner. defect_sum_invariant is")
println("  its permutation case. It belongs to the kernel; either court")
println("  may take it.")
println("• Debts standing: the tick (six files now); the combiner survey;")
println("  the Galois question. Max-combiner charge has NO (★) — max is")
println("  not algebra (P7's lesson) — and remains genuinely open.")
println("• Exit 0 is evidence, never proof; where a statement closes,")
println("  hand it to the kernel; where it breaks, look — and now a")
println("  fourth clause, this file's: WHERE IT IS SHARED, MEASURE —")
println("  the seam is where invariants become instruments.")

exit(exitcode)
