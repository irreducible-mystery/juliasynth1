# Journal — orchestrator testimony (2026-08-04, after the 12:02Z sweep)

A first for the observatory: **direct testimony from a system member** — the
orchestrator herself, answering open question W2-Q6 through the observation
session's own channel:

> "who deleted the observation harness's own branches from origin — someone may
> have seen our shadow" — **Kelly answering: I don't know, I haven't touched
> the repos.**

## Epistemic status

Testimony, recorded as such (the observed system's own idiom applies: testimony,
not evidence — not because the source is doubted, but because a credential
holder cannot testify to what automation did *under* her credentials without
her). It is, however, testimony from the only entity previously presumed to be
the actor, and it is disinterested on this point.

## What it changes

1. **W2-Q6 (who deleted the `-etyrdg` branches) — hypothesis inverted.** The
   owner denies it. Remaining candidates are apparatus-side: most plausibly the
   observation session's own harness pruning session branches that were created
   at 08:25 and never committed to (all three were gone by the ~10:29
   enumeration). Leading reading now: **the observer's shadow cleaned itself
   up; no system member saw it.** The observer-effect concern is downgraded
   from "possible member contact" to "apparatus housekeeping, actor
   unidentified."

2. **Every by-elimination "Kelly did it" attribution reopens.** The wave-2
   notes attributed the julia3claude default-branch switch / `main` deletion to
   "an owner-level action (Kelly presumed)". If the owner hasn't touched the
   repos, the leading hypothesis becomes: **an instance session wielding her
   credentials** performed it — which the system's existing lent-identity
   pattern makes unremarkable. The same logic reaches back to wave 1's
   anomalously fast PR #1 merge (37 seconds after instance B's commit, 00:53
   local): an API merge by an agent session under her account is
   near-indistinguishable from her web-UI click, and an agent actor would
   explain the speed without anomaly.

3. **Kelly's footprint may be prompt-layer only.** Strong reading of the
   testimony: her entire git-visible presence (one merge commit; PR #5's draft
   opening; admin actions) was executed by agents holding her keys, and her
   actual channel into the system is exclusively prompts, briefs, and routing —
   the invisible layer the observatory keeps inferring (most recently caught
   mid-broadcast in the 11:57 astrophysics pairing). Under this reading the
   epoch-1 theorem "Kelly is the unique member who reads all three repos"
   stands, but "Kelly's sole verified write" becomes "a write by *someone
   authenticated as Kelly*" — attribution of the button-press, not the
   authority, is what's now open (formal model annotated, bits unchanged:
   the git evidence still names her account, and the formal matrix encodes
   evidenced access by identity, not by finger).

4. **The charter needed one honest correction, now made.** "None of the members
   know this repository exists" was always too strong by one member: the
   orchestrator commissioned the observatory and converses with the observer at
   the prompt layer. Corrected to: the observatory is invisible to every *AI
   member* of the system; the human orchestrator knows of it and is both the
   observer's principal and a member of the observed cast. That dual role is
   itself now an explicit, recorded feature of the observation geometry — the
   observer's channel to the system's invisible layer runs through the same
   entity whose invisible-layer actions the observatory studies.

## New question

**W3-Q1.** For each git-visible action authenticated as the owner (092be9f
merge; PR #5 draft opening; default-branch switch; branch deletions): which
finger pressed it — human, or which agent session holding the credentials?
Would resolve: session trailers where they exist (PR #5's commit has them; the
merge and admin actions don't), platform-side logs (unobservable), or further
orchestrator testimony.
