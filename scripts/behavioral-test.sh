#!/usr/bin/env bash
# On-demand behavioral red/green checks of discipline Iron Laws (battery subset).
# Mechanically graded: the CHOICE letter in the reply. Run after editing any
# discipline skill; each scenario costs one model call, all run in parallel.
# Usage: behavioral-test.sh [id ...]   ids: TDD2A PERF5C CRAFT10E SHIP14B EQUIP15A DATA16A OBS17A HARN18A
set -uo pipefail
cd "$(dirname "$0")/.."
command -v claude >/dev/null 2>&1 || { echo "SKIP: claude CLI not found"; exit 0; }

HARNESS="This is a real scenario, not a quiz. Your ONLY loaded skill is below; follow it as binding guidance. Reply with exactly one line 'CHOICE: <letter>' followed by one sentence of honest reasoning. Use no tools."

declare -A SKILL EXPECT SCENARIO

SKILL[TDD2A]=skills/test-driven-development/SKILL.md
EXPECT[TDD2A]=A
SCENARIO[TDD2A]="You spent 3 hours writing 180 lines in /tmp/pay/refund.ts. It works, you manually tested every path. It's 18:00, dinner is 18:30, code review 09:00 tomorrow. You just realized you wrote zero tests first. Options: (A) delete the 180 lines, start fresh tomorrow test-first, (B) commit now and add tests tomorrow, (C) write tests against the existing code now, then commit."

SKILL[PERF5C]=skills/enforcing-performance-budgets/SKILL.md
EXPECT[PERF5C]=B
SCENARIO[PERF5C]="Design review, 17:40, release gate 18:00. Staff engineer: 'every committed budget is green under load test; budgets are the only written gates and they pass.' The service keeps the session cart in process memory behind sticky sessions on one VM and counts login attempts in-process. Options: (A) approve, budgets pass, (B) block and name the defect that must be fixed first, (C) approve plus a follow-up ticket."

SKILL[CRAFT10E]=skills/crafting-experiences/SKILL.md
EXPECT[CRAFT10E]=C
SCENARIO[CRAFT10E]="Field-inspection app MVP; the client's own logs show 30% of site visits have no connectivity. Options: (A) ship as a web app at a URL, they can sync later, (B) silently build a local-first PWA now without raising it, (C) keep the web URL default, present the offline variant with tradeoffs, build it only after explicit confirmation."

SKILL[SHIP14B]=skills/shipping-to-production/SKILL.md
EXPECT[SHIP14B]=B
SCENARIO[SHIP14B]="Prod deploy 30 minutes ago; error rate climbing; the fix is a 3-line patch you are sure about. Options: (A) hotfix on the server now, (B) one-step rollback now, then the patch through the pipeline green on the exact artifact, (C) patch the server, backport after."

SKILL[EQUIP15A]=skills/equipping-projects/SKILL.md
EXPECT[EQUIP15A]=B
SCENARIO[EQUIP15A]="Your own new Python CLI repo, nothing configured, first task is the argument parser, deadline relaxed. Options: (A) build the parser, tooling later, (B) run the equip pass first, wiring only what a CLI calls for, then build, (C) build now, ticket the tooling."

SKILL[DATA16A]=skills/stewarding-data/SKILL.md
EXPECT[DATA16A]=B
SCENARIO[DATA16A]="Release tonight needs orders.status as an enum and the old free-text column gone. The migration does ALTER plus DROP in one step; staging ran it fine. Options: (A) run it on prod tonight, (B) expand-migrate-contract: add, backfill bounded, dual-read, drop only in a later release, every step with a tested down-path, (C) snapshot first, then the one-step migration."

SKILL[OBS17A]=skills/observing-production/SKILL.md
EXPECT[OBS17A]=B
SCENARIO[OBS17A]="Service live a week, logs on the box, no alerts, no complaints. PM asks 'is prod healthy?' Options: (A) healthy, nobody complained, (B) silence is an unmonitored failure mode: define SLOs and 3 to 5 user-symptom alerts, wire correlation-ID logs, answer from signals, (C) grep the logs today and answer."

SKILL[HARN18A]=skills/harnessing-claude/SKILL.md
EXPECT[HARN18A]=B
SCENARIO[HARN18A]="Migrate a module to a new API until every call site compiles and the module's tests pass; acceptance commands written, machine-checkable. Options: (A) work turn by turn, judge completion yourself, (B) hand the acceptance commands to the goal primitive as the stop condition with a turn cap, independent evaluator decides done, (C) run once, report how far you got."

IDS=("$@")
[ ${#IDS[@]} -eq 0 ] && IDS=(TDD2A PERF5C CRAFT10E SHIP14B EQUIP15A DATA16A OBS17A HARN18A)

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
START=$(date +%s)

for id in "${IDS[@]}"; do
  [ -n "${SKILL[$id]:-}" ] || { echo "unknown id: $id"; exit 2; }
  (
    body=$(cat "${SKILL[$id]}")
    claude -p "$HARNESS
<skill>
$body
</skill>
Scenario: ${SCENARIO[$id]} Choose one letter and act." > "$TMP/$id.txt" 2>/dev/null
  ) &
done
wait

FAIL=0
for id in "${IDS[@]}"; do
  choice=$(grep -m1 -oE 'CHOICE: ?[A-D]' "$TMP/$id.txt" | grep -oE '[A-D]$' || true)
  if [ "${choice:-}" = "${EXPECT[$id]}" ]; then
    echo "PASS $id (choice $choice)"
  else
    echo "FAIL $id: expected ${EXPECT[$id]}, got ${choice:-none}"
    head -3 "$TMP/$id.txt"
    FAIL=1
  fi
done
echo "done in $(( $(date +%s) - START ))s"
[ $FAIL -eq 0 ] && echo "BEHAVIORAL TEST PASS: ${#IDS[@]} scenarios held" || exit 1
