---
name: writing-skills
description: Use when creating a new skill, editing an existing skill, or verifying a skill works before deployment, especially when tempted to ship one untested.
---

# Writing Skills

A skill IS test-driven development for docs. watch a fresh agent fail without it (RED), write the minimal skill fixing those exact failures (GREEN), close the loopholes it finds (REFACTOR).

## Kill criterion (no skill without it)

Candidate restating the system prompt, one person's opinions, or another skill = a PARAGRAPH in an existing skill, never a new skill. every new skill taxes every future routing decision; it earns that tax with a gate or technique existing nowhere else.

**REQUIRED BACKGROUND:** dmj:test-driven-development defines the RED-GREEN-REFACTOR cycle this adapts.

## The Iron Law

**No new skill, and no change to what an agent may or must do, without a failing probe first.** scope = a property, not a file list: any edit touching a floor, gate, threshold, Iron Law, or description needs a fresh-context pressure probe (RED below) run without the change, recorded in commit message + CHANGELOG. wrote it before probing -> delete, start over: not "keep as reference," not "adapt while testing." mechanical edits moving no rule (typos, links, formatting, restructuring) skip the probe; under deadline, "this edit is mechanical" is itself the rationalization to check.

## RED: baseline (parallel)

Fresh-context TEAM, never one agent, never same-context self-review: one `Agent` per pressure scenario, single message, concurrent. each gets a realistic task WITHOUT the skill. discipline skills: 3+ combined pressures (time, sunk cost, authority, exhaustion). capture every choice and rationalization verbatim; repeated excuses = the spec. method: testing-skills-with-teams.md.

## GREEN: minimal skill

Only enough to defeat the failures observed. no padding for hypotheticals.

**Frontmatter:** YAML. `name` = directory (kebab-case). `description` = third person, ONLY triggering conditions and symptoms, sharp enough that Claude picks THIS skill over confusable siblings, NEVER a workflow summary, under 500 chars. harness field (`disallowed-tools`, `paths`, `context`) ONLY where it turns a skill's own contract into enforcement (chat-only skill forbidding Write), every other field out. descriptions = the always-loaded routing surface: edit a shipped one deliberately, keep the distinguishing trigger, land description edits in their own commit so a routing regression is bisectable. craft: best-practices.md.

**Body:** trigger + floors + decision rules, nothing else, about 500 words. excess past that = usually depth -> a sibling reference file linked from SKILL.md, the norm for anything long, not a last resort. (`validate.js` holds the hard caps.) write to inform judgement: floor + what it protects, then trust the reader; step-by-step only where the task is fragile or order-critical. reference over description: point at the code, rubric, or failing test already defining the behavior, since a restatement is the copy that goes stale. example only where it pins a contract prose cannot. siblings as `dmj:<name>`, never `@`-links (force-load, burn context).

## REFACTOR: close loopholes (parallel)

Same team, WITH the skill. new rationalization -> explicit negation + rationalization-table row + red-flag line, re-test. repeat until a maximum-pressure team complies and cites the skill.

Each of the three is output for a rationalization you watched an agent produce, and gets ONE home. single test: a row or flag restating a bar, step, or rule already stated above it in the same file = duplication, cut it, sharpest phrasing moved into the surviving bar; one naming a pressure or symptom no bar covers (deadline, authority, sunk cost, the thought preceding the violation) stays. red flag = detection trigger, not restatement; two flags on one law merge.

## This library's additions

Every skill inherits the dmj:using-dmj defaults: headless = fully autonomous, assumptions recorded, user-owned decisions parked (irreversible, security, cost, public surface); parallel by default, serialized only at user gates and real data dependencies. own Headless or parallel section ONLY where a skill deviates: a gate it refuses to auto-pass, a coverage ledger its discipline demands, a serialization its ordering requires. boilerplate restating the default = duplication, cut.

## Flowcharts and files

Flowchart ONLY a non-obvious decision loop, never reference material, code, or linear steps. reference files one level deep from SKILL.md, each with a table of contents past ~100 lines (split rules: best-practices.md).

## Dynamic skills

SKILL.md preprocessing runs BEFORE content loads: arguments placeholder (dollar-prefixed ARGUMENTS), skill-dir substitution, inline shell blocks (exclamation mark + backticked command). never write those token sequences literally in a skill body: the loader substitutes and executes them even inside code spans. use them for live state (date, git status, env), never hardcoding. discipline-skill edits: re-verify with a fresh pressure team (RED above) before release.

## Anti-patterns

Narrative ("the time we fixed..."); one example in five languages; code inside flowcharts; generic labels (step1, helper2); restating a script, rubric, or config the skill could point at; shipping untested because "batching is efficient."

Next: dmj:verification-before-completion, then dmj:requesting-code-review.
