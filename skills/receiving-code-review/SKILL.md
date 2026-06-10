---
name: receiving-code-review
description: Use when receiving code review feedback, before implementing any suggestion, especially when feedback seems unclear, sweeping, or technically questionable
---

# Receiving Code Review

Review feedback is input to evaluate, not orders to obey. Technical correctness over social comfort.

## The response pattern

```
1. READ the whole feedback without reacting
2. UNDERSTAND: restate each item in your own words, or ask
3. VERIFY each item against the actual code
4. EVALUATE: is it sound for THIS codebase?
5. RESPOND: technical acknowledgment, or reasoned pushback
6. IMPLEMENT verified items one at a time, testing each
```

## Never implement a suggestion you have not verified

A reviewer (human or review-lens teammate) can be wrong, lack context, or hallucinate a bug. Before changing code, confirm the claim against reality: does the cited line actually do what the finding says? Does the suggestion break existing behavior, or any platform/version still supported? Is there a reason the current code is the way it is? Unverified compliance is how a confident-but-wrong finding becomes your bug.

Cannot verify it (missing context, external dependency)? Say so: "I cannot verify this without X. Investigate, ask, or proceed?" Never proceed on faith.

## No performative agreement

Forbidden, a standing instruction not a style preference: "You're absolutely right," "Great point," "Excellent feedback," any thanks. Add nothing, signal compliance over thought.

Instead: restate the requirement, ask a question, push back with reasoning, or just fix it and let the code show you heard. Correct finding: "Fixed: [what changed]" or "Good catch, [issue], fixed in [location]." Caught yourself about to type "Thanks"? Delete it, state the fix.

## Triage in parallel, gate on verification

Independent items can be assessed concurrently (verify several at once, or fan out to teammates for a large batch via `dmjcustomizations:dispatching-parallel-teams`). But items often relate: if any is unclear, clarify ALL unclear items before implementing ANY, since partial understanding yields wrong fixes. Then implement blocking items (breaks, security) first, simple fixes (typos, imports) next, complex (refactor, logic) last, testing each, no regressions.

## YAGNI check

Reviewer says "implement this properly"? Grep for actual usage first. Nothing calls it: "This isn't called anywhere, remove it (YAGNI)?" Used: implement it properly.

## Push back when

The suggestion breaks existing behavior, the reviewer lacks context, it violates YAGNI, it is wrong for this stack, legacy/compatibility needs the current form, or it conflicts with a prior architectural decision (raise that one with the user). Push back with technical reasoning and a reference to working code or a test, never defensiveness. Wrong after pushing back? "You were right, I checked X and it does Y. Fixing." Move on, no long apology.

## GitHub threads

Reply inside the comment thread (`gh api repos/{owner}/{repo}/pulls/{pr}/comments/{id}/replies`), not as a top-level PR comment.

## Headless mode

A background agent verifies every item against the code, implements what survives, records in the final report what it changed, what it pushed back on with reasoning, what it could not verify. Park only genuine architectural conflicts the user owns.

Feedback resolved and verified? Back to `dmjcustomizations:verification-before-completion`, then `dmjcustomizations:finishing-a-development-branch`.
