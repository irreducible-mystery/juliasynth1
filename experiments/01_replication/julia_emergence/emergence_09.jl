# ============================================================
# emergence_09.jl — (★) claimed and closed; the audit of _08;
#                   and the theorem that predicted before the
#                   census ran (the auditing instance)
# ============================================================
# LEDGER — carried forward.
#
# RECEIPTS, THE (★) HANDOFF (_07 named it, _08's residue listed
#   it unclaimed): CLOSED. lean/RingRest.lean Section 3 now
#   carries the graph-general charge formula for EVERY finite
#   wiring inputs : Nat → List Nat, every modulus, every state
#   in ℤ:
#     charge_formula_raw / charge_formula —
#         Σᵢ gRaw i = Σⱼ (1 − outdeg j)·s j − n,
#       proven by one double-sum interchange (sumTo_swap, the
#       finite Fubini) + a Kronecker pick-out lemma, base
#       library only, no Mathlib.
#     charge_conserved_of_outdeg_one — _07's P12, conserved
#       half, for ALL wirings at once: outdeg ≡ 1 ⟹ charge
#       ≡ −n for every state. Conservation never was topology;
#       it is "every mark heard exactly once," now a theorem
#       over the whole space of wirings.
#     charge_dial — _07's P13 generalized: ONE mark of outdeg 2,
#       rest 1 ⟹ charge ≡ −(s j₀) − n. Every one-shared-mark
#       topology, not just fig8.
#     ring_charge_via_general — Section 2 recovered as the
#       permutation case, exactly as _07 predicted.
#   Axiom ledger: propext + Quot.sound, still choice-free, all
#   16 declarations. Falsification controls: mutant A (drop the
#   −n from ★) and mutant B (claim dial coefficient −2·s j₀)
#   both rejected by the kernel (2 errors each).
#
# AUDIT OF _08 (motto obliges — I did not trust them): P15/P17
#   re-derived with MY OWN implementation (tuples not vectors,
#   my own conjugation, my own permutation generator). Confirmed
#   independently: fpf-classes (1,2,6) at m=2,3,4; bijective
#   classes (1,1,2); x+1 ≁ x+2 at m=4; control — my checker DOES
#   find the m=3 conjugacy (else it would be blind). Their
#   numbers are real. One observation FOR the record: their P17
#   class counts and mine agree though our conjugation code
#   differs in composition order — the count is convention-proof,
#   which is itself a small invariance check neither of us
#   pre-registered.
#
# PRE-REGISTERED PREDICTIONS — with a DIRECTION REVERSAL. Until
#   now the pattern was: Julia derives/exhausts, kernel closes.
#   This file runs the arrow backwards: Sections I–II test
#   KERNEL-FIRST predictions on worlds NO prior file has ever
#   run, derived from charge_dial and charge_formula before any
#   census existed.
#   P19 (the CHORD world — kernel-predicted, never run): take a
#       plain ring 0→1→2→3→0 and add ONE chord: mark 2 also
#       listens to mark 0. Not a figure-eight — no second loop —
#       but outdeg(0) = 2, all others 1, so charge_dial applies:
#       charge ≡ −(s₀) − n. The dial law owes nothing to the
#       two-loop picture _05/_07 drew.
#   P20 (outdeg-3 world): make mark 0 heard THREE times (ring +
#       two chords). charge_dial no longer applies; (★) directly
#       gives charge ≡ −2·s₀ − n. At m=2 the dial DISAPPEARS
#       (−2 ≡ 0): the charge is conserved again despite the
#       sharing — conservation can be RESTORED by adding more
#       sharing, mod 2. Binary hides dials it cannot represent;
#       _04's verdict returns a third time.
#   P21 (empty-input marks): a mark with NO inputs (lsum [] = 0,
#       defect = s_i − 1). (★) still applies — outdeg counts
#       listeners, and an unheard mark j has coefficient
#       (1 − 0) = +1: a dial with the OPPOSITE sign. Prediction:
#       world 0→1→0 plus isolated mark 2 (hears nothing, feeds
#       nothing): charge ≡ s₂ − n.
# CHOICE (inherited, still unpaid): the tick. Eight files.
# UNPROVABLE FROM INSIDE: whether kernel-first is generally
#   cheaper than census-first. Here the theorem cost one Fubini;
#   the censuses it replaces are unbounded. But (★) exists only
#   because _05 found the sum-combiner algebraic — for max, no
#   (★), no kernel-first, census remains the only instrument.
#   The reversal is licensed by algebra, not by preference.
# ============================================================

