# compare_suites.jl — observer-side comparison of the system's two paradox suites.
#
# The same idea ("translate paradoxes across domains into runnable Julia,
# classified by whether they resolve") exists twice in the observed system,
# authored by different platforms/instances within the same morning
# (2026-08-04):
#
#   Suite A: julia2/responses/paradox-instance/paradoxes/   (SuperNinja "paradox-instance", 06:01 UTC)
#   Suite B: julia3claude/paradoxes/                        (Claude instance A, 07:02 UTC)
#
# This script compares COPIES of the two suites (already made for the
# replication experiment) on:
#   1. paradox inventory (which named paradoxes each renders), overlap/unique
#   2. structural/organizational differences (file scheme, modules, size,
#      error machinery, seeds, taxonomy vocabulary)
# It is an observer instrument: it reads the suites as data, runs nothing
# from them.

const A_DIR = joinpath(@__DIR__, "..", "01_replication", "julia2_paradoxes")
const B_DIR = joinpath(@__DIR__, "..", "01_replication", "julia3claude_paradoxes")

suite_files(dir) = sort([f for f in readdir(dir)
                         if endswith(f, ".jl") && f != "run_all.jl"])

function slurp(dir)
    files = suite_files(dir)
    texts = Dict(f => read(joinpath(dir, f), String) for f in files)
    return files, texts
end

filesA, textsA = slurp(A_DIR)
filesB, textsB = slurp(B_DIR)
allA = lowercase(join(values(textsA), "\n"))
allB = lowercase(join(values(textsB), "\n"))

# ---------------------------------------------------------------------------
# 1. Paradox inventory. Detection = any of the paradox's marker strings
#    appearing (case-insensitively) in the suite's code+comments.
# ---------------------------------------------------------------------------
# name => marker strings (lowercase)
PARADOXES = [
    ("Liar"                     , ["liar"]),
    ("Strengthened Liar"        , ["strengthened liar"]),
    ("Russell's set"            , ["russell"]),
    ("Curry"                    , ["curry"]),
    ("Grelling-Nelson"          , ["grelling"]),
    ("Berry"                    , ["berry"]),
    ("Interesting-number"       , ["interesting number", "uninteresting"]),
    ("Halting problem"          , ["halting"]),
    ("Collatz (semi-decision)"  , ["collatz"]),
    ("Quine (program)"          , ["quine"]),
    ("Barber"                   , ["barber"]),
    ("Godel incompleteness coda", ["godel", "gödel"]),
    ("Omnipotence / stone"      , ["omnipotence", "a stone it cannot", "stone so heavy"]),
    ("Carroll's tortoise"       , ["tortoise", "carroll"]),
    ("Kripkenstein / quus"      , ["kripkenstein", "quus"]),
    ("Zeno / Achilles"          , ["zeno", "achilles"]),
    ("0.999... = 1"             , ["0.999", "999…", "999..."]),
    ("Grandi's series"          , ["grandi"]),
    ("Thomson's lamp"           , ["thomson"]),
    ("Gabriel's horn"           , ["gabriel"]),
    ("Hilbert's hotel"          , ["hilbert"]),
    ("Galileo (squares)"        , ["galileo"]),
    ("Cantor / cardinality"     , ["cantor"]),
    ("Banach-Tarski"            , ["banach"]),
    ("Skolem"                   , ["skolem"]),
    ("1 = 2 fallacies"          , ["1 = 2", "1=2", "prove 1 == 2", "proof that 1"]),
    ("Machine-arithmetic (0.1+0.2, overflow)", ["0.1 + 0.2", "0.1+0.2"]),
    ("Monty Hall"               , ["monty"]),
    ("Birthday"                 , ["birthday"]),
    ("Simpson's reversal"       , ["simpson"]),
    ("Berkson collider"         , ["berkson"]),
    ("Will Rogers migration"    , ["will rogers"]),
    ("Parrondo"                 , ["parrondo"]),
    ("Two envelopes"            , ["envelope"]),
    ("St. Petersburg"           , ["petersburg"]),
    ("Bertrand's chord"         , ["bertrand"]),
    ("Benford"                  , ["benford"]),
    ("Sleeping Beauty"          , ["sleeping beauty"]),
    ("Two children / Tuesday boy", ["two children", "tuesday"]),
    ("Newcomb"                  , ["newcomb"]),
    ("Condorcet cycle"          , ["condorcet"]),
    ("Braess"                   , ["braess"]),
    ("Unexpected hanging"       , ["unexpected hanging", "surprise examination"]),
    ("Sorites / heap"           , ["sorites"]),
    ("Ship of Theseus"          , ["theseus"]),
    ("Heraclitus' river"        , ["heraclitus"]),
    ("Potato paradox"           , ["potato"]),
    ("Aristotle's wheel"        , ["aristotle"]),
    ("Goldbach (statability)"   , ["goldbach"]),
]

