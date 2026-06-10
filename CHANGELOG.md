# Changelog

All notable changes to dmjcustomizations are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: semver.

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
