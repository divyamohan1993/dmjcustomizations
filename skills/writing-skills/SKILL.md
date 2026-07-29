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

**No new skill, and no change to what an agent may or must do, without a failing probe first.** The scope is a property, not a file list: any edit touching a floor, gate, threshold, Iron Law, or description needs a fresh-context pressure probe (RED below) run without the change, recorded in the commit message and CHANGELOG. Wrote it before probing? Delete, start over: not "keep as reference," not "adapt while testing." Mechanical edits that move no rule (typos, links, formatting, restructuring) skip the probe; under deadline, "this edit is mechanical" is itself the rationalization to check.

## RED: baseline (parallel)

Fresh-context TEAM, never one agent, never same-context self-review: one `Agent` teammate per pressure scenario, all spawned in a single message so they run concurrently. Each gets a realistic task WITHOUT the skill. Discipline skills: combine 3+ pressures (time, sunk cost, authority, exhaustion). Collect every choice and rationalization verbatim; the repeated excuses are your spec. Full method: testing-skills-with-teams.md.

## GREEN: minimal skill

Only enough to defeat the failures observed. No padding for hypotheticals.

**Frontmatter:** YAML. Required: `name` = the directory (kebab-case); `description`: third person, ONLY triggering conditions and symptoms, named sharply enough that Claude picks THIS skill over its confusable siblings, NEVER a workflow summary, under 500 chars. A harness field (`disallowed-tools`, `paths`, `context`) enters ONLY when it turns one of the skill's own contracts into enforcement (a chat-only skill forbidding Write); every other field stays out. Descriptions are the always-loaded routing surface: edit a shipped one deliberately, keep the trigger that distinguishes it from siblings, and land description edits in their own commit so a routing regression is bisectable. Craft: best-practices.md.

**Body:** the trigger, the floors, and the decision rules, nothing else, which is about 500 words. Past that, the excess is usually depth, and depth belongs in a sibling reference file linked from SKILL.md; that split is the norm for anything long, not a last resort. (`validate.js` holds the hard caps.) Write to inform judgement: state the floor and what it protects, then trust the reader to apply it; specify step by step only where the task is fragile or order-critical. Prefer a reference to a description: point at the code, rubric, or failing test that already defines the behavior instead of restating it, because the restatement is the copy that goes stale. Keep an example only where it pins a contract more precisely than prose can. Cross-reference siblings as `dmj:<name>`, never `@`-links (force-load, burn context).

## REFACTOR: close loopholes (parallel)

Re-run the same team WITH the skill. New rationalization? Add an explicit negation + a rationalization-table row + a red-flag line, re-test. Repeat until a maximum-pressure team complies and cites the skill.

Each of those three is output for a rationalization you watched an agent produce, and it gets ONE home. The test is single: a row or flag that restates a bar, step, or rule stated above it in the same file is duplication, cut it after moving its sharpest phrasing into the surviving bar; one that names a pressure or symptom no bar covers (deadline, authority, sunk cost, the thought that precedes the violation) stays. A red flag is a detection trigger, not a restatement, and two flags covering one law merge into one.

## This library's additions

Every skill inherits the library defaults stated in dmj:using-dmj: headless runs are fully autonomous with assumptions recorded and user-owned decisions parked (irreversible, security, cost, public surface), and work is parallel by default, serialized only at user gates and real data dependencies. A skill writes its own Headless or parallel section ONLY where it deviates from that default: a gate it refuses to auto-pass, a coverage ledger its discipline demands, a serialization its ordering requires. Boilerplate restating the default is duplication, cut it.

## Flowcharts and files

Flowchart ONLY a non-obvious decision loop, never reference material, code, or linear steps. Reference files sit one level deep from SKILL.md, each carrying a table of contents once it passes ~100 lines (split rules: best-practices.md).

## Dynamic skills

SKILL.md supports preprocessing that runs BEFORE content loads: an arguments placeholder (dollar-prefixed ARGUMENTS), a skill-dir substitution, and inline shell blocks (exclamation mark plus a backticked command). Never write those token sequences literally in a skill body; the loader substitutes and executes them even inside code spans. Use them to inject live state (date, git status, env) instead of hardcoding. Discipline-skill edits: re-verify with a fresh pressure team (the RED method above) before release.

## Anti-patterns

Narrative ("the time we fixed..."); the same example in five languages; code inside flowcharts; generic labels (step1, helper2); restating a script, rubric, or config the skill could point at; shipping untested because "batching is efficient."

Next: dmj:verification-before-completion, then dmj:requesting-code-review.