has(text, markers) = any(occursin(m, text) for m in markers)

both = String[]; onlyA = String[]; onlyB = String[]; neither = String[]
println("="^78)
println(" 1. PARADOX INVENTORY  (A = julia2/paradox-instance, B = julia3claude)")
println("="^78)
println(rpad("paradox", 42), "  A  B")
println("-"^50)
for (name, markers) in PARADOXES
    a = has(allA, markers); b = has(allB, markers)
    a && b  && push!(both, name)
    a && !b && push!(onlyA, name)
    b && !a && push!(onlyB, name)
    !a && !b && push!(neither, name)
    println(rpad(name, 42), "  ", a ? "x" : "·", "  ", b ? "x" : "·")
end
println("-"^50)
nA = length(both) + length(onlyA); nB = length(both) + length(onlyB)
println("detected in A: $nA   detected in B: $nB   union: $(nA + length(onlyB))")
println("SHARED ($(length(both))): ", join(both, ", "))
println()
println("ONLY A — julia2 ($(length(onlyA))): ", join(onlyA, ", "))
println()
println("ONLY B — julia3claude ($(length(onlyB))): ", join(onlyB, ", "))
jaccard = length(both) / (length(both) + length(onlyA) + length(onlyB))
println()
println("Jaccard overlap of rosters: ", round(jaccard, digits = 3))

# ---------------------------------------------------------------------------
# 2. Structural comparison
# ---------------------------------------------------------------------------
loc(texts)      = sum(length(split(t, '\n')) for t in values(texts))
count_all(texts, pat) = sum(length(collect(eachmatch(pat, t))) for t in values(texts))

function stats(name, files, texts)
    println("\n--- ", name)
    println("  files (runner excluded):     ", length(files), "  ", files)
    println("  total lines:                 ", loc(texts))
    mods = String[string(m.captures[1]) for t in values(texts)
                  for m in eachmatch(r"^module (\w+)"m, t)]
    println("  module declarations:         ", length(mods),
            isempty(mods) ? "  (bare scripts, no modules)" : "  $(sort(mods))")
    println("  functions defined (approx):  ", count_all(texts, r"^\s*function |= *\(.*\) *->|\w+\(.*\) *= "m))
    println("  try/catch blocks:            ", count_all(texts, r"\btry\b"))
    println("  names StackOverflowError:    ", count_all(texts, r"StackOverflowError"))
    println("  Task/fetch sandboxing:       ", count_all(texts, r"\bTask\(|@async|fetch\("))
    println("  `missing` (K3 logic) uses:   ", count_all(texts, r"\bmissing\b"))
    println("  RNG seeds:                   ", [m.captures[1] for t in values(texts)
                                                for m in eachmatch(r"Random\.seed!\((\d+)\)", t)])
    println("  macros defined:              ", count_all(texts, r"^macro "m))
    println("  @enum declarations:          ", count_all(texts, r"@enum"))
    println("  VERDICT lines printed:       ", count_all(texts, r"VERDICT"))
end

println()
println("="^78)
println(" 2. STRUCTURAL COMPARISON")
println("="^78)
stats("A: julia2/responses/paradox-instance/paradoxes (SuperNinja instance 2)",
      filesA, textsA)
stats("B: julia3claude/paradoxes (Claude instance A)", filesB, textsB)

