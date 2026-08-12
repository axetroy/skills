---
name: skill-generator
description: Creates, reviews, and repairs Agent Skills that follow the agentskills.io specification. Use when the user asks to create a new skill, generate a SKILL.md, package a skill directory, validate Agent Skill metadata, or improve an existing skill for portability and progressive disclosure.
metadata:
  author: openai
  version: "1.0"
---

# Skill Generator

Create high-quality, portable Agent Skills from a natural-language requirement. Treat the skill as a small software artifact: define a precise trigger description, keep the core instructions concise, move detailed material into references, and validate the resulting structure.

## Workflow

### 1. Understand the requested capability

Extract:

- **Capability**: what the generated skill should help an agent do.
- **Trigger conditions**: what kinds of user requests should activate it.
- **Inputs**: files, text, parameters, tools, or external resources it may receive.
- **Outputs**: artifacts, edits, decisions, or responses it should produce.
- **Constraints**: runtime, operating system, dependencies, network access, or product-specific requirements.
- **Examples**: representative requests that should and should not trigger the skill.

If important requirements are missing, make conservative assumptions and state them briefly. Ask a clarification only when the missing information would materially change the skill's behavior.

### 2. Choose a valid skill name

The directory name and frontmatter `name` must be identical.

Use only lowercase ASCII letters, numbers, and single hyphens. The name must:

- be 1–64 characters;
- not start or end with `-`;
- not contain `--`;
- match the parent directory name exactly.

Prefer a short, capability-oriented name such as `api-doc-generator`, `release-notes`, or `frontend-review`.

Do not use uppercase, spaces, underscores, punctuation, or a name that describes the implementation rather than the capability.

### 3. Write a routing-quality description

The `description` is the primary discovery mechanism, so make it specific.

It must be 1–1024 characters and should say:

1. what the skill does;
2. when it should be used;
3. important synonyms or task keywords.

Prefer:

> Generates and validates OpenAPI documentation from source code. Use when documenting HTTP APIs, creating OpenAPI specs, or updating API reference material.

Avoid vague descriptions such as:

> Helps with APIs.

Do not put the complete procedure into the description. Keep it focused on routing.

### 4. Design the skill for progressive disclosure

The skill directory should normally look like:

```text
skill-name/
├── SKILL.md
├── scripts/       # only when executable automation is useful
├── references/    # detailed instructions loaded on demand
└── assets/        # templates, schemas, examples, or static resources
```

Keep `SKILL.md` under 500 lines and preferably below about 5,000 tokens.

Put only activation-relevant workflow and decision rules in `SKILL.md`. Move large tables, exhaustive API references, long examples, schemas, and domain-specific details into `references/`.

Reference files directly from `SKILL.md` using one-level relative paths, for example:

```text
See [the detailed reference](references/REFERENCE.md).
```

Avoid deep chains of references.

### 5. Write actionable instructions

The body should tell an executing agent what to do, not merely describe the topic.

Use:

- ordered steps for workflows;
- explicit decision points;
- concrete output requirements;
- validation gates;
- failure handling;
- concise examples where ambiguity is likely.

Prefer imperative language:

> Inspect the input schema. Preserve existing field names. Report incompatible changes before modifying files.

Avoid generic advice:

> Be careful and make good decisions.

When tools or scripts are required, name them explicitly and document their dependencies.

### 6. Add optional files only when they earn their context cost

Use `scripts/` for repeatable executable operations that are easier and safer to run than to reproduce manually. Scripts should be self-contained or document dependencies and provide useful errors.

Use `references/` for detailed material that is not needed on every activation.

Use `assets/` for static templates, schemas, examples, images, or other resources.

Do not create empty optional directories.

### 7. Handle safety and scope

The generated skill should not silently broaden its authority.

- State destructive or irreversible actions explicitly.
- Preserve user data unless the task requires modification.
- Ask for confirmation before consequential actions when the host agent's conventions require it.
- Never invent credentials, permissions, tool capabilities, or external facts.
- Distinguish required tools from optional tools.
- If an environment requirement is real, put it in `compatibility`; otherwise omit that field.

Avoid `allowed-tools` unless the target environment explicitly supports and requires it because the field is experimental and support varies.

### 8. Produce the skill artifact

When asked to **create/generate** a skill, produce the complete directory, not only a prose description.

At minimum create:

```text
<skill-name>/SKILL.md
```

If useful, also create `references/`, `scripts/`, or `assets/`.

When asked to **review** an existing skill, inspect the whole directory and report:

- frontmatter validity;
- name/directory consistency;
- description quality;
- instruction clarity;
- progressive-disclosure opportunities;
- file-reference correctness;
- unnecessary or missing resources;
- portability concerns.

When asked to **repair** a skill, make the smallest changes needed to satisfy the specification and preserve intended behavior.

### 9. Validate before finishing

Perform these checks:

- `SKILL.md` exists at the skill root.
- YAML frontmatter is present and parseable.
- `name` exists and satisfies the naming rules.
- `name` exactly matches the parent directory.
- `description` exists, is non-empty, and is at most 1024 characters.
- If present, `compatibility` is at most 500 characters.
- `metadata` values are strings.
- Any referenced files exist and use paths relative to the skill root.
- `SKILL.md` stays below 500 lines when practical.
- The instructions do not depend on undocumented, imaginary tools.

If `skills-ref` is available, run:

```bash
skills-ref validate ./<skill-name>
```

Treat validator failures as blockers. If the validator is unavailable, perform the checks above manually and clearly say that the reference validator was not run.

## Output conventions

For a newly generated skill, return:

1. the created skill directory;
2. a short summary of what it does;
3. any assumptions or environment requirements;
4. validation status.

Do not add unrelated documentation to the skill package merely to make it look complete.

## Example

User request:

> Create a skill that turns a repository's changelog entries into release notes.

A suitable result is a directory named `release-notes-generator` whose `SKILL.md` contains a routing-specific description, an actionable workflow for collecting and grouping changelog entries, explicit rules for preserving factual accuracy, and a validation step. Long formatting examples belong in `references/`, not in the main file.
