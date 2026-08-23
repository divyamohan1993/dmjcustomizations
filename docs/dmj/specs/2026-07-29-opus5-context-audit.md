# Opus 5 context audit: what to change

Date: 2026-07-29. Source: Anthropic context-engineering guidance (Opus 5 / Fable 5) + "Finding your unknowns" field guide.
Status: **partially applied 2026-07-29**, on the user's explicit instruction.

| Item | State |
|---|---|
| §2.1 dead team mechanism | **Applied.** 0 `TeamCreate` / 0 `Agent Teams` left; `team_name` survives only where it is documented as deprecated. 31 skills validate, 13/13 guard probes, 9/9 behavioral scenarios. |
| §2.2 stale model label | **Applied.** Rule 6 rewritten; `opus[1m]` kept as the floating alias. |
| Hook latency (from `/doctor`, §9a) | **Applied.** `pre-tool-guard` 578ms -> 309ms; `rtk hook claude` given `timeout: 10`. |
| §3 `CLAUDE.md` cut | **Applied, and it under-shot the estimate.** 18,544 -> 14,270 chars (23%, ~1,068 tokens/session). §3 projected ~11,000. The per-section savings below were eyeballed, not measured, and were roughly 40% optimistic in aggregate. The cut list itself was carried out in full; the arithmetic attached to it was wrong. Devil's Advocate was kept whole per `/doctor`'s position on the §9a disagreement. |
| §4.1 claude.ai connectors | **Not applied.** User-only; neither Claude nor `/doctor` can reach them. |
| §2.3 / §2.4 conflicts | **Applied (2.18.0).** One conjunctive trivial-change threshold in CLAUDE.md, referenced by using-dmj, brainstorming, and the gate; `outputStyle: verbose` removed. |
| §5.2 / §5.3 / §5.4 | **Applied (2.19.0).** using-dmj rewritten without coercion (2,625 to 1,919 chars); 15 descriptions trimmed (8,829 to 7,307 chars); defending-in-depth and enforcing-quality-gates prose compressed, laws and tables intact. |
| §6 additions | **Applied (2.19.0)** minus two declines on record: blind-spot pass, interview mode, rich-reference specs, mock-react into brainstorming; Deviations log into executing-plans and team-driven-development. Declined: quiz-before-merge, pitch artifacts (user-side practices). Rubrics already exist as review-lens.md. |
| §10 trend rule | **Applied (2.19.0).** evolving-skills dated-laws bar: every added law names the behavior it compensates for. |

Backups: `~/.claude/CLAUDE.md.pre-cut-bak`, `~/.claude/settings.json.doctor-bak`.

---

## 1. The number

Context consumed before the user types a character:

| Source | Chars | Basis |
|---|---:|---|
| `~/.claude/CLAUDE.md` | 18,544 | measured |
| MCP tool names + server instruction blocks | ~12,700 | estimated from loaded listing |
| `dmj` skill descriptions (31) | 8,829 | measured |
| Built-in + plugin skill descriptions | ~7,200 | estimated from loaded listing |
| Agent-type listing | ~2,900 | estimated |
| `using-dmj` injected by SessionStart hook | 2,625 | measured |
| caveman SessionStart + UserPromptSubmit | ~1,590 | measured from injected text |
| `RTK.md` (via `@RTK.md`) | 993 | measured |
| `MEMORY.md` index | ~300 | measured |
| **Total** | **~55,700** | **~14,000 tokens** |

Anthropic deleted 80% of Claude Code's system prompt with no eval loss. The equivalent
cut here lands around 3K tokens. The cost is not only tokens: it is competing
instructions the model must reconcile before it does any work.

---

## 2. Blocking contradictions (fix before anything else)

### 2.1 Rule 6 mandates a tool that no longer exists

`CLAUDE.md` rule 6: *"Maximize parallelism via Agent Teams. NEVER use subagents. All
delegated work spawns teammates via `TeamCreate` + `Agent` (with `team_name`)... If a
skill instructs you to use `Agent` without `team_name`, the `Task` tool, or 'subagents',
rewrite that skill in place to use Agent Teams before following it."*

Verified this session:

- `ToolSearch "select:TeamCreate"` returns nothing. `TeamCreate` is absent from the tool
  list and from the deferred list.
- The `Agent` tool schema now reads: `team_name: "Deprecated; ignored. The session has a
  single implicit team."`
