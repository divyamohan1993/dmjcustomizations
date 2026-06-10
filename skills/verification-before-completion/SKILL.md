---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, passing, or ready, before committing, opening a PR, or handing off, including any expression of satisfaction about the work state
---

# Verification Before Completion

Claiming done without verifying is dishonesty, not efficiency. Evidence before claims.

## The Iron Law

```
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE
```

Did not run the command in *this* turn? You cannot say it passes. A paraphrase, synonym, or implied success is still a claim: letter and spirit are one rule.

## The gate

```
BEFORE any status claim or expression of satisfaction:
1. IDENTIFY the command that proves it
2. RUN it fresh and complete: clean build, FULL suite, not cached/partial/prior
3. READ all output: exit code, failure count
4. MATCH output to claim -> state the actual status WITH the evidence
Skipping a step is lying, not verifying.
```

Fresh and complete is load-bearing: a stale green proves nothing, a passing subset hides the failure you skipped. Quote the output verbatim, do not summarize: "all green" is a claim, the runner's `34 passed, 0 failed` is auditable evidence.

## Claim to evidence

| Claim | Proof required | Not sufficient |
|-------|----------------|----------------|
| Tests pass | full-suite output, 0 failures, quoted | a prior run, "should pass" |
| Build succeeds | build exit 0 | linter passed (not a compiler) |
| Bug fixed | original symptom retested, passes | code changed, assumed fixed |
| Regression test works | red-green seen: revert to MUST-FAIL, restore to pass | test passes once |
| Performance met | measured vs budget (`dmjcustomizations:enforcing-performance-budgets`) | "feels fast" |
| Teammate finished | VCS diff inspected | their "success" report |
| Requirements met | line-by-line vs the plan | tests pass |

## Adversarial fresh-context verification

Self-review in your own context is not enough: you believe it works, so you read output charitably. For any nontrivial deliverable, before claiming success, dispatch one FRESH-context teammate (`dmjcustomizations:requesting-code-review`, or a lone teammate via `dmjcustomizations:dispatching-parallel-teams`) to *refute* "it works": clean checkout, full suite, edge-case taxonomy, try to break it. Claim done only after it fails to refute; a passing self-test proves only that your own test agreed with you. (No TeamCreate? Run the refutation as a fresh native Agent call and judge it yourself.)

## Red flags: STOP

"Should work," "probably," "seems to," any "Great! / Perfect! / Done!" before the command ran, about to commit/push/PR unverified, trusting a teammate's success report, "just this once," tired and wanting it over.

## Rationalizations

| Excuse | Reality |
|--------|---------|
| "Should work now" | Run it. |
| "I'm confident" | Confidence is not evidence. |
| "Linter passed" | Linter is not the compiler or the tests. |
| "Teammate said success" | Verify the diff independently. |
| "Partial check is enough" | Partial proves nothing about the rest. |
| "Different words, rule won't apply" | Spirit over letter. |

## Headless mode

No user to reassure means no excuse to skip evidence: every verification still runs fresh, the adversarial pass still runs, the quoted output goes in the final report. Cannot verify something (missing secret, external dependency)? Report it unverified with the reason; never assert a green you did not see.

Verified with quoted evidence and an independent refutation? Next: `dmjcustomizations:requesting-code-review`, then `dmjcustomizations:finishing-a-development-branch`.
