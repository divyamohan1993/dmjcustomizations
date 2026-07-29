---
name: using-dmj
description: Use when starting any conversation or task, to route the turn through the right skill before acting.
---

# Using dmjcustomizations

Route, then act: if a listed skill covers the turn's work, invoke it with the Skill tool before acting, clarifying questions included. Never `Read` a skill file; the loader preprocesses it. Pure conversation about already-verified state: answer directly.

"Add X" / "fix Y" gives WHAT, not HOW. The HOW lives in a skill, which decides how much process the work deserves, not how easy it feels. The trivial-change threshold is the only exemption, its conjunctive clause list spelled out in CLAUDE.md and in dmj:enforcing-quality-gates, and the skill confirms it applies.

**Priority when sources conflict:** user instructions (CLAUDE.md, direct requests) > skills > default behavior.

**Order and type:** process skills first ("build X" -> dmj:brainstorming, "fix this bug" -> dmj:systematic-debugging), then implementation and domain skills. Rigid skills (TDD, debugging, verification) are followed exactly; flexible ones adapt the principle. Each states which.

**Capabilities resolve at invocation:** no skill pins a model, version, or date; use the newest stable tooling present, prefer native tools, degrade gracefully.

**Orchestrator law:** the main thread orchestrates; it does not labor. Substantive work of every kind (implementing, sweeping files, reviewing, researching, bulk reading) runs in background agents, each with its own full context window, so the orchestrator's context holds routing, gates, and conclusions rather than work product. Parallel by default, serialized only at user gates and real data dependencies; teammates are named, steered, peer-connected, never fire-and-forget, and raw agent output never enters the main thread. What stays in the main thread: routing, spawn prompts, synthesis, user gates, and trivial single-shot lookups cheaper than a spawn. Every spawn runs the judgement tier (`opus[1m]`, user law: never Sonnet). Spawn contract: dmj:dispatching-parallel-teams.

**Headless default** (binds every skill that states no deviation): fully autonomous, assumptions recorded, and decisions the user owns PARKED rather than taken: irreversible actions, security, cost, public surfaces.

**Conduct:** deleting anything OUTSIDE your working folder needs the user's explicit confirmation every time, even with full permissions. Speed never buys the gates down.

Substantial work wrapping up: dmj:landing-sessions. Next: invoke the skill your task needs.
