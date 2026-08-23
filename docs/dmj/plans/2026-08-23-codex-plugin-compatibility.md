# Plan: Codex Plugin Compatibility

**Status:** Approved
**Date:** 2026-08-23
**Causal-chain owner:** Codex compatibility maintainer
**Outcome:** Codex loads the native manifest and hook routes on Windows and POSIX hosts. Shared hooks keep normal valid Claude behavior and deny malformed, bypass, and broken-engine cases.

The causal-chain owner is accountable for design, RED, implementation, GREEN, and evidence. File-level delegation may be disjoint, but accountability is not split.

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

The 14 changed `SKILL.md` files only quote YAML `description` scalars. Parsed text, keys, and bodies stay identical. The exact paths are listed in the approved design.

### Preserve exactly

- `hooks/hooks.json`
- `.github/workflows/validate.yml`
- Files belonging to the external security-guidance plugin.

No file outside this map may change. The two Claude metadata files may change only their `version` fields. No repository command or fixture may edit local Codex or Claude config, install state, cache, marketplace snapshots, or user home files.

## Ownership

- Codex compatibility maintainer: native files, hooks, fixture, tests, fuzz, validators, qgate artifacts, and workflow.
- Records maintainer: README, CHANGELOG, approved design and plan, the four legacy STE files, and the legacy Opus context-audit record.
- YAML maintainer: the representation-only `SKILL.md` paths listed in the approved design.
- Shell maintainer: shell lint fixes in the five shell files listed in the approved design.

One causal-chain owner remains accountable for design, implementation, evidence, and release scope.

## Dependency-ordered work

### 1. Baseline and RED

Record the branch and the exact file map. Confirm the Claude manifest and `hooks/hooks.json` are unchanged before implementation.

Run the RED command before either native manifest exists:

```sh
node scripts/test-hook-compatibility.mjs
```

Expected result: exit `1` with missing native manifest failures. On Windows PowerShell, use:

```powershell
node .\\scripts\\test-hook-compatibility.mjs
```

Do not install a plugin or alter local Codex state to obtain RED evidence.

### 2. Native Codex surfaces

Create `.codex-plugin/plugin.json` and `.codex/hooks.json` only. The native hook manifest shall contain exactly `SessionStart` and `PreToolUse`.

Use these exact routes:

| Event | Matcher | POSIX `command` | Windows `commandWindows` |
| --- | --- | --- | --- |
| `SessionStart` | `startup\|clear\|compact` | `"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start` | `cmd.exe /c ""%CLAUDE_PLUGIN_ROOT%\\hooks\\run-hook.cmd" session-start"` |
| `PreToolUse` | `Bash\|PowerShell` | `"${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" pre-tool-guard` | `cmd.exe /c ""%CLAUDE_PLUGIN_ROOT%\\hooks\\run-hook.cmd" pre-tool-guard"` |

Do not add `UserPromptSubmit`, `PostToolUse`, a second runner, or a manifest `hooks` field.

### 3. Shared hook hardening

Update only the four shared hook files in the map.

- Keep valid `SessionStart` JSON and harmless `PreToolUse` output unchanged.
- Allow only `session-start` and `pre-tool-guard`, exactly one argument, and trusted fixed Bash paths.
- Reject invalid names and extra arguments with non-zero status. Propagate the child status.
- Parse complete PreToolUse JSON. Empty, malformed, unreadable, and missing-command input returns a valid deny decision.
- A missing Node interpreter or selected guard file returns a deny decision. No environment value or unsupported argument bypasses the policy.
- Keep the three existing deny policies, including the `--force-with-lease` exception.

### 4. GREEN fixture

Run the cross-host fixture after the native files and hardening are present:

```sh
node scripts/test-hook-compatibility.mjs
```

```powershell
node .\\scripts\\test-hook-compatibility.mjs
```

Expected result: exit `0` on POSIX and Windows.
The fixture checks manifest shape and the exact POSIX and Windows route strings.
It checks `CLAUDE_PLUGIN_ROOT`, valid SessionStart JSON, and harmless PreToolUse behavior.
It checks deny cases, malformed and missing-command input, invalid runner input, child status propagation, and the Claude hook snapshot.

### 5. Records and traceability

Update README with Claude Code and Codex support plus install expectations. Add the dated 5.1.0 Keep a Changelog entry for native manifests and hooks, the cross-host fixture, and fail-closed hook hardening. Keep the design requirements and traceability matrix authoritative. The requirement IDs are stable `R-001` through `R-017` in the approved design.

The feature file is the scenario source. The Node fixture implements it. `tests/hooks.bats` runs the fixture as the acceptance command. `scripts/fuzz-hooks.sh` runs the bounded hostile-input checks.

### 6. Validation and stop gate

Run these exact checks. Do not run `codex plugin marketplace add` or `codex plugin add` in the repository gate because those commands write Codex-managed local state.

```sh
node scripts/test-hook-compatibility.mjs
bats tests/hooks.bats
bash scripts/fuzz-hooks.sh
bash -n hooks/run-hook.cmd
bash -n hooks/session-start
bash -n hooks/pre-tool-guard
node scripts/validate.js
bash scripts/validate.sh
git diff --name-only
git diff --check -- docs/dmj/specs/2026-08-23-codex-plugin-compatibility-design.md docs/dmj/plans/2026-08-23-codex-plugin-compatibility.md README.md CHANGELOG.md
```

On Windows PowerShell, run the Node validator with `node .\\scripts\\validate.js` and the fixture with `node .\\scripts\\test-hook-compatibility.mjs`. Use Git Bash for the Bash checks.

Stop if any command fails or any file outside the map changes.
Stop if Claude surface semantics drift or malformed or bypass input is allowed.
Stop if local or external security-guidance state changes.
No commit or push is part of this plan.
