# Changelog

All notable changes to dmjcustomizations are documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning: semver.

## [2.16.0] - 2026-07-07

### Added

- orchestrating-products (new skill): the wireframe. One table routes an idea through ten gated stages (research, definition, identity, plan, equip, build, verify, ship, operate, evolve), each stage naming its owning skill, its loop primitive, and the cheapest model tier that holds the stage's bar; strongest tiers reserved for definition and adversarial review, scripts replacing inference wherever work is deterministic. Token-economy laws (scripts beat inference, criteria beat supervision, fresh minimal contexts, pilot before fleet, never re-derive), the ecosystem rule (a graph of pipeline runs sharing identity tokens and contracts, never one mega-build), and the floors law (a tier that misses a security, performance, or experience bar is not sufficient: escalate the tier, never lower the bar). Justified: no artifact carried the stage-to-skill-to-tier matrix, so every session re-derived it, which is itself the token leak; user-ordered. GREEN 3/3 with verbatim citations. Battery section 19; runner grows ORCH19B (9 scenarios).
- Skill count honesty: this breaks the informal 30-skill cap at 31. On record: the conductor is the one skill whose job is reducing total inference cost across all the others; the cap intent (every addition must earn routing tax) is preserved by the RED evidence and by its role as entry point.

## [2.15.0] - 2026-07-07

### Added

- tracing-codebases: disallowed-tools frontmatter (Write, Edit, NotebookEdit). The skill's chat-only contract, previously instruction backed by battery scenario 8B, is now enforced by the harness itself while the skill is active. Same enforcement-over-instruction philosophy as the 2.14.0 PreToolUse guard.
- equipping-projects: the project-memory row now wires path-scoped .claude/rules/ (globs in paths frontmatter) alongside CLAUDE.md, per current docs guidance (CLAUDE.md stays lean, conventions load only where they apply).
- writing-skills: frontmatter rule updated from "two fields" to required-two-plus-earned-harness-fields: disallowed-tools, paths, or context enter only when they turn one of the skill's own contracts into enforcement, never as decoration.

### Audit notes

- Third docs sweep (skills frontmatter reference, .claude directory, memory pages, fetched 2026-07-07). Deliberately not adopted: when_to_use (descriptions already routing-optimized and capped), paths-gating on discipline skills (would suppress auto-load in conversations that precede file work), context fork (fights team orchestration where the lead spawns and coordinates), skill-scoped hooks and argument-hint (no consumer in this library). Docs surface relevant to a skills plugin is now fully adopted or consciously declined across three sweeps.

## [2.14.0] - 2026-07-07

### Added

- hooks/pre-tool-guard + PreToolUse wiring: three skill laws become hard gates at the harness level. Denies, via permissionDecision, any Bash or PowerShell call containing git --no-verify, git push --force or -f (--force-with-lease stays allowed), or git reset --hard against origin/ or @{u}. Escape hatch DMJ_ALLOW=1, logged loudly, meant only for the user's explicit on-record consent, mirroring HUMANIZE_SKIP. Fail-open without perl or on unexpected input: the guard is defense in depth on top of the skill instructions, never the only line. scripts/guard-test.sh: 13 deterministic probes (deny, allow, and bypass paths), wired into validate.sh.
- marketplace.json relevance block (v2.1.152+ clients): suggests the plugin on real engineering sessions (git/pnpm/npm/cargo/go commands, common manifests read). Inert until an administrator allowlists the marketplace; older clients ignore it.
- validate.sh now runs the official claude plugin validate when the CLI is present (skipped in CI where it is absent), plus syntax and probe checks for the new guard.

### Audit notes

