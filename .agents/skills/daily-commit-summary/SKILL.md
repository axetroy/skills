---
name: daily-commit-summary
description: Summarize what the user committed today across all git repositories managed by gpm. Gets the repository list from `gpm ls`, narrows it to repositories modified in the last 24 hours, extracts commits authored by the user today, and produces a consolidated daily summary. Use when the user asks what they did today, wants a daily work log, a standup-style summary, or a review of today's commits across multiple repositories.
---

# Daily Commit Summary

## Purpose

This Skill is applicable when the user wants to know what they committed today, potentially across many git repositories. The core scope is:

1. Obtain the list of repositories from `gpm ls`.
2. Narrow it down to repositories modified within the last 24 hours.
3. From those, extract the commits authored by the current user today.
4. Collect the matching commits.
5. Summarize all collected commits into a consolidated daily report.

The user may have repositories in several locations, but all of them are reported by `gpm ls`. This Skill must NOT fabricate commits, must NOT treat uncommitted changes as commits, and must NOT modify any repository.

## Workflow

### 1. List all repositories with `gpm ls`

`gpm ls` (alias `gpm list`) already enumerates every directory managed by gpm, including all nested repositories, so there is no need to traverse the filesystem manually:

```bash
gpm ls
# /Users/axetroy/gpm
#     /Users/axetroy/gpm/github.com/axetroy/skills
#     /Users/axetroy/gpm/github.com/axetroy/anti-redirect
#     ...
```

Prefer the JSON form for reliable parsing:

```bash
gpm ls --json
# {"root-a": ["<path>", ...], "root-b": ["<path>", ...]}
```

Flatten all paths with python3 (or jq):

```bash
gpm ls --json | python3 -c "import json,sys; [print(p) for v in json.load(sys.stdin).values() for p in v]"
```

If `gpm ls` fails or returns nothing, state this explicitly and ask the user for the directories to search instead.

### 2. Filter to repositories modified within the last 24 hours

`gpm ls` reports every directory under the roots, which includes non-repository subdirectories (for example `.idea/inspectionProfiles` or package subdirectories). Two filters are applied here, in order of cheapness:

**a) Keep only real git repositories** — entries containing a `.git` directory or file:

```bash
gpm ls | sed 's/^[[:space:]]*//' | while IFS= read -r d; do
  [ -n "$d" ] && { [ -d "$d/.git" ] || [ -f "$d/.git" ]; } && echo "$d"
done
```

**b) Keep only repositories with a commit in the last 24 hours** — read the newest commit timestamp (cheap: one `git log` per repo, far cheaper than a full `--since` scan) and compare it to the cutoff:

```bash
now=$(date +%s); cutoff=$((now - 86400))
while IFS= read -r d; do
  ts=$(git -C "$d" log --all -1 --format=%ct 2>/dev/null)
  [ -n "$ts" ] && [ "$ts" -ge "$cutoff" ] && echo "$d"
done
```

The 24-hour window is intentionally wider than "today" so that commits made early in the day on an older machine timezone are not missed; the final "today" check in step 3 does the exact filtering.

Deduplicate and canonicalize the survivors with:

```bash
git -C <repo> rev-parse --show-toplevel
```

This resolves worktrees, submodules, and symlinks to a single canonical path per repository.

### 3. Determine the current user's identity

The commits to collect are the ones authored by "me" (the current user). Resolve the identity from Git configuration:

```bash
git config --global user.name
git config --global user.email
```

Keep both values, and use them as author filters when querying each repository.

### 4. Check today's commits for each repository

For each repository, query the commits authored by the current user since today started:

```bash
git -C <repo> log --all --since="midnight" \
  --author="<user.name>" --author="<user.email>" \
  --no-merges --pretty=format:"%h|%ad|%an|%s" --date=short
```

Notes on this command:

- `--author` is a regex; passing both the name and the email matches commits authored by the user regardless of which appears in the author line.
- `--since="midnight"` selects commits recorded today (local time). To include commits from all branches, keep `--all`; if only the current branch matters, drop it.
- `--no-merges` skips merge commits by default; drop it if the user wants merges included.
- A repository with no output has no commits by the user today; skip it. Only keep repositories that returned at least one commit.

If the commit subjects alone are too terse or ambiguous, inspect the diffs to summarize accurately:

```bash
git -C <repo> show <commit> --stat
git -C <repo> show <commit>
```

