---
name: crafting-experiences
description: Use when building, changing, or reviewing anything a user sees or touches (page, component, app, flow, CLI output, error message), when deciding whether a feature should exist, how a project is delivered, or how it should feel, or when work looks done but feels generic, clunky, or burdensome.
---

# Crafting Experiences

Ship experiences, not software. code = means, feeling = product. tech removes hassle, automates burden, never mints chores (dashboards/settings/manuals/docs) the user tends. selling to a prospect, not designing use -> dmj:selling-the-vision.

## Gate 0: the Jobs test

One sentence each: who, when, why life gets genuinely easier. needs explanation -> rethink the product, not the pitch. no concrete user+moment+relief = perfect product of no use. kill it.

## Non-negotiables

| Bar | Floor |
|---|---|
| First second | Hooks instantly. distinctive, memorable, never template-mistakable; mistakable -> redesign. first impressions happen once: polish deferred = polish never seen |
| One story | One story, minimal interaction surface: obvious next step always, zero config/upkeep, Apple-grade straightforward. one narrator = one voice across UI/errors/receipts/email, tone tuned to domain seriousness, never default-playful. story-forking feature, or a control the story does not need -> cut |
| Story edges | Edges = designed beats, not leftovers. onboarding: first value < 30s or user lost forever. first frame: every zero-data state names status, teaches one thing, opens one path to first value. failure: error = product moment, recover in place, input preserved, undo offered, no blame. loading: progress, never blank. interruption: one-tap resume at exact state, never a return-nag. ending: export+deletion reachable, confirmed, executable end to end |
| Cinematic with purpose | Tactile depth, micro-interactions, transitions serving comprehension. delight > decoration. every animation earns existence. reduced motion respected |
| Burden | Every feature subtracts hassle; adds steps/choices/upkeep -> no ship. every option = decision tax: adapt from signals already held (locale, color scheme, reduced motion, device, usage), visible control only where adaptation is impossible. count user actions on the path, cut to minimum (saved defaults, one primary action per screen, optional fields collapsed) before shipping, never a later sprint |
| Completeness | MLP not MVP = minimum LOVABLE product. end-to-end working or not shipped. last 10% = where the product lives. defaults ARE the product. say no to 100, ship 1. zero TODO/placeholder/dead control in any user-facing path |
| Accessibility | A right, not a feature. WCAG 2.2 AAA target, AA = never-below floor: keyboard, screen reader, focus order, reduced motion, high contrast, captions, alt text, no color-only meaning. blind/deaf/motor/ADHD/anxiety/cognitive/low-vision/color-blind = equal userbase from line one, never degrade one for another |
| Baseline device | Slow phone, bad internet, small town. works there = works everywhere: core flow completes on 3G on low-end Android |
| Language | Multilingual from line one: Hindi+English+regional baseline, zero hardcoded strings, RTL-ready, locale-aware dates/numbers/currency/pluralization, tested in Devanagari + long-text expansion |
| Offline | Offline-first wherever the product plausibly meets a dead zone. network = a lie: cache shown instantly, staleness marked subtly, writes queued+retried, user data never lost, conflict resolution defined before code |
| Self-evidence | Needs docs to start -> design failed. docs only where they remove hassle, selling the vision in seconds |
| Delivery | Default = web: one URL, zero install, every device. other mode (offline-first, native, CLI) only where it genuinely serves the user better (no connectivity, heavy local compute, privacy), tradeoffs shown, built after the user confirms |
| Coherent world | One source of truth. a change lands everywhere visible, immediately, transition showing cause and effect. stale panels, refresh-to-see, lagging counts = defects, not quirks |
| Engineered feeling | Journeys built to researched psychology (method: experience-psychology.md): first real success in seconds, one deliberate peak, every ending lands. personalization only from consented first-party signals processed close to the user. compulsion mechanics (streak guilt, engagement-tuned feeds, fake scarcity) never ship |
| Longevity | Outlives trends: web standards first, enhancement on top, user data portable+exportable. still running and still current years out = part of the experience |

## Artifact rule (agent contracts, not documentation)

Specs/maps/plans here = working artifacts for agents: one screen, terse, feeding machine-checkable gates. never docs a human must read to proceed, or maintain to keep correct.

## Parallel pattern

User-facing diff -> experience lens on the review panel (dmj:requesting-code-review), beside security and performance. competing visual directions = parallel spikes decided by screenshots, in dmj:art-directing.

Deadline moves no bar: it buys a fast distinctive pass, never a default one. "it works" without the feeling fails the product.

**Headless:** apply autonomously; PARK taste calls that define brand identity + any switch off web delivery.

Next: dmj:brainstorming gates what gets built; dmj:requesting-code-review carries the lens; dmj:verification-before-completion proves end to end.
