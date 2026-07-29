---
name: systematic-debugging
description: Use when encountering any bug, test failure, unexpected behavior, performance regression, or build/integration failure, before proposing or writing any fix
---

# Systematic Debugging

Random fixes waste time and create new bugs. Root cause first.

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

Not past Phase 1 = no fix proposal. Binds hardest when you want to skip it: deadline, "one quick fix," after fixes already failed. Simple bugs have root causes too; systematic beats thrashing.

## Phase 1: Investigate

1. **Read the error.** Whole message, full stack trace, line numbers, codes. Often names the fix.
2. **Reproduce reliably.** Exact steps, every time. Not reproducible -> gather data, never guess.
3. **Check recent changes.** `git diff`, new deps, config, env.
4. **Instrument boundaries** (multi-component: CI -> build -> sign, API -> service -> DB). Log enter/exit per boundary, run once, read which breaks. Investigate that component, not the symptom.
5. **Trace data flow backward** to the bad value's source, fix there. See `debugging-techniques.md`.

## Phase 2: Fan out hypotheses in parallel

List every plausible root cause. 2+ live hypotheses = never serial in your own context: spin a team (`dmj:dispatching-parallel-teams`), one fresh-context teammate per hypothesis, each a distinct evidence job:

| Teammate | Gathers |
|----------|---------|
| logs | what the runtime/CI emitted at the failure |
| git-bisect | first bad commit |
| minimal-repro | smallest input that triggers it |
| dependency-diff | version/lockfile/config deltas vs last-good |

Each reports evidence midway. **No fix is written until the evidence is in.** Consolidate: which hypothesis it supports, which it kills.

## Phase 3: Confirm one hypothesis

State it: "X is the root cause because Y." Test with the *smallest* change, one variable. Confirmed -> Phase 4. Not -> new hypothesis, never stack fixes. Do not understand something? Say so, investigate more.

## Phase 4: Fix at the source

1. **Failing test first** reproducing the bug (`dmj:test-driven-development`), before the fix.
2. **One fix** at the root cause. No "while I'm here," no bundled refactor.
3. **Verify** (`dmj:verification-before-completion`): test passes, nothing else broke.
4. **Validate at every layer** the bad value crossed, making the bug structurally impossible: `dmj:defending-in-depth`.

**Fix failed?** First failure: back to Phase 1 with the new evidence. **Two consecutive failed fixes at the same root cause, or each fix exposing a new problem elsewhere: stop. The hypothesis space is wrong, not the hypothesis, and the agent judging whether it is thrashing is the thrashing agent, which is why this is a count and not a feeling.** Raise the architecture question with the user before any third attempt.

## Red flags: STOP, return to Phase 1

"Quick fix now, investigate later" / "just try changing X" / "probably X" / multiple changes at once / skipping the test / listing fixes before tracing data flow / "one more attempt" after two failed fixes.

## Headless mode

Complete every phase, all evidence in the final report, safe minimal fixes. Park architectural reversals (Phase 4, two failed fixes) as a flagged question; never refactor unsupervised.

Root cause fixed with a guarding test? Next: `dmj:verification-before-completion`, then `dmj:requesting-code-review`.