### 5. Consolidate and summarize- Filter out meaningless commits (trivial `wip` / `temp`, formatting-only changes, add-then-revert pairs that cancel out).
- Merge repeated or related commits for the same logical change into a single item — a bug fixed across several commits appears once, not once per commit.
- Group changes into logical change records per repository, then produce an overall summary across repositories.
- The change records must come from the actual collected commits; do not invent features, fixes, or dependencies.

## Output Template

The final output MUST follow the template below. Only include repositories that had commits today; omit empty ones. When no repository had commits today, state that explicitly instead of producing empty sections.

```markdown
# Daily Work Summary - <date>

Today I made <total-commits> commit(s) in <repo-count> repository(ies).

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

- `<date>`: today's date in `YYYY-MM-DD`.
- `<repository-name>`: the basename of the repository root (e.g. `skills`, `anti-redirect`).
- `<logical change summary>`: one consolidated change record per logical change, written in the user's language, describing what changed rather than copying commit messages verbatim.
- `## Overall Summary`: 2–4 bullet points capturing the day's main themes across all repositories. If the user only wants the per-repository breakdown, this section may be omitted.
- If a repository had several commits that all belong to the same logical change, list it once with the total commit count in the heading.

## ALWAYS

- MUST run `gpm ls` (or `gpm ls --json`) first to obtain the repository candidates.
- MUST filter the `gpm ls` output to actual git repositories (entries containing a `.git` directory or file).
- MUST apply the 24-hour modification filter (newest commit timestamp within the last 24 hours) before scanning commit histories.
- MUST determine the current user's Git identity (`git config --global user.name` / `user.email`) and use it as the author filter.
- MUST only count commits authored by the current user and recorded today; commits by others or on other days MUST NOT be included.
- MUST base the summary on the actual collected commits and MUST NOT fabricate changes.
- MUST filter out meaningless commits and consolidate repeated commits for the same change into a single item.
- MUST include the header line with the date and the per-repository sections in the output.
- MUST, when a commit message is ambiguous, read its diff (`git show <commit>`) before summarizing it.
- MUST state explicitly when no commits were found today rather than producing empty or invented output.

## NEVER

- NEVER modify, create, or delete Git Tags, commits, or branches to perform the analysis; this Skill only reads history.
- NEVER treat uncommitted working tree changes as committed changes unless the user explicitly asks for working-tree differences too.
- NEVER guess which repositories were touched; only use repositories reported by `gpm ls` and confirmed to be git repositories.
- NEVER assume every path from `gpm ls` is a repository; entries that do not contain a `.git` must be excluded.
- NEVER list every commit message verbatim and call it a summary; consolidate them into logical changes.
- NEVER fabricate a daily summary when the repositories have no commits today; report the empty result honestly.
- NEVER ignore a repository that had commits just because it is deeply nested, in a worktree, or accessed via a symlink; resolve and include it.
- NEVER reuse the same summary content from a previous day or another repository as a template for today.

## Notes

- `gpm ls` enumerates every directory under the configured roots (including non-repository subdirectories), so the results must be filtered to entries that contain a `.git` directory or file.
- `gpm ls` does not require manual filesystem traversal and already excludes heavy directories such as `node_modules`.
- `gpm ls --json` returns a JSON object mapping each root to its list of paths; use it for reliable parsing.
- The 24-hour modification filter uses the newest commit timestamp (`git log --all -1 --format=%ct`) so only recently active repositories are scanned in depth, keeping the process fast on large setups.
- The 24-hour window is wider than "today" on purpose: it avoids missing commits made early in the day, and the exact "today" check happens later with `--since="midnight"`.
- Repositories can be nested several levels deep (for example `<root>/github.com/owner/repo`); `gpm ls` covers all of them.
- `.git` may be a directory or a file (worktrees, submodules); either marks a repository root.
- The identity used by `--author` should match what appears in commit author lines; if the user has multiple identities, ask which one to use.
- If `git log --since="midnight"` returns nothing for every repository, report that there are no commits by the user today.
- When a repository is huge or the range is large, `git log --stat` or targeted `git show` calls are preferable to dumping full diffs.
- The output should focus on what the user can read directly; do not include irrelevant command execution details.
- If the user asks for a specific range (e.g. "since last Friday", "in the last week"), replace `--since="midnight"` with the requested time range.

## Output Language

The change records should be output in the same language as the user's conversation. If the user's conversation is in Chinese, output the records in Chinese; if it is in English, output the records in English.
