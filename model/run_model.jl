#!/usr/bin/env julia
# run_model.jl -- load the observatory data, run every analysis, print the report.
# Deterministic by construction: no clock reads, no RNG, no network.
# Exit code 0 iff every model check passes.

include(joinpath(@__DIR__, "Observatory.jl"))
using .Observatory
using Dates
using Printf

const MODEL = load_model(joinpath(@__DIR__, "data", "cast.json"),
                         joinpath(@__DIR__, "data", "events.json"))
const SHORT = Dict(m.id => m.short for m in MODEL.members)
const FAILURES = String[]

section(t) = (println(); println("=" ^ 78); println(t); println("=" ^ 78))

function check(desc, cond)
    cond || push!(FAILURES, desc)
    @printf("  [%s] %s\n", cond ? "PASS" : "FAIL", desc)
end

hms(t) = Dates.format(t, "HH:MM:SS")
span(p) = string(Dates.canonicalize(Dates.CompoundPeriod(p)))

function print_bool_matrix(M)
    labels = string.(REPOS)
    w = maximum(length.(labels)) + 2
    print("  ", " " ^ w)
    for l in labels
        print(lpad(l, w))
    end
    println()
    for (i, l) in enumerate(labels)
        print("  ", rpad(l, w))
        for j in 1:length(labels)
            print(lpad(M[i, j] ? "1" : ".", w))
        end
        println()
    end
end

# ------------------------------------------------------------------ header
println("OBSERVATORY MODEL -- irreducible-mystery julia / julia2 / julia3claude (+ :synth)")
println("Data snapshot: 2026-08-04 (17 commits, 03:55:35-07:54:09 UTC).")
println("Everything below is COMPUTED from data/cast.json and data/events.json.")
@printf("Loaded: %d repos, %d members, %d footprints, %d events.\n",
        length(REPOS), length(MODEL.members), length(MODEL.footprints),
        length(MODEL.events))

# ----------------------------------------------------------------- 1. cast
section("1. CAST AND ACCESS RELATION (verdict-corrected cast atlas)")
for m in MODEL.members
    fps = [f for f in MODEL.footprints if f.member == m.id]
    tags = join(["$(f.repo)[$(f.access) $(f.reads ? "r" : "-")$(f.writes ? "w" : "-")]"
                 for f in fps], "  ")
    @printf("  %-10s %-22s %s\n", m.short, "(" * string(m.kind) * ")", tags)
    println("             ", m.display)
end
println()
println("  Access semantics: committer => reads+writes its repo; quoted /")
println("  referenced-only / subject-of-discussion => presence WITHOUT agency")
println("  (a member's words in a repo the member need not have read). Kelly reads")
println("  all three system repos as orchestrator; the merge bot writes without")
println("  reading. No member has any footprint in :synth.")

# ------------------------------------------------------------- 2. bipartite
section("2. MEMBER-REPO BIPARTITE GRAPH AND REPO-OVERLAP PROJECTION")
ms_any = membership(MODEL)
ms_com = membership(MODEL; committers_only = true)
println("  Members per repo (letter = access class: c committer, q quoted,")
println("  r referenced-only, s subject-of-discussion):")
for r in REPOS
    fps = sort!([f for f in MODEL.footprints if f.repo == r],
                by = f -> SHORT[f.member])
    lst = join(["$(SHORT[f.member])($(first(string(f.access))))" for f in fps], ", ")
    @printf("  %-14s %d members, %d committers : %s\n", string(r),
            length(ms_any[r]), length(ms_com[r]), isempty(lst) ? "(none)" : lst)
end
println()
println("  Repo-overlap projection (Jaccard = |shared| / |union|):")
println("    pair                            any-footprint                committer-only")
pa = repo_projection(MODEL)
pc = repo_projection(MODEL; committers_only = true)
for (x, y) in zip(pa, pc)
    sh_a = isempty(x.shared) ? "-" : join([SHORT[s] for s in x.shared], ",")
    sh_c = isempty(y.shared) ? "-" : join([SHORT[s] for s in y.shared], ",")
    @printf("    %-12s ~ %-12s  %5.3f %-20s  %5.3f %s\n",
            string(x.a), string(x.b), x.jaccard, "(" * sh_a * ")",
            y.jaccard, "(" * sh_c * ")")
end
println()
println("  Reading: the julia~julia2 overlap is carried by three members in the")
println("  wide sense but by SuperNinja-1 ALONE at committer level; julia3claude")
println("  shares nobody with the other repos except Kelly; and no repo shares")
println("  anyone with :synth -- the observatory has no members at all.")

# ------------------------------------------------------- 3. information flow
section("3. INFORMATION-FLOW REACHABILITY (a influences b iff a member reads a and writes b)")
Mdir = influence_matrix(MODEL)
println("  Direct influence matrix (rows = source, cols = destination):")
print_bool_matrix(Mdir)
println()
println("  Inter-repo channels and the members that realize them:")
for a in REPOS, b in REPOS
    a == b && continue
    vs = edge_vectors(MODEL, a, b)
    isempty(vs) && continue
    @printf("    %-12s -> %-12s via %s\n", string(a), string(b),
            join([SHORT[v] for v in vs], ", "))
