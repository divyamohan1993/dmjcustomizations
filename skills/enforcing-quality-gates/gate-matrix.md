# Gate Matrix

Per-stack tools per lane. `install-gate.sh` picks every matched stack's rows and writes the commands into `.qgate-lanes.sh` (thresholds and waivers go to `qgate.config.sh`). "none stable" = the lane reports UNAVAILABLE for that stack rather than pretending to pass.

## Contents
- Detection
- Unit + coverage
- Acceptance (Gherkin)
- Mutation
- Complexity + size caps
- Fuzz
- Security
- Thresholds file

## Detection

| Signal | Stack |
|---|---|
| `package.json` | node (TS if `tsconfig.json`) |
| `pyproject.toml`, `requirements.txt`, `setup.py` | python |
| `Cargo.toml` | rust |
| `go.mod` | go |
| `pom.xml`, `build.gradle`, `build.gradle.kts` | jvm |
| `composer.json` | php |
| `*.csproj`, `*.sln` | dotnet |
| none of the above, `*.sh` present | shell |

A repo can match more than one. Run every matched stack's lanes; a polyglot repo is not an excuse to gate only the biggest language.

## Unit + coverage

| Stack | Unit | Coverage |
|---|---|---|
| node | `vitest run` or `jest` | `vitest run --coverage` (v8/istanbul), `c8` |
| python | `pytest` | `pytest --cov` (coverage.py) |
| rust | `cargo test` | `cargo llvm-cov` |
| go | `go test ./...` | `go test -coverprofile` |
| jvm | JUnit 5 via maven/gradle | JaCoCo |
| php | `phpunit` | phpunit `--coverage-text` (xdebug/pcov) |
| dotnet | `dotnet test` | coverlet |
| shell | `bats` | `kcov` |

## Acceptance (Gherkin)

| Stack | Runner |
|---|---|
| node | `@cucumber/cucumber` |
| python | `pytest-bdd` or `behave` |
| rust | `cucumber` crate |
| go | `godog` |
| jvm | Cucumber-JVM |
| php | `Behat` |
| dotnet | `Reqnroll` (SpecFlow's maintained successor) |
| shell | `bats` with `@test` names written as scenarios |

Feature files live in `features/`, written before implementation.

## Mutation

| Stack | Tool |
|---|---|
| node | `@stryker-mutator/core` |
| python | `mutmut` or `cosmic-ray` |
| rust | `cargo-mutants` |
| go | `gremlins` or `go-mutesting` |
| jvm | `PIT` (pitest), the reference implementation |
| php | `Infection` |
| dotnet | `Stryker.NET` |
| shell | none stable, report UNAVAILABLE |

Scope mutation to changed files in T3, always. Whole-repo mutation on a mature codebase runs for hours, then gets switched off.

## Complexity + size caps

| Stack | Tool |
|---|---|
| node | ESLint `complexity`, `max-lines-per-function`, `max-lines`; `eslint-plugin-sonarjs` for cognitive complexity |
| python | `radon cc`, flake8 `max-complexity` (mccabe) |
| rust | clippy `cognitive_complexity`, `too_many_lines` |
| go | `gocyclo`, `funlen` via `golangci-lint` |
| jvm | Checkstyle `CyclomaticComplexity`/`MethodLength`, PMD |
| php | `PHPMD` `CyclomaticComplexity`, `ExcessiveMethodLength` |
| dotnet | Roslyn analyzers, `SonarAnalyzer.CSharp` |
| shell | `shellcheck` (no complexity rule; cap by review) |

## Fuzz

Target selection, harness patterns, tier per fuzzer kind: `fuzzing.md`.

| Stack | Tool |
|---|---|
| node | `fast-check` (property-based), `jsfuzz` |
| python | `hypothesis` (property-based), `atheris` (coverage-guided, libFuzzer) |
| rust | `cargo-fuzz` (libFuzzer), `proptest` |
| go | native `go test -fuzz`, built in since 1.18 |
| jvm | `Jazzer` |
| php | `php-fuzzer` |
| dotnet | `SharpFuzz` |
| shell | hand-written adversarial corpus over the four attack axes (fuzzing.md) |

## Security

Mostly stack-agnostic = the lanes worth wiring first in an unfamiliar repo.

| Lane | Tool | Notes |
|---|---|---|
| Secrets | `gitleaks`, `trufflehog` | full history, not just the diff |
| SAST | `semgrep` (multi-language), CodeQL | CodeQL free for public repos in GitHub Actions |
| SAST, python | `bandit` | + semgrep |
| SAST, go | `gosec` | |
| SAST, jvm/dotnet | `SpotBugs` + `find-sec-bugs`, `security-code-scan` | |
| Dependencies | `pnpm audit`, `pip-audit`, `cargo audit`, `govulncheck`, `composer audit`, `dotnet list package --vulnerable`, OWASP dependency-check | fail on critical and high |
| Containers + IaC | `trivy`, `grype` | if a Dockerfile or terraform is present |
| DAST | OWASP ZAP baseline scan | needs a running instance, T3 only |
| Supply chain | SBOM via `syft` or `cyclonedx`, lockfile integrity, license audit | matches the supply-chain rule in CLAUDE.md |

## Thresholds file

`install-gate.sh` writes these into `qgate.config.sh`: visible, diffable, reviewable rather than buried in tool configs.

```sh
COVERAGE_CHANGED_MIN=80
COVERAGE_TOTAL_MIN=70
MUTATION_CHANGED_MIN=70
COMPLEXITY_MAX=10
FUNCTION_LINES_MAX=50
FILE_LINES_MAX=400
FUZZ_SMOKE_SECONDS=30      # T2
FUZZ_DEEP_SECONDS=900      # T3
SEVERITY_FAIL=high         # SAST, deps, secrets, DAST
EARS_ENFORCE=1             # requirement lines under "## Requirements" / REQ- must be EARS
EARS_PATHS="docs/dmj/specs docs/specs specs"
STE_ENFORCE=1              # ACTIVE for AI-authored prose, user law; blocking lane
STE_ALLOWLIST="webhook idempotent middleware serverless runtime API SDK CLI JSON YAML OAuth JWT"   # grow per repo
STE_PATHS="README.md docs"
WAIVERS=""                 # "lane:reason:YYYY-MM-DD" entries, printed every run; legacy human docs get dated waivers, never a disabled lane
```

Raising a threshold = a normal commit. Lowering one needs a reason in the commit message: it is the cheapest way to turn a red gate green without fixing anything.
