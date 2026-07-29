---
name: art-directing
description: Use when designing or restyling any UI surface (page, panel, dashboard, landing) or picking its visual identity (palette, type, layout, motion, morphic language). Symptoms: looks templated or AI-generated, must fill every screen size, "make it unique", "what colors".
---

# Art Directing

Every project earns a researched visual identity, never a default. dmj:crafting-experiences sets the bar; this hits it. **One identity per project**: panels share its tokens, each earns a signature; distinct across projects, cohesive within one.

## Gate 0: research before color

Before any pixel, in parallel (dmj:researching-deeply): (1) what the project IS, its world and vernacular; (2) the emotion the audience needs (trust, calm, focus, energy); (3) the current best technique, plus 2 to 3 category-defining products read for the principles behind them, never to clone a look and never to reuse a past project's identity. Derive the palette from that EMOTION, not from cliché, habit, or a flag (method, ratios, and the culture caveat: color-psychology.md). Contrast is a floor, not a vibe: every pair AA, color-blind-safe, dark and light.

## The token system (the artifact)

Emit named tokens, never prose: 4 to 6 core palette hex with roles (plus text tiers), type scale, spacing, radii, motion, as CSS vars or Tailwind. 2 to 3 type roles (display with personality, legible body, optional mono); **never the AI-default stack** (Inter / Space Grotesk / JetBrains Mono is the tell). Perf wins (dmj:enforcing-performance-budgets): variable fonts, latin-subset, self-host or font-display:swap, preload hero weights. Morphic language (skeuo, neu, glass, clay, flat, brutalist, aurora, bento, blend) research-chosen, never locked. Hand a direction over as the token file plus a live mock; a paragraph describing a look is not a spec.

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

Competing directions: a team runs 2 to 3 spikes (one named `Agent` per direction, spawned in a single message), screenshots decide (dmj:dispatching-parallel-teams, dmj:brainstorming). User-facing diffs carry the experience lens (dmj:requesting-code-review).

## The default attractors

Name them or you drift into them, because habit and hurry both land here: a dark background plus one neon accent; the Inter / Space Grotesk stack; a 1200px centered column with the screen wasted around it; a hue chosen from a flag or a logo; a column, metric, or panel that exists only above a breakpoint. Every one is already refused by a bar above. Reaching for one is the signal that research got skipped.

**Headless:** research, derive tokens, build, screenshot-verify autonomously; PARK only brand calls (wordmark, hue), ship a default.

Next: dmj:crafting-experiences (the bar this serves), dmj:selling-the-vision (marketing surfaces); dmj:verification-before-completion proves every breakpoint.
