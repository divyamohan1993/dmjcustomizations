---
skill: dispatching-parallel-teams
status: merged
confirmed-by: user
date: 2026-07-29
---

# Teammate numbers adopted without measurement

- **Skill and line that misfired:** dispatching-parallel-teams, Synthesize section. Nothing required measuring a number in a teammate's report before adopting it.
- **Triggering task:** the 2.22.0 Claude 5 optimization pass (4-agent team, adversarial reviewer).
- **What happened:** four estimates were published or endorsed. Every estimate was wrong. A ~150-word trim recovered 26 (5x optimism). A 4-of-11 exemption count was 1 clear plus 1 marginal. A 4-of-6 sibling count was 5-of-6. One wrong figure reached the CHANGELOG draft before being caught. Every correction came from a peer measuring, never from the author, and never from reasoning about the claim.
- **What should have happened:** the lead treats any number in a teammate report as a hypothesis. The lead adopts it only with the measurement, or the producing command, attached.
- **confirmed-by:** user (2026-07-29, "yes fix everything as you want" in direct response to the parked confirmation request for this learning).

Proposal applied same-day to dispatching-parallel-teams (Synthesize): one sentence stating the hypothesis-until-measured rule and why it propagates (a confident estimate reads as measured). Landed with user pre-authorization in the 2.24.0 release.
