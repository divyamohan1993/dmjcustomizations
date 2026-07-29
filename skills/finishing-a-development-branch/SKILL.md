---
name: finishing-a-development-branch
description: Use when implementation is complete and tests pass and you must decide how to integrate the work (merge, open a PR, keep, or discard) and stand down teammates and branches.
---

# Finishing a Development Branch

Verify -> options -> execute -> tear down. Never reach options without verification evidence.

## Step 1: Require verification evidence

No options on a *claim* that tests pass. Run them, read output. **REQUIRED:** dmj:verification-before-completion. Failures -> report the failing output, stop. No merge or PR until green.

## Step 2: Detect environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
BASE=$(git show-ref -q --verify refs/heads/main && echo main || echo master)
```

`GIT_DIR != GIT_COMMON` = a worktree exists (something created one; worktrees are banned by user law, so surface it to the user rather than adopting it). Detached HEAD removes the local-merge option.

## Step 3: Present options

AskUserQuestion, single batched question, these as choices, no extra prose:

1. **Merge** to base locally
2. **PR**: push, open a pull request
3. **Keep** the branch as-is
4. **Discard** this work

Detached HEAD -> drop option 1.

## Step 4: Execute

Gates before ANY commit or merge:
- CHANGELOG.md at repo root updated (Keep a Changelog, grouped by date) in the same commit.
- Every configured hook runs. Never `--no-verify`, never bypass signing or hooks; a failing hook = fix the cause, never skip.
- Hook manager (husky, pre-commit, lefthook): installed and active first.
- Deploys carry the same gate, absolute: NOTHING deploys, ever, without the full test suite green on the exact artifact deployed.

- **Merge:** `git checkout $BASE && git pull && git merge <branch>`, re-run tests on the result, stand down (Step 5), `git branch -d <branch>`. Merge before deleting anything.
- **PR:** `git push -u origin <branch>` then `gh pr create`. Keep the branch for review iteration; no stand-down.
- **Keep:** report the branch. No stand-down.
- **Discard:** user types `discard`, then stand down, `git branch -D <branch>`.

## Step 5: Stand down (Merge and Discard only)

Drain the team before deleting branches or scratch clones: `SendMessage` each teammate "finish your current tool call, flush or commit your work, reply drained", await that reply, then stop it (`TaskStop` by name). The drain matters because a stop is not instant and a branch or clone deleted under a teammate mid-write eats its work; never delete on a timer. Delete spike temp clones from the scratchpad. A stray worktree found here: the user's word before any `git worktree remove`.

## Headless mode

Background run: never auto-merge, never discard. Stop at a pushed branch with a prepared PR description (title + summary + test-plan body), report it. Park the merge/keep/discard decision; keep all branches and teammates unless their work is confirmed merged.

## Red flags

Options on unverified tests / merging without re-testing the result / a commit without its CHANGELOG update / `--no-verify` or any skipped hook / discarding without typed confirmation / force-pushing unasked / deleting a branch or tree you did not create.

Next: dmj:requesting-code-review before merge, or after a clean merge the cycle restarts at dmj:brainstorming.
