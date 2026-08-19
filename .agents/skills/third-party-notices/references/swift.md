# Swift / Apple (Swift Package Manager, CocoaPods, Carthage)

## Signal files

- `Package.swift`, `Package.resolved`
- CocoaPods: `Podfile`, `Podfile.lock`, `Pods/`
- Carthage: `Cartfile`, `Cartfile.resolved`, `Carthage/Checkouts/`

## 1. Preferred tools

```bash
swift package show-dependencies            # tree of direct + transitive deps
swift package show-dependencies --format json
swift package dump-package                 # resolved manifest
```

SPM has no built-in license reporter.

## 2. Fallback: parse lockfiles

- `Package.resolved`: each `pins` entry has `identity`, `location` (git URL), `state.version` (tag), `state.revision` (commit). No license metadata.
- `Podfile.lock`: `PODS:` sections list pod names and versions.
- `Cartfile.resolved`: `github "owner/repo" "version"` lines.

For each pin, read the license from the repository at the pinned tag:

- If checked out: `.build/checkouts/<identity>/LICENSE*`.
- Else fetch the LICENSE from the repo's default branch at the tag (try `LICENSE`, `LICENSE.md`, `COPYING`, `NOTICE`), or clone and `git checkout <tag>`.

## 3. License texts

1. From `.build/checkouts/<identity>/` after `swift package resolve`.
2. From the repo's LICENSE at the pinned tag.
3. CocoaPods: `Pods/<name>/LICENSE`; Carthage: `Carthage/Checkouts/<name>/LICENSE`.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- `identity` differs from the repo name — use `location` for fetching.
- Tags may be a version like `1.2.3` or a commit SHA.
- Pods without `source_files` metadata may still carry license files — check `Pods/<name>/`.