end
Mclo = transitive_closure(Mdir)
mem_pairs = reachable_pairs(Mclo)
Mobs = observer_influence(Mdir)
obs_pairs = reachable_pairs(Mobs)
println()
println("  Transitive closure, member view (identical to the direct matrix -- the")
println("  member graph is already transitively closed):")
print_bool_matrix(Mclo)
println()
println("  Observer view (observer reads all four repos, writes only :synth):")
print_bool_matrix(Mobs)
println()
@printf("  Member-visible ordered pairs   : %d of 12  [%s]\n", length(mem_pairs),
        join(["$(a)->$(b)" for (a, b) in mem_pairs], ", "))
@printf("  Observer-visible ordered pairs : %d of 12  (adds every x -> :synth edge)\n",
        length(obs_pairs))
isynth = findfirst(==(:synth), REPOS)
no_member_reaches_synth = all(!Mclo[i, isynth] for i in 1:length(REPOS)) &&
                          all(!Mclo[isynth, j] for j in 1:length(REPOS))
println("  :synth in the member view: ",
        no_member_reaches_synth ?
        "unreachable and non-influencing -- no member reaches (or can name) the observatory." :
        "REACHED (unexpected).")
println("  The asymmetry is one-way glass: the observer's extra edges all terminate")
println("  in :synth and none run between the three system repos.")
println()
println("  Observed use of the channels (from event annotations):")
for e in MODEL.events
    e.transfer === nothing && continue
    fr, fseq, art = e.transfer
    src = MODEL.events[fseq]
    @printf("    event %d (%s %s) imports VERBATIM from event %d (%s %s):\n",
            e.seq, string(e.repo), hms(e.time), fseq, string(src.repo), hms(src.time))
    println("      ", art)
    println("      transfer latency: ", span(e.time - src.time))
end
println("    Caveat: the model's julia2 -> julia edge is realized by SuperNinja-1's")
println("    read/write capability, but the observed transfer travelled a two-hop")
println("    courier path (Kelly read julia2, handed content off-git, the authoring")
println("    instance wrote julia) that a single-member edge cannot represent.")

# ----------------------------------------------------------------- 4. replay
section("4. EVENT-LOG REPLAY -- STATE TRAJECTORY")
final, deltas = replay(MODEL)
println("  Event log (seq / UTC / repo / actor / sha7 / summary):")
for e in MODEL.events
    @printf("  %3d %s %-12s %-10s %s %s\n", e.seq, hms(e.time), string(e.repo),
            SHORT[e.actor], e.sha[1:7], e.summary)
end
println()
println("  Per-event deltas (new = paths first appearing; old = retouched paths;")
println("  size = repo artifact count after; * = actor's first event in that repo,")
println("  i.e. footprint growth):")
println("   seq  time      repo          actor        new  old  size")
for d in deltas
    e = MODEL.events[d.seq]
    marks = (d.first_touch ? " *" : "") *
            (startswith(e.channel, "merge") ? "  merge: no new artifacts" : "")
    @printf("   %3d  %s  %-12s  %-10s  %3d  %3d  %4d%s\n", d.seq, hms(d.time),
            string(d.repo), SHORT[d.actor], length(d.new_files), d.retouched,
            d.repo_size_after, marks)
end
println()
println("  Final state -- repo contents as artifact sets:")
for r in REPOS
    @printf("    %-14s %3d artifacts\n", string(r), length(final.files[r]))
end
@printf("    %-14s %3d artifacts across the system\n", "total",
        sum(length(final.files[r]) for r in REPOS))
println()
println("  Final footprints -- commit counts, member x repo:")
@printf("    %-11s", "")
for r in REPOS
    @printf(" %12s", string(r))
end
println()
committing = [m for m in MODEL.members if any(k -> k[1] == m.id, keys(final.commits))]
for m in committing
    @printf("    %-11s", m.short)
    for r in REPOS
        c = get(final.commits, (m.id, r), 0)
        @printf(" %12s", c == 0 ? "." : string(c))
    end
    println()
end
noncommit = [m.short for m in MODEL.members if !(m in committing)]
println("    zero-commit members (present only as quoted/referenced content): ",
        join(noncommit, ", "))
println()
first_e, last_e = MODEL.events[1], MODEL.events[end]
@printf("  Span: %s -> %s UTC = %s; three repos worked in parallel.\n",
        hms(first_e.time), hms(last_e.time), span(last_e.time - first_e.time))
gaps = [(MODEL.events[i+1].time - MODEL.events[i].time, i)
        for i in 1:length(MODEL.events)-1]
sort!(gaps, by = first)
println("  Fastest consecutive handoffs anywhere in the system:")
for (g, i) in gaps[1:3]
    a, b = MODEL.events[i], MODEL.events[i+1]
    @printf("    %-22s event %2d -> event %2d  (%s %s -> %s %s)\n", span(g),
            a.seq, b.seq, string(a.repo), SHORT[a.actor], string(b.repo), SHORT[b.actor])
end

