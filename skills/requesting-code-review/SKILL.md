---
name: requesting-code-review
description: Use when a task or major feature is complete, before merging to main, or when stuck and needing a fresh perspective on the work product
---

# Requesting Code Review

Review early, review often. Never your own diff in your own context: you already believe it is correct. Dispatch fresh-context teammates who see only the work product, never your reasoning.

## When

**Mandatory:** after each task in team-driven development, after a major feature, before merge to main. **Valuable:** when stuck, before a large refactor.

## Run a parallel review panel, not one reviewer

One reviewer misses by lens. Spin a team (`dmj:dispatching-parallel-teams`): one fresh-context teammate per lens, same diff, all concurrent, each posting progress midway.

| Lens | Hunts for | Anchored by |
|------|-----------|-------------|
| Correctness | logic bugs, broken edge cases, plan deviations, missing functionality | the plan / requirements |
| Security | injection, authz gaps, unsafe input handling, secret leakage, blast radius | `dmj:defending-in-depth` |
| Performance | complexity regressions, N+1, missing caching, budget breaches | `dmj:enforcing-performance-budgets` |
| Simplicity | dead code, premature abstraction, duplication, YAGNI, naming | matching surrounding code |

User-facing diff -> add a fifth **Experience** lens hunting breaches of the non-negotiables table in `dmj:crafting-experiences`, where those bars are defined.

Synthesize the reports yourself. Give each teammate the diff range (`git rev-parse origin/main`, or `HEAD~1`, or the task's start SHA, through `HEAD`), never your history. Each returns findings as `file:line + what + why + severity (Critical/Important/Minor)`. Prompt skeleton: `review-lens.md`.

## Consolidate, dedupe, spot-verify

Lenses overlap: collapse duplicates to one. Spot-verify before anything reaches the user, because a lens can hallucinate. Per Critical/Important finding, confirm against the actual code that the cited line does what the finding says; drop or downgrade what does not survive. Unverified speculation never reaches the user as fact.

## Act on surviving findings

Critical -> fix immediately. Important -> before proceeding. Minor -> note. A finding you believe is wrong: neither silently comply nor silently ignore, push back with technical reasoning (`dmj:receiving-code-review`).

## Blast radius

Panel size follows blast radius: the lens table by default, narrowed (correctness + security only, say) for a tiny low-risk diff. Name the tier to the user when you narrow it; never narrow silently.

## Red flags

Skipping review because "it is simple" / a diff covering more than one concern / ignoring a Critical / proceeding with unfixed Important.

## Headless mode

Background agent: full panel unprompted, consolidate, spot-verify, report surviving findings with fixes and any pushback with reasoning. Park nothing it can verify itself; flag only genuine judgment calls the user owns.

Findings resolved? Next: `dmj:finishing-a-development-branch`. Receiving the feedback: `dmj:receiving-code-review`.
