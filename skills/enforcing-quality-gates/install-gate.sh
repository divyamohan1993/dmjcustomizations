#!/usr/bin/env bash
# install-gate.sh - generate a repo's own quality gate.
#
# Usage: bash install-gate.sh [target-repo]   (default: cwd)
#
# Detects the stack, writes FOUR files into the target repo: qgate.sh,
# qgate.config.sh, .qgate-lanes.sh, and .github/workflows/qgate.yml, then
# prints a WIRED/UNAVAILABLE report per lane. Idempotent: an existing
# qgate.config.sh is preserved (your thresholds and waivers are yours);
# qgate.sh and .qgate-lanes.sh are regenerated because they are machinery,
# not policy.
#
# Design notes worth keeping when editing this:
#   - Runner is static, config is generated. Policy stays diffable.
#   - A missing tool is UNAVAILABLE, never a silent pass. See qgate.sh.
#   - Mutation and deep fuzz are T3 only. Putting them in the pre-commit path
#     is how gates get disabled, and a disabled gate still reads as green.
set -uo pipefail
TARGET="${1:-.}"
cd "$TARGET" || { echo "no such directory: $TARGET" >&2; exit 1; }
REPO=$(pwd)
echo "Installing quality gate into: $REPO"
echo

# ---------------------------------------------------------------- detection --
STACKS=""
add() { case " $STACKS " in *" $1 "*) ;; *) STACKS="$STACKS $1" ;; esac; }
[ -f package.json ]      && add node
[ -f tsconfig.json ]     && add ts
[ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ] && add python
[ -f Cargo.toml ]        && add rust
[ -f go.mod ]            && add go
[ -f pom.xml ] || [ -f build.gradle ] || [ -f build.gradle.kts ] && add jvm
[ -f composer.json ]     && add php
# compgen per pattern: `ls -- a b` exits nonzero if EITHER glob misses, which
# silently dropped whole stacks (this repo detected none of its own shell).
globs() { for g in "$@"; do compgen -G "$g" >/dev/null 2>&1 && return 0; done; return 1; }
globs '*.csproj' '*.sln' && add dotnet
globs '*.sh' 'scripts/*.sh' 'hooks/*.sh' 'hooks/*' && add shell
STACKS="${STACKS# }"
[ -n "$STACKS" ] || STACKS="unknown"
echo "Detected stack(s): $STACKS"

have() { command -v "$1" >/dev/null 2>&1; }
pm() { if [ -f pnpm-lock.yaml ]; then echo pnpm; elif [ -f yarn.lock ]; then echo yarn; else echo npm; fi; }

# --------------------------------------------------------- per-lane commands --
# Lanes are stored PER STACK (L_<LANE>_<stack>) and the runner executes every
# populated stack's command for each slot. A polyglot repo runs every matched
# stack's suite; the last-detected stack must never clobber the others, and
# each command keeps its own tool_present verdict (concatenating with && would
# turn one stack's missing tool into another stack's FAIL).
LANE_SLOTS="FMT LINT TYPES UNIT UNIT_CHANGED ACCEPT COVERAGE MUTATION COMPLEXITY FUZZ_SMOKE FUZZ_DEEP SECRETS SAST DEPS DAST"
setlane() { eval "L_$1_$2=\$3"; }   # setlane <SLOT> <stack> <command>

