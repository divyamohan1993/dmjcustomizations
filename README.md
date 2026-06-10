# dmjcustomizations

Parallel-first engineering skills for Claude Code. A ground-up rebuild of [superpowers](https://github.com/obra/superpowers) for the agent-team era: terse, date-agnostic, adversarially verified, secure from line 1.

## Why

Superpowers encoded the right discipline on old assumptions: one agent, one chat thread, expensive code, a human watching every step. All four flipped. dmjcustomizations keeps the gates and rebuilds the mechanics.

- **Parallel between gates, serial at gates.** Agent teams fan out; the user approves at a few hard checkpoints. Nothing else blocks.
- **Evidence over claims.** Fresh-context teammates adversarially verify specs, code, and every "done". Self-review is not review.
- **Demonstrate, don't describe.** Competing approaches become disposable worktree spikes with benchmarks, not paragraphs.
- **Dynamic by design.** No hardcoded models, versions, or dates. Skills probe for the strongest model and newest stable tooling at invocation time.
- **Security and performance from line 1.** Threat models at design time, quantum-safe crypto defaults, O(1)-first thinking, budgets enforced in CI.
- **Terse.** Every skill is context-budgeted: under 500 words, and the always-loaded meta-skill under 300.

## Skills

| Skill | One-liner |
|---|---|
| using-dmjcustomizations | Meta-skill, injected each session: how skills are found, routed, and prioritized |
| brainstorming | Idea to approved spec: parallel context sweep, batched questions, evidence-based options |
| writing-plans | Spec to implementation plan with per-task dependencies, parallelizability, acceptance criteria |
| executing-plans | Team executes a plan: tasks claimed concurrently, worktree isolation, review gates |
| team-driven-development | Plan execution in the current session with implementer and reviewer teammates |
| dispatching-parallel-teams | Any 2+ independent tasks: fan out a team, coordinate, synthesize |
| test-driven-development | Iron Law TDD plus an extreme edge-case taxonomy (adversarial, concurrency, boundaries) |
| systematic-debugging | Root cause before fixes; parallel hypothesis investigation |
| verification-before-completion | Evidence before claims; independent fresh-context verification |
| requesting-code-review | Multi-lens parallel review panel: correctness, security, performance, simplicity |
| receiving-code-review | Rigor over performative agreement; verify before implementing feedback |
| using-git-worktrees | Isolation for parallel work and disposable spikes |
| finishing-a-development-branch | Verified finish: merge, PR, or cleanup, with team and worktree teardown |
| writing-skills | TDD for documentation: baseline, write, close loopholes, team-tested |
| defending-in-depth | Security from line 1: threat model, OWASP, zero trust, quantum-safe defaults |
| enforcing-performance-budgets | O(1)-first, measured budgets, cache-first, regressions block merges |
| researching-deeply | Parallel research with adversarial source verification and dated citations |
| exploring-codebases | Five-lens parallel codebase mapping with an anti-redundancy gate: reuse before rebuild |
| explore | Parallel slice-by-slice tracing of how a codebase really works, explained in chat, no artifacts |
| karpathy-laws | Anti-hallucination working rules: receipts before claims, short leash, error-spiral brake |
| harnessing-claude | Capability routing: strongest native Claude feature for every job, never hand-rolled substitutes |
| crafting-experiences | Experience supremacy: Jobs test, first-second hook, cinematic with purpose, zero user burden |

## Install

From GitHub:

```
/plugin marketplace add divyamohan1993/dmjcustomizations
/plugin install dmjcustomizations@dmjcustomizations
```

Or from a local clone:

```
/plugin marketplace add D:\dmjcustomizations
/plugin install dmjcustomizations@dmjcustomizations
```

Then disable superpowers so the two rule systems do not compete:

```
/plugin uninstall superpowers
```

## Provenance

Forked from [obra/superpowers](https://github.com/obra/superpowers) 5.1.0 by Jesse Vincent (MIT). Rebuilt 2026-06-10 by Divya Mohan. MIT licensed.
