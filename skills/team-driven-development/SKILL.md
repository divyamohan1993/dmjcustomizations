---
name: team-driven-development
description: Use when you have an implementation plan with independent tasks and are continuing in the CURRENT session (its context already loaded) to carry it out.
---

# Team-Driven Development

Execute a plan in this session with an Agent Team: a fresh-context teammate implements each task; each task passes a two-stage review (spec compliance, then code quality) before the next. Independent tasks run in parallel; gates are serial.

Announce: "Using team-driven-development to execute this plan."

Fresh session, or many parallel waves? Use dmj:executing-plans. No plan yet? Use dmj:brainstorming.

## Setup

1. Read the plan ONCE. Extract every task with full text, file set, dependencies, acceptance criteria onto a shared task list (dmj:dispatching-parallel-teams). Never make a teammate read the plan file; hand it the text.
2. `TeamCreate`, then spawn teammates with `Agent` (always `team_name` + a `name`) on the strongest model available at invocation with max thinking. Isolate work in worktrees (dmj:using-git-worktrees). If TeamCreate is unavailable, run the same per-task stages as native parallel `Agent` calls and synthesize yourself.

## Per-task loop (continuous, no check-ins)

Run all tasks without pausing to ask "should I continue". Stop only for an unresolvable BLOCKED, genuine ambiguity, or all-done.

1. **Implement.** Dispatch an implementer with the task text + scene-setting context (`teammate-prompts.md`). It asks questions first if unclear, then builds by dmj:test-driven-development, posts progress, commits, self-reviews, reports a status.
2. **Spec review (fresh context).** A different teammate verifies the code matches the task, nothing missing or extra, by READING the code, not trusting the report. Loop fixes until compliant.
3. **Quality review (fresh context, only after spec passes).** A third teammate runs dmj:requesting-code-review (one-responsibility files, tests verify behavior, security per dmj:defending-in-depth, budgets per dmj:enforcing-performance-budgets). Loop fixes until approved.
4. Mark the task done. Parallel-safe tasks (per the plan) may run concurrently on separate teammates + worktrees; serialize file-overlapping tasks.

## Handling implementer status

| Status | Action |
|---|---|
| DONE | Proceed to spec review |
| DONE_WITH_CONCERNS | Read concerns; fix correctness/scope before review, note observations |
| NEEDS_CONTEXT | Provide missing context, re-dispatch |
| BLOCKED | Diagnose: more context, or stronger model, or split the task, or escalate to user |

Never re-dispatch the same way after BLOCKED: something must change. Never ignore a teammate's question.

## Finish

After the last task, one fresh-context reviewer checks the whole diff, then dmj:verification-before-completion.

## Headless mode

No interactive user: run the loop autonomously, record assumptions, PARK only user-owned decisions (irreversible, security, cost, public surface) as blocking notes. A blocked task halts itself, not independent tasks.

## Red flags (stop)

- Implementing yourself instead of dispatching (context pollution).
- Same context reviewing what it built; quality review before spec passes.
- Fire-and-forget: no progress messages, no peer channel.
- Proceeding with an open review finding, or onto a file-overlapping task without a worktree.
- Starting on `main` without consent.

Skeletons: `teammate-prompts.md`. Next: **dmj:verification-before-completion**, then **dmj:finishing-a-development-branch**.
