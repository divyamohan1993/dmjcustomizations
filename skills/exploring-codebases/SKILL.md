---
name: exploring-codebases
description: Use when about to design, implement, or add code in a codebase you have not mapped, or when adding a helper, utility, type, or pattern that might already exist somewhere in the repo; the deliverable is a persisted repo map plus an anti-redundancy gate, so nothing gets built twice.
---

# Exploring Codebases

map in parallel until you can answer: what lives where, how it connects, what already exists. result: nothing built twice. explaining how it works, no build to follow, no artifact wanted -> dmj:tracing-codebases. quick orientation, no artifact at all -> harness-native explore skill. this one: the persisted map + the gate.

## Iron Law

NO new code in unmapped territory. cannot name where similar logic already lives, or show evidence it does not exist: not ready to add more. reuse beats rebuild. evidence beats memory.

## Parallel sweep (one lens per teammate)

one teammate per lens (dmj:dispatching-parallel-teams). prefer the harness's read-only Explore agent type for pure reads; map-refuting verifier on the judgement tier. every finding carries file:line evidence, lenses resolve overlaps with each other, you synthesize.

| Lens | Question | Reads |
|---|---|---|
| Structure | what lives where? | dir tree, manifests, build config, entry points |
| Flow | how does data move? | routes, handlers, queues, schemas, state |
| Assets | what is reusable? | utils, helpers, shared types, configs, scripts |
| Seams | how do modules connect? | imports, interfaces, contracts, env, DI |
| History | what changes, what breaks? | git log hotspots, churn, TODO/FIXME density |

scale lens count to repo size. merge or add lenses, never serialize what can fan out. depth only where you will work, breadth everywhere else.

## The map

ONE map at `docs/dmj/maps/YYYY-MM-DD-<repo>-map.md`: module responsibilities, connection seams, reusable assets (the anti-redundancy index), conventions (naming, errors, test layout), danger zones (god files, existing duplication). every claim carries a file path. a FRESH-context teammate spot-verifies a sample by trying to refute it before the map is trusted. never self-certify your own map. map exists already: refresh only what structure changes invalidated, never re-sweep. stale maps = debris, delete freely.

## Anti-redundancy gate

before creating any function, helper, type, or file, small helpers included (small helpers = where duplication breeds): search the map's asset index AND grep the repo for plausible names + synonyms. record searches and results in the plan or PR ("checked map + rg 'formatCurrency|toINR|money', none found"). the search is one grep; a duplicate costs maintenance forever. duplicate found later = this gate was skipped, not that it failed.

## Red flags (stop)

- map claim with no file path.
- one serial read-through instead of a parallel sweep.

Next: **dmj:brainstorming** to design in the mapped code, or **dmj:writing-plans** if the design already exists.
