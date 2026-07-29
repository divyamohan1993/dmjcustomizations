# Skill Authoring Best Practices

Load when writing or revising a skill body, choosing its description, or deciding how to split files. distilled from Anthropic's official guidance. SKILL.md = the method, this = the craft reference.

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

Context window = public good (system prompt, history, every skill's metadata). assume Claude is smart: cut any sentence he already knows (what PDFs are, how libraries work, term definitions). 50 tokens assuming competence > 150 teaching basics.

Examples cost most per point. one pinning a contract prose cannot state (exact output shape, ambiguous boundary case) earns its tokens; a second on the same point, or one idea in five languages, = padding. examples describing an interface -> write the interface.

## Degrees of freedom

Match specificity to task fragility.

- **High** (prose steps): many valid approaches, context decides. "Review the code structure, check for edge cases, suggest improvements."
- **Medium** (parameterized pattern): a preferred shape, allowed variation.
- **Low** (exact script, no flags): fragile, order-critical, consistency-critical. "Run exactly `python scripts/migrate.py --verify --backup`. Do not modify."

Narrow bridge with cliffs -> low freedom + guardrails. open field -> high freedom + trust. default high, spend specificity where a mistake is expensive: a rule steering a reader who would have judged right still costs a reconciliation, never free. floor + what it protects; steps only where the path is genuinely narrow.

## Writing the description (the CSO trap)

Description = the ONLY thing pre-loaded for discovery, and Claude picks skills from it among many. rules:

- Third person, under 500 chars, naming the situation that triggers it (most read naturally as "Use when...", but the situation, not the prefix, is the rule).
- ONLY triggering conditions and symptoms. include error strings, symptom words, synonyms an agent would search for.
- NEVER summarize the workflow.

Why: a step-summary makes Claude follow the summary, never the body. real case: "code review between tasks" -> ONE review where the body specified two. trigger-only -> body read, both done.

```yaml
# BAD (workflow leaks in, becomes a shortcut)
description: Use when executing plans, dispatches a teammate per task with review between tasks

# GOOD (trigger only)
description: Use when executing an implementation plan with independent tasks
```

Describe the problem (race condition, flaky test), not a language-specific symptom (setTimeout), unless the skill itself is technology-specific.

Shipped description = load-bearing routing state: Claude picks among confusable siblings by these lines alone. edit deliberately, keep the distinguishing trigger, land description edits in their own commit so a routing regression is bisectable. body edits carry no such cost.

## Naming

Gerund or verb-first, by what you DO or the core insight: `condition-based-waiting` over `async-test-helpers`, `root-cause-tracing` over `debugging-techniques`. `name` must equal the directory name. avoid vague names (helper, utils, tools).

## Progressive disclosure

Default shape, never a rescue for files that grew too big. SKILL.md = trigger + floors + decision rules; everything needed only after committing to the work (method, evidence, parameter tables, worked procedure) -> a sibling file. write it that way from the first draft: cheap up front, expensive to retrofit, and a one-screen SKILL.md is what makes floors findable under pressure.

Two hard rules:

- **One level deep.** every reference file links directly from SKILL.md. nested links (SKILL -> advanced -> details) get partially read with `head`, losing information.
- **Table of contents** atop any reference file over ~100 lines, so a partial read still reveals full scope. keep it current when sections move.

Execution intent explicit: "Run `x.py`" (execute) vs "See `x.py` for the algorithm" (read).

## References over restatement

Best reference = not prose at all. something already defining the behavior exactly -> point at it, say how to read it. a paraphrase = a second copy that drifts the moment the original changes, unmarked as stale.

- **Code is the spec.** deterministic work -> ship a script, never instructions for regenerating one, constants self-documenting (no `TIMEOUT = 47`). name the file + the symbol (`AI_TELLS` in `humanize-guard.mjs`), never the contents. a gate's real behavior = what its script does, so the skill owns only the contract: when it runs, what blocks, what the escape hatch is.
- **Rubrics are references.** review lenses, grading criteria, scoring tables live in a file a verifier can be handed directly: that is what lets a loop or a teammate consume them without a human relaying the standard.
- **A spec can be a rich artifact.** a failing test suite, a throwaway HTML mock, a pointed-at source directory carries more fidelity than a paragraph about it. prefer the artifact, let the prose say why it is the spec.

Still prose: the floor, the tradeoff, the reason. no file states those.

## Consistent terminology

One term, kept: always "field," never field/box/element. always "extract," never extract/pull/get. inconsistent vocabulary makes instructions ambiguous.

## Avoid time-sensitive content

No "before August 2025, use the old API." it rots. superseded guidance -> a collapsed "Old patterns" section, deprecation noted, current method live text. no model version or date pinned in the main flow: the floating judgement-tier alias (`opus[1m]`, every spawn, per user law in dmj:dispatching-parallel-teams) is the only model reference a skill may carry, resolved to newest stable at invocation.

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

Back to SKILL.md for the method these serve.
