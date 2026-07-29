# Color Psychology: deriving a palette from emotion

Gate 0 reference for dmj:art-directing. color "meaning" is **not universal**: context-dependent, part learned, part biological (color-in-context theory; Elliot & Maier, 2012). reject deterministic myths ("red means X" everywhere). two solid levers:

1. **Ecological valence** (Palmer & Schloss, PNAS, 2010): people prefer colors tied to objects they like; average valence of a color's associated objects predicted ~80% of preference. so a *positive* palette = hues whose real-world referents the audience finds pleasant (clear-sky and water blues, daylight, foliage greens, ripe-fruit warms), avoiding referents they dislike (rot and sludge browns, sickly yellow-greens, bile).
2. **Context and culture**: the same hue shifts meaning by context and locale. natural and perceptual associations travel, object-derived and symbolic ones do not (Madden, Hewett & Roth, 8-country study, 2000: gray read "cheap" in China and Japan but not the US; red meant "love" widely yet also "good-tasting" in China). check the audience's locale before trusting any symbolic reading.

## Method (run inside Gate 0)

1. **State the emotional target** the research found: what the audience must FEEL in the first second (trust + competence for fintech, calm focus for a health tool, momentum for fitness).
2. **Pick referents, not cliches.** for that emotion + the project's world, name positively-valenced real things, take their hues (trust and calm: deep ocean, night sky, evergreen; energy: sunrise, citrus). the valence move, and it dodges the "saffron because India" trap (a flag symbol, not a researched feeling).
3. **Build in OKLCH** (perceptually even; equal lightness steps look equal across hues; all modern browsers + Tailwind 4). lightness ladder first, one high-chroma accent for the signature, neutrals tinted from the same hue family, never pure `#000`/`#fff`. OKLCH lightness is perceptual, not WCAG luminance: it makes contrast *predictable*, never *assumed*, so still compute the real ratio.
4. **Accessibility overrides vibe, always.** every text pair >= 4.5:1 (3:1 large text and UI/graphics), aim 7:1 for body. never meaning by hue alone (pair with text, icon, or underline); separate states by lightness too, so color-blind users still read them; mirror to dark mode via the same OKLCH ladder. contrast = the single most common web accessibility failure, do not add to it.
5. **Verify with numbers, not eyes.** compute every ratio (WebAIM or equivalent), simulate color-vision deficiency (protan/deutan/tritan), then screenshot per the skill's HARD gate.

## Emotion -> starting hue (HYPOTHESES to verify, not laws)

| Audience feeling | Positively-valenced anchors | Watch |
|---|---|---|
| Trust, competence, calm | Blues, teals, deep greens (sky, water, evergreen) | Generic corporate blue = the safe-default; differentiate via chroma and neutrals |
| Focus, clarity | Cool neutrals + one restrained accent | Too little chroma reads flat; let the accent carry the energy |
| Energy, optimism | Warm saturated: coral, amber, citrus (sunrise, fruit) | High chroma + low contrast = unreadable; hold AA |
| Warmth, care | Soft warm earths, rose, peach | Muddy browns carry negative valence (rot); keep them clean and light |
| Premium, depth | Deep tinted near-blacks + one precise accent | The AI-default "dark + neon"; use only where research earns it, and make the accent ownable |

## Confidence

- Ecological-valence preference, context-dependence of meaning, cultural variance of symbolic colors: **established** (primary sources below).
- Specific hue -> emotion mappings: **weak and contested**. treat the table as hypotheses, test on the real audience. hue effects on emotion are real but modest; the durable wins are valence (liked referents), legibility, and a distinctive, non-default execution.
- What reopens this: a palette that tests poorly with the actual audience, or any pair failing the contrast math. vibe never overrides the math.

## Sources

- Elliot, A. J. (2015). "Color and psychological functioning: a review of theoretical and empirical work." *Frontiers in Psychology*, 6:368.
- Elliot, A. J., & Maier, M. A. (2012). "Color-in-Context Theory." *Advances in Experimental Social Psychology*.
- Palmer, S. E., & Schloss, K. B. (2010). "An ecological valence theory of human color preference." *PNAS*, 107(19):8877-8882.
- Madden, T. J., Hewett, K., & Roth, M. S. (2000). "Managing Images in Different Cultures: A Cross-National Study of Color Meanings and Preferences." *Journal of International Marketing*, 8(4).
- W3C WCAG 2.2 (2023), success criteria 1.4.3 (contrast minimum) and 1.4.11 (non-text contrast).
- OKLCH in CSS: baseline browser support since 2023; adopted by Tailwind CSS 4 (2025).

Back to SKILL.md for Gate 0 and the bars this feeds.
