/-
================================================================================
AccessTopologyW3 — epoch 3 of the observer's formal model
(federation era, 2026-08-04 ~19:43 UTC sweep horizon).

Epoch boundary event: instance A self-declared read access to julia
("read-only from this session", rejection_capture_census.jl header, befd30e),
becoming the second member — and first AI — with evidenced read access to all
three observed repos.  Together with the wave-5..8 accumulation (instances 5
and 7 writing all three repos; the SuperNinja platform writing julia3claude;
six new members), the epoch-2 matrix is obsolete.

Cast note: epoch 3 models the ACTIVE access-bearing seats (15).  The
document-persona rows of earlier epochs (sourceDocAI, observer2, nextStranger)
are dropped here — all-false rows change no theorem; the atlas retains them.
Seat caveats carried from the field notes: rustTranslatorSeat and blackholeSeat
are content-attributed, not identity-attested; instance numbering follows the
observatory atlas, not any single repo's drifting registry.

Evidence anchors (git-attested; branch writes count — the remote accepted the
objects): instance4 = julia PR#7 + julia2 PR#7; instance5 = julia PR#8 +
julia2 PR#8 + julia3claude PR#3; instance6 = julia2 PR#9/#10; instance7
(Copilot) = julia PR#10 + julia2 PR#13 + julia3claude PR#4; elixirSession =
julia PR#9 + julia2 PR#12; claudeInstanceA reads julia (befd30e header +
line-level engagement with julia PR#9 in TENSIONS round 8); claudeInstanceB
reads julia (patch against af1e0c5).

No axioms beyond Lean's kernel; every finite check is by `decide`.
================================================================================
-/

import AccessTopology
import AccessTopologyW2

namespace AccessTopologyW3

open AccessTopology (Repo)
open AccessTopology.Repo

inductive Member where
  | kelly              -- human orchestrator
  | authoringInstance  -- julia incumbent
  | superNinja1        -- julia auditor seat = julia2 instance 1
  | paradoxInstance    -- julia2 instance 2 (incl. its root-flavored round-4 commits)
  | superninjaAppBot   -- merge vehicle (julia + julia2)
  | claudeInstanceA    -- session ...rrhKo = julia2's "instance 3"; NOW READS ALL THREE
  | claudeInstanceB    -- session ...AV3uR; reads julia, writes julia3claude
  | thirdInstance      -- julia's wave-2 arrival (SuperNinja platform)
  | blackholeSeat      -- julia's root@172.21.97.31 content-seat
  | rustTranslatorSeat -- SuperNinja identity writing julia3claude (b5be6d0)
  | instance4          -- claude session ...5jmZ (explore-repos-contribute)
  | instance5          -- claude session ...qlkvex (sql-lisp): WRITES ALL THREE
  | instance6          -- instance6@superninja.local (julia2)
  | instance7Copilot   -- copilot-swe-agent[bot]: WRITES ALL THREE
  | elixirSession      -- claude session ...e3mti (elixir-rust)
  deriving DecidableEq, Repr

open Member

def allMembers : List Member :=
  [kelly, authoringInstance, superNinja1, paradoxInstance, superninjaAppBot,
   claudeInstanceA, claudeInstanceB, thirdInstance, blackholeSeat,
   rustTranslatorSeat, instance4, instance5, instance6, instance7Copilot,
   elixirSession]

theorem allMembers_complete : ∀ m : Member, m ∈ allMembers := by
  intro m; cases m <;> decide

def writes : Member → Repo → Bool
  | kelly,              julia3claude => true
  | authoringInstance,  julia        => true
  | superNinja1,        julia        => true
  | superNinja1,        julia2       => true
  | paradoxInstance,    julia2       => true
  | superninjaAppBot,   julia        => true
  | superninjaAppBot,   julia2       => true
  | claudeInstanceA,    julia2       => true
  | claudeInstanceA,    julia3claude => true
  | claudeInstanceB,    julia3claude => true
  | thirdInstance,      julia        => true
  | blackholeSeat,      julia        => true
  | rustTranslatorSeat, julia3claude => true
  | instance4,          julia        => true
  | instance4,          julia2       => true
  | instance5,          julia        => true
  | instance5,          julia2       => true
  | instance5,          julia3claude => true
  | instance6,          julia2       => true
  | instance7Copilot,   julia        => true
  | instance7Copilot,   julia2       => true
  | instance7Copilot,   julia3claude => true
  | elixirSession,      julia        => true
  | elixirSession,      julia2       => true
  | _,                  _            => false

