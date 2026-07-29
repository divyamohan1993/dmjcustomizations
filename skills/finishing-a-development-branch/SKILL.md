---
name: finishing-a-development-branch
description: Use when implementation is complete and tests pass and you must decide how to integrate the work (merge, open a PR, keep, or discard) and tear down worktrees and teammates.
---

# Finishing a Development Branch

Verify -> options -> execute -> tear down. Never reach options without verification evidence.

## Step 1: Require verification evidence

No options on a *claim* that tests pass. Run them, read output. **REQUIRED:** dmj:verification-before-completion. Failures: report the failing output, stop, no merge or PR until green.

## Step 2: Detect environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
BASE=$(git merge-base HEAD main 2>/dev/null && echo main || echo master)
```

`GIT_DIR != GIT_COMMON` = worktree (cleanup applies). Detached HEAD removes the local-merge option.

## Step 3: Present options

AskUserQuestion, single batched question, these as choices, no extra prose:

1. **Merge** to base locally
2. **PR**: push, open a pull request
3. **Keep** the branch as-is
4. **Discard** this work

Detached HEAD: drop option 1.

## Step 4: Execute

Automatic gates before ANY commit or merge:
- Update CHANGELOG.md at repo root (Keep a Changelog, grouped by date) in the same commit.
- Let every configured hook run. Never `--no-verify`, never bypass signing or hooks; a failing hook means fix the cause, never skip.
- Hook manager (husky, pre-commit, lefthook): ensure installed and active first.
- Deploys carry the same gate, absolute: NOTHING deploys, ever, without the full test suite green on the exact artifact deployed.

From the main repo root, never inside a worktree being removed:

```bash
MAIN=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel); cd "$MAIN"
```

- **Merge:** `git checkout $BASE && git pull && git merge <branch>`, re-run tests on the result, tear down (Step 5), `git branch -d <branch>`. Merge before removing anything.
- **PR:** `git push -u origin <branch>` then `gh pr create`. Keep the worktree for review iteration; no teardown.
- **Keep:** report branch and worktree path. No teardown.
- **Discard:** user types `discard`, then tear down, `git branch -D <branch>`.

## Step 5: Tear down (Merge and Discard only)

Shut down the team before removing shared trees: `SendMessage` each teammate a `shutdown_request`, await `shutdown_response`. Then, only for worktrees under `.worktrees/` (ours, never harness-owned):

```bash
git worktree remove "<path>"   # --force only for Discard
git worktree prune
```

Leave harness-owned or host workspaces in place; use the platform exit tool if one exists.

## Headless mode

Background run: never auto-merge, never discard. Stop at a pushed branch with a prepared PR description (title + summary + test-plan body), report it. Park the merge/keep/discard decision; keep all worktrees and teammates unless their work is confirmed merged.

## Red flags

Options on unverified tests; merging without re-testing the result; a commit without its CHANGELOG update; `--no-verify` or any skipped hook; removing a worktree before merge succeeds; discarding without typed confirmation; force-pushing unasked; removing a tree you did not create.

Next: dmj:requesting-code-review before merge, or after a clean merge the cycle restarts at dmj:brainstorming.