for s in $STACKS; do case "$s" in
  node|ts)
    P=$(pm)
    setlane FMT node "$P exec prettier --check ."
    setlane LINT node "$P exec eslint ."
    [ "$s" = ts ] && setlane TYPES node "$P exec tsc --noEmit"
    setlane UNIT node "$P exec vitest run"
    setlane UNIT_CHANGED node "$P exec vitest run --changed"
    setlane ACCEPT node "$P exec cucumber-js"
    setlane COVERAGE node "$P exec vitest run --coverage"
    setlane MUTATION node "$P exec stryker run"
    setlane COMPLEXITY node "$P exec eslint . --rule '{\"complexity\":[\"error\",\$COMPLEXITY_MAX],\"max-lines-per-function\":[\"error\",\$FUNCTION_LINES_MAX],\"max-lines\":[\"error\",\$FILE_LINES_MAX]}'"
    setlane FUZZ_SMOKE node "$P exec vitest run fuzz/"
    setlane DEPS node "$P audit --audit-level=high"
    ;;
  python)
    setlane FMT python "ruff format --check ."
    setlane LINT python "ruff check ."
    setlane UNIT python "pytest -q"
    setlane ACCEPT python "pytest -q --bdd"
    setlane COVERAGE python "pytest --cov --cov-fail-under=\$COVERAGE_TOTAL_MIN"
    setlane MUTATION python "mutmut run"
    setlane COMPLEXITY python "radon cc -n C -s ."
    setlane FUZZ_SMOKE python "pytest -q tests/property"
    setlane SAST python "bandit -r . -ll"
    setlane DEPS python "pip-audit"
    ;;
  rust)
    setlane FMT rust "cargo fmt --check"
    setlane LINT rust "cargo clippy -- -D warnings"
    setlane UNIT rust "cargo test"
    setlane COVERAGE rust "cargo llvm-cov --fail-under-lines \$COVERAGE_TOTAL_MIN"
    setlane MUTATION rust "cargo mutants"
    setlane FUZZ_SMOKE rust "cargo test --test proptest"
    setlane FUZZ_DEEP rust "cargo fuzz run fuzz_target_1 -- -max_total_time=\$FUZZ_DEEP_SECONDS"
    setlane DEPS rust "cargo audit"
    ;;
  go)
    setlane FMT go "gofmt -l ."
    setlane LINT go "golangci-lint run"
    setlane UNIT go "go test ./..."
    setlane COVERAGE go "go test ./... -coverprofile=coverage.out"
    setlane FUZZ_SMOKE go "go test ./... -run Fuzz -fuzztime=\${FUZZ_SMOKE_SECONDS}s"
    setlane FUZZ_DEEP go "go test ./... -run Fuzz -fuzz=Fuzz -fuzztime=\${FUZZ_DEEP_SECONDS}s"
    setlane SAST go "gosec ./..."
    setlane DEPS go "govulncheck ./..."
    ;;
  jvm)    setlane UNIT jvm "mvn -q test"; setlane COVERAGE jvm "mvn -q jacoco:report"; setlane MUTATION jvm "mvn -q org.pitest:pitest-maven:mutationCoverage"; setlane DEPS jvm "mvn -q org.owasp:dependency-check-maven:check" ;;
  php)    setlane UNIT php "phpunit"; setlane ACCEPT php "behat"; setlane MUTATION php "infection"; setlane COMPLEXITY php "phpmd . text codesize"; setlane DEPS php "composer audit" ;;
  dotnet) setlane UNIT dotnet "dotnet test"; setlane MUTATION dotnet "dotnet stryker"; setlane DEPS dotnet "dotnet list package --vulnerable" ;;
  shell)
    setlane LINT shell "shellcheck \$(git ls-files '*.sh' 2>/dev/null || find . -name '*.sh')"
    setlane UNIT shell "bats tests"
    setlane FUZZ_SMOKE shell "bash scripts/fuzz-*.sh"
    ;;
esac; done

# Stack-agnostic lanes ride a synthetic "common" stack. These are why an
# unfamiliar repo still gets a real gate.
QG_STACKS="$STACKS"
case " $QG_STACKS " in *" common "*) ;; *) QG_STACKS="$QG_STACKS common" ;; esac
have gitleaks && setlane SECRETS common "gitleaks detect --no-banner --redact"
have semgrep  && setlane SAST common "semgrep --error --config=auto --quiet"
have trivy    && setlane DEPS common "trivy fs --exit-code 1 --severity HIGH,CRITICAL ."

# ------------------------------------------------------------------- config --
if [ -f qgate.config.sh ]; then
  echo "qgate.config.sh exists, preserving your thresholds and waivers."
else
  cat > qgate.config.sh <<CFG
#!/usr/bin/env bash
# Quality gate policy. Machinery lives in qgate.sh; this file is the policy.
# Raising a threshold is a normal commit. Lowering one needs a reason in the
# commit message: it is the cheapest way to make a red gate green without
# fixing anything.

STACKS="$STACKS"

COVERAGE_CHANGED_MIN=80
COVERAGE_TOTAL_MIN=70
MUTATION_CHANGED_MIN=70
COMPLEXITY_MAX=10
FUNCTION_LINES_MAX=50
FILE_LINES_MAX=400
FUZZ_SMOKE_SECONDS=30
FUZZ_DEEP_SECONDS=900
SEVERITY_FAIL=high

