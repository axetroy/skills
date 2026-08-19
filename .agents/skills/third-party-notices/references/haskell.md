# Haskell (Cabal / Stack / Hpack)

## Signal files

- `*.cabal`, `package.yaml` (hpack), `stack.yaml`, `stack.yaml.lock`
- `cabal.project`, `cabal.project.freeze`

## 1. Preferred tools

```bash
stack ls dependencies                    # resolved package list
cabal freeze                             # writes cabal.project.freeze with exact versions
cabal list --installed                   # packages in the GHC package db
cabal install cabal-plan && cabal-plan --tree
```

## 2. Fallback: parse freeze files / package.yaml

- `cabal.project.freeze`: lines like `constraints: <name> == <version>`. No license data.
- `stack.yaml.lock`: `packages` with `version` and snapshot info.
- `package.yaml`: `dependencies:` list (direct only).

Resolve via Hackage:

```text
https://hackage.haskell.org/package/<name>-<version>/<name>-<version>.cabal
```

→ the `license:` field (SPDX id), `homepage`, `source-repository`, and `license-file:`.

## 3. License texts

1. The file named by the cabal `license-file:` field inside the package tarball.
2. From the tarball: `https://hackage.haskell.org/package/<name>-<version>/<name>-<version>.tar.gz`.
3. From vendored source if a `vendor/` directory is shipped.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- GHC boot packages (bytestring, containers, etc.) ship with GHC — exclude unless redistributed.
- `license: BSD-3-Clause` is the most common; preserve the actual copyright holders from the LICENSE file.
- `license: OtherLicense` / `license: NONE` → UNKNOWN; inspect the tarball.
