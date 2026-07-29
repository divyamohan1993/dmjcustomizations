# Claude 5 "Then and Now" pass, design

Date: 2026-07-29. Scope approved by user: repo + global ~/.claude files, full restructure, direct to main, re-litigate all prior audit decisions. Inviolate throughout: no tests in this repo, sub-second lint only, LF endings, user's global laws (existence; wording and placement are auditable).

Source: five fresh-context sweep reports over all 73 tracked repo files plus 8 global files, audited against the six "then and now" shifts: S1 rules to judgement, S2 examples to interfaces, S3 progressive disclosure, S4 single home, S5 auto-memory, S6 rich references.

## Why

The library was written across model generations. Sweeps measured the drift: the spawn contract is stated in 13 files, the model-tier menu in 10, headless boilerplate in 26, the trivial-change threshold in 3, the crypto profile in 4 homes with one drifted weaker. The global CLAUDE.md burns ~4.6K tokens on every conversation; ~2.6K of that is prose that repo skills already own. Six verified correctness bugs sit in the tooling, including one where the quality gate silently skips a whole language's test suite.

## Workstreams

### W1: Global context slim (outside repo, edited in place)

- CLAUDE.md 152 lines to ~60: every mandate kept, verbatim where it is law (paid-confirmation, writing style, pnpm, security bullets' 4 mandate lines, trivial threshold, core principles). Inlined content that a skill owns becomes a named pointer; today CLAUDE.md never names shipping-to-production, observing-production, stewarding-data, selling-the-vision, or equipping-projects while restating their content. Sections reduced to pointer + kept laws: Deployment (3 lines: one target, paid-confirmation verbatim, DNS manual), Security (4 mandate lines + pointer, the SIKE/Grover rationale lives in defending-in-depth), Performance/Complexity/A11y/CI-CD/Logging/Observability/Database (one line + pointer each; perf numbers' single home becomes the skill, which already carries the fuller set with INP/CLS), Design Philosophy (identity line + 3 pointers), Core Principle 6 (2 lines: parallel by default, two tiers, never fire-and-forget, contract in dmj:dispatching-parallel-teams).
- Frontend/Naming/Environment stack defaults move to `~/.claude/reference/stack-defaults.md`, pointer stays.
- Super Admin: requirement line stays in CLAUDE.md, implementation numbers move to `~/.claude/reference/super-admin.md`.
- ship-checklist.md: 13 of 17 gates have strict-superset skill homes; rewrite as 4 orphan gates (API error schema, mobile/India readiness, docs, SEO/social) + a gate-to-skill pointer table. Fixes the drifted-weaker crypto gate by deletion, not sync.
- design-thinking.md: trim to the sections nothing owns (cross-pollination, biomimicry, negative space, constraint-as-fuel, gut-check table, plus 3/7/10); owned sections become pointers.
- pitch-deck.md: replace 110 lines of copy-paste CSS/JS with an interface contract (required regions, keyboard, hash routing, budgets) + one `pitch-template.html` the agent adapts; hard sub-counts become the stated intent (scannable in 10 seconds). Kawasaki 10-slide structure stays.
- linkedin-posts.md: keep bars and good/bad hooks, cut the four fill-in templates.
- user-identity.md: "Claude (Opus)" byline to "Claude (Anthropic)", shell line corrected, coursework tables dropped, flagship rows stay.
- Dead pointers fixed: RTK.md's circular "refer to CLAUDE.md", pitch-deck's repo-root MEMORY.md.

### W2: Single home dedup (repo)

Each rule gets one owner; other files point or stay silent. No law is deleted anywhere in this workstream, only relocated.

| rule | surviving home |
|---|---|
| spawn contract (one message, named, background, steering) | dispatching-parallel-teams |
| model-tier menu (`opus[1m]`/`sonnet[1m]`) | CLAUDE.md rule 6 + dispatching-parallel-teams; role-specific assignments say "judgement tier"/"mechanical tier" |
| trivial-change clause list | CLAUDE.md; brainstorming and enforcing-quality-gates keep only their skill-specific mapping + pointer |
| headless default (autonomous, log assumptions, PARK user-owned calls) | using-dmj states it once; skills keep only deviations (art-directing, crafting-experiences, selling-the-vision, humanizing-output, TDD ledger) |
| fresh-context adversarial review mechanics | requesting-code-review; others one line + pointer |
| qgate thresholds | generated qgate.config.sh; SKILL keeps policy shape, gate-matrix annotates |
| crypto profile, DEK/KEK, agility, audit chain | defending-in-depth (+ quantum-durable-crypto.md for depth); stewarding-data and CLAUDE.md point; intra-file echoes in defending-in-depth cut (Argon2id x4, agility x5) |
| teams env gate + mechanics | team-mechanics.md (verified current against live docs; sizing numbers docs-sourced, KEEP) |
| implementer contract | team-driven-development; executing-plans points |
| AI-tell lexicon | humanize-guard.mjs `AI_TELLS` exported; humanize.mjs imports it; SKILL.md points |
| worktree teardown | finishing-a-development-branch; landing-sessions points |
| CHANGELOG-same-commit | CLAUDE.md one line; skills point |

