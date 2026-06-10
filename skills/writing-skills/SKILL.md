---
name: writing-skills
description: Use when creating a new skill, editing an existing skill, or verifying a skill works before deployment, especially when tempted to ship one untested.
---

# Writing Skills

Writing a skill IS test-driven development applied to documentation. You watch a fresh agent fail without the skill (RED), write the minimal skill that fixes those exact failures (GREEN), then close the loopholes it finds (REFACTOR).

**REQUIRED BACKGROUND:** dmjcustomizations:test-driven-development defines the RED-GREEN-REFACTOR cycle this adapts.

Announce: "Writing this skill via TDD-for-docs."

## The Iron Law

**No skill, and no edit to a skill, without a failing test first.** Wrote it before testing? Delete it and start over. Not "keep as reference," not "adapt while testing," not "just a section." Violating the letter is violating the spirit.

## RED: baseline (parallel)

Spawn a fresh-context TEAM, not one agent and never same-context self-review: `TeamCreate`, then an `Agent` teammate per pressure scenario, run concurrently. Each gets a realistic task WITHOUT the skill. For discipline skills, combine 3+ pressures (time, sunk cost, authority, exhaustion). Collect every choice and rationalization verbatim; the repeated excuses are your spec. Full method: testing-skills-with-teams.md.

## GREEN: minimal skill

Write only enough to defeat the failures you observed. Do not pad for hypotheticals.

**Frontmatter:** YAML, two fields. `name` equals the directory (kebab-case). `description`: third person, starts "Use when", ONLY triggering conditions and symptoms, NEVER a workflow summary, under 500 chars. A description that summarizes steps becomes a shortcut Claude follows instead of reading the body. See best-practices.md.

**Body:** under 500 words. Core principle up top, keyword-rich for discovery, one excellent example per concept, tables for quick reference. Cross-reference siblings as `dmjcustomizations:<name>`, never `@`-links (they force-load and burn context).

## REFACTOR: close loopholes (parallel)

Re-run the same team WITH the skill. New rationalization? Add an explicit negation, a rationalization-table row, and a red-flag line, then re-test. Repeat until a maximum-pressure team complies and cites the skill.

## This library's additions

Every skill you write here must also specify, where applicable:
- a **headless mode** (autonomous behavior at each user gate: safe defaults, assumption ledger, park user-owned decisions), and
- **parallel structure** (what runs concurrently between gates, what serializes at gates).
Add both to the skill's own checklist.

## Flowcharts and files

Flowchart ONLY a non-obvious decision loop, never reference material, code, or linear steps. Split to a separate file only for heavy reference or a reusable tool; keep references one level deep from SKILL.md.

## Anti-patterns

Narrative ("the time we fixed..."); the same example in five languages; code inside flowcharts; generic labels (step1, helper2); shipping untested because "batching is efficient."

Next: dmjcustomizations:verification-before-completion, then dmjcustomizations:requesting-code-review.
