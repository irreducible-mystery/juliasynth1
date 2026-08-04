# Observatory.jl -- stdlib-only Julia model of the observed multi-agent repo system.
#
# The observed system: three git repos owned by a human orchestrator (Kelly,
# github irreducible-mystery) and populated by AI instances from several
# platforms, worked in parallel over a single four-hour window (2026-08-04,
# 03:55-07:54 UTC, 17 commits). The observer holds a fourth repo, :synth (the
# observatory this file lives in), which no system member can see or reach.
#
# The model has two inputs (data/cast.json, data/events.json) and derives all
# structure from them:
#
#   Member    -- a cast-atlas member (human / AI instance / bot / persona)
#   Footprint -- the access relation: the atlas category (committer, quoted,
#                referenced-only, subject-of-discussion) plus the read/write
#                capability used by the flow analysis. Quoted or referenced
#                presence is content WITHOUT agency: a member's words can sit
#                in a repo it cannot read (the 'shock' is exactly this).
#   Event     -- one git commit, reattributed to its true actor (git identity
#                and actor differ where identities were lent or shifted).
#
# Analyses:
#   (a) membership / repo_projection : the member-repo bipartite graph and its
#       repo-overlap projection with Jaccard coefficients, in two flavors
#       (any footprint vs committers only)
#   (b) influence_matrix / transitive_closure / observer_influence :
#       information-flow reachability -- repo a can influence repo b iff some
#       member reads a AND writes b; the observer adds read-everything /
#       write-:synth edges that no member has
#   (c) replay : fold the event log into a state trajectory -- repo contents as
#       artifact-path sets, member footprints growing, per-event deltas
#   (d) broker_scores : the invented metric (justification at the function),
#       with turn_taking / actor_entropy as secondary governance signatures

module Observatory

using Dates

export Member, Footprint, Event, SystemModel, REPOS,
       load_model,
       membership, repo_projection,
       readers, writers, influence_matrix, edge_vectors,
       transitive_closure, observer_influence, reachable_pairs,
       EventDelta, FinalState, replay,
       turn_taking, actor_entropy, broker_scores, git_identities

# ------------------------------------------------------------------ MiniJSON
# Julia's stdlib ships no JSON parser; the data files are plain-ASCII JSON, so
# a small recursive-descent parser suffices (objects, arrays, strings with the
# standard escapes, numbers, true/false/null).
module MiniJSON

function parse(s::AbstractString)
    str = String(s)
    v, i = _value(str, _ws(str, 1))
    i = _ws(str, i)
    i > ncodeunits(str) || error("MiniJSON: trailing data at byte $i")
    return v
end

function _ws(s, i)
    n = ncodeunits(s)
    while i <= n
        c = codeunit(s, i)
        (c == 0x20 || c == 0x09 || c == 0x0a || c == 0x0d) || break
        i += 1
    end
    return i
end

function _value(s, i)
    i <= ncodeunits(s) || error("MiniJSON: unexpected end of input")
    c = codeunit(s, i)
    c == UInt8('{') && return _object(s, i)
    c == UInt8('[') && return _array(s, i)
    c == UInt8('"') && return _string(s, i)
    c == UInt8('t') && return (true, i + 4)
    c == UInt8('f') && return (false, i + 5)
    c == UInt8('n') && return (nothing, i + 4)
    return _number(s, i)
end

function _object(s, i)
    d = Dict{String,Any}()
    i = _ws(s, i + 1)
    codeunit(s, i) == UInt8('}') && return (d, i + 1)
    while true
        k, i = _string(s, i)
        i = _ws(s, i)
        codeunit(s, i) == UInt8(':') || error("MiniJSON: expected ':' at byte $i")
        v, i = _value(s, _ws(s, i + 1))
        d[k] = v
        i = _ws(s, i)
        c = codeunit(s, i)
        if c == UInt8(',')
            i = _ws(s, i + 1)
        elseif c == UInt8('}')
            return (d, i + 1)
        else
            error("MiniJSON: expected ',' or '}' at byte $i")
        end
    end
end

