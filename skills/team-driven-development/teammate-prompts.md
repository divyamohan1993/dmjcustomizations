# Teammate Prompt Contracts

Contracts for the three team-driven-development roles, as field tables rather than paste-blocks: assemble each prompt from its rows. A teammate inherits NONE of the lead's conversation (dmj:dispatching-parallel-teams `team-mechanics.md`), so every field is LITERAL: paste the task text, the report, the diff range. A file path where text belongs, or an "as we discussed", resolves to nothing on the other side. Reviewers run in FRESH context, never the implementer reviewing itself.

## Every prompt carries

| Field | Literal content | Why literal |
|---|---|---|
| Task | full task text from the plan, Files and Acceptance criteria included | the plan file is not readable context on the other side |
| Ownership | the exact file set owned; editing outside it collides with a peer | overlap corrupts parallel diffs |
| Coordination | midway progress update via SendMessage; message peers directly about shared interfaces | plain text is invisible to other agents |
| Process | the governing skill, named | the teammate loads skills fresh and routes itself |

## Per-role deltas

| Role | Governing skill | Extra fields | Output contract |
|---|---|---|---|
| Implementer | dmj:test-driven-development | context (where the task fits, interfaces peers own); the file set it owns, everything else off limits; "ask the lead and WAIT if anything is unclear, do not guess"; self-review before reporting (requirements met, no extra scope, tests verify behavior not mocks) | status enum `DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT`, what was built, the verification command's ACTUAL pasted output, files changed, concerns. Always OK to say "this is too hard": bad work is worse than none, and doubted work is never shipped silently |
| Spec reviewer | none (read the code, not the report) | the implementer's claimed report, pasted; the diff range `<base SHA>..<head SHA>` | "Spec compliant" OR "Issues:" with file:line per gap or extra; confirms the acceptance commands pass; checks nothing skipped, nothing unrequested, no misread requirement |
| Quality reviewer (only after spec passes) | dmj:requesting-code-review | the diff range; the task reference | Strengths, Issues (Critical/Important/Minor with file:line), Assessment. Deltas beyond the standard review: one clear responsibility and defined interface per file; units independently testable; judge whether THIS change bloated a file, not pre-existing size |
