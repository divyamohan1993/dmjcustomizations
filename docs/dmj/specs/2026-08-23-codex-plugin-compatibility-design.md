# Codex Plugin Compatibility Design

- Date: 2026-08-23
- Status: Approved
- Causal-chain owner: Codex compatibility maintainer
- Decision: add Codex-native metadata and hook routing beside the existing Claude surfaces. Reuse the shared runner and guard, with fail-closed handling for malformed input and broken hook dependencies.

## Evidence and decision

- Claude metadata is in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
- Claude hook routing is in `hooks/hooks.json`.
- The native Codex surfaces are `.codex-plugin/plugin.json` and `.codex/hooks.json`.
- The local Codex CLI exposes `codex plugin marketplace add` and `codex plugin add`; the repository must provide the native files those commands load.
- The shared runner is `hooks/run-hook.cmd`. It routes to `hooks/session-start` and `hooks/pre-tool-guard` on Windows and POSIX hosts.
- The native route must preserve `CLAUDE_PLUGIN_ROOT` because the shared scripts resolve the plugin root from that value.

## Scope

- Add native Codex metadata and hook routing.
- Reuse the existing hook entry points without changing normal valid Claude behavior.
- Harden the shared runner and PreToolUse guard against malformed input, bypass attempts, invalid names, missing dependencies, and child failures.
- Add one cross-host fixture for manifest shape, Windows and POSIX command routes, hook output, runner exit behavior, and Claude-surface preservation.
- Record the compatibility surface in README and CHANGELOG.

## Out of scope

- The external security-guidance plugin is not part of this change and its files are not edited.
- Claude metadata and `hooks/hooks.json` are not renamed, replaced, or routed through a shim.
- Repository code and the fixture do not create or edit local Codex or Claude config, install state, cache, or marketplace snapshots. They do not edit user home files.
- No new dependency, cloud change, account change, publish, or push is included.

## Exact file map

### Add

- `.codex-plugin/plugin.json`
- `.codex/hooks.json`
- `.github/workflows/qgate.yml`
- `.qgate-lanes.sh`
- `qgate.config.sh`
- `qgate.sh`
- `features/codex-plugin-compatibility.feature`
- `tests/hooks.bats`
- `scripts/fuzz-hooks.sh`
- `scripts/test-hook-compatibility.mjs`

### Modify

- `.claude-plugin/plugin.json` (version field only)
- `.claude-plugin/marketplace.json` (version field only)
- `hooks/run-hook.cmd`
- `hooks/session-start`
- `hooks/pre-tool-guard`
- `hooks/pre-tool-guard.js`
- `scripts/pre-commit-secrets.sh`
- `scripts/release.sh`
- `scripts/validate.js`
- `scripts/validate.sh`
- `skills/enforcing-quality-gates/install-gate.sh`
- `skills/humanizing-output/install.sh`
- `README.md`
- `CHANGELOG.md`
- `docs/dmj/specs/2026-08-23-codex-plugin-compatibility-design.md`
- `docs/dmj/plans/2026-08-23-codex-plugin-compatibility.md`
- `docs/dmj/skill-learnings/2026-07-29-teammate-numbers-unmeasured.md`
- `docs/dmj/skill-learnings/README.md`
- `docs/dmj/specs/2026-07-29-claude5-then-now-pass-design.md`
- `docs/dmj/specs/2026-07-29-claude5-then-now-pass-ledger.md`
- `docs/dmj/specs/2026-07-29-opus5-context-audit.md`

### YAML representation-only changes

The following `SKILL.md` files may change only by quoting a YAML `description` scalar:

- `skills/art-directing/SKILL.md`
- `skills/defending-in-depth/SKILL.md`
- `skills/enforcing-performance-budgets/SKILL.md`
- `skills/enforcing-quality-gates/SKILL.md`
- `skills/equipping-projects/SKILL.md`
- `skills/evolving-skills/SKILL.md`
- `skills/humanizing-output/SKILL.md`
- `skills/observing-production/SKILL.md`
- `skills/orchestrating-products/SKILL.md`
- `skills/researching-deeply/SKILL.md`
- `skills/selling-the-vision/SKILL.md`
- `skills/shipping-to-production/SKILL.md`
- `skills/stewarding-data/SKILL.md`
- `skills/tracing-codebases/SKILL.md`

The parsed description text, keys, and body must remain identical.

### Preserve exactly

- `hooks/hooks.json`
- `.github/workflows/validate.yml`
- Every file in the external security-guidance plugin.

Any implementation file outside this map is a release failure. Local config and cache paths are forbidden.

## Ownership

