# PHP (Composer)

## Signal files

- `composer.json`, `composer.lock`

## 1. Preferred tools

Built into Composer:

```bash
composer licenses          # human-readable table
composer licenses --format=json
```

## 2. Fallback: parse composer.lock

Each entry in `packages` / `packages-dev` has `name`, `version`, `license` (array of SPDX ids), and `source` / `dist` URLs.

For packages missing license metadata, query Packagist:

```text
https://repo.packagist.org/p2/<vendor>/<name>.json
```

→ `packages[<name>][<version>].license`.

## 3. License texts

1. From `vendor/<vendor>/<name>/LICENSE*` (or `COPYING*`).
2. From the `dist` tarball or the `source` repo recorded in composer.lock.
3. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- `packages-dev`: dev dependencies — exclude unless shipped.
- `"license": ["proprietary"]` → mark UNKNOWN / proprietary for review.
- Multiple entries in the license array: usually OR / AND semantics — include all listed texts.
