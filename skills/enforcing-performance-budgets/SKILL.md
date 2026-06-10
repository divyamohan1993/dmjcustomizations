---
name: enforcing-performance-budgets
description: Use when something is slow or might be ("it feels slow", "is this fast enough"), or when a choice affects speed: a slow endpoint, an N+1 query, nested loops over large input, a heavy bundle, picking a stack, database, framework, data structure, or algorithm, adding a hot-path dependency, or reviewing code for performance.
---

# Enforcing Performance Budgets

Performance is a gate, not an afterthought. An unenforced budget is a wish. Regressions block merges.

## Gate 1: Complexity first

Target O(1); else justify the lowest achievable in a comment at the call site: O(log n) > O(n) > O(n log n). **O(n^2) or worse requires written justification next to the code** naming the input bound that keeps it safe. No silent quadratics on unbounded input.

## Gate 2: Measure, never guess

Profile before optimizing; the bottleneck is rarely where intuition points. No optimization lands without a before/after measurement. A guess is not evidence; a flame graph is.

## Gate 3: Written budgets, enforced in CI

Every budget is written and machine-checked. Start from these floors, adjust per project, always commit the number:

| Budget | Floor | Gate |
|--------|-------|------|
| p95 API latency | < 200ms | load test |
| LCP | < 2.5s | Lighthouse CI |
| INP | < 200ms | Lighthouse CI |
| CLS | < 0.1 | Lighthouse CI |
| JS bundle | < 200KB gzip | bundlesize / size-limit |

Confirm current Core Web Vitals thresholds at invocation (fetch web.dev; limits evolve, INP replaced FID). Lighthouse `budget.json` and bundlesize assert at `error` so a breach **fails the build**.

## Gate 4: Cache-first architecture

Origin is the last resort, not the default:
- Immutable static assets at the edge, long TTL, content-hashed.
- API responses cached with stale-while-revalidate.
- HTML via edge SSG/ISR; origin hit only on a genuine miss of uncacheable data.

## Choosing a stack

Pick the fastest-fit by measured evidence, not fashion. Probe current independent benchmarks at decision time; ties break on your workload, not a marketing chart.

## Load and soak

Load-test at peak times a safety factor; soak to catch leaks and GC stalls. The bar: a graph that flatlines under normal plus moderate attack load.

## Parallel pattern

Run a dedicated **performance lens as a fresh-context teammate** in every review panel (never same-context self-review). When two implementations are plausible, race them as **parallel spikes in disposable worktrees** (dmjcustomizations:using-git-worktrees); the benchmark decides. Coordinate via TeamCreate + Agent (team_name, name); if TeamCreate is unavailable, race them as native parallel Agent calls.

## Rationalization table

| Excuse | Reality |
|--------|---------|
| "Optimize later, ship now" | Later is a rewrite under production load. Budget now. |
| "n is small here" | Inputs grow; the bound is not in the code. Write it or fix it. |
| "It feels fast on my machine" | Your machine is not p95 on 3G. Measure the tail. |

## Red flags: STOP, measure, set the budget

- Nested loop or N+1 over unbounded input, no justification comment
- Optimizing without a profile
- A budget that warns instead of failing the build
- Stack chosen by popularity, not a workload benchmark

Handoff: bake budgets into dmjcustomizations:writing-plans; enforce the perf lens via dmjcustomizations:requesting-code-review.
