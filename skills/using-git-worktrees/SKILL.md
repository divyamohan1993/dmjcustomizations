---
name: using-git-worktrees
description: Use when starting feature work that needs isolation, before executing a plan, when running concurrent teammates that touch overlapping files, or when spiking a throwaway design experiment.
---

# Using Git Worktrees

Lowest-blast-radius workspace: changes stay off your branch, trivially discarded. One per non-trivial change, per concurrent teammate, per spike.

## Step 0: Detect existing isolation

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
```

`GIT_DIR != GIT_COMMON` AND `git rev-parse --show-superproject-working-tree` empty -> already in a worktree, skip to Setup. Else continue.

## Step 1: Create

Use the native tools (`EnterWorktree`/`ExitWorktree`, `isolation: "worktree"` on spawns): they manage placement and cleanup, and raw `git worktree add` beside them creates phantom state. Raw fallback, for a harness without them:

```bash
git check-ignore -q .worktrees || { echo ".worktrees/" >> .gitignore && git add .gitignore && git commit -m "chore: ignore worktrees"; }
git worktree add ".worktrees/<branch>" -b "<branch>"
cd ".worktrees/<branch>"
```

`<branch>`: descriptive kebab-case. Verify `.worktrees` is git-ignored BEFORE creating, or it commits into the repo. Sandbox/permission error on add: tell the user the sandbox blocked it, work in place, continue.

## Parallel work

- **Concurrent teammates, overlapping files:** one worktree per teammate (`isolation: "worktree"` on the spawn), each on its own branch named for the teammate or slice. Disjoint files in one tree is fine; overlap without separate trees corrupts each other's diffs. Merge at the gate, not mid-flight. See dmj:dispatching-parallel-teams.
- **Spikes:** throwaway tree `spike-<question>`, answer the design question, record the conclusion, force-discard: `git worktree remove --force` + `git branch -D`. Conclusion survives; code never merges.

## Setup and baseline

Install deps for the stack (pnpm install / cargo build / uv sync / go mod download), run the suite. Tests fail at baseline: report and ask before building, so new breakage stays distinguishable. Pass: report ready with path and branch.

## Never leave orphans

One worktree = one branch = one purpose. Remove the moment work merges or is abandoned (dmj:finishing-a-development-branch owns this). `git worktree prune` after any removal. No nested worktrees, no reusing one tree for two tasks.

## Headless mode

No native tool, no stated preference: default `.worktrees/<branch>`, do not block. Park only a destructive choice (discarding existing uncommitted work); log the assumption.

Next: implement here, then dmj:finishing-a-development-branch.
