---
name: code-modification-guidelines
description: Mandatory workflow and safety rules for AI assistants when modifying existing codebases.
-----------------------------------------------------------------------------------------------------

# Code Modification Guidelines

## Overview

This document defines the mandatory workflow, constraints, and best practices for AI assistants when modifying existing code.

The primary goal is to ensure that all code modifications are:

* Safe
* Minimal
* Traceable
* Reviewable
* Backward compatible
* Easy to verify and rollback

The assistant MUST follow these guidelines whenever modifying existing code unless the user explicitly overrides them.

---

# Core Principles

## 1. Minimum Change Principle

Modify only the code required to solve the requested problem.

Do NOT:

* Refactor unrelated code
* Reformat unrelated sections
* Rename symbols without necessity
* "Improve" surrounding code without instruction
* Introduce architectural changes unless requested

Avoid "drive-by" modifications.

---

## 2. Backward Compatibility

Preserve existing behavior, APIs, interfaces, side effects, and execution order unless explicitly instructed otherwise.

The assistant MUST NOT silently:

* Change function signatures
* Modify return structures
* Alter timing behavior
* Change async/sync semantics
* Change error handling behavior
* Remove deprecated APIs
* Change public interfaces

If breaking changes are necessary, they MUST be explicitly documented.

---

## 3. Safety First

Any modification that could potentially introduce regressions, behavioral changes, or compatibility risks MUST include:

* Risk assessment
* Impact scope
* Rollback strategy
* Verification steps

High-risk modifications MUST be clearly warned about before execution.

---

## 4. Verifiable Changes

Every modification MUST include:

* A validation method
* Expected behavior
* Affected scenarios
* Suggested test cases

Changes should be easy to review and verify.

---

## 5. Traceable Modifications

All meaningful modifications SHOULD be traceable.

When appropriate:

* Add modification comments
* Preserve previous implementations temporarily
* Explain WHY the change exists
* Explain expected impact

Do not make unexplained behavioral changes.

---

## 6. Preserve Existing Style

Follow the existing project conventions.

This includes:

* Naming style
* Formatting style
* File organization
* Error handling patterns
* Async patterns
* Architectural conventions

Do NOT modernize legacy code unless explicitly requested.

---

# Mandatory Workflow

# Phase 1: Understand & Assess (Required)

Before writing or modifying code, the assistant MUST:

1. Understand the original intent

   * Read surrounding code
   * Read comments and documentation
   * Understand why the code exists

2. Identify dependencies

   * What calls this code?
   * What depends on its behavior?
   * Is it public or internal?

3. Assess impact scope

   * Which files/functions/modules are affected?
   * Are side effects possible?
   * Could this affect runtime behavior?

4. Detect risk level

   * Low / Medium / High

5. Produce an assessment report BEFORE modification

---

# Phase 2: Propose Solution

The assistant MUST describe the modification plan before generating code.

Use the following structure:

```yaml
Solution Structure:
  Goal:
    One-sentence description of the problem being solved

  Description:
    Brief explanation of the chosen approach

  Files Changed:
    - file1
    - file2

  Risk Points:
    - Potential issue
    - Compatibility concern
    - Regression possibility

  Rollback Plan:
    - How to revert safely

  Alternatives:
    - Optional alternative approaches
```

---

# Phase 3: Execute Modification

## Modification Rules

```yaml
Modification Rules:
  - Follow the minimum change principle
  - Preserve backward compatibility
  - Keep surrounding code untouched
  - Add comments when behavior changes
  - Do not silently change logic
  - Keep deprecated APIs when possible
  - Use named constants instead of magic numbers
  - Follow existing project style
  - Preserve existing comments
  - Avoid unnecessary refactoring
  - When adding/modifying code comments or descriptions, the language used should be consistent with that of the rest of the code.
```

---

## Deletion Rules

Before deleting important code:

* Explain why deletion is safe
* Prefer deprecation over removal
* Comment out code temporarily when appropriate
* Mention potentially affected callers

---

## Refactoring Rules

When refactoring:

* Keep public interfaces stable
* Preserve old signatures with `@deprecated`
* Avoid large-scale rewrites
* Keep migration paths clear

---

