---
name: harnessing-claude
description: Use when orchestrating any nontrivial task and choosing its execution shape (teams, workflows, plan mode, goal loops, background runs), when a stronger reviewer or structured output would raise quality, or when library or API knowledge may be stale.
---

# Harnessing Claude

Route every job through the strongest native capability available. Probe availability at invocation (tool list, ToolSearch); degrade gracefully; never hand-roll what the harness provides.

## Capability routing

| Need | Use |
|---|---|
| Parallel work, shared context, peer messaging | Named teammates: several `Agent(name:)` calls in ONE message, background, steered mid-run via `SendMessage({to: name})`. Spawn contract, the enabling gate, and the no-teams fallback: dmj:dispatching-parallel-teams |
| Deterministic fan-out: loops, judge panels, schema-validated outputs, resumable runs | Workflow tool (requires user opt-in): pipeline() default, parallel() only at true barriers, agent(prompt, {schema}) for validated structured returns |
| A procedure a skill already owns | Skill tool: invoke it, never re-derive it (dmj:using-dmj) |
| Design approval gate | Native plan mode when present; else the skill's own gate. A teammate can be spawned needing plan approval: it stays read-only until the lead approves, and the lead approves autonomously, so its approval criteria belong in the spawn prompt |
| Enforce a gate on team work | `TeammateIdle`, `TaskCreated`, `TaskCompleted` hooks: exit code 2 blocks the transition and returns feedback to the agent. Enforcement outranks instruction |
| Stronger reviewer at a gate | advisor tool when available: consult before committing to an approach and before any done-claim |
| Deterministic finish line (tests pass, score threshold, queue empty) | Goal loop (/goal or the harness's goal primitive): hand it the machine-checkable criteria as the stop condition plus an explicit turn cap; an independent evaluator judges done, never the working model |
| Fresh-context read-only sweep | Explore agent type; isolation:"worktree" when parallel edits could collide |
| Library or API truth | context7 MCP or official docs via WebFetch; never memory (dmj:verification-before-completion) |
| Deferred tool needed | ToolSearch "select:Name" first; direct call fails without it |
| Long or recurring jobs | run_in_background, Monitor; a time loop or Cron/schedule for routines, interval matched to how fast the watched thing changes |
| Cross-session knowledge | memory files + MEMORY.md index, written at decision time (dmj:landing-sessions) |
| User choices | AskUserQuestion: batch up to 4, multiSelect, previews for visual compare |

Dynamic skill authoring (argument and inline-command preprocessing): dmj:writing-skills.

## Tiers

Declare a spawn's tier by ROLE, never by family member: `opus[1m]` for judgement work, `sonnet[1m]` for mechanical or criteria-bounded work, never below Sonnet, max thinking and effort where the harness exposes them. Model menus differ by surface and generation, so probe what the spawn tool advertises, let the alias resolve to the newest stable model in that role, and set nothing the environment already forces. The lead orchestrates on whatever model the session runs. Full spawn contract: dmj:dispatching-parallel-teams.

## Loops close the automation

Skill gates are written machine-checkable precisely so loops can consume them: acceptance criteria (dmj:writing-plans), budgets (dmj:enforcing-performance-budgets), and screenshot gates (dmj:art-directing) double as goal conditions. Hand the criteria to the loop; the working model never certifies its own finish.

## Red flags (stop)

- Hand-rolled orchestration where Workflow or teams exist.
- Serial agent calls for independent work.
- A from-memory library answer while context7 or WebFetch is available.
- Polling a background task the harness will announce.
- Babysitting turn-by-turn a task whose finish line is already machine-checkable: that is a goal loop.
- A pinned model version in any instruction file; the floating tier aliases (`opus[1m]`, `sonnet[1m]`) are the mechanism, not a violation.
- Raw agent transcripts relayed into the orchestration thread.

**Headless:** all routing applies unattended; advisor and plan-mode gates park for the user, never block.

Next: dmj:dispatching-parallel-teams for the team shape, or the task's domain skill.
