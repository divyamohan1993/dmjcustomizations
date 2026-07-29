---
name: writing-plans
description: Use when you have an approved spec or design and need an implementation plan before touching code, especially a multi-task build you intend to fan out across a team or execute task-by-task.
---

# Writing Plans

Approved design -> a task graph a teammate with zero session context can execute correctly. DRY, YAGNI, TDD, frequent commits.

Save to `docs/dmj/plans/YYYY-MM-DD-<feature>.md` (user path wins; same root as specs, maps, skill-learnings).

## Before tasks

- **Scope.** Design spans independent subsystems -> one plan each, each producing working testable software alone.
- **File map.** Every file created/modified + its one responsibility. Small focused files; split by responsibility, not layer; follow existing patterns.
- **Granularity.** One task = one self-contained deliverable (a function, a test file, a review). Too small -> coordination outweighs the work; too large -> it runs long before a wrong turn surfaces.
- **Requirements.** Every requirement goes as an EARS pattern under `## Requirements` (The / When / While / If-then / Where), so the generated ears lane verifies it. Acceptance criteria stay machine-checkable commands.

## Plan header

```markdown
# <Feature> Implementation Plan

**Goal:** <one sentence> · **Architecture:** <2-3 sentences> · **Tech stack:** <key libs>
**Execution:** team-driven-development or executing-plans. Tasks are checkboxes.
```

## Each task declares (parallel-first)

- **Depends on:** task IDs that must finish first (or `none`).
- **Parallel-safe:** `yes` only if no unlisted dependency AND its file set overlaps no other runnable task. Overlap -> serialize (worktrees banned: dmj:using-git-worktrees).
- **Files:** exact create / modify (`path:lines`) / test paths.
- **Acceptance criteria:** machine-checkable, each a command + expected result (exit code, test name, output, benchmark threshold).
- **Steps:** TDD, one action each (2-5 min): failing test, run it fail, minimal code, run it pass, commit.
- **Verification:** the command(s) proving the criteria, run before marking done.

## Task template

Steps carry the spec at full fidelity: code inline, or a pointer to a COMMITTED artifact that already is the spec (failing test file, fixture, HTML mock, source function to port). Prose carries the decision and the criteria, nothing else.

````markdown
### Task N: <name>
**Depends on:** <ids|none> · **Parallel-safe:** <yes|no>
**Files:** Create `a.ts` · Test `a.test.ts` · **Acceptance:** `pnpm test a.test.ts` → 3 pass

- [ ] Failing test (code) → run → FAIL · minimal code (code) → run → PASS
- [ ] Verify acceptance command, then commit
````

## No placeholders (plan failures)

A step describing WHAT with no code block and no committed-artifact pointer = a placeholder. So are "TBD", "implement later", "add error handling / validation / edge cases", "write tests for the above". Three that hide better: "similar to Task N" (tasks land out of order in fresh contexts; repeat it in full), a symbol no task defines, a pointer to an uncommitted artifact.

## Performance and security

Budgets into acceptance criteria (dmj:enforcing-performance-budgets): lowest achievable complexity, no unjustified O(n²)+. Threat model into tasks as explicit steps + criteria (dmj:defending-in-depth): validation, parameterized queries, least privilege.

## Fresh-context review (never self-review)

Plan complete -> ONE fresh-context teammate, handed spec + plan, checks: every spec requirement maps to a task; no placeholders; type and signature names consistent across tasks; dependency edges acyclic; every acceptance criterion machine-checkable. Fix blockers; re-dispatch only for a structural blocker.

Headless: same checklist, SEPARATE pass (or a fresh `Agent` call), recorded as run. Never skip the gate silently.

Next: **dmj:team-driven-development** (same session) or **dmj:executing-plans** (fresh session).