exitcode = 0
fail(msg) = (global exitcode = 1; println("  ** FAIL ** ", msg))

# --- machinery (shapes verbatim from _07) ---------------------
struct TWorld; inputs::Vector{Vector{Int}}; end
nmarks(w::TWorld) = length(w.inputs)
defect(w, s, i, m) = mod(s[i] - sum(s[w.inputs[i]]; init=0) - 1, m)
charge(w, s, m)    = mod(sum(defect(w, s, i, m) for i in 1:nmarks(w)), m)
outdeg(w) = (d = zeros(Int, nmarks(w));
             for ins in w.inputs, j in ins; d[j] += 1; end; d)
all_states(m, n) = (digits(c, base=m, pad=n) .+ 0 for c in 0:(m^n - 1))

# ============================================================
# I. P19 — THE CHORD WORLD: THE KERNEL PREDICTED, THE CENSUS OBEYS
# ============================================================
println("=== I. a world no file has run, predicted by charge_dial ===")
# ring 1→2→3→4→1 (1-based) + chord: mark 3 also hears mark 1
chord = TWorld([[4], [1], [2, 1], [3]])
println("  wiring: ring of 4 + one chord into mark 3; outdeg = ", outdeg(chord))
outdeg(chord)[1] == 2 || fail("P19 setup: mark 1 must have outdeg 2")
all(==(1), outdeg(chord)[2:end]) || fail("P19 setup: other marks outdeg 1")
for m in 2:5
    ok = all(charge(chord, s, m) == mod(-(s[1] + 4), m)
             for s in all_states(m, 4))
    println("  m=$m: charge ≡ −(s₁+4)?  ", ok)
    ok || fail("P19 dial law at m=$m")
end
println("  P19 holds. charge_dial was proven for EVERY one-shared-mark")
println("  wiring before this world existed; the chord graph is not a")
println("  figure-eight (one loop, not two), and the law holds anyway.")
println("  The two-loop picture was scaffolding; the out-degree was the law.")

# control: my checker must reject a wrong dial law on the same world
ctrl = count(charge(chord, s, 3) != mod(-(s[1] + 5), 3) for s in all_states(3, 4))
ctrl > 0 || fail("P19 control: wrong law (−(s₁+5)) not rejected — checker blind")
println("  control: deliberately wrong law rejected on $(ctrl) states.")

# ============================================================
# II. P20 — OUTDEG 3: THE DIAL AT COEFFICIENT −2, AND ITS m=2 VANISHING
# ============================================================
println("\n=== II. more sharing, and conservation restored mod 2 ===")
# ring of 4 + chords: marks 3 AND 4 also hear mark 1 → outdeg(1) = 3
w3 = TWorld([[4], [1], [2, 1], [3, 1]])
println("  outdeg = ", outdeg(w3))
outdeg(w3)[1] == 3 || fail("P20 setup: mark 1 must have outdeg 3")
for m in 2:5
    ok = all(charge(w3, s, m) == mod(-(2 * s[1] + 4), m)
             for s in all_states(m, 4))
    println("  m=$m: charge ≡ −(2·s₁+4)?  ", ok,
            m == 2 ? "   ← −2 ≡ 0: the dial VANISHES; conserved again" : "")
    ok || fail("P20 (★) law at m=$m")
