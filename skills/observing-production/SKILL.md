---
name: observing-production
description: Use when a service is heading to or running in production and health must be known without waiting for complaints: SLOs, alerts, structured logs, correlation IDs, dashboards, error tracking, incidents. Symptoms: "is prod healthy", no alerts defined, debugging from user reports, a repeat incident.
---

# Observing Production

Healthy means the signals say so. Silence is an unmonitored failure mode, not good news. Observability is defined BEFORE launch, because launch is when you are blind and the traffic is real.

## Gate 0: instrumented before deployed

Before the first production deploy, in writing:
- **SLOs**: availability and latency (p95 tied to the committed budgets, dmj:enforcing-performance-budgets).
- **Symptom alerts**: user-facing error rate, p95 latency, saturation. One alert per user-visible symptom, on symptoms, never on causes; causes go on dashboards, because fifty cause-pages a day train everyone to ignore the fifty-first.
- **Paging path**: who or what reacts, and how fast.

An alert that fires without action twice is deleted or fixed: fatigue buries the page that matters.

## Instrumentation floors

| Floor | Rule |
|---|---|
| Logs | Structured (JSON), leveled, to stdout; a correlation ID on every request, propagated across every service boundary; secrets and PII never logged (dmj:defending-in-depth) |
| Golden signals | Latency, traffic, errors, saturation per service; one dashboard answers "is it healthy" in one glance |
| Probes | Shallow and deep health endpoints wired to the deploy gate (dmj:shipping-to-production) |
| Errors | Every unhandled exception captured with release tag and correlation ID, deduplicated, triaged |

## Incident loop

1. **Detect** from signals, not tickets.
2. **Stabilize**: one-step rollback FIRST (dmj:shipping-to-production incident rule); diagnose after the bleeding stops.
3. **Root cause** by dmj:systematic-debugging, never by guess.
4. **Blameless post-mortem** for every user-visible incident: timeline, root cause, action items landing as commits and tests WITH OWNERS. A summary in chat is not a post-mortem; a recurrence with no landed action item is the real failure.

## Red flags (stop)

- A production deploy with zero alerts defined.
- A request-path log line with no correlation ID.
- An incident closed with no landed action items.
- Debugging production from user reports instead of signals.

**Headless:** wire instrumentation and draft SLOs autonomously from the budgets; PARK paging targets and product-owned SLO numbers.

Next: dmj:shipping-to-production deploys what this watches; dmj:systematic-debugging owns the root cause; dmj:equipping-projects wires the error tracker and CI.
