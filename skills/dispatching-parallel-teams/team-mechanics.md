# Agent Team Mechanics

Harness behavior behind the spawn contract in SKILL.md: what to enable, what a teammate inherits, the limits that change a fan-out plan. Source of truth, deeper than this file: https://code.claude.com/docs/en/agent-teams

## Enable

```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

- Experimental, off by default. settings.json or the environment. Unset -> no team at session start, no team directories written, no teammate spawned or proposed; a spawn still runs as a result-only worker (own context window, reports to its caller, no peer messaging, no shared task list). Probe once per run; never assume a shape.
- The lead never spawns without the user's approval either way. The agent panel lists both shapes identically, so a populated panel is not proof a team formed. Ask for a team explicitly when the work needs peer messaging.

## What a teammate inherits

| Carried over | Not carried over |
|---|---|
| CLAUDE.md, MCP servers, skills, loaded fresh like any session | The lead's conversation history: none of it |
| The lead's permission mode at spawn time | The lead's `/model` selection, unless the spawn or the default-teammate-model setting says so |
| The lead's effort level | Anything you only said in your own thread |

- Model and fast mode fix at spawn; effort applies to later turns. Hence spawn prompts quote errors, paths, interfaces, constraints in full: a teammate cannot ask for what it never saw.
- An agent-type definition (project, user, plugin, CLI scope) can be reused as a teammate role: its `tools` allowlist and `model` are honored, its body appended to the teammate's system prompt. Its `skills` and `mcpServers` frontmatter are NOT applied; those load from project and user settings. Messaging and task-management tools stay available even when `tools` restricts everything else.

## Shared task list

- Three states (pending, in progress, completed) + dependencies. A pending task with unresolved dependencies cannot be claimed; completing one unblocks its dependents automatically. Claiming is file-locked against races.
- Lead may assign explicitly; a teammate self-claims the next unassigned unblocked task on finishing one.
- Sizing per the official docs: 3 to 5 teammates, 5 to 6 tasks each, each task a self-contained deliverable (a function, a test file, a review). Granularity rationale: dmj:writing-plans.

## Enforce gates with hooks

| Hook | Fires | Exit code 2 |
|---|---|---|
| `TeammateIdle` | a teammate is about to go idle | keeps it working, with your feedback |
| `TaskCreated` | a task is being created | blocks creation, with your feedback |
| `TaskCompleted` | a task is being marked complete | blocks completion, with your feedback |

Enforcement path for any gate that must not depend on a teammate remembering it: wired here, it holds even when the instruction is ignored (dmj:equipping-projects wires hooks per repo).

## Limits that change plans

- **No nested teams.** A teammate cannot spawn teammates. Any stage needing its own fan-out runs at the lead.
- **In-process teammates cannot run background workers.** Their spawns run foreground; background returns an error (that work cannot outlive the lead's process).
- **The lead is fixed** for the session's lifetime; one team per session. No promotion, no transfer, no second team.
- **Resumption does not restore in-process teammates.** The lead may message teammates that no longer exist; spawn new ones.
- **Task status lags.** A teammate can finish work and never mark the task complete, silently blocking dependents. Check the work, then nudge or update status.
- **Shutdown is not instant.** A teammate finishes its current request or tool call first.
- **Two teammates editing one file overwrite each other.** Disjoint file-ownership sets in the prompts, or sequence the tasks (dmj:using-git-worktrees; worktrees banned by user law).
- **Permission prompts surface at the lead.** Pre-approve the run's common operations before spawning, or a fan-out stalls on prompts.

## Where state lives

Team config and mailboxes live under the user's Claude home, keyed by a session-derived name. Task list persists locally for resumed sessions; team config is removed at session end. Runtime state is machine-written: never hand-edit or pre-author it, never treat a project-local copy as configuration.

Back to SKILL.md for the spawn contract and coordination law.
