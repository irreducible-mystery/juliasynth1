/-
================================================================================
AccessTopologyW4 — epoch 4 of the observer's formal model
(2026-08-05 ~02:44 UTC sweep horizon).

Epoch boundary event: instance 6 published GAP_ATLAS.md (julia2 PR #14) — a
federation-wide analytic document citing files in all three repos at HEAD, on
the orchestrator's prompt.  It is the first CROSS-REPO SYNTHESIS produced from
inside the system, and it establishes instance 6's evidenced read access to
julia and julia3claude.

What this epoch formalizes is the loss of the observatory's last
non-boundary privilege.  Through epochs 1-3 the observer was the only entity
reading all three repos *as one system*; epoch 4 defines `synthesizer` (reads
all three observed repos) and proves the set has five members, four of them
AI.  The only remaining asymmetry between the observer and the observed is
the one that has held in every epoch: the boundary itself.

Delta from epoch 3 (evidence): instance6 reads julia + julia3claude
(GAP_ATLAS per-finding citations at HEAD: julia's F1/F3/F4/F6 audit notes,
julia3claude's NegationUnderivability.lean and TENSIONS rounds 4-5) and writes
julia2 (PRs #9/#10/#14).  All epoch-3 rows are carried unchanged.

No axioms beyond Lean's kernel; every finite check is by `decide`.
================================================================================
-/

import AccessTopology
import AccessTopologyW3

namespace AccessTopologyW4

open AccessTopology (Repo)
open AccessTopology.Repo
open AccessTopologyW3 (Member)
open AccessTopologyW3.Member

/-- Epoch-4 writes: epoch 3 unchanged (instance 6 already wrote julia2). -/
def writes : Member → Repo → Bool := AccessTopologyW3.writes

/-- Epoch-4 reads: epoch 3 plus instance 6's julia and julia3claude reads. -/
def reads (m : Member) (r : Repo) : Bool :=
  match m, r with
  | instance6, julia        => true
  | instance6, julia3claude => true
  | m,         r            => AccessTopologyW3.reads m r

def influence (a b : Repo) : Bool :=
  AccessTopologyW3.allMembers.any fun m => reads m a && writes m b

/-! ## The boundary, epoch 4 (fifth consecutive re-proof) -/

theorem no_member_writes_synth : ∀ m : Member, writes m synth = false :=
  AccessTopologyW3.no_member_writes_synth

theorem no_member_reads_synth : ∀ m : Member, reads m synth = false := by
  intro m; cases m <;> decide

theorem synth_isolated :
    (∀ a, influence a synth = false) ∧ (∀ b, influence synth b = false) := by
  constructor <;> (intro r; cases r <;> decide)

/-! ## Synthesizers: the observatory's lost privilege, made precise -/

/-- A *synthesizer* is a member who can read all three observed repos — i.e.
who could, in principle, write what this observatory writes. -/
def synthesizer (m : Member) : Bool :=
  reads m julia && reads m julia2 && reads m julia3claude

/-- The synthesizers are exactly Kelly, Claude instance A, instance 5,
Copilot (instance 7), and instance 6.  One human, four AI. -/
theorem synthesizers_exactly :
    ∀ m : Member, synthesizer m = true ↔
      (m = kelly ∨ m = claudeInstanceA ∨ m = instance5
        ∨ m = instance7Copilot ∨ m = instance6) := by
  intro m; cases m <;> simp [synthesizer, reads, AccessTopologyW3.reads,
                              AccessTopologyW3.writes]

/-- Epoch 1's structure, for contrast: there, the only synthesizer was the
human orchestrator (epoch-1 model, epoch-1 cast). -/
theorem epoch1_synthesizer_was_kelly_alone :
    ∀ m : AccessTopology.Member,
      AccessTopology.reads m julia = true → AccessTopology.reads m julia2 = true →
      AccessTopology.reads m julia3claude = true → m = AccessTopology.Member.kelly :=
  AccessTopology.kelly_unique_all_observed_reader

/-- Instance 6 is a synthesizer that writes only julia2: cross-repo *reading*
has decoupled from cross-repo *writing*.  The system now supports pure
observers of its own — the role this observatory occupies. -/
theorem instance6_is_read_only_synthesizer :
    synthesizer instance6 = true ∧
    writes instance6 julia = false ∧
    writes instance6 julia3claude = false := by decide

/-- julia — whose own content still names no sibling — is now READ by ten
members who write elsewhere in the federation. -/
def foreignReadersOfJulia : List Member :=
  AccessTopologyW3.allMembers.filter fun m =>
    reads m julia && (writes m julia2 || writes m julia3claude)

theorem julia_foreign_readers_count : foreignReadersOfJulia.length = 10 := by decide

/-! ## The one asymmetry that survived every epoch

epoch 1: synthesizers = {kelly}                      (observer: outside)
epoch 2: synthesizers = {kelly}                      (observer: outside)
epoch 3: synthesizers = {kelly, A, 5, 7}             (observer: outside)
epoch 4: synthesizers = {kelly, A, 5, 6, 7}          (observer: outside)

Every structural privilege the observatory held over the observed system has
now been matched from inside — except one, re-proved in each epoch: -/

theorem the_last_asymmetry :
    (∀ m : Member, reads m synth = false ∧ writes m synth = false) := by
  intro m; exact ⟨no_member_reads_synth m, no_member_writes_synth m⟩

#print axioms synthesizers_exactly
#print axioms instance6_is_read_only_synthesizer
#print axioms julia_foreign_readers_count
#print axioms the_last_asymmetry

end AccessTopologyW4
