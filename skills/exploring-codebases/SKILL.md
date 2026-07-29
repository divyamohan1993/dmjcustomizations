---
name: exploring-codebases
description: Use when about to design, implement, or add code in a codebase you have not mapped, or when adding a helper, utility, type, or pattern that might already exist somewhere in the repo; the deliverable is a persisted repo map plus an anti-redundancy gate, so nothing gets built twice.
---

# Exploring Codebases

Map a codebase in parallel until you can answer: what lives where, how it connects, what already exists, so nothing gets built twice. Explaining how it works with no build to follow and no artifact wanted is dmj:tracing-codebases instead; quick orientation with no artifact at all is the harness-native explore skill. This one exists for the persisted map and the gate.

## Iron Law

NO new code in unmapped territory. Cannot name where similar logic already lives, or show evidence it does not exist: not ready to add more. Reuse beats rebuild; evidence beats memory.

## Parallel sweep (one lens per teammate)

One teammate per lens, delegated per dmj:dispatching-parallel-teams; prefer the harness's read-only Explore agent type for pure reads, and put the map-refuting verifier on the judgement tier. Every finding carries file:line evidence, lenses resolve overlaps with each other, and you synthesize.

| Lens | Question | Reads |
|---|---|---|
| Structure | What lives where? | Dir tree, manifests, build config, entry points |
| Flow | How does data move? | Routes, handlers, queues, schemas, state |
| Assets | What is reusable? | Utils, helpers, shared types, configs, scripts |
| Seams | How do modules connect? | Imports, interfaces, contracts, env, DI |
| History | What changes, what breaks? | git log hotspots, churn, TODO/FIXME density |

Scale the lens count to repo size; merge or add lenses, but never serialize what can fan out. Depth only where you will work; breadth everywhere else.

## The map

Synthesize the fragments into ONE map at `docs/dmj/maps/YYYY-MM-DD-<repo>-map.md`: module responsibilities, connection seams, reusable assets (the anti-redundancy index), conventions (naming, errors, test layout), danger zones (god files, duplication already present). Every claim carries a file path. A FRESH-context teammate spot-verifies a sample of claims by trying to refute them before the map is trusted; never self-certify your own map. A map already exists: refresh only what structure changes invalidated, never re-sweep. Stale maps are debris: delete freely.

## Anti-redundancy gate

Before creating any function, helper, type, or file, small helpers included (small helpers are where duplication breeds): search the map's asset index AND grep the repo for plausible names and synonyms. Record the searches and results in the plan or PR ("checked map + rg 'formatCurrency|toINR|money', none found"). The search is one grep; a duplicate costs maintenance forever. A duplicate discovered later means this gate was skipped, not that it failed.

## Red flags (stop)

- A map claim without a file path.
- One serial read-through instead of a parallel sweep.

Next: **dmj:brainstorming** to design in the mapped code, or **dmj:writing-plans** if the design already exists.
