---
name: test-driven-development
description: Use when implementing any feature or bugfix, before writing implementation code, or whenever tempted to write production code without a failing test
---

# Test-Driven Development

Test first. Watch it fail. Minimal code to pass. Never saw it fail = do not know it tests anything. A failing test or concrete input/output example beats any prose spec: show, then build.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Code before test? Delete it. No reference copy, no adapting, no looking. Reimplement from the test. Letter = spirit.

**Exceptions (throwaway only):** spikes, generated code, config. Spike = deleted-after temp clone (`dmj:using-git-worktrees` policy; never a worktree). Conclusions survive, code does not. "Skip just this once" on real code = rationalization.

## RED-GREEN-REFACTOR

1. **RED:** one behavior, clear name, real code (mocks only if unavoidable). Run it. Confirm it *fails* (not errors) for the *expected* reason. Passes first run = testing existing behavior; fix the test.
2. **GREEN:** simplest code that passes. No extra options, no "while I'm here." Run: this + all others green, output pristine. Test fails -> fix code, never test.
3. **REFACTOR:** only when green. Kill duplication, improve names, add no behavior, stay green. Then next failing test.

**RED before GREEN is strictly serial within one unit of work: that ordering IS the discipline.** Separate-task test files may be authored concurrently by teammates (`dmj:team-driven-development`); serial rule binds within each.

## Edge-case taxonomy

All input hostile. Name rows covered + rows out of scope. Silently missing row = the coverage drop nobody sees.

| Row | Probe |
|-----|-------|
| Boundaries | empty, single, max, off-by-one, overflow |
| Adversarial input | injection, malformed encoding, oversized, fuzz |
| Concurrency | races, reentrancy, partial failure, ordering |
| Resource exhaustion | memory, disk, fd, pool limits |
| Idempotency / retry | duplicate, replay, at-least-once delivery |
| Clock / timezone | DST, leap, skew, expiry |
| Property-based | invariants for all inputs (round-trip, monotonicity) |

Past the input layer: `dmj:defending-in-depth`. Complexity floor: `dmj:enforcing-performance-budgets`.

## Tests that execute but never assert

Green proves the code ran, not that anything was checked. Mutation score catches it: gate lane, not judgement call. Run it (`dmj:enforcing-quality-gates`, T3).

## Rationalizations: all mean "delete the code, start over"

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test costs 30 seconds. |
| "I'll test after" | Tests-after pass immediately, prove nothing. First = "what should it do"; after = "what does this do." |
| "Deleting X hours is wasteful" | Sunk cost. Unverified code = debt. |

## Red flags: STOP and start over

Code before test / passes first run / cannot explain the failure / "this is different because…" / any rationalization above.

## When stuck

Hard to test = hard to use. Too coupled -> inject deps. Huge setup -> wrong interface. Bug -> failing repro test first (`dmj:systematic-debugging`). Mocks or test-only code -> `testing-anti-patterns.md`.

## Headless mode

Log skipped rows + reasons in the assumption ledger. Park scope cuts for the user. Never silently drop coverage.

Done = every applicable row covered or excused, every test seen failing first, output pristine. Next: `dmj:verification-before-completion`.
