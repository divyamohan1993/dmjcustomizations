---
name: team-driven-development
description: Use when you have an implementation plan with independent tasks and are continuing in the CURRENT session (its context already loaded) to carry it out.
---

# Team-Driven Development

Run a plan in this session with named teammates: a fresh-context teammate per task, two-stage review (spec, then quality) before the next. Independent tasks parallel; gates serial.

Fresh session, or many parallel waves -> dmj:executing-plans. No plan yet -> dmj:brainstorming.

## Setup

1. Read the plan ONCE. Extract every task (full text, file set, dependencies, acceptance criteria) onto a shared task list. Never make a teammate read the plan file; hand it the text.
2. Spawn per dmj:dispatching-parallel-teams: every spawn on `opus[1m]` (user law), each prompt carrying strict file ownership. Overlapping file sets never parallel: sequence those tasks (worktrees banned, dmj:using-git-worktrees). A task risky enough to stop before it edits gets spawned requiring plan approval, approval criteria in the prompt.

## Per-task loop (continuous, no check-ins)

Run all tasks without asking "should I continue". Stop only for an unresolvable BLOCKED, genuine ambiguity, or all-done.

1. **Implement.** Dispatch an implementer with task text + scene-setting context (`teammate-prompts.md`). It asks first if unclear, builds by dmj:test-driven-development, posts progress, logs any forced plan deviation under Deviations in `implementation-notes.md` (conservative option), commits, self-reviews, reports a status.
2. **Spec review (fresh context).** A different teammate verifies the code matches the task, nothing missing or extra, by READING the code, never trusting the report. Lead checks Deviations against later tasks. Loop until compliant.
3. **Quality review (fresh context, only after spec passes).** A third teammate runs dmj:requesting-code-review: one-responsibility files, tests verifying behavior, security per dmj:defending-in-depth, budgets per dmj:enforcing-performance-budgets. Loop until approved.
4. Mark done. Parallel-safe tasks run concurrently on separate teammates with disjoint ownership; file-overlapping tasks serialize.

**Fixes go back to the teammate that wrote the code**, via `SendMessage` to its name, never a fresh spawn: it still holds the task context. Spawn fresh only for review stages, where missing that context is the point.

## Handling implementer status

| Status | Action |
|---|---|
| DONE | Proceed to spec review |
| DONE_WITH_CONCERNS | Read concerns; fix correctness/scope before review, note observations |
| NEEDS_CONTEXT | Provide missing context, re-dispatch |
| BLOCKED | Diagnose: more context, or stronger model, or split the task, or escalate to user |

Never re-dispatch the same way after BLOCKED: something must change. Never ignore a teammate's question.

## Finish

Last task done -> one fresh-context reviewer checks the whole diff, then dmj:verification-before-completion.

## Headless mode

Run the loop autonomously, record assumptions, PARK per the library default (dmj:using-dmj). A blocked task halts itself, not independent tasks.

## Red flags (stop)

- Implementing yourself instead of dispatching (context pollution).
- Same context reviewing what it built; quality review before spec passes.
- Starting on `main` without consent.

Skeletons: `teammate-prompts.md`. Next: **dmj:verification-before-completion**, then **dmj:finishing-a-development-branch**.
