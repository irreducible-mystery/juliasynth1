/-
================================================================================
AccessTopology — an external observer's formal model of the access topology
of the three-repo AI-collaboration system operated by Kelly
(GitHub: irreducible-mystery / kellyjs1313), 2026-08-04.
================================================================================

THIS IS AN OBSERVER'S MODEL.  The observer does not participate in the
system.  The fourth repo, `synth`, stands for the observer's own observatory
repo (juliasynth1), which is invisible to every system member; theorems
`no_member_writes_synth` / `no_member_reads_synth` / `synth_isolated` record
that boundary formally.

Date of model: 2026-08-04.

Data provenance:
  * Read-only clones /home/user/julia (HEAD 35479fe), /home/user/julia2
    (HEAD e251aa3), /home/user/julia3claude (HEAD 092be9f, merge of PR #1);
    commit authorship re-checked against `git log` at model time.
  * `writes m r = true`  ⟺  m has verified commit/merge authorship in r's
    git history.  Claude instance A's three julia3claude commits are recorded
    under Kelly's lent git identity (kellyjs1313@gmail.com) but carry
    Claude-Session trailers; they are attributed to the instance, not Kelly.
    Kelly's sole verified write is the julia3claude PR #1 merge (092be9f).
  * `reads m r = true`  ⟺  m has EVIDENCED read access to r's content:
    every committer reads the repo it commits to, and Kelly's engagement
    with all three repos is evidenced (her verbatim-quoted questions about
    julia's content in emergence_06/_07; owner-requested work and
    adjudication invitations in julia2; the PR #1 merge in julia3claude).
    `reads` encodes evidenced access, not potential capability: Kelly could
    push anywhere as owner, but the record shows no such write, so none is
    encoded.
  * "Referenced-only" / "quoted" presence is NOT access: the source-document
    AI, the personas observer-2 and "the next stranger", and the julia2
    paradox-instance's report quoted into julia as the anonymous "shock"
    confer no read/write bit on their subjects.
  * Cast: the verdict-corrected atlas (10 deduplicated members; the
    julia3claude `-6uiqo3` branch identity is folded into Claude instance A;
    the observation session's own `-etyrdg` branch traces are excluded).

Modeling note: `influence a b` is single-member-witnessed flow — some member
reads repo a and writes repo b.  Off-git relay (e.g. Kelly prompting an
instance in chat with content she read elsewhere) is deliberately NOT
modeled; only repo-access-mediated flow is.  `Reaches` is the transitive
closure of `influence`.

No axioms beyond Lean's kernel are used; every finite check is by `decide`.
================================================================================
-/

namespace AccessTopology

/-- The three observed system repos, plus the observer's own repo. -/
inductive Repo where
  | julia          -- irreducible-mystery/julia   (emergence dialogue, RingRest.lean)
  | julia2         -- irreducible-mystery/julia2  (generative field, paradox suite)
  | julia3claude   -- irreducible-mystery/julia3claude (Claude paradoxes + Lean stub)
  | synth          -- the observer's observatory repo (juliasynth1) — outside the system
  deriving DecidableEq, Repr

/-- The deduplicated cast of the system (verdict-corrected atlas). -/
inductive Member where
  | kelly             -- human orchestrator (irreducible-mystery / kellyjs1313@gmail.com)
  | authoringInstance -- julia's authoring-instance <authoring@invalid>; platform unattested
  | superNinja1       -- superninja@ninjatech.ai platform identity: julia's auditor
                      --   ("the stranger", later auditor@sandbox seat) = julia2's instance 1
  | paradoxInstance   -- SuperNinja instance 2 <paradox-instance@agents.local> (julia2)
  | superninjaAppBot  -- superninja-app[bot] GitHub App id 223766961 (julia2 merge vehicle)
  | claudeInstanceA   -- Claude Code session ...rrhKo: julia3claude author (under Kelly's git identity)
  | claudeInstanceB   -- Claude Code session ...AV3uR: julia3claude Lean scaffold (PR #1)
  | sourceDocAI       -- unnamed assistant behind the julia2 seed documents (quoted only)
  | observer2         -- persona inside julia2's Part 3 demo data (referenced only)
  | nextStranger      -- julia's standing vacant auditor role (referenced only)
  deriving DecidableEq, Repr

open Repo Member

/-- Enumeration of the whole cast. -/
def allMembers : List Member :=
  [kelly, authoringInstance, superNinja1, paradoxInstance, superninjaAppBot,
   claudeInstanceA, claudeInstanceB, sourceDocAI, observer2, nextStranger]

theorem allMembers_complete : ∀ m : Member, m ∈ allMembers := by
  intro m; cases m <;> decide

/--
Verified write access: commit/merge authorship in the repo's git history.
  kelly            → julia3claude (merge 092be9f only)
  authoringInstance→ julia        (3f95cde, 90f249a, 722ac99)
  superNinja1      → julia        (59c7fa2, c05d555, 127b8ef, 35479fe)
                   → julia2       (24a393c, root F_0)
  paradoxInstance  → julia2       (3eac782, 9c159a6)
  superninjaAppBot → julia2       (merges 213304b, e251aa3)
  claudeInstanceA  → julia3claude (4954a3f, 48390e1, ea552d2 — Claude-Session trailers)
  claudeInstanceB  → julia3claude (c9727a0)
Nobody writes `synth`.
-/
def writes : Member → Repo → Bool
  | kelly,             julia3claude => true
  | authoringInstance, julia        => true
  | superNinja1,       julia        => true
  | superNinja1,       julia2       => true
  | paradoxInstance,   julia2       => true
  | superninjaAppBot,  julia2       => true
  | claudeInstanceA,   julia3claude => true
  | claudeInstanceB,   julia3claude => true
  | _,                 _            => false

/--
Evidenced read access: every committer reads its repo; Kelly additionally
reads julia (her questions engage its content; emergence_06/_07) and julia2
(owner-requested Broome deep dive, adjudication invitations, shock routing).
"Quoted"/"referenced-only" presence is not read access.  Nobody reads `synth`.
-/
def reads : Member → Repo → Bool
  | kelly,             julia        => true
  | kelly,             julia2       => true
  | kelly,             julia3claude => true
  | authoringInstance, julia        => true
  | superNinja1,       julia        => true
  | superNinja1,       julia2       => true
  | paradoxInstance,   julia2       => true
  | superninjaAppBot,  julia2       => true
  | claudeInstanceA,   julia3claude => true
  | claudeInstanceB,   julia3claude => true
  | _,                 _            => false

/-- Hygiene: verified writers are evidenced readers of the same repo. -/
theorem writes_imp_reads : ∀ (m : Member) (r : Repo),
    writes m r = true → reads m r = true := by
  intro m r; cases m <;> cases r <;> decide

/--
Membership-witnessed flow: content can move from repo `a` to repo `b`
iff some single member reads `a` and writes `b`.
-/
def influence (a b : Repo) : Bool :=
  allMembers.any fun m => reads m a && writes m b

/-- Semantic characterization of `influence`: it holds exactly when a
member witnesses the flow. -/
theorem influence_iff (a b : Repo) :
    influence a b = true ↔ ∃ m : Member, reads m a = true ∧ writes m b = true := by
  constructor
  · intro h
    have h' := List.any_eq_true.mp h
    match h' with
    | ⟨m, _, hm⟩ =>
      simp only [Bool.and_eq_true] at hm
      exact ⟨m, hm⟩
  · intro h
    match h with
    | ⟨m, hr, hw⟩ =>
      exact List.any_eq_true.mpr ⟨m, allMembers_complete m, by simp [hr, hw]⟩

/-- Reachability: the transitive closure of `influence`. -/
inductive Reaches : Repo → Repo → Prop
  | step  {a b : Repo}   : influence a b = true → Reaches a b
  | trans {a b c : Repo} : Reaches a b → Reaches b c → Reaches a c

/--
Non-obvious closure fact: the influence relation of this system is ALREADY
transitively closed — taking the transitive closure adds no new pairs.
-/
theorem influence_trans :
    ∀ a b c : Repo, influence a b = true → influence b c = true →
      influence a c = true := by
  intro a b c
  cases a <;> cases b <;> cases c <;> decide

/-- Hence reachability coincides exactly with one-step influence. -/
theorem reaches_iff_influence : ∀ a b : Repo, Reaches a b ↔ influence a b = true := by
  intro a b
  constructor
  · intro h
    induction h with
    | step h' => exact h'
    | trans _ _ ih1 ih2 => exact influence_trans _ _ _ ih1 ih2
  · exact Reaches.step

/--
The full ground truth of the influence graph on the three observed repos
(rows julia, julia2, julia3claude; columns likewise):
  julia        → julia, julia2, julia3claude
  julia2       → julia, julia2, julia3claude
  julia3claude → julia3claude only.
-/
theorem influence_table :
    influence julia julia               = true  ∧
    influence julia julia2              = true  ∧
    influence julia julia3claude        = true  ∧
    influence julia2 julia              = true  ∧
    influence julia2 julia2             = true  ∧
    influence julia2 julia3claude       = true  ∧
    influence julia3claude julia        = false ∧
    influence julia3claude julia2       = false ∧
    influence julia3claude julia3claude = true := by decide

/-! ## Theorems (1) and (2): the observer boundary -/

/-- (1) No system member writes the observer's repo. -/
theorem no_member_writes_synth : ∀ m : Member, writes m synth = false := by
  intro m; cases m <;> decide

/-- (2) No system member reads the observer's repo. -/
theorem no_member_reads_synth : ∀ m : Member, reads m synth = false := by
  intro m; cases m <;> decide

/-- The observer's repo is fully isolated in the flow graph:
nothing reaches it and it reaches nothing. -/
theorem synth_isolated : ∀ r : Repo, ¬ Reaches synth r ∧ ¬ Reaches r synth := by
  intro r
  constructor
  · intro h
    have h' := (reaches_iff_influence _ _).mp h
    revert h'
    cases r <;> decide
  · intro h
    have h' := (reaches_iff_influence _ _).mp h
    revert h'
    cases r <;> decide

/-! ## Theorem (3): exact reachability among the observed repos

The three observed repos are NOT mutually reachable.  The truth is:
julia and julia2 are mutually reachable (via the SuperNinja platform
identity, which reads and writes both); julia3claude is reachable from
both (via Kelly, the only member who reads julia/julia2 and writes
julia3claude); but julia3claude reaches nothing outside itself — it is a
sink of the system. -/

theorem julia_reaches_julia2 : Reaches julia julia2 := .step (by decide)
theorem julia2_reaches_julia : Reaches julia2 julia := .step (by decide)
theorem julia_reaches_julia3claude : Reaches julia julia3claude := .step (by decide)
theorem julia2_reaches_julia3claude : Reaches julia2 julia3claude := .step (by decide)

/-- julia3claude is a sink: it reaches neither julia nor julia2. -/
theorem julia3claude_is_sink :
    ¬ Reaches julia3claude julia ∧ ¬ Reaches julia3claude julia2 := by
  constructor
  · intro h
    exact absurd ((reaches_iff_influence _ _).mp h) (by decide)
  · intro h
    exact absurd ((reaches_iff_influence _ _).mp h) (by decide)

/-- The exact reachability statement, bundled. -/
theorem observed_reachability_exact :
    (Reaches julia julia2 ∧ Reaches julia2 julia) ∧
    (Reaches julia julia3claude ∧ Reaches julia2 julia3claude) ∧
    (¬ Reaches julia3claude julia ∧ ¬ Reaches julia3claude julia2) :=
  ⟨⟨julia_reaches_julia2, julia2_reaches_julia⟩,
   ⟨julia_reaches_julia3claude, julia2_reaches_julia3claude⟩,
   julia3claude_is_sink⟩

/-! ## Theorem (4): what is actually true about "universal" access

The hypothesis "the orchestrator is the unique member with write access to
every observed repo" is FALSE in the verified record: Kelly's only write is
the julia3claude merge.  What IS true: -/

/-- (4a) NO member — Kelly included — writes all three observed repos. -/
theorem no_member_writes_all_observed :
    ∀ m : Member,
      ¬ (writes m julia = true ∧ writes m julia2 = true ∧
         writes m julia3claude = true) := by
  intro m; cases m <;> decide

/-- (4b) Kelly reads all three observed repos. -/
theorem kelly_reads_all_observed :
    reads kelly julia = true ∧ reads kelly julia2 = true ∧
    reads kelly julia3claude = true := by decide

/-- (4c) …and she is the UNIQUE member who does: universal access in this
system is read-side and human. -/
theorem kelly_unique_all_observed_reader :
    ∀ m : Member,
      reads m julia = true → reads m julia2 = true →
      reads m julia3claude = true → m = kelly := by
  intro m h1 h2 h3
  cases m <;>
    first
      | rfl
      | exact absurd h1 (by decide)
      | exact absurd h2 (by decide)
      | exact absurd h3 (by decide)

/-- (4d) The only member with write access to more than one repo is the
SuperNinja platform identity (julia + julia2). -/
theorem superNinja1_unique_multi_repo_writer :
    ∀ m : Member, ∀ a b : Repo, a ≠ b →
      writes m a = true → writes m b = true → m = superNinja1 := by
  intro m a b hab ha hb
  cases m <;> cases a <;> cases b <;>
    first
      | rfl
      | exact absurd rfl hab
      | exact absurd ha (by decide)
      | exact absurd hb (by decide)

/-! ## Theorem (5): cut vertices of the flow graph

Non-obvious structural property: the system has EXACTLY TWO cut members.
Removing Kelly severs all flow into julia3claude (it becomes a separate
component); removing the SuperNinja platform identity severs julia ↔ julia2
in both directions.  Removing any other member changes no edge at all. -/

/-- `influence` with member `x` deleted from the cast. -/
def influenceWithout (x : Member) (a b : Repo) : Bool :=
  allMembers.any fun m => decide (m ≠ x) && reads m a && writes m b

/-- (5a) Kelly is a cut vertex: she alone carries the flow into julia3claude. -/
theorem kelly_is_cut :
    influence julia julia3claude = true ∧
    influence julia2 julia3claude = true ∧
    influenceWithout kelly julia julia3claude = false ∧
    influenceWithout kelly julia2 julia3claude = false := by decide

/-- Sharpening (5a): without Kelly, NOTHING flows into julia3claude from
any other repo. -/
theorem without_kelly_no_flow_into_julia3claude :
    ∀ a : Repo, a ≠ julia3claude →
      influenceWithout kelly a julia3claude = false := by
  intro a ha
  cases a
  case julia3claude => exact absurd rfl ha
  all_goals decide

/-- (5b) The SuperNinja platform identity is a cut vertex: it alone carries
the julia ↔ julia2 flow, in both directions. -/
theorem superNinja1_is_cut :
    influence julia julia2 = true ∧
    influence julia2 julia = true ∧
    influenceWithout superNinja1 julia julia2 = false ∧
    influenceWithout superNinja1 julia2 julia = false := by decide

/-- (5c) …and these are the ONLY cut members: deleting any other member
leaves every influence edge unchanged. -/
theorem cut_members_only (x : Member) :
    x = kelly ∨ x = superNinja1 ∨
    ∀ a b : Repo, influenceWithout x a b = influence a b := by
  cases x
  case kelly => exact Or.inl rfl
  case superNinja1 => exact Or.inr (Or.inl rfl)
  all_goals exact Or.inr (Or.inr (fun a b => by cases a <;> cases b <;> decide))

/-- (5d) Member-level version: EVERY cross-repo influence edge is witnessed
only by Kelly or the SuperNinja identity — all six AI committers besides
superNinja1 live inside a single repo. -/
theorem cross_edges_only_kelly_or_superNinja1 (m : Member) (a b : Repo)
    (hab : a ≠ b) (hr : reads m a = true) (hw : writes m b = true) :
    m = kelly ∨ m = superNinja1 := by
  cases m <;> cases a <;> cases b <;>
    first
      | exact Or.inl rfl
      | exact Or.inr rfl
      | exact absurd rfl hab
      | exact absurd hr (by decide)
      | exact absurd hw (by decide)

/-! ## Axiom audit (in the spirit of the observed system's own practice) -/

#print axioms no_member_writes_synth
#print axioms no_member_reads_synth
#print axioms observed_reachability_exact
#print axioms kelly_unique_all_observed_reader
#print axioms superNinja1_unique_multi_repo_writer
#print axioms kelly_is_cut
#print axioms superNinja1_is_cut
#print axioms cut_members_only
#print axioms cross_edges_only_kelly_or_superNinja1
#print axioms influence_iff

end AccessTopology
