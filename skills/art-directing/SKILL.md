---
name: art-directing
description: Use when designing or restyling any UI surface (page, panel, dashboard, component, landing) and picking its visual identity (palette, type, layout, motion, morphic language), especially when it risks looking templated or generic, must fill every screen size, or needs colors that psychologically fit the project. Symptoms: "make it unique", "design the UI", "what colors", "responsive across all devices", "don't make it look AI-generated".
---

# Art Directing

Every project earns a researched visual identity, never a default. dmj:crafting-experiences sets the bar; this hits it. **One identity per project**: panels share its tokens, each earns a signature; distinct across projects, cohesive within one.

## Gate 0: research before color

Before any pixel, in parallel (dmj:researching-deeply): (1) what the project IS, its world and vernacular; (2) the emotion the audience needs (trust, calm, focus, energy); (3) the current-best technique, never hardcoded. Derive the palette from that EMOTION, not cliché or habit. **Contrast wins**: every pair meets WCAG AA, color-blind-safe, dark and light. Low-contrast is a failure, not a vibe.

## The token system (the artifact)

Emit named tokens, never prose: 4 to 6 core palette hex with roles (plus text tiers), type scale, spacing, radii, motion, as CSS vars or Tailwind. 2 to 3 type roles (display with personality, legible body, optional mono); **never the AI-default stack** (Inter / Space Grotesk / JetBrains Mono is the tell). Perf wins (dmj:enforcing-performance-budgets): variable fonts, latin-subset, self-host or font-display:swap, preload hero weights. Morphic language (skeuo, neu, glass, clay, flat, brutalist, aurora, bento, blend) research-chosen, never locked.

## Non-negotiables

| Bar | Floor |
|---|---|
| Hero is a thesis | Open with the most characteristic thing in the subject's world, not a headline on a gradient |
| Hide nothing by size | Every element reaches every breakpoint; responsive reflows and rescales, never removes or display:none by width. A nav may collapse to an accessible menu, items still reachable |
| Fill every edge, stay readable | Chrome, grids, visuals run edge-to-edge at every size. Fill large and 4k by scaling the composition and reflowing the SAME content into columns, never adding data a small screen never sees, never a centered column in whitespace. Text holds a 66 to 75ch measure as its type grows |
| One signature | A single element carries the boldness; everything around it stays disciplined. High-energy is not noisy |
| Show, not tell | Cut chrome and decoration, not content: demonstrate, do not narrate, yet every needed fact stays visible. Full semantic HTML and ARIA beneath (screen readers need the words); active voice, name what the user controls |
| Structure encodes meaning | Numbering, eyebrows, dividers only when they carry real information, never decoration |

## Screenshot-verify (HARD gate)

No "done" without it (dmj:verification-before-completion): screenshot every breakpoint (mobile-portrait, mobile-landscape, tablet, laptop, desktop, 4k) via Playwright MCP, contrast-check, critique, fix. Confirm each shot is your page. Playwright genuinely absent (a failed launch, never a mere claim): a per-breakpoint checklist plus contrast math, numbers shown. Self-asserted "looks responsive/AA" is not verification.

## Parallel pattern

Competing directions: a team runs 2 to 3 spikes (TeamCreate + Agent, team_name), screenshots decide (dmj:dispatching-parallel-teams, dmj:brainstorming). User-facing diffs carry the experience lens (dmj:requesting-code-review). TeamCreate unavailable: native parallel Agent calls, judge yourself.

## Rationalizations (all false)

| Excuse | Reality |
|---|---|
| "Dark bg plus one neon accent" | An AI-default look; research a palette |
| "Inter / Space Grotesk is safe" | Safe is the template tell; distinctive type is the cheapest identity |
| "Saffron because India" | Cliché is not researched emotion; derive color from the feeling the audience needs |
| "Add a column or metric for big screens" | Then it is hidden on small ones; reflow the same content, never viewport-exclusive content |

## Red flags (stop)

- Any element shown at one screen size and hidden at another.
- "Done" or "verified" without proof (a failed launch, a per-shot page check).
- A default font stack, a dark-plus-neon palette, or color by habit.
- One identity on every project, or ten unrelated looks inside one.

**Headless:** research, derive tokens, build, screenshot-verify autonomously; PARK only brand calls (wordmark, hue), ship a logged default.

Next: dmj:crafting-experiences (the bar this serves), dmj:selling-the-vision (marketing surfaces); dmj:verification-before-completion proves every breakpoint.
