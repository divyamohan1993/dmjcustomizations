---
name: landing-sessions
description: Use when substantial work is wrapping up (a deliverable shipped, a session winding down, the user signals done), before context is lost, or when teammates, worktrees, background tasks, or unrecorded learnings may be left dangling.
---

# Landing Sessions

Land everything the session created: knowledge to memory, state to git, resources to zero, threads to the user. Context dies; only what lands survives, and the two thoughts that lose it are "the user will remember" and "next session can figure it out".

## Checklist (parallel where independent)

1. **Memory write-back.** Every non-obvious learning, decision, or gotcha: memory file + one MEMORY.md index line, written at decision time when possible, landed here at latest. Never repo-derivable facts; update or delete stale entries while there.
2. **State durable.** Work committed (CHANGELOG in the same commit, hooks run) and pushed where a remote exists. Uncommitted experiments: named to the user, never silent.
3. **Resources to zero.** Teammates drained (messaged to flush, replied) then stopped by name; spike and teammate worktrees removed (dmj:using-git-worktrees); background tasks stopped.
4. **Threads surfaced.** One short list: done (verified, with evidence), decisions parked for the user, anything unresolved. No silent loose ends.
5. **Debris.** Self-created scratch files inside the working folder: deleted. Anything outside it: the user confirms first, every time (hard conduct rule).
6. **Skill learnings.** A skill that misfired this session, once the user confirms the learning, gets a file in `docs/dmj/skill-learnings/`; if any are queued, run the session-end proposal pass (dmj:evolving-skills) that opens gated PRs. User-confirmed only, never auto-merge.

**Headless:** land automatically; the thread list and evidence go in the final report.

Next: nothing. Landing is terminal; the next session starts clean.
