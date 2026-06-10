---
name: brainstorming
description: Use when starting any creative work (a feature, component, behavior change, schema, or refactor) before writing code, scaffolding, or invoking an implementation skill, especially when the request is vague, names multiple subsystems, or you feel an urge to skip design because it "looks simple".
---

# Brainstorming Ideas Into Designs

Turn an idea into an approved, reviewed design before implementation.

## Iron Law

NO merged implementation before an approved design: no code, scaffold, or implementation skill until the design is written, adversarially reviewed, and user-approved. Every task, including the ones that look too simple to need a design. Spikes are the only code allowed first, and only in a disposable worktree.

## Ceremony tiers (state the tier to the user)

| Blast radius | Tier | Shape |
|---|---|---|
| Local, reversible (one file, additive) | Light | One AskUserQuestion round, prose design, one reviewer lens |
| Cross-module / new dependency / data shape | Standard | Full flow below |
| Security, auth, migration, money, deletion, public API | Heavy | Full flow + competing spikes + all four lenses + mandatory threat model (dmjcustomizations:defending-in-depth) |

Tiers scale the SIZE of the design, NEVER whether approval happens. Every tier, including Light, ends with explicit user approval in THIS conversation before any merge-bound artifact: a tracked-file edit, commit, PR, or scaffold. While waiting, prepare changes only in a disposable worktree; never open a PR pre-approval.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "We already discussed/settled the design earlier" | If it is not written and approved in THIS conversation, it is not approved |
| "I will prepare everything and only hold the final click" | Preparation outside a disposable worktree IS implementation |

## Flow (parallel between gates, serial at gates)

1. **Fan out context + first questions together.** Spawn a teammate sweep (dmjcustomizations:dispatching-parallel-teams) over existing code, patterns, and constraints WHILE you ask up to 4 batched AskUserQuestion items (multiple choice preferred). Never serialize these.
2. **Decompose if oversized.** If the request spans independent subsystems, split into sub-projects and brainstorm only the first. Each gets its own spec, plan, build.
3. **Approaches.** Prose tradeoff comparison with your recommendation. When approaches genuinely compete on a measurable axis (perf, ergonomics, footprint), run parallel spikes and decide on evidence. Threat-model security (dmjcustomizations:defending-in-depth); weigh complexity (dmjcustomizations:enforcing-performance-budgets).
4. **Present the design ONCE** as one structured document for a single annotation pass. Cover architecture, interfaces, data flow, error handling, testing, security, a machine-checkable acceptance-criteria list, and an assumption ledger (every belief, confirmed or assumed).
5. **Write and commit** to `docs/dmjcustomizations/specs/YYYY-MM-DD-<topic>-design.md` (user path preference wins).
6. **Adversarial review by FRESH-context teammates**, never self-review. One lens each: pre-mortem (prod failure), YAGNI (cut unrequested scope), ambiguity (two engineers building different things), security (dmjcustomizations:defending-in-depth). If TeamCreate is unavailable, run the lenses as native parallel `Agent` calls. Fix blocking findings; re-run only the failed lens.
7. **User approval gate.** Ask the user to review the committed spec; apply changes, re-review, proceed only on approval.

## Spikes, visuals, headless

**Spikes:** one disposable worktree each (dmjcustomizations:using-git-worktrees), force-discarded after. Conclusions and evidence survive in the doc; the code never merges.

**Visuals:** no local server. Use AskUserQuestion previews, or render one HTML file with Playwright, else a text comparison.

**Headless (no interactive user):** at each gate, record the choice in the assumption ledger, pick the lowest-blast-radius safe default, and PARK decisions the user must own (irreversible, security, cost, public surface). Never deadlock.

## Red flags (stop)

- Code or an implementation skill before approval (only next skill: dmjcustomizations:writing-plans).
- Editing a tracked file, committing, or opening a PR before approval, even "small/reversible", even holding only the final click.
- Treating a tier as permission to skip approval; tiers size the design, not the gate.
- Reviewing your own design in the same context.
- Questions asked one at a time instead of batched.
- An acceptance criterion no script could check, or a spike that merged.

Next: **dmjcustomizations:writing-plans**.
