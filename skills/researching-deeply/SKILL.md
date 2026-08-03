---
name: researching-deeply
description: Use when choosing a library, framework, model, or stack, asking "what is the current best" or "is this still true", or verifying any claim before relying on it: a factual question that affects a decision, unfamiliar territory, prior art, an assertion you are about to build on.
---

# Researching Deeply

one source = a rumor. a decision rests on triangulated, dated, primary-source evidence, with a named adversary who tried to break each load-bearing claim and failed.

## Step 0: Use the native engine if present

harness exposes a deep-research tool or skill -> prefer it: already fans out, fetches, verifies. drive it, then apply the verification and synthesis discipline below to its output. hand-roll the team only when no native engine exists. library/API questions: context7 MCP (live docs) or WebFetch on official docs first. deps law: before adding a package or reimplementing, read the EXISTING deps' docs and types; never assume a library lacks a capability unchecked. established maintained lib beats a reimplementation when it cuts net complexity.

## Fan out by angle, in parallel

research team, one teammate per angle (dmj:dispatching-parallel-teams; every spawn the judgement tier, user law). each owns one angle, cites **primary sources with publication dates**:

| Angle | Primary source |
|-------|----------------|
| Official truth | vendor docs, specs, standards, RFCs |
| Ground truth | source code, release notes, changelogs |
| Failure truth | issue trackers, CVEs, post-mortems |
| Measured truth | independent benchmarks, reproducible tests |
| Formal truth | papers, standards bodies |
| Lived truth | practitioner reports, forums (corroborate, never alone) |

never decide on a single source or a single teammate.

## Adversarial verification pass

every load-bearing claim: a **fresh-context teammate tries to refute it** before you rely on it. never same-context self-review; the author is blind to their own gaps. claim survives only if refutation fails against a primary source. refutation succeeds -> drop or qualify the claim.

## Recency discipline

prefer the newest authoritative source. state the **as-of date of every fact**. flag anything older than the domain moves: fast-moving framework in months, stable protocol in years. "true once" is not "true now". re-verify at invocation.

## Synthesis: separate the three

sort every finding into one bin, never blur:
- **established fact**: primary-sourced, survived refutation.
- **current consensus**: widely held, may shift.
- **open question**: contested or unknown.

## Output: decision-ready digest

- the answer, **confidence level** per claim.
- citations (source + date) on every load-bearing statement.
- **what would change the conclusion**: the trip-wire to re-open.
- established fact vs consensus vs open question, kept distinct.

**Headless:** fully autonomous, no user gate. spawn, verify, synthesize, land the digest in the final report. a claim that cannot be verified ships labeled "unverified", never silently.

Handoff: the digest -> dmj:brainstorming or dmj:writing-plans as the evidence base for the decision.
