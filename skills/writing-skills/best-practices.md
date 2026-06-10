# Skill Authoring Best Practices

Load when writing or revising a skill body, choosing its description, or deciding how to split files. Distilled from Anthropic's official guidance. The SKILL.md states the method; this is the craft reference.

## Contents
- Concise is key
- Degrees of freedom
- Writing the description (the CSO trap)
- Naming
- Progressive disclosure
- Consistent terminology
- Avoid time-sensitive content
- Quick checklist

## Concise is key

The context window is a public good shared with the system prompt, history, and every other skill's metadata. Assume Claude is already smart. Challenge each sentence: does Claude actually not know this? Cut explanations of what PDFs are, how libraries work, what a term means. A 50-token instruction that assumes competence beats a 150-token one that teaches basics.

## Degrees of freedom

Match specificity to how fragile the task is.

- **High freedom** (prose steps): many valid approaches, context decides. Example: "review the code structure, check for edge cases, suggest improvements."
- **Medium freedom** (parameterized pattern): a preferred shape with allowed variation.
- **Low freedom** (exact script, no flags): fragile, order-critical, consistency-critical. Example: "Run exactly `python scripts/migrate.py --verify --backup`. Do not modify."

Narrow bridge with cliffs -> low freedom and guardrails. Open field -> high freedom and trust.

## Writing the description (the CSO trap)

The description is the ONLY thing pre-loaded for discovery, and Claude picks skills from it among many. Rules:

- Third person, starts "Use when", under 500 chars.
- ONLY triggering conditions and symptoms. Include the error strings, symptom words, and synonyms an agent would search for.
- NEVER summarize the workflow.

Why the last rule matters: when a description summarizes steps, Claude follows the summary instead of reading the body. A real case: "code review between tasks" caused ONE review even though the body specified two. Changed to a trigger-only description, Claude read the body and did both.

```yaml
# BAD (workflow leaks in, becomes a shortcut)
description: Use when executing plans, dispatches a teammate per task with review between tasks

# GOOD (trigger only)
description: Use when executing an implementation plan with independent tasks
```

Describe the problem (race condition, flaky test), not a language-specific symptom (setTimeout), unless the skill itself is technology-specific.

## Naming

Gerund or verb-first, by what you DO or the core insight: `condition-based-waiting` over `async-test-helpers`, `root-cause-tracing` over `debugging-techniques`. The `name` field must equal the directory name. Avoid vague names (helper, utils, tools).

## Progressive disclosure

SKILL.md is a table of contents. Keep its body lean; push heavy reference or reusable tools to sibling files. Two hard rules:

- **One level deep.** Every reference file links directly from SKILL.md. Nested links (SKILL -> advanced -> details) get partially read with `head` and lose information.
- **Table of contents** at the top of any reference file over ~100 lines, so a partial read still reveals the full scope.

Make execution intent explicit: "Run `x.py`" (execute) versus "See `x.py` for the algorithm" (read). For deterministic operations, ship a script rather than asking Claude to regenerate one; self-document its constants (no `TIMEOUT = 47`).

## Consistent terminology

Pick one term and keep it: always "field," not field/box/element. Always "extract," not extract/pull/get. Inconsistent vocabulary makes instructions ambiguous.

## Avoid time-sensitive content

No "before August 2025, use the old API." It rots. Put superseded guidance in a collapsed "Old patterns" section with the deprecation noted, and keep the current method as the live text. Name no model, version, or date in the main flow; tell the reader to use the strongest model and newest stable tooling at invocation.

## Quick checklist

- [ ] Description: third person, "Use when", triggers only, no workflow, under 500 chars
- [ ] Body assumes a smart reader; every sentence earns its tokens
- [ ] Freedom level matches task fragility
- [ ] Name is verb-first and equals the directory
- [ ] Reference files one level deep; ToC if over ~100 lines
- [ ] One term per concept throughout
- [ ] No time-sensitive or version-pinned content in the main flow
- [ ] Forward-slash paths only
