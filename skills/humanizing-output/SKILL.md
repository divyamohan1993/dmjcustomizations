---
name: humanizing-output
description: Use when shipping or finishing any project, before pushing prose (README, docs, landing copy, CHANGELOG, commit messages), or when setting up a repo, to strip em dashes and AI-tell language. Symptoms: "sounds AI-generated", "humanize the copy", "before push".
---

# Humanizing Output

Shipped prose reads like a careful human wrote it, never an AI. no em dashes, no AI-tell vocabulary. a gate every project carries, enforced before push and in CI, never a habit you hope to remember, so collaborators and pull requests pass the same bar.

## What blocks

Prose only: `.md`, `.mdx`, `.markdown`, `.txt`, plus commit messages in repos wiring the guard's `--commit-msg` hook (flag exists, default install wires pre-push only). fenced and inline code skipped, so real command output is never flagged.

- **Unicode dashes**: block in every mode, always. exact set = the `DASH` regex in `humanize-guard.mjs`, read there, never from memory. use commas, colons, semicolons, periods.
- **AI-tell words and phrases**: warn by default, block under `--gate` = the mode hook and CI both run. rewrite to plain words. a sample, not the list: `delve`, `seamless`, `robust`, `leverage`, `utilize`, `it's worth noting`, `testament to`, `moreover`. the list itself = `AI_TELLS` in `humanize-guard.mjs`, read there, never from memory; tune per project in `.humanize-allow`, one term per line.

## The pieces (each file is its own spec; read it, never re-derive it)

| File | What it is |
|---|---|
| `humanize-guard.mjs` | Checker, zero dependencies. `node humanize-guard.mjs --gate [files]`; no files -> scans prose changed in the push range |
| `hooks/pre-push` | Enforcement. only prose in the commits being pushed, chains husky/lefthook/native hook, degrades to dash-only when Node is missing, bypassed once by `HUMANIZE_SKIP=1 git push` |
| `humanize.mjs` | The fix. rewrites flagged prose to plain language via the `claude` CLI, shows a diff, applies only on your approval. no `claude` -> reports and stops |
| `install.sh` | `sh install.sh` wires one repo (`.humanize/` + hook), prints the CI line. `--global` sets a chained `core.hooksPath` machine-wide, aborting when a global one points elsewhere, because repointing it silently disables every hook living there, secret scanners included |

CI step: `node .humanize/humanize-guard.mjs --gate`.

## Non-negotiables

| Bar | Floor |
|---|---|
| Block, never silently mutate | Gate blocks; rewriting is a separate step you see and approve. never push machine-rewritten prose unseen |
| Never brick a push | Missing Node or `claude` degrades to dash-only, never a hard error. `HUMANIZE_SKIP=1` = the on-the-record escape hatch |
| Protect code and meaning | Only prose scanned. code, strings, links, numbers, facts stay byte-identical through a humanize pass |
| Travels with the repo | Hook + CI committed, so the gate holds everywhere, not just on your machine |

**Headless:** run the guard and report; apply a rewrite only with recorded approval, never push an unreviewed rewrite.

Next: dmj:selling-the-vision and dmj:crafting-experiences write the prose this gate keeps human; dmj:verification-before-completion before the push.