# EARS: requirement lines in these paths must match an EARS pattern.
# Patterns: ubiquitous / event-driven (When) / state-driven (While) /
# unwanted (If..then) / optional (Where).
EARS_PATHS="docs/dmj/specs docs/specs specs"
EARS_ENFORCE=1

# ASD-STE100: warn-only by decision. Sentence limits below are the commonly
# cited defaults and are NOT verified against Issue 9. Download Issue 9 from
# asd-ste100.org and calibrate before ever setting STE_ENFORCE=1.
STE_ENFORCE=0
STE_MAX_WORDS_PROCEDURAL=20
STE_MAX_WORDS_DESCRIPTIVE=25
STE_PATHS="README.md docs"
# Software terms STE's aerospace dictionary will flag. Grow this per repo.
STE_ALLOWLIST="webhook idempotent middleware serverless runtime API SDK CLI JSON YAML OAuth JWT"

# OWASP ASVS level asserted by the security lane.
ASVS_LEVEL=2

# Crypto lane. Algorithm names may appear ONLY inside these paths, so that
# swapping a primitive is one module's problem rather than a repo-wide grep.
CRYPTO_ENFORCE=1
CRYPTO_MODULE="src/crypto src/lib/crypto lib/crypto internal/crypto crypto"
# Primitives that are never acceptable in new code.
CRYPTO_BANNED="md5 sha1 bcrypt scrypt RC4 3DES ECB"

# Waivers: "lane:reason:YYYY-MM-DD". Printed on every run so they cannot rot
# quietly. A waived lane is reported WAIVED, never PASS.
WAIVERS=""
CFG
  echo "wrote qgate.config.sh"
fi

# ---------------------------------------------------- lane command manifest --
{
  echo "# Generated by install-gate.sh. Regenerate rather than hand-editing."
  printf 'QG_STACKS=%q\n' "$QG_STACKS"
  for slot in $LANE_SLOTS; do
    for s in $QG_STACKS; do
      eval "v=\${L_${slot}_${s}:-}"
      [ -n "$v" ] && printf 'L_%s_%s=%q\n' "$slot" "$s" "$v"
    done
  done
} > .qgate-lanes.sh
echo "wrote .qgate-lanes.sh"

# ------------------------------------------------------------------ runner --
# tool_present is defined ONCE here and injected verbatim into the generated
# runner, so the install report and the runner can never disagree about what
# counts as installed (a report that says WIRED where the runner says
# UNAVAILABLE sends people to debug the wrong thing).
TOOL_PRESENT_DEF='# Is the tool this lane needs actually present? A missing tool must report
# UNAVAILABLE, never FAIL: "you have not installed anything yet" and "your code
# is broken" are different states, and conflating them is how a red gate starts
# getting ignored. Probed at run time, not at generation time, so a lane starts
# working the moment its tool is installed, with no regeneration.
tool_present() {
  local cmd="$1"; set -- $cmd
  case "$1" in
    ears_check|ste_check|crypto_check) return 0 ;;         # shell functions
    pnpm|npm|yarn)
      command -v "$1" >/dev/null 2>&1 || return 1
      [ "${2:-}" = exec ] || return 0                      # e.g. "pnpm audit"
      # Check the local bin directly. `pnpm exec X --version` can resolve X
      # over the network, so it reports available for a package that is not
      # installed, and the lane then FAILs instead of reporting UNAVAILABLE.
      [ -x "node_modules/.bin/$3" ] || command -v "$3" >/dev/null 2>&1 ;;
    *) command -v "$1" >/dev/null 2>&1 ;;
  esac
}'

cat > qgate.sh <<'QGATE'
#!/usr/bin/env bash
# Quality gate runner. Generated by dmj:enforcing-quality-gates.
# Usage: bash qgate.sh [--fast|--merge|--deep]   (default --merge)
#
# A lane whose tool is missing reports UNAVAILABLE. --merge and --deep refuse
# to go green while any lane is UNAVAILABLE and unwaived, because a gate that
# silently skips is a gate that lies.
set -uo pipefail
cd "$(dirname "$0")"
. ./qgate.config.sh
if [ ! -f ./.qgate-lanes.sh ]; then
  echo "qgate: missing .qgate-lanes.sh (the generated lane manifest)." >&2
  echo "qgate: regenerate it: bash install-gate.sh" >&2
  exit 1
fi
. ./.qgate-lanes.sh
TIER="${1:---merge}"
FAILED=0; UNAVAIL=0; RAN=0

