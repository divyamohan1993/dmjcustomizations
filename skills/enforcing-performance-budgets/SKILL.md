---
name: enforcing-performance-budgets
description: Use when something is slow or might be ("it feels slow", "is this fast enough"), or when a choice affects speed: a slow endpoint, an N+1 query, nested loops over large input, a heavy bundle, picking a stack, database, framework, data structure, or algorithm, adding a hot-path dependency, or reviewing code for performance. Also when a stack or hosting choice affects money: cost estimates, free-tier fit, oversized infrastructure.
---

# Enforcing Performance Budgets

Performance is a gate, not an afterthought. An unenforced budget is a wish. Regressions block merges.

## Gate 1: Complexity first

Target O(1); else justify the lowest achievable in a comment at the call site: O(log n) > O(n) > O(n log n). **O(n^2) or worse requires written justification next to the code**, naming the input bound that keeps it safe. No silent quadratics on unbounded input.

## Gate 2: Measure, never guess

Profile before optimizing; the bottleneck is rarely where intuition points. No optimization lands without a before/after measurement. A guess is not evidence; a flame graph is.

## Gate 3: Written budgets, enforced in CI

Every budget written and machine-checked. From these floors, adjust per project, always commit the number:

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

## Choosing a stack (cost is a budget too)

Two measured axes, never one: performance fit (meets every budget on YOUR workload; probe current independent benchmarks at decision time, not marketing charts) and total cost of ownership (infra, egress, build minutes, per-request pricing, at realistic and at 10x traffic). Among stacks that meet the budgets, the cheapest runs; a free tier that holds the numbers beats anything billable. Price it BEFORE adopting; commit the estimate beside the budgets.

A stack named by anyone, the user included, enters the same race as a hypothesis, never a conclusion. When it loses on cost or fit: present the numbers, recommend the winner, build only after the user decides with the evidence in front of them. Silent compliance with an oversized stack is a budget breach, not respect.

## Load and soak

Load-test at peak times a safety factor; soak to catch leaks and GC stalls. The bar: a graph that flatlines under normal plus moderate attack load.

## Parallel pattern

Run a dedicated **performance lens as a fresh-context teammate** in every review panel (never same-context self-review). Two implementations plausible: race them as **parallel spikes in disposable worktrees** (dmj:using-git-worktrees); the benchmark decides. Coordinate via TeamCreate + Agent (team_name, name); TeamCreate unavailable: race as native parallel Agent calls.

## Rationalization table

| Excuse | Reality |
|--------|---------|
| "Optimize later, ship now" | Later is a rewrite under production load. Budget now. |
| "n is small here" | Inputs grow; the bound is not in the code. Write it or fix it. |
| "It feels fast on my machine" | Your machine is not p95 on 3G. Measure the tail. |
| "The user/client already chose the stack" | Their choice is a hypothesis; race it on cost and fit, show the numbers, then they decide. |
| "Team familiarity is worth the monthly bill" | Familiarity is a one-time learning cost; the bill recurs forever. Price both. |

## Red flags: STOP, measure, set the budget

- Nested loop or N+1 over unbounded input, no justification comment
- Optimizing without a profile
- A budget that warns instead of failing the build
- Stack chosen by popularity, not a workload benchmark
- A stack adopted with no cost estimate, or a named stack built unexamined

Handoff: budgets into dmj:writing-plans; enforce the perf lens via dmj:requesting-code-review.
