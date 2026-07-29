---
name: writing-plans
description: Use when you have an approved spec or design and need an implementation plan before touching code, especially a multi-task build you intend to fan out across a team or execute task-by-task.
---

# Writing Plans

Turn an approved design into a task graph a teammate with no session context can execute correctly. DRY, YAGNI, TDD, frequent commits.

Save to `docs/dmj/plans/YYYY-MM-DD-<feature>.md` (user path preference wins; same root as specs, maps, and skill-learnings).

## Before tasks

- **Scope.** Design spans independent subsystems: one plan each. Each must produce working, testable software alone.
- **File map.** List every file created/modified + its one responsibility. Small focused files; split by responsibility not layer; follow patterns.
- **Granularity.** One task = one self-contained deliverable (a function, a test file, a review). Too small and coordination costs more than the work; too large and it runs long before a wrong turn can be caught.

## Plan header

```markdown
# <Feature> Implementation Plan

**Goal:** <one sentence> · **Architecture:** <2-3 sentences> · **Tech stack:** <key libs>
**Execution:** team-driven-development or executing-plans. Tasks are checkboxes.
```

## Each task declares (parallel-first)

- **Depends on:** task IDs that must finish first (or `none`).
- **Parallel-safe:** `yes` only if no unlisted dependency AND its file set does not overlap another runnable task. Overlap forces a worktree (dmj:using-git-worktrees) or serialization.
- **Files:** exact create / modify (`path:lines`) / test paths.
- **Acceptance criteria:** machine-checkable, each a command + expected result (exit code, test name, output, benchmark threshold).
- **Steps:** TDD, one action each (2-5 min): failing test, run it fail, minimal code, run it pass, commit.
- **Verification step:** the command(s) proving the criteria, run before marking done.

## Task template

Steps carry actual code, not descriptions.

````markdown
### Task N: <name>
**Depends on:** <ids|none> · **Parallel-safe:** <yes|no>
**Files:** Create `a.ts` · Test `a.test.ts` · **Acceptance:** `pnpm test a.test.ts` → 3 pass

- [ ] Failing test (code) → run → FAIL · minimal code (code) → run → PASS
- [ ] Verify acceptance command, then commit
````

## No placeholders (plan failures)

A step that describes WHAT without the code block is a placeholder, and so are "TBD", "implement later", "add error handling / validation / edge cases", and "write tests for the above". Two that hide better: "similar to Task N" (tasks run out of order and land in fresh contexts, so repeat it in full) and a symbol no task defines.

## Performance and security

Bake budgets into acceptance criteria (dmj:enforcing-performance-budgets): lowest achievable complexity, no O(n²)+ unjustified. Carry the design's threat model into tasks as explicit steps + criteria (dmj:defending-in-depth): validation, parameterized queries, least privilege.

## Fresh-context review (never self-review)

Plan complete: dispatch ONE fresh-context teammate (no session history) with spec + plan to check: every spec requirement maps to a task; no placeholders; type and signature names consistent across tasks; dependency edges acyclic; each acceptance criterion machine-checkable. Fix blocking findings; re-dispatch only if a blocker was structural.

Headless: run the same checklist yourself in a SEPARATE pass (or as a fresh `Agent` call) and record it ran; never skip the gate silently.

## Red flags (stop)

- A task with no machine-checkable acceptance criterion.
- "Parallel-safe: yes" on tasks that share a file.
- Reviewing your own plan in the same context.
- A dependency cycle, or a task using an undefined symbol.

Next: **dmj:team-driven-development** (same session) or **dmj:executing-plans** (fresh session).
