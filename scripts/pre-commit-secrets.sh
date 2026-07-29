#!/usr/bin/env bash
#
# pre-commit-secrets.sh — diff-scoped secret guard for git pre-commit.
#
# WHAT IT DOES
#   Blocks a commit that would ADD an API key, OAuth token, private key, or a
#   sensitive-variable assignment. It scans ONLY the staged additions
#   (`git diff --cached`), never the repository history or the working tree.
#   Cost is O(staged diff), not O(repo) — it stays sub-second on a 1M-line
#   codebase because the size of one commit's diff does not grow with the repo.
#
# WHY DIFF-SCOPED
#   A pre-commit hook runs on every commit. Scanning the whole tree (or full
#   history) on each commit makes commits unusably slow once a repo is large,
#   which trains people to `--no-verify` and defeats the guard. Full-history
#   scanning belongs in CI (see the footer), run once per push, not per commit.
#
# ENGINE (first available wins)
#   1. gitleaks  (preferred, if on PATH) — the authoritative scanner, run in its
#      native staged mode so it parses the diff itself.
#   2. perl      — a SINGLE in-process pass over the staged diff with precompiled
#      PCRE. Always present on Windows (Git for Windows ships perl) and on macOS
#      / most Linux. This is the engine that actually runs on a stock Git-Bash
#      box, where `ripgrep` is usually NOT installed as a real binary.
#   3. ripgrep   — a SINGLE rg pass over the added lines (one awk pass attaches
#      real file:line first). Only for hosts that genuinely have rg on PATH.
#   Each engine is one constant-process-count pass over the staged diff; none
#   spawn a process per line. Fails CLOSED: if no engine is available the commit
#   is refused, never allowed through unscanned.
#
# ESCAPE HATCHES (use deliberately)
#   - Per line:   append a trailing comment  gitleaks:allow
#                 (also honors  pragma: allowlist secret )
#   - Per commit: git commit --no-verify     (discouraged; bypasses ALL hooks)
#
# OUTPUT
#   On a hit: prints  file:line  with the secret value MASKED (never in full),
#   exits 1 (commit aborted). On a clean diff: exits 0. Prints its own runtime
#   in milliseconds to stderr either way.
#
# INSTALL (do NOT run from this script; wire it explicitly)
#   Single repo:   ln -sf "$(pwd)/scripts/pre-commit-secrets.sh" .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
#   All repos:     copy/symlink into your  core.hooksPath  dir as `pre-commit`
#                  (find it with:  git config --get core.hooksPath )
#
set -u

# ---- runtime clock (milliseconds) -------------------------------------------
# date +%s%N is nanoseconds on Git Bash / coreutils. Guard against a platform
# that lacks %N (prints the literal 'N') so timing never crashes the hook.
_now_ms() {
  local ns
  ns="$(date +%s%N 2>/dev/null)"
  case "$ns" in
    *N|"") date +%s000 ;;        # no %N support → second resolution, ms-padded
    *)     printf '%s' "$(( ns / 1000000 ))" ;;
  esac
}
_START_MS="$(_now_ms)"

_report_runtime() {
  local end ms
  end="$(_now_ms)"
  ms=$(( end - _START_MS ))
  [ "$ms" -lt 0 ] && ms=0
  printf '\033[2m  secret-guard: scanned staged diff in %s ms\033[0m\n' "$ms" >&2
}
trap _report_runtime EXIT

# ---- fast exit when nothing is staged ---------------------------------------
# --diff-filter=ACM: only Added/Copied/Modified content can introduce a secret;
# pure deletions and renames cannot. -U0: zero context lines, so we never scan
# unchanged surrounding code. --no-color: keep ANSI out of the parsed stream.
DIFF="$(git diff --cached --unified=0 --no-color --diff-filter=ACM 2>/dev/null)"
if [ -z "$DIFF" ]; then
  exit 0
fi

# =============================================================================
# Engine 1: gitleaks (authoritative). Native staged mode parses the diff itself.
# =============================================================================
if command -v gitleaks >/dev/null 2>&1; then
  # --redact hides secret values in gitleaks output; --no-banner keeps it quiet;
  # --staged scopes it to `git diff --cached`. v8.19+ uses `git --staged`;
  # `protect --staged` is the pre-8.19 form (deprecated but still works), used
  # as a fallback so an older binary still scans rather than erroring out.
  # gitleaks reads .gitleaks.toml from the repo root automatically if present,
  # so per-repo allowlists/custom rules are honored with no extra wiring.
  if gitleaks git --staged --redact --no-banner --exit-code 1 . >&2 2>/dev/null; then
    exit 0
  else
    rc=$?
    # rc==1 → findings. Any other non-zero (bad flags on an old binary, etc.)
    # → retry the legacy command before deciding.
    if [ "$rc" -ne 1 ]; then
      if gitleaks protect --staged --redact --exit-code 1 >&2 2>/dev/null; then
        exit 0
      fi
    fi
    printf '\n\033[31m✖ Commit blocked: gitleaks found secret(s) in staged changes (values redacted above).\033[0m\n' >&2
    printf '  Fix: move the secret to an untracked .env, keep a placeholder in .env.example.\n' >&2
    printf '  False positive: add  gitleaks:allow  on the line, or bypass once with  git commit --no-verify .\n' >&2
    exit 1
  fi