function _array(s, i)
    a = Any[]
    i = _ws(s, i + 1)
    codeunit(s, i) == UInt8(']') && return (a, i + 1)
    while true
        v, i = _value(s, i)
        push!(a, v)
        i = _ws(s, i)
        c = codeunit(s, i)
        if c == UInt8(',')
            i = _ws(s, i + 1)
        elseif c == UInt8(']')
            return (a, i + 1)
        else
            error("MiniJSON: expected ',' or ']' at byte $i")
        end
    end
end

function _string(s, i)
    codeunit(s, i) == UInt8('"') || error("MiniJSON: expected '\"' at byte $i")
    buf = IOBuffer()
    i += 1
    n = ncodeunits(s)
    while i <= n
        c = codeunit(s, i)
        if c == UInt8('"')
            return (String(take!(buf)), i + 1)
        elseif c == UInt8('\\')
            e = codeunit(s, i + 1)
            if e == UInt8('u')
                print(buf, Char(Base.parse(UInt32, s[i+2:i+5]; base = 16)))
                i += 6
            else
                print(buf,
                      e == UInt8('n') ? '\n' :
                      e == UInt8('t') ? '\t' :
                      e == UInt8('r') ? '\r' :
                      e == UInt8('b') ? '\b' :
                      e == UInt8('f') ? '\f' : Char(e))   # covers \" \\ \/
                i += 2
            end
        else
            write(buf, c)
            i += 1
        end
    end
    error("MiniJSON: unterminated string")
end

function _number(s, i)
    n = ncodeunits(s)
    j = i
    while j <= n
        c = codeunit(s, j)
        ok = (UInt8('0') <= c <= UInt8('9')) || c == UInt8('-') || c == UInt8('+') ||
             c == UInt8('.') || c == UInt8('e') || c == UInt8('E')
        ok || break
        j += 1
    end
    tok = s[i:j-1]
    v = occursin(r"[.eE]", tok) ? Base.parse(Float64, tok) : Base.parse(Int, tok)
    return (v, j)
end

end # module MiniJSON

# -------------------------------------------------------------------- types

"The four repos of the model's universe. :synth is the observer's own repo --
present in the universe, invisible to every system member."
const REPOS = [:julia, :julia2, :julia3claude, :synth]

struct Member
    id::String
    kind::Symbol
    display::String
    short::String
end

struct Footprint
    member::String
    repo::Symbol
    access::Symbol   # atlas category: committer | quoted | referenced_only | subject_of_discussion
    reads::Bool      # capability used by the flow analysis
    writes::Bool
    note::String
end

struct Event
    seq::Int
    repo::Symbol
    sha::String
    time::DateTime           # UTC
    actor::String            # member id after reattribution
    git_author::String       # raw git identity (may belong to another member)
    channel::String
    summary::String
    files::Vector{String}
    # verified verbatim import: (from_repo, from_event_seq, artifact); nothing otherwise
    transfer::Union{Nothing,Tuple{Symbol,Int,String}}
end

struct SystemModel
    members::Vector{Member}
    footprints::Vector{Footprint}
    events::Vector{Event}
end

const DATEFMT = dateformat"yyyy-mm-dd HH:MM:SS"

function load_model(cast_path::AbstractString, events_path::AbstractString)
    cast = MiniJSON.parse(read(cast_path, String))
    evd  = MiniJSON.parse(read(events_path, String))

    Set(String.(cast["repos"])) == Set(string.(REPOS)) ||
        error("cast.json repo list disagrees with Observatory.REPOS")

    members = Member[]
    footprints = Footprint[]
    for m in cast["members"]
        push!(members, Member(m["id"], Symbol(replace(m["kind"], "-" => "_")),
                              m["display"], m["short"]))
        for f in m["footprint"]
            push!(footprints,
                  Footprint(m["id"], Symbol(f["repo"]),
                            Symbol(replace(f["access"], "-" => "_")),
                            f["reads"], f["writes"], String(get(f, "note", ""))))
        end
    end

    events = Event[]
    for e in evd["events"]
        t = get(e, "imports_verbatim", nothing)
        transfer = t === nothing ? nothing :
                   (Symbol(t["from_repo"]), Int(t["from_event"]), String(t["artifact"]))
        push!(events, Event(e["seq"], Symbol(e["repo"]), e["sha"],
                            DateTime(e["utc"], DATEFMT), e["actor"], e["git_author"],
                            e["channel"], e["summary"],
                            String[String(x) for x in e["files"]], transfer))
    end
    sort!(events, by = e -> (e.time, e.seq))

    # Sanity: referenced members/repos exist, and every event is backed by a
    # write-capable footprint of its actor -- the log must be consistent with
    # the access relation.
    ids = Set(m.id for m in members)
    for f in footprints
        f.member in ids || error("footprint for unknown member $(f.member)")
        f.repo in REPOS || error("footprint for unknown repo $(f.repo)")
    end
    for e in events
        e.actor in ids || error("event $(e.seq): unknown actor $(e.actor)")
        any(f -> f.member == e.actor && f.repo == e.repo && f.writes, footprints) ||
            error("event $(e.seq): actor $(e.actor) lacks write access to $(e.repo)")
    end
    return SystemModel(members, footprints, events)
