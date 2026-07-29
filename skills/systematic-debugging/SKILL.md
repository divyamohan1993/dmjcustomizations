---
name: systematic-debugging
description: Use when encountering any bug, test failure, unexpected behavior, performance regression, or build/integration failure, before proposing or writing any fix
---

# Systematic Debugging

Random fixes waste time and create new bugs. Find the root cause first.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Not past Phase 1? You cannot propose a fix. Binds hardest when you want to skip it: under deadline, on "one quick fix," after fixes already failed. Simple bugs have root causes too; systematic beats thrashing.

## Phase 1: Investigate

1. **Read the error.** Whole message, full stack trace, line numbers, codes. Often names the fix.
2. **Reproduce reliably.** Exact steps, every time. Not reproducible? Gather data, do not guess.
3. **Check recent changes.** `git diff`, new deps, config, env.
4. **Instrument boundaries** (multi-component systems: CI to build to sign, API to service to DB). Log what enters/exits each boundary, run once, read which breaks. Investigate that component, not the symptom.
5. **Trace data flow backward** to the bad value's source, fix there. See `debugging-techniques.md`.

## Phase 2: Fan out hypotheses in parallel

List every plausible root cause. For 2+ live hypotheses, do not test serially in your own context: spin a team (`dmj:dispatching-parallel-teams`), one fresh-context teammate per hypothesis, each a distinct evidence job:

| Teammate | Gathers |
|----------|---------|
| logs | what the runtime/CI emitted at the failure |
| git-bisect | first bad commit |
| minimal-repro | smallest input that triggers it |
| dependency-diff | version/lockfile/config deltas vs last-good |

Each reports its evidence back midway. **No fix is written until the evidence is in.** Consolidate: which hypothesis it supports, which it kills.

## Phase 3: Confirm one hypothesis

State it: "X is the root cause because Y." Test with the *smallest* change, one variable. Confirmed? Phase 4. Not? New hypothesis, do not stack fixes. Do not understand something? Say so, investigate more.

## Phase 4: Fix at the source

1. **Failing test first** reproducing the bug (`dmj:test-driven-development`), before the fix.
2. **One fix** at the root cause. No "while I'm here," no bundled refactor.
3. **Verify** (`dmj:verification-before-completion`): test passes, nothing else broke.
4. Add validation at every layer the bad value crossed, making the bug structurally impossible: `dmj:defending-in-depth`.

**Fix failed?** Under 3 attempts: back to Phase 1 with new evidence. **3+ failed, or each fix exposes a new problem elsewhere: stop, the architecture is wrong, not the hypothesis.** Raise it with the user; do not attempt fix #4.

## Red flags: STOP, return to Phase 1

"Quick fix now, investigate later," "just try changing X," "probably X," multiple changes at once, skipping the test, listing fixes before tracing data flow, "one more attempt" after 2+ failures.

## Headless mode

Complete every phase, capture all evidence in the final report, write safe minimal fixes, park architectural reversals (Phase 4, 3+ failures) as a flagged question rather than refactoring unsupervised.

Root cause fixed with a guarding test? Next: `dmj:verification-before-completion`, then `dmj:requesting-code-review`.
