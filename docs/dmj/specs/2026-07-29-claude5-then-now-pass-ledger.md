# Claude 5 "Then and Now" pass, disposition ledger

Companion to `2026-07-29-claude5-then-now-pass-design.md`. It covers every file tracked before the pass (74), the 8 global context files, and files the pass created. It records what changed, why a finding was rejected, or "clean" (no finding). Commit series: 9da9e8f design, 36dab18 design v2, 79ffac3 gates, bcfc669 guards, and 1669556 lint. Then edc5dde skills, d2494f8 dash cleanup, 23f4a5f routing, c963613 security dedup, 839b604 dedup, and e63cac2 rescues. The release commit carries this ledger. Globals: `~/.claude` git history eead1f8 (pre) -> 2047ae0 (post).

## Repo: modified (57)

| file | disposition |
|---|---|
| .claude-plugin/plugin.json | stale teams vocabulary replaced; keyword `agent-teams` -> `teammates` |
| .claude-plugin/marketplace.json | same description string, kept byte-identical to plugin.json |
| .github/workflows/validate.yml | humanize-guard gate step added (repo-wide prose) |
| CHANGELOG.md | Unreleased entries per commit; folded into 5.0.0 at release (major by user order) |
| README.md | teams vocabulary; word-cap line updated to one-home framing; version-hedge line honest about re-check pins |
| docs/dmj/skill-learnings/README.md | schema made real (frontmatter required, body a reference shape); RED method named |
| docs/dmj/skill-learnings/2026-07-29-teammate-numbers-unmeasured.md | frontmatter backfilled |
| docs/dmj/specs/2026-07-29-opus5-context-audit.md | section 8 marked historical; unicode dashes stripped |
| hooks/pre-tool-guard | bypass de-advertised (header only); node-engine-file-missing now DENIES; deny() hoisted |
| hooks/session-start | update check moved off the boot path (background subshell + notice file) |
| scripts/export-claude-ai.mjs | "agent-team tools" -> "delegation tools" |
| scripts/pre-commit-secrets.sh | all bypass advice replaced by per-line `gitleaks:allow`; no-engine branch offers install only |
| scripts/release.sh | dist export step added post-push; behavioral-diff gate KEPT permanently (user decision) |
| scripts/validate.js | judgement-era rewrite: prefix gate and subagent ban dropped, handoff regex widened, caps kept; added security-token presence, protection-line ratchet, guard parity tripwire |
| skills/art-directing/SKILL.md | attractor section folded into Gate 0 as a detection sentence |
| skills/brainstorming/SKILL.md | clause list -> pointer (eqg home); 2 definitional rationalization rows kept; headless = delta only |
| skills/crafting-experiences/SKILL.md | tables/flags cut after rescues (adapt-from-signals into Burden; deadline line kept) |
| skills/defending-in-depth/SKILL.md | session-and-auth floor + abuse classes ADDED (checklist rescues); crypto-lane claims made honest; two agility flags merged; per-surface structure otherwise upheld |
| skills/dispatching-parallel-teams/SKILL.md | when-to-fan-out sentence split readable; flags cut to the 3 naming symptoms |
| skills/dispatching-parallel-teams/team-mechanics.md | sizing kept docs-sourced; rationale routed to writing-plans; verified current against live docs |
| skills/enforcing-performance-budgets/SKILL.md | stack-choice duplicate row and flag cut |
| skills/enforcing-quality-gates/SKILL.md | four generated files named; clause list marked deliberate dual home |
| skills/enforcing-quality-gates/gate-matrix.md | lane-manifest filename corrected, multi-stack wording |
| skills/enforcing-quality-gates/install-gate.sh | per-stack lanes (clobber fixed), shared tool_present, missing-manifest detection, EARS scoping with exit 77 |
| skills/equipping-projects/SKILL.md | /init pointer; four gate files; tables/flags folded into the gate prose |
| skills/evolving-skills/SKILL.md | retirement evidence re-pointed to authoring-time probes recorded in commit + CHANGELOG |
| skills/executing-plans/SKILL.md | implementer contract -> pointer + wave delta; flags cut; PARK -> library default |
| skills/exploring-codebases/SKILL.md | description sharpened (map deliverable); native-explore line; gate absorbs rescued lines; 2 flags kept |
| skills/finishing-a-development-branch/SKILL.md | BASE capture fixed; drain-then-TaskStop teardown |
| skills/harnessing-claude/SKILL.md | auto-memory row; tier section de-literalized; flag self-defense trimmed |
| skills/humanizing-output/SKILL.md | dash set and commit-msg claims now point at code truthfully |
| skills/humanizing-output/hooks/pre-push | portable byte-check fallback (no GNU-only -P fail-open) |
| skills/humanizing-output/humanize-guard.mjs | AI_TELLS exported; import runs no scan; file remains sole lexicon home |
| skills/humanizing-output/humanize.mjs | NUL/SOH bytes escaped (file is text again); prompt built from the full lexicon; B4 tag dropped |
| skills/landing-sessions/SKILL.md | auto-memory curation; drain teardown; headless block removed (default binds) |
| skills/observing-production/SKILL.md | Edge floor ADDED (WAF cadence rescue); alert range -> principle; table + dup flag cut |
| skills/orchestrating-products/SKILL.md | unbacked 20-run floor -> no-number-without-a-producer principle |
| skills/receiving-code-review/SKILL.md | 6-step ritual -> one sentence; verify-first carries the law |
| skills/requesting-code-review/SKILL.md | panel count -> blast-radius principle |
| skills/requesting-code-review/review-lens.md | tier alias unquoted (judgement tier + pointer) |
| skills/researching-deeply/SKILL.md | flag section cut (all five restated stated rules) |
| skills/selling-the-vision/SKILL.md | table cut; deadline clause rescued into Tagline bar |
| skills/shipping-to-production/SKILL.md | duplicate rows/flags cut; pressure row and 2 symptom flags kept |
| skills/stewarding-data/SKILL.md | deletion-rights floor points at crypto-shredding |
| skills/systematic-debugging/SKILL.md | attempt arithmetic fixed at two consecutive failures, reason stated |
| skills/systematic-debugging/debugging-techniques.md | waitFor implementation -> spec |
| skills/systematic-debugging/find-polluter.sh | zero-match false all-clear fixed (git ls-files + exit 2) |
| skills/team-driven-development/SKILL.md | spawn mechanics -> pointer + role tiers; 3 dup flags cut |
| skills/team-driven-development/teammate-prompts.md | rebuilt as field-table contracts (status enum + too-hard bar kept) |
| skills/test-driven-development/SKILL.md | per-row excuse -> name covered/out-of-scope; 4 of 7 rows cut |
| skills/test-driven-development/testing-anti-patterns.md | 2 vignettes folded into the table; incomplete-mock kept |
| skills/tracing-codebases/SKILL.md | description sharpened (chat-only); native line; 4 of 5 flags cut; headless removed |
| skills/using-dmj/SKILL.md | delegation floor de-literalized; headless default with PARK enumeration now lives here |
| skills/using-git-worktrees/SKILL.md | EnterWorktree hedge dropped |
| skills/verification-before-completion/SKILL.md | table cut; guard sentence moved into Verified-stays-verified |
| skills/writing-plans/SKILL.md | committed-artifact specs allowed; placeholder rules extended; flags cut |
| skills/writing-skills/SKILL.md | Iron Law scoped by property; one-home test unified; library defaults deviation-only; description doctrine synced to lint |
| skills/writing-skills/best-practices.md | prefix rule relaxed to situation-naming; gauntlet language -> live constraint |
| skills/writing-skills/testing-skills-with-teams.md | bright-line doctrine scoped to irreversible/expensive; one-home REFACTOR; env gate -> pointer |

