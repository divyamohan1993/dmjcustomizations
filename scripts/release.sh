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
git commit -m "$MSG

Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>"
git push
if command -v claude >/dev/null 2>&1; then
    claude plugin marketplace update dmjcustomizations || true
    claude plugin update dmjcustomizations@dmjcustomizations || true
fi
echo "RELEASED $V"
