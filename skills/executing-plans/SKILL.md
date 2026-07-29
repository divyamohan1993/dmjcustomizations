---
name: executing-plans
description: Use when you have a written implementation plan to carry out in a fresh session (no prior context loaded), whether opened cold or handed off from planning, and the plan has multiple tasks.
---

# Executing Plans

Execute a saved plan in a fresh session by fanning its tasks across a team. Independent tasks are claimed concurrently from a shared list; gates stay serial.

Announce: "Using executing-plans to implement this plan as a team."

Same session with no plan file? Use dmj:team-driven-development instead.

## Step 1: Load and critique

Read the plan. Verify each task carries Depends-on, Parallel-safe, machine-checkable acceptance criteria, a verification step (dmj:writing-plans). Raise blocking gaps with the user before starting. Never begin on `main`/`master` without explicit consent; isolate first (dmj:using-git-worktrees).

## Step 2: Build the dependency wave plan

From each task's Depends-on, group into waves: a wave is the set whose dependencies are all satisfied. Within a wave, file-overlapping tasks cannot run together: give each its own worktree or push to a later wave. State the wave plan to the user.

## Step 3: Fan out per wave (parallel between gates)

Spawn a team (dmj:dispatching-parallel-teams): one named `Agent` per task, all in a single message so the wave runs concurrently. Put the wave's tasks on a shared list. Teammates CLAIM one each, never fire-and-forget. Each teammate:

- works the task by dmj:test-driven-development,
- posts a midway progress message, can message peers about shared interfaces,
- logs any forced plan deviation under Deviations in `implementation-notes.md` (conservative option chosen) and keeps going,
- runs the task's verification command, reports the actual output,
- commits inside its own worktree.

You (lead) do not implement; you coordinate, unblock, hold the gates.

## Step 4: Review gate (serial, fresh-context)

A wave's tasks report done: gate before the next wave. Per task, a FRESH-context reviewer (not the implementer) confirms acceptance criteria pass and spec is met (dmj:requesting-code-review); the lead reviews the Deviations log, since a deviation can invalidate a later task. Re-dispatch the implementer for blocking findings; re-review only what failed. Integrate worktrees, then run the full suite to catch cross-task breakage before opening the next wave.

## Step 5: Finish

After the final wave passes and the full suite is green: dmj:verification-before-completion, then dmj:finishing-a-development-branch.

## Stop and ask when

Unresolvable blocker (missing dep, unclear instruction, repeated verification failure), a plan gap that prevents starting, or a fundamental approach change. Do not force through; surface it.

## Headless mode

No interactive user: proceed wave by wave on the plan as written, record assumptions in the run log, PARK only decisions the user must own (irreversible, security, cost, public surface) as blocking notes. A failing gate halts the affected task, not the whole run; independent waves continue.

## Red flags (stop)

- One agent grinding tasks serially when the wave plan shows them independent.
- Concurrent tasks sharing a file with no worktree.
- Skipping a review gate, or the implementer reviewing its own task.
- Opening the next wave before the full suite is green.
- Starting on `main` without consent.

Next: **dmj:verification-before-completion**, then **dmj:finishing-a-development-branch**.
