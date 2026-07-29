---
name: tracing-codebases
description: Use when the deliverable is an explanation IN CHAT of how a codebase really works (execution start, data flow, module wiring) with no build to follow and nothing written to the repo: onboarding walkthroughs, "how does X work", auditing code against its docs.
disallowed-tools: Write, Edit, NotebookEdit
---

# Tracing Codebases

live, evidence-based model of how a codebase works. read the real source in parallel, deliver in chat.

## Contract

code = only source of truth. READMEs/comments/design docs = hints to verify, never facts to repeat. every claim cites file:line or ships flagged unverified. output IN CHAT ONLY: no map file, no memory entry, nothing into the repo. about to BUILD there? -> dmj:exploring-codebases (persisted map + anti-redundancy gate). quick orientation = harness-native explore skill. this adds parallel slice owners, seam cross-confirmation, refutation bar per claim.

## Flow

1. **recon** (you, fast): Glob/Grep for languages, manifests, entry points, top-level shape. no deep reads; triage for partitioning.
2. **partition**: 3-6 coherent slices by layer or feature boundary (API, domain, data, UI, jobs, shared). user focus = the spine: still map everything, bias depth toward the focus.
3. **fan out**: one explorer teammate per slice, all dispatched together (dmj:dispatching-parallel-teams); prefer the read-only Explore agent type. you synthesize.
4. **explorer charter** (each): slice purpose + key files with paths; trace execution in/out; trace data reads/writes; find every cross-boundary link, CONFIRM the other side with the owning explorer via SendMessage, never assume; post a midway update; flag everything unverifiable + every place code contradicts docs.
5. **synthesize**: reconcile boundary claims (conflict -> read the code yourself). deliver in chat: system shape, execution flow, data flow, interconnection map, docs-vs-code discrepancies, unknowns. cite file:line throughout. "presumably"/"probably" in the synthesis = trace it or list it unknown.

## When NOT to use

single-fact lookup (just search). area you already understand. mapping before you build (= dmj:exploring-codebases). a team costs real tokens; never spend it to find one function.

Next: **dmj:exploring-codebases** before building in the explored code, or **dmj:brainstorming** once the change you want is understood.
