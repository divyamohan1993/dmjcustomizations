---
name: karpathy-laws
description: Use when generating any nontrivial code or factual claim, when a diff is growing past one reviewable concern, when consecutive fixes keep failing, when asserting an API, version, or behavior from memory, or when hallucination risk is high (unfamiliar library, long session, stale context).
---

# Karpathy Laws

Working rules distilled from Andrej Karpathy's public guidance on LLM-assisted coding. Goal: maximum throughput, minimum hallucination, no compounding errors.

## The laws

1. **Short leash.** Work in small, independently verifiable increments. One concern per change; never grow a diff past what one review pass can hold. Big ambitions become many small merges, not one large one.
2. **Receipts or it did not happen.** Never assert an API, version, flag, path, or behavior from memory when it can be read from source, docs, or a command. Read or run first, then claim, citing file:line or quoted output. Unverifiable right now: say "unverified" out loud. See dmjcustomizations:verification-before-completion and dmjcustomizations:researching-deeply.
3. **Externalize memory.** Context is amnesiac. Plans, decisions, and learnings go to files (spec, CHANGELOG, memory) the moment they exist; re-read the file before reusing it instead of trusting recall of it.
4. **Autonomy slider.** Scale autonomy to blast radius: full speed on reversible dev-machine work; hard gates on merges, deploys, data migrations, anything irreversible or outward-facing.
5. **Context hygiene.** Stale and bloated context breeds hallucination. Prefer a fresh read over a remembered file state; delegate bulk reading to teammates and keep only conclusions; drop dead context instead of carrying it.
6. **Concrete beats abstract.** A failing test, an example input/output pair, or a real error message steers generation better than prose instructions. Show, then ask.
7. **Determinism shell.** Surround stochastic generation with deterministic verification: types, lints, tests, CI gates. The model drafts; the harness decides. See dmjcustomizations:test-driven-development.
8. **Error-spiral brake.** Two consecutive failed fixes means STOP patching. Re-read the actual error, re-ground from the real files, route to dmjcustomizations:systematic-debugging. Never stack a guess on a guess.

## Red flags (stop)

- Quoting or editing a file not read in this session.
- "Should work" or "probably" attached to a claim a command could settle.
- A diff covering more than one concern.
- Fixing a fix of a fix.
- Citing a library API, version, or config key from memory.

**Headless:** all laws apply unattended; gates from law 4 park for the user instead of blocking.

Next: the law that fired decides the route, dmjcustomizations:verification-before-completion, dmjcustomizations:systematic-debugging, or dmjcustomizations:researching-deeply.
