---
name: ripgrep
description: Use ripgrep (rg) for fast codebase search, symbol lookup, reference discovery, and project analysis.
---

# ripgrep

Use `rg` as the default search tool for source code.

## When to Use

Use `rg` whenever you need to:

- Find files.
- Locate symbols.
- Search code references.
- Search configuration values.
- Find environment variables.
- Analyze project structure.
- Estimate the impact of code changes.

Prefer `rg` over `grep`, `find | grep`, or other recursive search tools.

---

## Search Rules

### Prefer precise searches

Search for the exact identifier whenever possible.

Preferred:

```bash
rg -n "UserService"
```

Avoid unnecessarily broad patterns:

```bash
rg ".*UserService.*"
```

---

### Limit the search scope

When the target location is known, search only the relevant directory.

Example:

```bash
rg -n "UserService" src/
```

---

### Filter by file type

Restrict the search to relevant source files whenever possible.

Examples:

```bash
rg -n "UserService" -t ts

rg -n "UserService" -t js

rg -n "UserService" -t py
```

Avoid scanning unrelated files.

---

### Respect ignore files

By default, respect:

- `.gitignore`
- `.ignore`
- `.rgignore`

Do **not** use:

```bash
rg -uuu
```

unless hidden, generated, or ignored files are explicitly required.

---

## Common Operations

Find files:

```bash
rg --files
```

Find definitions:

```bash
rg -n "class User"

rg -n "function login"
```

Find references:

```bash
rg -n "UserService"
```

Find configuration:

```bash
rg -n "API_URL"

rg -n "TOKEN"
```

Find TODOs:

```bash
rg -n "TODO|FIXME"
```

---

## Advanced Search

Use PCRE (`-P`) only when advanced regular expressions are required.

Use multiline mode (`-U`) only for true multiline searches.

Avoid enabling either option by default.

---

## Search Workflow

When investigating existing code:

1. Find the definition.
2. Find all references.
3. Find related tests.
4. Evaluate the impact before making changes.

---

## Best Practices

ALWAYS:

- Use `rg -n` to include line numbers.
- Keep the search scope as small as possible.
- Prefer exact identifiers over broad patterns.
- Narrow directories before narrowing file types.

NEVER:

- Scan the entire filesystem.
- Perform unnecessarily broad recursive searches.
- Use complex regular expressions when a simple search is sufficient.
- Disable ignore rules unless explicitly necessary.

---

## Summary

When searching a codebase:

- ALWAYS use `rg`.
- ALWAYS include line numbers.
- ALWAYS minimize the search scope.
- ALWAYS respect ignore files.
- NEVER perform unnecessarily broad searches.
- NEVER use `grep -r` when `rg` is available.
