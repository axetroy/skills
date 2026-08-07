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

### 1. Run the collector script (primary path)

The bundled script performs steps 2–4 in one go and prints every repository with the user's commits since the given `--since` range. Run it first:

```bash
scripts/daily-commit-summary.sh
# == /path/to/gpm/github.com/axetroy/skills
# 2bd5a01|2026-08-07 18:22:20 +0800|新增 daily-commit-summary 技能文档
# ...
```

Arguments (all optional): `[since] [author-name] [author-email]`. By default `since=midnight`, and the author is taken from `git config --global user.name` / `user.email`.

If the script is missing or fails, fall back to the manual steps below. If the script returns nothing at all, report that there are no commits by the user in the requested range.

### 2. Manual fallback: list all repositories with `gpm ls`

`gpm ls` (alias `gpm list`) already enumerates every directory managed by gpm, including all nested repositories, so there is no need to traverse the filesystem manually. Prefer the JSON form for reliable parsing:

```bash
gpm ls --json | python3 -c "import json,sys; [print(p) for v in json.load(sys.stdin).values() for p in v]"
```

If `gpm ls` fails or returns nothing, state this explicitly and ask the user for the directories to search instead.

### 3. Manual fallback: filter to repositories modified within the last 24 hours

`gpm ls` reports every directory under the roots, including non-repository subdirectories (for example `.idea/inspectionProfiles` or package subdirectories). Two filters are applied here, in order of cheapness:

**a) Keep only real git repositories** — entries containing a `.git` directory or file:

```bash
gpm ls --json | python3 -c "import json,sys; [print(p) for v in json.load(sys.stdin).values() for p in v]" | while IFS= read -r d; do
  [ -n "$d" ] && { [ -d "$d/.git" ] || [ -f "$d/.git" ]; } && echo "$d"
done
```

**b) Keep only repositories with activity in the last 24 hours.** Every commit bumps the reflog `.git/logs/HEAD`, so its filesystem mtime is a cheap proxy — no git process is needed to check it:

```bash
now=$(date +%s); cutoff=$((now - 86400))
while IFS= read -r d; do
  ts=$(stat -f %m "$d/.git/logs/HEAD" 2>/dev/null)
  [ -n "$ts" ] && [ "$ts" -ge "$cutoff" ] && echo "$d"
done
```

The 24-hour window is intentionally wider than "today" so that commits made early in the day on an older machine timezone are not missed; the exact "today" check in step 4 does the precise filtering.

Deduplicate and canonicalize the survivors with:

```bash
git -C <repo> rev-parse --show-toplevel
```

This resolves worktrees, submodules, and symlinks to a single canonical path per repository.

### 4. Manual fallback: determine the current user's identity and check today's commits

Resolve the identity from Git configuration:

```bash
git config --global user.name
git config --global user.email
```

For each surviving repository, query the commits authored by the current user since today started:

```bash
git -C <repo> log --all --since="midnight" \
  --author="<user.name>" --author="<user.email>" \
  --no-merges --pretty=format:"%h|%ad|%s" --date=iso
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

### 5. Consolidate and summarize

- Filter out meaningless commits (trivial `wip` / `temp`, formatting-only changes, add-then-revert pairs that cancel out).
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

- MUST run `scripts/daily-commit-summary.sh` first (or `gpm ls --json` if the script is unavailable) to obtain the repositories and their today commits.
- MUST apply the 24-hour modification filter (reflog mtime via `stat` on `.git/logs/HEAD`) before scanning commit histories, so that inactive repositories are skipped without spawning git.
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
- NEVER run `find` over the whole filesystem tree to discover repositories; use `gpm ls` instead, which already excludes heavy directories such as `node_modules` and is far faster.
- NEVER list every commit message verbatim and call it a summary; consolidate them into logical changes.
- NEVER fabricate a daily summary when the repositories have no commits today; report the empty result honestly.
- NEVER ignore a repository that had commits just because it is deeply nested, in a worktree, or accessed via a symlink; resolve and include it.
- NEVER reuse the same summary content from a previous day or another repository as a template for today.

## Notes

- `gpm ls --json` returns a JSON object mapping each root to its list of paths; use it for reliable parsing.
- The bundled script `scripts/daily-commit-summary.sh` collapses steps 1–4 into one command. It prints `== <repo>` followed by that repo's matching commits, one per line as `<short-hash>|<iso-date>|<subject>`.
- The 24-hour modification filter uses the reflog mtime (`.git/logs/HEAD`) as a cheap proxy for the newest commit: a `stat` call per repo instead of a full `git log`, so only recently active repositories are scanned in depth. On a typical setup this drops the filter from ~5s to ~1s.
- The 24-hour window is wider than "today" on purpose: it avoids missing commits made early in the day, and the exact "today" check happens later with `--since="midnight"`.
- If `.git/logs/HEAD` is missing (fresh clone, bare repo), fall back to `git log --all -1 --format=%ct` for that repository rather than skipping it.
- The identity used by `--author` should match what appears in commit author lines; if the user has multiple identities, ask which one to use.
- If `git log --since="midnight"` returns nothing for every repository, report that there are no commits by the user today.
- When a repository is huge or the range is large, `git log --stat` or targeted `git show` calls are preferable to dumping full diffs.
- The output should focus on what the user can read directly; do not include irrelevant command execution details.
- If the user asks for a specific range (e.g. "since last Friday", "in the last week"), pass it as the first argument to the script or replace `--since="midnight"` in the manual commands.

## Output Language

The change records should be output in the same language as the user's conversation. If the user's conversation is in Chinese, output the records in Chinese; if it is in English, output the records in English.