### W3: Rules to judgement (repo)

- Rationalization tables: keep only rows carrying content no bar above states (TDD keeps 2 of 7, brainstorming keeps the 2 definitional approval rows, verification trims duplicate rows, crafting-experiences/art-directing/selling-the-vision/researching-deeply/equipping-projects cut theirs after rescuing the one novel sentence each). Red-flag sections keep only symptoms not restating body rows.
- Forced counts become principles: "3 to 5 symptom alerts" drops the range, "default panel is four" drops the count, systematic-debugging's 3-attempt arithmetic (self-contradictory at n=2) becomes the escalate principle, TDD's per-row written excuse becomes "name rows covered and rows out of scope".
- writing-skills: dead routing-gauntlet references (3 sites) replaced with the live constraint (descriptions are the always-loaded routing surface, edit deliberately); "every edit needs a failing test" narrowed to behavior-changing edits of discipline skills, matching its own line 58 and 2.23.0 reality; the mandatory per-skill headless/parallel section becomes "state deviations from the using-dmj default"; bright-line doctrine re-scoped to irreversible/expensive classes, anti-sycophancy clause kept.
- evolving-skills: retirement evidence bar re-pointed from deleted batteries to authoring-time fresh-context probes recorded in the PR.
- orchestrating-products: unbacked "20 logged runs at 95%" number replaced by the demotion principle (no fake threshold without a producer).
- receiving-code-review: 6-step ritual block dropped, verify-before-implement principle stays.
- validate.js rewrite: drop the handoff-line gate (100% compelled compliance), drop the "Use when" literal-prefix gate (description must name the triggering situation instead), drop the "subagent" word ban (now harness vocabulary), align the dead 500-char cap to the real 200 target as warn-only, raise word caps to runaway-guard-only (using-dmj 900, others 2500, still sub-second).

### W4: Correctness and gate integrity (repo)

All verified by reproduction in the sweeps:

1. install-gate.sh stack clobber: last matched stack overwrites earlier lanes; a node+shell repo (every project per CLAUDE.md ships autoconfig.sh) never runs its TS suite at T2. Fix: accumulate lanes per stack.
2. install-gate.sh writes 4 files, both prose homes say 3; missing `.qgate-lanes.sh` dies as `unbound variable` masquerading as a red gate. Fix: name 4 files, detect missing manifest, print regenerate hint.
3. install report and runner use different tool probes (report says WIRED, runner says UNAVAILABLE). Fix: one shared `tool_present()`.
4. find-polluter.sh false all-clear on the documented invocation (find pattern never matches, wc -l on empty = 1). Fix: git ls-files with fallback, non-zero exit on zero matches.
5. finishing-a-development-branch BASE one-liner captures two lines. Fix: `git show-ref` form.
6. humanize.mjs raw NUL/SOH bytes make the file binary to every grep. Fix: `'\0'`/`'\x01'` escapes. Also: rewriter prompt names 17 tells while the guard blocks 54; fix via the W2 lexicon export. Orphaned "B4" tag dropped.
7. humanizing-output pre-push fails open off GNU grep (`grep -qP` errors, gate greenlights). Fix: portable byte-sequence fallback that blocks.
8. Gate contradiction: pre-commit-secrets.sh advises `git commit --no-verify` in 5 places; pre-tool-guard hard-denies that exact command. Fix: advice becomes `gitleaks:allow` pragma / `DMJ_ALLOW=1` path.
9. pre-tool-guard advertises its own bypass in every denial. Fix: state block + fix; DMJ_ALLOW documented in header only.
10. Dual guard engines (perl + JS port) with no sync mechanism since suites were stripped. Fix: generate the perl pattern list from the JS constants at install time so divergence is impossible (structural, not a test).
11. hooks/session-start blocks boot up to 4s on a network call. Fix: inject synchronously, version-check in background, surface next boot.
12. EARS lane scoping: greps every shall/must line in prose specs, 3 false positives in this very repo. Fix: scope to `## Requirements` blocks or `REQ-` lines.
13. CI gap vs own exported law: add humanize-guard step to validate.yml (covers README/docs/CHANGELOG too), bump checkout to v5.
14. gate-matrix.md names the wrong output file; corrected with the multi-stack wording.
15. skill-learnings README mandates a schema its only instance ignores. Fix: schema simplified to match the real instance as reference; "TDD proposal" renamed to the pressure-run method.
16. Audit spec §8 marked historical (it instructs re-running deleted files).
17. shutdown_request/response (harness-labels it legacy) replaced by TaskStop-by-name + confirm-stopped-before-worktree-removal in finishing-a-development-branch, landing-sessions, team-mechanics.

