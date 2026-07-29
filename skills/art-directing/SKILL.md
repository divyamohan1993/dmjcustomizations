---
name: art-directing
description: Use when designing or restyling any UI surface (page, panel, dashboard, landing) or picking its visual identity (palette, type, layout, motion, morphic language). Symptoms: looks templated or AI-generated, must fill every screen size, "make it unique", "what colors".
---

# Art Directing

Every project earns a researched visual identity, never a default. dmj:crafting-experiences sets the bar, this hits it. **One identity per project**: panels share its tokens, each earns a signature. distinct across projects, cohesive within one.

## Gate 0: research before color

Before any pixel, in parallel (dmj:researching-deeply): (1) what the project IS, its world/vernacular; (2) the emotion the audience needs (trust, calm, focus, energy); (3) current best technique + 2 to 3 category-defining products read for principles, never to clone a look, never to reuse a past identity. palette derives from that EMOTION, not cliche/habit/flag (method, ratios, culture caveat: color-psychology.md). contrast = floor, not vibe: every pair AA, color-blind-safe, dark and light. reaching for a default attractor (dark + one neon accent, Inter/Space Grotesk, 1200px centered column, flag hue) = the signal this research got skipped; each is refused by a bar below.

## The token system (the artifact)

Named tokens, never prose: 4 to 6 core palette hex with roles (plus text tiers), type scale, spacing, radii, motion, as CSS vars or Tailwind. 2 to 3 type roles (display with personality, legible body, optional mono); **never the AI-default stack** (Inter/Space Grotesk/JetBrains Mono = the tell). perf (dmj:enforcing-performance-budgets): variable fonts, latin-subset, self-host or font-display:swap, preload hero weights. morphic language (skeuo, neu, glass, clay, flat, brutalist, aurora, bento, blend) research-chosen, never locked. handover = token file + live mock. a paragraph describing a look is not a spec.

## Non-negotiables

| Bar | Floor |
|---|---|
| Hero is a thesis | Open on the most characteristic thing in the subject's world, not a headline on a gradient |
| Hide nothing by size | Every element reaches every breakpoint. responsive reflows and rescales, never removes, never display:none by width. a nav may collapse to an accessible menu, items still reachable |
| Fill every edge, stay readable | Chrome/grids/visuals run edge-to-edge at every size. fill large and 4k by scaling the composition and reflowing the SAME content into columns, never data a small screen never sees, never a centered column in whitespace. text holds a 66 to 75ch measure as its type grows |
| One signature | One element carries the boldness, everything around it stays disciplined. high-energy is not noisy |
| Show, not tell | Cut chrome and decoration, not content: demonstrate, never narrate, every needed fact still visible. full semantic HTML+ARIA beneath (screen readers need the words). active voice, name what the user controls |
| Structure encodes meaning | Numbering, eyebrows, dividers only where they carry real information, never decoration |

## Screenshot-verify (HARD gate)

No "done" without it (dmj:verification-before-completion): screenshot every breakpoint (mobile-portrait, mobile-landscape, tablet, laptop, desktop, 4k) via Playwright MCP, contrast-check, critique, fix. confirm each shot is your page. Playwright genuinely absent (a failed launch, never a mere claim) -> per-breakpoint checklist + contrast math, numbers shown. self-asserted "looks responsive/AA" = not verification.

## Parallel pattern

Competing directions: 2 to 3 spikes (one named `Agent` each, single message), screenshots decide (dmj:dispatching-parallel-teams, dmj:brainstorming). user-facing diffs carry the experience lens (dmj:requesting-code-review).

**Headless:** research, derive tokens, build, screenshot-verify autonomously; PARK only brand calls (wordmark, hue), ship a default.

Next: dmj:crafting-experiences (the bar this serves), dmj:selling-the-vision (marketing surfaces); dmj:verification-before-completion proves every breakpoint.
