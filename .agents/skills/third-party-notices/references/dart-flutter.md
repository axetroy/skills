# Dart / Flutter

## Signal files

- `pubspec.yaml`, `pubspec.lock`

## 1. Preferred tools

```bash
dart pub deps          # tree of dependencies (direct + transitive)
flutter pub deps       # same, with a licenses hint; --style=compact for terser output
```

No built-in license report.

## 2. Fallback: parse pubspec.lock

Each `packages:<name>` entry has `version`, `source` (hosted / git / sdk), `description.url`, `description.name`. No license data.

Resolve via the pub.dev API:

```text
https://pub.dev/api/packages/<name>/versions/<version>
```

→ the package's `pubspec` (includes `homepage`, `repository`) and an `archive_url` to download the package.

## 3. License texts

1. Download the archive from `archive_url` (in the API response) and read LICENSE.
2. From the pub cache after `dart pub get`: `~/.pub-cache/hosted/pub.dev/<name>-<version>/LICENSE*`.
3. From the `repository` URL at the pinned version.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- `source: sdk` (`flutter`, `dart`): part of the SDK, not third-party — exclude.
- `source: git`: read the LICENSE from the git repo at the pinned commit.
- `dependency_overrides`: use the override's license.
