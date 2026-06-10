#!/usr/bin/env bash
# Structural self-audit. Heavy per-file checks run in ONE node pass
# (scripts/validate.js); bash only adds the hook-syntax check node cannot do.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
bash -n hooks/session-start || { echo "FAIL: hooks/session-start syntax"; fail=1; }
node scripts/validate.js || fail=1
exit $fail
