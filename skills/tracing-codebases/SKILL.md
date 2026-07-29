---
name: tracing-codebases
description: Use when the deliverable is an explanation IN CHAT of how a codebase really works (execution start, data flow, module wiring) with no build to follow and nothing written to the repo: onboarding walkthroughs, "how does X work", auditing code against its docs.
disallowed-tools: Write, Edit, NotebookEdit
---

# Tracing Codebases

Build a live, evidence-based model of how a codebase works by reading the real source in parallel, deliver it in chat.

## Contract

Code is the only source of truth: READMEs, comments, design docs are hints to verify, never facts to repeat. Every claim cites file:line or is flagged unverified. Output is IN CHAT ONLY: no map file, no memory entry, nothing into the repo. About to BUILD there instead? Route to dmj:exploring-codebases (persisted map plus anti-redundancy gate). Quick orientation is the harness-native explore skill; this adds parallel slice owners, seam cross-confirmation between them, and a refutation bar on every claim.

## Flow

1. **Recon** (you, fast): Glob and Grep for languages, manifests, entry points, top-level shape. No deep reads; triage for partitioning.
2. **Partition**: 3-6 coherent slices by layer or feature boundary (API, domain, data, UI, jobs, shared). A user focus becomes the spine: still map everything, bias depth toward the focus.
3. **Fan out**: one explorer teammate per slice, all dispatched together (delegation per dmj:dispatching-parallel-teams); prefer the read-only Explore agent type. Synthesize yourself.
4. **Explorer charter** (each): the slice's purpose and key files + paths; trace execution in and out; trace data reads and writes; find every cross-boundary link and CONFIRM the other side with the owning explorer via SendMessage, never assume; post a midway update; flag everything unverifiable and every place code contradicts docs.
5. **Synthesize**: reconcile boundary claims (on conflict, read the code yourself), deliver in chat: system shape, execution flow, data flow, interconnection map, docs-vs-code discrepancies, unknowns. Cite file:line throughout. "Presumably" or "probably" in the synthesis means trace it or list it as an unknown.

## When NOT to use

A single-fact lookup (just search), an area you already understand, or mapping before you build (that is dmj:exploring-codebases). A team costs real tokens; do not spend it to find one function.

Next: **dmj:exploring-codebases** before building in the explored code, or **dmj:brainstorming** once the change you want is understood.
