---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code, or whenever tempted to write production code without a failing test
---

# Test-Driven Development

Test first. Watch it fail. Minimal code to pass. Did not watch it fail? You do not know it tests anything. A failing test or a concrete input/output example steers better than any prose spec: show, then build.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Wrote code before the test? Delete it: no keeping as reference, no adapting, no looking. Reimplement fresh from the test. Letter and spirit are one rule.

**Exceptions (throwaway only):** spikes, generated code, config. A spike lives in a deleted-after temp clone (`dmj:using-git-worktrees` policy; never a worktree): conclusions survive, code does not. "Skip just this once" on real code is rationalization.

## RED-GREEN-REFACTOR

1. **RED:** one behavior, clear name, real code (mocks only if unavoidable). Run it. Confirm it *fails* (not errors) for the *expected* reason. Passes first run? Testing existing behavior, fix the test.
2. **GREEN:** simplest code that passes. No extra options, no "while I'm here." Run it: this and all other tests pass, output pristine. Test fails? Fix the code, never the test.
3. **REFACTOR:** only when green. Remove duplication, improve names, add no behavior, stay green. Then next failing test.

**RED before GREEN is strictly serial within one unit of work: that ordering IS the discipline.** Separate-task test files may be authored concurrently by teammates (`dmj:team-driven-development`); serial rule binds within each.

## Edge-case taxonomy

All input hostile. Name the rows covered and the rows judged out of scope; a silently missing row is the coverage drop nobody sees.

| Row | Probe |
|-----|-------|
| Boundaries | empty, single, max, off-by-one, overflow |
| Adversarial input | injection, malformed encoding, oversized, fuzz |
| Concurrency | races, reentrancy, partial failure, ordering |
| Resource exhaustion | memory, disk, fd, pool limits |
| Idempotency / retry | duplicate, replay, at-least-once delivery |
| Clock / timezone | DST, leap, skew, expiry |
| Property-based | invariants for all inputs (round-trip, monotonicity) |

Security past the input layer: `dmj:defending-in-depth`. Complexity floor: `dmj:enforcing-performance-budgets`.

## Tests that execute but never assert

A passing suite proves the code ran, not that anything was checked. The measure that catches it is the mutation score, and it is a gate lane rather than a judgement call: run it (`dmj:enforcing-quality-gates`, T3) instead of trusting the green.

## Rationalizations: all mean "delete the code, start over"

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. The test costs 30 seconds. |
| "I'll test after" | Tests-after pass immediately and prove nothing. First = "what should it do"; after = "what does this do." |
| "Deleting X hours is wasteful" | Sunk cost. Unverified code is debt, not an asset. |

## Red flags: STOP and start over

Code before test, test passes first run, cannot explain the failure, "this is different because…," any rationalization above.

## When stuck

Hard to test means hard to use: too coupled, inject dependencies; huge setup, the interface is wrong. Bug? Write the failing reproduction test first (`dmj:systematic-debugging`). Mocks or test-only code? Read `testing-anti-patterns.md`.

## Headless mode

Log skipped rows with reasons in the assumption ledger; park scope cuts for the user. Never silently drop coverage.

Done: every applicable row covered or excused, every test seen failing first, output pristine. Next: `dmj:verification-before-completion`.
