---
name: humanizing-output
description: Use when shipping or finishing any project, before pushing prose (README, docs, landing copy, CHANGELOG, commit messages), or when setting up a repo, to strip em dashes and AI-tell language. Symptoms: "sounds AI-generated", "humanize the copy", "before push".
---

# Humanizing Output

Shipped prose must read like a careful human wrote it, never an AI. No em dashes, no AI-tell vocabulary. This is a gate every project carries, enforced before push and in CI, not a habit you hope to remember, so collaborators and pull requests pass the same bar.

## What blocks

Prose only: `.md`, `.mdx`, `.markdown`, `.txt`, plus commit messages in repos that wire the guard's `--commit-msg` hook (the flag exists; the default install wires pre-push only). Fenced and inline code are skipped, so real command output is never flagged.

- **Unicode dashes**: block in every mode, always. The exact character set is the `DASH` regex in `humanize-guard.mjs`; read it there rather than from memory. Use commas, colons, semicolons, or periods.
- **AI-tell words and phrases**: warn by default, block under `--gate`, which is the mode the hook and CI both run. Rewrite to plain words. A sample, not the list: `delve`, `seamless`, `robust`, `leverage`, `utilize`, `it's worth noting`, `testament to`, `moreover`. The list itself is `AI_TELLS` in `humanize-guard.mjs`: read it there rather than from memory, and tune per project in `.humanize-allow`, one term per line.

## The pieces (each file is its own spec; read it, do not re-derive it)

| File | What it is |
|---|---|
| `humanize-guard.mjs` | The checker, zero dependencies. `node humanize-guard.mjs --gate [files]`; given no files it scans the prose changed in the push range |
| `hooks/pre-push` | The enforcement. Checks only prose in the commits being pushed, chains husky, lefthook, and a native hook, degrades to a dash-only check when Node is missing, bypassed once by `HUMANIZE_SKIP=1 git push` |
| `humanize.mjs` | The fix. Rewrites flagged prose to plain language with the `claude` CLI, shows a diff, applies only on your approval. No `claude` present means it reports and stops |
| `install.sh` | `sh install.sh` wires one repo (`.humanize/` plus the hook) and prints the CI line. `sh install.sh --global` sets a chained `core.hooksPath` for every repo on the machine, and aborts when a global one already points elsewhere, because repointing it silently disables every hook living there, secret scanners included |

CI step: `node .humanize/humanize-guard.mjs --gate`.

## Non-negotiables

| Bar | Floor |
|---|---|
| Block, never silently mutate | The gate blocks; rewriting is a separate step you see and approve. Never push machine-rewritten prose unseen |
| Never brick a push | A missing Node or `claude` degrades to a dash-only check, never a hard error. `HUMANIZE_SKIP=1` is the on-the-record escape hatch |
| Protect code and meaning | Only prose is scanned; code, strings, links, numbers, and facts stay byte-identical through a humanize pass |
| Travels with the repo | Hook plus CI committed, so the gate is enforced everywhere, not just on your machine |

**Headless:** run the guard and report; apply a humanize rewrite only with recorded approval, and never push an unreviewed rewrite.

Next: dmj:selling-the-vision and dmj:crafting-experiences write the prose this gate keeps human; dmj:verification-before-completion before the push.