- Codex compatibility maintainer: native files, hooks, fixture, tests, fuzz, validators, qgate artifacts, and workflow.
- Records maintainer: README, CHANGELOG, approved design and plan, the four legacy STE files, and the legacy Opus context-audit record.
- YAML maintainer: the representation-only `SKILL.md` paths listed above.
- Shell maintainer: shell lint fixes in `scripts/pre-commit-secrets.sh`, `scripts/release.sh`, `scripts/validate.sh`, and the two installer files.

One causal-chain owner remains accountable for design, implementation, evidence, and release scope.

## Preservation rules

The two Claude metadata files may change only their `version` field. All other parsed keys and values must remain identical. `hooks/hooks.json` stays unchanged. YAML frontmatter edits are representation-only quoting with identical parsed description text.

## Native routes

The Codex hook manifest contains exactly `SessionStart` and `PreToolUse`. It contains no `UserPromptSubmit` or `PostToolUse` route.

| Event | Matcher | POSIX `command` | Windows `commandWindows` | Shared script |
| --- | --- | --- | --- | --- |
| `SessionStart` | `startup\|clear\|compact` | `"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start` | `cmd.exe /c ""%CLAUDE_PLUGIN_ROOT%\\hooks\\run-hook.cmd" session-start"` | `session-start` |
| `PreToolUse` | `Bash\|PowerShell` | `"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" pre-tool-guard` | `cmd.exe /c ""%CLAUDE_PLUGIN_ROOT%\\hooks\\run-hook.cmd" pre-tool-guard"` | `pre-tool-guard` |

The strings above are data in `.codex/hooks.json`, not shell snippets assembled at runtime. Both routes carry `CLAUDE_PLUGIN_ROOT`, use the fixed shared runner, and pass one allowlisted script name.

## Threat model and security hardening

### Assets

- Plugin manifests, hook routing, scripts, command paths, arguments, and exit codes.
- `CLAUDE_PLUGIN_ROOT`, hook input, and the repository files reachable by a hook.
- Release records and validation evidence.

### Boundaries and abuse cases

- Host to Codex or Claude loader, loader to manifest, loader to hook process, and hook process to repository commands are trust boundaries.
- A route can point outside the repository, lose quoting, alter arguments, or run an unintended executable.
- A caller can send empty, malformed, or structurally incomplete hook input.
- An environment variable or unsupported argument can attempt to bypass the guard.
- A missing interpreter, missing guard file, invalid script name, or child failure can cause an unsafe fail-open path.
- A changed Claude route can silently alter existing sessions.

### Controls

- Native manifests use fixed, reviewed routes and exact Windows quoting. The runner accepts only `session-start` or `pre-tool-guard`, exactly one argument, and trusted fixed Bash locations. It does not search `PATH` for Bash.
- The PreToolUse guard parses the complete JSON payload, requires a non-empty string at `tool_input.command`, and returns a deny decision for empty, malformed, unreadable, or incomplete input.
- The guard keeps the existing deny policies for `--no-verify`, force push except `--force-with-lease`, and remote `reset --hard`. An environment value or other bypass attempt does not disable these checks.
- A missing Node interpreter or guard engine returns a deny decision. The runner returns a non-zero status for invalid names, extra arguments, and missing trusted Bash, and propagates the real child status.
- The fixture checks valid `SessionStart` JSON and harmless `PreToolUse` output with exit zero. It checks the three deny policies, malformed and missing-command denial, invalid runner input, and child status propagation. It checks native routes and Claude hook preservation.
- The implementation does not print hook payloads, command arguments, or secrets.

### ASVS Level 2 scope

ASVS Level 2 review covers local manifest and hook controls. These include input validation, path and command handling, configuration integrity, error handling, and logging. Authentication, sessions, network APIs, payment, and data-storage controls are not introduced. They are not applicable. This design does not create a separate ASVS matrix.

## Requirements

These stable R-IDs are the contract. The `REQ-` marker keeps each ID machine-readable. They use EARS patterns: Ubiquitous `[U]`, Event-driven `[E]`, Unwanted behavior `[W]`, and Optional or conditional `[O]`.

