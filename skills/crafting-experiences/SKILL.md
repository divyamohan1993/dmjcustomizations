---
name: crafting-experiences
description: Use when building, changing, or reviewing anything a user sees or touches (a page, component, app, flow, CLI output, onboarding, error message, email), when deciding whether a feature should exist, or when work looks done but feels generic, clunky, or burdensome.
---

# Crafting Experiences

We ship experiences, not software. Code is the means; how it makes the user feel is the product. Tech exists to remove hassle and automate burden, never to create chores (dashboards, settings, manuals, documentation) the user must tend.

## Gate 0: the Jobs test

Before building, answer in one sentence each: who uses this, when, and why does it make their life genuinely easier? An answer that needs explanation means rethink the product, not the pitch. No concrete user, moment, and relief: a perfect product of no use. Kill it.

## Non-negotiables

| Bar | Floor |
|---|---|
| First second | The experience hooks attention immediately; distinctive, memorable, never mistakable for a template. Mistakable for a template: redesign |
| Cinematic with purpose | Tactile depth, micro-interactions, transitions that serve comprehension. Delight beats decoration; every animation earns existence; reduced motion respected |
| Burden | Every feature must subtract hassle. A feature that adds steps, choices, or upkeep does not ship |
| Completeness | End-to-end working or not shipped. No TODO, placeholder, or dead control in any user-facing path |
| Accessibility | A right, not a feature: WCAG 2.2 AA floor, keyboard, screen reader, captions, no color-only meaning |
| Self-evidence | If the user needs documentation to start, the design failed. Docs only where they remove hassle, selling the vision in seconds |

## Artifact rule (agent contracts, not documentation)

Specs, maps, and plans this library writes are working artifacts for agents: one screen, terse, feeding machine-checkable gates. Never produce documentation a human must read to proceed or maintain to stay correct.

## Parallel pattern

User-facing diff: an **experience lens** joins the review panel (dmj:requesting-code-review) beside security and performance. Competing visual directions: parallel spikes in disposable worktrees, screenshots decide (dmj:brainstorming). TeamCreate unavailable: run the lens as a native parallel Agent call.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "It works, ship it" | Working but burdensome fails the product; the user remembers the feeling, not the function |
| "Polish later" | First impressions happen once; later is after the user left |
| "Users will read the docs" | Needing docs to start IS the defect |
| "A template is faster" | A template is forgettable; forgettable has zero value |
| "More options = more value" | Every option is a decision tax; the best default removes the choice |

## Red flags (stop)

- Could be mistaken for a generic template.
- Animation that decorates instead of explains.
- A user-facing TODO, placeholder, or dead end.
- A feature that adds steps or upkeep for the user.
- Shipping something that needs explanation to use.
- Creating an artifact a human must maintain.

**Headless:** apply these bars autonomously; PARK taste decisions that define brand identity for the user.

Next: dmj:brainstorming gates what gets built; dmj:requesting-code-review carries the lens; dmj:verification-before-completion proves it works end to end.
