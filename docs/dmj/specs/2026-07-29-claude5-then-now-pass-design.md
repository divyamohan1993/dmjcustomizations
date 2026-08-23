# Claude 5 "Then and Now" pass, design v2

Date: 2026-07-29. v1 reviewed by four fresh-context lenses (pre-mortem, YAGNI, ambiguity, security); v2 folds every blocker and major. Scope per user: repo + globals, full restructure, direct to main, re-litigate all. Inviolate: no tests in this repo, sub-second lint only, LF endings, user's global laws (existence; wording and placement auditable).

Sources: five sweep reports covering all tracked repo files (74 incl. this spec) plus 8 global files; four lens reports. Every claim below that carries a number was measured by a sweep or lens with the producing command.

## Reversals from v1 (lens-driven)

1. NO merge of exploring-codebases + tracing-codebases. The merge would drop tracing's `disallowed-tools: Write, Edit, NotebookEdit`, the library's only harness-enforced read-only guard, and CHANGELOG 2.19.0 already declined this merge for that reason. Instead, sharpen the two descriptions to disjoint triggers. Exploring means building a reusable repo map before changing code. Tracing means chat-only explanation with no artifacts. Add one line to each description stating what it adds over native explore. Description edits land as their own commit for bisectability.
2. CLAUDE.md slim rule is now: THE IMPERATIVE STAYS, ONLY RATIONALE AND DEPTH MOVE. Always-on enforcement never becomes opt-in. Target measured in chars, not lines: 16,749 to at most 10,000, with every imperative surviving (checklist below).
3. At-rest crypto profile and never-hand-roll move together or not at all; under rule 2 both stay as compressed mandate lines. The kept security lines must read as self-sufficient law in a plugin-less session.
4. TaskStop swap keeps the drain: SendMessage "finish current tool call, flush or commit, reply drained", await reply, TaskStop, only then remove the worktree.
5. Test rationalization-row cuts per row against writing-skills' own bar. A row that names a pressure no earlier bar covers STAYS. Deadline, authority, and sunk-cost rows are such pressures. Name each rescued sentence for each affected skill in the plan before editing. Use verified counts only. TDD keeps its 2 non-obvious rows plus pressure rows that pass the test.
6. validate.js: word caps NOT raised. Highest prose today is 927 of 1200. Nothing is near a cap and this pass only deletes. Handoff-line gate KEPT with a widened regex for any line-initial pointer or next-step form. Description cap stays hard at 500. Eighteen of 32 exceed 200 today. A warn on 56% is noise. "Use when" prefix gate deleted with no machine replacement. writing-skills SKILL.md:28 and best-practices.md:89 updated in the same commit so lint and doctrine agree. "subagent" word ban deleted. ADDED checks are all sub-second. They include security-token presence in defending-in-depth: AEGIS-256, ML-KEM-1024, ML-DSA-87, SLH-DSA, Argon2id, per-record DEK, per-tenant KEK, Hash-chained, Egress allowlist, and Hybrid. They include per-skill protection-line count: Iron Law, MUST, NEVER, and threshold lines. The count fails when it drops without a CHANGELOG "Removed" entry. They include perl/JS guard pattern parity: parse both, compare, and fail on drift.
7. NO codegen for the guard engines. Both stay hand-written. The validate.js parity check makes drift CI-fatal. hooks/pre-tool-guard prints to stderr and DENIES when its pattern source is missing or empty. It does not fail open.
8. pre-commit-secrets.sh: advice becomes `gitleaks:allow` pragma ONLY, at the 4 real advice sites (L102, L164, L245, L260). The no-engine fail-closed branch (L258-261) offers NO bypass, only install guidance. `DMJ_ALLOW` appears nowhere outside pre-tool-guard's header comment. (v1's DMJ_ALLOW advice would have advertised a broader bypass than the one removed; it also does not even bypass git hooks alone.)
9. release.sh behavioral-diff gate STAYS LIVE through this entire pass; it is the only automated semantic law-deletion detector and the security commit needs it. Parked decision is now keep-permanently vs strip-after-pass (if stripped later, the four live references in evolving-skills and skill-learnings/README get updated in that same commit).
10. Globals get version control BEFORE any W1 edit: `git init` in `C:\Users\DIVYA\.claude` scoped via a .gitignore allowlist to CLAUDE.md, RTK.md, reference/ (or, if the user objects, a timestamped full copy). First commit = pre-pass snapshot. Every W1 edit is then diffable and revertable.
11. EARS lane: requirement markers (`## Requirements` block or `REQ-` lines) scope the check. A spec path with NO markers makes the lane report UNAVAILABLE, never PASS.
12. Acceptance greps: this environment's rtk hook rewrote `grep -rln "opus\[1m\]"` to return 0 rows on a tree with 10 matches. Run all acceptance greps via `/usr/bin/grep`, or `grep -F` for bracketed literals, inside `bash -c`. Precede each 0-row criterion with a positive control against a known-present string.
13. CUT from v1 (YAGNI): pitch-template.html; the third mock-over-prose home in crafting-experiences; word-cap raises; the 200-char warn re-alignment; the blanket description review; actions/checkout bump; install-time codegen; restructuring trims to design-thinking.md, linkedin-posts.md templates, and user-identity tables (on-demand files, zero session-token gain; only stale-string fixes remain there).

