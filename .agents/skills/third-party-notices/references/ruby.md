# Ruby (Bundler)

## Signal files

- `Gemfile`, `Gemfile.lock`

## 1. Preferred tools

```bash
gem install license_finder
license_finder --format=json --output-file=notices.json
# scoped to the current bundle:
bundle exec license_finder
```

`license_finder` inspects the installed bundle (it also supports npm, pip, etc.).

## 2. Fallback: parse Gemfile.lock

Entries look like `    <name> (<version>)`, grouped under `DEPENDENCIES`, `GIT`, `PATH`, `PLATFORMS`. No license data.

Resolve via the RubyGems API:

```text
https://rubygems.org/api/v2/rubygems/<name>/versions/<version>.json
```

→ `licenses` (array of SPDX ids).

## 3. License texts

1. From the unpacked gem: `gem unpack <name> -v <version> --target /tmp/gems` then read the LICENSE file; or read from `~/.gem/` cache.
2. From the gem file: `https://rubygems.org/downloads/<name>-<version>.gem` (a tar containing `data.tar.gz`).
3. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- Gems with `license` nil or non-SPDX strings — normalize to SPDX ids.
- Path / git gems: read the LICENSE from the local path / repo.
- `bundler` itself is a dev dependency of your Gemfile — exclude unless shipped.
