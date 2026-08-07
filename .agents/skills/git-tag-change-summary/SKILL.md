---
name: git-tag-change-summary
description: This Skill is used to generate change records based on the commit history and Tag information of a Git repository. It accepts an optional version range parameter. When no range is specified, it defaults to the changes between HEAD and the most recent Tag (the previous version); when a range is specified, it summarizes the changes between the specified versions. The output follows a Keep a Changelog style template.
---

# Git Tag Change Summary

## Purpose

This Skill is applicable when the current working directory is already a Git repository and change records need to be generated based on the actual Git commit history. The core scope is:

1. Determine the change range: either use the range explicitly provided by the user, or fall back to the range from the most recent Tag to `HEAD`.
2. Retrieve the commit records within that range.
3. Summarize the changes based on the actual commit contents.
4. Output the change records following the "Output Template" below.

If a valid change range cannot be determined (for example, the repository has no Tags and no explicit range was given), this must be explicitly stated, and the change range must not be fabricated.

## Range Determination

The change range follows this priority:

1. **Range explicitly specified** — if the user provides two versions (for example `v1.0.0..v2.0.0`, `v1.0.0 v2.0.0`, or "from v1.0.0 to v2.0.0"), use that exact range as the baseline and end point.
2. **Single version specified** — if the user provides only one version (for example `v2.0.0` or "since v2.0.0"), treat it as the baseline and use the range `<version>..HEAD`.
3. **No range specified (default)** — determine the most recent Tag reachable from `HEAD`, then summarize the changes between that Tag and `HEAD`. If the current `HEAD` already corresponds to a Tag, use the Tag immediately before that Tag as the baseline, in order to summarize the complete changes of the current Tag relative to the previous Tag.

## Output Template

The final output MUST follow the template below, in the Keep a Changelog style. Only include sections that actually have changes; omit empty sections. Do not rename, reorder, or merge sections arbitrarily, and do not invent sections that have no changes.

```markdown
## [<version>] - <date>

### Added
- <new features added> (@<author>)

### Changed
- <behavior, API, or logic changes, refactoring, performance improvements> (@<author>)

### Fixed
- <bug fixes> (@<author>)

### Removed
- <removed features or deprecated APIs> (@<author>)

### Dependencies
- <dependency upgrades or build / engineering / configuration changes> (@<author>)
```

Rules for filling in the template:

- `<version>`: use the end point of the resolved range. If the end point is a Tag, use that Tag name; if the end point is `HEAD` and `HEAD` is not tagged, use `Unreleased`.
- `<date>`: use the commit date of the end point if it is a Tag (`git log -1 --format=%cs <end-point>`), otherwise use the current date.
- Each section is a bulleted (`-`) list. Keep each item concise and consolidated from the actual commits; do not copy commit messages verbatim.
- If a change does not fit neatly into a section, prefer the closest section over creating a new one; if there are genuinely fewer sections than the template, output only the sections that have content.
- Each item MUST end with an attribution of the contributor(s) in the form `(@<author>)`, where `<author>` is derived from the actual Git author name (`git log --format=%an`). When an item consolidates commits from multiple authors, list them all: `(@alice, @bob)`.

## Change Analysis

Workflow for turning raw commits into the final summary:

1. List the commits within the resolved range.
2. Read the commit subjects. For any commit whose meaning is unclear from the subject alone — ambiguous wording, generic messages, sweeping changes, or merge commits — inspect the actual diff instead of guessing:
   - `git show <commit> --stat` for a quick overview of which files changed.
   - `git show <commit>` (or `git show <commit> --format=fuller`) for the full diff content.
   - `git log <baseline>..<end-point> -p` to walk through all diffs at once when the range is small.
