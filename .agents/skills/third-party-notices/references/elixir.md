# Elixir (Mix / Hex)

## Signal files

- `mix.exs`, `mix.lock`

## 1. Preferred tools

```bash
mix deps            # dependency tree; newer Mix shows license metadata when available
mix deps.tree       # tree with paths
```

Run `mix deps.get` first so sources exist under `deps/`.

## 2. Fallback: parse mix.lock

Entries look like:

```elixir
"<name>": {:hex, :<name>, "<version>", "<checksum>", [...], [...], "<build_tools>"}
```

No license data. Resolve via the Hex API (requires a User-Agent header):

```bash
curl -A "your-app (contact)" https://hex.pm/api/packages/<name>/releases/<version>
```

→ `meta.licenses` (SPDX ids). General metadata: `https://hex.pm/api/packages/<name>`.

## 3. License texts

1. From `deps/<name>/LICENSE*` after `mix deps.get` (Hex does not always include LICENSE — fall back below).
2. From the package tarball: `https://repo.hex.pm/tarballs/<name>-<version>.tar` — read the LICENSE inside `contents.tar.gz`.
3. From the package's `meta.links.github` repository at the pinned version.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- Git / path deps declared in `mix.exs`: read LICENSE from the repo / path.
- `only: :dev` / `only: :test` deps: exclude unless shipped.
- The OTP runtime itself ships with the release — note it separately as a runtime dependency.
