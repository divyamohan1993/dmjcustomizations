# Experience Psychology

Method for engineering how a product feels, from primary research. Each principle carries a confidence grade and a build rule. Grades are honest: STRONG means replicated across domains; MODERATE means solid but context-sensitive; treat every mapping as a hypothesis to verify on your real users (dmj:verification-before-completion), never a law. Same discipline as art-directing/color-psychology.md: evidence first, cliche never.

## Principles

| Principle | Evidence (primary, dated) | Grade | Build rule |
|---|---|---|---|
| Response time gates flow | Doherty and Thadani 1982 (sub-400ms keeps users in flow); Card 1991 and Nielsen 1993 thresholds: ~100ms feels instant, ~1s keeps thought, ~10s loses attention | STRONG on the ordering, MODERATE on exact numbers | Acknowledge every action within ~100ms (optimistic UI), complete or show honest progress within ~400ms; budget it in dmj:enforcing-performance-budgets |
| Peak-end rule | Kahneman et al. 1993; Redelmeier and Kahneman 1996 (experiences judged by peak moment plus ending, not average) | STRONG | Engineer ONE deliberate peak per journey; land every session ending (a success state, a completed feeling); never end on a form, a spinner, or an error |
| Flow state | Csikszentmihalyi 1975, 1990 (clear goal, immediate feedback, challenge slightly above skill) | MODERATE (robust construct, varied operationalization) | First real success within seconds of arrival; visible feedback on every action; complexity revealed as skill grows, never all at once |
| Choice load | Hick 1952; Hyman 1953 (decision time grows with options); Cowan 2001 (~4 chunks in working memory) | STRONG direction | One primary action per screen; defaults over choices; progressive disclosure for depth |
| Aesthetic-usability | Kurosu and Kashimura 1995; Tractinsky et al. 2000 (attractive interfaces perceived as more usable, tolerated longer) | MODERATE to STRONG | Craft buys forgiveness; it never substitutes for function. Spend polish where the first second lands |
| Motion shows causality | Michotte 1946/1963 launching effect (timed motion is perceived as cause and effect) | STRONG perceptual finding | Transitions exist to show cause, effect, and object continuity (shared-element moves); decoration motion is cut; prefers-reduced-motion always respected |
| Endowed progress | Nunes and Dreze 2006 (visible earned progress accelerates completion); Kivetz, Urminsky and Zheng 2006 (goal-gradient acceleration near a real goal, field data) | MODERATE | Show real progress toward the user's goal: real goal, real gap. Fabricated or illusionary progress is a dark pattern, never shipped |
| Isolation effect | von Restorff 1933 (the distinctive item is remembered) | STRONG in memory research | One signature moment per surface (matches art-directing's one-signature bar); two competing peaks cancel |
| Personalization-privacy paradox | Awad and Krishnan 2006; Sutanto et al. 2013 (personalization raises value AND privacy concern; trust moderates both) | MODERATE | Adapt only from consented first-party signals, processed as close to the user as possible; explain adaptations on request. Surveillance-fed tailoring burns the trust personalization runs on |
| Variable reward compulsion | Skinner's schedules of reinforcement; documented in product "hook" models | STRONG mechanism, ethically radioactive | Never ship compulsion mechanics: streak guilt, infinite feeds tuned for retention, fabricated scarcity, fake urgency. Delight serves the user's goal, not the engagement metric. This is a floor, not a preference |
| Resumption, not tension | Ghibellini and Meier 2025 meta-analysis (no Zeigarnik memory advantage for unfinished tasks; a consistent Ovsiankina spontaneous-resumption tendency, no prompt needed) | STRONG | Interrupted work restores in one tap with exact state; never nag a return. The pull to resume already exists; the design job is removing re-entry friction, not manufacturing tension |
| Failure is a designed beat | Nielsen heuristics 3, 5, 9 (1994, NN/g maintained); Kaplan, NN/g 2022 (hostile error patterns) | STRONG authority consensus | Recover in place: input preserved, undo offered, validate after the field is finished; the message states what happened and the one way forward, never blame or ALL-CAPS alarm |
| Empty states are the first frame | Kaplan, NN/g 2021 | MODERATE to STRONG consensus | Every zero-data view states system status, teaches one thing, and opens one direct path to first value; a blank screen erodes confidence before the hook can land |
| One narrator | Moran, NN/g 2016, reviewed 2024 (trustworthiness explained ~52% of desirability variance vs ~8% for friendliness; playful tone reduced trust in serious domains) | MODERATE, measured | One voice across UI, errors, empty states, receipts, email; tone tuned to the domain's seriousness. "Friendly and playful" is not a safe default |
| Curiosity gaps | Loewenstein 1994 (inverted-U; curiosity as cognitively induced deprivation) | MODERATE theory | A reveal is legitimate only when the gap closes in-session; a gap held open for a retention metric is inflicted deprivation, banned with the compulsion mechanics |
| Offboarding is the resolution | GDPR Art 17 (erasure) and Art 20 (portability): legal floor. Warmth-at-exit improving brand: untested extension of session-scoped peak-end | CERTAIN legal, HYPOTHESIS brand | Export and deletion are first-class designed beats, reachable and confirmed, executable end to end (pairs with per-record crypto-shredding in dmj:defending-in-depth) |

## Method (per journey)

1. Name the journey and the feeling arc it should leave (calm, mastery, relief, awe): the emotional target, as in color-psychology.md.
2. Place the peak deliberately (the moment of value: the render finishes, the report lands, the share goes out) and design the ending to close warm.
3. Budget response times per the thresholds; wire them into the perf budgets so CI enforces feel.
4. Map every state change to visible propagation: one source of truth, every visible surface reflecting a change immediately, motion carrying cause and effect. Staleness anywhere breaks the world.
5. Verify on real flows: walk the journey, time the acknowledgments, screenshot the peak and the ending, confirm reduced-motion and every attunement signal honored.

## Anti-patterns

Tour-before-action onboarding (blocks flow); two heroes on one screen (isolation effect cancelled); celebration animation on trivial actions (peak inflation); progress bars that lie; personalization that requires an account before showing value; any mechanic whose success metric is time-in-app rather than user-goal-reached.

Excluded on evidence, never build: "you left something unfinished" return-nags and deliberate cliffhangers (Zeigarnik lacks universal validity; resumability is the evidenced design); points-badges-leaderboards veneer (small effects that destabilize under methodological rigor, Sailer and Homner 2020; the working ingredients are challenge, meaningful goals, narrative); narrative transportation as a UI goal (its measured signature is reduced critical scrutiny, Green and Brock 2000: a manipulation vector, and tool absorption is already flow); a literal three-act or hero's-journey arc mapped onto the UI (validated only in linear authored media; software is re-entrant and user-authored, and "rising action" prescribes friction. Keep the evidenced part: one peak, a landed ending).

Back to SKILL.md for the bars these serve.
