#!/usr/bin/env bash
# Commit summary collector for gpm-managed repositories.
#
# Pipeline:
#   1. gpm ls --json       -> list every path under the gpm roots
#   2. cheap filter        -> keep only git repos modified within the time window,
#                             using stat on the reflog instead of spawning
#                             git for every repo
#   3. exact filter        -> git log --since=<SINCE> --until=<UNTIL> --author=<ME>
#   4. print per-repo      -> "== <repo>" followed by its commits
#
# Usage:
#   daily-commit-summary.sh [since] [until] [author-name] [author-email]
#     since        git log --since value (default: midnight for today)
#                  Accepts: today, yesterday, N days ago, YYYY-MM-DD, last week, etc.
#     until        git log --until value (default: now)
#                  Accepts: now, YYYY-MM-DD, tomorrow, etc.
#     author-name  author to match (default: git config --global user.name)
#     author-email author to match (default: git config --global user.email)
#
# Output format:
#   == /abs/path/to/repo
#   <short-hash>|<iso-date>|<subject>
#   ...

set -euo pipefail

SINCE="${1:-midnight}"
UNTIL="${2:-now}"
NAME="${3:-$(git config --global user.name 2>/dev/null || true)}"
EMAIL="${4:-$(git config --global user.email 2>/dev/null || true)}"

# Convert user-friendly time formats to git log compatible formats
# Use a fixed reference date to avoid issues with midnight boundary
REF_DATE=$(date "+%Y-%m-%d")

# Calculate start of week (Monday)
WEEK_START=$(date -v-$(($(date +%u) - 1))d "+%Y-%m-%d" 2>/dev/null || date -d "monday this week" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")
# Calculate end of week (Sunday)
WEEK_END=$(date -v+$(($(date +%u) * -1 + 7))d "+%Y-%m-%d" 2>/dev/null || date -d "sunday this week" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")
# Calculate start of last week
LAST_WEEK_START=$(date -v-$(($(date +%u) + 6))d "+%Y-%m-%d" 2>/dev/null || date -d "monday last week" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")
# Calculate end of last week
LAST_WEEK_END=$(date -v-$(($(date +%u) - 1))d "+%Y-%m-%d" 2>/dev/null || date -d "sunday last week" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")
# Calculate start of this month
MONTH_START=$(date -v-$(($(date +%d) - 1))d "+%Y-%m-%d" 2>/dev/null || date -d "$(date +%Y-%m-01)" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")
# Calculate end of this month
MONTH_END=$(date -v+$(($(date -d "$(date +%Y-%m-01) + 1 month - 1 day" +%d 2>/dev/null || echo 30) - $(date +%d)))d "+%Y-%m-%d" 2>/dev/null || date -d "$(date +%Y-%m-01) + 1 month - 1 day" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")
# Calculate start of last month
LAST_MONTH_START=$(date -v-$(($(date +%d) - 1 + 30))d "+%Y-%m-%d" 2>/dev/null || date -d "$(date +%Y-%m-01) - 1 month" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")
# Calculate end of last month
LAST_MONTH_END=$(date -v-$(($(date +%d) - 1))d "+%Y-%m-%d" 2>/dev/null || date -d "$(date +%Y-%m-01) - 1 day" "+%Y-%m-%d" 2>/dev/null || echo "$REF_DATE")

convert_since() {
  case "$1" in
    today) echo "$REF_DATE 00:00:00" ;;
    yesterday) date -v-1d "+%Y-%m-%d 00:00:00" 2>/dev/null || date -d "yesterday" "+%Y-%m-%d 00:00:00" ;;
    "this week") echo "$WEEK_START 00:00:00" ;;
    "last week") echo "$LAST_WEEK_START 00:00:00" ;;
    "this month") echo "$MONTH_START 00:00:00" ;;
    "last month") echo "$LAST_MONTH_START 00:00:00" ;;
    *) echo "$1" ;;
  esac
}

convert_until() {
  case "$1" in
    now) echo "$REF_DATE 23:59:59" ;;
    tomorrow) date -v+1d "+%Y-%m-%d 23:59:59" 2>/dev/null || date -d "tomorrow" "+%Y-%m-%d 23:59:59" ;;
    "this week") echo "$WEEK_END 23:59:59" ;;
    "last week") echo "$LAST_WEEK_END 23:59:59" ;;
    "this month") echo "$MONTH_END 23:59:59" ;;
    "last month") echo "$LAST_MONTH_END 23:59:59" ;;
    *) echo "$1" ;;
  esac
}

GIT_SINCE=$(convert_since "$SINCE")
GIT_UNTIL=$(convert_until "$UNTIL")

if [ -z "$NAME" ] && [ -z "$EMAIL" ]; then
  echo "error: cannot determine the user identity (git config --global user.name/email)" >&2
  exit 1
fi

# Calculate cutoff for the cheap filter based on the time range.
# We parse the SINCE value to determine how far back to look.
# This is a best-effort approximation; the exact filter happens in git log.
calculate_cutoff() {
  local since_val="$1"
  local now_ts=$(date +%s)
  
  case "$since_val" in
    today|midnight)
      echo $((now_ts - 86400))  # 24 hours
      ;;
    yesterday)
      echo $((now_ts - 2 * 86400))  # 48 hours
      ;;
    *days\ ago)
      local days=$(echo "$since_val" | sed 's/ days ago//')
      echo $((now_ts - days * 86400))
      ;;
    *day\ ago)
      local days=$(echo "$since_val" | sed 's/ day ago//')
      echo $((now_ts - days * 86400))
      ;;
    *weeks\ ago)
      local weeks=$(echo "$since_val" | sed 's/ weeks ago//')
      echo $((now_ts - weeks * 7 * 86400))
      ;;
    *week\ ago)
      local weeks=$(echo "$since_val" | sed 's/ week ago//')
      echo $((now_ts - weeks * 7 * 86400))
      ;;
    *months\ ago)
      local months=$(echo "$since_val" | sed 's/ months ago//')
      echo $((now_ts - months * 30 * 86400))
      ;;
    *month\ ago)
      local months=$(echo "$since_val" | sed 's/ month ago//')
      echo $((now_ts - months * 30 * 86400))
      ;;
    last\ week)
      echo $((now_ts - 7 * 86400))
      ;;
    this\ week)
      echo $((now_ts - 7 * 86400))
      ;;
    last\ month)
      echo $((now_ts - 30 * 86400))
      ;;
    this\ month)
      echo $((now_ts - 30 * 86400))
      ;;
    since\ *)
      local date_str=$(echo "$since_val" | sed 's/since //')
      # Try to parse the date
      local since_ts=$(date -j -f "%Y-%m-%d" "$date_str" +%s 2>/dev/null || date -d "$date_str" +%s 2>/dev/null || echo "$now_ts")
      echo $((since_ts - 86400))  # Add 1 day buffer
      ;;
    *)
      # Default to 24 hours for unknown formats
      echo $((now_ts - 86400))
      ;;
  esac
}

cutoff=$(calculate_cutoff "$SINCE")

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

    commits=$(git -C "$d" log --all --since="$GIT_SINCE" --until="$GIT_UNTIL" \
      --author="$NAME" --author="$EMAIL" \
      --no-merges --pretty=format:"%h|%ad|%s" --date=iso 2>/dev/null || true)

    if [ -n "$commits" ]; then
      echo "== $d"
      echo "$commits"
    fi
  done
