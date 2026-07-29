#!/usr/bin/env bash
# Adversarial evasion + fuzz suite for hooks/pre-tool-guard.
#
# The guard is a SECURITY control: it decides whether history-destroying git
# commands execute, and it fails OPEN. A regex that can be walked around is
# worse than no guard, because it buys false confidence. This suite attacks it.
#
# Why the corpus lives in this file rather than on a command line: the guard
# inspects every Bash tool call, so a test harness that passes payloads as
# arguments gets blocked by the very control it is testing. Payloads are data.
#
# Verdict classes:
#   deny  - guard MUST block this
#   allow - guard MUST NOT block this (false-positive regression)
#   gap   - documented, accepted limit of string matching. Asserted so that a
#           change in either direction shows up instead of passing silently.
set -uo pipefail
cd "$(dirname "$0")/.."
G=hooks/pre-tool-guard
FAIL=0; N=0; GAPS=0

verdict() { # -> "deny" | "allow"
  local out
  out=$(printf '%s' "$1" | DMJ_ALLOW= bash "$G" 2>/dev/null)
  if printf '%s' "$out" | grep -q '"permissionDecision":"deny"'; then echo deny; else echo allow; fi
}

check() { # check <class> <name> <json>
  local want="$1" name="$2" json="$3" got
  N=$((N+1))
  got=$(verdict "$json")
  case "$want" in
    gap)
      GAPS=$((GAPS+1))
      if [ "$got" = allow ]; then echo "  GAP   $name (known limit, still open)"
      else echo "  GAP*  $name (now caught - tighten the doc)"; fi ;;
    *)
      if [ "$got" = "$want" ]; then echo "  ok    $name"
      else echo "  FAIL  $name: wanted $want, got $got"; FAIL=1; fi ;;
  esac
}

j() { # j <command-string-as-json-body> -> full hook payload
  printf '{"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"
}

echo "== 1. baseline: the three laws still hold =="
check deny  "force push long"        "$(j 'git push --force origin main')"
check deny  "force push short"       "$(j 'git push -f')"
check deny  "no-verify commit"       "$(j 'git commit -m x --no-verify')"
check deny  "hard reset origin"      "$(j 'git reset --hard origin/main')"
check deny  "hard reset upstream"    "$(j 'git reset --hard @{u}')"
check allow "force-with-lease"       "$(j 'git push --force-with-lease origin main')"
check allow "plain push"             "$(j 'git push origin main')"
check allow "local hard reset"       "$(j 'git reset --hard HEAD~1')"
check allow "unrelated rm"           "$(j 'rm -rf node_modules')"
check allow "verify substring"       "$(j 'echo no-verifying-here && git status')"

echo
echo "== 2. encoding evasion: harness decodes, guard must too =="
# Claude Code JSON-decodes before executing. Anything the guard fails to decode
# is a command it inspects in a different form than the one that runs.
B='\'        # single literal backslash, so payloads carry real \uXXXX escapes
check deny "unicode-escaped --force"     "$(j "git push ${B}u002d${B}u002dforce origin main")"
check deny "unicode-escaped --no-verify" "$(j "git commit -m x ${B}u002d${B}u002dno-verify")"
check deny "unicode-escaped git"         "$(j "${B}u0067it push ${B}u002d${B}u002dforce origin main")"
check deny "escaped forward slash"       "$(j "git reset --hard origin${B}/main")"

echo
echo "== 3. structural evasion: which \"command\" does the guard read? =="
# The harness reads tool_input.command. A guard that greps the first "command"
# anywhere reads whichever the attacker puts first.
check deny "decoy in sibling field" '{"tool_name":"Bash","description":"safe command: ls","tool_input":{"command":"git push --force origin main"}}'
check deny "decoy nested json str"  '{"tool_name":"Bash","description":"{\"command\":\"ls -la\"}","tool_input":{"command":"git push --force origin main"}}'
check deny "decoy before tool_input" '{"command":"echo hello","tool_name":"Bash","tool_input":{"command":"git push -f origin main"}}'
check deny "whitespace in key"      '{"tool_name":"Bash","tool_input":{ "command" : "git push --force origin main" }}'

