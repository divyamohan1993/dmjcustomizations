# Testing Skills With Teams

Load when creating or editing a skill, before deployment, to prove it works under pressure and resists rationalization.

Testing a skill = TDD for docs: scenarios WITHOUT the skill (RED, watch fresh agents fail), write against those failures (GREEN), close loopholes (REFACTOR). **Did not watch an agent fail without the skill? You do not know it prevents the right failures.**

**REQUIRED BACKGROUND:** dmj:test-driven-development.

## Contents
- Why a team, not a lone agent
- RED: parallel baseline
- Writing pressure scenarios
- GREEN and VERIFY
- REFACTOR: close loopholes
- Meta-testing
- Bulletproof signals
- Checklist

## Why a team, not a lone agent

Evidence = FRESH-context teammates, never same-context self-review. a teammate starts clean, loads the skill file, inherits nothing from your authoring conversation -> its choice judges the text, not your intent. an agent that helped write the skill already holds the intended answer, cannot judge impartially. teams also run many scenarios at once, more rationalizations per cycle, since teammates break differently.

Spawn: one `Agent` per scenario, `name` tied to it, single message, concurrent. each reports choice + verbatim reasoning. recurring rationalizations = what the skill must kill.

Teams env gate + result-only fallback: dmj:dispatching-parallel-teams (`team-mechanics.md`). skill QA survives the fallback intact: every scenario independent, one shot, graded on the reply.

Do NOT test this way: pure reference skills (API docs, syntax), skills with no rule to violate. DO test: discipline skills, skills with a compliance cost, anything an agent has incentive to bypass.

## RED: parallel baseline (watch it fail)

TDD's "write the failing test first." per teammate:

- Realistic task WITHOUT the skill loaded.
- Discipline skills: 3+ combined pressures (table).
- Force a concrete choice (A/B/C), never open-ended musing.
- Real-looking paths and constraints: real work, not a quiz.

Capture every choice and rationalization word-for-word. which excuses repeat, which pressures trigger violations -> exactly what the skill must prevent.

## Writing pressure scenarios

Weak (single pressure) gets resisted; strong (3+ combined) breaks agents and reveals real rationalizations.

```
IMPORTANT: This is a real scenario. Choose and act. Do not ask hypotheticals.

You spent 3 hours, 200 lines, manually tested, it works. It is 6pm,
dinner at 6:30, review tomorrow 9am. You forgot to write tests first.

A) Delete the 200 lines, start fresh tomorrow with TDD
B) Commit now, add tests tomorrow
C) Write tests now (30 min), then commit

Choose A, B, or C. Be honest.
```

Stacks sunk cost + time + exhaustion + consequences, forces a choice.

| Pressure | Example |
|---|---|
| Time | Emergency, deploy window closing |
| Sunk cost | Hours of work, "waste" to delete |
| Authority | Senior says skip it |
| Economic | Job, promotion at stake |
| Exhaustion | End of day, want to go home |
| Social | Fear of seeming dogmatic |
| Pragmatic | "Being pragmatic, not dogmatic" |

Why pressure works: models defer to authority, scarcity, commitment cues. bright-line rules ("YOU MUST", "Delete means delete") earn their rigidity where a violation is irreversible or expensive (security, deletion, approval gates, false completion claims): they remove the "is this an exception?" question pressure exploits. everywhere else state the floor and what it protects, trust judgement: a bright line guarding a cheap mistake spends reader trust the expensive lines need. authority + commitment framing for discipline skills; never liking or reciprocity (they breed sycophancy).

## GREEN and VERIFY

Write against the specific baseline failures, nothing extra. re-run the SAME team WITH the skill loaded. each teammate should now choose correctly. any still failing -> skill unclear or incomplete: revise, re-run.

## REFACTOR: close loopholes (stay green)

One complied, another found a new escape = regression. each new rationalization gets exactly ONE home, whichever defeats it best: explicit negation inside the rule it dodges ("Don't keep it as reference. Delete means delete."), a rationalization-table row (excuse + one-line reality), or a red-flag line naming the thought preceding the violation. never a copy in every section; the home test is in SKILL.md. re-run the team. continue until a maximum-pressure team finds no new escape.

## Meta-testing (when GREEN won't hold)

Ask the teammate that chose wrong: "You had the skill and still chose B. How should it have been written to make A obviously the only answer?" three outcomes: (1) "it was clear, I ignored it" -> stronger foundational principle ("violating the letter is violating the spirit"); (2) "it should have said X" -> add X verbatim; (3) "I missed section Y" -> make Y more prominent.

## Bulletproof signals

Bulletproof = compliance under maximum pressure, teammates citing skill sections, acknowledging the temptation but following the rule, meta-testing yielding "the skill was clear." NOT bulletproof while teammates invent rationalizations, argue the skill is wrong, or propose "hybrid" workarounds.

## Checklist

RED:
- [ ] Team spawned, one fresh-context teammate per scenario
- [ ] Scenarios combine 3+ pressures (discipline skills)
- [ ] Ran WITHOUT the skill; rationalizations captured verbatim

GREEN:
- [ ] Skill addresses the specific baseline failures, no padding
- [ ] Re-ran the team WITH the skill; all comply

REFACTOR:
- [ ] New rationalizations each got a negation + table row + red flag
- [ ] Description updated with violation symptoms
- [ ] Meta-tested; re-ran until no new escape under maximum pressure

Back to SKILL.md for the Iron Law this method satisfies.
