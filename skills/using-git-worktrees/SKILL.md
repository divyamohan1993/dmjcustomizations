---
name: using-git-worktrees
description: Use when parallel work might collide on files, when spiking a throwaway experiment, or when tempted to create a git worktree or pass worktree isolation to a spawn. Worktrees are banned by user law; this skill is the isolation policy that replaces them.
---

# Isolation Without Worktrees

**User law: NEVER create git worktrees, on any repo.** Never run `git worktree add`, never pass `isolation: "worktree"` to a spawn, never instruct a teammate to. Recorded reason: work has been lost when a worktree's branch switched out from under uncommitted edits. The law compensates for a real, experienced failure; it retires only when the user says so.

## What replaces them

| Need | Policy |
|---|---|
| Parallel teammates | All spawn in the MAIN checkout. Each prompt declares strict file ownership: the exact set it may touch, everything else off limits. Disjoint sets run concurrently |
| Two tasks want one file | Never in parallel. Sequence them, or have one produce a patch the lead applies after the other lands |
| Spike / throwaway experiment | Temp clone in the scratchpad (`git clone --local . <scratch>/spike-<question>`), answer the question, record the conclusion, delete the clone. Conclusions survive; code never merges. NOT a worktree |
| Feature isolation | A branch in the main checkout. Commit early; uncommitted work is the exposure the ban exists to close |
| Risky teammate | Spawn requiring plan approval (read-only until the lead approves); approval criteria in the prompt |

## Floors

- Ownership boundaries are stated in the spawn prompt, not assumed; a teammate editing outside its set is a stop-and-fix, not a merge conflict to untangle later.
- Baseline before building: install deps, run the suite; failures at baseline are reported before new work starts, so new breakage stays distinguishable.
- A stray worktree found in a repo (legacy or hand-made): report it to the user; remove only on their word (`git worktree remove` + `prune`), never adopt it for new work.

Next: implement on the branch, then dmj:finishing-a-development-branch.
