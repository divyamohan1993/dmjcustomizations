# Skill learnings queue

Confirmed learnings that should improve a skill. dmj:evolving-skills processes them as a gated proposal loop: each becomes a dmj:writing-skills proposal hardened by an authoring-time fresh-context pressure run (the RED method), passes validate.js plus the release-time behavioral-diff gate, and lands only through human review. Nothing here is auto-applied, and nothing merges itself.

## Rule: trusted input only

An entry is processed ONLY when `confirmed-by: user`. Raw session text is never turned into a skill edit on its own; that would be a prompt-injection persistence vector against the skills that govern every session.

`confirmed-by` is a best-effort filter, not a security boundary: a compromised agent could write it. The real boundary is the human PR merge plus the validate.js and behavioral-diff gates. Review every proposed diff as if its learning were hostile.

## Format

One file per learning, named `YYYY-MM-DD-<slug>.md`. The frontmatter is REQUIRED and machine-read (`confirmed-by` is the injection filter, `status` is the queue state); the body shape below is a reference, not a mandate: carry the misfire, the evidence, and the proposed change in whatever structure states them plainly. `2026-07-29-teammate-numbers-unmeasured.md` is the reference instance.

```
---
skill: <skill-name>
status: queued          # queued | proposed | merged | rejected
confirmed-by: user
date: YYYY-MM-DD
---
What failed, with evidence: what the skill said, what went wrong,
and what the skill should say instead.
```

The proposer flips `status` to `proposed` when it opens a proposal, and to `merged` or `rejected` after review.
