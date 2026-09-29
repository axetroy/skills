---
name: nodapt
description: Use this skill whenever working with Node.js, npm, npx, yarn, pnpm, or Node.js version management. Always use nodapt to execute Node.js-related commands. Also use nodapt when the user wants to switch Node.js environments, or when the current Node.js environment does not satisfy the project's or task's requirements.
---

# Nodapt

Use `nodapt` whenever interacting with Node.js.

This includes:

- `node`
- `npm`
- `npx`
- Node.js version management
- Projects with a Node.js version requirement
- Switching Node.js environments
- Tasks where the current Node.js environment is incompatible or insufficient
- Resolving Node.js version compatibility issues

---

## When to Use

ALWAYS use `nodapt` when:

- Running `node`, `npm`, or `npx` commands.
- The project specifies `engines.node` in `package.json`.
- The user requests a specific Node.js version.
- The user wants to switch Node.js versions or environments.
- The user wants to use a different Node.js environment for a task.
- The current Node.js version does not satisfy the project's requirements.
- The current Node.js environment causes a compatibility or execution error.
- Installing, removing, listing, or switching Node.js versions.
- The user mentions `nodapt`.

If the current Node.js environment is not suitable for the task, use `nodapt` to select a compatible Node.js version before retrying the task.

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

When a Node.js-related command fails because the current Node.js version is incompatible, retry it through `nodapt` so that a compatible version can be selected automatically.

---

## Switching Node.js Environments

When the user wants to switch Node.js environments, first determine the required version from the project or task whenever possible.

Prefer automatic version selection:

```bash
nodapt node -v
nodapt npm install
```

If the project defines `engines.node`, let `nodapt` resolve the compatible version automatically.

When the user specifies a version, use:

```bash
nodapt use 22 npm test

nodapt use 20 node app.js

nodapt use ^18 npm install
```

If the user wants to switch the environment for subsequent commands, use the appropriate `nodapt` version-selection mechanism rather than manually changing `PATH` or invoking a system Node.js binary.

### `nodapt use` ALWAYS Requires a Version AND a Command

NEVER run `nodapt use` on its own, and NEVER run `nodapt use <version>` alone. Two rules:

1. The version argument is mandatory.
2. A command MUST follow the version.

Running `nodapt use <version>` without a trailing command starts a Node.js REPL, which never exits and causes the agent to hang indefinitely. This is a critical failure mode — avoid it.

```bash
# ❌ WRONG — no version specified
nodapt use

# ❌ WRONG — version specified but no command; starts a REPL and hangs the agent
nodapt use 20

# ✅ CORRECT — version specified AND a command follows
nodapt use 20 npm test

nodapt use 20 node app.js
```

Before running `nodapt use`, you MUST have both a concrete version AND a command to run:

1. Read the required version from the project (`package.json` → `engines.node`, `.nvmrc`, `.node-version`).
2. If the project does not define one, ask the user which version they want.
3. If the version is ambiguous (e.g. `14`, `14.x`, `latest`, `lts`), ask the user to clarify whether they mean a major version, an exact version, or a version range before executing anything.

Do not guess. Do not run `nodapt use` without a version to let it pick a default, and do not run `nodapt use <version>` without a trailing command.

If you only want to verify the effective Node.js version, include a command that exits immediately:

```bash
nodapt use 20 node -v
```

If `nodapt use` fails because the version is not installed, check available versions with `nodapt ls-remote` and then retry with the resolved version.

---

## Handling Incompatible Node.js Environments

If the current Node.js environment does not satisfy the task requirements:

1. Check the project's `package.json` for `engines.node` when available.
2. Determine the required Node.js version or version range.
3. Use `nodapt` to select a compatible version.
4. Retry the Node.js-related command using `nodapt`.
5. If no compatible version is installed, determine whether an appropriate version is available remotely.

For example, if the project requires Node.js 20 or newer and the current environment is incompatible, use:

```bash
nodapt use 20 npm install
```

If the project specifies a version range, prefer the compatible version resolved by `nodapt` rather than guessing a version manually.

Do not work around a Node.js version incompatibility by ignoring `engines.node`.

When selecting the version, ALWAYS pass it explicitly to `nodapt use` AND always follow it with a command. NEVER invoke `nodapt use` without a version argument, and NEVER run `nodapt use <version>` alone — it starts a REPL and hangs the agent.

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

When a required Node.js version is not installed, check available versions with:

```bash
nodapt ls-remote
```

Then select a compatible version with `nodapt`.

---

## Error Handling

If no compatible Node.js version is found:

- Suggest checking the project's `package.json`.
- Suggest specifying a Node.js version explicitly.
- If necessary, use `nodapt ls-remote` to determine whether a compatible version is available.

If a version does not exist:

- Recommend running:

```bash
nodapt ls-remote
```

If the version format is unclear:

- Ask the user to clarify before executing any command.

If a Node.js-related command fails due to a version mismatch:

- Treat the failure as a reason to check Node.js compatibility.
- Inspect `package.json` and relevant project configuration when available.
- Use `nodapt` to switch to a compatible Node.js environment.
- Retry the command after switching versions.

---

## Best Practices

ALWAYS:

- Respect `package.json` version constraints.
- Prefer automatic version resolution whenever possible.
- Specify an explicit version when running `nodapt use`.
- Follow `nodapt use <version>` with a command to execute.
- Use `nodapt` when switching Node.js environments.
- Use `nodapt` when the current Node.js environment is incompatible with the task.
- Use explicit versions in CI environments.
- Reuse existing installed versions whenever possible.
- Verify the effective Node.js environment before retrying a failed Node.js-related task.

NEVER:

- Run `nodapt use` without a version argument.
- Run `nodapt use <version>` without a trailing command — it starts a REPL and hangs the agent.
- Ignore `engines.node` if it exists.
- Guess the intended Node.js version when the requirement is ambiguous.
- Execute Node.js commands without `nodapt`, unless explicitly requested by the user.
- Manually bypass `nodapt` to work around Node.js version incompatibilities.
- Assume the current Node.js environment is suitable after a version-related failure without checking compatibility.

---

## Summary

When working with Node.js:

- ALWAYS execute commands through `nodapt`.
- ALWAYS respect the project's Node.js version requirements.
- ALWAYS pass an explicit version to `nodapt use` AND follow it with a command (e.g. `nodapt use 20 npm test`).
- ALWAYS use `nodapt` when the user wants to switch Node.js environments.
- ALWAYS use `nodapt` when the current Node.js environment does not satisfy the task requirements.
- ALWAYS ask for clarification if the requested version is ambiguous.
- NEVER run `nodapt use` on its own without a version.
- NEVER run `nodapt use <version>` alone — it starts a REPL and hangs the agent.
- NEVER guess the intended Node.js version.
- NEVER bypass `nodapt` to work around an incompatible Node.js environment.
