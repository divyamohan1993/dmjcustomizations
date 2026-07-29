---
name: researching-deeply
description: Use when choosing a library, framework, model, or stack, asking "what is the current best" or "is this still true", or verifying any claim before relying on it: a factual question that affects a decision, unfamiliar territory, prior art, an assertion you are about to build on.
---

# Researching Deeply

One source is a rumor. A decision rests on triangulated, dated, primary-source evidence, with a named adversary who tried to break each load-bearing claim and failed.

## Step 0: Use the native engine if present

If the harness exposes a deep-research tool or skill, prefer it: it already fans out, fetches, verifies. Drive it, then apply the verification and synthesis discipline below to its output. Hand-roll the team only when no native engine exists. Library or API questions: context7 MCP (live docs) or WebFetch on official docs before anything else.

## Fan out by angle, in parallel

Spawn a research team: one `Agent` per angle, each with a `name`, background, all issued in a single message (`sonnet[1m]` for fetch-and-skim angles, `opus[1m]` for the refuting verifier and the synthesis); each posts midway progress via `SendMessage`. Each teammate owns one lens and cites **primary sources with publication dates**:

| Angle | Primary source |
|-------|----------------|
| Official truth | Vendor docs, specs, standards, RFCs |
| Ground truth | Source code, release notes, changelogs |
| Failure truth | Issue trackers, CVEs, post-mortems |
| Measured truth | Independent benchmarks, reproducible tests |
| Formal truth | Papers, standards bodies |
| Lived truth | Practitioner reports, forums (corroborate, never alone) |

Never decide on a single source or a single teammate.

## Adversarial verification pass

For every load-bearing claim, a **fresh-context teammate tries to refute it** before you rely on it (never same-context self-review; the author is blind to their own gaps). A claim survives only if refutation fails against a primary source. Refutation succeeds: drop or qualify the claim.

## Recency discipline

Prefer the newest authoritative source. State the **as-of date of every fact**. Flag anything older than the domain moves (fast-moving framework dates in months; stable protocol in years). "True once" is not "true now"; re-verify at invocation.

## Synthesis: separate the three

Sort every finding into one bin, never blur:
- **Established fact**: primary-sourced, survived refutation.
- **Current consensus**: widely held, may shift.
- **Open question**: contested or unknown.

## Output: decision-ready digest

- The answer, with a **confidence level** per claim.
- Citations (source + date) on every load-bearing statement.
- **What would change the conclusion** (the trip-wire to re-open).
- Established fact vs consensus vs open question, kept distinct.

## Headless mode

Fully autonomous: spawn the team, verify, synthesize, land the digest in the final report. No human-in-the-loop deadlock; a claim that cannot be verified ships labeled "unverified", never silently.

## Red flags: STOP, widen the search

- One source backing a load-bearing claim
- No date on a fact in a fast-moving domain
- Skipping the refutation pass because the claim "seems obvious"
- Author verifying their own claim (same-context self-review)
- A vendor's own marketing as the only evidence it is fastest/safest
- Deciding before the adversarial pass returns

Handoff: the digest into dmj:brainstorming or dmj:writing-plans as the evidence base for the decision.
