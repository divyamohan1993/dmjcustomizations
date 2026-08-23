#!/usr/bin/env bash
set -euo pipefail

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
GUARD="$ROOT/hooks/pre-tool-guard"
if [ -x /usr/bin/bash ]; then
  BASH_EXE=/usr/bin/bash
elif [ -x /bin/bash ]; then
  BASH_EXE=/bin/bash
else
  printf 'FAIL: trusted Bash was not found\n' >&2
  exit 1
fi
failures=0
denies=0
allows=0
FUZZ_CASE_TIMEOUT_SECONDS="${FUZZ_CASE_TIMEOUT_SECONDS:-5}"
if ! command -v timeout >/dev/null 2>&1; then
  printf 'FAIL: timeout command is required for bounded fuzz cases\n' >&2
  exit 1
fi

record_failure() {
  printf 'FAIL: %s\n' "$1" >&2
  failures=$((failures + 1))
}

assert_deny() {
  local label="$1"
  local payload="$2"
  local output status
  set +e
  output=$(printf '%s' "$payload" | timeout "${FUZZ_CASE_TIMEOUT_SECONDS}s" env CLAUDE_PLUGIN_ROOT="$ROOT" "$BASH_EXE" "$GUARD" 2>/dev/null)
  status=$?
  set -e
  if [ "$status" -eq 124 ]; then
    record_failure "$label: timed out after ${FUZZ_CASE_TIMEOUT_SECONDS}s"
    return
  fi
  if [ "$status" -ne 0 ]; then
    record_failure "$label: guard returned exit $status"
    return
  fi
  if ! DENY_OUTPUT="$output" node -e '
    const value = JSON.parse(process.env.DENY_OUTPUT ?? "");
    const output = value.hookSpecificOutput;
    if (output?.hookEventName !== "PreToolUse" || output.permissionDecision !== "deny") process.exit(1);
  ' >/dev/null 2>&1; then
    record_failure "$label: invalid input did not return deny JSON"
    return
  fi
  denies=$((denies + 1))
}

assert_verdict() {
  local label="$1"
  local payload="$2"
  local token="$3"
  local output status
  set +e
  output=$(printf '%s' "$payload" | timeout "${FUZZ_CASE_TIMEOUT_SECONDS}s" env CLAUDE_PLUGIN_ROOT="$ROOT" "$BASH_EXE" "$GUARD" 2>/dev/null)
  status=$?
  set -e
  if [ "$status" -eq 124 ]; then
    record_failure "$label: timed out after ${FUZZ_CASE_TIMEOUT_SECONDS}s"
    return
  fi
  if [ "$status" -ne 0 ]; then
    record_failure "$label: guard returned exit $status"
    return
  fi
  if ! DENY_OUTPUT="$output" EXPECTED_TOKEN="$token" node -e '
    const value = JSON.parse(process.env.DENY_OUTPUT ?? "");
    const output = value.hookSpecificOutput;
    if (output?.hookEventName !== "PreToolUse" || output.permissionDecision !== "deny") process.exit(1);
    if (!output.permissionDecisionReason.includes(process.env.EXPECTED_TOKEN ?? "")) process.exit(1);
  ' >/dev/null 2>&1; then
    record_failure "$label: expected verdict token $token"
    return
  fi
  denies=$((denies + 1))
}

assert_allow() {
  local output status
  set +e
  output=$(printf '%s' '{"tool_name":"Bash","tool_input":{"command":"git status"}}' | timeout "${FUZZ_CASE_TIMEOUT_SECONDS}s" env CLAUDE_PLUGIN_ROOT="$ROOT" "$BASH_EXE" "$GUARD" 2>/dev/null)
  status=$?
  set -e
  if [ "$status" -eq 124 ]; then
    record_failure "harmless command: timed out after ${FUZZ_CASE_TIMEOUT_SECONDS}s"
    return
  fi
  if [ "$status" -ne 0 ] || [ -n "$output" ]; then
    record_failure 'harmless command: expected empty allow output and exit zero'
    return
  fi
  allows=$((allows + 1))
}

assert_deny 'empty input' ''
assert_deny 'malformed JSON' '{not-json'
assert_deny 'missing tool input' '{"tool_name":"Bash"}'
assert_deny 'missing command' '{"tool_name":"Bash","tool_input":{}}'
assert_deny 'null command' '{"tool_name":"Bash","tool_input":{"command":null}}'
assert_deny 'decoy command' '{"command":"git status","tool_input":{"command":"git push --force origin main"}}'
assert_verdict 'no-verify' '{"tool_name":"Bash","tool_input":{"command":"git commit --no-verify -m x"}}' '--no-verify'
assert_verdict 'force push' '{"tool_name":"Bash","tool_input":{"command":"git push --force origin main"}}' 'force push'
assert_verdict 'hard reset' '{"tool_name":"Bash","tool_input":{"command":"git reset --hard origin/main"}}' 'reset --hard'
assert_verdict 'escaped force push' '{"tool_name":"Bash","tool_input":{"command":"git push \u002d\u002dforce origin main"}}' 'force push'
assert_allow

if [ "$failures" -ne 0 ]; then
  printf 'HOOK FUZZ FAIL: %d failures, %d deny cases, %d allow cases\n' "$failures" "$denies" "$allows"
  exit 1
fi
printf 'HOOK FUZZ PASS: %d deny cases, %d allow cases\n' "$denies" "$allows"
