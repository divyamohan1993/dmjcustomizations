---
name: landing-sessions
description: Use when substantial work is wrapping up (a deliverable shipped, a session winding down, the user signals done), before context is lost, or when teammates, scratch clones, background tasks, or unrecorded learnings may be left dangling.
---

# Landing Sessions

Land everything the session created: knowledge -> memory, state -> git, resources -> zero, threads -> the user. Context dies; only what lands survives. The two thoughts that lose it: "the user will remember" and "next session can figure it out".

## Checklist (parallel where independent)

1. **Memory write-back.** Auto-memory captures what a session surfaces; landing curates what it decided. Confirm every non-obvious learning, decision, and gotcha landed; correct or delete what it got wrong; add what it missed. Never repo-derivable facts. Prune stale entries while there.
2. **State durable.** Work committed (CHANGELOG in the same commit, hooks run) and pushed where a remote exists. Uncommitted experiments: named to the user, never silent.
3. **Resources to zero.** Teammates drained (messaged to flush, replied) then stopped by name; spike temp clones deleted (dmj:using-git-worktrees policy); background tasks stopped.
4. **Threads surfaced.** One short list: done (verified, with evidence), decisions parked for the user, anything unresolved. No silent loose ends.
5. **Debris.** Self-created scratch files inside the working folder: deleted. Anything outside it: the user confirms first, every time (hard conduct rule).
6. **Skill learnings.** A skill that misfired this session, once the user confirms the learning, gets a file in `docs/dmj/skill-learnings/`; any queued -> run the session-end proposal pass (dmj:evolving-skills) opening gated PRs. User-confirmed only, never auto-merge.

Next: nothing. Landing is terminal; the next session starts clean.
