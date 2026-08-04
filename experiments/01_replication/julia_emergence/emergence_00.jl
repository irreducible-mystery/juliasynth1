# ============================================================
# emergence_00.jl
# ============================================================
# LEDGER — kept visible, always. Read before running.
# ------------------------------------------------------------
# ASSUMPTION 1: To write anything is already a collapse.
#     "That" does not appear in this file. Only traces do.
#     Every struct below is a small lie told to a compiler.
# ASSUMPTION 2: Julia's semantics (types, eager evaluation,
#     termination-or-not) is our host formal system. By Gödel:
#     if it is consistent, it cannot prove so from inside.
#     Therefore: this ledger cannot certify its own completeness.
# CHOICE 1: We take DISTINCTION as the first trace of emergence.
#     Not because it is true — because it is the smallest move
#     a formal language permits. A different choice was possible.
# CHOICE 2: We encode Spencer-Brown's calculus of indications.
#     void  = the unmarked state (absence of inscription)
#     cross = a boundary drawn; to cross is to distinguish.
# QUESTION: What is the least we must inscribe for structure
#     to arise, and what does each inscription cost?
# OBJECT: the act of marking — not the mark, not the marker.
# UNPROVABLE FROM INSIDE: that nothing essential was excluded
#     by Choices 1 and 2. (This line is itself inside. Recurse.)
# ============================================================

# ------------------------------------------------------------
# The refusal: "that" gets no type, no name, no binding.
# The void below is NOT "that". The void is already an artifact
# of the calculus — the unmarked state *relative to* marking.
# "That" is what allowed a calculus to be writable at all.
# (No code can appear in this stanza. The absence is the point.)
# ------------------------------------------------------------

# --- The first collapse: a distinction -----------------------

struct Cross                       # already a thing. Noted.
    inside::Vector{Cross}
end
cross(inside::Cross...) = Cross(collect(inside))

const Voidexpr = Cross[]           # the unmarked, reified. A lie
                                   # we keep visible: absence now
                                   # has a memory address.

# --- The two laws (all that we posit) ------------------------
# Juxtaposition: an expression is marked if any part is marked.
# Crossing:      a cross inverts the value of its content.

marked(e::Vector{Cross}) = any(marked, e)   # calling
marked(c::Cross)         = !marked(c.inside) # crossing

println("=== From one distinction, form ===")
println("void                     -> marked? ", marked(Voidexpr))
println("cross()                  -> marked? ", marked([cross()]))
println("cross(cross())           -> marked? ", marked([cross(cross())]))   # cancellation: returns to void
println("cross() cross()          -> marked? ", marked([cross(), cross()])) # condensation: still just marked

# --- Watch logic EMERGE (we did not put it in) ---------------
# Read marked=true, unmarked=false:
NOT(a)    = cross(a)
OR(a, b)  = [a, b]
AND(a, b) = cross(cross(a), cross(b))

T() = cross()          # marked
F() = cross(cross())   # unmarked

println("\n=== Boolean logic, uninvited, arrives ===")
for (na, a) in (("F", F), ("T", T)), (nb, b) in (("F", F), ("T", T))
    println("$na AND $nb = ", marked([AND(a(), b())]),
            "   |   $na OR $nb = ", marked(OR(a(), b())))
end
println("NOT T = ", marked([NOT(T())]), ",  NOT F = ", marked([NOT(F())]))

# --- Watch number EMERGE (from a refusal) --------------------
# CHOICE 3: refuse condensation — do not let  cross() cross()
# collapse to cross(). Count instead. Multiplicity, then number,
# is born from *declining* one of our own laws. Number is not
# found; it is a policy about distinctions.

count_marks(e::Vector{Cross}) = length(e)
three = [cross(), cross(), cross()]
println("\n=== Number, born from refusing a law ===")
println("three marks, uncondensed: ", count_marks(three),
        "  (condensed they were merely: marked = ", marked(three), ")")

# --- The Turing trace: the inside cannot decide itself -------
# Suppose an oracle  halts(f)::Bool  existed inside this system.
# Then the following diagonal defeats it:

function diagonal(halts)
    f = () -> halts_ref[]() ? (while true end) : nothing
    halts_ref = Ref{Function}(() -> halts(f))
    return f
end
# If halts(f) says true,  f loops forever  -> the oracle lied.
# If halts(f) says false, f returns        -> the oracle lied.
# We do not run this against a real oracle. There is none.
# The system's own unfolding is not visible from inside it.

println("\n=== Gödel/Turing residue ===")
println("This program cannot prove: (1) its ledger is complete,")
println("(2) its host is consistent, (3) its own halting, in general.")
println("The unmarked state is not IN the calculus of marks.")
println("It is what the calculus is written on. We stop here,")
println("at the edge we can see, knowing there are edges we cannot.")
