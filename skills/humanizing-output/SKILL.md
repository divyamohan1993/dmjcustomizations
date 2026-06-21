---
name: humanizing-output
description: Use when shipping or finishing any project and before pushing prose (README, docs, landing copy, CHANGELOG, commit messages), or when setting up a repo, to strip em dashes and AI-tell language so the writing reads human. Symptoms: "remove em dashes", "sounds AI-generated", "humanize the copy", "before push", "no AI language".
---

# Humanizing Output

Shipped prose must read like a careful human wrote it, never an AI. No em dashes, no AI-tell vocabulary. This is a gate every project carries, enforced before push, not a habit you hope to remember. It lives in the project (and in CI), so collaborators and pull requests pass the same bar.

## What it checks (prose only: md, mdx, txt, and commit messages)

- **Unicode dashes** (em, en, horizontal bar, minus, figure): always blocks. Use commas, colons, semicolons, or periods.
- **AI-tell words and phrases** (`delve`, `tapestry`, `robust`, `seamless`, `leverage`, `utilize`, `it's worth noting`, `boasts`, `testament to`, `underscores`, `moreover`, `elevate`, `unlock`, `myriad`, `plethora`, `pivotal`, and kin): blocks in gate mode; rewrite to plain words.

Fenced and inline code are skipped, so real command output is never flagged. Tune false positives per project in `.humanize-allow`, one term per line.

## The gate (every project includes it)

- `humanize-guard.mjs`: the checker. `node humanize-guard.mjs --gate [files]`. Zero dependencies. No files given means it scans the prose changed in the push range.
- `hooks/pre-push`: blocks a push that has violations. Bypass once with `HUMANIZE_SKIP=1 git push`. It chains an existing `.husky/pre-push`, so it never disables husky or lefthook, and it falls back to a dash-only check when Node is absent rather than erroring.
- `humanize.mjs`: the fix. It rewrites flagged prose to plain language with the `claude` CLI, shows a diff, and applies only on your approval. No `claude` present means it reports and stops.
- CI step: `node .humanize/humanize-guard.mjs --gate` in the pipeline covers collaborators and pull requests.

## Install

- One repo: `sh install.sh` copies the guard and fixer into `.humanize/` and wires the pre-push hook (or `.husky/`), then prints the CI line.
- Every repo on the machine: `sh install.sh --global` sets a chained `core.hooksPath`. It warns first, because that path overrides per-repo `.git/hooks` for every repo; the hook chains husky so nothing breaks.

## Non-negotiables

| Bar | Floor |
|---|---|
| Block, never silently mutate | The gate blocks; rewriting is a separate step you see and approve. Never push machine-rewritten prose unseen |
| Never brick a push | A missing Node or `claude` degrades to a dash-only check, never a hard error. `HUMANIZE_SKIP=1` is the on-the-record escape hatch |
| Protect code and meaning | Only prose is scanned; code, strings, links, numbers, and facts stay byte-identical through a humanize pass |
| Travels with the repo | Hook plus CI committed, so the gate is enforced everywhere, not just on your machine |

## Red flags (stop)

- Auto-rewriting prose and pushing it with no human seeing the diff.
- A global hook that quietly disables a project's husky or lefthook.
- Scanning or rewriting source code instead of only prose.
- An em dash shipped because the check was skipped silently rather than with `HUMANIZE_SKIP=1` on the record.

**Headless:** run the guard and report; apply a humanize rewrite only with recorded approval, and never push an unreviewed rewrite.

Next: dmj:selling-the-vision and dmj:crafting-experiences write the prose this gate keeps human; dmj:verification-before-completion before the push.
