#!/usr/bin/env bash
# Bisection: find which test creates an unwanted file/state (shared-state pollution).
# Usage:   ./find-polluter.sh <path_to_check> <test_glob>
# Example: ./find-polluter.sh '.git' 'src/**/*.test.ts'
# Override the runner if not npm:  TEST_CMD='pnpm vitest run' ./find-polluter.sh ...

set -e

if [ $# -ne 2 ]; then
  echo "Usage: $0 <path_to_check> <test_glob>"
  echo "Example: $0 '.git' 'src/**/*.test.ts'"
  exit 1
fi

POLLUTION_CHECK="$1"
TEST_PATTERN="$2"
TEST_CMD="${TEST_CMD:-npm test}"   # newest stable runner for the project; override via env

echo "Searching for the test that creates: $POLLUTION_CHECK"
echo "Test glob: $TEST_PATTERN   Runner: $TEST_CMD"
echo ""

TEST_FILES=$(find . -path "$TEST_PATTERN" | sort)
TOTAL=$(echo "$TEST_FILES" | wc -l | tr -d ' ')
echo "Found $TOTAL test files"
echo ""

COUNT=0
for TEST_FILE in $TEST_FILES; do
  COUNT=$((COUNT + 1))

  if [ -e "$POLLUTION_CHECK" ]; then
    echo "Pollution already exists before test $COUNT/$TOTAL; skipping $TEST_FILE"
    continue
  fi

  echo "[$COUNT/$TOTAL] $TEST_FILE"
  $TEST_CMD "$TEST_FILE" > /dev/null 2>&1 || true

  if [ -e "$POLLUTION_CHECK" ]; then
    echo ""
    echo "FOUND POLLUTER: $TEST_FILE created $POLLUTION_CHECK"
    ls -la "$POLLUTION_CHECK"
    echo "Investigate:  $TEST_CMD $TEST_FILE   (run alone)"
    exit 1
  fi
done

echo ""
echo "No polluter found; all tests clean."
exit 0
