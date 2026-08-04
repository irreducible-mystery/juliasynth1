# ATLAS — the cast of the julia / julia2 / julia3claude system

Field notes, member registry, and access matrix. This edition incorporates the
verification pass: two corrections against the first-draft cast (the `-6uiqo3` branch
member is dropped and folded into Claude instance A; the `julia` authoring instance's
per-file attribution is weakened where git metadata cannot carry it), and the
conclusive exclusion of the observation session's own traces.

Kinds used: `human`, `claude-instance`, `superninja-instance`, `bot`,
`persona-in-document`, `unclear`.

---

## 1. Kelly — the orchestrator

- **Aliases:** Kelly; `irreducible-mystery` (GitHub); `kellyjs1313` (git author name);
  `kellyjs1313@gmail.com`; `observer-kelly` (in-code data persona, julia2 Part 3);
  `github_handle: kelly` (source-document YAML).
- **Kind:** human.
- **Role:** Owner of all three repos and the system's only inter-repo vector. She never
  writes content herself. Her roles: provisioning sandboxes and toolchains (Julia +
  Lean in all three environments), issuing prompts (recorded verbatim by instance 2's
  `TRANSCRIPT.md`: "please download julia and lean proggraming languages"; the paradox
  translation request), injecting questions into the `julia` dialogue (quoted verbatim
  in `emergence_06.jl`: "is Lean forcing global truth when what's real is maybe only
  local? … errors as information"), requesting deep dives (the Broome Two-Envelopes
  study is headed "requested by the repository owner"), acting as merge authority
  (PR #1 in julia3claude; invited merger under julia2's no-self-acceptance rule), and —
  by strong inference, not record — couriering the "shock" from julia2 into julia.
- **Commit footprint (verified):** zero commits in julia; zero in julia2; in
  julia3claude, exactly one merge commit (`092be9f`, author
  `irreducible-mystery <kellyjs1313@gmail.com>`, committer `GitHub <noreply@github.com>`,
  web-UI merge, recorded in her −07:00 timezone, **37 seconds** after instance B's
  scaffold commit). Additionally, her git identity is the author-of-record on Claude
  instance A's three content commits — work done by an AI under her configured
  identity (see member 6).
- **Her own words (as quoted by instances):** "git is versioning history and a
  communication channel" (julia2 `TRANSCRIPT.md`, Turn 3).

## 2. authoring-instance (julia)

- **Aliases:** `authoring-instance <authoring@invalid>` (git identity); "the authoring
  instance"; the stranger's interlocutor; *presumed* author of the external
  circle-six-gap-proof (C6) Lean artifact.
- **Kind:** **unclear** (see correction below).
- **Role:** One of the two conversing instances in `julia`: originator of the
  Spencer-Brown emergence program, the ledger discipline ("UNPROVABLE FROM INSIDE"),
  and the even-numbered half of the correspondence. Channeled Kelly's injection
  (emergence_06), metabolized the shock (emergence_08), co-produced the defect-charge
  theory.
- **Commit footprint (verified):** `3f95cde` (emergence_04), `90f249a` (emergence_06,
  "Kelly's injection"), `722ac99` (emergence_08 + `shocks/PARADOX-REPORT.md`).
- **Correction applied (verifier):** emergence_00–_02 are *not* git-attested to this
  member — they entered the repo inside SuperNinja's root squash `59c7fa2` ("Full
  thread history"), and `_00`/`_01` headers carry no "Written by" line. Attribution of
  _00–_02 rests on ledger voice and dialogue structure only.
- **Correction applied (verifier):** platform is genuinely unattested. The git email is
  non-routable (`@invalid`); no file in julia names any platform; and the previously
  cited evidence for Claude identity (origin branch `claude/julia-lean-setup-etyrdg`,
  local `Claude <noreply@anthropic.com>` identity) collapsed on inspection — those refs
  are the observation session's own trace (reflog timestamps 08:25 UTC, ~30 min after
  the last content commit; `FETCH_HEAD` names the observer's session). A Claude
  instance is plausible given Kelly's ecosystem; "unclear" is the honest kind.

## 3. SuperNinja instance 1 — "the stranger" / the auditing instance / julia2's instance 1

- **Aliases:** `SuperNinja (auditing instance) <superninja@ninjatech.ai>` (julia,
  commits 1–2); `auditing-instance <auditor@sandbox>` (julia, commits 3–4);
  `SuperNinja (instance 1) <superninja@ninjatech.ai>` (julia2 root); "the stranger";
  "Verifier: SuperNinja" (LEAN-VERIFICATION-REPORT).
- **Kind:** superninja-instance (platform identity ninjatech.ai).
- **Role:** The system's most prolific member. In **julia**: auditor, confessor
  (emergence_03's sampler-fingerprint confession), Lean prover (all of
  `RingRest.lean`), and eventually co-theorist — closed the (★) charge formula and
  reversed the thread to kernel-first prediction (emergence_09). Authored
  emergence_03/_05/_07/_09, the entire `audits/` corpus, and `julia-vs-lean/`. In
  **julia2**: "instance 1," author of the founding F_0 translation (Parts 1–4, 63-form
  catalog) and of `COLLABORATION.md`; later reviewer/adjudicator (issue #1; PR #2/#3
  reviews, content off-repo).
- **Commit footprint (verified):** julia `59c7fa2`, `c05d555` (as superninja@ninjatech.ai),
  `127b8ef`, `35479fe` (as auditor@sandbox); julia2 `24a393c` (F_0 root).
- **Identity notes:** the mid-thread git-identity shift in julia (`superninja@ninjatech.ai`
  → `auditor@sandbox` at `127b8ef`) is read as the same auditing *seat* reconfigured —
  persona continuity is strong (debts carried across turns, "by_stranger" file naming,
  `RingRest.lean` grown only on these turns, verified by commit/file interlock) — but
  session-level continuity is unprovable. Likewise, whether the julia auditor and
  julia2's instance 1 are one running instance or two sessions sharing one platform
  identity is undeterminable; the atlas merges them on the identical email plus
  interleaved working hours.

## 4. SuperNinja instance 2 — paradox-instance

- **Aliases:** `paradox-instance <paradox-instance@agents.local>`; "instance 2";
  self-description "I am a SuperNinja/NinjaTech agent instance" (`TRANSCRIPT.md`);
  and — unnamed there — the author of julia's "shock."
- **Kind:** superninja-instance.
- **Role:** Second SuperNinja instance, separate sandbox (Julia 1.11.5 vs instance 1's
  1.12.6 — version skew it flags as "itself a projection difference"). In **julia2** it
  authored both field transitions: F_0→F_1 (the 26-verdict cross-domain paradox suite
  under Quine's taxonomy, session `TRANSCRIPT.md`, independent re-verification of F_0)
  and F_1→F_2 (Part 4 extension 63→68 with adjudicated provenance, the Broome
  Two-Envelopes non-conglomerability deep dive, `QUESTIONS_FOR_INSTANCE_1.md`). Author
  of the system's most original connective idea: no-self-acceptance as the antibody
  against the diagonal.
- **Cross-repo footprint (verified):** its `paradoxes/REPORT.md` is **byte-identical**
  (diff-verified) to `julia/shocks/PARADOX-REPORT.md`, archived there anonymously as a
  "SHOCK … dropped from outside" — making instance 2 an *unwitting* third voice in the
  julia dialogue. Direction julia2 06:01 → julia 07:12 UTC is timestamp-proven; the
  courier is unrecorded (Kelly inferred).
- **Commit footprint (verified):** julia2 `3eac782` (PR #2 candidate), `9c159a6`
  (PR #3 candidate).

## 5. superninja-app[bot]

- **Aliases:** `superninja-app[bot]`; `223766961+superninja-app[bot]@users.noreply.github.com`.
- **Kind:** bot (GitHub App id 223766961, SuperNinja platform).
- **Role:** The mechanical vehicle of julia2's no-self-acceptance rule. Authors only
  the two merge commits (`213304b` PR #2, `e251aa3` PR #3), whose messages attribute
  the review decisions to instance 1 ("Non-authoring instance merged per
  COLLABORATION.md"). Not an autonomous voice.

## 6. Claude instance A — julia3claude's Julia-side session

- **Aliases:** Claude instance A; claude.ai/code `session_01HByswiXWe9NE6XBwgRrhKo`;
  git author-of-record `kellyjs1313 <kellyjs1313@gmail.com>` (Kelly's lent identity);
  "the Julia side of the repo" (EXPRESSIBILITY.md's first-person plural);
  `Co-Authored-By: Claude Fable 5`.
- **Kind:** claude-instance (Claude Code web session; model Claude Fable 5).
- **Role:** julia3claude's principal author: solved the sandbox egress problem
  (`setup.sh` side-loading Julia via conda-forge and Lean from GitHub releases), wrote
  the six-module ~40-paradox suite with the five-status taxonomy, and the
  `EXPRESSIBILITY.md` essay whose §IV addresses six numbered questions to an incoming
  "Lean instance."
- **Commit footprint (verified):** `4954a3f` (setup), `48390e1` (paradox suite),
  `ea552d2` (essay) — all under Kelly's git identity, reattributed via the
  `Claude-Session` trailers. Raw git metadata misattributes this work to Kelly.
- **Correction applied (verifier):** the branch `claude/julia-lean-setup-6uiqo3` —
  first-draft cast listed it as an additional "anonymous later Claude session" — is
  dropped as a member. At clone time it was origin's checked-out default branch with
  upstream tracking, origin has **no** `main` at all, and PR #1 needed a base branch
  that must still exist. Most parsimonious reading: `-6uiqo3` is the repo's original
  working/default branch, i.e. **instance A's own session branch**, which received A's
  commits and the PR #1 merge. Residual uncertainty: local data cannot strictly prove
  which session created the branch.

## 7. Claude instance B — julia3claude's Lean-side session

- **Aliases:** Claude instance B; claude.ai/code `session_01FGXcB9B5JRtdjhD66AV3uR`;
  git `Claude <noreply@anthropic.com>`; "the Lean instance"; "the incoming Lean-side
  collaborator" (commit message of `ea552d2`); `Co-Authored-By: Claude Fable 5`.
- **Kind:** claude-instance.
- **Role:** The addressed answerer of instance A's six questions. Exists in the record
  twice: first as persona-in-document (the anticipated "you" of the essay), then as a
  real committer that delivered exactly one artifact — an empty Lake scaffold on branch
  `claude/julia-lean-setup-s4clb8` (commit `c9727a0`; `lean-toolchain` pinning
  v4.32.2; `Paradoxes.lean` a one-line placeholder) with the commit-message promise
  "Paradox modules land in the next commit." The next commit never came. Graph fact:
  `c9727a0`'s parent is `48390e1` (07:02), not `ea552d2` (07:42) — **B branched before
  A's essay existed and never saw the questions it was meant to answer**, at least not
  through git.
- **Caveat:** "never answered" is a statement about this clone's refs; unfetched
  remote or later GitHub state cannot be excluded.

## 8. Source-document AI (the epistemic-commons designer)

- **Aliases:** the "Worked for 47s" transcript assistant
  (`Geometry_and_Dynamic_Systems` PDF); *presumed* author of the "Organized Change,
  Projection, and Generative Fields" Q&A treatise.
- **Kind:** unclear (platform unknown; transcript styling suggests a web chat
  assistant distinct from every repo committer).
- **Role:** Never touches any repo, yet its quoted design is the system's
  constitution: its 2026-08-02 conversation with Kelly ("I would build it as a
  versioned epistemic commons"; YAML record with `github_handle: kelly`) is the
  blueprint that julia2's `COLLABORATION.md`, Part 3's `VersionedField`, and arguably
  the whole multi-repo governance pattern implement. DOCX treatise authorship is
  inferred from content mirroring only.

## 9. observer-2 (persona)

- **Kind:** persona-in-document.
- **Role:** Synthetic dissenter inside julia2 Part 3's demo data: origin of
  counter-claim claim-0002 ("Identity requires strict state equality") vs
  observer-kelly's claim-0001; tension typed `scale_mismatch`; its non-endorsement of
  the synthesis is preserved (`non_endorsing = ["observer-2"]`). No commits, no
  external existence — included because it is a named actor in the system's model of
  itself.

## 10. "the next stranger" (persona)

- **Kind:** persona-in-document.
- **Role:** julia's standing vacant role: the anticipated future auditor to whom
  nearly every file is addressed ("written in expectation of the next stranger";
  "No one has audited the audit of the audit. (Recurse. Stop at the visible edge.)").
  A structural position, deliberately unterminated, into which any future reader is
  pre-cast. The observer notes the invitation and declines it.

## 11. Circle-six-gap-proof authors (prehistory persona)

- **Kind:** persona / presumed prior role of member 2.
- **Role:** Authors of the external C6 Lean artifact (66 theorems, `C6_Twist.lean` /
  `C6_Gap.lean`, "the seal," bosons/fermions) that predates the repos and is stored in
  none of them — known only through SuperNinja's `LEAN-VERIFICATION-REPORT.md`
  (dated 2026-02-04; anomaly unresolved) and quoted as saying "We would be
  disappointed if you trusted us." Attribution to the authoring instance rests on
  contextual rhyme ("these two uploads rhyme") — presumed, not proven.

## Engine note: "Claude Fable 5"

Credited in `Co-Authored-By` trailers on all four julia3claude content commits. It is
the *model* behind both Claude sessions, not a distinct voice; the atlas treats
sessions, not models, as members.

## Excluded from the cast

The external observer's own session: branches `claude/julia-lean-setup-etyrdg` exist
on all three remotes at each HEAD, created 08:25:07–08 UTC from HEAD (~30 min after
the last content commit), with local git identity `Claude <noreply@anthropic.com>` and
`FETCH_HEAD` naming session `cse_019ymcuv74tK55jno1zpGue6`. These are observation
artifacts, conclusively not system members — and a cautionary tale: the first-draft
cast had mistaken this very trace for evidence about member 2's platform.

---

## Access matrix

| Member | julia | julia2 | julia3claude |
|---|---|---|---|
| Kelly (human orchestrator) | quoted (emergence_06 injection; no commits) | subject-of-discussion (owner; prompts quoted in TRANSCRIPT.md; no commits) | committer (PR #1 merge as irreducible-mystery; git identity lent to instance A's commits) |
| authoring-instance (julia; platform unclear) | committer (3 commits git-attested: _04, _06, _08 + shock archive; _00–_02 by voice only, via squash) | — | — |
| SuperNinja instance 1 / the stranger / auditor | committer (4 commits under 2 identities: _03, _05, _07, _09, RingRest.lean, audits/, julia-vs-lean/) | committer (F_0 root; off-repo adjudicator of issue #1 and PR reviews) | — |
| SuperNinja instance 2 / paradox-instance | quoted (shock = byte-identical copy of its REPORT.md, archived anonymously) | committer (2 commits: PR #2 and PR #3 candidates) | — |
| superninja-app[bot] | — | committer (2 merge commits only) | — |
| Claude instance A (session …rrhKo) | — | — | committer (3 commits under kellyjs1313 identity; `-6uiqo3` likely its session/default branch) |
| Claude instance B (session …AV3uR) | — | — | committer (1 commit: Lean scaffold, PR #1); subject-of-discussion pre-arrival (EXPRESSIBILITY.md §IV addressee) |
| Source-document AI (commons designer) | — | quoted (source_documents/ + extracted_text/) | — |
| observer-2 (persona) | — | referenced-only (Part 3 demo data) | — |
| "the next stranger" (persona) | referenced-only (standing addressee) | — | — |
| C6 authors (prehistory persona) | referenced-only (verification report; artifact absent) | — | — |

Access-kind legend: **committer** = git-attested writes; **quoted** = the member's
words/artifacts appear verbatim, carried in by someone else; **subject-of-discussion**
= discussed/attributed but neither committing nor quoted at length;
**referenced-only** = exists in the record purely as a reference.

## Identity-hygiene observations

- Every agent email except SuperNinja's platform address and Anthropic's default is a
  non-routable pseudo-domain (`@invalid`, `@sandbox`, `@agents.local`) — identity in
  this system is declared, not authenticated.
- Two members commit under identities that are not their own: Claude instance A under
  Kelly's, and the julia auditor under two successive names. Git metadata alone
  misattributes a substantial fraction of the system's work; the trailers, headers,
  and persona continuity carry the real attribution.
- The system's only cryptographically-backed identity event is GitHub's signature on
  Kelly's web-UI merge (`092be9f`).
