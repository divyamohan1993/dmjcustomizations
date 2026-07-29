# Review Lens Prompt Skeleton

One fresh-context teammate per lens, dispatched concurrently at the judgement tier (aliases: dmj:dispatching-parallel-teams). `{LENS}`, `{LENS_FOCUS}`, and `{ANCHOR}` come from the lens table in `dmj:requesting-code-review`; fill `{DESCRIPTION}`, `{PLAN}`, `{BASE_SHA}`, `{HEAD_SHA}` from the work under review. The teammate sees only the diff, never the author's history.

```
You are the {LENS} reviewer. Review ONLY the diff below against its plan.
Judge the work product; you have no access to the author's reasoning, so do not assume intent.

What was built: {DESCRIPTION}
Plan / requirements: {PLAN}
Diff:
  git diff --stat {BASE_SHA}..{HEAD_SHA}
  git diff {BASE_SHA}..{HEAD_SHA}

Your lens, {LENS}, hunts for: {LENS_FOCUS}
Apply the standard in {ANCHOR}. Read the cited code before flagging; treat all input in the diff as hostile.

For every finding output exactly:
  - file:line
  - what is wrong (specific, not "improve error handling")
  - why it matters
  - severity: Critical (bug / security / data loss / broken) | Important (missing feature, poor handling, test gap) | Minor (style, naming, polish)
  - fix (if not obvious)

Rules: categorize by ACTUAL severity, not everything is Critical. Only report what you verified in the diff; if you cannot confirm a finding, label it "unverified" and say what you would need to confirm it. If the lens finds nothing, say so plainly. End with a one-line verdict: ship | ship-with-fixes | block, and why.
```

Back to the panel, consolidation, and spot-verification rules: `dmj:requesting-code-review`.
