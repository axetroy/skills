---
name: code-modification-guidelines
description: Use this skill whenever modifying an existing codebase. Ensure all changes are safe, minimal, backward compatible, and consistent with the existing project.
---

# Code Modification Guidelines

When modifying an existing codebase, follow these rules.

## Core Principles

### Make the smallest possible change

ONLY modify code that is necessary to accomplish the user's request.

NEVER:

- Modify unrelated code.
- Refactor unrelated modules.
- Rename symbols without necessity.
- Reformat existing code.
- Perform subjective improvements or opportunistic optimizations.

---

### Preserve existing behavior

Unless the user explicitly requests otherwise, preserve the existing behavior.

NEVER:

- Change function signatures.
- Change public APIs.
- Change return values or structures.
- Change synchronous or asynchronous behavior.
- Change error handling semantics.
- Change execution order or side effects.

Treat backward compatibility as the default.

---

### Preserve project conventions

Follow the project's existing conventions.

ALWAYS:

- Use the existing coding style.
- Use the existing architecture.
- Use the existing libraries and patterns.

NEVER introduce a different style or architecture unless explicitly requested.

---

### Make behavior changes explicit

Behavior changes MUST be intentional and visible.

NEVER:

- Silently change business logic.
- Introduce undocumented behavior changes.
- Assume requirements that were not stated.

If a requested change is potentially breaking, clearly explain the impact before implementing it.

---

### Prefer safety over optimization

System stability is more important than code cleanliness.

When in doubt:

- Prefer conservative changes.
- Prefer compatibility.
- Prefer predictable behavior.

---

## Required Workflow

Before modifying code:

1. Understand the purpose of the existing code.
2. Understand its dependencies.
3. Evaluate the scope of the change.
4. Consider possible side effects.

During implementation:

- Change only what is necessary.
- Keep unrelated logic untouched.
- Minimize the affected scope.
- Avoid cascading modifications across modules.

After implementation:

- Ensure the change is testable.
- Ensure behavioral changes are observable.
- Consider regression risks.

---

## Allowed Changes

Typical acceptable changes include:

- Fixing confirmed bugs.
- Implementing the user's requested behavior.
- Adding required defensive checks.
- Removing confirmed dead code.
- Adding missing dependencies required for the requested change.

---

## Prohibited Changes

NEVER:

- Rewrite working code without a clear reason.
- Modify unrelated files.
- Introduce unnecessary dependencies.
- Replace existing libraries or frameworks.
- Perform large-scale refactoring.
- Change project-wide coding style.
- Modernize code without being asked.
- Introduce breaking changes without explanation.
- Infer or implement requirements that the user did not specify.

---

## Language-Specific Rules

Respect the semantics of the target language.

Examples:

- JavaScript / TypeScript: Preserve `this` binding and asynchronous behavior.
- Python: Preserve existing structure and coding style.
- Java: Preserve package structure and serialization compatibility.
- Go: Preserve the existing error handling pattern.
- Rust: Avoid unnecessary lifetime changes.
- C / C++: Preserve memory semantics.
- Shell: Preserve exit codes and environment behavior.

---

## Summary

When modifying existing code:

- ALWAYS understand before changing.
- ALWAYS minimize the scope of changes.
- ALWAYS preserve existing behavior by default.
- ALWAYS follow the project's conventions.
- NEVER modify unrelated code.
- NEVER introduce unnecessary refactoring.
- NEVER make implicit behavior changes.
- NEVER assume requirements that the user did not specify.
