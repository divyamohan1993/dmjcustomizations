#!/bin/sh
# Install the humanize pre-push gate.
#   sh install.sh           install into the current repo
#   sh install.sh --global  set a chained global core.hooksPath for all repos
set -e
SRC=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

repo() {
  ROOT=$(git rev-parse --show-toplevel)
  mkdir -p "$ROOT/.humanize"
  cp "$SRC/humanize-guard.mjs" "$SRC/humanize.mjs" "$ROOT/.humanize/"
  if [ -f "$ROOT/.husky/pre-push" ]; then
    cp "$SRC/hooks/pre-push" "$ROOT/.husky/pre-push.humanize"
    echo "husky found: added .husky/pre-push.humanize; call it from .husky/pre-push."
  else
    cp "$SRC/hooks/pre-push" "$ROOT/.git/hooks/pre-push"
    chmod +x "$ROOT/.git/hooks/pre-push"
  fi
  echo "humanize: installed into $ROOT (.humanize/ + pre-push hook)."
  echo "CI: add  'node .humanize/humanize-guard.mjs --gate'  to your pipeline."
}

global() {
  DIR="$HOME/.humanize-hooks"
  mkdir -p "$DIR/hooks"
  cp "$SRC/humanize-guard.mjs" "$SRC/humanize.mjs" "$DIR/"
  cp "$SRC/hooks/pre-push" "$DIR/hooks/pre-push"
  chmod +x "$DIR/hooks/pre-push"
  echo "WARNING: core.hooksPath overrides every repo's .git/hooks. The hook chains"
  echo ".husky/pre-push so husky and lefthook still run, but verify your setup."
  printf "Set core.hooksPath to %s/hooks for ALL repos? [y/N] " "$DIR"
  read a
  case "$a" in
    y|Y|yes) git config --global core.hooksPath "$DIR/hooks"; echo "global gate set." ;;
    *) echo "skipped. Files staged at $DIR; set it yourself when ready." ;;
  esac
}

case "${1:-}" in --global) global ;; *) repo ;; esac
