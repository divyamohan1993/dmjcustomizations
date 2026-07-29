---
name: writing-skills
description: Use when creating a new skill, editing an existing skill, or verifying a skill works before deployment, especially when tempted to ship one untested.
---

# Writing Skills

A skill IS test-driven development for docs. Watch a fresh agent fail without it (RED), write the minimal skill fixing those exact failures (GREEN), close the loopholes it finds (REFACTOR).

## Kill criterion (no skill without it)

A candidate that restates the system prompt, one person's opinions, or another skill is a PARAGRAPH in an existing skill, never a new skill. Each new skill taxes every future routing decision; it must earn that tax with a gate or technique that exists nowhere else.

**REQUIRED BACKGROUND:** dmj:test-driven-development defines the RED-GREEN-REFACTOR cycle this adapts.

## The Iron Law

**No skill, no edit to a skill, without a failing test first.** Wrote it before testing? Delete, start over. Not "keep as reference," not "adapt while testing," not "just a section." Violating the letter is violating the spirit.

## RED: baseline (parallel)

Fresh-context TEAM, never one agent, never same-context self-review: one `Agent` teammate per pressure scenario, all spawned in a single message so they run concurrently. Each gets a realistic task WITHOUT the skill. Discipline skills: combine 3+ pressures (time, sunk cost, authority, exhaustion). Collect every choice and rationalization verbatim; the repeated excuses are your spec. Full method: testing-skills-with-teams.md.

## GREEN: minimal skill

Only enough to defeat the failures observed. No padding for hypotheticals.

**Frontmatter:** YAML. Required: `name` = the directory (kebab-case); `description`: third person, ONLY triggering conditions and symptoms, named sharply enough that Claude picks THIS skill over its confusable siblings, NEVER a workflow summary, under 500 chars. A harness field (`disallowed-tools`, `paths`, `context`) enters ONLY when it turns one of the skill's own contracts into enforcement (a chat-only skill forbidding Write); every other field stays out. Descriptions are the always-loaded routing surface: edit a shipped one deliberately, keep the trigger that distinguishes it from siblings, and land description edits in their own commit so a routing regression is bisectable. Craft: best-practices.md.

**Body:** the trigger, the floors, and the decision rules, nothing else, which is about 500 words. Past that, the excess is usually depth, and depth belongs in a sibling reference file linked from SKILL.md; that split is the norm for anything long, not a last resort. (`validate.js` holds the hard caps.) Write to inform judgement: state the floor and what it protects, then trust the reader to apply it; specify step by step only where the task is fragile or order-critical. Prefer a reference to a description: point at the code, rubric, or failing test that already defines the behavior instead of restating it, because the restatement is the copy that goes stale. Keep an example only where it pins a contract more precisely than prose can. Cross-reference siblings as `dmj:<name>`, never `@`-links (force-load, burn context).

## REFACTOR: close loopholes (parallel)

Re-run the same team WITH the skill. New rationalization? Add an explicit negation + a rationalization-table row + a red-flag line, re-test. Repeat until a maximum-pressure team complies and cites the skill.

Each of those three is output for a rationalization you watched an agent produce, and it gets ONE home: a row or flag that only restates a floor, step, or rule stated above it is duplication rather than enforcement, and belongs cut. Which one is the home is a lookup, not a taste call:

- **A test's PASS criterion cites a section** ("citing the Delivery bar"): that section is the home. Move the row's sharpest phrasing into it, then cut the row.
- **The test or the CHANGELOG records the ROW itself** as what was added and passed: the row is the home and the prose gives way.
- **No scenario maps to the row at all:** the test is whether it restates a bar, step, or rule in the same file. If it does, that is the home and the row goes. If it names a pressure no bar covers, it stays.

A red flag is a detection trigger, not a restatement: it earns its place by naming the symptom or the thought that precedes the violation. One that repeats a bar's words is the duplicate, and two flags covering one law merge into one.

## This library's additions

Every skill here must also specify, where applicable:
- **headless mode** (autonomous behavior at each user gate: safe defaults, assumption ledger, park user-owned decisions),
- **parallel structure** (what runs concurrently between gates, what serializes at gates).

Add both to the skill's checklist.

## Flowcharts and files

Flowchart ONLY a non-obvious decision loop, never reference material, code, or linear steps. Reference files sit one level deep from SKILL.md, each carrying a table of contents once it passes ~100 lines (split rules: best-practices.md).

## Dynamic skills

SKILL.md supports preprocessing that runs BEFORE content loads: an arguments placeholder (dollar-prefixed ARGUMENTS), a skill-dir substitution, and inline shell blocks (exclamation mark plus a backticked command). Never write those token sequences literally in a skill body; the loader substitutes and executes them even inside code spans. Use them to inject live state (date, git status, env) instead of hardcoding. Discipline-skill edits: re-verify with a fresh pressure team (the RED method above) before release.

## Anti-patterns

Narrative ("the time we fixed..."); the same example in five languages; code inside flowcharts; generic labels (step1, helper2); restating a script, rubric, or config the skill could point at; shipping untested because "batching is efficient."

Next: dmj:verification-before-completion, then dmj:requesting-code-review.
