#!/bin/sh
# Install the humanize pre-push gate.
#   sh install.sh           install into the current repo
#   sh install.sh --global  set a chained global core.hooksPath for all repos
set -e
SRC=$(
  unset CDPATH
  cd -- "$(dirname -- "$0")" && pwd
)

repo() {
  ROOT=$(git rev-parse --show-toplevel)
  mkdir -p "$ROOT/.humanize"
  cp "$SRC/humanize-guard.mjs" "$SRC/humanize.mjs" "$ROOT/.humanize/"
  if [ -f "$ROOT/.husky/pre-push" ]; then
    cp "$SRC/hooks/pre-push" "$ROOT/.husky/pre-push.humanize"
    echo "husky found: added .husky/pre-push.humanize; call it from .husky/pre-push."
  else
    HK="$ROOT/.git/hooks/pre-push"
    if [ -f "$HK" ] && ! grep -q 'humanize pre-push gate' "$HK" 2>/dev/null; then
      mv "$HK" "$ROOT/.git/hooks/pre-push.local"
      chmod +x "$ROOT/.git/hooks/pre-push.local" 2>/dev/null || true
      echo "backed up existing pre-push to pre-push.local (the gate chains it)."
    fi
    cp "$SRC/hooks/pre-push" "$HK"
    chmod +x "$HK"
  fi
  echo "humanize: installed into $ROOT (.humanize/ + pre-push hook)."
  echo "CI: add  'node .humanize/humanize-guard.mjs --gate'  to your pipeline."
}

global() {
  DIR="$HOME/.humanize-hooks"
  # Fail closed if a global hooksPath already exists elsewhere: repointing it
  # would silently disable every hook living at the current path (secret
  # scanners included) for every repo on the machine.
  EXISTING=$(git config --global --get core.hooksPath 2>/dev/null || true)
  if [ -n "$EXISTING" ] && [ "$EXISTING" != "$DIR/hooks" ]; then
    echo "ABORT: global core.hooksPath is already $EXISTING."
    echo "Repointing it would silently disable the hooks living there for ALL repos."
    echo "Instead: chain $DIR/hooks/pre-push from that path, or unset it first:"
    echo "  git config --global --unset core.hooksPath"
    exit 1
  fi
  mkdir -p "$DIR/hooks"
  cp "$SRC/humanize-guard.mjs" "$SRC/humanize.mjs" "$DIR/"
  cp "$SRC/hooks/pre-push" "$DIR/hooks/pre-push"
  chmod +x "$DIR/hooks/pre-push"
  # core.hooksPath overrides .git/hooks for ALL hook types, which would silently
  # disable each repo's own pre-commit (e.g. a secret scanner). Re-run it.
  cat > "$DIR/hooks/pre-commit" <<'PC'
#!/bin/sh
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo .)
[ -x "$ROOT/.git/hooks/pre-commit" ] && { "$ROOT/.git/hooks/pre-commit" "$@" || exit 1; }
exit 0
PC
  chmod +x "$DIR/hooks/pre-commit"
  echo "WARNING: git core.hooksPath overrides EVERY repo's .git/hooks for ALL hook"
  echo "types, not just pre-push. This installer adds a pre-commit chainer that re-runs"
  echo "each repo's own .git/hooks/pre-commit, so a secret scanner is NOT disabled;"
  echo "the pre-push chains .husky/pre-push. Verify your setup after enabling."
  printf "Set core.hooksPath to %s/hooks for ALL repos? [y/N] " "$DIR"
  read -r a
  case "$a" in
    y|Y|yes) git config --global core.hooksPath "$DIR/hooks"; echo "global gate set." ;;
    *) echo "skipped. Files staged at $DIR; set it yourself when ready." ;;
  esac
}

case "${1:-}" in --global) global ;; *) repo ;; esac
