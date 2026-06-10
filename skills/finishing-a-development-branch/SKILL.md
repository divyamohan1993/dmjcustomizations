---
name: finishing-a-development-branch
description: Use when implementation is complete and tests pass and you must decide how to integrate the work (merge, open a PR, keep, or discard) and tear down worktrees and teammates.
---

# Finishing a Development Branch

Verify -> present options -> execute -> tear down. Never skip to options without verification evidence.

Announce: "Finishing this branch."

## Step 1: Require verification evidence

You may NOT present integration options on a claim that tests pass. Run them and read the output first. **REQUIRED:** dmjcustomizations:verification-before-completion. Failures: report the failing output, stop, do not offer to merge or open a PR until green.

## Step 2: Detect environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
BASE=$(git merge-base HEAD main 2>/dev/null && echo main || echo master)
```

`GIT_DIR != GIT_COMMON` means a worktree (cleanup applies). Detached HEAD removes the local-merge option.

## Step 3: Present options

Use AskUserQuestion (single batched question, these as choices), no extra prose:

1. **Merge** to base locally
2. **PR**: push and open a pull request
3. **Keep** the branch as-is
4. **Discard** this work

Detached HEAD: drop option 1.

## Step 4: Execute

Before ANY commit or merge, two automatic gates: (1) update CHANGELOG.md at the repo root (Keep a Changelog format, grouped by date) in the same commit; (2) let every configured hook run. Never `--no-verify`, never bypass signing or hooks; a failing hook means fix the cause, never skip. If the repo uses a hook manager (husky, pre-commit, lefthook), ensure it is installed and active first. Deploys carry the same gate, absolute: NOTHING deploys, ever, without the full test suite green on the exact artifact being deployed.

From the main repo root, never from inside a worktree being removed:

```bash
MAIN=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel); cd "$MAIN"
```

- **Merge:** `git checkout $BASE && git pull && git merge <branch>`, re-run tests on the result, then tear down (Step 5) and `git branch -d <branch>`. Merge before removing anything.
- **PR:** `git push -u origin <branch>` then `gh pr create`. Keep the worktree alive for review iteration; do not tear down.
- **Keep:** report branch and worktree path. No teardown.
- **Discard:** require the user to type `discard`, then tear down and `git branch -D <branch>`.

## Step 5: Tear down (Merge and Discard only)

Shut down the team before removing shared trees: `SendMessage` each teammate a `shutdown_request`, wait for `shutdown_response`. Then, only for worktrees under `.worktrees/` (ones we own, never harness-owned):

```bash
git worktree remove "<path>"   # --force only for Discard
git worktree prune
```

Leave harness-owned or host workspaces in place; use the platform exit tool if one exists.

## Headless mode

Background run: never auto-merge and never discard. Stop at a pushed branch with a prepared PR description (title plus summary and test-plan body) and report it. Park the merge/keep/discard decision for the user; keep all worktrees and teammates unless their work is confirmed merged.

## Red flags

Proceeding on unverified tests; merging without re-testing the result; a commit without its CHANGELOG update; `--no-verify` or any skipped hook; removing a worktree before merge succeeds; discarding without typed confirmation; force-pushing unasked; removing a tree you did not create.

Next: dmjcustomizations:requesting-code-review before merge, or after a clean merge the cycle restarts at dmjcustomizations:brainstorming.
