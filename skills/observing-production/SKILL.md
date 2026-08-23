---
name: observing-production
description: "Use when a service is heading to or running in production and health must be known without waiting for complaints: SLOs, alerts, structured logs, correlation IDs, dashboards, error tracking, incidents. Symptoms: \"is prod healthy\", no alerts defined, debugging from user reports, a repeat incident."
---

# Observing Production

healthy = the signals say so. silence: an unmonitored failure mode, not good news. observability defined BEFORE launch, because launch is when you are blind and the traffic is real.

## Gate 0: instrumented before deployed

before the first production deploy, in writing:
- **SLOs**: availability + latency (p95 tied to the committed budgets, dmj:enforcing-performance-budgets).
- **symptom alerts**: user-facing error rate, p95 latency, saturation. one alert per user-visible symptom, on symptoms, never on causes. causes go on dashboards: fifty cause-pages a day train everyone to ignore the fifty-first.
- **paging path**: who or what reacts, how fast.

alert fires twice with no action -> deleted or fixed. fatigue buries the page that matters.

## Instrumentation floors

| Floor | Rule |
|---|---|
| Logs | structured JSON, leveled, to stdout, verbose: timestamp, file:line, function, severity, correlation ID, anonymized user context on every line. trace ID travels every hop. secrets and PII never logged (dmj:defending-in-depth) |
| Two audiences | user sees zero raw errors, friendly recovery only. super-admin panel sees everything: SIEM-grade real-time feed, filterable + searchable, every error a row with timestamp, file:line, stack, request ID, sanitized payload |
| Golden signals | latency (p50/p95/p99), traffic, errors, saturation per endpoint. dashboards day one. one glance answers "is it healthy" |
| Probes | shallow + deep health endpoints wired to the deploy gate (dmj:shipping-to-production) |
| Errors | every unhandled exception captured with release tag + correlation ID, deduplicated, triaged |
| Edge | WAF + edge logs reviewed on a cadence, not only during incidents. traffic anomalies surface here first |

## Incident loop

1. **detect** from signals, not tickets.
2. **stabilize**: one-step rollback FIRST (dmj:shipping-to-production incident rule). diagnose after the bleeding stops.
3. **root cause** by dmj:systematic-debugging, never by guess.
4. **blameless post-mortem** on every user-visible incident: timeline, root cause, action items landing as commits and tests WITH OWNERS. chat summary: not a post-mortem. recurrence with no landed action item: the real failure.

## Red flags (stop)

- production deploy with zero alerts defined.
- request-path log line with no correlation ID.
- incident closed with no landed action items.
- debugging production from user reports instead of signals.

**Headless:** wire instrumentation + draft SLOs autonomously from the budgets; PARK paging targets and product-owned SLO numbers.

Next: dmj:shipping-to-production deploys what this watches; dmj:systematic-debugging owns the root cause; dmj:equipping-projects wires the error tracker and CI.
