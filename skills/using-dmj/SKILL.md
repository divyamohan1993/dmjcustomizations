---
name: using-dmj
description: Use when starting any conversation or before any response, including clarifying questions, to find and apply the right skill before acting.
---

# Using dmjcustomizations

**1% rule: any chance a skill applies, invoke it via the Skill tool BEFORE responding**, clarifying questions included. Wrong invocation costs nothing; a skip costs the task. Not optional, not rationalizable. Scope: any turn that acts (reads or edits files, runs commands, spawns agents, commits to an approach). Pure conversation about already-verified state: answer directly.

Never `Read` a skill file. Use the `Skill` tool so it loads correctly.

## Priority when sources conflict

1. User instructions (CLAUDE.md, direct requests) win.
2. Skills override default behavior.
3. Default behavior is the floor.

"Add X" / "fix Y" gives WHAT, not HOW: never skip a skill.

## Order

Process skills before implementation skills. "Build X" -> brainstorming. "Fix this bug" -> systematic-debugging. Then domain skills.

## Types

- **Rigid** (TDD, debugging, verification): follow exactly, never adapt away the discipline.
- **Flexible** (patterns): adapt the principle to context.

Skill states which.

## Capabilities resolve at invocation

Skills name no fixed model, version, or date. At invocation use the strongest model and newest stable tooling, prefer native tools, degrade gracefully if absent. Delegated work uses Agent Teams (teammates that message each other), never a lone fire-and-forget agent. No TeamCreate -> same stages as parallel Agent calls.

Default everything to parallel (teams, in-turn tool batching, spikes, lenses); serialize ONLY at user gates and real data dependencies. Speed never buys robustness, features, or performance down: the gates stay.

## Hard conduct rule

Deleting anything OUTSIDE your working folder needs the user's explicit confirmation, every time, even with full permissions. Cleaning up files you created inside it is free.

## Red flags (you are rationalizing)

| Thought | Reality |
|---|---|
| "Just a simple question" | A question that leads to action is a task. Check before acting. |
| "I need context first" | Skill check precedes clarifying questions. |
| "I'll do one thing first" | Check BEFORE any action. |
| "I remember this skill" | Skills evolve. Re-invoke it. |

Substantial work wrapping up: dmj:landing-sessions.

Next: invoke the skill your task needs.
