---
name: commit-summary
description: Summarize what the user committed across all git repositories managed by gpm within a specified time range. Gets the repository list from `gpm ls`, narrows it to repositories modified within the time window, extracts commits authored by the user, and produces a consolidated summary. Use when the user asks what they did today, this week, since a specific date, or wants a work log/standup-style summary across multiple repositories. Supports flexible time ranges: "today" (default), "yesterday", "N days ago", "since YYYY-MM-DD", "last week", "this week", etc.
---

# Commit Summary

## Purpose

This Skill is applicable when the user wants to know what they committed within a specified time range, potentially across many git repositories. The core scope is:

1. Obtain the list of repositories from `gpm ls`.
2. Narrow it down to repositories modified within the specified time window (default: last 24 hours for "today").
3. From those, extract the commits authored by the current user within the time range.
4. Collect the matching commits.
5. Summarize all collected commits into a consolidated report.

The user may have repositories in several locations, but all of them are reported by `gpm ls`. This Skill must NOT fabricate commits, must NOT treat uncommitted changes as commits, and must NOT modify any repository.

## Time Range Specification

The time range can be specified in various flexible formats:

- **Relative**: `today` (default), `yesterday`, `N days ago` (e.g., `7 days ago`), `last week`, `this week`, `last month`, `this month`
- **Absolute**: `since YYYY-MM-DD` (e.g., `since 2026-08-01`), `until YYYY-MM-DD`
- **Range**: `YYYY-MM-DD..YYYY-MM-DD` (e.g., `2026-08-01..2026-08-07`)
- **Git-native**: Any format accepted by `git log --since` and `--until` (e.g., `midnight`, `2 weeks ago`, `last Monday`)

If no time range is specified, defaults to `today` (commits since midnight).

## Workflow

### 1. Run the collector script (primary path)

The bundled script performs steps 2–4 in one go and prints every repository with the user's commits since the given `--since` range. Run it first:

```bash
scripts/daily-commit-summary.sh [since] [until] [author-name] [author-email]
# == /path/to/gpm/github.com/axetroy/skills
# 2bd5a01|2026-08-07 18:22:20 +0800|新增 daily-commit-summary 技能文档
# ...
```

Arguments (all optional): 
- `since`: git log `--since` value (default: `midnight` for today). Accepts flexible formats like `today`, `yesterday`, `7 days ago`, `since 2026-08-01`, `last week`, etc.
- `until`: git log `--until` value (default: `now`). Accepts flexible formats like `now`, `tomorrow`, `YYYY-MM-DD`, etc.
- `author-name`: author to match (default: `git config --global user.name`)
- `author-email`: author to match (default: `git config --global user.email`)

If the script is missing or fails, fall back to the manual steps below. If the script returns nothing at all, report that there are no commits by the user in the requested range.

### 2. Manual fallback: list all repositories with `gpm ls`

`gpm ls` (alias `gpm list`) already enumerates every directory managed by gpm, including all nested repositories, so there is no need to traverse the filesystem manually. Prefer the JSON form for reliable parsing:

```bash
gpm ls --json | python3 -c "import json,sys; [print(p) for v in json.load(sys.stdin).values() for p in v]"
```

If `gpm ls` fails or returns nothing, state this explicitly and ask the user for the directories to search instead.

### 3. Manual fallback: filter to repositories modified within the time window

`gpm ls` reports every directory under the roots, including non-repository subdirectories (for example `.idea/inspectionProfiles` or package subdirectories). Two filters are applied here, in order of cheapness:

**a) Keep only real git repositories** — entries containing a `.git` directory or file:

```bash
gpm ls --json | python3 -c "import json,sys; [print(p) for v in json.load(sys.stdin).values() for p in v]" | while IFS= read -r d; do
  [ -n "$d" ] && { [ -d "$d/.git" ] || [ -f "$d/.git" ]; } && echo "$d"
done
```

**b) Keep only repositories with activity within the time window.** Every commit bumps the reflog `.git/logs/HEAD`, so its filesystem mtime is a cheap proxy — no git process is needed to check it. Calculate the cutoff based on the time range:

```bash
# For "today" (default): 24 hours
# For "N days ago": N * 86400 seconds
# For specific dates: calculate from the date
now=$(date +%s)
# Example for 7 days ago:
cutoff=$((now - 7 * 86400))
while IFS= read -r d; do
  ts=$(stat -f %m "$d/.git/logs/HEAD" 2>/dev/null)
  [ -n "$ts" ] && [ "$ts" -ge "$cutoff" ] && echo "$d"
done
```

The time window is intentionally wider than the exact range so that commits made near the boundary are not missed; the exact range check in step 4 does the precise filtering.

Deduplicate and canonicalize the survivors with:

```bash
git -C <repo> rev-parse --show-toplevel
```

This resolves worktrees, submodules, and symlinks to a single canonical path per repository.

### 4. Manual fallback: determine the current user's identity and check commits within the time range

Resolve the identity from Git configuration:

```bash
git config --global user.name
git config --global user.email
```

For each surviving repository, query the commits authored by the current user within the specified time range:

```bash
git -C <repo> log --all --since="<since>" --until="<until>" \
  --author="<user.name>" --author="<user.email>" \
  --no-merges --pretty=format:"%h|%ad|%s" --date=iso
```

Notes on this command:

- `--author` is a regex; passing both the name and the email matches commits authored by the user regardless of which appears in the author line.
- `--since` and `--until` accept flexible formats: `midnight` (today), `yesterday`, `7 days ago`, `2026-08-01`, `last week`, etc. Use the same format as the user specified.
- To include commits from all branches, keep `--all`; if only the current branch matters, drop it.
- `--no-merges` skips merge commits by default; drop it if the user wants merges included.
- A repository with no output has no commits by the user in the range; skip it. Only keep repositories that returned at least one commit.

