---
name: git-tag-change-summary
description: This Skill is used to generate change records based on the commit history and Tag information of a Git repository. It accepts an optional version range parameter. When no range is specified, it defaults to the changes between HEAD and the most recent Tag (the previous version); when a range is specified, it summarizes the changes between the specified versions.
---

# Git Tag Change Summary

## Purpose

This Skill is applicable when the current working directory is already a Git repository and change records need to be generated based on the actual Git commit history. The core scope is:

1. Determine the change range: either use the range explicitly provided by the user, or fall back to the range from the most recent Tag to `HEAD`.
2. Retrieve the commit records within that range.
3. Summarize the changes based on the actual commit contents.
4. Output the change records as a numbered list, listing items `1.` through `4.` by default.

If a valid change range cannot be determined (for example, the repository has no Tags and no explicit range was given), this must be explicitly stated, and the change range must not be fabricated.

## Range Determination

The change range follows this priority:

1. **Range explicitly specified** — if the user provides two versions (for example `v1.0.0..v2.0.0`, `v1.0.0 v2.0.0`, or "from v1.0.0 to v2.0.0"), use that exact range as the baseline and end point.
2. **Single version specified** — if the user provides only one version (for example `v2.0.0` or "since v2.0.0"), treat it as the baseline and use the range `<version>..HEAD`.
3. **No range specified (default)** — determine the most recent Tag reachable from `HEAD`, then summarize the changes between that Tag and `HEAD`. If the current `HEAD` already corresponds to a Tag, use the Tag immediately before that Tag as the baseline, in order to summarize the complete changes of the current Tag relative to the previous Tag.

## ALWAYS

- MUST determine the change range first, following the priority in "Range Determination", before summarizing changes.
- MUST confirm the exact names of the baseline and end point revisions and confirm that there is an analyzable commit range between them.
- MUST check `HEAD` and Tag information in the current Git repository before summarizing changes.
- MUST prioritize actual Git commit records as the data source for the change summary.
- MUST use `git log <baseline>..<end-point>` or an equivalent method to retrieve commit records within the range.
- MUST, when the user explicitly specifies a range, respect it exactly and MUST NOT silently replace it with the most recent Tag even if the current `HEAD` is not covered by that range.
- MUST, when the current `HEAD` already corresponds to a Tag and no range was specified, use the Tag immediately before that Tag as the baseline, in order to summarize the complete changes of the current Tag relative to the previous Tag.
- MUST consolidate multiple related commits into changes that are understandable to users rather than mechanically copying commit messages one by one.
- MUST preserve the accuracy of important technical terms, module names, APIs, file paths, and version numbers.
- MUST generate changes based on the actual commit contents and must not use fixed template content to masquerade as real changes.
- MUST output a numbered list using at least the `1.`, `2.`, `3.`, `4.` format; if there are clearly fewer than four actual changes, content must not be fabricated just to fill the list.
- MUST, when sufficient information exists, merge duplicate, related, or multiple commits concerning the same feature into a single logical change item.
- MUST distinguish between different types of changes, such as feature additions, feature modifications, bug fixes, refactoring, dependency upgrades, and build or engineering configuration changes.
- MUST explicitly state the reason and stop generating change records based on guesses when there is no valid commit range.

## NEVER

- NEVER infer the entire version's change scope from only the most recent few commit messages, as this may omit other commits within the range.

```bash
# ❌ Wrong: only look at the last 4 commits
git log -4 --oneline

# ✅ Correct: view the complete commits within the specified range
git log <baseline>..<end-point> --oneline
```

- NEVER use the current date, Tag name, or common Release Notes templates to guess nonexistent feature changes, because change records must come from the actual repository history.

```text
❌ 1. Add user login feature
❌ 2. Optimize performance
❌ 3. Fix several bugs
❌ 4. Upgrade dependencies

# If these have no corresponding actual commits, they must not be written into the result.
```

- NEVER list every commit message verbatim and call it a "change summary", because users need consolidated change records.

```text
❌ 1. fix: xxx
❌ 2. fix: xxx
❌ 3. feat: xxx
❌ 4. chore: xxx

# ✅ Should be consolidated into logical changes
1. Fix the error handling problem in the xxx scenario.
2. Add the xxx feature and improve the related logic.
```

- NEVER use an unrelated or excessively early Tag as the change baseline without checking the relationship between the Tag and the end point.

```bash
# ❌ Wrong: arbitrarily pick an old Tag as the baseline
git log v1.0.0..HEAD

# ✅ Correct: first determine the Tag closest to the current HEAD that qualifies as the baseline
git describe --tags --abbrev=0 HEAD
```

- NEVER, when no range is specified and the current `HEAD` is already a Tag, use the current Tag itself as the "previous Tag" and skip the preceding Tag, as this would omit the complete changes of the current version relative to the previous version.

```text
❌ HEAD = v2.0.0
   baseline = v2.0.0

# ✅
HEAD = v2.0.0
current Tag = v2.0.0
previous Tag = v1.9.0
change range = v1.9.0..v2.0.0
```

- NEVER modify, create, or delete Git Tags to perform the analysis task, because the responsibility of this Skill is to read and summarize history, not to alter version history.
- NEVER treat uncommitted working tree changes as Git commit changes unless the user explicitly requests that working tree differences also be analyzed.

