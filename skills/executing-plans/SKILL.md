---
name: executing-plans
description: Use when you have a written implementation plan to carry out in a fresh session (no prior context loaded), whether opened cold or handed off from planning, and the plan has multiple tasks.
---

# Executing Plans

Execute a saved plan in a fresh session by fanning its tasks across a team. Independent tasks are claimed concurrently from a shared list; gates stay serial.

Same session with no plan file? Use dmj:team-driven-development instead.

## Step 1: Load and critique

Read the plan. Verify each task carries Depends-on, Parallel-safe, machine-checkable acceptance criteria, a verification step (dmj:writing-plans). Raise blocking gaps with the user before starting. Never begin on `main`/`master` without explicit consent; branch first (dmj:using-git-worktrees policy: main checkout, never a worktree).

## Step 2: Build the dependency wave plan

From each task's Depends-on, group into waves: a wave is the set whose dependencies are all satisfied. Within a wave, file-overlapping tasks cannot run together: push one to a later wave (worktrees are banned; ownership boundaries + sequencing are the policy). State the wave plan to the user.

## Step 3: Fan out per wave (parallel between gates)

Spawn a team (dmj:dispatching-parallel-teams): one named `Agent` per task, all in a single message so the wave runs concurrently, its tasks on a shared list, each teammate claiming one, never fire-and-forget. Hand each the full task text: a teammate inherits none of your context.

Each teammate works the implementer contract from dmj:team-driven-development (skeleton in its `teammate-prompts.md`). The wave-specific delta: a forced plan deviation takes the conservative option and never stalls the wave; the Deviations log is reviewed at the gate because one deviation can invalidate a later task.

You (lead) do not implement; you coordinate, unblock, hold the gates. Only the lead fans out a wave.

## Step 4: Review gate (serial, fresh-context)

A wave's tasks report done: gate before the next wave. Per task, a FRESH-context reviewer (not the implementer) confirms acceptance criteria pass and spec is met (dmj:requesting-code-review); the lead reviews the Deviations log, since a deviation can invalidate a later task. Re-dispatch the implementer for blocking findings; re-review only what failed. Run the full suite to catch cross-task breakage before opening the next wave.

## Step 5: Finish

After the final wave passes and the full suite is green: dmj:verification-before-completion, then dmj:finishing-a-development-branch.

## Stop and ask when

Unresolvable blocker (missing dep, unclear instruction, repeated verification failure), a plan gap that prevents starting, or a fundamental approach change. Do not force through; surface it.

## Headless mode

No interactive user: proceed wave by wave on the plan as written, record assumptions in the run log, PARK per the library default (dmj:using-dmj) as blocking notes. A failing gate halts the affected task, not the whole run; independent waves continue.

Next: **dmj:verification-before-completion**, then **dmj:finishing-a-development-branch**.