c_pass=$'\033[32m'; c_fail=$'\033[31m'; c_warn=$'\033[33m'; c_dim=$'\033[2m'; c_off=$'\033[0m'
[ -t 1 ] || { c_pass=; c_fail=; c_warn=; c_dim=; c_off=; }

waived() { case "$WAIVERS" in *"$1:"*) return 0 ;; *) return 1 ;; esac; }
QGATE
printf '%s\n' "$TOOL_PRESENT_DEF" >> qgate.sh
cat >> qgate.sh <<'QGATE'

lane() { # lane <name> <command> [warn-only]
  local name="$1" cmd="$2" warnonly="${3:-}"
  if [ -z "$cmd" ] || ! tool_present "$cmd"; then
    if waived "$name"; then printf '  %-14s %sWAIVED%s\n' "$name" "$c_warn" "$c_off"; return; fi
    local why="no tool wired for this stack"
    if [ -n "$cmd" ]; then
      # Name the tool that is actually missing. For "pnpm exec vitest run" the
      # missing thing is vitest, not pnpm, and saying pnpm sends people to fix
      # the wrong thing.
      set -- $cmd
      local missing="$1"; [ "${2:-}" = exec ] && missing="$3"
      why="not installed: $missing"
    fi
    printf '  %-14s %sUNAVAILABLE%s (%s)\n' "$name" "$c_warn" "$c_off" "$why"
    UNAVAIL=$((UNAVAIL+1)); return
  fi
  RAN=$((RAN+1))
  local out; out=$(eval "$cmd" 2>&1); local rc=$?
  if [ $rc -eq 0 ]; then
    printf '  %-14s %sPASS%s\n' "$name" "$c_pass" "$c_off"
  elif [ $rc -eq 77 ]; then
    # 77 = the check ran but found nothing in scope to verify. That is not a
    # pass; it is the same state as a missing tool.
    printf '  %-14s %sUNAVAILABLE%s (nothing in scope to check)\n' "$name" "$c_warn" "$c_off"
    RAN=$((RAN-1)); UNAVAIL=$((UNAVAIL+1))
  elif [ -n "$warnonly" ]; then
    printf '  %-14s %sWARN%s\n' "$name" "$c_warn" "$c_off"
    printf '%s\n' "$out" | sed 's/^/      /' | head -12
  else
    printf '  %-14s %sFAIL%s\n' "$name" "$c_fail" "$c_off"
    printf '%s\n' "$out" | sed 's/^/      /' | head -30
    FAILED=$((FAILED+1))
  fi
}

# slot <display> <SLOT> [warn-only]: run every stack's command for this slot.
# A polyglot repo runs every matched stack's lane; if no stack wired one, the
# slot reports a single UNAVAILABLE row.
slot() {
  local display="$1" slotname="$2" warnonly="${3:-}" any=0 s v
  for s in $QG_STACKS; do
    eval "v=\${L_${slotname}_${s}:-}"
    [ -n "$v" ] || continue
    any=1
    lane "$display($s)" "$v" $warnonly
  done
  [ $any = 1 ] || lane "$display" ""
}

# unit-chg falls back per stack to that stack's full unit suite.
slot_unit_changed() {
  local any=0 s v
  for s in $QG_STACKS; do
    eval "v=\${L_UNIT_CHANGED_${s}:-\${L_UNIT_${s}:-}}"
    [ -n "$v" ] || continue
    any=1
    lane "unit-chg($s)" "$v"
  done
  [ $any = 1 ] || lane "unit-chg" ""
}

# EARS: requirement lines must match an EARS pattern. Scoped to MARKED
# requirements only: lines inside a "## Requirements" section, or lines
# starting with "REQ-". Prose that happens to contain shall/must/should is
# not a requirement, and a lane that cries wolf gets switched off. A spec
# tree with no marked requirements returns 77 (UNAVAILABLE, never PASS):
# zero checked lines verified nothing.
ears_check() {
  [ "${EARS_ENFORCE:-0}" = 1 ] || return 0
  local bad=0 any=0 f line inreq isreq
  for d in $EARS_PATHS; do
    [ -d "$d" ] || continue
    while IFS= read -r f; do
      inreq=0
      while IFS= read -r line; do
        case "$line" in
          '## Requirements'*) inreq=1; continue ;;
          '#'*) inreq=0 ;;
        esac
        isreq=0
        [ $inreq = 1 ] && isreq=1
        case "$line" in REQ-*) isreq=1 ;; esac
        [ $isreq = 1 ] || continue
        printf '%s' "$line" | grep -qiE '\b(shall|must|should)\b' || continue
        any=1
        printf '%s' "$line" | grep -qiE '^[[:space:]]*(REQ-[A-Za-z0-9_.-]+:?[[:space:]]*)?[-*0-9.]*[[:space:]]*(The|When|While|If|Where|Once)\b' && continue
        echo "$f: not EARS: ${line:0:90}"; bad=1
      done < "$f"
    done < <(find "$d" -name '*.md' 2>/dev/null)
  done
  [ $any = 1 ] || return 77
  return $bad
}

