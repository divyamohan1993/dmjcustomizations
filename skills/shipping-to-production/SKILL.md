---
name: shipping-to-production
description: Use when a build must go live (deploy, ship it, release tonight), when writing or fixing a deploy script or pipeline, when production breaks after a release, or when adding any billable infrastructure. Symptoms: hand-run deploy steps, no rollback path, no health check, an unpriced cloud resource.
---

# Shipping To Production

deploy = scripted, repeatable, reversible operation, never a performance. hands on a production server: the process failed.

## Gate 0: green on the artifact

nothing deploys, ever, without the full suite green on the EXACT artifact being deployed (dmj:verification-before-completion). branch passing is not artifact passing. same artifact in every environment.

## The deploy artifact set (every project carries it)

| Piece | Floor |
|---|---|
| Idempotent deploy script | blank machine to running app in one command. rerun converges, never duplicates or breaks. env validated at startup, crash loud on misconfiguration. secret rotation safe on rerun |
| Health verification | shallow (`/health`) + deep (`/health/ready`) endpoints. script FAILS the deploy when they do not answer after start. no green without the probe |
| One-step rollback | previous artifact retained, switchable in one command, under 60 seconds. deploy without a rollback path: not finished |
| Deploy is not release | feature flags gate exposure. kill switch per risky surface. risky paths roll out staged: canary a small slice, watch error rates, auto-roll-back on a spike, then widen. migrations zero-downtime (dmj:stewarding-data) |
| Front door | reverse proxy or edge in front. process never faces raw traffic. TLS terminated properly (dmj:defending-in-depth) |
| Supervision | process manager or unit file: crash restarts, boot starts, log rotation. one project's crash never takes down another's |
| Hardened container | multi-stage Dockerfile, distroless or alpine base, non-root user, read-only filesystem, no secrets in any layer (runtime mount only) |
| Super-admin panel | `/super-admin` for DR, factory reset, master controls: quantum-safe access (session-tier parameters, dmj:defending-in-depth), brute-force backoff, DDoS early-reject, audit-logged, zero external dependencies, no recovery path. verified before ship |
| Pipeline | CI runs the same gates as local hooks, deploys the built artifact. local hand-deploys are for emergencies that do not exist |

## Cost gate

any new billable resource priced BEFORE provisioning, in writing: the recommendation, the free alternative, exactly what free gives up. then the user picks (cost axis: dmj:enforcing-performance-budgets). free wins when the numbers hold. always-on resource nobody asked for: a defect.

## Incident rule

production bleeding after a release: one-step rollback FIRST, then land the fix through the pipeline with the suite green on the new artifact. rollback runs as fast as a hotfix and leaves no drift. patching a live server turns the next deploy into a mystery, and "I am sure about the patch" is how drift starts.

## Manual boundaries

step needing access you do not have (DNS record, dashboard toggle): hand the user the exact value, one clear message. never automate around it, never retry into a lockout.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "SSH and restart is faster tonight" | tonight's hand deploy = next month's unreproducible server. the script ships tonight too, correctly |

## Red flags (stop)

- deploy done by hand, or a script that breaks on rerun.
- editing code or config directly on a production machine.

**Headless:** deploy through the script, report probe output; PARK new billable resources and any step needing credentials the user holds.

Next: dmj:finishing-a-development-branch precedes the ship; dmj:equipping-projects wires the pipeline; dmj:verification-before-completion proves the green.