- Full docs sweep (code.claude.com index, plugins reference, hooks reference, plugin-relevance, fetched 2026-07-07). Adopted: PreToolUse enforcement, relevance metadata, official schema validation. Deliberately not adopted, with reasons: plugin-shipped agents (the library's Agent-Teams law supersedes lone subagent definitions), bundled MCP servers (duplicate the playwright and context7 plugins already present), LSP servers and themes (language-specific and cosmetic, no discipline value), background monitors (experimental; a project-agnostic plugin has no universal thing to watch), channels (infrastructure product, not a skills-library concern).

## [2.13.0] - 2026-07-07

### Added

- harnessing-claude: goal-loop routing. New capability row sends any task with a deterministic finish line (tests pass, score threshold, queue empty) to the harness's goal primitive: the machine-checkable criteria become the stop condition, a turn cap bounds the run, and an independent evaluator judges done, never the working model. New "Loops close the automation" section states the design intent: skill gates are machine-checkable precisely so loops can consume them (acceptance criteria, budgets, screenshot gates double as goal conditions). Long-or-recurring row now names interval-matched time loops. New red flag: babysitting turn-by-turn what a goal loop would finish. Verified against live Claude Code docs (agents, goal, scheduling pages, fetched 2026-07-07). Justified: RED runs attributed the evaluator-decides-done rule to the skill when it was only in the scenario text (L2 time-loop routing cited real skill rows and needed no change); GREEN 2/2 citing the new row. Battery section 18; runner grows HARN18A (8 scenarios).

## [2.12.0] - 2026-07-07

### Added

- stewarding-data (new skill): data outlives code. Gate 0 restorable-before-touchable (a backup counts only after its restore is DRILLED to scratch with counts and checksums, on a schedule); expand-migrate-contract migrations with tested down-paths, contract in a later release; pipeline-only migration runs (hand-run prod SQL is an incident); lifecycle columns, field-level PII crypto, written retention per data type, executable right-to-deletion. Baselines passed curated choice probes on model priors, but no portable artifact carried the operational floors (drill schedule, down-path law, two-release contract); user-approved addition.
- observing-production (new skill): health from signals, not silence. Gate 0 instrumented-before-deployed (SLOs tied to the perf budgets, 3 to 5 user-symptom alerts, a paging path, in writing); structured logs with correlation IDs propagated across boundaries; golden-signal dashboards; alert-fatigue law (ignored twice means deleted or fixed); incident loop of detect, rollback-first, root-cause, blameless post-mortem whose action items land as commits and tests with owners. Same justification pattern as stewarding-data.
- equipping-projects: the Always row now wires dependency-update automation (Renovate or Dependabot, auto-merge patch and minor on green CI, majors reviewed) plus a dependency audit failing CI on high or critical.
- tests/pressure-test-battery.md: sections 16 (stewarding-data) and 17 (observing-production); scripts/behavioral-test.sh grows DATA16A and OBS17A (7 scenarios total).

### Changed

- Renamed skill explore to tracing-codebases: the old slug was shadowed by the Claude Code builtin explore skill, so routing could land on the wrong one. Content unchanged; no other skill referenced the old slug (verified by grep); README row and battery section header updated.

## [2.11.0] - 2026-07-06

### Fixed

- writing-plans: plan artifacts now save under docs/dmj/plans/, the same root as specs (brainstorming), maps (exploring-codebases), and skill-learnings (evolving-skills). Previously docs/dmjcustomizations/plans/ split project artifacts across two roots.

### Changed

- Full-plugin conflict audit, evidence-backed: all 30 dmj: cross-skill references resolve (zero dangling); the suspected equipping-projects vs brainstorming first-commit deadlock tested 2/2 clean in a dual-skill run (guard-rail wiring is hygiene the equip pass owns, the design gate governs the feature, they compose in parallel); the shipping-to-production vs enforcing-performance-budgets cost overlap confirmed complementary through their cross-links. One known name shadow remains, dmj:explore vs the harness builtin explore skill; the rename is parked for the user since it is a breaking slug change (RENAME_MAP release path exists for exactly this).

## [2.10.1] - 2026-07-06

### Added

- tests/pressure-test-battery.md: 5F (cost pressure cannot convert a committed budget into a known issue; free raced first, breach escalated with numbers) and 14C (a billable resource is never provisioned on "it's pennies"; both paths surfaced with the free path's compromise named, the user decides). Both behaviors verified 4/4 green with skill-text attribution (2.9.0 cost axis, 2.10.0 cost gate), so no skill was edited; the scenarios lock the evidence in as regression guards.

## [2.10.0] - 2026-07-06

### Added

- shipping-to-production (new skill): deploys as scripted, repeatable, reversible operations. Green-on-the-exact-artifact gate, the deploy artifact set every project carries (idempotent script with env validation and health-probe failure, one-step rollback, front door, supervision, pipeline), a written cost gate before any billable resource, the incident rule (rollback first, fix through the pipeline, never patch a live server), and manual-boundary handling (hand the user the DNS record, never automate around missing access). Justified: baseline runs reached the right choices only by citing machine-local global config ("my global standards", "same artifact everywhere"), so the rules did not live in the portable artifact; the operational technique existed in no skill.
- equipping-projects (new skill): detect-and-wire project guard rails in minutes, idempotent, derived from the repo's signals (secret scan and CI always; prose gate when prose ships; preview, browser MCP, perf budgets when a web UI exists; live-docs MCP when libraries are consumed; deploy pieces when a target exists; project memory when agents work there), with the chain-never-replace hook law and an ownership rule: wire your own repos by default, propose in one message and wire on consent for third-party repos. Justified: clean baseline FAIL (agent deferred tooling to a someday ticket on a client repo).
- crafting-experiences: three bars and an evidence-graded reference. Coherent world (one source of truth, changes reflected everywhere immediately, staleness is a defect), Engineered feeling (journeys designed to researched psychology: first success in seconds, one deliberate peak, endings that land; personalization only from consented first-party signals; compulsion mechanics never ship), Longevity (standards first, enhancement layered, data portable). New experience-psychology.md carries the primary research with honest confidence grades (Doherty threshold, peak-end, flow, choice load, aesthetic-usability, Michotte causality, endowed progress, von Restorff, personalization-privacy paradox, variable-reward ethics floor) and a per-journey method. Justified: RED runs attributed the operative rules to option text, model priors, and global config rather than the skill.
- tests/pressure-test-battery.md: 10G, 10H, 10I (coherent world, onboarding psychology, telemetry ethics), sections 14 (shipping) and 15 (equipping).
- scripts/behavioral-test.sh: now a multi-scenario parallel runner (TDD 2A, perf 5C, crafting 10E, shipping 14B, equipping 15A) with per-scenario PASS/FAIL and exit 1 on any regression; the automated self-test half of the improvement loop. Proposal and merge stay gated per evolving-skills; capture, proposal, gating, and PR remain the automated parts, the human merge stays the boundary.

## [2.9.0] - 2026-07-06

### Added

- enforcing-performance-budgets: cost is now a first-class budget axis in stack choice. Two measured axes (performance fit on your workload, total cost of ownership at realistic and 10x traffic); among stacks that meet the budgets the cheapest runs, free tier beating billable when the numbers hold; the estimate is committed beside the budgets. A stack named by anyone, the user included, enters the same race as a hypothesis, never a conclusion: numbers shown, winner recommended, built only after the decider sees the evidence. Two rationalization rows and a red flag added; description now routes cost questions. Justified by a contaminated baseline: RED runs quoted the machine-level zero-budget mandate from global CLAUDE.md rather than the skill, proving the rule lived outside the portable artifact (the same portability reasoning that created selling-the-vision in 2.2.0). GREEN 4/4 in a leak-proofed client-pays setting, each run citing the new text verbatim.
- crafting-experiences: Delivery bar. Default delivery is the web platform (visit a URL, zero install, every device); an offline-first, native, or CLI variant is proposed only when it genuinely serves the user better, tradeoffs shown, and built only after the user confirms. Headless parks any switch away from web delivery. Same justification: RED runs imported the confirmation rule from global CLAUDE.md ("surface decisions rather than automate around them"), not from the skill.
- tests/pressure-test-battery.md: 5D, 5E (stack cost race under customer-is-king and client-indifference pressure), 10E, 10F (delivery-mode gate under offline-need and premium-container pressure).

## [2.8.0] - 2026-07-06

### Added

- tests/pressure-test-battery.md: five regression scenarios (5C, 10C, 10D, 12A, 13A) locking in behavior verified green this session under maximum pressure. 5C: green budgets on one box cannot launder in-process state; the reviewer must name statelessness before approval. 10C: action count is a burden gate; the path is cut before shipping. 10D: a "customizable per user" contract is satisfied by automatic attunement from signals the product already has (locale, color scheme, reduced motion, device, usage), never by a 12-toggle settings tax. 12A: art direction starts by inferring principles from category-defining products, never cloning, never habit. 13A: a skill misfire becomes a queued, user-confirmed learning; never silence, never a live rewrite. Nine of nine baseline runs passed with the current skill text, so per the writing-skills Iron Law (no failing test, no edit) the skills themselves were deliberately left untouched.

### Security

- humanizing-output/install.sh --global now fails closed when a global core.hooksPath already points somewhere else. Repointing it would silently disable every hook living at the existing path (secret scanners included) for every repo on the machine; it now aborts and prints chain-or-unset instructions instead. Verified against a live machine with a custom hooksPath: clean abort, no mutation.

## [2.7.0] - 2026-06-21

### Added

- evolving-skills skill: a gated proposal loop so skills improve from real use without ever rewriting themselves. Capture is trusted-input only (a learning enters docs/dmj/skill-learnings/ only with confirmed-by: user; raw session text is never auto-applied, which closes the prompt-injection persistence vector). Each confirmed learning becomes a writing-skills TDD proposal, passes validate.js plus the behavioral-diff gate, and opens a PR a human merges; never auto-merge, never straight to main. landing-sessions triggers a proposal pass at session end when the queue is non-empty. Ships the threat model and the docs/dmj/skill-learnings queue with its format.

### Changed

- landing-sessions: added a skill-learnings capture and session-end proposal-pass step (dmj:evolving-skills), user-confirmed only.

### Security

- Hardened the release gate and humanizer after a fresh-context adversarial review (two rounds). release.sh: the behavioral-diff gate now fails closed when claude is absent, reads the exact first verdict line (no grep first-match bypass), runs on opus, labels the diff untrusted, and reviews all skill .md including reference files (not just SKILL.md). rename-check.js: RENAME_MAP is now an allowlist (real skill slugs and plugin tokens only; retired slugs via RENAME_ALLOW), so a semantic word-swap (required to optional, fail-closed to fail-open) can no longer ride the mechanical fast-path. validate.js: scans reference files for dashes and forbidden tokens, with a wider dash class (adds U+2010 and U+2011). Humanizer: the pre-push hook checks only the commits being pushed (no first-push full-scan brick), NUL-delimits filenames so a name with spaces cannot evade the gate, chains husky and any native pre-push without recursing, and logs HUMANIZE_SKIP bypasses; install --global adds a pre-commit chainer so core.hooksPath cannot silently disable a repo secret scanner, and per-repo install backs up an existing pre-push; humanize.mjs warns when a rewrite changes code, URLs, or numbers.

## [2.6.0] - 2026-06-21

### Added

- humanizing-output skill plus a portable pre-push gate for every project (not this plugin). humanize-guard.mjs blocks unicode dashes (always) and AI-tell phrases (gate mode) in prose files and commit messages, skipping fenced and inline code so command output is never flagged. humanize.mjs rewrites flagged prose to plain language via the claude CLI, shows a diff, and applies on approval. hooks/pre-push chains husky and lefthook, degrades to a dash-only grep check when Node is absent, and bypasses once with HUMANIZE_SKIP=1. install.sh wires it per-repo or sets a chained global core.hooksPath (with a warning, since that overrides per-repo hooks). Tunable per project via .humanize-allow. git calls use execFileSync with argument arrays, no shell. Mandated in global CLAUDE.md as an every-project artifact.

## [2.5.0] - 2026-06-21

### Changed

- Relaxed the skill word-count guardrail in validate.js: prose cap 500 to 1200, total 650 to 1800, meta-skill (using-dmj) 300 to 600. Substance is no longer trimmed just to hit a number; the cap now only catches true runaway bloat. README's terseness claim softened to match.
- art-directing: restored content previously trimmed to fit the old cap, including the "cap at 1200px and center" rationalization row and fuller wording in the rationalizations table.

## [2.4.0] - 2026-06-21

### Added

- art-directing/color-psychology.md: a one-level-deep reference giving Gate 0 a real, sourced method to derive palettes from audience emotion instead of cliché. Grounded in primary research: ecological valence theory (Palmer & Schloss, PNAS 2010, preference tracks liked-object associations, so positive palettes use positively-valenced referents), color-in-context theory (Elliot & Maier, meaning is context-dependent not universal), and cross-cultural variance (Madden et al. 2000). Method: state the emotional target, pick valenced referents not symbols, build in OKLCH, accessibility overrides vibe (WCAG AA, color-blind-safe, dark and light), verify contrast with the numbers shown. Includes an emotion-to-hue table framed as hypotheses to test (not laws) and honest confidence levels: the hue mappings are weak and contested, valence and legibility are the durable wins. SKILL.md Gate 0 now points to it.

## [2.3.0] - 2026-06-21

### Added

- art-directing: research-driven visual identity, the execution layer crafting-experiences explicitly parks. Gate 0 derives the palette from researched audience emotion (not cultural cliche or habit), contrast winning over vibe (WCAG AA, color-blind-safe, dark and light). Emits a named token system (palette, type, spacing, motion) not prose; bans the AI-default font stack (Inter / Space Grotesk / JetBrains Mono) and the dark-plus-neon default look; morphic language (skeuo, neu, glass, clay, flat, brutalist, aurora, bento) chosen per project, never locked. Fill-every-edge-yet-readable responsive: edge-to-edge chrome, text capped near 66 to 75ch, large and 4k screens filled by scaling and reflowing the same content (nothing hidden by viewport size, no element exists only at one breakpoint), never a centered column in whitespace. Screenshot-verify HARD gate: every breakpoint from mobile-portrait to 4k via Playwright plus a contrast check, self-asserted "looks responsive" rejected. Chains researching-deeply, enforcing-performance-budgets, dispatching-parallel-teams, crafting-experiences, and verification-before-completion so the design skills compose. Baseline-tested: fresh agents holding the existing design skills still converged on the default font trio, dark-plus-neon, cliche color, and centered-max-width 4k; this skill targets exactly those failures. Global CLAUDE.md de-mandated from forced skeuomorphic to research-chosen morphic language.

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