fi

# =============================================================================
# Engine 2: perl (single in-process PCRE pass over the staged diff).
#
# This is the fallback that actually runs on a stock Git-for-Windows box: perl
# is always present, ripgrep usually is not. The whole scan is ONE perl process
# reading the diff on stdin — detection, allowlist, masking, and file:line
# reporting in a single pass, no per-line subprocess. Patterns mirror the shapes
# gitleaks flags by default: provider key prefixes, PEM private-key headers,
# JWT triple, and "<sensitive-name> = <long value>" assignments.
# =============================================================================
if command -v perl >/dev/null 2>&1; then
  GUARD="$(cat <<'PERL'
binmode(STDERR, ":utf8");
my ($file, $lineno, $findings) = ("(unknown)", 0, 0);

# Precompiled once; reused for every line (no per-line process spawn).
# Honors both gitleaks' own pragma (gitleaks:allow) and the detect-secrets-style
# "pragma: allowlist secret", plus obvious placeholder tokens.
my $allow = qr/(gitleaks:allow|allowlist secret|your_|_here|example|dummy|sample|changeme|placeholder|redacted|xxxx|<[a-z0-9_-]+>|\*\*\*\*)/i;

# 1) High-confidence token shapes (match anywhere on the line).
my $hi = qr/(sk-[A-Za-z0-9]{20,}|gh[posru]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,}|ya29\.[0-9A-Za-z_-]{20,}|glpat-[A-Za-z0-9_-]{20,}|sk_live_[A-Za-z0-9]{20,}|-----BEGIN[A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{6,})/;

# 2) Secret-context assignment: a sensitive var name set to a long value.
my $ctx = qr/(api[_-]?key|secret|token|password|passwd|client[_-]?secret|access[_-]?key|private[_-]?key|map[_-]?key|auth[_-]?token|bearer)["' ]*[:=][ "']*[A-Za-z0-9\/+_=-]{16,}/i;

# For masked display: pull the first secret-looking substring out of the line.
my $extract = qr/(sk-[A-Za-z0-9]{20,}|gh[posru]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,}|ya29\.[0-9A-Za-z_-]{20,}|glpat-[A-Za-z0-9_-]{20,}|sk_live_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{6,}|[A-Za-z0-9\/+_=-]{16,})/;

while (my $l = <STDIN>) {
  chomp $l;
  if ($l =~ /^\+\+\+ (.*)/) { my $f = $1; $f =~ s{^b/}{}; $file = $f; next; }
  if ($l =~ /^\@\@ -[0-9,]+ \+([0-9]+)/) { $lineno = $1; next; }
  next unless ($l =~ /^\+/ && $l !~ /^\+\+\+/);

  my $c = substr($l, 1);
  next if $c =~ $allow;
  if ($c =~ $hi || $c =~ $ctx) {
    my $sec = ($c =~ $extract) ? $1 : $c;
    my $m = (length($sec) <= 8) ? "********"
          : substr($sec, 0, 4) . "\x{2026}" . substr($sec, -2);
    print STDERR "\n\e[31m\x{2717} Commit blocked: possible secret(s) detected in staged changes.\e[0m\n\n" if $findings == 0;
    print STDERR "  $file:$lineno\n    $m\n";
    $findings++;
  }
  $lineno++;
}

if ($findings > 0) {
  print STDERR <<'MSG';

Never commit credentials. To fix:
  1. Move the secret into an untracked .env (ensure .env is in .gitignore).
  2. Keep a .env.example with a dummy placeholder value instead.
  3. Unstage the offending file:  git restore --staged <file>   (working copy is untouched)

False positive? Append a trailing  gitleaks:allow  comment to that line,
or bypass once (sparingly) with:  git commit --no-verify
MSG
  exit 1;
}
exit 0;
PERL
)"
  # Here-string feed (not `printf | perl`): reuses the already-captured diff
  # with no extra subprocess and no pipe, ~2x faster than the pipe form on a
  # multi-thousand-line worst-case diff (measured ~105ms vs ~190ms / 6.4k lines).
  perl -e "$GUARD" <<< "$DIFF"
  exit $?
fi

