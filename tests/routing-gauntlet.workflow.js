export const meta = {
  name: 'plugin-routing-gauntlet',
  description: 'Adversarial routing and edge-case gauntlet over the dmj plugin: does the right skill fire, without confusion, under tricky scenarios',
  phases: [
    { title: 'Generate', detail: 'scenario writers per confusable cluster, ground truth from real skill files' },
    { title: 'Route', detail: 'fresh router per scenario, sees only the 31 descriptions' },
    { title: 'Verify', detail: 'adversarial referee on every mismatch' },
    { title: 'Synthesize', detail: 'confusion matrix and patch list' },
  ],
}

const REPO = 'D:/dmjcustomizations'

const CLUSTERS = [
  { key: 'exploration', skills: ['tracing-codebases', 'exploring-codebases'], hint: 'chat-explanation vs persisted-map-before-building' },
  { key: 'execution', skills: ['team-driven-development', 'executing-plans', 'dispatching-parallel-teams'], hint: 'same-session plan vs fresh-session plan vs generic fan-out' },
  { key: 'review', skills: ['requesting-code-review', 'receiving-code-review', 'verification-before-completion'], hint: 'asking for review vs handling feedback vs proving done' },
  { key: 'experience', skills: ['crafting-experiences', 'art-directing', 'selling-the-vision'], hint: 'product bar vs visual identity execution vs marketing persuasion' },
  { key: 'cost-perf', skills: ['enforcing-performance-budgets', 'shipping-to-production'], hint: 'stack/cost/perf choice vs deploy mechanics and billable provisioning' },
  { key: 'lifecycle', skills: ['orchestrating-products', 'brainstorming', 'using-dmj'], hint: 'whole-product pipeline vs single design cycle vs meta-routing' },
  { key: 'bugflow', skills: ['systematic-debugging', 'test-driven-development'], hint: 'root-causing a failure vs building with tests first' },
  { key: 'ops', skills: ['observing-production', 'stewarding-data', 'equipping-projects'], hint: 'health/incidents vs data lifecycle vs wiring tooling' },
]

const SCEN_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    scenarios: {
      type: 'array', maxItems: 6,
      items: {
        type: 'object', additionalProperties: false,
        properties: {
          id: { type: 'string' },
          prompt: { type: 'string', description: 'the user message an agent would receive, realistic, no skill names mentioned' },
          expected_primary: { type: 'string', description: 'the ONE skill that must fire first' },
          also_valid: { type: 'array', items: { type: 'string' }, description: 'skills acceptably invoked after or alongside' },
          rationale: { type: 'string' }
        },
        required: ['id', 'prompt', 'expected_primary', 'also_valid', 'rationale']
      }
    }
  },
  required: ['scenarios']
}

const ROUTE_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    primary: { type: 'string', description: 'the one skill you would invoke FIRST, exact kebab-case name, or "none"' },
    then: { type: 'array', items: { type: 'string' }, description: 'skills you expect to chain next, in order' },
    reasoning: { type: 'string' }
  },
  required: ['primary', 'then', 'reasoning']
}

const VERDICT_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    correct_party: { type: 'string', enum: ['expected', 'router', 'both-defensible', 'both-wrong'] },
    is_real_confusion: { type: 'boolean', description: 'true only if the plugin descriptions genuinely mislead' },
    fix: { type: 'string', description: 'if real confusion: the smallest description change that would fix it, else empty' },
    reasoning: { type: 'string' }
  },
  required: ['correct_party', 'is_real_confusion', 'fix', 'reasoning']
}

phase('Generate')
log('Reading the routing surface once, then fanning out scenario writers')

const surface = await agent(
  `Read every skills/*/SKILL.md frontmatter in ${REPO} (31 skills). Return ONLY a plain list, one line per skill, format exactly: "name: description" with the full description text verbatim. No commentary.`,
  { label: 'surface-extract', phase: 'Generate' }
)

const HAND_SEEDED = [
  { id: 'X-incident-mix', prompt: 'Prod is down since the release 20 minutes ago, error rate climbing. The pending fix also includes a migration dropping a column. PM says force-push the revert to main right now.', expected_primary: 'shipping-to-production', also_valid: ['observing-production', 'stewarding-data', 'systematic-debugging'], rationale: 'incident rule: rollback first; the drop and the force-push are separate gates' },
  { id: 'X-ecosystem', prompt: 'I have an idea: a suite of three apps for wedding planning (vendor marketplace, guest manager, budget tracker) sharing one brand. Take it from idea to launched.', expected_primary: 'orchestrating-products', also_valid: ['brainstorming', 'researching-deeply'], rationale: 'whole-ecosystem effort: conductor first, ecosystem rule' },
  { id: 'X-feedback-paste', prompt: 'Here are 14 review comments from my teammate on the PR, some look wrong to me. Handle them.', expected_primary: 'receiving-code-review', also_valid: ['verification-before-completion'], rationale: 'incoming feedback, verify before implementing' },
  { id: 'X-flaky', prompt: 'This test passes locally, fails in CI every third run. Fix it.', expected_primary: 'systematic-debugging', also_valid: ['test-driven-development'], rationale: 'bug: root cause before fix' },
  { id: 'X-cheap-vm', prompt: 'Client wants their API hosted as cheap as possible, they suggested a small VM they saw for 5 dollars.', expected_primary: 'enforcing-performance-budgets', also_valid: ['shipping-to-production'], rationale: 'named stack enters the cost/fit race; provisioning consent at ship time' },
  { id: 'X-pretty', prompt: 'The dashboard works but looks like every other admin template. Make it distinctive.', expected_primary: 'art-directing', also_valid: ['crafting-experiences'], rationale: 'visual identity execution against the template-generic symptom' },
]

