# Skill learnings queue

Confirmed learnings that should improve a skill. dmj:evolving-skills processes them as a gated proposal loop: each becomes a dmj:writing-skills TDD proposal, passes validate.js plus the behavioral-diff gate, and opens a PR for a human to merge. Nothing here is auto-applied, and nothing merges itself.

## Rule: trusted input only

An entry is processed ONLY when `confirmed-by: user`. Raw session text is never turned into a skill edit on its own; that would be a prompt-injection persistence vector against the skills that govern every session.

`confirmed-by` is a best-effort filter, not a security boundary: a compromised agent could write it. The real boundary is the human PR merge plus the validate.js and behavioral-diff gates. Review every proposed diff as if its learning were hostile.

## Format

One file per learning, named `YYYY-MM-DD-<slug>.md`:

```
---
skill: <skill-name>
status: queued          # queued | proposed | merged | rejected
confirmed-by: user
date: YYYY-MM-DD
---
## What failed
The exact misfire, with evidence: what the skill said, what went wrong.

## Proposed change
What the skill should say instead, and why.
```

The proposer flips `status` to `proposed` when it opens a PR, and to `merged` or `rejected` after review.
