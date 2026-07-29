---
name: enforcing-quality-gates
description: Use when about to call work done, shipped, or merged, or when a repo has no automated proof it works: generates and runs that repo's unit, acceptance, mutation, coverage, fuzz, and security gate.
---

# Enforcing Quality Gates

Every repo carries its own gate. The gate is generated from the repo's actual stack, committed to the repo, run by machine, and consulted before any completion claim. "I read the diff and it looks right" is not a gate.

## Iron Law

**No done-claim before a green gate.** Not "tests pass", not "it works locally": the gate ran, every lane reported, and no lane is red or silently skipped. This binds shipped code, agent-written code, and your own code equally. Agent-written tests are the reason mutation testing is in the gate, not an excuse to drop it.

A repo with no gate is not "passing". It is unmeasured. Generate the gate first (`install-gate.sh`), then run it.

**One exemption**, the trivial-change threshold in CLAUDE.md: one file, reversible, no new dependency, no schema or stored-data change, nothing touching auth, crypto, secrets, PII, money, deletion, or a public surface, no production config. All clauses must hold, and a change touching crypto or auth can never be trivial, so the security lanes are never the ones skipped. A trivial change needs **T1 green only**.

## Tier by feedback loop, not by importance

Gates die by slowness: mutation and fuzz in the pre-commit path means a nine-minute wait and a disabled gate by Friday. Slowness is a correctness risk.

| Tier | Budget | Lanes | Trigger |
|---|---|---|---|
| **T1 fast** | < 10s | format, lint, types, secret scan, unit tests for changed files | pre-commit, every agent turn that edited code |
| **T2 merge** | < 10min | full unit, Gherkin acceptance, coverage thresholds, complexity and size caps, SAST, dependency audit, fuzz smoke over the committed corpus | pre-push, PR, before any done-claim |
| **T3 deep** | unbounded | mutation testing, extended fuzz (time-boxed), DAST against a running instance, license audit | nightly, pre-release, after a security-relevant change |

A done-claim needs **T2 green**. Shipping needs **T3 green** since the last release (dmj:shipping-to-production).

## The lanes, and what each one actually proves

| Lane | Answers | Fails when |
|---|---|---|
| Unit | Does each piece do what it claims? | behavior changed |
| **Acceptance (Gherkin)** | Did we build the right thing? | the feature, described in the user's language, does not work end to end |
| Coverage | What did the tests never execute? | untested paths shipped |
| **Mutation** | Do the tests actually assert, or just execute? | a deliberate bug survives the whole suite |
| Complexity + size caps | Can a human or an agent still reason about this unit? | a function outgrew review |
| **Fuzz** | What happens on input nobody imagined? | crash, hang, or a security control that fails open |
| SAST + deps + secrets | Is there a known-bad pattern, package, or leaked credential? | any critical or high |
| DAST | Does the running system leak or break under hostile traffic? | any high |

**Coverage is a floor; mutation score is the truth.** 90% coverage with a 30% mutation score means tests that run the code and assert almost nothing: the signature failure of quickly-generated tests, invisible to every other lane.

**Gherkin is the spec, not decoration.** Write the `.feature` first and hand *that* to the implementer. A scenario an implementer cannot make pass was never actually specified.

## Skipped is not passed

A lane whose tool is missing reports **SKIP**, loudly, and T2 refuses to go green while any lane is SKIP. To accept a gap, waive it in the config with a reason and a date; the waiver prints on every run.

## Default thresholds

Tighten per repo, never loosen silently.

- Line coverage: **80% on changed files**, 70% overall. Gate the diff, not the legacy.
- Mutation score: **70% on changed files**.
- Cyclomatic complexity: **10 per function**. Function length **50 lines**. File length **400 lines**.
- SAST, dependency, secret findings: **zero** critical or high. Binary, not a percentage.

Size and complexity caps are not style: they bound how much an agent changes in one reviewable step and keep mutation runs tractable.

## Adopted writing and security frameworks

| Framework | Controls | Enforcement |
|---|---|---|
| **EARS** (Easy Approach to Requirements Syntax) | the **structure** of a requirement sentence | **enforced.** The `ears` lane fails on any requirement line in a spec path that does not match an EARS pattern. |
| **ASD-STE100** (Simplified Technical English) | the **vocabulary and sentence length** of prose | **warn only.** Reported, never blocking, with a per-repo domain allowlist. Its dictionary is aerospace-derived and flags ordinary software terms. |
| **OWASP ASVS L2** | what "secure enough" means, testably | **enforced.** The security lanes assert against ASVS L2 rather than a vague pass. |

EARS patterns:

| Pattern | Template |
|---|---|
| Ubiquitous | The `<system>` shall `<response>` |
| Event-driven | **When** `<trigger>`, the `<system>` shall `<response>` |
| State-driven | **While** `<state>`, the `<system>` shall `<response>` |
| Unwanted behaviour | **If** `<trigger>`, **then** the `<system>` shall `<response>` |
| Optional feature | **Where** `<feature>`, the `<system>` shall `<response>` |

"Users must be able to reset passwords somehow" fails the lane; "When a user requests a password reset, the system shall send a single-use link valid for 15 minutes" passes and cannot be built wrong.

STE limits ship as **defaults to calibrate, not verified values**: download Issue 9 (free, asd-ste100.org) and tune `qgate.config.sh` before ever setting `STE_ENFORCE=1`.

## Flow

1. **Generate.** `bash install-gate.sh <repo>` detects the stack, writes `qgate.sh` + `qgate.config.sh` + a CI job, and reports every lane as WIRED or UNAVAILABLE. Commit them. Wiring into hooks and CI: dmj:equipping-projects.
2. **Write the acceptance feature first** for anything user-facing, then unit tests (dmj:test-driven-development), then implementation.
3. **Run T1 continuously** while working.
4. **Run T2 before any done-claim.** Red or SKIP means not done. Fix, rerun.
5. **Run T3** before release and after any change to authentication, parsing, crypto, money, or deletion.
6. **Feed failures back.** A fuzz crash or a surviving mutant becomes a committed regression case; a finding fixed without a test is one you will get again.

Per-stack tools and exact commands: `gate-matrix.md`. Fuzz target selection, the four attack axes, and harness discipline: `fuzzing.md`, which ends with the run that found **10 live bypasses** in a fail-open control that had passed a 13-probe behavior suite for weeks. That gap is why every repo gets a fuzz lane, not only the security-shaped ones. Threat model behind the security lanes: dmj:defending-in-depth. Evidence discipline around the claim itself: dmj:verification-before-completion.

## Red flags (stop)

- "Tests pass" as the done-claim, with no gate run.
- Mutation or fuzz lanes moved into T1, then disabled for slowness.
- Coverage raised by tests with no assertions; a mutation score that never moves.
- Thresholds lowered to make a red gate green.
- Fuzzing only the "security" component. The parser, the config loader, and the CLI argument handler are all attack surface.

Next: **dmj:verification-before-completion** for the claim itself, then **dmj:shipping-to-production**.