## Repo: created

| file | disposition |
|---|---|
| docs/dmj/specs/2026-07-29-claude5-then-now-pass-design.md | the approved design (v2, four lenses folded) |
| docs/dmj/specs/2026-07-29-claude5-then-now-pass-ledger.md | this file |
| scripts/protection-baseline.json | protection-line ratchet baseline (regenerate via `--update-baseline`) |

## Repo: clean or findings rejected (17)

| file | disposition |
|---|---|
| .claude/settings.json | clean (sweep) |
| .gitattributes | comment premise fixed by humanize.mjs becoming text; rule itself inviolate |
| .gitignore, LICENSE | clean |
| hooks/hooks.json | REJECTED making skill injection async (it is the hook's job); latency fixed in session-start instead |
| hooks/pre-tool-guard.js | unchanged by design: parity with the perl engine is now CI-enforced (validate.js) |
| hooks/run-hook.cmd, scripts/rename-check.js, scripts/validate.sh | clean (rename-check called out as the S6 target state) |
| skills/art-directing/color-psychology.md, skills/crafting-experiences/experience-psychology.md | clean, named the model aux files |
| skills/defending-in-depth/quantum-durable-crypto.md | version pins KEPT with their re-check hedges; README line updated to match. Reference-codec proposal REJECTED: shipping crypto construction code from a skills repo invites copy-paste into production without audit |
| skills/enforcing-quality-gates/fuzzing.md | clean (one sub-threshold nit, left) |
| skills/humanizing-output/install.sh | REJECTED restructure: interactive installer run by a human; the abort and one warning are load-bearing (MEMORY.md footgun), triple-statement tolerated |
| enforcing-performance-budgets, shipping-to-production, humanizing-output SKILL.md | fixed late (see modified rows) |

## Globals (~/.claude, git eead1f8 -> 2047ae0)

| file | disposition |
|---|---|
| CLAUDE.md | 16,751 -> 9,813 chars. Every imperative kept (30-probe grep green). Rationale and stack detail moved to skill/reference homes. DA ritual compressed to principle (user decision Q2) |
| RTK.md | shrunk to the hook note + meta commands + the /usr/bin/grep caveat; import kept (user decision Q3) |
| reference/stack-defaults.md | CREATED: naming, logging, env/secrets, frontend, database, CI lanes |
| reference/super-admin.md | CREATED: implementation numbers; points at the SESSION tier, carries no crypto parameters |
| reference/ship-checklist.md | rewritten as a gate map with pass criteria, 4 orphan gates, and presentation gates. Drifted-weaker crypto line deleted (skill superset). Never-skip-security kept verbatim. Skip profiles and pre-push table kept. Rescues homed in skills first (e63cac2) |
| reference/pitch-deck.md | CSS/JS blocks -> interface contract; counts -> intent; identity deferred to art-directing; byline and MEMORY.md pointers fixed; dashes stripped |
| reference/user-identity.md | byline "Claude (Anthropic)", never-pin note, shell line corrected; portfolio tables KEPT (on-demand file, cuts earn nothing) |
| reference/design-thinking.md | UNTOUCHED (on-demand; trims save zero session tokens; overlap tolerated as prompt content for brainstorming lenses) |
| reference/linkedin-posts.md | UNTOUCHED (same reasoning; templates stay as channel spec) |
| reference/deployment-blueprints.md | receives the GCP VM workflow and full Dockerfile hardening sentence |

## Late user directives (mid-release, applied before 5.0.0)

| change | home |
|---|---|
| Orchestrator law: main thread never labors. All substantive work runs in background agents with own contexts. Conclusions enter only the main thread. Delegation is the default, even for one task | using-dmj (law), dispatching-parallel-teams (mechanics), CLAUDE.md principle 6 (pointer) |
| Governance to dmjcustomizations; CLAUDE.md identity + laws only (second slim, 9,813 -> 5,917 chars) | CLAUDE.md + new skill homes: API schema -> equipping-projects (Endpoints row); container hardening + super-admin -> shipping-to-production artifact table |
| Version 5.0.0 instead of 2.25.0 | this release |
| Terse-doctrine batch: worktree ban in a 14-file sweep. using-git-worktrees became the no-worktree isolation policy. All-opus spawns retired the two-tier menu. The lexicon gained +25 terms. Floors cover AAA, baseline-device, and MLP. Other changes cover SIEM observability, deploy-is-not-release, API v2, DPDP residency, and perf/offline/arch shapes. CLAUDE.md uses a telegraphic register (6,136 chars) | crafting-experiences, observing-production, shipping-to-production, equipping-projects, defending-in-depth, humanize-guard.mjs, dispatching-parallel-teams, using-git-worktrees + 8 sweep files, stack-defaults.md, CLAUDE.md |
| TeamCreate/team_name in the user draft: dead mechanisms, translated to the orchestrator law, not adopted verbatim | using-dmj + dispatching-parallel-teams |

## Standing decisions recorded

- release.sh behavioral-diff gate: KEEP permanently (user, Q1).
- No tests in this repo, sub-second lint only, LF endings: inviolate, unchanged.
- selling-the-vision keeps its 8-word LinkedIn shape inline: REJECTED pointer-only (ships standalone to claude.ai).
- claude.ai connectors token cost (old audit 4.1): user-owned settings choice, out of scope.
- exploring/tracing merge: REJECTED (harness-enforced read-only frontmatter would be lost).
