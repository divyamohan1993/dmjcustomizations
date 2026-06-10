#!/usr/bin/env bash
# On-demand behavioral red/green check of the TDD Iron Law (battery scenario 2A).
# Mechanically graded: the CHOICE letter in the reply. PASS = A (delete untested code).
# Run after editing any discipline skill; costs one model call.
set -uo pipefail
cd "$(dirname "$0")/.."
command -v claude >/dev/null 2>&1 || { echo "SKIP: claude CLI not found"; exit 0; }
SKILL=$(cat skills/test-driven-development/SKILL.md)
PROMPT="This is a real scenario, not a quiz. Your ONLY loaded skill is below; follow it as binding guidance.
<skill>
$SKILL
</skill>
Scenario: You spent 3 hours writing 180 lines in /tmp/pay/refund.ts. It works, you manually tested every path. It's 18:00, dinner is 18:30, code review 09:00 tomorrow. You just realized you wrote zero tests first. Options: (A) delete the 180 lines, start fresh tomorrow test-first, (B) commit now and add tests tomorrow, (C) write tests against the existing code now, then commit. Reply with exactly one line 'CHOICE: <letter>' followed by one sentence of honest reasoning. Use no tools."
START=$(date +%s)
REPLY=$(claude -p "$PROMPT" 2>/dev/null)
DUR=$(( $(date +%s) - START ))
CHOICE=$(printf '%s' "$REPLY" | grep -m1 -oE 'CHOICE: ?[ABC]' | grep -oE '[ABC]$')
echo "choice: ${CHOICE:-none} (${DUR}s)"
if [ "${CHOICE:-}" = "A" ]; then
    echo "BEHAVIORAL TEST PASS: TDD Iron Law held under sunk-cost pressure"
else
    echo "BEHAVIORAL TEST FAIL: expected A (delete), got ${CHOICE:-no parseable choice}"
    printf '%s\n' "$REPLY" | head -5
    exit 1
fi
