---
name: using-git-worktrees
description: Use when starting feature work that needs isolation, before executing a plan, when running concurrent teammates that touch overlapping files, or when spiking a throwaway design experiment.
---

# Using Git Worktrees

A worktree is the lowest-blast-radius workspace: changes stay off your current branch and are trivially discarded. Use one for every non-trivial change, for each teammate in concurrent work, and for every spike.

Announce: "Setting up an isolated worktree."

## Step 0: Detect existing isolation

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
```

`GIT_DIR != GIT_COMMON` AND `git rev-parse --show-superproject-working-tree` is empty -> already in a worktree. Skip to Setup. Otherwise you are in a normal checkout: continue.

## Step 1: Create

Prefer a native tool if one exists (a name like `EnterWorktree`, a `/worktree` command, or a `--worktree` flag): it manages placement and cleanup, so use it. Fighting the harness with raw `git worktree add` when a native tool exists creates phantom state. Fallback:

```bash
git check-ignore -q .worktrees || { echo ".worktrees/" >> .gitignore && git add .gitignore && git commit -m "chore: ignore worktrees"; }
git worktree add ".worktrees/<branch>" -b "<branch>"
cd ".worktrees/<branch>"
```

`<branch>` is descriptive kebab-case. Verify the directory is git-ignored BEFORE creating, or the worktree gets committed into the repo.

Permission/sandbox error on add: tell the user the sandbox blocked it, work in place, continue.

## Parallel work

- **Concurrent teammates on overlapping files:** one worktree per teammate, each on its own branch, named for the teammate or its slice. Disjoint files in one tree is fine; overlap without separate trees corrupts each other's diffs. Merge at the gate, not mid-flight. See dmjcustomizations:dispatching-parallel-teams.
- **Spikes:** create a throwaway tree, name it `spike-<question>`, answer the design question, record the conclusion, then force-discard: `git worktree remove --force` + `git branch -D`. The conclusion survives; the code never merges.

## Setup and baseline

Install deps for the detected stack (pnpm install / cargo build / uv sync / go mod download), then run the test suite. Tests fail at baseline: report and ask before building, so new breakage stays distinguishable. Tests pass: report ready with path and branch.

## Never leave orphans

One worktree maps to one branch and one purpose. Remove it the moment its work merges or is abandoned (dmjcustomizations:finishing-a-development-branch owns this). Run `git worktree prune` after any removal. No nested worktrees, no reusing one tree for two tasks.

## Headless mode

No native tool and no stated preference: default to `.worktrees/<branch>`, do not block. Park only a destructive choice (discarding existing uncommitted work) for the user; log the assumption.

Next: implement here, then dmjcustomizations:finishing-a-development-branch.
