---
name: git-tag-change-summary
description: This Skill is used to generate change records based on the commit history and Tag information of a Git repository, and is applicable to scenarios where version changes need to be summarized.
---

# Git Tag Change Summary

## Purpose

This Skill is applicable when the current working directory is already a Git repository and change records need to be generated based on the actual Git commit history. The core scope is:

1. Determine the current Git status and `HEAD`.
2. Find the previous Tag to use as the change baseline.
3. Retrieve the commit records between that Tag and the current state.
4. Summarize the changes based on the actual commit contents.
5. Output the change records as a numbered list, listing items `1.` through `4.` by default.

If the repository has no Tags, or if a valid Tag baseline cannot be determined, this must be explicitly stated, and the change range must not be fabricated.

## ALWAYS

- MUST check `HEAD` and Tag information in the current Git repository before summarizing changes.
- MUST prioritize actual Git commit records as the data source for the change summary.
- MUST determine the specific name of the change baseline Tag and confirm that there is an analyzable commit range between it and the current `HEAD`.
- MUST use `git log <previous-tag>..HEAD` or an equivalent method to retrieve commit records after the baseline Tag.
- MUST, when the current `HEAD` already corresponds to a Tag, use the Tag immediately before that Tag as the baseline, in order to summarize the complete changes of the current Tag relative to the previous Tag.
- MUST consolidate multiple related commits into changes that are understandable to users rather than mechanically copying commit messages one by one.
- MUST preserve the accuracy of important technical terms, module names, APIs, file paths, and version numbers.
- MUST generate changes based on the actual commit contents and must not use fixed template content to masquerade as real changes.
- MUST output a numbered list using at least the `1.`, `2.`, `3.`, `4.` format; if there are clearly fewer than four actual changes, content must not be fabricated just to fill the list.
- MUST, when sufficient information exists, merge duplicate, related, or multiple commits concerning the same feature into a single logical change item.
- MUST distinguish between different types of changes, such as feature additions, feature modifications, bug fixes, refactoring, dependency upgrades, and build or engineering configuration changes.
- MUST explicitly state the reason and stop generating change records based on guesses when there is no valid commit range.

## NEVER

- NEVER infer the entire version's change scope from only the most recent few commit messages, as this may omit other commits after the Tag.

```bash
# ❌ 错误：只查看最近 4 条提交
git log -4 --oneline

# ✅ 正确：查看上一个 Tag 到当前 HEAD 的完整提交范围
git log <previous-tag>..HEAD --oneline
```

- NEVER use the current date, Tag name, or common Release Notes templates to guess nonexistent feature changes, because change records must come from the actual repository history.

```text
❌ 1. 新增用户登录功能
❌ 2. 优化性能
❌ 3. 修复若干 Bug
❌ 4. 升级依赖

# 如果这些内容没有对应的实际提交，就不能写入结果。
```

- NEVER list every commit message verbatim and call it a "change summary", because users need consolidated change records.

```text
❌ 1. fix: xxx
❌ 2. fix: xxx
❌ 3. feat: xxx
❌ 4. chore: xxx

# ✅ 应归纳为逻辑变更
1. 修复 xxx 场景下的错误处理问题。
2. 新增 xxx 功能，并完善相关逻辑。
```

- NEVER use an unrelated or excessively early Tag as the change baseline without checking the relationship between the Tag and `HEAD`.

```bash
# ❌ 错误：随意选择一个历史 Tag
git log v1.0.0..HEAD

# ✅ 正确：先确定距离当前 HEAD 最近且符合基线要求的 Tag
git describe --tags --abbrev=0 HEAD
```

- NEVER, when the current `HEAD` is already a Tag, use the current Tag itself as the "previous Tag" and skip the preceding Tag, as this would omit the complete changes of the current version relative to the previous version.

```text
❌ HEAD = v2.0.0
   基线 = v2.0.0

# ✅
HEAD = v2.0.0
当前 Tag = v2.0.0
上一个 Tag = v1.9.0
变更范围 = v1.9.0..v2.0.0
```

- NEVER modify, create, or delete Git Tags to perform the analysis task, because the responsibility of this Skill is to read and summarize history, not to alter version history.
- NEVER treat uncommitted working tree changes as Git commit changes unless the user explicitly requests that working tree differences also be analyzed.

## Common Patterns

### 1. Current HEAD is not tagged: summarize changes after the most recent Tag

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
1. 新增 xxx 功能，支持 xxx 场景。
2. 优化 xxx 模块的处理逻辑，改善 xxx。
3. 修复 xxx 场景下的错误问题。
4. 更新 xxx 依赖及相关工程配置。
```

### 2. Current HEAD is already a Tag: summarize changes of the current Tag relative to the previous Tag

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
1. 新增 xxx 能力。
2. 调整 xxx 模块，实现 xxx 行为。
3. 修复 xxx 条件下导致的 xxx 问题。
4. 优化构建、依赖或工程配置。
```

### 3. Many commits: consolidate by feature theme

When there are many commits between Tags, first obtain the commit list:

```bash
git log <previous-tag>..HEAD --oneline --no-merges
```

Then categorize them based on their contents, for example:

```text
功能新增：
- feat: add xxx
- feat: support xxx

问题修复：
- fix: xxx error
- fix: handle xxx

工程与依赖：
- chore: update xxx
- build: change xxx
```

Do not output the complete commit list in the final result. Instead, consolidate them into user-readable change records:

```text
1. 新增并完善 xxx 功能，支持 xxx 使用场景。
2. 修复 xxx 模块在 xxx 条件下的异常问题。
3. 优化 xxx 处理流程及相关性能。
4. 更新 xxx 依赖和构建配置。
```

## Notes

- `git describe --tags --abbrev=0 HEAD` is generally suitable for locating the most recent Tag reachable from the current `HEAD`, but "most recent" is based on the Git commit ancestry relationship and is not equivalent to simply sorting Tags by creation time.
- If the repository contains both annotated tags and lightweight tags, the actual Git reference relationships should be used as the basis rather than inferring version order solely from Tag names.
- If the current branch contains merge commits, `--first-parent`, ordinary `git log`, and `git diff` when necessary should be considered together to determine which changes belong to the current version; absolute conclusions must not be drawn from a single log view alone.
- If the repository has no Tags, explicitly state that the "previous Tag" cannot be determined, and, when permitted by the user, the summary can instead be based on all available commits.
- If there are no commits between Tags, for example when `git log <previous-tag>..HEAD` returns nothing, explicitly state that there are no new committed changes within the current range.
- If multiple branches or multiple Tags point to different histories, the baseline should be determined primarily according to the ancestry relationship of the current `HEAD`, rather than simply selecting the most recently created Tag in the repository.
- If the user requires the output to contain exactly four items but there are actually fewer than four types of changes, factual accuracy should take priority; related changes may be reasonably merged, but MUST NOT fabricate nonexistent changes.
- If the user only requests change records, there is generally no need to output complete commit hashes, authors, commit times, or other metadata; include such information only when it is genuinely helpful for understanding the changes.
- The output should focus on change records that the end user can read directly and should avoid exposing irrelevant Git command execution details.

## Output Language

The change records should be output in the same language as the user's conversation. If the user's conversation is in Chinese, output the change records in Chinese; if it is in English, output the change records in English.
