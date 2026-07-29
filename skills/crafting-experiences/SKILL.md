---
name: crafting-experiences
description: Use when building, changing, or reviewing anything a user sees or touches (page, component, app, flow, CLI output, error message), when deciding whether a feature should exist, how a project is delivered, or how it should feel, or when work looks done but feels generic, clunky, or burdensome.
---

# Crafting Experiences

We ship experiences, not software. Code is the means; how it makes the user feel is the product. Tech exists to remove hassle and automate burden, never to create chores (dashboards, settings, manuals, documentation) the user must tend. (Selling it to a prospect, not designing its use? dmj:selling-the-vision.)

## Gate 0: the Jobs test

Before building, answer in one sentence each: who uses this, when, and why does it make their life genuinely easier? An answer that needs explanation means rethink the product, not the pitch. No concrete user, moment, and relief: a perfect product of no use. Kill it.

## Non-negotiables

| Bar | Floor |
|---|---|
| First second | The experience hooks attention immediately; distinctive, memorable, never mistakable for a template. Mistakable for a template: redesign. First impressions happen once, so polish scheduled for later is polish the user never sees |
| One story | An app is one complete story with a minimal interaction surface: an obvious next step at every moment, nothing to configure or tend, Apple-grade straightforwardness. One narrator: a single voice across UI, errors, receipts, email, tone tuned to the domain's seriousness, never default-playful. A feature that forks the narrative or adds a control the story does not need: cut |
| Story edges | The journey's edges are designed beats, not leftovers. First frame: every zero-data state names status, teaches one thing, opens one path to first value. Failure: recover in place, input preserved, undo offered, no blame. Interruption: one-tap resume with exact state, never a return-nag (the pull to resume already exists; remove re-entry friction). Ending: export and deletion are reachable, confirmed, executable end to end |
| Cinematic with purpose | Tactile depth, micro-interactions, transitions that serve comprehension. Delight beats decoration; every animation earns existence; reduced motion respected |
| Burden | Every feature must subtract hassle. A feature that adds steps, choices, or upkeep does not ship; every option is a decision tax, so adapt from signals the product already has (locale, color scheme, reduced motion, device, usage) and add a visible control only where adaptation is impossible. Count the user's actions along the path and cut it to the minimum (saved defaults, one primary action per screen, optional fields collapsed) before shipping, never in a later sprint |
| Completeness | End-to-end working or not shipped. No TODO, placeholder, or dead control in any user-facing path |
| Accessibility | A right, not a feature: WCAG 2.2 AA floor, keyboard, screen reader, captions, no color-only meaning |
| Self-evidence | If the user needs documentation to start, the design failed. Docs only where they remove hassle, selling the vision in seconds |
| Delivery | Default is the web platform: visit a URL, zero install, every device. Propose a different mode (offline-first, native, CLI) only when it genuinely serves the user better (no-connectivity work, heavy local compute, privacy), tradeoffs shown, built only after the user confirms |
| Coherent world | One source of truth; a change is reflected everywhere it is visible, immediately, with the transition showing cause and effect. Stale panels, refresh-to-see, and counts that lag the truth are defects, not quirks |
| Engineered feeling | Journeys designed to researched psychology (method: experience-psychology.md): first real success in seconds, one deliberate peak, every ending lands. Personalization only from consented first-party signals, processed close to the user; compulsion mechanics (streak guilt, engagement-tuned feeds, fake scarcity) never ship |
| Longevity | Built to outlive trends: web standards first, enhancement layered on top, user data portable and exportable. Still running and still current years out is part of the experience |

## Artifact rule (agent contracts, not documentation)

Specs, maps, and plans this library writes are working artifacts for agents: one screen, terse, feeding machine-checkable gates. Never produce documentation a human must read to proceed or maintain to stay correct.

## Parallel pattern

User-facing diff: an **experience lens** joins the review panel (dmj:requesting-code-review) beside security and performance. Competing visual directions run as parallel spikes decided by screenshots, in dmj:art-directing.

Under deadline pressure the bars hold: a deadline buys a fast distinctive pass, never a default one, and "it works" without the feeling fails the product.

**Headless:** apply these bars autonomously; PARK for the user both taste decisions that define brand identity and any switch away from web delivery.

Next: dmj:brainstorming gates what gets built; dmj:requesting-code-review carries the lens; dmj:verification-before-completion proves it works end to end.