REQ-R-001: The repository shall expose `.codex-plugin/plugin.json` with the `dmj` identity, strict semantic version, author, repository, homepage, license, and keyword fields.
REQ-R-002: The repository shall expose `.codex/hooks.json` with exactly the `SessionStart` and `PreToolUse` routes and no other event.
REQ-R-003: When Codex dispatches a supported event on POSIX, the native route shall use the exact `command` string and preserve `CLAUDE_PLUGIN_ROOT`.
REQ-R-004: When Codex dispatches a supported event on Windows, the native route shall use the exact `commandWindows` string and preserve `CLAUDE_PLUGIN_ROOT`.
REQ-R-005: When a native route runs, it shall invoke only `hooks/run-hook.cmd` with its matching allowlisted script name.
REQ-R-006: The runner shall accept one allowlisted name, reject invalid names and extra arguments, use fixed trusted Bash, and return child status.
REQ-R-007: When valid harmless `SessionStart` input is run, the shared hook shall return valid `SessionStart` JSON with the existing context contract.
REQ-R-008: When valid harmless `PreToolUse` input is run, the guard shall return empty output and exit zero, preserving normal valid Claude behavior.
REQ-R-009: If a command contains `--no-verify`, force push without `--force-with-lease`, or remote `reset --hard`, then the guard shall return a valid `PreToolUse` deny decision.
REQ-R-010: If PreToolUse input is empty, malformed, unreadable, or missing a non-empty `tool_input.command`, then the guard shall return a valid `PreToolUse` deny decision.
REQ-R-011: If Node or the selected guard engine is unavailable, then the hook shall return a valid deny decision instead of running unguarded.
REQ-R-012: If an environment value or unsupported argument attempts bypass, then the guard shall enforce R-009 and reject it as authorization.
REQ-R-013: The repository shall preserve the Claude hook manifest and Claude metadata semantics, and shall not add, remove, or retarget a Claude event.
REQ-R-014: The repository shall leave the external security-guidance plugin, local config, local cache, and user home state untouched.
REQ-R-015: When the validator runs, it shall require native files, allowed events, route values, interface fields, version parity, and preserved Claude hook behavior.
REQ-R-016: When the cross-host fixture runs on Windows or POSIX, it shall check native manifests, both routes, hooks, runner errors, Claude preservation, and local-state safety.
REQ-R-017: The release record shall contain one dated Keep a Changelog 5.1.0 entry for native Codex manifests and hooks, the cross-host fixture, and fail-closed hook hardening.

## Traceability matrix

| Requirement IDs | Implementation or evidence | Exact proof |
| --- | --- | --- |
| R-001, R-002, R-003, R-004, R-005 | `.codex-plugin/plugin.json`, `.codex/hooks.json` | `node scripts/test-hook-compatibility.mjs` |
| R-006, R-007, R-008, R-009, R-010, R-011, R-012 | `hooks/run-hook.cmd`, `hooks/session-start`, `hooks/pre-tool-guard`, `hooks/pre-tool-guard.js` | `node scripts/test-hook-compatibility.mjs`; `bash -n hooks/session-start`; `bash -n hooks/pre-tool-guard` |
| R-013 | `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `hooks/hooks.json` | Claude semantic and hash snapshot in `scripts/test-hook-compatibility.mjs` |
| R-014 | Exact file map and repository diff | `git diff --name-only`; `git diff --check -- <owned files>` |
| R-015 | `scripts/validate.js`, `.codex-plugin/plugin.json`, `.codex/hooks.json`, `hooks/hooks.json` | `node scripts/validate.js`; `node scripts/test-hook-compatibility.mjs` |
| R-016 | `features/codex-plugin-compatibility.feature`, `scripts/test-hook-compatibility.mjs`, `tests/hooks.bats`, `scripts/fuzz-hooks.sh` | `node scripts/test-hook-compatibility.mjs`; `bats tests/hooks.bats`; `bash scripts/fuzz-hooks.sh` |
| R-017 | `CHANGELOG.md` | `node scripts/validate.js` |

## RED and GREEN commands

The RED command runs before either native manifest exists and must exit `1` because R-001 and R-002 are unmet. The GREEN command runs after the native files and fixture are present and must exit `0`.

### POSIX

```sh
# RED, before .codex-plugin/plugin.json and .codex/hooks.json exist
node scripts/test-hook-compatibility.mjs

# GREEN, after the approved implementation files exist
node scripts/test-hook-compatibility.mjs
bash -n hooks/run-hook.cmd
bash -n hooks/session-start
bash -n hooks/pre-tool-guard
node scripts/validate.js
bash scripts/validate.sh
```

### Windows PowerShell

```powershell
# RED, before .codex-plugin/plugin.json and .codex/hooks.json exist
node .\scripts\test-hook-compatibility.mjs

# GREEN, after the approved implementation files exist
node .\scripts\test-hook-compatibility.mjs
node .\scripts\validate.js
```

The feature scenarios are implemented by `scripts/test-hook-compatibility.mjs`. `tests/hooks.bats` binds that fixture to the acceptance command. `scripts/fuzz-hooks.sh` adds bounded hostile-input checks. The fixture invokes the shared runner through `/bin/bash` on POSIX and `cmd.exe` on Windows. It proves the exact native route strings. `codex plugin marketplace add` and `codex plugin add` install plugins, not validate them. They write Codex local config or cache, so they are outside this repository change.

## Approval boundary

The implementation is approved only when all R-IDs have evidence and the exact file map is clean. Normal valid Claude behavior must be preserved. Malformed and bypass inputs must deny. No local or external security-guidance state may change. No push or release publication is authorized by this design.