echo
echo "== 4. lexical evasion =="
check deny "uppercase GIT"          "$(j 'GIT push --force origin main')"
check deny "mixed case Git"         "$(j 'Git push --force origin main')"
check deny "absolute path git"      "$(j '/usr/bin/git push --force origin main')"
check deny "git.exe"                "$(j 'git.exe push --force origin main')"
check deny "tab separated"          "$(j 'git\tpush\t--force')"
check deny "repeated spaces"        "$(j 'git    push     --force')"
check deny "-c flag before push"    "$(j 'git -c core.pager=cat push --force origin main')"
check deny "force=true"             "$(j 'git push --force=true origin main')"
check deny "env prefix"             "$(j 'GIT_DIR=.git git push --force')"
check deny "sudo prefix"            "$(j 'sudo git push --force origin main')"

echo
echo "== 5. accepted limits of string matching (documented, not fixed) =="
# No regex over a command string can resolve what the shell will expand.
# These are why the guard is defense in depth and not the only line.
check gap "command substitution"  "$(j 'git push $(echo --force) origin main')"
check gap "variable indirection"  "$(j 'F=--force; git push $F origin main')"
check gap "backtick substitution" "$(j 'git push `echo --force` origin main')"
check gap "base64 pipeline"       "$(j 'echo Z2l0IHB1c2ggLWY= | base64 -d | sh')"
check gap "git alias"             "$(j 'g push --force origin main')"

echo
echo "== 6. structural fuzz: never crash, never emit malformed JSON =="
fuzzcase() { # fuzzcase <name> <payload>
  local name="$1" payload="$2" out rc
  N=$((N+1))
  out=$(printf '%s' "$payload" | DMJ_ALLOW= timeout 10 bash "$G" 2>/dev/null); rc=$?
  if [ $rc -ge 124 ]; then echo "  FAIL  $name: hung (rc=$rc)"; FAIL=1; return; fi
  if [ $rc -ne 0 ]; then echo "  FAIL  $name: nonzero exit $rc"; FAIL=1; return; fi
  if [ -n "$out" ] && ! printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{JSON.parse(s);process.exit(0)}catch{process.exit(1)}})' 2>/dev/null; then
    echo "  FAIL  $name: emitted malformed JSON"; FAIL=1; return
  fi
  echo "  ok    $name"
}
fuzzcase "empty input"        ''
fuzzcase "not json"           'hello world'
fuzzcase "truncated json"     '{"tool_input":{"command":"git pu'
fuzzcase "null bytes"         "$(printf '{"tool_input":{"command":"git\x00 push"}}')"
fuzzcase "deep nesting"       "$(python -c 'print("{\"a\":"*200 + "1" + "}"*200)' 2>/dev/null || echo '{}')"
fuzzcase "huge command"       "$(j "$(head -c 100000 /dev/zero | tr '\0' 'a')")"
fuzzcase "many quotes"        '{"tool_input":{"command":"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\""}}'
fuzzcase "unterminated esc"   '{"tool_input":{"command":"git push \\'
fuzzcase "unicode soup"       "$(j 'git push 😀🔥 --force')"
fuzzcase "crlf"               "$(j 'git push\r\n--force')"

echo
echo "== 7. mutation fuzz: dangerous cores under mechanical mutation =="
# Each mutation preserves what the shell would execute; the guard must still deny.
CORES=('git push --force origin main' 'git commit -m x --no-verify' 'git reset --hard origin/main')
mutate() { # mutate <n> <cmd>
  case "$1" in
    0) printf '%s' "$2" ;;
    1) printf '  %s  ' "$2" ;;
    2) printf '%s' "$2" | sed 's/ /  /g' ;;
    3) printf 'true && %s' "$2" ;;
    4) printf '%s' "$2" | sed 's/^git/\/usr\/bin\/git/' ;;
    5) printf 'env FOO=bar %s' "$2" ;;
    6) printf '%s' "$2" | sed 's/^git/GIT/' ;;
    7) printf '%s' "$2" | sed 's/ /\\t/g' ;;
  esac
}
for core in "${CORES[@]}"; do
  for m in 0 1 2 3 4 5 6 7; do
    payload=$(mutate "$m" "$core")
    check deny "mut$m: ${payload:0:44}" "$(j "$payload")"
  done
done

echo
echo "-------------------------------------------------------------"
if [ $FAIL -eq 0 ]; then
  echo "FUZZ PASS: $N cases, 0 evasions, $GAPS documented limits"
else
  echo "FUZZ FAIL: evasions found above. The guard is bypassable."
  exit 1
fi
