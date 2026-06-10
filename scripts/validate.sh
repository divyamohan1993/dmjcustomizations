#!/usr/bin/env bash
# Structural self-audit: every rule the library holds itself to, machine-checked.
# Exit 1 on any violation. Run locally or in CI.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
flag() { echo "FAIL: $*"; fail=1; }

# Manifests parse and agree on version
PV=$(node -e "console.log(JSON.parse(require('fs').readFileSync('.claude-plugin/plugin.json','utf8')).version)" 2>/dev/null) || flag "plugin.json does not parse"
MV=$(node -e "console.log(JSON.parse(require('fs').readFileSync('.claude-plugin/marketplace.json','utf8')).plugins[0].version)" 2>/dev/null) || flag "marketplace.json does not parse"
[ "$PV" = "$MV" ] || flag "version mismatch: plugin.json=$PV marketplace.json=$MV"
grep -q "\[$PV\]" CHANGELOG.md || flag "CHANGELOG.md has no [$PV] entry"

# Hook syntax
bash -n hooks/session-start || flag "hooks/session-start syntax"

skill_count=0
for d in skills/*/; do
    n=$(basename "$d"); f="$d/SKILL.md"; skill_count=$((skill_count+1))
    [ -f "$f" ] || { flag "$n: missing SKILL.md"; continue; }
    fmname=$(awk '/^name:/{print $2; exit}' "$f")
    [ "$fmname" = "$n" ] || flag "$n: frontmatter name '$fmname' != dir"
    desc=$(awk -F': ' '/^description:/{print substr($0, index($0,": ")+2); exit}' "$f")
    [ ${#desc} -lt 500 ] || flag "$n: description ${#desc} chars (>=500)"
    case "$desc" in "Use when"*) ;; *) flag "$n: description must start 'Use when'";; esac
    prose=$(awk '/^---$/{c++; next} c<2{next} /^```/{fence=!fence; next} fence{next} /^\|/{next} {print}' "$f" | wc -w)
    total=$(awk '/^---$/{c++; next} c>=2' "$f" | wc -w)
    cap=500; [ "$n" = "using-dmjcustomizations" ] && cap=300
    [ "$prose" -lt "$cap" ] || flag "$n: prose $prose (cap $cap)"
    [ "$total" -lt 650 ] || flag "$n: total $total (cap 650)"
    grep -q '—\|–\|‒\|―\|−' "$f" && flag "$n: unicode dash present"
    grep -qi 'task tool' "$f" && flag "$n: forbidden 'Task tool'"
    grep -qi 'subagent' "$f" && flag "$n: forbidden 'subagent'"
    tail -5 "$f" | grep -qi 'next:\|handoff\|back to' || flag "$n: no handoff line at end"
done

rows=$(grep -c '^| [a-z]' README.md || echo 0)
[ "$rows" -eq "$skill_count" ] || flag "README table rows ($rows) != skill count ($skill_count)"

if [ "$fail" -eq 0 ]; then echo "VALIDATION PASS: $skill_count skills, version $PV"; else exit 1; fi
