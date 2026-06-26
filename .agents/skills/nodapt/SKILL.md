---
name: nodapt
description: Use this skill whenever working with Node.js, npm, npx, or Node.js version management. Always use nodapt to execute Node.js-related commands.
---

# Nodapt

Use `nodapt` whenever interacting with Node.js.

This includes:

- `node`
- `npm`
- `npx`
- Node.js version management
- Projects with a Node.js version requirement

---

## When to Use

ALWAYS use `nodapt` when:

- Running `node`, `npm`, or `npx` commands.
- The project specifies `engines.node` in `package.json`.
- The user requests a specific Node.js version.
- Installing, removing, listing, or switching Node.js versions.
- The user mentions `nodapt`.

Do not invoke `node`, `npm`, or `npx` directly unless the user explicitly requests otherwise.

---

## Running Commands

Prefer automatic version selection whenever possible.

Examples:

```bash
nodapt node -v

nodapt npm install

nodapt npm test

nodapt npm run build

nodapt npx vite
```

If the project defines `engines.node`, rely on automatic version resolution.

---

## Using a Specific Node.js Version

When the user specifies a version, use:

```bash
nodapt use 22 npm test

nodapt use 20 node app.js

nodapt use ^18 npm install
```

If the requested version is ambiguous or invalid, ask the user for clarification before proceeding.

Examples:

- `14`
- `14.x`
- `latest`
- `lts`

Clarify whether the user wants a major version, an exact version, or a version range.

---

## Version Management

Use:

```bash
nodapt ls
```

to list installed versions.

Use:

```bash
nodapt ls-remote
```

to list available versions.

Use:

```bash
nodapt rm <version>
```

to remove a version.

Use:

```bash
nodapt clean
```

to remove all installed versions.

---

## Error Handling

If no compatible Node.js version is found:

- Suggest checking the project's `package.json`.
- Suggest specifying a Node.js version explicitly.

If a version does not exist:

- Recommend running:

```bash
nodapt ls-remote
```

If the version format is unclear:

- Ask the user to clarify before executing any command.

---

## Best Practices

ALWAYS:

- Respect `package.json` version constraints.
- Prefer automatic version resolution.
- Use explicit versions in CI environments.
- Reuse existing installed versions whenever possible.

NEVER:

- Ignore `engines.node` if it exists.
- Guess an ambiguous Node.js version.
- Execute Node.js commands without `nodapt`, unless explicitly requested by the user.

---

## Summary

When working with Node.js:

- ALWAYS execute commands through `nodapt`.
- ALWAYS respect the project's Node.js version requirements.
- ALWAYS ask for clarification if the requested version is ambiguous.
- NEVER guess the intended Node.js version.
