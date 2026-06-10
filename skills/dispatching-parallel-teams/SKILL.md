---
name: dispatching-parallel-teams
description: Use when you face 2+ independent tasks (separate test failures, subsystems, files, or investigations) with no shared state or sequential dependency, and working them one at a time would waste time.
---

# Dispatching Parallel Teams

Run independent work concurrently with an Agent Team: spawn teammates with isolated context you construct, let them claim tasks from a shared list, require progress messages + a peer channel, then synthesize.

## When

```dot
digraph d {
  "2+ tasks?" [shape=diamond];
  "Independent?" [shape=diamond];
  "Overlap files?" [shape=diamond];
  "One teammate" [shape=box];
  "Fan out + worktree each" [shape=box];
  "Fan out + shared list" [shape=box];
  "2+ tasks?" -> "One teammate" [label=no];
  "2+ tasks?" -> "Independent?" [label=yes];
  "Independent?" -> "One teammate" [label="no, coupled"];
  "Independent?" -> "Overlap files?" [label=yes];
  "Overlap files?" -> "Fan out + worktree each" [label=yes];
  "Overlap files?" -> "Fan out + shared list" [label=no];
}
```

Good fits: test files failing on different root causes, independent subsystems, parallel research threads, competing spikes. Not for: coupled failures (fixing one may fix others), exploratory debugging before you know what broke, or anything needing one whole-system view. Deterministic fan-out (loops, judge panels, schema-validated outputs, resumable runs) with user opt-in: prefer the Workflow tool; routing table in dmj:harnessing-claude.

## Fan out

1. **Split into domains.** One task per independent problem; name the file set each touches so overlaps surface now.
2. `TeamCreate`, then one `Agent` per domain (always `team_name` + a unique `name`, strongest model available at invocation, max thinking). Overlapping file sets get a worktree each (dmj:using-git-worktrees) or serialize. If TeamCreate is unavailable, run the same domains as native parallel `Agent` calls and synthesize yourself.
3. **Shared task list.** Post all tasks; each teammate CLAIMS one, marks it in-progress, moves to the next free one when done. Claiming prevents two teammates colliding on the same task.

## Each teammate prompt carries

- **Focused scope:** one domain, not "fix everything".
- **Self-contained context:** the errors, file paths, constraints needed, no reliance on your session history.
- **Constraints:** what NOT to touch (e.g. "tests only, no production code").
- **Required output:** root cause + exact changes, so you can synthesize.

## Coordination (never fire-and-forget)

Teammates MUST `SendMessage` a midway progress update and MAY message peers about anything shared (an interface, a fixture, a discovered root cause). Fire-and-forget (spawn and walk away) is forbidden: you lose visibility and teammates duplicate or conflict. You (lead) stay available to unblock.

**Orchestrator posture.** The lead session is the control plane: delegate processing and bulk reading, hold conclusions not transcripts, stay responsive to the user. A user update mid-run is a STEER: relay it to the affected running teammates via `SendMessage` (they receive it on their next turn); never stop or respawn agents for a course correction.

## Synthesize

When teammates report: read each result, check for conflicting edits (same file touched by two), run the full suite to confirm fixes compose, spot-check (parallel workers can make the same systematic error). Resolve conflicts before integrating.

## Headless mode

No interactive user: dispatch on the plan as written, record assumptions, PARK only user-owned decisions (irreversible, security, cost, public surface). One teammate's blocker halts its task, not the others.

## Red flags (stop)

- Spawning teammates with no progress messages or peer channel (fire-and-forget).
- Two teammates on overlapping files with no worktree.
- A scope so broad ("fix all tests") the teammate gets lost.
- Integrating without a full-suite run and conflict check.
- Fanning out coupled work that one investigation would solve faster.

Handoff: this primitive powers **dmj:brainstorming** (context sweep, review lenses), **dmj:executing-plans**, and **dmj:team-driven-development** (per-wave fan-out).
