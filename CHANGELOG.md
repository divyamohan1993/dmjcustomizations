# Changelog

All notable changes to dmjcustomizations are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: semver.

## [2.2.0] - 2026-06-10

### Added

- selling-the-vision: launch and marketing persuasion as gates, the one-second hook (headline lands the core promise alone), the keynote arc (problem the audience feels, agitate, reveal, proof, one CTA), one message, one call to action, show-not-tell hero, 7-word tagline, honest claims only, channel-fit sizing. Distinct from crafting-experiences (product UX) by audience and artifact; boundary cross-linked both ways. Carries the Jobs-grade go-to-market craft into the plugin so it survives removal of the global reference docs.

## [2.1.0] - 2026-06-10

### Added

- scripts/rename-check.js + release.sh RENAME_MAP fast-path: a mass rename (e.g. the 2.0.0 plugin rename) now passes the release gate by mechanical proof instead of fail-closing the model gate on a huge diff. The operator DECLARES the substitution (`RENAME_MAP="old=>new"`); the check verifies the staged skill diff is EXACTLY that rename and nothing else. Safety proven by test: a disguised rule inversion (never to always) not in the declared map leaves residual lines and correctly falls through to the model gate, never false-passing.

## [2.0.0] - 2026-06-10

### Changed

- BREAKING: plugin renamed `dmjcustomizations` to `dmj` (and marketplace name to `dmj`), so every skill now fires as `dmj:<name>` (e.g. `dmj:brainstorming`) for instant identification. All cross-references rewritten to the `dmj:` prefix; meta-skill `using-dmjcustomizations` renamed to `using-dmj`; hook, validator, release script, and output-doc paths (`docs/dmj/`) updated. New install: `/plugin install dmj@dmj`. The GitHub repo slug stays `dmjcustomizations`. Existing installs must reinstall under the new name.

## [1.8.2] - 2026-06-10

### Changed

- harnessing-claude: Maximums section set to the owner's canonical wording.
- scripts/validate: rewritten as a single Node pass (scripts/validate.js), 13.6s to 0.4s (~34x) by collapsing ~180 per-file subprocess spawns into one process; bash wrapper keeps only the hook-syntax check.
- scripts/release: behavioral-diff gate now fires only when a skill's behavior text actually changes (not version or CHANGELOG-only releases) and runs on a fast model (sonnet, low effort, haiku fallback) instead of the session default, with the CHANGELOG passed separately as relocation intent.

## [1.8.1] - 2026-06-10

### Added

- harnessing-claude: "Max the knobs" section restored in non-repeating form, the execution-dial layer (extended thinking, effort ceiling, long-context tier, widest parallelism) distinct from model selection, with explicit probe-before-set and dial-down-only-on-a-measured-cost-ceiling rules. Carries the maximize-everything posture independent of the global CLAUDE.md the owner plans to remove.

## [1.8.0] - 2026-06-10

### Added

- scripts/pre-commit-secrets.sh: portable diff-scoped secret guard for machines without the owner's global git hooks (gitleaks preferred, Perl single-pass fallback, never ripgrep in hook environments); benchmarked sub-second on a 6k-line staged diff with planted secrets caught at file:line. The owner's repos already inherit a production Perl guard via core.hooksPath; this ships the same defense for everyone else.
- scripts/behavioral-test.sh: mechanically graded red/green behavioral check of the TDD Iron Law (one model call, CHOICE-letter grading); required after discipline-skill edits.
- release.sh: fresh-context behavioral-diff review gate between staging and commit; a skill diff that inverts, weakens, or un-relocates a rule BLOCKS the release. Implements propose-review-publish with an independent reviewer.
- writing-skills: kill criterion, anything restating the system prompt, one person's opinions, or another skill is a paragraph, never a new skill.

### Changed

- README: "budgets enforced in CI" corrected to what is true (the skills require projects to enforce them).
- harnessing-claude: Maximums and Dynamic-skills sections removed (environment-forced and relocated to writing-skills respectively); cross-refs retargeted.
- test-driven-development, requesting-code-review, landing-sessions: absorbed the unique karpathy laws (concrete-beats-abstract, one-concern-per-diff, memory-at-decision-time).

### Removed

- karpathy-laws: retired under the new kill criterion; its load-bearing laws already lived in (or are now folded into) verification-before-completion, systematic-debugging, test-driven-development, requesting-code-review, and landing-sessions. Battery section 9 retargeted to the fold hosts.

## [1.7.1] - 2026-06-10

### Changed

- dispatching-parallel-teams: orchestrator posture encoded, the lead session is the control plane (delegate processing, hold conclusions not transcripts, stay responsive to the user) and user updates mid-run are steers relayed to running teammates via SendMessage, never stop-and-respawn.

## [1.7.0] - 2026-06-10

### Added

- landing-sessions: session-scope teardown gate (learnings to memory, state committed and pushed, teams and worktrees and background tasks to zero, loose threads surfaced); the meta-skill routes wrap-ups to it.
- scripts/release.sh: one-command release (manifests bump, validate, commit, push, local install refresh) with the changelog-before-commit law enforced as a precondition.
- scripts/validate.sh + GitHub Actions workflow: the structural audit (frontmatter, budgets, dashes, forbidden tokens, handoffs, manifest/version/README coherence) now runs itself on every push.

### Changed

- using-dmj: 1% rule scoped precisely to acting turns (file reads/edits, commands, agent spawns, approach commitments); pure conversation about already-verified state answers directly. Dead superpowers-precedence line replaced with the landing-sessions route.
- exploring-codebases: stale maps declared deletable debris, never artifacts to tend.

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
- using-dmj: parallel-default law, everything parallel (teams, in-turn batching, spikes, lenses), serialize only at user gates and real data dependencies, speed never buys robustness down.

### Changed

- Full-library compression pass: every SKILL.md and supporting instruction rewritten telegraphic for model-only consumption, 35-50% fewer prose words, zero rules, gates, rationalization rows, red flags, numbers, or cross-references lost (verified per file against git history).

## [1.3.0] - 2026-06-10

### Changed

- using-dmj: hard conduct rule added, deleting anything outside the active working folder requires the user's explicit confirmation every time, even with full permissions (in-folder cleanup of self-created files stays free).

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
- SessionStart hook injecting the using-dmj meta-skill (Windows-safe polyglot launcher).
- Plugin and marketplace manifests for local installation.

### Removed (relative to superpowers)

- Visual companion local web server (replaced by native AskUserQuestion previews, Playwright rendering, and live spikes).
- Codex, Gemini, Cursor, and Copilot compatibility shims (this fork targets Claude Code only).
- One-question-per-message interview flow (replaced by batched AskUserQuestion rounds).
- All "Task tool" and fire-and-forget subagent dispatch patterns (replaced by Agent Teams with SendMessage coordination).
