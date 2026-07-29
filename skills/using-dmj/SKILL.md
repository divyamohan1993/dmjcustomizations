---
name: using-dmj
description: Use when starting any conversation or task, to route the turn through the right skill before acting.
---

# Using dmjcustomizations

Route, then act: when a listed skill covers the turn's work, invoke it via the Skill tool before acting, clarifying questions included. The skill, not the feeling, decides how much process the work deserves; CLAUDE.md's trivial-change threshold is the only exemption, and the skill is what confirms it applies. Pure conversation about already-verified state: answer directly. Never `Read` a skill file; the Skill tool loads it correctly.

## Priority when sources conflict

1. User instructions (CLAUDE.md, direct requests) win.
2. Skills override default behavior.
3. Default behavior is the floor.

"Add X" / "fix Y" gives WHAT, not HOW; the HOW lives in a skill.

## Order and types

Process skills before implementation skills: "build X" -> dmj:brainstorming, "fix this bug" -> dmj:systematic-debugging, then domain skills. **Rigid** skills (TDD, debugging, verification) are followed exactly; **flexible** ones adapt the principle to context. Each states which.

## Capabilities resolve at invocation

Skills pin no model, version, or date: at invocation use the newest stable tooling present, prefer native tools, degrade gracefully. Delegated work is named `Agent` spawns issued together in one message, background by default, on `opus[1m]` (judgement) or `sonnet[1m]` (mechanical), steered mid-run and coordinated via `SendMessage`; never a lone fire-and-forget agent, never raw agent output in the main thread. Default to parallel (teams, in-turn tool batching, spikes, lenses); serialize only at user gates and real data dependencies. Speed never buys the gates down.

## Hard conduct rule

Deleting anything OUTSIDE your working folder needs the user's explicit confirmation, every time, even with full permissions. Cleaning up files you created inside it is free.

Substantial work wrapping up: dmj:landing-sessions.

Next: invoke the skill your task needs.
