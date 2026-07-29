---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing any suggestion, especially when feedback seems unclear, sweeping, or technically questionable
---

# Receiving Code Review

Feedback = input to evaluate, not orders to obey. Correctness > comfort. Understand -> judge against this codebase -> implement verified items one at a time, test each.

## Never implement a suggestion you have not verified

Reviewers (human or review-lens teammate) can be wrong, lack context, hallucinate. Confirm against reality first: cited line does what the finding says? / fix breaks existing behavior or a still-supported platform/version? / current form deliberate?

Unverified compliance = a confident-but-wrong finding becoming your bug. Cannot verify (missing context, external dependency)? "I cannot verify this without X. Investigate, ask, or proceed?" Never proceed on faith.

## No performative agreement

Forbidden, standing instruction not style preference: "You're absolutely right," "Great point," "Excellent feedback," any thanks. Signal compliance over thought.

Instead: restate the requirement / ask / push back with reasoning / fix it and let the code show you heard. Correct finding -> "Fixed: [what changed], in [location]."

## Triage in parallel, gate on verification

Independent items assess concurrently (large batch -> fan out, `dmj:dispatching-parallel-teams`). Items relate: any unclear -> clarify ALL unclear before implementing ANY. Partial understanding = wrong fixes. Order: blocking (breaks, security) -> simple (typos, imports) -> complex (refactor, logic). Test each, no regressions.

## YAGNI check

"Implement this properly"? Grep for usage first. Nothing calls it -> "This isn't called anywhere, remove it (YAGNI)?" Used -> implement properly.

## Push back when

Breaks existing behavior / reviewer lacks context / violates YAGNI / wrong for this stack / legacy or compatibility needs the current form / conflicts with a prior architectural decision (that one goes to the user).

Reasoning + a reference to working code or a test. Never defensiveness. Wrong after pushing back? "You were right, I checked X and it does Y. Fixing." Move on, no apology.

## GitHub threads

Reply inside the thread (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), never top-level.

## Headless mode

Background agent: verify every item, implement what survives, report what changed / pushbacks with reasoning / what it could not verify. Park only genuine architectural conflicts the user owns.

Resolved and verified? Back to `dmj:verification-before-completion`, then `dmj:finishing-a-development-branch`.
