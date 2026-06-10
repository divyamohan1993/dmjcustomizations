---
name: harnessing-claude
description: Use when orchestrating any nontrivial task and choosing its execution shape (teams, workflows, plan mode, background runs), when a stronger reviewer or structured output would raise quality, when library or API knowledge may be stale, or when unsure which Claude Code capability fits the job.
---

# Harnessing Claude

Route every job through the strongest native capability available. Probe availability at invocation (tool list, ToolSearch); degrade gracefully; never hand-roll what the harness provides.

## Capability routing

| Need | Use |
|---|---|
| Parallel work, shared context, peer messaging | Agent Teams: TeamCreate + Agent(team_name, name) + SendMessage |
| Deterministic fan-out: loops, judge panels, schema-validated outputs, resumable runs | Workflow tool (requires user opt-in): pipeline() default, parallel() only at true barriers, agent(prompt, {schema}) for validated structured returns |
| Design approval gate | Native plan mode when present; else the skill's own gate |
| Stronger reviewer at a gate | advisor tool when available: consult before committing to an approach and before any done-claim |
| Fresh-context read-only sweep | Explore agent type; isolation:"worktree" when parallel edits could collide |
| Library or API truth | context7 MCP or official docs via WebFetch; never memory (dmj:verification-before-completion) |
| Deferred tool needed | ToolSearch "select:Name" first; direct call fails without it |
| Long or recurring jobs | run_in_background, Monitor; Cron or schedule for routines |
| Cross-session knowledge | memory files + MEMORY.md index, written at decision time (dmj:landing-sessions) |
| User choices | AskUserQuestion: batch up to 4, multiSelect, previews for visual compare |

Dynamic skill authoring ($ARGUMENTS, !`cmd` preprocessing): dmj:writing-skills.

## Maximums

Strongest available model on every spawn; max thinking and effort where the harness exposes them; long-context tier for large inputs. Probe first: set nothing the environment already forces.

## Red flags (stop)

- Hand-rolled orchestration where Workflow or teams exist.
- Serial agent calls for independent work.
- A from-memory library answer while context7 or WebFetch is available.
- Polling a background task the harness will announce.
- A hardcoded model name in any instruction file.

**Headless:** all routing applies unattended; advisor and plan-mode gates park for the user, never block.

Next: dmj:dispatching-parallel-teams for the team shape, or the task's domain skill.
