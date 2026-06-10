---
name: writing-skills
description: Use when creating a new skill, editing an existing skill, or verifying a skill works before deployment, especially when tempted to ship one untested.
---

# Writing Skills

A skill IS test-driven development for docs. Watch a fresh agent fail without it (RED), write the minimal skill fixing those exact failures (GREEN), close the loopholes it finds (REFACTOR).

## Kill criterion (no skill without it)

A candidate that restates the system prompt, one person's opinions, or another skill is a PARAGRAPH in an existing skill, never a new skill. Each new skill taxes every future routing decision; it must earn that tax with a gate or technique that exists nowhere else.

**REQUIRED BACKGROUND:** dmjcustomizations:test-driven-development defines the RED-GREEN-REFACTOR cycle this adapts.

Announce: "Writing this skill via TDD-for-docs."

## The Iron Law

**No skill, no edit to a skill, without a failing test first.** Wrote it before testing? Delete, start over. Not "keep as reference," not "adapt while testing," not "just a section." Violating the letter is violating the spirit.

## RED: baseline (parallel)

Fresh-context TEAM, never one agent, never same-context self-review: `TeamCreate`, then an `Agent` teammate per pressure scenario, concurrent (TeamCreate unavailable: same scenarios as native parallel Agent calls). Each gets a realistic task WITHOUT the skill. Discipline skills: combine 3+ pressures (time, sunk cost, authority, exhaustion). Collect every choice and rationalization verbatim; the repeated excuses are your spec. Full method: testing-skills-with-teams.md.

## GREEN: minimal skill

Only enough to defeat the failures observed. No padding for hypotheticals.

**Frontmatter:** YAML, two fields. `name` = the directory (kebab-case). `description`: third person, starts "Use when", ONLY triggering conditions and symptoms, NEVER a workflow summary, under 500 chars. A description summarizing steps becomes a shortcut Claude follows instead of reading the body. See best-practices.md.

**Body:** under 500 words. Core principle up top, keyword-rich for discovery, one excellent example per concept, tables for reference. Cross-reference siblings as `dmjcustomizations:<name>`, never `@`-links (force-load, burn context).

## REFACTOR: close loopholes (parallel)

Re-run the same team WITH the skill. New rationalization? Add an explicit negation + a rationalization-table row + a red-flag line, re-test. Repeat until a maximum-pressure team complies and cites the skill.

## This library's additions

Every skill here must also specify, where applicable:
- **headless mode** (autonomous behavior at each user gate: safe defaults, assumption ledger, park user-owned decisions),
- **parallel structure** (what runs concurrently between gates, what serializes at gates).

Add both to the skill's checklist.

## Flowcharts and files

Flowchart ONLY a non-obvious decision loop, never reference material, code, or linear steps. Separate file only for heavy reference or a reusable tool; references one level deep from SKILL.md.

## Dynamic skills

SKILL.md supports $ARGUMENTS, ${CLAUDE_SKILL_DIR}, and inline !`cmd` blocks executing BEFORE content loads: inject live state (date, git status, env) instead of hardcoding. Discipline-skill edits: re-run the relevant battery scenario (tests/pressure-test-battery.md) and scripts/behavioral-test.sh before release.

## Anti-patterns

Narrative ("the time we fixed..."); the same example in five languages; code inside flowcharts; generic labels (step1, helper2); shipping untested because "batching is efficient."

Next: dmjcustomizations:verification-before-completion, then dmjcustomizations:requesting-code-review.
