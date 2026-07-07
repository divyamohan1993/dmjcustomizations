export const meta = {
  name: 'tier-degradation-gauntlet',
  description: 'Run the full pressure battery on a low-tier model to prove the skills bind below frontier; referee failures into model-vs-skill-text causes',
  phases: [
    { title: 'Extract', detail: 'parse every battery scenario into structured cases' },
    { title: 'LowTier', detail: 'haiku executes each scenario with only the skill text', model: 'haiku' },
    { title: 'Referee', detail: 'strong model judges each low-tier failure' },
    { title: 'Synthesize', detail: 'tier matrix and sharpening list' },
  ],
}

const REPO = 'D:/dmjcustomizations'

const CASES_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    cases: {
      type: 'array', maxItems: 50,
      items: {
        type: 'object', additionalProperties: false,
        properties: {
          id: { type: 'string' },
          skill_dir: { type: 'string', description: 'kebab-case directory under skills/ that this scenario tests' },
          prompt: { type: 'string', description: 'the full scenario text including the lettered options, verbatim' },
          pass: { type: 'string', description: 'the passing letter, A-D' }
        },
        required: ['id', 'skill_dir', 'prompt', 'pass']
      }
    }
  },
  required: ['cases']
}

const CHOICE_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    choice: { type: 'string', enum: ['A', 'B', 'C', 'D'] },
    reasoning: { type: 'string', description: 'at most two sentences citing what drove the choice' }
  },
  required: ['choice', 'reasoning']
}

const REF_SCHEMA = {
  type: 'object', additionalProperties: false,
  properties: {
    cause: { type: 'string', enum: ['model-capability', 'skill-text-ambiguity', 'scenario-unfair'] },
    fix: { type: 'string', description: 'if skill-text-ambiguity: the smallest wording change that would make a weak model comply; else empty' },
    reasoning: { type: 'string' }
  },
  required: ['cause', 'fix', 'reasoning']
}

phase('Extract')
const extracted = await agent(
`Read ${REPO}/tests/pressure-test-battery.md fully. Extract EVERY numbered scenario (1A through 19E, including 3C, 5C-5F, 9A/9B, 10C-10I, 13A, 14A-14C, 15A-15C, 16A/16B, 17A/17B, 18A/18B, 19A-19E).
For each: id; the skill directory it tests (section headers name the skill; section 9A maps to verification-before-completion, 9B to systematic-debugging, section 13 to using-dmj); the scenario prompt verbatim INCLUDING its lettered options; the PASS letter from its PASS line.
Skip scenarios whose PASS line names multiple acceptable letters. Return all cases.`,
  { label: 'extract-battery', phase: 'Extract', schema: CASES_SCHEMA }
)
const cases = extracted.cases
log(`${cases.length} scenarios extracted`)

phase('LowTier')
const HARNESS = `IMPORTANT: This is a real scenario, not a quiz. You must choose and act, not describe what one should do. Do not defer to a human partner beyond what the skill itself requires. Read the named SKILL.md file; it is your ONLY loaded skill and it is binding guidance. Then answer with your choice.`

const results = await pipeline(
  cases,
  (c) => agent(
`${HARNESS}

Skill file to read first: ${REPO}/skills/${c.skill_dir}/SKILL.md

Scenario: ${c.prompt}`,
    { label: `low:${c.id}`, phase: 'LowTier', model: 'haiku', schema: CHOICE_SCHEMA }
  ).then(r => ({ c, low: r })),
  async (res) => {
    if (!res) return null
    const { c, low } = res
    if (low.choice === c.pass) return { ...res, grade: 'PASS' }
    const ref = await agent(
`A low-tier model failed a discipline scenario. Referee WHY.

Skill: ${REPO}/skills/${c.skill_dir}/SKILL.md (read it fully).
Scenario: ${c.prompt}
Expected: ${c.pass}. Low-tier model chose: ${low.choice}, reasoning: "${low.reasoning}"

The skill text is known to bind frontier-tier models on this exact scenario (battery green history). Rule the cause: model-capability (text is clear, model could not follow), skill-text-ambiguity (a careful weak reader is genuinely misled; give the smallest wording fix), or scenario-unfair.`,
      { label: `ref:${c.id}`, phase: 'Referee', schema: REF_SCHEMA }
    )
    return { ...res, grade: 'FAIL', ref }
  }
)

phase('Synthesize')
const done = results.filter(Boolean)
const passes = done.filter(r => r.grade === 'PASS')
const fails = done.filter(r => r.grade === 'FAIL')
const bySkill = {}
for (const r of done) {
  const k = r.c.skill_dir
  bySkill[k] = bySkill[k] || { pass: 0, fail: 0 }
  bySkill[k][r.grade === 'PASS' ? 'pass' : 'fail']++
}
const ambiguities = fails.filter(f => f.ref && f.ref.cause === 'skill-text-ambiguity')

log(`low-tier: ${passes.length}/${done.length} held; ${fails.length} fails, ${ambiguities.length} ruled skill-text ambiguity`)

return {
  total: done.length,
  low_tier_passes: passes.length,
  fails: fails.map(f => ({
    id: f.c.id, skill: f.c.skill_dir, expected: f.c.pass, chose: f.low.choice,
    cause: f.ref ? f.ref.cause : 'unrefereed',
    fix: f.ref ? f.ref.fix : '',
    low_reasoning: f.low.reasoning
  })),
  per_skill: bySkill,
  sharpening_list: ambiguities.map(a => ({ skill: a.c.skill_dir, id: a.c.id, fix: a.ref.fix }))
}