## Common Patterns

### 1. Default (no range specified): summarize changes after the most recent Tag

First confirm the current repository status and the most recent Tag:

```bash
git status --short
git rev-parse HEAD
git describe --tags --abbrev=0 HEAD
```

Retrieve the commits from the most recent Tag to the current `HEAD`:

```bash
git log <previous-tag>..HEAD --oneline --decorate
```

Inspect the complete commit contents when necessary:

```bash
git log <previous-tag>..HEAD --stat
git log <previous-tag>..HEAD --format=fuller
```

Finally, consolidate the commits into something like:

```text
1. Add the xxx feature, supporting the xxx scenario.
2. Optimize the processing logic of the xxx module, improving xxx.
3. Fix the error problem in the xxx scenario.
4. Update the xxx dependencies and related build configuration.
```

### 2. Default (no range specified): current HEAD is already a Tag

First determine whether the current `HEAD` corresponds exactly to a Tag:

```bash
git tag --points-at HEAD
```

If the current Tag is `v2.0.0`, find the Tag immediately preceding it and analyze the commits between the two versions:

```bash
git describe --tags --abbrev=0 HEAD^
git log <previous-tag>..v2.0.0 --oneline --decorate
```

Further inspect the complete diff:

```bash
git diff --stat <previous-tag>..v2.0.0
git diff --name-status <previous-tag>..v2.0.0
```

The summary should focus on the actual logical changes that occurred between the two Tags:

```text
1. Add the xxx capability.
2. Adjust the xxx module to implement the xxx behavior.
3. Fix the xxx problem caused under the xxx condition.
4. Optimize build, dependency, or project configuration.
```

### 3. Single version specified: summarize changes since that version

When the user specifies a single version such as `v2.0.0` or "since v2.0.0", treat it as the baseline and summarize the commits from that version to the current `HEAD`:

```bash
git log v2.0.0..HEAD --oneline --decorate
```

Confirm the specified baseline Tag actually exists before summarizing:

```bash
git tag --list "v2.0.0"
```

If the specified Tag does not exist, state this explicitly and ask the user to confirm the baseline rather than guessing.

### 4. Two versions specified: summarize changes between them

When the user specifies a range such as `v1.0.0..v2.0.0`, or two versions like "from v1.0.0 to v2.0.0", use the range as given and do not adjust it to `HEAD`:

```bash
git log v1.0.0..v2.0.0 --oneline --decorate
```

Inspect the complete diff between the two versions:

```bash
git diff --stat v1.0.0..v2.0.0
git diff --name-status v1.0.0..v2.0.0
```

### 5. Many commits: consolidate by feature theme

When there are many commits within the range, first obtain the commit list:

```bash
git log <baseline>..<end-point> --oneline --no-merges
```

Then categorize them based on their contents, for example:

```text
Feature additions:
- feat: add xxx
- feat: support xxx

Bug fixes:
- fix: xxx error
- fix: handle xxx

Engineering and dependencies:
- chore: update xxx
- build: change xxx
```

Do not output the complete commit list in the final result. Instead, consolidate them into user-readable change records:

```text
1. Add and improve the xxx feature, supporting the xxx use case.
2. Fix the abnormal problem of the xxx module under the xxx condition.
3. Optimize the xxx processing flow and related performance.
4. Update the xxx dependencies and build configuration.
```

## Notes

- When no range is specified, `git describe --tags --abbrev=0 HEAD` is generally suitable for locating the most recent Tag reachable from the current `HEAD`, but "most recent" is based on the Git commit ancestry relationship and is not equivalent to simply sorting Tags by creation time.
- If the user specifies a range, always respect the given revisions; do not expand or shrink the range based on your own assumptions.
- If the repository contains both annotated tags and lightweight tags, the actual Git reference relationships should be used as the basis rather than inferring version order solely from Tag names.
- If the current branch contains merge commits, `--first-parent`, ordinary `git log`, and `git diff` when necessary should be considered together to determine which changes belong to the current version; absolute conclusions must not be drawn from a single log view alone.
- If the repository has no Tags and no range was specified, explicitly state that the "previous Tag" cannot be determined, and, when permitted by the user, the summary can instead be based on all available commits.
- If there are no commits within the range, for example when `git log <baseline>..<end-point>` returns nothing, explicitly state that there are no new committed changes within the current range.
- If multiple branches or multiple Tags point to different histories, the baseline should be determined primarily according to the ancestry relationship of the current `HEAD`, rather than simply selecting the most recently created Tag in the repository.
- If the user requires the output to contain exactly four items but there are actually fewer than four types of changes, factual accuracy should take priority; related changes may be reasonably merged, but MUST NOT fabricate nonexistent changes.
- If the user only requests change records, there is generally no need to output complete commit hashes, authors, commit times, or other metadata; include such information only when it is genuinely helpful for understanding the changes.
- The output should focus on change records that the end user can read directly and should avoid exposing irrelevant Git command execution details.

## Output Language

The change records should be output in the same language as the user's conversation. If the user's conversation is in Chinese, output the change records in Chinese; if it is in English, output the change records in English.
