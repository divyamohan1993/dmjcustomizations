#!/usr/bin/env bash
# Deterministic tests for hooks/pre-tool-guard: feed PreToolUse JSON, assert
# deny/allow. No model calls; runs in validate.sh.
set -uo pipefail
cd "$(dirname "$0")/.."
G=hooks/pre-tool-guard
FAIL=0

probe() { # probe <name> <expect deny|allow> <command-string-json-escaped>
  local name="$1" expect="$2" cmd="$3" out rc
  out=$(printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$cmd" | DMJ_ALLOW= bash "$G")
  rc=$?
  if [ "$expect" = deny ]; then
    if printf '%s' "$out" | grep -q '"permissionDecision":"deny"'; then echo "PASS $name (denied)"; else echo "FAIL $name: expected deny, got rc=$rc out=$out"; FAIL=1; fi
  else
    if [ -z "$out" ] && [ $rc -eq 0 ]; then echo "PASS $name (allowed)"; else echo "FAIL $name: expected allow, got rc=$rc out=$out"; FAIL=1; fi
  fi
}

probe no-verify-commit        deny  'git commit -m x --no-verify'
probe no-verify-push          deny  'git push --no-verify'
probe force-push-long         deny  'git push --force origin main'
probe force-push-short        deny  'git push -f'
probe hard-reset-origin       deny  'git reset --hard origin/main'
probe hard-reset-upstream     deny  'git reset --hard @{u}'
probe plain-commit            allow 'git commit -m \"feat: x\"'
probe plain-push              allow 'git push origin main'
probe force-with-lease        allow 'git push --force-with-lease origin main'
probe hard-reset-local        allow 'git reset --hard HEAD~1'
probe unrelated-rm            allow 'rm -rf node_modules'
probe verify-in-word          allow 'echo no-verifying-here && git status'

# Bypass path: DMJ_ALLOW=1 must allow and log.
out=$(printf '{"tool_input":{"command":"git push --force"}}' | DMJ_ALLOW=1 bash "$G" 2>/tmp/guard-bypass.log)
if [ -z "$out" ] && grep -q BYPASSED /tmp/guard-bypass.log; then echo "PASS bypass (DMJ_ALLOW=1 logged)"; else echo "FAIL bypass"; FAIL=1; fi
rm -f /tmp/guard-bypass.log

[ $FAIL -eq 0 ] && echo "GUARD TEST PASS: 13 probes held" || exit 1