### W5: Harness alignment (repo)

- landing-sessions and harnessing-claude rewritten for auto-memory: confirm capture, correct or delete wrong entries, keep deliberate decision-capture; drop hand-authoring protocol and index maintenance.
- equipping-projects points at native `/init` for CLAUDE.md seeding, keeps the rules-splitting guidance.
- using-git-worktrees drops the "if one exists" hedge on EnterWorktree.
- exploring-codebases + tracing-codebases merge into one skill (deliverable is a parameter: repo map vs chat explanation) that states what it adds over native explore (parallel lenses, refutation pass, anti-redundancy gate). Native-collision resolved.
- Stale "team-based workflows"/"agent-teams" strings replaced in plugin.json, marketplace.json, README.md, export-claude-ai.mjs.
- Descriptions across skills reviewed once against the new validate.js rules (no compelled prefix, situation-naming).
- dist/ rebuilt via export-claude-ai.mjs after all source edits (removes shipped stale battery/gauntlet text).
- crafting-experiences gains the mock-over-prose sentence mirroring art-directing (S6).
- writing-plans allows a committed failing test / fixture / mock as the step spec, prose carries decision + criteria; inline code only when no artifact exists yet.

## Sequencing

1. W4 correctness fixes (mechanical, verifiable, no law movement).
2. W5 harness alignment + W3 judgement rewrites, validate.js first so the lint agrees with the new shape.
3. W2 dedup, security files LAST: defending-in-depth/quantum/stewarding-data get their own commit + dedicated security review before merge of that commit.
4. W1 globals (outside git, edited in place; CLAUDE.md last, after repo pointers it targets exist).
5. Rebuild dist, run gates, CHANGELOG, version bump to 2.25.0, commit series.

Each workstream lands as its own commit (series on main per user's direct-to-main choice), conventional messages.

## Acceptance criteria (machine-checkable)

- `grep -rn "gauntlet" skills/ scripts/ hooks/` returns 0 rows.
- `grep -rn "shutdown_request" skills/` returns 0 rows.
- `grep -rln "opus\[1m\]" skills/` returns exactly 1 file (dispatching-parallel-teams).
- `grep -rn "team-based workflows\|agent-teams" .claude-plugin README.md scripts/` returns 0 rows.
- `grep -cI . skills/humanizing-output/humanize.mjs` succeeds (file classified text, not binary).
- `node scripts/validate.js` exits 0 over all skills post-edit; runtime under 1s.
- install-gate.sh on a synthetic node+shell fixture emits lanes for BOTH stacks (repro from sweep rerun green).
- find-polluter.sh with a zero-match pattern exits non-zero.
- validate.yml contains a humanize-guard step.
- CLAUDE.md at or under 70 lines AND a law checklist (paid-confirmation, one-target, DNS-manual, security 4 mandates, pnpm, no-em-dashes, trivial clause list, principles 1-7, changelog, Argon2id, per-record DEK) each findable by grep in the new file.
- Disposition ledger in this doc's companion covers all 73 repo + 8 global files.
- humanize-guard.mjs passes over all changed prose; no unicode dashes introduced.

## Assumption ledger

- Floating aliases (`opus[1m]`, `sonnet[1m]`) remain valid harness inputs. Confirmed live in this session's settings.
- Auto-memory is active for this user (MEMORY.md observed in session context), so S5 rewrites lose nothing.
- dmj plugin is installed globally via marketplace on every machine that loads the slimmed CLAUDE.md, so pointers resolve. Single-machine user today.
- team-mechanics.md content verified against live agent-teams docs this session; treated as current.
- claude.ai export consumers get the fix only after dist rebuild + user's export flow.
- No behavior change intended for any target-repo-facing generated artifact except the listed bug fixes.

## Parked for user at approval

1. release.sh behavioral-diff gate is model-in-the-loop at release time. Strip (matches 2.23.0 spirit, releases rely on authoring-time pressure + lint) or keep (last cross-file semantic check before publish). Recommendation: strip.
2. Devil's advocate + worst-case mandatory one-liners in CLAUDE.md: compress to a 3-line principle (interrogate approach, necessity, assumptions, tradeoffs, timing, impact; name the worst realistic failure) or keep the full 15-line ritual verbatim. Recommendation: compress; the six lenses survive as brainstorming's adversarial review.
3. RTK.md: shrink to a 6-line always-loaded note (hook active, commands rewritten, meta commands list) or drop the import entirely (risk: confusion when Bash output comes back rewritten). Recommendation: shrink, keep import.
4. deploy/ directory mandate (Compose + K8s + Terraform in every project): keep as-is or make on-demand via deployment-blueprints.md when revenue justifies. Recommendation: on-demand; contradicts the file's own timing principle today.
