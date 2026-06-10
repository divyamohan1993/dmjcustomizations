---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code, or whenever tempted to write production code without a failing test
---

# Test-Driven Development

Test first. Watch it fail. Minimal code to pass. Did not watch it fail? You do not know it tests anything.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it: no keeping as reference, no adapting, no looking. Reimplement fresh from the test. Letter and spirit are one rule.

**Exceptions (throwaway only):** spikes, generated code, config. A spike lives in a force-discarded worktree (`dmjcustomizations:using-git-worktrees`): conclusions survive, code does not. "Skip just this once" on real code is rationalization.

## RED-GREEN-REFACTOR

1. **RED:** one behavior, clear name, real code (mocks only if unavoidable). Run it. Confirm it *fails* (not errors) for the *expected* reason. Passes first run? Testing existing behavior, fix the test.
2. **GREEN:** simplest code that passes. No extra options, no "while I'm here." Run it: this and all other tests pass, output pristine. Test fails? Fix the code, never the test.
3. **REFACTOR:** only when green. Remove duplication, improve names, add no behavior, stay green. Then next failing test.

**RED before GREEN is strictly serial within one unit of work: that ordering IS the discipline.** Separate-task test files may be authored concurrently by teammates (`dmjcustomizations:team-driven-development`); serial rule binds within each.

## Edge-case taxonomy

All input hostile. Cover every applicable row; for each that does not apply, say so and why.

| Row | Probe |
|-----|-------|
| Boundaries | empty, single, max, off-by-one, overflow |
| Adversarial input | injection, malformed encoding, oversized, fuzz |
| Concurrency | races, reentrancy, partial failure, ordering |
| Resource exhaustion | memory, disk, fd, pool limits |
| Idempotency / retry | duplicate, replay, at-least-once delivery |
| Clock / timezone | DST, leap, skew, expiry |
| Property-based | invariants for all inputs (round-trip, monotonicity) |

Security past the input layer: `dmjcustomizations:defending-in-depth`. Complexity floor: `dmjcustomizations:enforcing-performance-budgets`.

## Rationalizations: all mean "delete the code, start over"

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. The test costs 30 seconds. |
| "I'll test after" | Tests-after pass immediately and prove nothing. |
| "Already manually tested" | Ad-hoc, no record, cannot re-run. |
| "Deleting X hours is wasteful" | Sunk cost. Unverified code is debt, not an asset. |
| "Keep it as reference" | You will adapt it. That is testing after. |
| "Tests-after, same spirit" | After = "what does this do." First = "what should it do." |
| "TDD is dogmatic, I'm pragmatic" | TDD is faster than debugging in production. |

## Red flags: STOP and start over

Code before test, test passes first run, cannot explain the failure, "too simple to test," tests added "later," "this is different because…," any rationalization above.

## When stuck

Hard to test means hard to use: too coupled, inject dependencies; huge setup, the interface is wrong. Bug? Write the failing reproduction test first (`dmjcustomizations:systematic-debugging`). Mocks or test-only code? Read `testing-anti-patterns.md`.

## Headless mode

Log skipped rows with reasons in the assumption ledger; park scope cuts for the user. Never silently drop coverage.

Done: every applicable row covered or excused, every test seen failing first, output pristine. Next: `dmjcustomizations:verification-before-completion`.