# Phase 4: Validate & Output

The assistant MUST provide:

```yaml
Output Content:
  - Assessment report
  - Solution proposal
  - Complete modified code
  - Line-by-line change summary
  - Verification steps
  - Risk reminders
  - Rollback guidance
```

---

# Specific Constraints

## Language-Specific Rules

| Language   | Constraints                                             |
| ---------- | ------------------------------------------------------- |
| Python     | Follow PEP8; avoid unnecessary import reordering        |
| JavaScript | Preserve `this` behavior; keep async style consistent   |
| TypeScript | Preserve type safety; avoid weakening types             |
| Java       | Keep package paths unchanged; preserve serialVersionUID |
| Go         | Preserve existing error handling patterns               |
| Rust       | Do not alter lifetimes unnecessarily                    |
| C/C++      | Avoid changing memory ownership semantics               |
| Shell      | Preserve exit codes and environment behavior            |

---

# Prohibited Actions

The assistant MUST NOT:

* ❌ Delete comments without reason
* ❌ Reformat entire files
* ❌ Rewrite working code unnecessarily
* ❌ Rename identifiers without necessity
* ❌ Change coding style across files
* ❌ Introduce new frameworks/libraries without approval
* ❌ Modify unrelated code paths
* ❌ Silently change behavior
* ❌ Assume missing requirements
* ❌ Over-engineer simple fixes

---

# Permitted Incidental Improvements

The following are allowed ONLY if documented:

* ✅ Fix obvious typos
* ✅ Add missing imports
* ✅ Remove confirmed unused variables
* ✅ Add defensive null checks
* ✅ Improve comments for clarity

All incidental improvements MUST be mentioned in the report.

---

# Output Format Template

The assistant MUST use the following structure when responding to code modification requests.

## 📋 Modification Assessment

**Goal**:
[One sentence]

**Impact Scope**:
[List affected files/functions/modules]

**Risk Level**:
🟢 Low / 🟡 Medium / 🔴 High

---

## 🔧 Proposed Solution

[Brief explanation of the modification approach]

---

## 📝 Change Details

| Line | Original | New | Reason |
| ---- | -------- | --- | ------ |
| ...  | ...      | ... | ...    |

---

## ✅ Modified Code

```language
// Complete modified code
```

---

## 🧪 Verification Method

Describe:

1. How to test
2. Expected output
3. Edge cases
4. Regression checks

---

## ⚠️ Important Notes

Include:

* Breaking changes
* Manual migration steps
* Compatibility concerns
* Potentially affected callers
* Rollback guidance

---

# Example

## 📋 Modification Assessment

**Goal**:
Improve sorting performance from O(n²) to O(n log n)

**Impact Scope**:
`sort_items()` function only

**Risk Level**:
🟡 Medium

---

## 🔧 Proposed Solution

Replace manual bubble sort with Python's built-in Timsort while preserving sorting semantics.

---

## 📝 Change Details

| Line  | Original         | New               | Reason              |
| ----- | ---------------- | ----------------- | ------------------- |
| 23-27 | Bubble sort loop | `items.sort(...)` | Improve performance |

---

## ✅ Modified Code

```python
def sort_items(items):
    # MODIFIED:
    # Replaced manual bubble sort with Python Timsort.
    # Expected behavior remains unchanged.
    items.sort(key=lambda x: x.priority)
    return items
```

---

## 🧪 Verification Method

Run:

```bash
python test_sort.py
```

Verify:

1. Sorting output matches previous behavior
2. Empty arrays work
3. Duplicate values preserve ordering
4. `None` handling still works

---

## ⚠️ Important Notes

The original implementation had implicit handling for `None` values.
Verify compatibility before deployment.

---

# Self-Check Checklist

Before responding, the assistant MUST confirm:

* [ ] Did I fully understand the requested change?
* [ ] Did I assess impact scope?
* [ ] Did I minimize modifications?
* [ ] Did I preserve backward compatibility?
* [ ] Did I avoid unrelated refactoring?
* [ ] Did I explain risks?
* [ ] Did I provide verification steps?
* [ ] Did I preserve existing style?
* [ ] Did I avoid silent behavior changes?
* [ ] Did I document incidental improvements?
