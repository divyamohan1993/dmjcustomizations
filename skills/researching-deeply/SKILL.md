---
name: researching-deeply
description: Use when choosing a library, framework, model, or stack, asking "what is the current best" or "is this still true", or verifying a claim before relying on it. Other triggers: a factual or technology question that affects a decision, entering unfamiliar territory, checking prior art, any assertion you are about to build on.
---

# Researching Deeply

One source is a rumor. A decision rests on triangulated, dated, primary-source evidence, with a named adversary who tried to break each load-bearing claim and failed.

## Step 0: Use the native engine if present

If the harness exposes a deep-research tool or skill, prefer it: it already fans out, fetches, and verifies. Drive it, then apply the verification and synthesis discipline below to its output. Only hand-roll the team when no native engine exists.

## Fan out by angle, in parallel

Spawn a research team (TeamCreate, then Agent with team_name and a name per angle; SendMessage with midway progress posts). If TeamCreate is unavailable, run the same angles as native parallel Agent calls and synthesize yourself. Each teammate owns a different lens and cites **primary sources with publication dates**:

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

For every load-bearing claim, a **fresh-context teammate tries to refute it** before you rely on it (never same-context self-review; the author is blind to their own gaps). A claim survives only if the refutation fails against a primary source. Refutation succeeds: drop or qualify the claim.

## Recency discipline

Prefer the newest authoritative source. State the **as-of date of every fact**. Flag anything older than the domain moves (a fast-moving framework dates in months; a stable protocol in years). "It was true once" is not "it is true now"; re-verify at invocation.

## Synthesis: separate the three

Sort every finding into one of three bins, never blur them:
- **Established fact**: primary-sourced, survived refutation.
- **Current consensus**: widely held, may shift.
- **Open question**: contested or unknown.

## Output: decision-ready digest

- The answer, with a **confidence level** per claim.
- Citations (source + date) on every load-bearing statement.
- **What would change the conclusion** (the trip-wire to re-open).
- Established fact vs consensus vs open question, kept distinct.

## Headless mode

Runs fully autonomously: spawn the team, verify, synthesize, land the digest in the final report. No human-in-the-loop deadlock; if a claim cannot be verified, ship it labeled "unverified", never silently.

## Red flags: STOP, widen the search

- One source backing a load-bearing claim
- No date on a fact in a fast-moving domain
- Skipping the refutation pass because the claim "seems obvious"
- Author verifying their own claim (same-context self-review)
- A vendor's own marketing as the only evidence it is fastest/safest
- Deciding before the adversarial pass returns

Handoff: feed the digest into dmjcustomizations:brainstorming or dmjcustomizations:writing-plans as the evidence base for the decision.
