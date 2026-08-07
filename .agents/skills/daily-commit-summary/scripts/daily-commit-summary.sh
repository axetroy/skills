#!/usr/bin/env bash
# Daily commit summary collector for gpm-managed repositories.
#
# Pipeline:
#   1. gpm ls --json       -> list every path under the gpm roots
#   2. cheap filter        -> keep only git repos modified in the last 24h,
#                             using stat on the reflog instead of spawning
#                             git for every repo
#   3. exact filter        -> git log --since=<SINCE> --author=<ME>
#   4. print per-repo      -> "== <repo>" followed by its commits
#
# Usage:
#   daily-commit-summary.sh [since] [author-name] [author-email]
#     since        git log --since value (default: midnight)
#     author-name  author to match (default: git config --global user.name)
#     author-email author to match (default: git config --global user.email)
#
# Output format:
#   == /abs/path/to/repo
#   <short-hash>|<iso-date>|<subject>
#   ...

set -euo pipefail

SINCE="${1:-midnight}"
NAME="${2:-$(git config --global user.name 2>/dev/null || true)}"
EMAIL="${3:-$(git config --global user.email 2>/dev/null || true)}"

if [ -z "$NAME" ] && [ -z "$EMAIL" ]; then
  echo "error: cannot determine the user identity (git config --global user.name/email)" >&2
  exit 1
fi

# Repositories whose newest activity is older than 24h cannot contain
# "today" commits. Use the reflog mtime as a cheap proxy: every commit
# bumps .git/logs/HEAD, so a stale mtime lets us skip the repo without
# starting git at all. Fall back to git log if the reflog is missing.
now=$(date +%s)
cutoff=$((now - 86400))

# Portable "modified seconds since epoch" for a file path.
mtime() {
  case "$(uname)" in
    Darwin) stat -f %m "$1" 2>/dev/null || true ;;
    *)      stat -c %Y "$1" 2>/dev/null || true ;;
  esac
}

gpm ls --json |
  python3 -c "import json,sys; [print(p) for v in json.load(sys.stdin).values() for p in v]" |
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    { [ -d "$d/.git" ] || [ -f "$d/.git" ]; } || continue

    ts=$(mtime "$d/.git/logs/HEAD")
    if [ -n "$ts" ] && [ "$ts" -lt "$cutoff" ]; then
      continue
    fi

    commits=$(git -C "$d" log --all --since="$SINCE" \
      --author="$NAME" --author="$EMAIL" \
      --no-merges --pretty=format:"%h|%ad|%s" --date=iso 2>/dev/null || true)

    if [ -n "$commits" ]; then
      echo "== $d"
      echo "$commits"
    fi
  done
