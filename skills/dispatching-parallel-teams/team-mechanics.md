# Agent Team Mechanics

Harness behavior behind the spawn contract in SKILL.md: what to enable, what a teammate really inherits, and the limits that change how you plan a fan-out. Source of truth, and deeper than this file: https://code.claude.com/docs/en/agent-teams

## Enable

```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

Experimental, off by default, settable in settings.json or the environment. Unset, no team is set up at session start, no team directories are written, and no teammate is spawned or proposed. A spawn still runs as a result-only worker: own context window, reports to its caller, no peer messaging, no shared task list. Probe once at the start of a run rather than assuming either shape.

Either way the lead never spawns without the user's approval, and the agent panel lists both shapes identically, so a populated panel is not proof a team formed. Ask for a team explicitly when the work needs peer messaging.

## What a teammate inherits

| Carried over | Not carried over |
|---|---|
| CLAUDE.md, MCP servers, skills, loaded fresh like any session | The lead's conversation history: none of it |
| The lead's permission mode at spawn time | The lead's `/model` selection, unless the spawn or the default-teammate-model setting says so |
| The lead's effort level | Anything you only said in your own thread |

Model and fast mode are fixed at spawn; effort applies to later turns. This is why the spawn prompt must quote the errors, paths, interfaces, and constraints in full: a teammate cannot ask you for what it never saw, and a pointer into your session resolves to nothing.

An agent-type definition (project, user, plugin, or CLI scope) can be reused as a teammate role: its `tools` allowlist and `model` are honored and its body is appended to the teammate's system prompt. Its `skills` and `mcpServers` frontmatter fields are NOT applied to a teammate, which loads those from project and user settings instead. Messaging and task-management tools stay available even when `tools` restricts everything else.

## Shared task list

Three states (pending, in progress, completed) plus dependencies: a pending task whose dependencies are unresolved cannot be claimed, and completing a task unblocks its dependents automatically. Claiming is file-locked against races. The lead may assign explicitly, and a teammate self-claims the next unassigned unblocked task when it finishes one.

Sizing per the official docs: 3 to 5 teammates, 5 to 6 tasks each, each task a self-contained deliverable (a function, a test file, a review). Granularity rationale lives with the plan: dmj:writing-plans.

## Enforce gates with hooks

| Hook | Fires | Exit code 2 |
|---|---|---|
| `TeammateIdle` | a teammate is about to go idle | keeps it working, with your feedback |
| `TaskCreated` | a task is being created | blocks creation, with your feedback |
| `TaskCompleted` | a task is being marked complete | blocks completion, with your feedback |

This is the enforcement path for a gate that must not depend on a teammate remembering it: a quality gate wired here holds even when the instruction is ignored (dmj:equipping-projects wires hooks per repo).

## Limits that change plans

- **No nested teams.** A teammate cannot spawn teammates. Any stage needing its own fan-out runs at the lead.
- **In-process teammates cannot run background workers.** Their own spawns run in the foreground; asking for background returns an error, because that work cannot outlive the lead's process.
- **The lead is fixed** for the session's lifetime, and a session has exactly one team. No promotion, no transfer, no second team.
- **Resumption does not restore in-process teammates.** After a resume the lead may message teammates that no longer exist; spawn new ones instead.
- **Task status lags.** A teammate can finish work and fail to mark the task complete, silently blocking its dependents. Check the work, then nudge or update the status.
- **Shutdown is not instant.** A teammate finishes its current request or tool call first.
- **Two teammates editing one file overwrite each other.** Disjoint file-ownership sets in the prompts, or sequence the tasks (dmj:using-git-worktrees; worktrees banned by user law).
- **Permission prompts surface at the lead.** Pre-approving the run's common operations before spawning prevents a fan-out that stalls on prompts.

## Where state lives

Team config and mailboxes live under the user's Claude home, keyed by a session-derived name; the task list persists locally for resumed sessions while the team config is removed at session end. Runtime state is machine-written: never hand-edit or pre-author it, and never treat a project-local copy as configuration.

Back to SKILL.md for the spawn contract and coordination law.
