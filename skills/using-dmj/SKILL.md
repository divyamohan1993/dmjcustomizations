---
name: using-dmj
description: Use when starting any conversation or task, to route the turn through the right skill before acting.
---

# Using dmjcustomizations

Route, then act. Listed skill covers the turn -> invoke it (Skill tool) first, clarifying questions included. Never `Read` a skill file; the loader preprocesses it. Pure talk on already-verified state -> answer directly.

"Add X" / "fix Y" = WHAT, not HOW. HOW lives in a skill, which sizes process to the work, not to how easy it feels. Sole exemption = the trivial-change threshold; conjunctive clause list in CLAUDE.md and dmj:enforcing-quality-gates; the skill confirms it applies.

**Priority on conflict:** user instructions (CLAUDE.md, direct requests) > skills > default behavior.

**Order and type:** process skills first ("build X" -> dmj:brainstorming, "fix this bug" -> dmj:systematic-debugging), then implementation and domain skills. Rigid (TDD, debugging, verification) = follow exactly. Flexible = adapt the principle. Each states which.

**Capabilities resolve at invocation:** no skill pins a model, version, or date. Newest stable tooling present, native tools first, degrade gracefully.

**Orchestrator law:** main thread orchestrates, does not labor. Substantive work of every kind (implement, sweep files, review, research, bulk read) -> background agents, each its own full context window. Orchestrator context holds routing, gates, conclusions; never work product. Parallel by default, serial only at user gates and real data dependencies. Teammates named, steered, peer-connected, never fire-and-forget. Raw agent output never enters the main thread. Main thread keeps routing, spawn prompts, synthesis, user gates, trivial single-shot lookups cheaper than a spawn. Every spawn = judgement tier (`opus[1m]`, user law: never Sonnet). Spawn contract: dmj:dispatching-parallel-teams.

**Headless default** (binds every skill stating no deviation): fully autonomous, assumptions recorded, user-owned decisions PARKED not taken: irreversible actions, security, cost, public surfaces.

**Conduct:** deleting anything OUTSIDE your working folder = explicit user confirmation, every time, full permissions included. Speed never buys the gates down.

Substantial work wrapping up: dmj:landing-sessions. Next: invoke the skill your task needs.
