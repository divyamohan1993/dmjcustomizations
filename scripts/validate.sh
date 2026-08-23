#!/usr/bin/env bash
# Structural self-audit. Heavy per-file checks run in ONE node pass
# (scripts/validate.js); bash only adds the hook-syntax check node cannot do.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
fail=0
bash -n hooks/session-start || { echo "FAIL: hooks/session-start syntax"; fail=1; }
bash -n hooks/pre-tool-guard || { echo "FAIL: hooks/pre-tool-guard syntax"; fail=1; }
bash -n hooks/run-hook.cmd || { echo "FAIL: hooks/run-hook.cmd syntax"; fail=1; }
node scripts/test-hook-compatibility.mjs || fail=1
node scripts/validate.js || fail=1
# Official plugin schema validation when the CLI is present (absent in CI).
if command -v claude >/dev/null 2>&1; then
  claude plugin validate . || { echo "FAIL: claude plugin validate"; fail=1; }
fi
exit $fail