## Workstreams (v2)

### W1: Globals (out-of-repo manual step, recorded in CHANGELOG; git snapshot first per reversal 10)

CLAUDE.md, full section disposition (imperative stays, rationale moves):

| section | disposition |
|---|---|
| User Identity | keep verbatim (8 lines) |
| Devil's Advocate | parked Q2. Compress to a 3-line principle. It must interrogate approach, necessity, assumptions, tradeoffs, timing, and impact. It must name the worst realistic failure. The alternative is to keep it verbatim |
| Reality Standard | keep, compressed to its 4 imperatives (real everything; complete or don't ship; practical use case; Jobs test), rationale prose cut |
| Writing Style | keep verbatim |
| Core Principles 1-5, 7 | keep verbatim |
| Core Principle 6 | 3 lines: parallel by default, two floating tiers, never fire-and-forget, contract at dmj:dispatching-parallel-teams |
| Design and Product Philosophy | identity line + Jobs-principles line + pointers (dmj:crafting-experiences, dmj:art-directing, dmj:selling-the-vision, pitch/ship/linkedin reference files) |
| Complexity | imperative line kept (target O(1), never O(n^2) unjustified), pointer for method |
| Security | ALL eight mandate bullets stay as compressed imperative lines. Hybrid never pure. The at-rest profile keeps AEGIS-256, ML-KEM-1024, ML-DSA-87, SLH-DSA-SHA2-256s, and HKDF-SHA-512. It stays with never-hand-roll and audited-beats-unaudited. Argon2id stays. Per-record DEK and per-tenant KEK stay. Agility stays. Field-level PII and no credentials in logs stay. Hash-chained audit off-host stays. Egress allowlist stays. Rationale (SIKE story, harvest-now, Grover math, nonce aside) moves to dmj:defending-in-depth, where it already exists verbatim |
| Performance | imperative budgets line kept (p95 200ms, LCP 2.5s, 200KB gzip), cache-first line kept, method pointer |
| Accessibility | imperative kept (WCAG 2.2 AA a right; captions; no color-only), depth pointer |
| APIs | keep verbatim (2 lines, no skill home) |
| Changelog | keep 1 line |
| Naming, Logging, Environment, Frontend, Database | stack defaults move to NEW `~/.claude/reference/stack-defaults.md` with one always-loaded trigger line ("Stack defaults (Next/Drizzle/pino/zod env/naming): read reference/stack-defaults.md before scaffolding or picking libraries"). The secrets-encrypted-at-rest sentence is explicitly on the migration list, it may not fall between files |
| Super Admin | requirement line + quantum-safe + brute-force + audit-logged imperatives stay; implementation numbers move to NEW `~/.claude/reference/super-admin.md`, which names NO crypto parameters, it points at defending-in-depth's SESSION tier (no fifth crypto home) |
| Package Manager, Dependency Management | keep, compressed to imperatives (pnpm only; latest stable; audit fails critical/high; SBOM; SRI; lockfile CI; no GPL) |
| Deployment Architecture | Keep the one-target rule and paid-confirmation law verbatim. Keep the zero-budget context line. Keep DNS-manual with the two record forms. Keep Dockerfile hardening: multi-stage, non-root, read-only fs, and no secrets in layers. Keep the autoconfig one-liner. The deploy/ line becomes "deploy/ manifests on demand via reference/deployment-blueprints.md when revenue justifies". This aligns with the file's K8s-when-revenue law. Keep the humanizer-gate line and pointer. Keep the Cloudflare-at-every-tier line. Move GCP VM workflow and autoconfig essentials detail to dmj:shipping-to-production/deployment-blueprints.md. Verify the receiving file carries each dropped imperative before cutting |
| Scaling Philosophy | 1 line + blueprints pointer |
| RTK import | parked Q3 |

Pointer template is used everywhere. Globals use the `dmj:name` form because the plugin is the target. Use one sentence naming the rule's subject and its home. Carry no parameters, thresholds, or steps. Example: "Crypto parameter sets and rotation contract: dmj:defending-in-depth."

ship-checklist.md rewrite, all 17 gates dispositioned (executor verifies gate numbering against the live file before editing; the class decisions are fixed here):

| gate | disposition |
|---|---|
| G1 idea/design | pointer row -> dmj:brainstorming, keeps its one-line pass criterion |
| G2 security | Pointer row -> dmj:defending-in-depth after rescues. Add an auth/session row: refresh rotation, session invalidation on password change, MFA on admin endpoints, and failed-auth alerting. Add abuse-case classes: quota gaming, unintended use, and social engineering. Delete the drifted-weaker crypto line because the superset lives in the skill. The "Never skip security" sentence survives verbatim in the rewritten file |
| G3 env/config | pointer -> dmj:equipping-projects + dmj:shipping-to-production |
| G4 API contract | ORPHAN, kept whole (error schema + resilience: circuit breakers, retry with jitter, idempotent mutations, fail-fast) |
| G5 data | pointer -> dmj:stewarding-data |
| G6 quality | pointer -> dmj:enforcing-quality-gates |
| G7 a11y | pointer -> dmj:crafting-experiences |
| G8 UX/template test | pointer -> dmj:crafting-experiences + dmj:art-directing |
| G9 performance | pointer -> dmj:enforcing-performance-budgets |
| G10 mobile/India | ORPHAN, kept whole |
| G11 deploy | pointer -> dmj:shipping-to-production, plus the super-admin verification row KEPT here (only pre-ship check of that mandate) |
| G12 supply chain | pointer -> dmj:equipping-projects + gate-matrix |
| G13 docs | ORPHAN, kept whole |
| G14 SEO/social | ORPHAN, kept whole |
| G15 pitch deck | kept with its measurables (50KB, 7:1, keyboard, reduced-motion, no-JS) since its home is a reference file, not a skill |
| G16 linkedin | kept, same reason |
| G17 observability | pointer -> dmj:observing-production AFTER rescue: WAF-log review line added to observing-production |
| skip-profiles + quick pre-push table | KEPT, renumbered to match; "Never skip security" and per-profile floors survive verbatim |

Every pointer row keeps a one-line pass criterion so the checklist stays a checklist. Acceptance: every checkbox line of the pre-rewrite file maps in the ledger to "kept" or a named surviving home.

pitch-deck.md: Replace the CSS/JS block (110 lines) with an interface contract. The contract covers required regions, keyboard contract, hash routing, and budgets. Demote per-slide counts from MUST to guidance. Keep "scannable in 10 seconds" as the bar. Keep the Kawasaki 10-slide structure. Fix the stale "Claude Opus" byline on slide 8 to "Claude (Anthropic)". Fix the MEMORY.md dead pointer to the auto-memory path. Target: under 250 lines. No template file is created.

Stale-string fixes only (no restructure): user-identity.md byline + shell line; RTK.md circular pointer fixed per parked Q3; design-thinking.md and linkedin-posts.md untouched except design-thinking gains nothing and loses nothing (YAGNI: on-demand files, cuts earn nothing).

deployment-blueprints.md: receives the GCP VM workflow + autoconfig essentials imperatives from CLAUDE.md and the Dockerfile hardening sentence (both greppable there afterward). Otherwise untouched.

### W2: Single home dedup (repo)

Binding rule: L-"no law deleted" binds W2 only. W3 deletes deliberately with CHANGELOG Removed entries. Dedup in security files is PER SURFACE, not per file. Body mandate, rationalization row, red flag, and floors-table row are distinct trigger surfaces. One instance per surface stays. Before deleting any "echo", name its exact line. If a sweep count does not reproduce, the row shrinks to what is real. Measured: Argon2id 3x, not 4x. Agility 1x literal.

| rule | surviving home | others |
|---|---|---|
| spawn contract | dispatching-parallel-teams | pointer sentence |
| tier menu literal `opus[1m]`/`sonnet[1m]` | dispatching-parallel-teams/SKILL.md + CLAUDE.md rule 6 | role assignments say "judgement tier"/"mechanical tier"; the two meta-rules that quote the aliases (best-practices.md:85, harnessing-claude:45) refer to "the tier aliases named in dmj:dispatching-parallel-teams" without quoting |
| trivial threshold clause list | CLAUDE.md (user law) + enforcing-quality-gates inline IN FULL (ships standalone to claude.ai where CLAUDE.md does not exist; deliberate dual home, documented) | brainstorming points at enforcing-quality-gates, keeps its judge-against-clauses sentence |
| headless default | using-dmj carries the default, INCLUDING the four-item PARK enumeration. The items are irreversible, security, cost, and public surface. Delete `**Headless:**` blocks only from skills whose block restates the default. Keep them in art-directing, crafting-experiences, selling-the-vision, humanizing-output, and test-driven-development because they contain real deviations |
| fresh-context review mechanics | requesting-code-review | one line + pointer |
| qgate thresholds | generated qgate.config.sh | SKILL keeps policy shape; gate-matrix annotates |
| crypto content | defending-in-depth + quantum-durable-crypto.md | stewarding-data points; CLAUDE.md keeps mandate lines per W1 |
| teams mechanics | team-mechanics.md (verified current vs live docs) | pointers |
| implementer contract | team-driven-development | executing-plans points |
| AI-tell lexicon | humanize-guard.mjs `AI_TELLS` exported; humanize.mjs imports (install.sh already co-locates both files in targets) | SKILL.md points |
| worktree teardown | finishing-a-development-branch | landing-sessions points |
| CHANGELOG law | CLAUDE.md one line | skills point |

### W3: Judgement over rules (repo; every deletion CHANGELOG'd under Removed)

- Rationalization/red-flag trims per reversal 5's row test. receiving-code-review 6-step ritual dropped, verify-before-implement stays. observing-production alert range dropped for the principle; requesting-code-review default-count dropped, lens table stays.
- systematic-debugging: number KEPT. Off-by-one fixed: "two consecutive failed fixes at the same root cause: stop, question the hypothesis space, escalate." Red flag aligned to the same number.
- writing-skills: dead gauntlet references (3 sites) replaced with the live constraint. Descriptions are the always-loaded routing surface. Edit deliberately, one description change per commit. Iron Law scope narrowed BY PROPERTY. Any change to a floor, gate, threshold, Iron Law, or description needs an authoring-time fresh-context probe recorded in the commit message and CHANGELOG. This excludes "discipline skills" by category and PRs this repo does not produce. Headless-section mandate becomes "state deviations from the using-dmj default". Bright-line doctrine re-scoped to irreversible/expensive classes. Anti-sycophancy clause kept.
- evolving-skills: retirement evidence = authoring-time probe recorded in commit message + CHANGELOG.
- orchestrating-products: unbacked "20 logged runs at 95%" replaced by the demotion principle.
- validate.js per reversal 6, single commit, first in the W3 sequence so lint agrees with everything after.

### W4: Correctness (repo)

1. install-gate.sh clobber: per-stack lane variables (`L_UNIT_node`, `L_UNIT_shell`, ...); `.qgate-lanes.sh` emits every populated variable; qgate.sh runs one lane call per stack per slot so each keeps its own tool_present verdict. (Not `&&`-concatenation: tool_present probes only word one, which would convert missing-tool into code-broken.)
2. Four generated files named in both prose homes; qgate.sh detects missing `.qgate-lanes.sh`, prints regenerate hint.
3. Shared tool_present() between install report and runner.
4. find-polluter.sh: git ls-files with find fallback; zero matches exits non-zero.
5. finishing-a-development-branch BASE: `git show-ref` form.
6. humanize.mjs NUL/SOH to `'\0'`/`'\x01'`; B4 tag dropped; lexicon via W2 export.
7. pre-push portable dash check that blocks without GNU grep.
8. pre-commit-secrets per reversal 8.
9. pre-tool-guard: bypass de-advertised (header only) + deny-on-missing-patterns per reversal 7.
10. Guard parity check in validate.js per reversal 7.
11. session-start: skill injection stays sync; version curl moves to background, stamp read next boot.
12. EARS per reversal 11.
13. CI: humanize-guard step added to validate.yml (README, docs, CHANGELOG covered). No checkout bump.
14. gate-matrix.md:3 corrected to `.qgate-lanes.sh` multi-stack wording (line 119 already correct).
15. skill-learnings: frontmatter KEPT for machine-locatable `confirmed-by` and `status`. The injection filter stays machine-readable. Body sections become a reference shape. The one instance gets frontmatter backfilled. "TDD proposal" is renamed to the RED method name writing-skills uses post-W3.
16. Audit spec §8 (and §9 if it references deleted files): prepend "Historical: instructs re-running files deleted in 2.23.0."
17. shutdown_request: the 2 call sites (finishing-a-development-branch:56, landing-sessions:14) get the drain protocol per reversal 4; team-mechanics:50 prose updated to match.

### W5: Harness alignment (repo)

- landing-sessions + harnessing-claude auto-memory rewrite (curation and deliberate decision-capture stay; hand-index maintenance goes).
- equipping-projects points at native /init, keeps rules-splitting.
- using-git-worktrees drops the EnterWorktree hedge.
- exploring/tracing description sharpening per reversal 1 (own commit).
- Stale strings, exact sites, and replacements: plugin.json:3 and marketplace.json:11 description becomes "Battle-tested, parallel-first agentic engineering skills: teammate fan-out workflows, adversarial verification, quality gates, quantum-durable security defaults." plugin.json:14 keyword `agent-teams` becomes `teammates`. README.md:7/:9 "agent teams" becomes "teammate fan-out". export-claude-ai.mjs:64 "agent-team tools" becomes "delegation tools".
- writing-plans: committed failing test / fixture / mock allowed as step spec; prose carries decision + criteria; inline code when no artifact exists.
- crafting-experiences Artifact rule: cut no third mock sentence. Instead, add "a mock beats a paragraph: dmj:art-directing" at L33 only if the executor finds L33 contradicts art-directing. Otherwise leave L33 untouched.
- release.sh gains a dist-export step (`node scripts/export-claude-ai.mjs`) so rebuilds are release-mechanical; dist/ stays untracked; user's claude.ai upload recorded as a user action in CHANGELOG.

## Sequencing and commit series

All repo commits plain `git commit` on main, conventional messages; release.sh invoked once at the end.

1. `fix(gates)`: W4 items 1-5, 11-14 (mechanical correctness).
2. `fix(guards)`: W4 items 6-10, 15-17 (guard integrity; release.sh gate live).
3. `feat(lint)`: validate.js rewrite (reversal 6) + writing-skills:28/best-practices:89 sync.
4. `refactor(skills)`: W3 judgement rewrites + W5 harness alignment except descriptions.
5. `refactor(routing)`: exploring/tracing + any other description edits, isolated for bisect.
6. `refactor(security)`: W2 security-file dedup (defending-in-depth, quantum, stewarding-data), per-surface rule, token-presence check green, behavioral-diff gate green.
7. `refactor(dedup)`: remaining W2.
8. W1 globals: out-of-repo, git-snapshot first, recorded in CHANGELOG of this repo as a documented external step.
9. `chore(release)`: CHANGELOG [Unreleased] folds into [2.25.0], release.sh 2.25.0 (manifests bumped, dist exported, gate runs). Minor bump; no skill slug disappears in v2 so no `!`.

## Acceptance criteria (v2; all greps via /usr/bin/grep in bash, each 0-row check preceded by a positive control)

1. Positive control example: `/usr/bin/grep -rl "Iron Law" skills/ | wc -l` returns nonzero before any 0-row criterion is trusted.
2. `/usr/bin/grep -rn "gauntlet" skills/ scripts/ hooks/ README.md` = 0 rows.
3. `/usr/bin/grep -rn "shutdown_request" skills/` = 0 rows.
4. `/usr/bin/grep -rlF "opus[1m]" skills/` returns exactly: dispatching-parallel-teams/SKILL.md, writing-skills/best-practices.md, harnessing-claude/SKILL.md (the home + the two meta-rules); no role-to-tier assignment outside the home (manual read of those three).
5. `/usr/bin/grep -rn "team-based workflows" .claude-plugin README.md scripts/` = 0 rows; `/usr/bin/grep -n "agent-team" scripts/export-claude-ai.mjs` = 0 rows.
6. `grep -cI . skills/humanizing-output/humanize.mjs` exits 0 (file is text).
7. `bash scripts/validate.sh` exits 0, wall clock under 1s for the validate.js portion; local `claude plugin validate .` run once and green (user machine has the CLI).
8. install-gate.sh run against a scratch node+shell fixture under the session scratchpad (never committed): resulting `.qgate-lanes.sh` contains both `L_UNIT_node` and `L_UNIT_shell` lines; the file's content is pasted into the CHANGELOG entry as evidence.
9. find-polluter.sh with a zero-match pattern exits non-zero.
10. validate.yml contains a humanize-guard step.
11. validate.js token-presence check green (the ten security tokens in defending-in-depth).
12. validate.js guard-parity check green (perl and JS pattern lists equal).
13. CLAUDE.md at most 10,000 chars (`wc -c`). The imperative checklist must stay grep-positive in the new file. It covers paid-confirmation, one-target, DNS-manual, hybrid-never-pure, AEGIS-256, ML-KEM-1024, and Argon2id. It covers per-record DEK, never-hand-roll, egress allowlist, hash-chained, pnpm, and no em dashes rule. It covers the trivial clause list, principles 1-7 headers, CHANGELOG, SBOM, no GPL, and Reality Standard imperatives. It covers the super-admin requirement, Dockerfile non-root, autoconfig, WCAG 2.2 AA, and p95 200ms. This checklist is a spot list backed by the ledger. The ledger is the exhaustive check.
14. Ledger file `docs/dmj/specs/2026-07-29-claude5-then-now-pass-ledger.md` exists. Its schema is `file | disposition | rationale`. It covers every pre-pass tracked file (74), the 8 globals, and files created by the pass. Every imperative line of pre-slim CLAUDE.md and pre-rewrite ship-checklist maps to "kept" or a named surviving home.
15. Same dead-string greps (2, 3, 5) run over `dist/` after export = 0 rows.
16. humanize-guard.mjs green over all changed prose.

## Assumption ledger

- Floating aliases valid harness inputs (confirmed live).
- Auto-memory active (observed).
- Plugin installed globally on the single machine in use; slimmed CLAUDE.md's security lines are nonetheless written self-sufficient (reversal 3).
- team-mechanics.md verified current against live agent-teams docs this session.
- rtk hook may rewrite bare grep; acceptance pins /usr/bin/grep (reversal 12).
- claude.ai connectors token cost (audit §4.1, unapplied): user-owned settings choice, out of scope for this pass, noted here as the disposition.

## Parked for user at approval

- Q1 release.sh behavioral-diff gate: keep permanently, or strip AFTER this pass completes. The gate runs during the pass either way. Stripping later also updates its four live references.
- Q2 Devil's Advocate + worst-case ritual in CLAUDE.md: compress to 3-line principle, or keep the 15-line ritual verbatim.
- Q3 RTK.md: shrink to a 6-line note while keeping the import. Keep the hook active, commands rewritten, and meta commands. Or drop the import. Risk: sessions become confused by rewritten Bash output.
- Q4 approve design v2 for execution as specified.
