#!/usr/bin/env bash
# shellcheck disable=SC2034 # sourced by qgate.sh; policy variables are consumed there.
# Quality gate policy. Machinery lives in qgate.sh; this file is the policy.
# Raising a threshold is a normal commit. Lowering one needs a reason in the
# commit message: it is the cheapest way to make a red gate green without
# fixing anything.

STACKS="shell"

COVERAGE_CHANGED_MIN=80
COVERAGE_TOTAL_MIN=70
MUTATION_CHANGED_MIN=70
COMPLEXITY_MAX=10
FUNCTION_LINES_MAX=50
FILE_LINES_MAX=400
FUZZ_SMOKE_SECONDS=30
FUZZ_DEEP_SECONDS=900
FUZZ_CASE_TIMEOUT_SECONDS=5
LANE_TIMEOUT_SECONDS=120
LANE_OUTPUT_BYTES=12000
T2_TIMEOUT_MINUTES=15
SEVERITY_FAIL=high

# EARS: requirement lines in these paths must match an EARS pattern.
# Patterns: ubiquitous / event-driven (When) / state-driven (While) /
# unwanted (If..then) / optional (Where).
EARS_PATHS="docs/dmj/specs docs/specs specs"
EARS_ENFORCE=1

# ASD-STE100: ACTIVE for AI-authored prose, user law. The aerospace dictionary
# flags ordinary software terms: grow STE_ALLOWLIST per repo, waive legacy
# human-written docs with dated waivers, never disable the lane. Sentence
# limits are commonly cited defaults; calibrate against Issue 9
# (asd-ste100.org) when tuning.
STE_ENFORCE=1
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
# 2026-08-23: policy and reference text is excluded from primitive detection;
# runtime hooks and scripts remain scanned because they are not listed here.
# shellcheck disable=SC2034 # qgate.sh consumes this sourced gate policy.
CRYPTO_REFERENCE_PATHS="CHANGELOG.md docs/dmj/specs/2026-07-29-claude5-then-now-pass-design.md docs/dmj/specs/2026-07-29-opus5-context-audit.md scripts/validate.js skills/defending-in-depth/SKILL.md skills/defending-in-depth/quantum-durable-crypto.md skills/enforcing-quality-gates/install-gate.sh qgate.sh"
# Primitives that are never acceptable in new code.
CRYPTO_BANNED="md5 sha1 bcrypt scrypt RC4 3DES ECB"

# Waivers: "lane:reason:YYYY-MM-DD". Printed on every run so they cannot rot
# quietly. A waived lane is reported WAIVED, never PASS.
WAIVERS="types:no typed language in this repository:2026-08-23 coverage:kcov has no supported local Windows path for this required gate:2026-08-23 complexity:no stable shell complexity rule; review retains the cap:2026-08-23 deps:no dependency manifest or third-party runtime package graph:2026-08-23"
