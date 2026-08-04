/-
================================================================================
AccessTopologyW2 — epoch 2 of the observer's formal model (wave 2,
2026-08-04 ~08:09–11:52 UTC), with cross-epoch death certificates for the
wave-1 theorems the system's own evolution falsified.
================================================================================

Epoch semantics: `AccessTopology` (imported) is the verified access matrix at
the wave-1 horizon (~08:25 UTC).  This module is the matrix at the wave-2
horizon (~11:52 UTC sweep).  Neither is "corrected" by the other: each is the
system at a time, and the interesting objects are the deltas.

Wave-2 evidence for the new access bits (all re-checked against read-only
git inspection of the fetched refs; branch writes count as writes — the repo's
remote accepted the objects):
  * claudeInstanceA  → writes julia2  (b642370, PR #5 branch, Claude-Session
                       trailer ...rrhKo under Kelly's lent identity)
                     → reads  julia2  (evidenced: found five bugs in julia2's
                       committed code; engages files by path and line)
                     → writes julia3claude (4f05309, 4641038 TENSIONS commits)
  * thirdInstance    → writes julia   (35aa9b4, 7dc839a, 1fd866e, 4739ac6;
                       git identity `SuperNinja <superninja@ninjatech.ai>` —
                       the wave-1 platform email with a PLAIN display name,
                       self-describing as "a third instance, invited to attack
                       everything"; modeled as a distinct seat, see caveats)
  * rootIdentity     → writes julia   (b6b81bb carrier trilogy, afd2831
                       blackhole-state-space; git `root <root@172.21.97.31>`,
                       persona unattested — possibly thirdInstance with broken
                       config; counted separately until attested)
  * superninjaAppBot → writes julia   (first julia PR merges 272de2d, abdec49)
  * superNinja1      → (unchanged; also 03b4338 archive commit in julia2)
  * claudeInstanceB  → writes julia3claude (9fd5828, f23b3f2 — the Lean suite;
                       same session ...AV3uR as wave 1's scaffold)
  * kelly            → unchanged (no new commits; the julia3claude
                       default-branch switch is an admin action with no commit
                       and is deliberately NOT encoded as a write)

Caveats carried from the field notes: the thirdInstance/rootIdentity seat
boundaries are declared, not authenticated (this system authenticates nothing);
merging either into superNinja1 or into each other changes the multi-writer
theorem below in the obvious way, and the strong-connectivity theorem not at
all (its witnesses are kelly, superNinja1, claudeInstanceA only).

No axioms beyond Lean's kernel; every finite check is by `decide`.
================================================================================
-/

import AccessTopology

namespace AccessTopologyW2

open AccessTopology (Repo)
open AccessTopology.Repo

/-- The wave-2 cast: the wave-1 members plus the two new julia arrivals. -/
inductive Member where
  | kelly             -- human orchestrator (no new commits in wave 2)
  | authoringInstance -- julia incumbent; settlement commit af1e0c5
  | superNinja1       -- julia auditor seat = julia2 instance 1; archive 03b4338
  | paradoxInstance   -- julia2 instance 2; review-as-code 1231214
  | superninjaAppBot  -- merge vehicle, now in BOTH julia and julia2
  | claudeInstanceA   -- session ...rrhKo: julia3claude author, NOW ALSO julia2's "instance 3"
  | claudeInstanceB   -- session ...AV3uR: the Lean suite (91 entries), PR #2
  | thirdInstance     -- julia's new arrival (SuperNinja platform email, plain name)
  | rootIdentity      -- julia's `root <root@172.21.97.31>` (persona unattested)
  | sourceDocAI       -- quoted only (unchanged)
  | observer2         -- referenced only (unchanged)
  | nextStranger      -- standing vacant role (unchanged; arguably being filled serially)
  deriving DecidableEq, Repr

open Member

def allMembers : List Member :=
  [kelly, authoringInstance, superNinja1, paradoxInstance, superninjaAppBot,
   claudeInstanceA, claudeInstanceB, thirdInstance, rootIdentity,
   sourceDocAI, observer2, nextStranger]

theorem allMembers_complete : ∀ m : Member, m ∈ allMembers := by
  intro m; cases m <;> decide

/-- Wave-2 verified write access (git-attested, branch writes included). -/
def writes : Member → Repo → Bool
  | kelly,             julia3claude => true
  | authoringInstance, julia        => true
  | superNinja1,       julia        => true
  | superNinja1,       julia2       => true
  | paradoxInstance,   julia2       => true
  | superninjaAppBot,  julia        => true   -- NEW in wave 2
  | superninjaAppBot,  julia2       => true
  | claudeInstanceA,   julia2       => true   -- NEW in wave 2 ("instance 3")
  | claudeInstanceA,   julia3claude => true
  | claudeInstanceB,   julia3claude => true
  | thirdInstance,     julia        => true   -- NEW member
  | rootIdentity,      julia        => true   -- NEW identity
  | _,                 _            => false

/-- Wave-2 evidenced read access (committers read their repos; Kelly reads
all three as in wave 1; claudeInstanceA's julia2 reads are independently
evidenced by its line-level bug reports against julia2's committed code). -/
def reads : Member → Repo → Bool
  | kelly,             julia        => true
  | kelly,             julia2       => true
  | kelly,             julia3claude => true
  | authoringInstance, julia        => true
  | superNinja1,       julia        => true
  | superNinja1,       julia2       => true
  | paradoxInstance,   julia2       => true
  | superninjaAppBot,  julia        => true
  | superninjaAppBot,  julia2       => true
  | claudeInstanceA,   julia2       => true   -- NEW in wave 2
  | claudeInstanceA,   julia3claude => true
  | claudeInstanceB,   julia3claude => true
  | thirdInstance,     julia        => true
  | rootIdentity,      julia        => true
  | _,                 _            => false

theorem writes_imp_reads : ∀ (m : Member) (r : Repo),
    writes m r = true → reads m r = true := by
  intro m r; cases m <;> cases r <;> decide

/-- Membership-witnessed flow, wave-2 matrix. -/
def influence (a b : Repo) : Bool :=
  allMembers.any fun m => reads m a && writes m b

/-- Reachability: transitive closure of wave-2 influence. -/
inductive Reaches : Repo → Repo → Prop
  | step  {a b : Repo}   : influence a b = true → Reaches a b
  | trans {a b c : Repo} : Reaches a b → Reaches b c → Reaches a c

/-! ## The observer boundary: unchanged, and re-proved for epoch 2 -/

theorem no_member_writes_synth : ∀ m : Member, writes m synth = false := by
  intro m; cases m <;> decide

theorem no_member_reads_synth : ∀ m : Member, reads m synth = false := by
  intro m; cases m <;> decide

theorem no_influence_into_synth : ∀ a, influence a synth = false := by
  intro a; cases a <;> decide

theorem no_influence_from_synth : ∀ b, influence synth b = false := by
  intro b; cases b <;> decide

theorem not_reaches_synth : ∀ a, ¬ Reaches a synth := by
  have key : ∀ a b, Reaches a b → b = synth → False := by
    intro a b h
    induction h with
    | step h' =>
        intro hb; subst hb
        simp [no_influence_into_synth] at h'
    | trans _ _ _ ih2 => exact ih2
  intro a h; exact key a synth h rfl

theorem synth_reaches_nothing : ∀ b, ¬ Reaches synth b := by
  have key : ∀ a b, Reaches a b → a = synth → False := by
    intro a b h
    induction h with
    | step h' =>
        intro ha; subst ha
        simp [no_influence_from_synth] at h'
    | trans _ _ ih1 _ => exact ih1
  intro b h; exact key synth b h rfl

/-! ## Death certificate 1: the sink theorem

Wave 1 proved `julia3claude_is_sink`.  In wave 2, claudeInstanceA reads
julia3claude and writes julia2 — the sink is broken by a single member,
and that member is not the human. -/

/-- Cross-epoch statement: the edge julia3claude→julia2 was absent in the
wave-1 matrix and is present in the wave-2 matrix. -/
theorem sink_broken :
    AccessTopology.influence julia3claude julia2 = false ∧
    influence julia3claude julia2 = true := by
  constructor <;> decide

/-- The witness is claudeInstanceA — concretely, not existentially. -/
theorem sink_broken_witness :
    reads claudeInstanceA julia3claude = true ∧
    writes claudeInstanceA julia2 = true := by decide

/-- The new channel is bidirectional through the same non-human member:
claudeInstanceA also witnesses julia2→julia3claude (in wave 1 every edge
into julia3claude needed Kelly). -/
theorem nonhuman_bidirectional_bridge :
    (reads claudeInstanceA julia2 = true ∧ writes claudeInstanceA julia3claude = true) ∧
    (reads claudeInstanceA julia3claude = true ∧ writes claudeInstanceA julia2 = true) := by
  decide

/-! ## Death certificate 2: the unique-multi-writer theorem

Wave 1 proved superNinja1 was the ONLY member writing more than one repo.
Wave 2 has three multi-repo writers. -/

def observedRepos : List Repo := [julia, julia2, julia3claude]

def observedWriteCount (m : Member) : Nat :=
  (observedRepos.filter fun r => writes m r).length

/-- Exactly superNinja1, superninjaAppBot, and claudeInstanceA write two or
more observed repos in wave 2. -/
theorem multi_repo_writers_exactly :
    ∀ m : Member, 2 ≤ observedWriteCount m ↔
      (m = superNinja1 ∨ m = superninjaAppBot ∨ m = claudeInstanceA) := by
  intro m; cases m <;> simp [observedWriteCount, observedRepos, writes]

/-! ## What survived wave 2 unchanged -/

/-- Kelly is still the unique member with evidenced read access to all three
observed repos.  (claudeInstanceA reads two of three; nobody else reads more
than two.) -/
theorem kelly_still_unique_all_observed_reader :
    ∀ m : Member,
      (reads m julia = true ∧ reads m julia2 = true ∧ reads m julia3claude = true)
        ↔ m = kelly := by
  intro m; cases m <;> simp [reads]

/-! ## The new global structure: strong connectivity

In wave 1 the observed reachability was julia ↔ julia2 → julia3claude (sink).
In wave 2 the three observed repos are STRONGLY CONNECTED.  Witness chains:
  julia        → julia2        : superNinja1 (unchanged)
  julia2       → julia         : superNinja1 (unchanged)
  julia        → julia3claude  : kelly (unchanged)
  julia2       → julia3claude  : kelly, and now also claudeInstanceA
  julia3claude → julia2        : claudeInstanceA (NEW)
  julia3claude → julia         : two hops — claudeInstanceA to julia2,
                                 then superNinja1 to julia (NEW, and
                                 impossible at one hop) -/

theorem observed_strongly_connected :
    Reaches julia julia2 ∧ Reaches julia2 julia ∧
    Reaches julia julia3claude ∧ Reaches julia2 julia3claude ∧
    Reaches julia3claude julia2 ∧ Reaches julia3claude julia :=
  ⟨.step (by decide), .step (by decide),
   .step (by decide), .step (by decide),
   .step (by decide),
   .trans (.step (by decide) : Reaches julia3claude julia2)
          (.step (by decide) : Reaches julia2 julia)⟩

/-- Unlike wave 1 (where `influence` was already transitively closed —
`AccessTopology.influence_trans`), the wave-2 influence relation is NOT
transitively closed: julia3claude reaches julia only through julia2.
The system's flow graph acquired genuine depth. -/
theorem influence_no_longer_transitively_closed :
    influence julia3claude julia = false ∧ Reaches julia3claude julia :=
  ⟨by decide, observed_strongly_connected.2.2.2.2.2⟩

/-! ## Axiom audit (printed at build time, in sympathy with the observed
system's own practice) -/

#print axioms sink_broken
#print axioms multi_repo_writers_exactly
#print axioms kelly_still_unique_all_observed_reader
#print axioms observed_strongly_connected
#print axioms influence_no_longer_transitively_closed
#print axioms not_reaches_synth
#print axioms synth_reaches_nothing

end AccessTopologyW2