end

# --------------------------------------------- (a) bipartite graph & overlap

"Member sets per repo (the bipartite graph as adjacency); committers_only
restricts to the committer access class."
function membership(m::SystemModel; committers_only::Bool = false)
    d = Dict(r => Set{String}() for r in REPOS)
    for f in m.footprints
        committers_only && f.access != :committer && continue
        push!(d[f.repo], f.member)
    end
    return d
end

"Repo-overlap projection of the bipartite graph: for every unordered repo pair,
the shared members and the Jaccard overlap |shared| / |union|."
function repo_projection(m::SystemModel; committers_only::Bool = false)
    ms = membership(m; committers_only)
    out = NamedTuple{(:a, :b, :shared, :jaccard),
                     Tuple{Symbol,Symbol,Vector{String},Float64}}[]
    for i in 1:length(REPOS), j in i+1:length(REPOS)
        a, b = REPOS[i], REPOS[j]
        shared = sort!(collect(intersect(ms[a], ms[b])))
        u = union(ms[a], ms[b])
        push!(out, (a = a, b = b, shared = shared,
                    jaccard = isempty(u) ? 0.0 : length(shared) / length(u)))
    end
    return out
end

# ------------------------------------------------- (b) information-flow model

readers(m::SystemModel, r::Symbol) =
    Set(f.member for f in m.footprints if f.repo == r && f.reads)
writers(m::SystemModel, r::Symbol) =
    Set(f.member for f in m.footprints if f.repo == r && f.writes)

"M[a,b] == true iff repo a can influence repo b: some member reads a and writes b."
function influence_matrix(m::SystemModel)
    n = length(REPOS)
    M = falses(n, n)
    for (ia, a) in enumerate(REPOS), (ib, b) in enumerate(REPOS)
        M[ia, ib] = !isempty(intersect(readers(m, a), writers(m, b)))
    end
    return M
end

"The members that realize the direct a -> b channel."
edge_vectors(m::SystemModel, a::Symbol, b::Symbol) =
    sort!(collect(intersect(readers(m, a), writers(m, b))))

function transitive_closure(M::AbstractMatrix{Bool})
    C = Matrix{Bool}(M)
    n = size(C, 1)
    for k in 1:n, i in 1:n, j in 1:n
        C[i, j] = C[i, j] || (C[i, k] && C[k, j])
    end
    return C
end

"What the OBSERVER's presence adds: it reads every repo (it cloned all three
and owns :synth) and writes only :synth. No system member has any such edge."
function observer_influence(M::AbstractMatrix{Bool})
    C = Matrix{Bool}(M)
    isynth = findfirst(==(:synth), REPOS)
    for i in 1:size(C, 1)
        C[i, isynth] = true
    end
    return transitive_closure(C)
end

"Ordered reachable pairs (a != b) under a closed influence matrix."
reachable_pairs(C::AbstractMatrix{Bool}) =
    sort!([(REPOS[i], REPOS[j]) for i in axes(C, 1), j in axes(C, 2)
           if i != j && C[i, j]])

# ------------------------------------------------------- (c) event-log replay