# ASD-STE100: warn-only sentence-length heuristic with a domain allowlist.
ste_check() {
  local bad=0 f
  for p in $STE_PATHS; do
    [ -e "$p" ] || continue
    while IFS= read -r f; do
      awk -v maxw="$STE_MAX_WORDS_DESCRIPTIVE" -v file="$f" '
        /^```/ {inblock=!inblock} inblock {next}
        {
          n=split($0, s, /[.!?]/)
          for (i=1;i<=n;i++) { w=split(s[i], junk, /[ \t]+/); if (w>maxw) { print file ": " w " words: " substr(s[i],1,70); bad=1 } }
        } END {exit bad}' "$f" || bad=1
    done < <(find "$p" -name '*.md' 2>/dev/null)
  done
  return $bad
}

# Crypto: banned primitives anywhere, algorithm names outside the crypto module,
# and unseeded randomness in security-relevant files. Grep-based and therefore
# blunt, so it is scoped tightly: a lane that cries wolf gets switched off.
crypto_check() {
  [ "${CRYPTO_ENFORCE:-0}" = 1 ] || return 0
  local bad=0 files hit
  # Exclude the gate's own files. They contain every banned primitive and every
  # algorithm name by construction, as the rule definitions, and a linter that
  # flags its own ruleset reports a permanent false positive that masks the real
  # ones underneath it.
  files=$(git ls-files 2>/dev/null \
    | grep -Ev '(^|/)(test|tests|spec|__tests__|vendor|node_modules)/' \
    | grep -Ev '(^|/)(qgate\.sh|qgate\.config\.sh|\.qgate-lanes\.sh)$' || true)
  [ -n "$files" ] || return 0

  for p in $CRYPTO_BANNED; do
    hit=$(printf '%s\n' "$files" | xargs grep -lniE "(createHash|hashlib|Digest|hmac|password_hash|import|require)[^\n]{0,40}\b$p\b" 2>/dev/null || true)
    [ -n "$hit" ] && { echo "banned primitive '$p': $(printf '%s' "$hit" | tr '\n' ' ')"; bad=1; }
  done

  # Algorithm literals outside the crypto module: the thing that makes a
  # future migration a repo-wide edit instead of a one-file change.
  local outside
  outside=$(printf '%s\n' "$files" | grep -Ev "^($(printf '%s' "$CRYPTO_MODULE" | tr ' ' '|'))/" || true)
  if [ -n "$outside" ]; then
    hit=$(printf '%s\n' "$outside" | xargs grep -lnE "\b(aes-256-gcm|AES_256_GCM|AEGIS|ML-KEM|ML_KEM|ML-DSA|SLH-DSA|X25519|RSA-OAEP|PBKDF2|HKDF)\b" 2>/dev/null || true)
    [ -n "$hit" ] && { echo "algorithm name outside crypto module: $(printf '%s' "$hit" | tr '\n' ' ')"; bad=1; }
  fi

  # Non-cryptographic randomness in files that name a security concern.
  hit=$(printf '%s\n' "$files" | grep -iE '(token|secret|key|nonce|salt|session|auth)' \
        | xargs grep -lnE '(Math\.random\(\)|[^a-z_]rand\(\)|random\.random\(\))' 2>/dev/null || true)
  [ -n "$hit" ] && { echo "non-crypto randomness in security file: $(printf '%s' "$hit" | tr '\n' ' ')"; bad=1; }

  return $bad
}

echo "Quality gate: $TIER   stacks: $STACKS"
[ -n "$WAIVERS" ] && printf '%sactive waivers: %s%s\n' "$c_warn" "$WAIVERS" "$c_off"
echo

echo "T1 fast"
slot format   FMT
slot lint     LINT
slot types    TYPES
slot secrets  SECRETS
slot_unit_changed

if [ "$TIER" = --merge ] || [ "$TIER" = --deep ]; then
  echo
  echo "T2 merge"
  slot unit       UNIT
  slot acceptance ACCEPT
  slot coverage   COVERAGE
  slot complexity COMPLEXITY
  lane ears       "ears_check"
  lane crypto     "crypto_check"
  slot sast       SAST
  slot deps       DEPS
  slot fuzz-smoke FUZZ_SMOKE
  lane ste        "ste_check" warn
fi

if [ "$TIER" = --deep ]; then
  echo
  echo "T3 deep"
  slot mutation  MUTATION
  slot fuzz-deep FUZZ_DEEP
  slot dast      DAST
  echo
  echo "  ASVS L${ASVS_LEVEL}: verify the checklist in docs/security/asvs-l${ASVS_LEVEL}.md"
  echo "  ${c_dim}(machine lanes above cover part of it; the rest is a reviewed checklist)${c_off}"
fi

echo
echo "------------------------------------------------------------"
if [ $FAILED -gt 0 ]; then
  printf '%sGATE RED%s: %d lane(s) failed, %d ran\n' "$c_fail" "$c_off" "$FAILED" "$RAN"; exit 1
fi
# A gate that ran nothing has verified nothing. Reporting GREEN here would be
# the exact lie this gate exists to prevent, so it is never a pass at any tier.
if [ $RAN -eq 0 ]; then
  printf '%sNOTHING VERIFIED%s: 0 lanes ran. Install a tool or waive explicitly; this is not a pass.\n' "$c_fail" "$c_off"; exit 3
fi
if [ "$TIER" != --fast ] && [ $UNAVAIL -gt 0 ]; then
  printf '%sGATE NOT GREEN%s: %d lane(s) UNAVAILABLE. Wire the tool or add a dated waiver.\n' "$c_warn" "$c_off" "$UNAVAIL"; exit 2
fi
printf '%sGATE GREEN%s: %d lane(s) passed, %d unavailable\n' "$c_pass" "$c_off" "$RAN" "$UNAVAIL"
QGATE
chmod +x qgate.sh 2>/dev/null || true
echo "wrote qgate.sh"

# ----------------------------------------------------------------------- CI --
mkdir -p .github/workflows 2>/dev/null
if [ ! -f .github/workflows/qgate.yml ]; then
  cat > .github/workflows/qgate.yml <<'CI'
name: quality-gate
on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: '17 3 * * *'   # nightly T3
jobs:
  gate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }   # secrets lane scans full history
      - name: Run quality gate
        run: |
          tier=--merge
          [ "${{ github.event_name }}" = schedule ] && tier=--deep
          bash qgate.sh "$tier"
CI
  echo "wrote .github/workflows/qgate.yml"
fi

# -------------------------------------------------------------------- report --
echo
printf '%-20s %s\n' "LANE" "STATUS"
# The EXACT probe the runner uses (injected from the same definition above), so
# this report can never claim a lane is ready when the runner would report it
# UNAVAILABLE.
eval "$TOOL_PRESENT_DEF"
report_slot() { # report_slot <display> <SLOT>
  local display="$1" slotname="$2" any=0 s v
  for s in $QG_STACKS; do
    eval "v=\${L_${slotname}_${s}:-}"
    [ -n "$v" ] || continue
    any=1
    if tool_present "$v"; then printf '%-20s WIRED        %s\n' "$display($s)" "${v:0:40}"
    else printf '%-20s NEEDS INSTALL  %s\n' "$display($s)" "${v:0:38}"; fi
  done
  [ $any = 1 ] || printf '%-20s UNAVAILABLE  (no tool for this stack)\n' "$display"
}
report_slot format FMT;         report_slot lint LINT;       report_slot types TYPES
report_slot unit UNIT;          report_slot acceptance ACCEPT
report_slot coverage COVERAGE;  report_slot complexity COMPLEXITY
report_slot mutation MUTATION;  report_slot fuzz-smoke FUZZ_SMOKE
report_slot fuzz-deep FUZZ_DEEP; report_slot secrets SECRETS
report_slot sast SAST;          report_slot deps DEPS;       report_slot dast DAST
echo
echo "Next:"
echo "  1. Install any UNAVAILABLE tool, or add a dated waiver in qgate.config.sh."
echo "  2. Write features/*.feature before the next implementation task."
echo "  3. bash qgate.sh --merge"
