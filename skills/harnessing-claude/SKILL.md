---
name: harnessing-claude
description: Use when orchestrating any nontrivial task and choosing its execution shape (teams, workflows, plan mode, goal loops, background runs), when a stronger reviewer or structured output would raise quality, or when library or API knowledge may be stale.
---

# Harnessing Claude

Route every job through the strongest native capability available. Probe at invocation (tool list, ToolSearch), degrade gracefully, never hand-roll what the harness provides.

## Capability routing

| Need | Use |
|---|---|
| Parallel work, shared context, peer messaging | Named teammates: several `Agent(name:)` calls in ONE message, background, steered via `SendMessage({to: name})`. Spawn contract, enabling gate, no-teams fallback: dmj:dispatching-parallel-teams |
| Deterministic fan-out: loops, judge panels, schema-validated outputs, resumable runs | Workflow tool (user opt-in): pipeline() default, parallel() only at true barriers, agent(prompt, {schema}) for validated structured returns |
| A procedure a skill already owns | Skill tool: invoke it, never re-derive it (dmj:using-dmj) |
| Design approval gate | Native plan mode when present, else the skill's own gate. A teammate spawned needing plan approval stays read-only until the lead approves, and the lead approves autonomously, so approval criteria belong in the spawn prompt |
| Enforce a gate on team work | `TeammateIdle`, `TaskCreated`, `TaskCompleted` hooks: exit code 2 blocks the transition and returns feedback to the agent. Enforcement outranks instruction |
| Stronger reviewer at a gate | advisor tool when available: before committing to an approach, and before any done-claim |
| Deterministic finish line (tests pass, score threshold, queue empty) | Goal loop (/goal or the harness's goal primitive): machine-checkable criteria as the stop condition + an explicit turn cap; an independent evaluator judges done, never the working model |
| Fresh-context read-only sweep | Explore agent type (worktree isolation never: banned by user law, dmj:using-git-worktrees) |
| Library or API truth | context7 MCP or official docs via WebFetch; never memory (dmj:verification-before-completion) |
| Deferred tool needed | ToolSearch "select:Name" first; a direct call fails without it |
| Long or recurring jobs | run_in_background, Monitor; a time loop or Cron/schedule for routines, interval matched to how fast the watched thing changes |
| Cross-session knowledge | auto-memory records what sessions surface; capture decisions + reasoning at decision time, curate at landing (dmj:landing-sessions) |
| User choices | AskUserQuestion: batch up to 4, multiSelect, previews for visual compare |

Dynamic skill authoring (argument and inline-command preprocessing): dmj:writing-skills.

## Tiers

Every spawn runs the judgement tier, user law: floating alias + spawn contract in dmj:dispatching-parallel-teams; never Sonnet, never below, max thinking and effort where exposed. Model menus differ by surface and generation -> probe what the spawn tool advertises, set nothing the environment forces. Lead orchestrates on whatever model the session runs.

## Loops close the automation

Skill gates are machine-checkable so loops can consume them: acceptance criteria (dmj:writing-plans), budgets (dmj:enforcing-performance-budgets), screenshot gates (dmj:art-directing) all double as goal conditions. Hand the criteria to the loop; the working model never certifies its own finish.

## Red flags (stop)

- Hand-rolled orchestration where Workflow or teams exist.
- Serial agent calls for independent work.
- A from-memory library answer with context7 or WebFetch available.
- Polling a background task the harness announces.
- Turn-by-turn babysitting of a machine-checkable finish line: that is a goal loop.
- A pinned model version in any instruction file (floating tier aliases in dmj:dispatching-parallel-teams are the mechanism).
- Raw agent transcripts in the orchestration thread.

**Headless:** all routing applies unattended; advisor and plan-mode gates park for the user, never block.

Next: dmj:dispatching-parallel-teams for the team shape, or the task's domain skill.
