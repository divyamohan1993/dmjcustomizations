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
SKILL_DIFF=$(git diff --cached -- 'skills/*/SKILL.md' CHANGELOG.md)
if [ -n "$SKILL_DIFF" ] && command -v claude >/dev/null 2>&1; then
    echo "fresh-context behavioral-diff review..."
    VERDICT=$(claude -p "You are a fresh-context reviewer for a Claude Code skill library release. Below is the staged diff (skill files + CHANGELOG, which states intent). Rules may MOVE: a removal is fine when the rule is relocated in this same diff or the CHANGELOG names the fold target. Reply BLOCK only if a change INVERTS a rule's meaning, silently weakens or deletes a gate, Iron Law, rationalization row, red flag, or number without relocation, or opens a loophole. FIRST line of your reply must be exactly PASS or BLOCK: <one-line reason>.
$SKILL_DIFF" 2>/dev/null | grep -m1 -E '^(PASS|BLOCK)')
    case "$VERDICT" in
        PASS*) echo "diff review: PASS";;
        *) echo "diff review verdict: ${VERDICT:-no verdict}"; echo "ABORT: behavioral-diff review did not PASS."; exit 1;;
    esac
elif [ -n "$SKILL_DIFF" ]; then
    echo "WARN: claude CLI absent; skill diff shipped unreviewed"
fi
git commit -m "$MSG

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git push
if command -v claude >/dev/null 2>&1; then
    claude plugin marketplace update dmjcustomizations || true
    claude plugin update dmjcustomizations@dmjcustomizations || true
fi
echo "RELEASED $V"
