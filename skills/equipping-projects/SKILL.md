---
name: equipping-projects
description: Use when entering a fresh or under-tooled repo, starting a new project, or before the first commit leaves the machine, to detect and wire the guard rails and harness the project calls for: hooks (secret scan, prose gate), CI mirroring local gates, MCP and preview config, project memory. Symptoms: no hooks, no CI, no scanner, "set up the repo", "wire the tooling", a first task in an unequipped codebase.
---

# Equipping Projects

Every repo gets its guard rails wired in minutes, idempotent, DERIVED from what the project is, never a fixed kit. The skills stay global; the equip pass is where they adapt to one project.

## Gate: before the first commit leaves the machine

On any repo you work in: the equip pass has run, or was consciously proposed. A commit pushed from an unequipped repo (no secret scan, no CI) is the failure this skill exists to prevent.

## Ownership rule

- **Your own or a new repo:** wire by default, announce what was wired.
- **Someone else's repo (client, upstream, team):** propose the pass in ONE message (what, why, minutes to run), wire on consent. Never silently rewire a repo you do not own; never let that consent wait kill the gate either, the proposal itself is the record.

## Detect, then wire (the derivation table)

| Signal in the repo | Wire |
|---|---|
| Always | Secret-scan pre-commit (fail closed, diff-scoped), tests in CI on every push, CHANGELOG present, .env.example committed when env vars exist, dependency-update automation (Renovate or Dependabot: auto-merge patch and minor on green CI, majors reviewed) plus a dependency audit failing CI on high or critical |
| Prose ships (README, docs, marketing) | Prose pre-push gate (dashes, AI-tell language) plus the same check in CI (dmj:humanizing-output) |
| Web UI present | Preview or launch config, browser-automation MCP for the screenshot gate (dmj:art-directing), perf budgets asserted in CI (dmj:enforcing-performance-budgets) |
| External libraries consumed | Live-docs MCP (context7-class) in project config so API answers come from current docs, never memory (dmj:harnessing-claude) |
| Deploy target exists or is planned | Deploy script, health endpoints, pipeline job running the same gates (dmj:shipping-to-production) |
| Agents will work here | Project CLAUDE.md seeded with build, test, and run commands and the repo's conventions; file-type or directory conventions split into path-scoped .claude/rules/ (globs in paths frontmatter) so CLAUDE.md stays lean and rules load only where they apply |

Nothing on the list fires without its signal: a headless CLI gets no browser tooling, a repo with no prose gets no prose gate. Fit is the point.

## Chain, never replace

Installers CHAIN existing hooks (husky, lefthook, native) and fail closed when they cannot; a global hooks path must re-run repo-level hooks or it silently disables them machine-wide. Rerunning the pass converges: no duplicate hooks, no clobbered config, existing managers detected and respected.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "Just fix the task, tooling later" | The first unscanned commit is the one with the key in it. Minutes now, breach never |
| "Open a ticket for the tooling" | A ticket is deferral with a paper trail. Propose the pass now; it runs in minutes |
| "One standard kit for every repo" | Web gear on a CLI is dead weight and noise. Derive from the repo's signals |
| "It is not my repo, skip it" | Not yours to rewire, yours to propose. One message, then consent wires it |

## Red flags (stop)

- A commit leaving an unequipped repo unscanned.
- The same kit installed regardless of stack.
- An installer that replaces or shadows an existing hook instead of chaining.
- Equipping a third-party repo with no proposal on record.

**Headless:** wire your own and new repos fully; for third-party repos, prepare the pass and PARK the consent.

Next: dmj:shipping-to-production for the deploy pieces; dmj:exploring-codebases before working in the newly equipped repo.