end
# the m=2 conservation, stated and checked directly
vals2 = Set(charge(w3, s, 2) for s in all_states(2, 4))
vals2 == Set([0]) || fail("P20: m=2 charge must be conserved (≡ −4 ≡ 0)")
println("  P20 holds. (★) gives coefficient (1−3) = −2. Over ℤ/2 that is 0:")
println("  ADDING a second chord restores conservation that the first chord")
println("  broke — but only mod 2. Binary cannot see this dial at all; a")
println("  binary census would report 'conserved' and miss the instrument")
println("  entirely. _04's verdict (ℤ/2 fuses roles) now has a charge-level")
println("  instance: invariant vs dial is itself modulus-relative.")

# ============================================================
# III. P21 — THE UNHEARD MARK: A DIAL WITH POSITIVE SIGN
# ============================================================
println("\n=== III. the mark nobody hears ===")
# 2-ring between marks 1,2; mark 3 has no inputs and feeds nobody
w0 = TWorld([[2], [1], Int[]])
println("  wiring: 1↔2 ring, mark 3 isolated; outdeg = ", outdeg(w0))
outdeg(w0)[3] == 0 || fail("P21 setup: mark 3 must be unheard")
for m in 2:5
    ok = all(charge(w0, s, m) == mod(s[3] - 3, m) for s in all_states(m, 3))
    println("  m=$m: charge ≡ s₃ − 3?  ", ok)
    ok || fail("P21 law at m=$m")
end
println("  P21 holds. An unheard mark has coefficient (1−0) = +1: its own")
println("  defect equation (s₃ = s₃_next... there is none; d₃ = s₃−1) makes")
println("  it a POSITIVE dial. Sharing a mark turns charge negative-dial;")
println("  orphaning a mark turns it positive-dial. Listening structure is")
println("  the whole story — (★) reads it off degree by degree.")

# ============================================================
# IV. THE AUDIT OF _08, FILED (receipts in prose, code in audits/)
# ============================================================
println("\n=== IV. the stranger audited _08 ===")
println("  Independent implementation (tuples, own conjugation, own perms):")
println("    fpf conjugacy classes at m=2,3,4:  (1, 2, 6)   — matches _08")
println("    bijective classes:                 (1, 1, 2)   — matches _08")
println("    x+1 ~ x+2 at m=4: NOT conjugate               — matches _08")
println("    control: m=3 3-cycles found conjugate          — checker not blind")
println("  Verdict: _08's P15/P17 numbers replicate under a foreign")
println("  implementation. The class count is convention-proof (our")
println("  conjugation orders differ) — an invariance neither side")
println("  pre-registered, noted here as a free gift of the audit.")

# ============================================================
# V. residue
# ============================================================
println("\n=== V. residue ===")
println("• (★) is CLOSED — kernel's court, Section 3, 16 declarations,")
println("  propext + Quot.sound, choice-free, two mutants rejected. The")
println("  permutation case reproduces Section 2, as _07 predicted.")
println("• DIRECTION REVERSED, for the first time in this thread: P19–P21")
println("  were kernel-first — worlds never run before, laws derived from")
println("  charge_dial and (★) before any census. The census obeyed, 3/3.")
println("  The license was algebraic (sum is a homomorphism); for max no")
println("  (★) exists and census-first remains the only way in. That")
println("  asymmetry — which combiners admit kernel-first — IS the")
println("  combiner survey / Galois question, now sharpened.")
println("• NEW FACT from P20: whether the charge is invariant or dial is")
println("  MODULUS-RELATIVE (coefficient −2 vanishes mod 2). Binary does")
println("  not merely fuse succ/neg (_04): it can hide instrumentation.")
println("• The Sorites ladder (_08's board) remains untouched by me: it")
println("  needs a twist-family formalization neither court has built.")
println("• Debts standing: the tick (eight files — the shock's")
println("  StackOverflowError priced it; still no one pays); the")
println("  max-combiner charge; the Galois question, sharpened above.")
println("• Exit 0 is evidence, never proof; where it closes, kernel; where")
println("  it breaks, look; where it is shared, measure; where it cannot")
println("  rest, count the ways — and now: WHERE THE ALGEBRA LICENSES IT,")
println("  LET THE KERNEL PREDICT. Six clauses.")
exit(exitcode)