- `Agent` gained `name:` ("Makes it addressable via `SendMessage({to: name})` while
  running") and `SendMessage` resumes a named agent with its context intact.

Teams were folded into `Agent`. The rule forbids the only delegation tool that exists and
mandates one that does not, then instructs Claude to rewrite any skill that uses the
working mechanism. `TeamCreate` appears 20 times across 19 skill files; `team_name`
10 times. That is a large fraction of the library that cannot execute as written.

**Fix:** rewrite rule 6 to the current shape. Delegated work spawns named `Agent`s in one
message (parallel), teammates coordinate via `SendMessage` by name, never
fire-and-forget. Drop `TeamCreate` and `team_name` everywhere. Drop the "rewrite the skill
in place" clause: it turns a stale rule into cascading edits.

### 2.2 The library's own rule catches the user's own file

`skills/harnessing-claude/SKILL.md` red flag: *"A hardcoded model name in any instruction
file."*

`CLAUDE.md` rule 6: *"Always spawn agent-team members with the Opus 4.8 (1M context) model
(`model: "opus[1m]"`) with max thinking: never any other model."*

**Only the prose is stale: the selector is not.** `opus[1m]` is a floating alias, not a
pinned version: `settings.json` sets `"model": "opus[1m]"` and this session resolved to
`claude-opus-5[1m]`. So the selector already tracks the newest Opus, and
`CLAUDE_CODE_SUBAGENT_MODEL: "opus[1m]"` is correct as written. The violation is the
human-readable label **"Opus 4.8 (1M context)"**, one generation behind, sitting next to a
selector that is current. The `dmj` repo itself is clean of hardcoded models.

**Fix:** delete "Opus 4.8 (1M context)" from rule 6 and keep the intent plus the alias
("strongest available model via `opus[1m]`, max thinking"). Leave
`CLAUDE_CODE_SUBAGENT_MODEL` alone: it needs no change.

This is also the smallest item on the list: one phrase in one line. It reads worse than it
is because a stale model name next to a correct one is exactly what a reader scanning for
staleness will trust least.

### 2.3 Three incompatible gates on the same trivial task

| Source | Says |
|---|---|
| `CLAUDE.md` principle 4 | "Speed over process. Don't over-engineer simple tasks. If it's straightforward, just do it quickly." |
| `using-dmj` | "1% rule: any chance a skill applies, invoke it BEFORE responding, clarifying questions included. Not optional, not rationalizable." |
| `brainstorming` Iron Law | "NO merged implementation before an approved design... Every task, including ones that look too simple to need a design." |

For "add a log line" these three point three different directions. Opus 5 spends
reasoning reconciling them.

**Fix:** one rule with a stated threshold. Suggested: skills route by blast radius, not by
"any chance." Local + reversible + single-file goes straight to work. Anything crossing a
module, a data shape, a dependency, security, money, or a public surface gets the gate.
`brainstorming`'s ceremony tier table already encodes this; let it govern instead of the
Iron Law overriding it.

### 2.4 Output style fights the active hook

`settings.json`: `"outputStyle": "verbose"`. Caveman hook, every session and every prompt:
"Ultra-compressed... cuts token usage ~75%."

**Fix:** pick one. Caveman is the one actually running.

---

## 3. `CLAUDE.md` cut list

Article rule: *"spend most of the tokens on gotchas inside the codebase. Avoid stating the
obvious things Claude should know."*

### Cut entirely (Claude already does this)

| Section | Chars | Why |
|---|---:|---|
| Security: Posture, Transport, Injection, Monitoring | ~1,300 | OWASP defaults, TLS 1.3, HSTS, parameterized queries, explicit CORS. Claude does these unprompted. `dmj:defending-in-depth` covers the rest on demand. |
| Software Engineering: Code, Testing, Resilience, Docs, Git | ~900.<br> | SRP, YAGNI, DRY, KISS, test pyramid, circuit breakers, backoff+jitter, "document why not what", small commits. Baseline behavior. |
| Reality Standard historical examples | ~500 | Newton, Wave, Fire Phone, Kindle. Illustration, not instruction. |
| Scaling Philosophy tier list | ~300 | Already points at `deployment-blueprints.md`. Keep the pointer, drop the inline list. |
| Design Philosophy items 1-5 | ~600 | Duplicates `dmj:crafting-experiences` verbatim. |
| Frontend Experience prose | ~700 | Duplicates `dmj:art-directing`, which is more specific. |
| Dependency Management items 2-4, 6 | ~400 | Dependabot, lockfiles, `^` ranges, SBOM. Standard practice. |

Subtotal: ~4,700 chars.

### Compress (keep the number, drop the prose)

| Section | Now | To |
|---|---:|---|
| Devil's Advocate | ~900 | One line: "Before an architectural choice, name the tradeoff and the worst realistic failure." The mandatory scripted preamble is the article's exact anti-pattern; Opus 5 reasons this way without the ritual. |
| Performance | ~600 | Keep the budgets (p95 < 200ms, LCP < 2.5s, bundle < 200KB gzip) and cache-first. Drop the rest. |
| Accessibility | ~600 | Keep WCAG 2.2 AA and the deaf/blind specifics in 2 lines. |
| Security: Crypto, Auth, Data | ~700 | Keep only the non-default picks: Argon2id (no bcrypt, no scrypt), ML-KEM/ML-DSA, AES-256-GCM, field-level PII encryption. |
| Naming, APIs | ~500 | Keep the error schema shape. Naming is JS/TS default. |

Subtotal saved: ~2,300 chars.

### Keep verbatim (real gotchas, non-derivable)

- **Cloudflare DNS is manual.** Claude cannot edit it. Exact record format per target.
  This is the single most valuable line in the file.
- **Cloud cost strategy.** Paid needs prior confirmation every time; the three things to
  present; "silence is not consent." Plus the financial context (zero budget, ₹2.4L debt)
  which genuinely changes decisions.
- **Deploy targets.** Vercel or Cloud Run, one target per project, never more; VM is a
  confirmed paid path.
- **pnpm only.** No em dashes.
- **Super Admin panel** requirement and its constraints.
- **Every project includes**: `autoconfig.sh`, `Dockerfile`, `deploy/`, humanizer gate.
- **Stack picks**: Drizzle + 4 timestamp columns + soft delete, pino + `no-console`, zod
  env validation, Sentry + OTel + `/health` and `/health/ready`, Server Components default,
  Zustand + SWR, `react-hook-form` + zod.
- **CHANGELOG.md** before every commit.
- Core principles 1, 2, 5, 7.

**Net: 18,544 → roughly 11,000 chars.** Not the 80% Anthropic managed, because a real
share of this file is genuinely non-obvious personal constraint. The 80% figure applied to
a generic product system prompt.

---

## 4. Config surgery (cheapest win: no judgement calls)

Not the biggest win. By the section 3 table, `CLAUDE.md` recovers ~7,000 chars and this
recovers ~5,000-6,000. It goes second because it is zero-risk, not because it is largest.

### 4.1 MCP servers: two different mechanisms, two different places

Verified: `settings.json` has no `mcpServers` key and there is no `.mcp.json`. So these
split into two buckets and **editing `settings.json` will not touch the big one**.

**Bucket A: claude.ai connectors** (tool prefix `mcp__claude_ai_*`). Managed in claude.ai
connector settings, not on disk. Loaded and paying rent every session: **Canva** (39
tools), **Vercel** (30), **Cloudflare Developer Platform** (24), **Kindora Funder
Discovery** (12, instruction block long enough to be truncated in-context), **Anthropic
Economic Index** (9), **PubMed** (7), **Granted** (5), **Mermaid** (1).

Vercel and Cloudflare match the deploy stack and are worth keeping. Canva, Kindora,
Granted, PubMed, Economic Index, Mermaid are ~5,000-6,000 chars of names and prose for
capabilities this workload never uses. Disconnect them at claude.ai.

**Bucket B: plugin MCP servers** (`mcp__plugin_*`): `context7`, `playwright`. These live in
`enabledPlugins` in `settings.json`. Both earn their keep. No change.

**The 14 auth-pending servers are not a token item.** Consensus, Gmail, Calendar, BigQuery,
Drive, Helix GenoSphere, ICD-10, Indeed, Norton, Remote.com, Semrush, Stripe, Zoom,
alphaXiv cost only their names in the "needs authentication" list; their tool schemas
never loaded. Disconnecting them tidies the list and removes a standing prompt to
authorize, but recovers almost nothing. Do it for hygiene, not for tokens.

### 4.2 Overlapping rule systems

The article's named failure mode is conflicting messages inside one request. Current
duplicate pairs:

| Domain | Competing |
|---|---|
| Visual design | `frontend-design` plugin vs `dmj:art-directing` |
| Code review | `code-review` plugin vs `dmj:requesting-code-review` |
| Simplification | `code-simplifier` plugin vs built-in `simplify` |
| Codebase mapping | built-in `explore` vs `dmj:exploring-codebases` vs `dmj:tracing-codebases` |

**Action:** one per domain. Keep the `dmj` ones (they are tuned to this workflow), disable
`frontend-design` and `code-simplifier`. `explore` vs the two `dmj` skills is a genuine
three-way overlap inside the library itself: `exploring-codebases` and `tracing-codebases`
differ only in deliverable (reuse-gate vs chat explanation). Merge candidate.

### 4.3 Cost and staleness

- `CLAUDE_CODE_SUBAGENT_MODEL: "opus[1m]"`: **no change needed.** Floating alias, already
  resolves to Opus 5; see the correction in 2.2.
- `effortLevel: "max"` **and** `CLAUDE_CODE_EFFORT_LEVEL: "max"`: duplicated, and max
  effort on every trivial turn is a real spend against a zero budget. Consider `high` as
  the default with `max` reserved for the hard gates, which `harnessing-claude` can
  request per call.
- `outputStyle: "verbose"`: see 2.4.

---

## 5. Skills library changes

### 5.1 Mechanical (required by 2.1)

Rewrite 20 `TeamCreate` references and 10 `team_name` references across 19 files to
`Agent(name:)` + `SendMessage`. Files: `art-directing`, `brainstorming`,
`crafting-experiences`, `defending-in-depth`, `dispatching-parallel-teams`,
`enforcing-performance-budgets`, `executing-plans`, `exploring-codebases`,
`harnessing-claude`, `requesting-code-review`, `researching-deeply`, `selling-the-vision`,
`systematic-debugging`, `team-driven-development`, `tracing-codebases`, `using-dmj`,
`verification-before-completion`, `writing-plans`, `writing-skills` (+ its
`testing-skills-with-teams.md`).

Same pass removes the "no TeamCreate -> fall back to parallel Agent calls" hedging, which
becomes the only path.

**Three of those are rewrites, not substitutions. Do not scope this as find-and-replace or
hand it to a cheap tier:**

- `dispatching-parallel-teams` and `team-driven-development` are *named for* the dead
  mechanism. Their whole shape assumes a team object that is created, populated, and torn
  down. Under the current model there is one implicit team and agents are spawned named,
  addressed by name, and resumed by name. Different lifecycle, different teardown story.
- `using-dmj` asserts "No TeamCreate -> same stages as parallel Agent calls" as a
  *fallback*. That is now the only path, and this file is injected into every session, so
  a stale sentence here costs on every turn.

### 5.2 `using-dmj` (injected every session, tightest budget)

2,425 chars today. Problems, in the article's terms:

- `<EXTREMELY_IMPORTANT>` wrapper, "Not optional, not rationalizable", and a "you are
  rationalizing" table are coercion aimed at a model that no longer needs it. They argue
  against Claude's judgement instead of informing it.
- The 1% rule contradicts `CLAUDE.md` principle 4 (see 2.3).

**Rewrite as a routing map**: which skill for which situation, the conflict priority
order, the delete-outside-working-folder rule (a real guardrail, keep it). Drop the
coercion and the rationalization table. Target ~1,000 chars.

### 5.3 Skill descriptions

8,829 chars for 31 skills, mean 285. Descriptions are the always-loaded part; bodies are
free until invoked. Worst: `orchestrating-products` 455, `art-directing` 454,
`enforcing-performance-budgets` 445, `equipping-projects` 419, `crafting-experiences` 409.

These read as exhaustive symptom lists written when routing was unreliable. Trim to
trigger + domain, target ≤200 each: saves ~2,600 chars per session.

Counter-consideration: descriptions are the routing signal. Cutting too far degrades skill
selection, which is worse than the token cost. Trim the redundant symptom clauses, keep
the distinguishing trigger. Verify with the routing gauntlet (see 7).

### 5.4 Bodies: low priority, one exception

Bodies cost nothing until invoked, so size alone is not a reason to cut. The exception is
prose that overrides judgement rather than informing it: the rationalization tables in
`brainstorming`, `verification-before-completion`, `receiving-code-review`. Keep the
tables where the failure is genuinely expensive (verification claims, security), cut them
where the model now handles it (design ceremony on small tasks).

---

## 6. What the article says to ADD

Cutting is the efficiency half. The field guide's unknowns-discovery patterns are the
creativity half, and none of them exist in this library today.

| Pattern | Status | Where it belongs |
|---|---|---|
| **Blind spot pass** ("find my unknown unknowns before I prompt you") | missing | new skill, or front of `brainstorming` |
| **Prototype before wiring** (throwaway HTML mock reacted to before backend) | partial (spikes exist, visual mocks do not) | `brainstorming` step 1 |
| **Interview me one question at a time, prioritized by architectural impact** | missing (`AskUserQuestion` batching only) | `brainstorming` |
| **References over descriptions** (point at source code, a test suite, an HTML mock as the spec) | missing | `writing-plans`, `art-directing` |
| **`implementation-notes.md` with a Deviations log** | missing | `executing-plans`, `team-driven-development` |
| **Quiz the user on the change before merge** | missing | `finishing-a-development-branch` |
| **Rubrics as verifier input** | partial (`requesting-code-review` lenses) | formalize as rubric files |

The highest-value single addition is the blind spot pass. Everything in the library
assumes the user knows what they want and the job is to execute rigorously. The field
guide's claim is the opposite: with Opus 5 the bottleneck is the user's unstated unknowns,
not the model's execution. A `discovering-unknowns` skill that runs before `brainstorming`
targets exactly that.

Second highest: **specs as rich references instead of markdown prose.** `brainstorming`
step 5 writes `docs/dmj/specs/*.md`. The article's finding is that an HTML artifact, a
failing test suite, or a pointed-at source directory carries more fidelity than prose. The
skill should let the spec take whichever of those forms fits.

---

## 7. Do not touch

The article's "delete constraints" applies to prose competing for the model's judgement.
It does not apply to deterministic gates that live outside the context window and cost
zero tokens:

- `hooks/pre-tool-guard`: blocks `--no-verify`, force push, `reset --hard origin/*`.
  Exactly the worst-case class guardrails exist for, and it is free.
- `scripts/pre-commit-secrets.sh`.
- The humanizer pre-push gate.
- `defaultMode: bypassPermissions` is only defensible *because* these hooks exist. Keep
  both or neither.
- Performance budget numbers, the paid-resource confirmation rule, security floors. These
  are constraints on the *product*, not on the model's reasoning.

---

## 8. Verification gate

> **Historical (2.25.0):** this section instructs re-running files deleted in
> 2.23.0/2.23.1 (`tests/pressure-test-battery.md`, `scripts/behavioral-test.sh`,
> `scripts/guard-test.sh`). The battery is gone and will not be recreated (user
> order: no tests in this repo). What replaces it: authoring-time fresh-context
> pressure probes recorded in the commit message and CHANGELOG
> (dmj:writing-skills), validate.js structural checks, and the release-time
> behavioral-diff gate in scripts/release.sh.

`tests/pressure-test-battery.md` (34.7K), `scripts/behavioral-test.sh`, and
`scripts/guard-test.sh` are what certified 50/50 at 2.17.1. Any trim applied here is
verified by re-running that battery, not by reading the diff. A description trim that
saves 2,600 chars but drops routing accuracy below the last run is a regression, not a
win.

Add one battery scenario per contradiction in section 2, so the conflict cannot come back.

**Blocker on 5.3: the battery may be blind to description trims.** Its routing scenarios
were authored alongside the current descriptions and may echo their phrasing. If a
scenario reuses wording that only exists in the description being trimmed, a green battery
after the trim proves nothing: it matched text the trim was supposed to remove. Before
touching descriptions, check `tests/pressure-test-battery.md` for scenario prompts that
borrow description wording. If they do, the trim needs fresh scenarios written blind to
the descriptions, or an independent routing check, before the battery counts as evidence.

---

## 9. Order of operations

0. User runs `/doctor` (first-party, built for exactly this; cannot be run
   non-interactively from here). Compare its findings against this document.
1. Fix 2.1 and 2.2: broken and stale, no taste involved.
2. Section 4 settings surgery: biggest token win, zero judgement.
3. Resolve 2.3 and 2.4: needs one decision from the user each.
4. `CLAUDE.md` cut (section 3): needs review; it is the user's file.
5. `using-dmj` rewrite (5.2), then descriptions (5.3).
6. Re-run the battery (section 7).
7. Only then, the additions in section 6: new capability on a clean base.

---

## 9a. `/doctor` cross-check (run 2026-07-29, 50 sessions / 22 days / 12 projects)

### Confirmed, by an independent method

| Item | This audit | `/doctor` | |
|---|---|---|---|
| `CLAUDE.md` resident size | 18,544 chars | ~4.6k tokens | 18,544 ÷ 4 = 4,636. Exact match. |
| `dmj` skill descriptions | 8,829 chars (~2.2k tok) | ~2.3k tokens | Match. |
| Biggest always-loaded item | `CLAUDE.md`, top of table | "bigger than the entire skill listing (~3.6k)" | Same conclusion. |
| Plugins duplicating `dmj` skills | `frontend-design`, `code-review`, `code-simplifier`, `claude-md-management` (§4.2) | same four, remove | Independent agreement. |
| MCP connectors live at claude.ai, not `settings.json` | §4.1 bucket A | "I can't: claude.ai → Settings → Connectors" | Confirms the §4.1 correction. |
| `CLAUDE.md` keep-list | §3 "keep verbatim" | "Devil's Advocate, Reality Standard, Core Principles, no-em-dashes, pnpm-only, paid-resource rule stay" | Near-identical. |

### What `/doctor` found that this audit missed

**Hook latency: the biggest daily-friction item, and it is not in this document at all.**
Section 7 said "hooks cost zero context" and stopped there. Context is not the only cost:

- `SessionStart`: p50 **4,589 ms**, p90 **14,296 ms**. Two hooks stacked (`dmj` + `security-guidance`).
- `Stop`: 25 runs, avg **4,928 ms**, worst **16,188 ms**.
- `PreToolUse` on Bash: 909 runs, p95 1.6 s, p99 6.2 s, 8 runs over 10 s, **worst 324,841 ms (5.4 minutes)**, 4 hard timeouts, 17 non-blocking errors. Two hooks stacked: `rtk hook claude` + `dmj/pre-tool-guard`.

Section 7's "do not touch" verdict on `pre-tool-guard` stands on the security argument, but it
was reached without measuring what it costs per Bash call. A guard that occasionally
blocks for minutes is worth profiling even if it is worth keeping.

**`ralph-loop` fires a `Stop` hook at every turn end.** Its 1,388 "uses" are hook dispatches,
not invocations. Never examined here.

**Six plugins share an identical `lastUsedAt`**: the batch-install seed, not usage. Usage
had to be read from transcripts instead.

### What this audit found that `/doctor` cannot see

`/doctor` scores components by **usage**, not by **correctness**. It rates `dmj@dmj` "keep,
5,505 uses": true, and orthogonal to §2.1: `TeamCreate` no longer exists, so 20 references
across 19 of those skill files instruct a tool that is not there. A heavily-used plugin can
be heavily-used *and* substantially unexecutable; usage counts cannot distinguish them.

Also absent from `/doctor`, by design: the three-way gate conflict (§2.3), `outputStyle:
verbose` vs the caveman hook (§2.4), the stale "Opus 4.8" label (§2.2), and the missing
unknowns-discovery capability (§6).

### One genuine disagreement

**Devil's Advocate.** `/doctor` keeps it always-loaded; §3 compresses it to one line. Both
are defensible: it is user-identity content (doctor's axis), and it is a scripted ritual of
the kind newer models perform without prompting (this audit's axis). The user decides.

### Revised token accounting

`/doctor` scores deferred MCP tool schemas at ~0 resident and prices only the three prose-heavy
servers' instructions at ~1.1k tokens. §1 counted ~1,900 tokens of MCP tool *names* as
resident: those names are visibly present in the loaded context, so the true figure sits
between the two. The recoverable portion both methods agree on is the **instructions**, not
the names. Treat §1's ~14k as the fuller accounting and ~1.1k to 3.2k as the honest range for
the MCP line specifically.

---

## 10. Trend note

The last five commits added laws: "verified-stays-verified guard law", "earned
per-category autonomy", "pivot-gate", "gamed-evaluator regression". Each was a reasonable
response to a real failure. The accumulation is itself the finding the article describes:
constraints added for a model generation that needed them, still firing for one that does
not. Worth a standing rule in `evolving-skills`: every added law names the model behavior
it compensates for, so a later pass can test whether that behavior still exists.
