# JavaScript / Node.js (npm, pnpm, yarn, bun)

## Signal files

- `package.json` (required)
- Lockfiles: `package-lock.json` (npm), `pnpm-lock.yaml` (pnpm), `yarn.lock` (yarn 1-4), `bun.lock` / `bun.lockb` (bun)

## 1. Preferred tools

Require `node_modules` to be installed. Use the matching package manager.

npm:

```bash
npx license-checker-rseidelsohn --production --json --out notices.json
```

- `--production` excludes devDependencies; drop it to include everything.
- `npx` will download the tool — get permission first if required.
- Output fields include `licenses`, `repository`, `copyright`, and `licenseText`.

pnpm:

```bash
pnpm licenses list
pnpm licenses list --json
```

yarn classic (1.x):

```bash
yarn licenses list --json
```

yarn berry (2+): import the official plugin, then list:

```bash
yarn plugin import licenses
yarn licenses list --json
```

bun: no built-in license command — use the lockfile fallback below.

## 2. Fallback: parse the lockfile

- `package-lock.json` (v2/v3): the `packages` map. Each entry has `version` and may include `license` / `repository`. The root entry `packages[""]` describes the project itself.
- `pnpm-lock.yaml` (v9+): entries under `packages` include `version` and `license` / `licenses` fields.
- `yarn.lock`: blocks keyed by `name@range:`; no license metadata — resolve each via the npm registry.
- `bun.lock` (text or binary): package entries carry `version`; resolve license via the npm registry.

## 3. Resolving licenses

Per package, query the npm registry (no auth required):

```text
https://registry.npmjs.org/<name>/<version>
```

The response includes `license` (SPDX id or an object), `repository`, and occasionally `copyright`.

Full license text, in order of preference:

1. From the `license-checker` JSON (`licenseText` field).
2. From the installed package: `node_modules/<name>/LICENSE*` / `COPYING*`.
3. From the registry tarball: `https://registry.npmjs.org/<name>/-/<name>-<version>.tgz` (read the license file inside), or `https://unpkg.com/<name>@<version>/LICENSE`.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- Scoped packages: URL-encode the scope, e.g. tarball `https://registry.npmjs.org/@scope/name/-/name-<version>.tgz`.
- Monorepos / workspaces: run once per workspace package, or treat the workspace root as the manifest and union all workspace deps.
- `UNLICENSED` / `SEE LICENSE IN ...`: copy the referenced text or mark UNKNOWN.
- Dual `license` object `{ type, url }`: use `type`.
- The same package+version may appear in several lockfile sections — deduplicate.
- dev / bundled / optional deps: `--production` filters devDependencies; keep the rest as shipped.
