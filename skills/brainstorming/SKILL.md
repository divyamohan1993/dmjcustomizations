---
name: brainstorming
description: Use when starting any creative work (a feature, component, behavior change, schema, or refactor) before writing code, scaffolding, or invoking an implementation skill, especially when the request is vague, names multiple subsystems, or you feel an urge to skip design because it "looks simple".
---

# Brainstorming Ideas Into Designs

Idea -> approved, reviewed design -> implementation.

## Iron Law

NO merged implementation before an approved design. No code, scaffold, or implementation skill until the design is written, adversarially reviewed, user-approved. Spikes = the only code allowed first, one disposable temp clone each (dmj:using-git-worktrees policy; never a worktree), deleted after: conclusions and evidence survive in the doc, code never merges.

**Exactly one exemption exists**, the trivial-change threshold: conjunctive clause list in CLAUDE.md, or dmj:enforcing-quality-gates where no CLAUDE.md exists. Every clause must hold; fail one -> this law applies in full. Judge the clauses, not how simple it feels.

## Ceremony tiers (state the tier to the user)

| Blast radius | Tier | Shape |
|---|---|---|
| Local, reversible (one file, additive) | Light | One AskUserQuestion round, prose design, one lens |
| Cross-module / new dependency / data shape | Standard | Full flow below |
| Security, auth, migration, money, deletion, public API | Heavy | Full flow + spikes + four lenses + threat model (dmj:defending-in-depth) |

Tiers scale the SIZE of the design, NEVER whether approval happens. Every tier, Light included, ends in explicit user approval in THIS conversation before any merge-bound artifact: tracked-file edit, commit, PR, scaffold. Staging in the main tree = a tracked-file edit. While waiting, prepare only in a disposable temp clone; never open a PR pre-approval.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "We already discussed/settled the design earlier" | Not written and approved in THIS conversation = not approved |
| "The order itself IS the approval" | Approval evaluates the WRITTEN design, values filled in. An order approves the request, not the change; the requester has not seen it |

## Flow (parallel between gates, serial at gates)

1. **Fan out context + first questions together.** Teammate sweep (dmj:dispatching-parallel-teams) over code, patterns, constraints WHILE asking up to 4 batched AskUserQuestion items. One at a time, highest architectural impact first, only when each answer shapes the next. Unfamiliar territory, yours or the user's -> **blind-spot pass** first: the unknown unknowns (what good looks like, prior art, potholes).
2. **Decompose if oversized.** Independent subsystems -> sub-projects; brainstorm the first only. Each gets its own spec, plan, build.
3. **Approaches.** Prose tradeoff comparison + your recommendation. Competing on a measurable axis -> parallel spikes, decide on evidence. Threat-model (dmj:defending-in-depth); weigh complexity (dmj:enforcing-performance-budgets). Four bars per candidate: simplest meeting CURRENT requirements (no speculative abstraction/config/indirection); grows in layers atop a working end-to-end product; holds long term (no stopgap built to be replaced); code compat deleted, never shimmed (carve-outs = live-data migrations, ciphertext versions, public API contracts).
4. **Present ONCE**, one annotation pass: architecture, interfaces, data flow, error handling, testing, security, machine-checkable acceptance criteria, assumption ledger (every belief, confirmed or assumed).
5. **Write + commit** `docs/dmj/specs/YYYY-MM-DD-<topic>-design.md` (user path wins). Requirements as EARS lines under `## Requirements`; none marked -> UNAVAILABLE ears lane, not a pass. Reference beats prose: code, a failing test suite, or a throwaway HTML mock carrying intent better -> link it, keep decisions + criteria only.
6. **Adversarial review by FRESH-context teammates**, never self-review. One per lens, concurrent: pre-mortem (prod failure), YAGNI (cut unrequested scope), ambiguity (two engineers build different things), security (dmj:defending-in-depth). Fix blockers; re-run only the failed lens.
7. **User approval gate.** User reviews the committed spec; apply changes, re-review, proceed only on approval. Native plan mode -> its approval satisfies this gate.

## Visuals and headless

**Visuals:** react before wiring: throwaway HTML mock with fake data, AskUserQuestion previews, one Playwright-rendered file, text comparison. No local server.

**Headless (no interactive user):** never deadlock at a gate. Lowest-blast-radius safe default, recorded in the assumption ledger, PARK per the library default (dmj:using-dmj).

## Red flags (stop)

- Code, an implementation skill, a tracked-file edit, a commit, or a PR before approval, even "small/reversible", even holding only the final click.
- An acceptance criterion no script could check, or a spike that merged.

Next: **dmj:writing-plans**.
