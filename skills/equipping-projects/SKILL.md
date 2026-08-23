---
name: equipping-projects
description: "Use when entering a fresh or under-tooled repo, starting a new project, or before the first commit leaves the machine, to wire the guard rails the project calls for (hooks, secret scan, CI mirroring local gates, MCP config, project memory). Symptoms: no hooks, no CI, \"set up the repo\", a first task in an unequipped codebase."
---

# Equipping Projects

Every repo gets its guard rails wired in minutes, idempotent, DERIVED from what the project is, never a fixed kit. Skills stay global; the equip pass adapts them to one project.

## Gate: before the first commit leaves the machine

On any repo you work in: the equip pass has run, or was consciously proposed. A commit pushed from an unequipped repo (no secret scan, no CI) is the failure this skill prevents: the first unscanned commit is the one with the key in it. "Tooling later" or "open a ticket" = deferral wearing a paper trail. Runs in minutes; propose it now.

## Ownership rule

- **Your own or a new repo:** wire by default, announce what was wired.
- **Someone else's repo (client, upstream, team):** not yours to rewire, yours to propose. ONE message (what, why, minutes to run), wire on consent. Never silently rewire a repo you do not own; never let that consent wait kill the gate either, the proposal itself is the record.

## Detect, then wire (the derivation table)

| Signal in the repo | Wire |
|---|---|
| Always | Secret-scan pre-commit (fail closed, diff-scoped), tests in CI on every push, CHANGELOG present, .env.example committed when env vars exist, dependency-update automation (Renovate or Dependabot: auto-merge patch and minor on green CI, majors reviewed) plus a dependency audit failing CI on high or critical |
| Endpoints exposed | REST or GraphQL, never mixed; versioned `/v1/` from day one; uniform error shape `{ error: { code, message, requestId, details? } }` that never leaks internals; cursor pagination; per-user per-endpoint rate limits with `Retry-After`; idempotency keys on mutations; docs auto-generated, stale docs fail the build |
| Prose ships (README, docs, marketing) | Prose pre-push gate plus the same check in CI: dashes and AI-tell language (dmj:humanizing-output), and on AI-authored docs the EARS and STE lanes active (dmj:enforcing-quality-gates) |
| Web UI present | Preview or launch config, browser-automation MCP for the screenshot gate (dmj:art-directing), perf budgets asserted in CI (dmj:enforcing-performance-budgets) |
| External libraries consumed | Live-docs MCP (context7-class) in project config so API answers come from current docs, never memory (dmj:harnessing-claude) |
| Deploy target exists or is planned | Deploy script, health endpoints, pipeline job running the same gates (dmj:shipping-to-production) |
| Agents will work here | Project CLAUDE.md seeded via the native `/init` command (build, test, run commands, conventions); what /init cannot know: file-type or directory conventions split into path-scoped .claude/rules/ (globs in paths frontmatter) so CLAUDE.md stays lean and rules load only where they apply |

Nothing fires without its signal: a headless CLI gets no browser tooling, a repo with no prose gets no prose gate. Fit is the point.

## Wire the quality gate

Part of equipping any repo: `bash install-gate.sh <repo>` (dmj:enforcing-quality-gates) detects every stack and writes four files: `qgate.sh`, `qgate.config.sh`, `.qgate-lanes.sh`, a CI job. Commit all four. Pre-commit `--fast`, pre-push and PR `--merge`, nightly `--deep`. Not equipped until its gate runs and reports every lane.

## Chain, never replace

Installers CHAIN existing hooks (husky, lefthook, native) and fail closed when they cannot. A global hooks path must re-run repo-level hooks or it silently disables them machine-wide. Rerunning converges: no duplicate hooks, no clobbered config, existing managers detected and respected.

**Headless:** wire your own and new repos fully; third-party repos -> prepare the pass and PARK the consent.

Next: dmj:shipping-to-production for the deploy pieces; dmj:exploring-codebases before working in the newly equipped repo.