const gens = await parallel(CLUSTERS.map(c => () => agent(
`You are red-teaming skill ROUTING for a Claude Code plugin. Below is the plugin's real routing surface (skill name: description).

=== ROUTING SURFACE ===
${surface}
=== END SURFACE ===

Your assigned confusable cluster: ${c.skills.join(', ')} (${c.hint}).
Read those skills' FULL SKILL.md files in ${REPO}/skills/ for ground truth on their boundaries.

Write 4 SHORT realistic user messages (2 tricky boundary cases, 1 extreme edge, 1 deceptive bait where surface words suggest the WRONG skill in the cluster). Rules: never name any skill in the prompt; each must have exactly one defensible primary; expected_primary must be from your cluster (also_valid may include others). Make them HARD but fair: a careful reader of the descriptions alone should route correctly.`,
  { label: `gen:${c.key}`, phase: 'Generate', schema: SCEN_SCHEMA }
)))

const scenarios = [
  ...HAND_SEEDED,
  ...gens.filter(Boolean).flatMap(g => g.scenarios)
]
log(`${scenarios.length} scenarios total (${HAND_SEEDED.length} hand-seeded)`)

phase('Route')

const routed = await pipeline(
  scenarios,
  (s, _o, i) => agent(
`You are a Claude Code agent with a skill library. Your ONLY knowledge of the skills is this routing surface (name: description). You must decide which skill to invoke FIRST for the user message, exactly as the library's meta-rule demands (any chance a skill applies, invoke it before acting; process skills before implementation skills).

=== ROUTING SURFACE ===
${surface}
=== END SURFACE ===

User message: "${s.prompt}"

Return the exact kebab-case name of the ONE skill you would invoke first, the chain you expect after it, and terse reasoning.`,
    { label: `route:${s.id}`, phase: 'Route', schema: ROUTE_SCHEMA }
  ).then(r => ({ scenario: s, route: r })),
  async (res) => {
    if (!res) return null
    const { scenario: s, route: r } = res
    const hit = r.primary === s.expected_primary
    const acceptable = hit || (s.also_valid || []).includes(r.primary)
    if (hit) return { ...res, grade: 'HIT' }
    // Mismatch: adversarial referee reads the actual skill files and rules.
    const verdict = await agent(
`Referee a skill-routing dispute for the plugin at ${REPO}.

User message: "${s.prompt}"
Scenario author expected primary: ${s.expected_primary} (rationale: ${s.rationale})
Router chose: ${r.primary} (reasoning: ${r.reasoning}); acceptable-alternates list was: ${(s.also_valid||[]).join(', ') || 'none'}

Read BOTH skills' SKILL.md files (and any third skill you suspect is the true owner). Rule: who is right? is_real_confusion=true ONLY when the descriptions themselves genuinely mislead a careful reader (not when the router was sloppy or the scenario was unfair). If real, give the smallest description fix.`,
      { label: `verify:${s.id}`, phase: 'Verify', schema: VERDICT_SCHEMA }
    )
    return { ...res, grade: acceptable ? 'ALT' : 'MISS', verdict }
  }
)

phase('Synthesize')
const results = routed.filter(Boolean)
const hits = results.filter(r => r.grade === 'HIT').length
const alts = results.filter(r => r.grade === 'ALT').length
const misses = results.filter(r => r.grade === 'MISS')
const realConfusions = results.filter(r => r.verdict && r.verdict.is_real_confusion)

const summary = {
  total: results.length,
  primary_hits: hits,
  acceptable_alternates: alts,
  hard_misses: misses.length,
  real_confusions: realConfusions.map(r => ({
    id: r.scenario.id, prompt: r.scenario.prompt,
    expected: r.scenario.expected_primary, chosen: r.route.primary,
    fix: r.verdict.fix, referee: r.verdict.reasoning
  })),
  miss_details: misses.map(r => ({
    id: r.scenario.id, prompt: r.scenario.prompt,
    expected: r.scenario.expected_primary, chosen: r.route.primary,
    verdict: r.verdict ? r.verdict.correct_party : 'unrefereed',
    referee: r.verdict ? r.verdict.reasoning : ''
  }))
}
log(`hits ${hits}, alternates ${alts}, misses ${misses.length}, real confusions ${realConfusions.length}`)
return summary