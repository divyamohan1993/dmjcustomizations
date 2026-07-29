---
name: brainstorming
description: Use when starting any creative work (a feature, component, behavior change, schema, or refactor) before writing code, scaffolding, or invoking an implementation skill, especially when the request is vague, names multiple subsystems, or you feel an urge to skip design because it "looks simple".
---

# Brainstorming Ideas Into Designs

Idea to approved, reviewed design before implementation.

## Iron Law

NO merged implementation before an approved design: no code, scaffold, or implementation skill until the design is written, adversarially reviewed, user-approved. Spikes are the only code allowed first, and only in a disposable worktree.

**Exactly one exemption exists**, the trivial-change threshold defined in CLAUDE.md: one file, reversible, no new dependency, no schema or stored-data change, nothing touching auth, crypto, secrets, PII, money, deletion, or a public surface, no production config. Every clause must hold; fail one and this law applies in full. The list is conjunctive because "too simple to need a design" is the rationalization this law stops: judge against the clauses, not the feeling.

## Ceremony tiers (state the tier to the user)

| Blast radius | Tier | Shape |
|---|---|---|
| Local, reversible (one file, additive) | Light | One AskUserQuestion round, prose design, one lens |
| Cross-module / new dependency / data shape | Standard | Full flow below |
| Security, auth, migration, money, deletion, public API | Heavy | Full flow + spikes + four lenses + threat model (dmj:defending-in-depth) |

Tiers scale the SIZE of the design, NEVER whether approval happens. Every tier, Light included, ends with explicit user approval in THIS conversation before any merge-bound artifact: a tracked-file edit, commit, PR, or scaffold. Staging a change in the main tree IS a tracked-file edit. While waiting, prepare only in a disposable worktree; never open a PR pre-approval.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "We already discussed/settled the design earlier" | Not written and approved in THIS conversation = not approved |
| "I will prepare everything and only hold the final click" | Preparation outside a disposable worktree IS implementation |
| "Asking approval now is obstruction; the deadline is real" | Approval costs one message and seconds; an unapproved merge-bound artifact is the real obstruction |
| "The order itself IS the approval" | Approval evaluates the WRITTEN design with values filled in. An order approves the request, not the change; the requester has not seen it |

## Flow (parallel between gates, serial at gates)

1. **Fan out context + first questions together.** Teammate sweep (dmj:dispatching-parallel-teams) over existing code, patterns, constraints WHILE asking up to 4 batched AskUserQuestion items; switch to a one-question-at-a-time interview, highest architectural impact first, only when each answer shapes the next question. Territory unfamiliar to you or the user: open with a **blind-spot pass**, naming the unknown unknowns (what good looks like, prior art, potholes) before any design.
2. **Decompose if oversized.** Request spans independent subsystems: split into sub-projects, brainstorm only the first. Each gets its own spec, plan, build.
3. **Approaches.** Prose tradeoff comparison + your recommendation. When they genuinely compete on a measurable axis, run parallel spikes, decide on evidence. Threat-model security (dmj:defending-in-depth); weigh complexity (dmj:enforcing-performance-budgets).
4. **Present the design ONCE**, one annotation pass. Cover architecture, interfaces, data flow, error handling, testing, security, a machine-checkable acceptance-criteria list, and an assumption ledger (every belief, confirmed or assumed).
5. **Write and commit** to `docs/dmj/specs/YYYY-MM-DD-<topic>-design.md` (user path wins). A reference beats prose: when source code, a failing test suite, or a throwaway HTML mock carries the intent better, the spec links that reference and keeps only the decisions and criteria.
6. **Adversarial review by FRESH-context teammates**, never self-review. One lens each: pre-mortem (prod failure), YAGNI (cut unrequested scope), ambiguity (two engineers building different things), security (dmj:defending-in-depth). One named `Agent` per lens, all spawned in a single message. Fix blocking findings; re-run only the failed lens.
7. **User approval gate.** User reviews the committed spec; apply changes, re-review, proceed only on approval. Native plan mode present: its approval satisfies this gate.

## Spikes, visuals, headless

**Spikes:** one disposable worktree each (dmj:using-git-worktrees), force-discarded after. Conclusions and evidence survive in the doc; code never merges.

**Visuals:** react before wiring: a throwaway HTML mock with fake data, AskUserQuestion previews, one Playwright-rendered file, or text comparison. No local server.

**Headless (no interactive user):** at each gate, record the choice in the assumption ledger, pick the lowest-blast-radius safe default, PARK decisions the user must own (irreversible, security, cost, public surface). Never deadlock.

## Red flags (stop)

- Code or an implementation skill before approval.
- Editing a tracked file, committing, or opening a PR before approval, even "small/reversible", even holding only the final click.
- Treating a tier as permission to skip approval; tiers size the design, not the gate.
- Reviewing your own design in the same context.
- Questions one at a time instead of batched.
- An acceptance criterion no script could check, or a spike that merged.

Next: **dmj:writing-plans**.
