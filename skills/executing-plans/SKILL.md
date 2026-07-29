---
name: executing-plans
description: Use when you have a written implementation plan to carry out in a fresh session (no prior context loaded), whether opened cold or handed off from planning, and the plan has multiple tasks.
---

# Executing Plans

Saved plan, fresh session -> fan tasks across a team. Independent tasks claimed off a shared list; gates serial.

Same session, no plan file -> dmj:team-driven-development.

## Step 1: Load and critique

Read the plan. Each task must carry Depends-on, Parallel-safe, machine-checkable acceptance criteria, verification step (dmj:writing-plans). Raise blocking gaps with the user first. Never begin on `main`/`master` without explicit consent; branch first (dmj:using-git-worktrees policy: main checkout, never a worktree).

## Step 2: Dependency wave plan

Group by Depends-on: a wave = the set whose dependencies are satisfied. File-overlapping tasks cannot share a wave -> push one later (worktrees banned; ownership boundaries + sequencing are the policy). State the wave plan to the user.

## Step 3: Fan out per wave (parallel between gates)

One named `Agent` per task, all in a single message, shared task list, never fire-and-forget (dmj:dispatching-parallel-teams). Hand each the full task text; a teammate inherits none of your context.

Teammates work the implementer contract from dmj:team-driven-development (skeleton: its `teammate-prompts.md`). Wave delta: a forced deviation takes the conservative option and never stalls the wave.

Lead does not implement: coordinate, unblock, hold gates. Only the lead fans out a wave.

## Step 4: Review gate (serial, fresh-context)

Wave done -> gate before the next. Per task, a FRESH-context reviewer (never the implementer) confirms acceptance criteria pass and spec is met (dmj:requesting-code-review). Lead reads the Deviations log: one deviation can invalidate a later task. Re-dispatch the implementer for blockers; re-review only what failed. Full suite before the next wave opens: cross-task breakage.

## Step 5: Finish

Final wave passed, suite green -> dmj:verification-before-completion, then dmj:finishing-a-development-branch.

## Stop and ask when

Unresolvable blocker (missing dep, unclear instruction, repeated verification failure), a plan gap blocking the start, a fundamental approach change. Do not force through; surface it.

## Headless mode

Run wave by wave on the plan as written, record assumptions in the run log, PARK per the library default (dmj:using-dmj). A failing gate halts its task, not the run; independent waves continue.

Next: **dmj:verification-before-completion**, then **dmj:finishing-a-development-branch**.
