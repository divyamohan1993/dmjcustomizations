---
name: explore
description: Use when you need to understand how an unfamiliar or large codebase actually works (how modules interconnect, where execution starts, how data flows, how a feature is wired) and the deliverable is an explanation in chat, such as onboarding, "how does X work", "map the architecture", or auditing whether code matches its docs.
---

# Explore

Build a live, evidence-based model of how a codebase works by reading the real source in parallel, and deliver the understanding in chat.

## Contract

Code is the only source of truth: READMEs, comments, and design docs are hints to verify, never facts to repeat. Every claim cites file:line or is flagged unverified. Output is IN CHAT ONLY: write no map file, no memory entry, nothing into the repo. About to BUILD there instead? Route to dmjcustomizations:exploring-codebases (persisted map plus anti-redundancy gate).

## Flow

1. **Recon** (you, fast): Glob and Grep for languages, manifests, entry points, top-level shape. No deep reads; this is triage for partitioning.
2. **Partition**: split the repo into 3 to 6 coherent slices by layer or feature boundary (API, domain, data, UI, jobs, shared). A user focus becomes the spine: still map everything, bias depth toward the focus.
3. **Fan out**: TeamCreate, then one explorer teammate per slice via Agent (team_name, name) in a single message so all run concurrently. If TeamCreate is unavailable, run the slices as native parallel Agent calls (read-only Explore agent type when present) and synthesize yourself.
4. **Explorer charter** (give each): identify the slice's purpose and key files with paths; trace real execution in and out; trace data reads and writes; find every cross-boundary link and CONFIRM the other side with the owning explorer via SendMessage rather than assuming; post a midway progress update; flag everything unverifiable and every place code contradicts docs.
5. **Synthesize**: reconcile boundary claims (on conflict, read the code yourself), then deliver in chat: system shape, execution flow, data flow, interconnection map, docs-versus-code discrepancies, unknowns. Cite file:line throughout.

## Red flags (stop)

- A claim only the README supports: verify in code or drop it.
- Explorers spawned one at a time: dispatch all in one message.
- A seam confirmed by only one of its two owning explorers.
- Any file written: this skill's output is chat only.
- "Presumably" or "probably" in the synthesis: trace it or list it as an unknown.

## When NOT to use

A single-fact lookup (just search), an area you already understand, or mapping before you build (that is dmjcustomizations:exploring-codebases). A team costs real tokens; do not spend it to find one function.

**Headless:** runs fully autonomous, no user gate; the synthesis lands in the final report.

Next: **dmjcustomizations:exploring-codebases** before building in the explored code, or **dmjcustomizations:brainstorming** once the change you want is understood.
