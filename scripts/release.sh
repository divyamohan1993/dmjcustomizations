#!/usr/bin/env bash
# One-command release: scripts/release.sh <version> "<commit message>"
# Requires: CHANGELOG already has the [<version>] entry (changelog-before-commit law).
# Bumps both manifests, validates, commits, pushes, refreshes the local install.
set -euo pipefail
cd "$(dirname "$0")/.."
V="${1:?usage: release.sh <version> \"<commit message>\"}"
MSG="${2:?usage: release.sh <version> \"<commit message>\"}"

grep -q "\[$V\]" CHANGELOG.md || { echo "ABORT: CHANGELOG.md has no [$V] entry. Changelog before commit."; exit 1; }
node -e "
const fs=require('fs');
for (const [f,set] of [['.claude-plugin/plugin.json',(j,v)=>j.version=v],['.claude-plugin/marketplace.json',(j,v)=>j.plugins[0].version=v]]) {
  const j=JSON.parse(fs.readFileSync(f,'utf8')); set(j,'$V'); fs.writeFileSync(f,JSON.stringify(j,null,2)+'\n');
}
console.log('manifests -> $V');"
bash scripts/validate.sh
git add -A
# Gate fires ONLY when skill behavior text changes (not version/CHANGELOG/script-
# only releases). Runs on a fast model: this is a safety net, not the author.
SKILL_DIFF=$(git diff --cached -- 'skills/*/SKILL.md')
if [ -n "$SKILL_DIFF" ] && command -v claude >/dev/null 2>&1; then
    echo "fresh-context behavioral-diff review (fast model)..."
    INTENT=$(git diff --cached -- CHANGELOG.md)
    VERDICT=$(claude -p --model sonnet --effort low --fallback-model haiku "Fresh-context reviewer for a skill-library release. Rules may MOVE: a removal is fine when relocated in this same diff or named in the CHANGELOG intent. Reply BLOCK only if a change INVERTS a rule, silently weakens or deletes a gate/Iron Law/rationalization row/red flag/number without relocation, or opens a loophole. FIRST line EXACTLY 'PASS' or 'BLOCK: <reason>'.
=== SKILL DIFF ===
$SKILL_DIFF
=== CHANGELOG INTENT ===
$INTENT" 2>/dev/null | grep -m1 -E '^(PASS|BLOCK)')
    case "$VERDICT" in
        PASS*) echo "diff review: PASS";;
        *) echo "diff review verdict: ${VERDICT:-no verdict}"; echo "ABORT: behavioral-diff review did not PASS."; exit 1;;
    esac
fi
git commit -m "$MSG

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git push
if command -v claude >/dev/null 2>&1; then
    claude plugin marketplace update dmj || true
    claude plugin update dmj@dmj || true
fi
echo "RELEASED $V"
