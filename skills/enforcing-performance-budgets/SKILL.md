---
name: enforcing-performance-budgets
description: Use when something is slow or might be, or when a choice affects speed or money: a slow endpoint, an N+1 query, nested loops over large input, a heavy bundle, picking a stack or data structure, a hot-path dependency, a perf review, a cost estimate, free-tier fit.
---

# Enforcing Performance Budgets

performance = a gate, not an afterthought. unenforced budget = a wish. regressions block merges.

## Gate 1: Complexity first

target O(1). else justify the lowest achievable in a comment at the call site: O(log n) > O(n) > O(n log n). **O(n^2) or worse requires written justification next to the code**, naming the input bound that keeps it safe. no silent quadratics on unbounded input.

## Gate 2: Measure, never guess

profile before optimizing. bottleneck rarely sits where intuition points. no optimization lands without a before/after measurement. guess: not evidence. flame graph: evidence.

## Gate 3: Written budgets, enforced in CI

every budget written and machine-checked. floors below, adjust per project, always commit the number:

| Budget | Floor | Gate |
|--------|-------|------|
| p95 API latency | < 200ms | load test |
| LCP | < 2.5s | Lighthouse CI |
| INP | < 200ms | Lighthouse CI |
| CLS | < 0.1 | Lighthouse CI |
| JS bundle | < 200KB gzip | bundlesize / size-limit |

confirm current Core Web Vitals thresholds at invocation (fetch web.dev; metric set and limits evolve). Lighthouse `budget.json` + bundlesize assert at `error` -> a breach **fails the build**.

## Gate 4: Cache-first architecture

origin = last resort, not default:
- immutable static assets at the edge, long TTL, content-hashed.
- API responses cached, stale-while-revalidate.
- HTML via edge SSG/ISR. origin hit only on a genuine miss of uncacheable data.

**scale shape:** services stateless, state externalized (session store, queue, DB) -> one instance and a thousand behave identically. event-driven, edge-first, degrades gracefully. these patterns carry a single box to sharded multi-region without a rewrite, keeping 10x traffic a config change instead of a redesign.

## Choosing a stack (cost is a budget too)

two measured axes, never one:
- **performance fit**: meets every budget on YOUR workload. current independent benchmarks at decision time, not marketing charts.
- **total cost of ownership**: infra, egress, build minutes, per-request pricing, at realistic and at 10x traffic.

cheapest stack meeting the budgets runs. free tier holding the numbers beats anything billable. price BEFORE adopting, commit the estimate beside the budgets.

a stack named by anyone, the user included, enters the same race as a hypothesis, never a conclusion. loses on cost or fit -> present the numbers, recommend the winner, build only after the user decides with the evidence in front of them. silent compliance with an oversized stack = a budget breach, not respect.

## Load and soak

load-test at peak times a safety factor. soak to catch leaks and GC stalls. bar = a graph flatlining under normal plus moderate attack load.

## Parallel pattern

every review panel runs a **performance lens as a fresh-context teammate**, never same-context self-review (dmj:dispatching-parallel-teams). two implementations plausible -> race them as **parallel spikes in disposable temp clones** (dmj:using-git-worktrees policy); the benchmark decides.

## Rationalization table

| Excuse | Reality |
|--------|---------|
| "Optimize later, ship now" | later = a rewrite under production load. budget now. |
| "n is small here" | inputs grow; the bound is not in the code. write it or fix it. |
| "It feels fast on my machine" | your machine is not p95 on 3G. measure the tail. |
| "Team familiarity is worth the monthly bill" | familiarity = one-time learning cost. the bill recurs forever. price both. |

## Red flags: STOP, measure, set the budget

- nested loop or N+1 over unbounded input, no justification comment
- optimizing without a profile
- a budget that warns instead of failing the build
- stack chosen by popularity, not a workload benchmark

Handoff: budgets -> dmj:writing-plans; perf lens enforced via dmj:requesting-code-review.
