#!/usr/bin/env bats

@test "native hook compatibility fixture passes" {
  run node scripts/test-hook-compatibility.mjs
  [ "$status" -eq 0 ]
  [[ "$output" == "HOOK COMPATIBILITY PASS: "* ]]
}
