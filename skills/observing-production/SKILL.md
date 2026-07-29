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
| Logs | Structured (JSON), leveled, to stdout, verbose: timestamp, file:line, function, severity, correlation ID, anonymized user context on every line; the trace ID travels through every hop; secrets and PII never logged (dmj:defending-in-depth) |
| Two audiences | The user sees zero raw errors, friendly recovery only. The super-admin panel sees everything: a SIEM-grade real-time feed, filterable and searchable, every error a row with timestamp, file:line, stack, request ID, sanitized payload |
| Golden signals | Latency (p50/p95/p99), traffic, errors, saturation per endpoint; dashboards day one; one glance answers "is it healthy" |
| Probes | Shallow and deep health endpoints wired to the deploy gate (dmj:shipping-to-production) |
| Errors | Every unhandled exception captured with release tag and correlation ID, deduplicated, triaged |
| Edge | WAF and edge logs reviewed on a cadence, not only during incidents; traffic anomalies surface here first |

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
