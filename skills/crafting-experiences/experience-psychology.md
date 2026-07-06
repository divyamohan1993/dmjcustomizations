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
| Endowed progress | Nunes and Dreze 2006 (visible earned progress accelerates completion) | MODERATE | Show real progress toward the user's goal; fabricated progress is a dark pattern, never shipped |
| Isolation effect | von Restorff 1933 (the distinctive item is remembered) | STRONG in memory research | One signature moment per surface (matches art-directing's one-signature bar); two competing peaks cancel |
| Personalization-privacy paradox | Awad and Krishnan 2006; Sutanto et al. 2013 (personalization raises value AND privacy concern; trust moderates both) | MODERATE | Adapt only from consented first-party signals, processed as close to the user as possible; explain adaptations on request. Surveillance-fed tailoring burns the trust personalization runs on |
| Variable reward compulsion | Skinner's schedules of reinforcement; documented in product "hook" models | STRONG mechanism, ethically radioactive | Never ship compulsion mechanics: streak guilt, infinite feeds tuned for retention, fabricated scarcity, fake urgency. Delight serves the user's goal, not the engagement metric. This is a floor, not a preference |

## Method (per journey)

1. Name the journey and the feeling arc it should leave (calm, mastery, relief, awe): the emotional target, as in color-psychology.md.
2. Place the peak deliberately (the moment of value: the render finishes, the report lands, the share goes out) and design the ending to close warm.
3. Budget response times per the thresholds; wire them into the perf budgets so CI enforces feel.
4. Map every state change to visible propagation: one source of truth, every visible surface reflecting a change immediately, motion carrying cause and effect. Staleness anywhere breaks the world.
5. Verify on real flows: walk the journey, time the acknowledgments, screenshot the peak and the ending, confirm reduced-motion and every attunement signal honored.

## Anti-patterns

Tour-before-action onboarding (blocks flow); two heroes on one screen (isolation effect cancelled); celebration animation on trivial actions (peak inflation); progress bars that lie; personalization that requires an account before showing value; any mechanic whose success metric is time-in-app rather than user-goal-reached.

Back to SKILL.md for the bars these serve.