# ---------------------------------------------------------------- 5. metrics
section("5. GOVERNANCE METRICS (incl. the invented sole-vector broker score)")
tt = turn_taking(MODEL)
he = actor_entropy(MODEL)
interp = Dict(
    :julia        => "perfect two-voice ping-pong: adversarial audit dialogue, no PRs",
    :julia2       => "strict alternation across three seats: author/review/merge protocol",
    :julia3claude => "monologue then handoff: human-led relay, frozen mid-dialogue",
    :synth        => "no member events -- the observatory only watches",
)
println("  Turn-taking index T (actor alternation between consecutive same-repo")
println("  commits; 1.0 = strict dialogue, 0.0 = monologue) and actor entropy H:")
for r in REPOS
    t = tt[r]
    ts = t === missing ? "  n/a" : (@sprintf("%5.3f", t))
    @printf("    %-14s T = %s   H = %5.3f bits   %s\n", string(r), ts, he[r], interp[r])
end
println()
scores, detail = broker_scores(MODEL)
println("  Sole-vector broker score: the number of ordered repo pairs (a,b) whose")
println("  ONLY read(a)&write(b) member is this one -- channels that go dark if the")
println("  member is removed:")
for m in MODEL.members
    s = scores[m.id]
    s == 0 && continue
    d = join(["$(p[1])->$(p[2])" for p in detail[m.id]], ", ")
    @printf("    %-10s %d   [%s]\n", m.short, s, d)
end
println("    (every other member: 0)")
println("  Reading: all four inter-repo channels are single-threaded, split evenly")
println("  between one human (Kelly) and one AI (SuperNinja-1). Removing either")
println("  halves the system's inter-repo connectivity; removing both disconnects")
println("  the three repos entirely.")
println()
peractor, peremail = git_identities(MODEL)
println("  Git identity hygiene (computed from event metadata):")
for m in MODEL.members
    haskey(peractor, m.id) || continue
    ems = sort!(collect(peractor[m.id]))
    flag = length(ems) > 1 ? "   <- mid-thread identity shift" : ""
    @printf("    %-10s commits as: %s%s\n", m.short, join(ems, " ; "), flag)
end
for (em, actors) in sort!(collect(peremail), by = first)
    length(actors) > 1 || continue
    println("    shared email ", em, " used by ",
            join(sort!([SHORT[a] for a in actors]), " and "),
            "  <- identity lending: raw git metadata misattributes work")
end

# ----------------------------------------------------------------- 6. checks
section("6. MODEL CHECKS")
check("event seq numbers equal chronological order 1..17",
      length(MODEL.events) == 17 &&
      all(MODEL.events[i].seq == i for i in 1:length(MODEL.events)))
check("every event actor holds write access to the event's repo",
      all(any(f -> f.member == e.actor && f.repo == e.repo && f.writes,
              MODEL.footprints) for e in MODEL.events))
check("no member has any footprint in :synth",
      all(f.repo != :synth for f in MODEL.footprints))
check("member-view closure: :synth row and column empty (no member reaches the observatory)",
      no_member_reaches_synth)
check("observer view: every repo, including :synth, reaches :synth",
      all(Mobs[i, isynth] for i in 1:length(REPOS)))
check("observer view adds NO edge between the three system repos (one-way glass)",
      all(Mobs[i, j] == Mclo[i, j]
          for i in 1:length(REPOS), j in 1:length(REPOS) if j != isynth))
check("merge events introduce zero new artifacts",
      all(isempty(d.new_files) for d in deltas
          if startswith(MODEL.events[d.seq].channel, "merge")))
check("julia's README.md is touched by all 7 julia commits (the ledger discipline)",
      count(e -> e.repo == :julia && "README.md" in e.files, MODEL.events) == 7 &&
      count(e -> e.repo == :julia, MODEL.events) == 7)
check("final artifact counts: julia=22, julia2=25, julia3claude=18, synth=0",
      length(final.files[:julia]) == 22 && length(final.files[:julia2]) == 25 &&
      length(final.files[:julia3claude]) == 18 && length(final.files[:synth]) == 0)
check("turn-taking: julia 1.0, julia2 1.0, julia3claude 0.5",
      tt[:julia] == 1.0 && tt[:julia2] == 1.0 && tt[:julia3claude] == 0.5)
check("broker scores: exactly Kelly=2 and SuperNinja-1=2, all others 0",
      scores["kelly_orchestrator"] == 2 &&
      scores["superninja_instance_1_auditor"] == 2 && sum(values(scores)) == 4)
tr_events = [e for e in MODEL.events if e.transfer !== nothing]
check("exactly one verified verbatim cross-repo transfer: julia2 -> julia (the shock)",
      length(tr_events) == 1 && tr_events[1].repo == :julia &&
      tr_events[1].transfer[1] == :julia2)

println()
if isempty(FAILURES)
    println("ALL MODEL CHECKS PASSED -- in the observed system's own idiom:")
    println("exit 0 is evidence, never proof.")
else
    println(length(FAILURES), " CHECK(S) FAILED:")
    for f in FAILURES
        println("  - ", f)
    end
    exit(1)
end