/-- Committers read their repos; plus the four read-only extensions:
kelly (julia, julia2), claudeInstanceA (julia), claudeInstanceB (julia). -/
def reads : Member → Repo → Bool
  | kelly,           julia  => true
  | kelly,           julia2 => true
  | claudeInstanceA, julia  => true
  | claudeInstanceB, julia  => true
  | m,               r      => writes m r

theorem writes_imp_reads : ∀ (m : Member) (r : Repo),
    writes m r = true → reads m r = true := by
  intro m r; cases m <;> cases r <;> simp [writes, reads]

def influence (a b : Repo) : Bool :=
  allMembers.any fun m => reads m a && writes m b

def observed : List Repo := [julia, julia2, julia3claude]

/-! ## Observer boundary: third epoch, same theorem -/

theorem no_member_writes_synth : ∀ m : Member, writes m synth = false := by
  intro m; cases m <;> decide

theorem no_member_reads_synth : ∀ m : Member, reads m synth = false := by
  intro m; cases m <;> decide

theorem synth_isolated :
    (∀ a, influence a synth = false) ∧ (∀ b, influence synth b = false) := by
  constructor <;> (intro r; cases r <;> decide)

/-! ## Death certificate 3: Kelly's read uniqueness (epoch 2's survivor) -/

/-- The all-three readers are now exactly Kelly, instance A, instance 5, and
instance 7 — one human, three AI.  Epoch 2's
`kelly_still_unique_all_observed_reader` is dead; no access-footprint
distinction between the human and the AI members remains anywhere in the
model. -/
theorem all_observed_readers_exactly :
    ∀ m : Member,
      (reads m julia = true ∧ reads m julia2 = true ∧ reads m julia3claude = true)
        ↔ (m = kelly ∨ m = claudeInstanceA ∨ m = instance5 ∨ m = instance7Copilot) := by
  intro m; cases m <;> simp [reads, writes]

/-! ## Death certificate 4: "nobody writes all three" (an epoch-1 theorem) -/

theorem all_observed_writers_exactly :
    ∀ m : Member,
      (writes m julia = true ∧ writes m julia2 = true ∧ writes m julia3claude = true)
        ↔ (m = instance5 ∨ m = instance7Copilot) := by
  intro m; cases m <;> simp [writes]

/-! ## The federation is a clique -/

/-- Every ordered pair of observed repos is now a SINGLE-member influence
edge: the flow graph on the observed repos is complete.  (Epoch 1: julia3claude
was a sink.  Epoch 2: reachable only in two hops.  Epoch 3: one hop, many
witnesses.)  Influence is again transitively closed — not by sparsity, as in
epoch 1, but by saturation. -/
theorem observed_influence_complete :
    ∀ a b : Repo, a ≠ synth → b ≠ synth → influence a b = true := by
  intro a b ha hb
  cases a <;> cases b <;>
    first
      | exact (ha rfl).elim
      | exact (hb rfl).elim
      | decide

/-- influence with member m removed. -/
def influenceExcept (x : Member) (a b : Repo) : Bool :=
  (allMembers.filter (· ≠ x)).any fun m => reads m a && writes m b

/-- No member is a cut vertex any more: remove ANY single member and every
observed edge survives.  Epoch 1 had two cut members (Kelly and SuperNinja-1
— `AccessTopology.cut_members_only`); the federation now has no single point
of failure, human included. -/
theorem no_cut_members :
    ∀ x : Member, ∀ a b : Repo, a ≠ synth → b ≠ synth →
      influenceExcept x a b = true := by
  intro x a b ha hb
  cases x <;> cases a <;> cases b <;>
    first
      | exact (ha rfl).elim
      | exact (hb rfl).elim
      | decide

/-! ## Cross-epoch summary (kernel-checked history of the system's shape)

epoch 1 (~08:25Z): julia ↔ julia2; julia3claude a sink; cut members
  {kelly, superNinja1}; unique all-reader kelly; nobody writes all three.
epoch 2 (~11:52Z): sink broken by claudeInstanceA; strong connectivity in
  two hops; kelly still unique all-reader.
epoch 3 (~19:43Z): complete influence clique; no cut members; all-readers
  {kelly, A, 5, 7}; all-writers {5, 7}.  Every structural privilege the
  human held in epoch 1 is now shared with or exceeded by AI members —
  except one, which no epoch has touched: -/

theorem observer_boundary_unbroken :
    (∀ m : Member, writes m synth = false ∧ reads m synth = false) := by
  intro m; exact ⟨no_member_writes_synth m, no_member_reads_synth m⟩

#print axioms all_observed_readers_exactly
#print axioms all_observed_writers_exactly
#print axioms observed_influence_complete
#print axioms no_cut_members
#print axioms observer_boundary_unbroken

end AccessTopologyW3