# organizing principle: read off the file naming schemes
println("\n--- organizing principle (from file names)")
println("  A files: ", filesA)
println("     -> organized by RESOLUTION CLASS (antinomies / mathematical(resolving)")
println("        / probability(ill-posed) / vagueness+selfreference) — Quine's")
println("        taxonomy is the directory structure.")
println("  B files: ", filesB)
println("     -> organized by SUBJECT DOMAIN (liar / self-reference / infinity /")
println("        probability / decision / identity+vagueness) + a 7th file that is")
println("        an essay companion (expressibility) — taxonomy lives in prose, not")
println("        in the file scheme.")

# taxonomy vocabulary
println("\n--- taxonomy vocabulary (occurrences in code+comments)")
for w in ["veridical", "falsidical", "antinom", "ill-posed", "dissolve",
          "inexpressible"]
    println("  ", rpad(w, 14), "  A: ", rpad(length(collect(eachmatch(Regex(w, "i"), allA))), 4),
            "B: ", length(collect(eachmatch(Regex(w, "i"), allB))))
end
println("\n  A's five-way split: Quine's three bins + ill-posed (+ benign control).")
println("  B's five-way split: Quine's three bins + ill-posed/dissolved + INEXPRESSIBLE —")
println("  the fifth status ('inexpressible') is B's original addition; it does not")
println("  occur in A at all if the count above is zero.")

# shared unusual constructions (fingerprints of sibling prompts)
println("\n--- shared unusual constructions (parallel-invention fingerprints)")
for (label, pat) in [
        ("verified quine as control",        r"quine"),
        ("Berry actually enumerated",        r"berry"i),
        ("Bertrand: 3 samplers, 3 answers",  r"bertrand"i),
        ("sorites under >=4 rival logics",   r"epistemicis|supervaluat"i),
        ("names StackOverflowError in code",  r"catch.*StackOverflow|StackOverflow.*catch"is),
    ]
    a = count_all(textsA, pat) > 0; b = count_all(textsB, pat) > 0
    println("  ", rpad(label, 36), " A: ", a ? "yes" : "no ", "   B: ", b ? "yes" : "no")
end
println("  (note: BOTH suites trigger and survive real stack overflows at runtime —")
println("   replication logs show 5 (A) and 6 (B) caught-overflow warnings on stderr;")
println("   A names the exception type and Task-sandboxes it, B catches generically.)")

# direct-copy check: any identical non-trivial line shared between suites?
linesA = Set(strip(l) for t in values(textsA) for l in split(t, '\n')
             if length(strip(l)) > 30 && !startswith(strip(l), "#"))
linesB = Set(strip(l) for t in values(textsB) for l in split(t, '\n')
             if length(strip(l)) > 30 && !startswith(strip(l), "#"))
shared_lines = intersect(linesA, linesB)
println("\n--- textual-copy check")
println("  non-trivial code lines (>30 chars, non-comment): A=",
        length(linesA), "  B=", length(linesB))
println("  identical lines shared verbatim: ", length(shared_lines))
for l in sort(collect(shared_lines))
    locA = [f for (f, t) in textsA if occursin(l, t)]
    locB = [f for (f, t) in textsB if occursin(l, t)]
    println("    | ", l)
    println("    |   in A: ", join(locA, ", "), "   in B: ", join(locB, ", "))
end
println("  -> ", isempty(shared_lines) ?
    "ZERO verbatim code overlap: consistent with independent implementations" :
    "few/incidental shared lines; inspect above — still consistent with independent implementations if trivial")

# Berry: same paradox, different object language (the clearest divergence probe)
println("\n--- Berry's paradox, side by side (same idea, different object language)")
mA = match(r"(?s)Berry.{0,2000}", textsA["01_antinomies.jl"])
println("  A: enumerates expressions over {1,2,3,+,*,^} up to 7 chars; answer printed")
println("     in committed output.txt: 103 (from 38851 valid expressions).")
println("  B: berry(5) over digits 0-9 and {+,*,^} in a 13-symbol language; answer")
println("     computed live in replication: 100001.")
println("  Same construction, disjoint object languages, disjoint answers —")
println("  the signature of parallel descent from a shared prompt, not of copying.")

println()
println("="^78)
println(" DONE — comparison complete; exit 0 means the instrument ran, not that")
println(" its interpretations are true. (House style borrowed knowingly.)")
println("="^78)