3. Summarize each commit into one short sentence (the per-commit summary), capturing what changed and why, based on the diff when the subject is insufficient.
4. Consolidate the per-commit summaries into the overall summary following the "Output Template", merging related commits and grouping them under the correct sections.
5. Attribute each consolidated item to the authors of the commits that contributed to it.

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
- MUST output the change records strictly following the "Output Template" (Keep a Changelog style); if there are clearly fewer actual changes than sections in the template, content must not be fabricated just to fill the sections.
- MUST include the `<version>` and `<date>` header line in the output.
- MUST, when sufficient information exists, merge duplicate, related, or multiple commits concerning the same feature into a single logical change item.
- MUST, when a commit message alone is ambiguous or insufficient, read the actual diff content (`git show <commit>`) before summarizing it, rather than guessing from the subject.
- MUST attribute every output item to its contributor(s) using the actual Git author name in the form `(@<author>)`, and list all authors when an item combines commits from multiple people.
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
❌ ## [v2.0.0] - 2026-08-07

### Added
- Add user login feature

### Changed
- Optimize performance

### Fixed
- Fix several bugs

# If these have no corresponding actual commits, they must not be written into the result.
```

- NEVER list every commit message verbatim and call it a "change summary", because users need consolidated change records.

```text
❌ 1. fix: xxx
❌ 2. fix: xxx
❌ 3. feat: xxx
❌ 4. chore: xxx

# ✅ Should be consolidated into logical changes following the template
## [v2.0.0] - 2026-08-07

### Added
- Add the xxx feature and improve the related logic.

### Fixed
- Fix the error handling problem in the xxx scenario.

### Dependencies
- Update the xxx dependency.
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
- NEVER invent or guess an `@` attribution; author names must come from the actual commit metadata (`git log --format=%an`), and must not be replaced with fabricated usernames.

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

```markdown
## [Unreleased]

### Added
- Add the xxx feature, supporting the xxx scenario. (@alice)

### Changed
- Optimize the processing logic of the xxx module, improving xxx. (@bob)

### Fixed
- Fix the error problem in the xxx scenario. (@alice)

### Dependencies
- Update the xxx dependencies and related build configuration. (@charlie)
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

```markdown
## [v2.0.0] - 2026-08-07

### Added
- Add the xxx capability. (@alice, @bob)

### Changed
- Adjust the xxx module to implement the xxx behavior. (@bob)

### Fixed
- Fix the xxx problem caused under the xxx condition. (@charlie)

### Dependencies
- Optimize build, dependency, or project configuration. (@alice)
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
- feat: add xxx (alice)
- feat: support xxx (bob)

Bug fixes:
- fix: xxx error (alice)
- fix: handle xxx (charlie)

Engineering and dependencies:
- chore: update xxx (bob)
- build: change xxx (dave)
```

When a commit message is not descriptive enough, read its diff before categorizing:

```bash
git show <commit> --stat
git show <commit>
```

Do not output the complete commit list in the final result. Instead, consolidate them into user-readable change records following the template:

```markdown
## [v1.5.0] - 2026-05-20

### Added
- Add and improve the xxx feature, supporting the xxx use case. (@alice, @bob)

### Fixed
- Fix the abnormal problem of the xxx module under the xxx condition. (@charlie)

### Changed
- Optimize the xxx processing flow and related performance. (@bob)

### Dependencies
- Update the xxx dependencies and build configuration. (@dave)
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
- If the user provides their own output format or explicitly asks for a plain numbered list, follow the user's request instead of the template.
- The template sections are a default; when a change type has no content, omit that section entirely rather than outputting an empty heading.
- If the user only requests change records, there is generally no need to output complete commit hashes, authors, commit times, or other metadata; include such information only when it is genuinely helpful for understanding the changes.
- The `@` attribution comes from the Git author name (`git log --format=%an`); it is not guaranteed to be the GitHub username. If the user wants actual GitHub handles, ask which mapping to use rather than guessing.
- When an item consolidates commits by several people, list every author; when a commit was authored by someone other than the committer, prefer the author.
- Reading diffs is recommended when commit messages are too terse to summarize reliably, when the range spans large refactors, or when the user explicitly asks for a thorough summary; for trivial, well-described commits it may be skipped for efficiency.
- The output should focus on change records that the end user can read directly and should avoid exposing irrelevant Git command execution details.

## Output Language

The change records should be output in the same language as the user's conversation. If the user's conversation is in Chinese, output the change records in Chinese; if it is in English, output the change records in English.
