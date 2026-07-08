---
name: conventional-commits
description: Use the Conventional Commits specification to write Git Commit Messages, automatically applying it when creating, modifying, or optimizing commit messages.
---

---

# Conventional Commits

## Purpose

Use this Skill whenever you need to write, modify, optimize, or review a Git Commit Message.

Applicable scenarios include, but are not limited to:

- Writing a new Git Commit Message
- Generating a Commit Message based on code changes
- Modifying an existing Commit Message
- Standardizing commit conventions across a team
- Working with automation tools such as commitlint, semantic-release, release-please, and Changesets
- Automatically generating a Changelog or version number based on commits

Not applicable to:

- Pull Request titles (unless your team requires the same convention)
- Issue titles
- The body of Release Notes
- General text descriptions

This Skill follows the Conventional Commits 1.0.0 specification. ([Conventional Commits][1])

---

## ALWAYS (Mandatory Rules)

- MUST use the following basic format:

```text
<type>[optional scope][!]: <description>
```

- MUST use a standard ASCII colon (`:`) followed by a single space.

- MUST choose a clear `type` for every commit.

- MUST use `feat` when introducing a new feature.

- MUST use `fix` when fixing a bug.

- MUST mark breaking changes using either `!` or `BREAKING CHANGE:`.

- MUST keep the title (`description`) concise and focused on the primary change in the commit.

- MUST wrap `scope` (if present) in parentheses.

- MUST leave one blank line between the title and the body (if present).

- MUST leave one blank line between the body and the footer (if present).

- MUST keep `BREAKING CHANGE:` fully uppercase.

- MUST ensure each Commit represents a single primary purpose. If multiple unrelated changes are included, split them into separate Commits. ([Conventional Commits][1])

---

## NEVER (Prohibited Practices)

### Do not omit the type

Reason: Automation tools cannot recognize the commit type.

❌

```text
Fix login issue
```

✅

```text
fix(auth): Fix login failure
```

---

### Do not use meaningless descriptions

Reason: They do not help readers understand the commit history.

❌

```text
feat: update
```

```text
fix: change
```

```text
chore: modify
```

✅

```text
feat(auth): Add support for WeChat login
```

```text
fix(cache): Fix duplicate requests caused by cache invalidation
```

---

### Do not combine multiple unrelated changes into a single Commit

Reason: It reduces readability and negatively impacts version analysis and rollback.

❌

```text
feat: Add user management, fix payment bug, and update README
```

✅

```text
feat(user): Add user management system
```

```text
fix(payment): Fix payment failure
```

```text
docs: Update README
```

---

### Do not misuse `feat` and `fix`

Reason: It affects automatic Semantic Version calculation.

❌

```text
feat: Fix login issue
```

✅

```text
fix(auth): Fix login issue
```

---

### Do not omit `BREAKING CHANGE`

Reason: Major compatibility changes cannot be detected automatically.

❌

```text
feat(api): Remove v1 API
```

✅

```text
feat(api)!: Remove v1 API
```

or

```text
feat(api): Remove v1 API

BREAKING CHANGE: Remove all v1 endpoints. Please migrate to v2.
```

---

## Common Patterns

### Pattern 1: Adding a New Feature

```text
feat(auth): Add GitHub OAuth login support
```

---

### Pattern 2: Fixing a Bug

```text
fix(parser): Fix JSON parsing error
```

---

### Pattern 3: Using a Scope

```text
feat(cli): Add init command
```

```text
refactor(core): Refactor plugin loading workflow
```

---

### Pattern 4: Including a Body

```text
feat(storage): Add object storage support

Add support for both S3 and MinIO backends.

Unify the Storage Provider interface for easier future extensions.
```

---

### Pattern 5: Including a Footer

```text
fix(api): Fix incorrect pagination parameters

Pagination parameters were incorrectly ignored when offset was 0.

Refs: #102
Reviewed-by: Alice
```

---

### Pattern 6: Breaking Changes

```text
feat(config)!: Refactor configuration system
```

or

```text
feat(config): Refactor configuration system

BREAKING CHANGE: Change the configuration file format from YAML to TOML.
```

---

### Pattern 7: Recommended Types

```text
feat(ui): Add theme switching

fix(login): Fix login issue

docs: Update API documentation

style: Adjust code formatting

refactor(core): Refactor task scheduler

perf(cache): Improve cache hit rate

test(api): Add API tests

build: Upgrade webpack

ci: Update GitHub Actions

chore: Update development tool configuration

revert: Revert previous changes
```

Where:

| Type     | Purpose                                                 |
| -------- | ------------------------------------------------------- |
| feat     | New feature                                             |
| fix      | Bug fix                                                 |
| docs     | Documentation changes                                   |
| style    | Code style changes that do not affect logic             |
| refactor | Code refactoring without adding features or fixing bugs |
| perf     | Performance improvements                                |
| test     | Test-related changes                                    |
| build    | Build system or dependency changes                      |
| ci       | CI/CD changes                                           |
| chore    | Miscellaneous maintenance                               |
| revert   | Revert a previous commit                                |

---

## Notes

- `scope` is optional and should use a module name that accurately describes the affected area, such as `api`, `cli`, `core`, `ui`, `auth`, or `parser`.
- In addition to `feat` and `fix`, new `type` values may be introduced according to team conventions, but they should remain consistent across the project. ([Conventional Commits][1])
- `feat` typically corresponds to a **MINOR** update under Semantic Versioning (SemVer).
- `fix` typically corresponds to a **PATCH** update under Semantic Versioning (SemVer).
- Any commit type containing `BREAKING CHANGE` or `!` corresponds to a **MAJOR** update. ([Conventional Commits][1])
- Footers are recommended to follow the Git Trailer format, for example:

```text
Refs: #123
Closes: #456
Reviewed-by: Alice
Co-authored-by: Bob <bob@example.com>
```

- It is recommended to keep Commit titles short, focused, and readable. Each Commit should represent a single logical change to facilitate review, rollback, and automatic Changelog generation.

[1]: https://www.conventionalcommits.org/en/v1.0.0/ "Conventional Commits"