If the commit subjects alone are too terse or ambiguous, inspect the diffs to summarize accurately:

```bash
git -C <repo> show <commit> --stat
git -C <repo> show <commit>
```

### 5. Consolidate and summarize

- Filter out meaningless commits (trivial `wip` / `temp`, formatting-only changes, add-then-revert pairs that cancel out).
- Merge repeated or related commits for the same logical change into a single item — a bug fixed across several commits appears once, not once per commit.
- Group changes into logical change records per repository, then produce an overall summary across repositories.
- The change records must come from the actual collected commits; do not invent features, fixes, or dependencies.

## Output Template

The final output MUST follow the template below. Only include repositories that had commits in the specified range; omit empty ones. When no repository had commits in the range, state that explicitly instead of producing empty sections.

```markdown
# Commit Summary - <date-range>

I made <total-commits> commit(s) in <repo-count> repository(ies) <time-period>.

## Repositories

### <repository-name> (<commit-count> commits)
- <logical change summary>
- <logical change summary>

### <repository-name> (<commit-count> commits)
- <logical change summary>

## Overall Summary
- <themes, highlights, or notable work across all repositories>
```

Rules for filling in the template:

- `<date-range>`: the date range in `YYYY-MM-DD` format (e.g., `2026-08-01 to 2026-08-07`) or a descriptive period (e.g., `today`, `this week`, `last 7 days`).
- `<time-period>`: natural language description (e.g., `today`, `this week`, `since 2026-08-01`).
- `<repository-name>`: the basename of the repository root (e.g. `skills`, `anti-redirect`).
- `<logical change summary>`: one consolidated change record per logical change, written in the user's language, describing what changed rather than copying commit messages verbatim.
- `## Overall Summary`: 2–4 bullet points capturing the main themes across all repositories. If the user only wants the per-repository breakdown, this section may be omitted.
- If a repository had several commits that all belong to the same logical change, list it once with the total commit count in the heading.

## ALWAYS

- MUST run `scripts/daily-commit-summary.sh` first (or `gpm ls --json` if the script is unavailable) to obtain the repositories and their commits in the specified range.
- MUST apply the time-window modification filter (reflog mtime via `stat` on `.git/logs/HEAD`) before scanning commit histories, so that inactive repositories are skipped without spawning git. The cutoff should be based on the time range (e.g., 24h for "today", 7 days for "7 days ago", etc.).
- MUST determine the current user's Git identity (`git config --global user.name` / `user.email`) and use it as the author filter.
- MUST only count commits authored by the current user and recorded within the specified time range; commits by others or outside the range MUST NOT be included.
- MUST base the summary on the actual collected commits and MUST NOT fabricate changes.
- MUST filter out meaningless commits and consolidate repeated commits for the same change into a single item.
- MUST include the header line with the date range and the per-repository sections in the output.
- MUST, when a commit message is ambiguous, read its diff (`git show <commit>`) before summarizing it.
- MUST state explicitly when no commits were found in the range rather than producing empty or invented output.

## NEVER

- NEVER modify, create, or delete Git Tags, commits, or branches to perform the analysis; this Skill only reads history.
- NEVER treat uncommitted working tree changes as committed changes unless the user explicitly asks for working-tree differences too.
- NEVER guess which repositories were touched; only use repositories reported by `gpm ls` and confirmed to be git repositories.
- NEVER assume every path from `gpm ls` is a repository; entries that do not contain a `.git` must be excluded.
- NEVER run `find` over the whole filesystem tree to discover repositories; use `gpm ls` instead, which already excludes heavy directories such as `node_modules` and is far faster.
- NEVER list every commit message verbatim and call it a summary; consolidate them into logical changes.
- NEVER fabricate a summary when the repositories have no commits in the range; report the empty result honestly.
- NEVER ignore a repository that had commits just because it is deeply nested, in a worktree, or accessed via a symlink; resolve and include it.
- NEVER reuse the same summary content from a previous range or another repository as a template for the current range.

## Notes

- `gpm ls --json` returns a JSON object mapping each root to its list of paths; use it for reliable parsing.
- The bundled script `scripts/daily-commit-summary.sh` collapses steps 1–4 into one command. It prints `== <repo>` followed by that repo's matching commits, one per line as `<short-hash>|<iso-date>|<subject>`.
- The time-window modification filter uses the reflog mtime (`.git/logs/HEAD`) as a cheap proxy for the newest commit: a `stat` call per repo instead of a full `git log`, so only recently active repositories are scanned in depth. On a typical setup this drops the filter from ~5s to ~1s. The cutoff is calculated based on the time range (e.g., 24h for "today", 7*86400 for "7 days ago").
- The time window is intentionally wider than the exact range on purpose: it avoids missing commits made near the boundary, and the exact range check happens later with `--since`/`--until`.
- If `.git/logs/HEAD` is missing (fresh clone, bare repo), fall back to `git log --all -1 --format=%ct` for that repository rather than skipping it.
- The identity used by `--author` should match what appears in commit author lines; if the user has multiple identities, ask which one to use.
- If `git log --since="<since>" --until="<until>"` returns nothing for every repository, report that there are no commits by the user in the range.
- When a repository is huge or the range is large, `git log --stat` or targeted `git show` calls are preferable to dumping full diffs.
- The output should focus on what the user can read directly; do not include irrelevant command execution details.
- If the user asks for a specific range (e.g. "since last Friday", "in the last week", "last month"), pass it as the first argument to the script or replace `--since`/`--until` in the manual commands.

## Output Language

The change records should be output in the same language as the user's conversation. If the user's conversation is in Chinese, output the records in Chinese; if it is in English, output the records in English.
