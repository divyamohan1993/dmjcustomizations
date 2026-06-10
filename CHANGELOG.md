# Changelog

All notable changes to dmjcustomizations are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: semver.

## [1.6.0] - 2026-06-10

### Added

- crafting-experiences: experience supremacy encoded as gates (the Jobs test kills features without a named user, moment, and relief; first-second distinctiveness; cinematic with purpose; burden subtraction; end-to-end completeness; WCAG 2.2 AA floor; self-evidence over documentation). Artifact rule: specs, maps, and plans are one-screen agent contracts, never human-tended documentation.
- requesting-code-review: conditional fifth Experience lens on user-facing diffs.

## [1.5.0] - 2026-06-10

### Added

- Automatic update notification: the SessionStart hook now checks GitHub for a newer release at most once per 24 hours (4s timeout, every failure silent, never blocks boot) and, when one exists, injects a notice instructing the session's Claude to tell the user and offer to run the two update commands. Tested on all three branches: equal versions silent, throttled re-run silent, older install fires the notice.

## [1.4.1] - 2026-06-10

### Added

- Published to GitHub (divyamohan1993/dmjcustomizations); README gains the install-from-GitHub marketplace path.

## [1.4.0] - 2026-06-10

### Added

- harnessing-claude: capability-routing skill so every session exploits the strongest native Claude features (Agent Teams vs Workflow selection, plan mode, advisor reviewer at gates, schema-validated agent outputs, dynamic !cmd skill injection, context7/WebFetch for live docs, ToolSearch, worktree isolation, background and cron runs, memory) instead of hand-rolling weaker substitutes.
- using-dmjcustomizations: parallel-default law, everything parallel (teams, in-turn batching, spikes, lenses), serialize only at user gates and real data dependencies, speed never buys robustness down.

### Changed

- Full-library compression pass: every SKILL.md and supporting instruction rewritten telegraphic for model-only consumption, 35-50% fewer prose words, zero rules, gates, rationalization rows, red flags, numbers, or cross-references lost (verified per file against git history).

## [1.3.0] - 2026-06-10

### Changed

- using-dmjcustomizations: hard conduct rule added, deleting anything outside the active working folder requires the user's explicit confirmation every time, even with full permissions (in-folder cleanup of self-created files stays free).

## [1.2.0] - 2026-06-10

### Changed

- finishing-a-development-branch: automatic pre-commit gates encoded, CHANGELOG.md updated in the same commit and all configured hooks always run (no-verify and hook-skipping are red flags; hook managers must be installed and active), plus the absolute deploy gate: nothing deploys without the full test suite green on the exact deploy artifact.
- defending-in-depth: dev-freedom/prod-strictness split made explicit, full permissions on the development machine never relax the shipped artifact; every deployed change carries negligible blast radius (reversible migrations, one-step rollback, staged or flagged exposure, kill switch on new surface).

### Added

- explore: folded in from the personal ~/.claude/skills/explore skill (which is being retired) so the whole rule system lives in this one versioned plugin. Parallel explorer teammates trace real execution, data flow, and cross-slice seams (both owners confirm every seam); code is the only source of truth; output is in-chat only, no artifacts. Boundary sharpened against exploring-codebases: explore answers "how does this work", exploring-codebases maps before building with the anti-redundancy gate.
- karpathy-laws: eight anti-hallucination and productivity working rules distilled from Andrej Karpathy's public LLM-coding guidance (short leash, receipts before claims, externalized memory, autonomy slider, context hygiene, concrete beats abstract, determinism shell, error-spiral brake).

## [1.1.0] - 2026-06-10

### Added

- exploring-codebases: parallel five-lens codebase mapping (structure, flow, assets, seams, history) producing one evidence-backed map, with a hard anti-redundancy gate (search the asset index and grep before creating any function, helper, type, or file) and fresh-context spot-verification of map claims.

## [1.0.0] - 2026-06-10

### Added

- Initial release: full fork of superpowers 5.1.0, rebuilt for the parallel agentic era.
- 14 rewritten skills: parallel-first (Agent Teams, never lone subagents), terse (lower context cost), date-agnostic (probe for the best model and tools at invocation time), with hard gates, headless fallbacks, and adversarial fresh-context verification preserved or strengthened.
- 3 new skills: defending-in-depth (security from line 1), enforcing-performance-budgets (O(1)-first, measurable budgets), researching-deeply (parallel research with adversarial source verification).
- SessionStart hook injecting the using-dmjcustomizations meta-skill (Windows-safe polyglot launcher).
- Plugin and marketplace manifests for local installation.

### Removed (relative to superpowers)

- Visual companion local web server (replaced by native AskUserQuestion previews, Playwright rendering, and live spikes).
- Codex, Gemini, Cursor, and Copilot compatibility shims (this fork targets Claude Code only).
- One-question-per-message interview flow (replaced by batched AskUserQuestion rounds).
- All "Task tool" and fire-and-forget subagent dispatch patterns (replaced by Agent Teams with SendMessage coordination).
