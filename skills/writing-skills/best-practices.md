# Skill Authoring Best Practices

Load when writing or revising a skill body, choosing its description, or deciding how to split files. Distilled from Anthropic's official guidance. SKILL.md states the method; this is the craft reference.

## Contents
- Concise is key
- Degrees of freedom
- Writing the description (the CSO trap)
- Naming
- Progressive disclosure
- References over restatement
- Consistent terminology
- Avoid time-sensitive content
- Quick checklist

## Concise is key

The context window is a public good shared with the system prompt, history, every skill's metadata. Assume Claude is smart. Challenge each sentence: does Claude actually not know this? Cut explanations of what PDFs are, how libraries work, what a term means. A 50-token instruction assuming competence beats a 150-token one teaching basics.

Examples cost the most per point made, so make them earn it. One example that pins a contract the prose cannot state precisely (an exact output shape, a boundary case that reads ambiguous in words) is worth its tokens; a second example of the same point, or the same idea shown in five languages, is padding. Where a list of examples is really describing an interface, write the interface.

## Degrees of freedom

Match specificity to task fragility.

- **High** (prose steps): many valid approaches, context decides. "Review the code structure, check for edge cases, suggest improvements."
- **Medium** (parameterized pattern): a preferred shape, allowed variation.
- **Low** (exact script, no flags): fragile, order-critical, consistency-critical. "Run exactly `python scripts/migrate.py --verify --backup`. Do not modify."

Narrow bridge with cliffs -> low freedom and guardrails. Open field -> high freedom and trust. Default to the high end and spend the specificity where a mistake is expensive: a rule written to steer a reader who would have judged it correctly still has to be reconciled against that judgement, and reconciliation is not free. State the floor and what it protects; prescribe the steps when the path is genuinely narrow.

## Writing the description (the CSO trap)

The description is the ONLY thing pre-loaded for discovery, and Claude picks skills from it among many. Rules:

- Third person, under 500 chars, naming the situation that triggers it (most read naturally as "Use when...", but the situation, not the prefix, is the rule).
- ONLY triggering conditions and symptoms. Include the error strings, symptom words, synonyms an agent would search for.
- NEVER summarize the workflow.

Why the last rule: a description that summarizes steps makes Claude follow the summary instead of reading the body. Real case: "code review between tasks" caused ONE review though the body specified two. Trigger-only -> Claude read the body and did both.

```yaml
# BAD (workflow leaks in, becomes a shortcut)
description: Use when executing plans, dispatches a teammate per task with review between tasks

# GOOD (trigger only)
description: Use when executing an implementation plan with independent tasks
```

Describe the problem (race condition, flaky test), not a language-specific symptom (setTimeout), unless the skill itself is technology-specific.

A shipped description is load-bearing routing state, not prose: Claude picks among skills by these lines alone, against confusable siblings. Edit one deliberately, preserve the distinguishing trigger, and land description edits in their own commit so a routing regression is bisectable. Body edits carry no such cost.

## Naming

Gerund or verb-first, by what you DO or the core insight: `condition-based-waiting` over `async-test-helpers`, `root-cause-tracing` over `debugging-techniques`. `name` must equal the directory name. Avoid vague names (helper, utils, tools).

## Progressive disclosure

The default shape, not a rescue for files that grew too big. SKILL.md holds the trigger, the floors, and the decision rules; everything a reader needs only after committing to the work (method, evidence, parameter tables, worked procedure) goes to a sibling file. Write it that way from the first draft: the split is cheap up front and expensive to retrofit, and a SKILL.md that fits on one screen is what makes the floors findable under pressure.

Two hard rules:

- **One level deep.** Every reference file links directly from SKILL.md. Nested links (SKILL -> advanced -> details) get partially read with `head` and lose information.
- **Table of contents** atop any reference file over ~100 lines, so a partial read still reveals full scope. Keep it current when sections move.

Make execution intent explicit: "Run `x.py`" (execute) vs "See `x.py` for the algorithm" (read).

## References over restatement

The best reference is not prose at all. When something already defines the behavior exactly, point at it and say how to read it; a paraphrase in the skill is a second copy that drifts the moment the original changes, and the reader cannot tell which one is current.

- **Code is the spec.** For deterministic work ship a script rather than instructions for regenerating one, and self-document its constants (no `TIMEOUT = 47`). Name the file and the symbol inside it (`AI_TELLS` in `humanize-guard.mjs`), never the contents. A gate's real behavior is what its script does, so the skill's job is the contract around it: when it runs, what blocks, what the escape hatch is.
- **Rubrics are references.** Review lenses, grading criteria, and scoring tables belong in a file a verifier can be handed directly, which is also what lets a loop or a teammate consume them without a human relaying the standard.
- **A spec can be a rich artifact.** A failing test suite, a throwaway HTML mock, or a pointed-at source directory carries more fidelity than a paragraph describing the same thing. Prefer the artifact, and let the prose say why it is the spec.

What still belongs in prose: the floor, the tradeoff, and the reason, since those are the parts no file states.

## Consistent terminology

One term, kept: always "field," not field/box/element. Always "extract," not extract/pull/get. Inconsistent vocabulary makes instructions ambiguous.

## Avoid time-sensitive content

No "before August 2025, use the old API." It rots. Put superseded guidance in a collapsed "Old patterns" section with the deprecation noted, keep the current method as live text. Pin no model version or date in the main flow; the floating judgement-tier alias (`opus[1m]`, every spawn, per user law in dmj:dispatching-parallel-teams) is the only model reference a skill may carry, and tooling resolves it to the newest stable at invocation.

## Quick checklist

- [ ] Description: third person, triggers only, no workflow, under 500 chars; edits deliberate, distinguishing trigger kept, own commit
- [ ] Body assumes a smart reader; every sentence earns its tokens
- [ ] Freedom level matches task fragility; steps prescribed only where the path is narrow
- [ ] Name is verb-first and equals the directory
- [ ] SKILL.md holds trigger, floors, decision rules; depth in reference files one level deep, ToC if over ~100 lines
- [ ] Nothing restated that a script, rubric, test, or config already defines; those are named and pointed at
- [ ] Every example pins a contract prose cannot; no second example of the same point
- [ ] One term per concept throughout
- [ ] No time-sensitive or version-pinned content in the main flow
- [ ] Forward-slash paths only
