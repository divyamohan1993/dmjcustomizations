---
name: shipping-to-production
description: Use when a build must go live (deploy, ship it, release tonight), when writing or fixing a deploy script or pipeline, when production breaks after a release, or when adding any billable infrastructure. Symptoms: hand-run deploy steps, no rollback path, no health check, an unpriced cloud resource.
---

# Shipping To Production

A deploy is a scripted, repeatable, reversible operation, never a performance. Hands on a production server means the process failed.

## Gate 0: green on the artifact

Nothing deploys, ever, without the full suite green on the EXACT artifact being deployed (dmj:verification-before-completion). The branch passing is not the artifact passing. Same artifact in every environment.

## The deploy artifact set (every project carries it)

| Piece | Floor |
|---|---|
| Idempotent deploy script | Blank machine to running app in one command; rerun converges, never duplicates or breaks. Env validated at startup, crash loud on misconfiguration; secret rotation safe on rerun |
| Health verification | Shallow (`/health`) and deep (`/health/ready`) endpoints; the script FAILS the deploy when they do not answer after start. No green without the probe |
| One-step rollback | Previous artifact retained and switchable in one command. A deploy without a rollback path is not finished |
| Front door | Reverse proxy or edge in front of the app; the process never faces raw traffic; TLS terminated properly (dmj:defending-in-depth) |
| Supervision | Process manager or unit file: crash restarts, boot starts, log rotation. One project's crash never takes down another's |
| Pipeline | CI runs the same gates as local hooks and deploys the built artifact; local hand-deploys are for emergencies that do not exist |

## Cost gate

Any new billable resource is priced BEFORE provisioning, in writing: the recommendation, the free alternative, and exactly what free gives up, then the user picks (cost axis: dmj:enforcing-performance-budgets). Free wins when the numbers hold. An always-on resource nobody asked for is a defect.

## Incident rule

Production bleeding after a release: one-step rollback FIRST, then land the fix through the pipeline with the suite green on the new artifact. Rollback is as fast as a hotfix and leaves no drift; patching a live server turns the next deploy into a mystery, and "I am sure about the patch" is how drift starts.

## Manual boundaries

A step needing access you do not have (DNS record, dashboard toggle): hand the user the exact value to enter, one clear message, never automate around it and never retry into a lockout.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "SSH and restart is faster tonight" | Tonight's hand deploy is next month's unreproducible server. The script ships tonight too, correctly |
| "Rollback is overkill for this change" | Every deploy believes that; the one that needs it decides your night |
| "We will price the resource after launch" | After launch it is a bill, not a decision |

## Red flags (stop)

- A deploy done by hand, or a script that breaks on rerun.
- A deploy reported done with no health-probe output.
- Editing code or config directly on a production machine.
- No retained previous artifact, or rollback untested.
- A billable resource provisioned with no written price.

**Headless:** deploy through the script and report probe output; PARK new billable resources and any step needing credentials the user holds.

Next: dmj:finishing-a-development-branch precedes the ship; dmj:equipping-projects wires the pipeline; dmj:verification-before-completion proves the green.
