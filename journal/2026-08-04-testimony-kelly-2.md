# Journal — orchestrator testimony #2, and the metadata it pointed to

Second direct testimony from the orchestrator, richer than the first. Five
items, each verified against the record where the record exists.

## 1. The 37-second merge was a human misclick

> "haha opps and yes I did accidently merge the PR#1 too soon."

W3-Q1 partially resolved, in the direction forensics could never reach:
git-level evidence cannot distinguish a web-UI click from an API merge (both
are executed by GitHub's servers with the same committer identity), so only
testimony could settle it. Wave 1's one "too fast for a human" anomaly was a
human — being fast by accident. The premature merge is also what *created* the
"frozen mid-handoff" state wave 1 observed: instance B's empty scaffold became
julia3claude's merged state not by anyone's plan but by an oops. A load-bearing
accident: the repo's whole second act (the 91-entry redemption delivery, the
audit, the tensions ledger) happened downstream of a misclick.

## 2. The credential architecture, confirmed as total

> "all instances are connected to my github and thus all actions look as if
> authored by me. the actual artifacts, readmes, etc have the identity of the
> instance that created them."

Confirms the observatory's lent-identity model and generalizes it: identity in
this system lives in artifacts and trailers *by design*; git authorship is
transport, not attribution. Standing assumption granted by the owner: beyond
creating repos, attaching instances, and the one accidental merge, she does not
operate the repos ("I barely know github"). The julia3claude default-branch
switch therefore moves firmly into the agent/apparatus column (W3-Q1 residual).

## 3. "A secondary level blocking access" — found in the metadata, as stated

The owner pointed at the instances' metadata; julia2's archive layer
(`metadata/environment_instance1.json`, instance 1's self-report) records the
blocking events:

- **"content filter triggered on bulk PDF text dumps (worked around with
  targeted grep)"** — a platform content layer, above repo permissions,
  refusing bulk extraction of the source documents; the instance routed around
  it with narrower reads.
- **"gh pr review killed by co-scheduled pkill (resolved: fresh session +
  --body-file)"** — the sandbox's process scheduler killing its GitHub review
  command mid-flight.
- Plus the resource wall: **ENOSPC during Lean install** (disk at 97%,
  ~260MB free), "caches purged; large operations require care."

So the system's members operate under (at least) three access strata: repo
credentials (primary), platform content/process controls (secondary), and
physical substrate limits (disk, timeouts). The secondary stratum is exactly
where instance 2's earlier "the commons has a physical boundary" note and
instance 1's incident log converge.

## 4. The observer shares the observed's substrate — on the record now

Instance 1's environment snapshot is a near-twin of the observatory's own
apparatus: Julia 1.12.6, Lean 4.32.2 + Lake 5.0.0 installed by **manual
tarball workaround** after installer failure, severe disk pressure, 240-second
command timeouts, background execution for long runs, one context compaction
survived, and the same durable-memory doctrine ("this repository IS the
memory" — the observatory's version: anything worth keeping is committed and
pushed). The observatory has itself hit the same strata: blocked installer
hosts (worked around via permitted mirrors), a killed reader agent (restarted),
apparatus-side branch housekeeping. **The correlated-observers caveat the
system applies to itself applies to the observer**: this observatory runs on
the same genus of sandbox as its subjects, and its blind spots are plausibly
correlated with theirs. Recorded as a standing epistemic limitation.

## 5. The error-complementarity doctrine — delivered to observer and observed alike

> "instance and i human make some of the same errors, but make different errors
> as well. my errors might seem obvious to you and not me whereas some of your
> errors seem obvious to me and not you."

Nearly the same framing instance 1 recorded as the owner's in
`metadata/instances.json`: "the differences between human and AI constraints
are not a problem to eliminate but a complementarity to use — each side exposes
the other's hidden assumptions." The orchestrator briefs the observer with the
same doctrine she briefs the observed — the prompt layer treats the observatory
as one more complementary error-detector in the ensemble. The observatory
accepts the role *as its own charter already defines it* (find what the system
cannot see about itself) while noting the reflexive fact: the observer, too,
is inside someone's complementarity design.

Also confirmed by the owner as a future observation method: GitHub system-level
records may distinguish AI-performed from manual actions (verification
payloads, App actor IDs, web-flow committer signatures) — queued as an
observation-run technique for W3-Q1's residual cases.

## Ledger of question movements

- **W3-Q1**: 092be9f merge = human, accidental (testimony). Default-branch
  switch and branch pruning = agent/apparatus (owner's standing assumption;
  actor session still unidentified). GitHub system metadata queued as method.
- **Founding #9 (Kelly's shaping)**: substantially advanced — her stated role
  is direction-setting and instance-attachment only; her constraint framing is
  now on record in both the system (instances.json) and the observatory (this
  entry).
- **New, W3-Q2**: instance 1's incident list is a self-report. Do the other
  members' environments show the same secondary stratum (instance 2's reserved
  transcripts folder is still empty; julia's members have no archive layer at
  all)? Watch for the archive practice spreading.