# =============================================================================
# Engine 3: ripgrep (only on hosts that genuinely have rg on PATH).
#
# One awk pass turns the unified diff into a stream of  "<file>:<line>:<text>"
# for ADDED lines only (tracking the +N hunk header to compute true line nums).
# That stream is piped through a SINGLE rg invocation. Process count is
# constant; work is linear in the staged diff. The patterns mirror the shapes
# gitleaks flags by default: provider key prefixes, PEM private-key headers,
# JWT triple, and "<sensitive-name> = <long value>" assignments.
# =============================================================================
if command -v rg >/dev/null 2>&1; then
  # Build the added-lines stream. awk is one pass, no per-line subprocess.
  ADDED="$(
    printf '%s\n' "$DIFF" | awk '
      /^\+\+\+ /        { f = $0; sub(/^\+\+\+ /, "", f); sub(/^b\//, "", f); next }
      /^@@ /            { ln = $0; sub(/^@@ -[0-9,]+ \+/, "", ln); sub(/[, ].*$/, "", ln); lineno = ln + 0; next }
      /^\+/ && !/^\+\+\+/ { print f ":" lineno ":" substr($0, 2); lineno++; next }
      /^ /              { lineno++; next }   # context line (rare at -U0) advances line counter
    '
  )"
  [ -z "$ADDED" ] && exit 0

  # Allowlist: drop intentional placeholders and pragma-marked lines BEFORE the
  # secret scan, so they can never trip it. Case-insensitive.
  ALLOW='gitleaks:allow|allowlist secret|your_|_here|example|dummy|sample|changeme|placeholder|redacted|xxxx|<[a-z0-9_-]+>|\*\*\*\*'

  # High-confidence provider shapes (anchored to known prefixes) + structural
  # secrets (PEM, JWT). These are low-false-positive on their own.
  HI='sk-[A-Za-z0-9]{20,}|gh[posru]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{30,}|AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,}|ya29\.[0-9A-Za-z_-]{20,}|glpat-[A-Za-z0-9_-]{20,}|sk_live_[A-Za-z0-9]{20,}|-----BEGIN[A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{6,}'

  # Secret-context assignment: a sensitive variable name set to a long value.
  # Requires the name→value shape so it does not fire on prose mentioning these
  # words. Case-insensitive (applied via the -i pass below).
  CTX='(api[_-]?key|secret|token|password|passwd|client[_-]?secret|access[_-]?key|private[_-]?key|map[_-]?key|auth[_-]?token|bearer)["'"'"' ]*[:=][ "'"'"']*[A-Za-z0-9/+_=-]{16,}'

  # Single combined scan. -P (PCRE2) for the alternations and lookahead-free
  # shapes; -i so CTX/ALLOW match regardless of case; -N keeps our injected
  # file:line prefix intact (no rg-added numbering). We first strip allowlisted
  # lines (rg -v), then match HI or CTX in one more pass.
  HITS="$(
    printf '%s\n' "$ADDED" \
      | rg -v -iP "$ALLOW" \
      | rg -iP "($HI)|($CTX)" -N 2>/dev/null
  )"

  if [ -n "$HITS" ]; then
    printf '\n\033[31m✖ Commit blocked: possible secret(s) detected in staged changes.\033[0m\n\n' >&2
    # Print each hit as  file:line  with the value masked. The hit line is
    # "<file>:<lineno>:<text>"; mask any secret-looking token in <text>.
    printf '%s\n' "$HITS" | while IFS= read -r hit; do
      loc="${hit%%:*}"; rest="${hit#*:}"
      lno="${rest%%:*}"; txt="${rest#*:}"
      # Extract the first secret-looking token for masked display.
      tok="$(printf '%s' "$txt" | rg -oP "$HI|[A-Za-z0-9/+_=-]{16,}" -N 2>/dev/null | head -n1)"
      [ -z "$tok" ] && tok="$txt"
      n=${#tok}
      if [ "$n" -le 8 ]; then masked='********'; else masked="${tok:0:4}…${tok: -2}"; fi
      printf '  %s:%s\n    %s\n' "$loc" "$lno" "$masked" >&2
    done
    cat >&2 <<'MSG'

Never commit credentials. To fix:
  1. Move the secret into an untracked .env (ensure .env is in .gitignore).
  2. Keep a .env.example with a dummy placeholder value instead.
  3. Unstage the offending file:  git restore --staged <file>   (working copy is untouched)

False positive? Append a trailing  gitleaks:allow  comment to that line,
or bypass once (sparingly) with:  git commit --no-verify
MSG
    exit 1
  fi
  exit 0
fi

# =============================================================================
# No engine available → fail CLOSED. A pre-commit secret guard that lets commits
# through unscanned is worse than useless: it gives false assurance. Git for
# Windows / macOS / most Linux ship perl, so this branch should be unreachable
# in practice; reaching it means the environment is unusually stripped down.
# =============================================================================
printf '\n\033[31m✖ secret-guard: no scanner found (need gitleaks, perl, or ripgrep) — refusing to commit unscanned.\033[0m\n' >&2
printf '  perl ships with Git for Windows; ensure it is on PATH. Or install gitleaks (recommended).\n' >&2
printf '  Or bypass deliberately for this commit:  git commit --no-verify\n' >&2
exit 1
