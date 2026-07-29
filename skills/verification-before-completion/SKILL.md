---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, passing, or ready, before committing, opening a PR, or handing off, including any expression of satisfaction about the work state
---

# Verification Before Completion

Claiming done without verifying = dishonesty, not efficiency. Evidence before claims.

## The Iron Law

```
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE
```

Did not run the command in *this* turn = cannot say it passes. Paraphrase, synonym, implied success: still a claim. Letter = spirit.

## The gate

```
BEFORE any status claim or expression of satisfaction:
1. IDENTIFY the command that proves it
2. RUN it fresh and complete: clean build, FULL suite, not cached/partial/prior
3. READ all output: exit code, failure count
4. MATCH output to claim -> state the actual status WITH the evidence
Skipping a step is lying, not verifying.
```

Stale green proves nothing; a passing subset hides the failure you skipped. Quote verbatim, never summarize: "all green" = a claim, the runner's `34 passed, 0 failed` = auditable evidence.

## Claim to evidence

| Claim | Proof required | Not sufficient |
|-------|----------------|----------------|
| Tests pass | full-suite output, 0 failures, quoted | a prior run, "should pass" |
| Build succeeds | build exit 0 | linter passed (not a compiler) |
| Bug fixed | original symptom retested, passes | code changed, assumed fixed |
| Regression test works | red-green seen: revert to MUST-FAIL, restore to pass | test passes once |
| Performance met | measured vs budget (`dmj:enforcing-performance-budgets`) | "feels fast" |
| Teammate finished | VCS diff inspected | their "success" report |
| Requirements met | line-by-line vs the plan | tests pass |

## The machine gate comes first

Before any human or teammate judgement, the repo's gate must be green: `bash qgate.sh --merge`. No gate -> generate one (dmj:enforcing-quality-gates), then run it. "Tests pass" is not the gate; nor is a clean read of the diff. Everything below happens *after* green: a green gate proves the code does what its tests say, not that its tests say the right thing.

## Adversarial fresh-context verification

Self-review in your own context is not enough: you believe it works, so you read output charitably. Any nontrivial deliverable, before the success claim: dispatch one FRESH-context teammate (`dmj:requesting-code-review`, or a lone teammate via `dmj:dispatching-parallel-teams`) to *refute* "it works" -> clean checkout, full suite, edge-case taxonomy, try to break it. Done only after it fails to refute; a passing self-test proves only that your own test agreed with you. advisor tool present -> consult it before the done-claim, a second independent reviewer.

## Verified stays verified

One-time green = an assumption with a timestamp. Green proves today; the guard proves tomorrow. Nontrivial completion leaves a STANDING GUARD so the proof outlives the turn: regression test in the suite (dmj:test-driven-development), CI assertion or lint rule enforcing the new invariant (a migration leaves a no-old-imports check), an alert (dmj:observing-production), or a scheduled predicate. Done without its guard is not done; the claim decays the moment the code evolves.

## Red flags: STOP

"Should work" / "probably" / "seems to" / any "Great! / Perfect! / Done!" before the command ran / about to commit/push/PR unverified / trusting a teammate's success report / "just this once" / tired and wanting it over / a nontrivial completion leaving no standing guard behind.

## Headless mode

No user to reassure = no excuse to skip evidence. Every verification runs fresh, the adversarial pass runs, quoted output goes in the final report. Cannot verify (missing secret, external dependency)? Report it unverified with the reason; never assert a green you did not see.

Verified with quoted evidence and an independent refutation? Next: `dmj:requesting-code-review`, then `dmj:finishing-a-development-branch`.