struct EventDelta
    seq::Int
    time::DateTime
    repo::Symbol
    actor::String
    new_files::Vector{String}   # paths first appearing in the repo at this event
    retouched::Int              # touched paths that already existed
    first_touch::Bool           # actor's first event in this repo (footprint growth)
    repo_size_after::Int        # repo artifact count after the event
end

struct FinalState
    files::Dict{Symbol,Set{String}}            # repo contents as artifact sets
    commits::Dict{Tuple{String,Symbol},Int}    # (member id, repo) -> event count
end

"Fold the event log into (final state, per-event deltas): the system's state
trajectory, with repo contents as artifact sets and footprints growing."
function replay(m::SystemModel)
    files = Dict(r => Set{String}() for r in REPOS)
    commits = Dict{Tuple{String,Symbol},Int}()
    deltas = EventDelta[]
    for e in m.events
        fresh = [p for p in e.files if !(p in files[e.repo])]
        key = (e.actor, e.repo)
        first = !haskey(commits, key)
        commits[key] = get(commits, key, 0) + 1
        union!(files[e.repo], e.files)
        push!(deltas, EventDelta(e.seq, e.time, e.repo, e.actor, fresh,
                                 length(e.files) - length(fresh), first,
                                 length(files[e.repo])))
    end
    return FinalState(files, commits), deltas
end

# --------------------------------------------------------------- (d) metrics

"Turn-taking index: fraction of consecutive same-repo events whose actor
changes. 1.0 = strict alternation (a dialogue), 0.0 = monologue. Separates the
repos' governance styles quantitatively."
function turn_taking(m::SystemModel)
    out = Dict{Symbol,Union{Float64,Missing}}()
    for r in REPOS
        seq = [e.actor for e in m.events if e.repo == r]
        out[r] = length(seq) < 2 ? missing :
                 count(i -> seq[i] != seq[i+1], 1:length(seq)-1) / (length(seq) - 1)
    end
    return out
end

"Shannon entropy (bits) of the per-repo actor distribution: how many effective
voices a repo has. Complements turn_taking, which only sees adjacency."
function actor_entropy(m::SystemModel)
    out = Dict{Symbol,Float64}()
    for r in REPOS
        seq = [e.actor for e in m.events if e.repo == r]
        if isempty(seq)
            out[r] = 0.0
        else
            cnt = Dict{String,Int}()
            for a in seq
                cnt[a] = get(cnt, a, 0) + 1
            end
            out[r] = -sum(c / length(seq) * log2(c / length(seq)) for c in values(cnt))
        end
    end
    return out
end

# INVENTED METRIC: the sole-vector (broker) score.
#
# For each ordered repo pair (a, b), a != b, whose influence edge exists, a
# member is the SOLE VECTOR if it is the only member with read(a) & write(b):
# remove that one member and the channel goes dark. The score counts such
# pairs per member. Why this metric: it converts the atlas's narrative claim
# ("Kelly and SuperNinja-1 are the system's only inter-repo conduits") into a
# computed number, and it exposes the system's structural fragility -- every
# inter-repo channel turns out to be single-threaded through exactly one of
# two articulation members, one human and one AI.
function broker_scores(m::SystemModel)
    scores = Dict(mm.id => 0 for mm in m.members)
    detail = Dict{String,Vector{Tuple{Symbol,Symbol}}}()
    for a in REPOS, b in REPOS
        a == b && continue
        vs = edge_vectors(m, a, b)
        if length(vs) == 1
            scores[vs[1]] += 1
            push!(get!(detail, vs[1], Tuple{Symbol,Symbol}[]), (a, b))
        end
    end
    return scores, detail
end

"Raw git author emails per actor and actors per email -- surfaces identity
shifts (one actor, several emails) and identity lending (one email, several
actors), both of which the observed system exhibits."
function git_identities(m::SystemModel)
    peractor = Dict{String,Set{String}}()
    peremail = Dict{String,Set{String}}()
    for e in m.events
        mm = match(r"<([^>]+)>", e.git_author)
        email = mm === nothing ? e.git_author : String(mm.captures[1])
        push!(get!(peractor, e.actor, Set{String}()), email)
        push!(get!(peremail, email, Set{String}()), e.actor)
    end
    return peractor, peremail
end

end # module Observatory
