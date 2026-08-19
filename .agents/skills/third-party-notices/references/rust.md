# Rust (Cargo)

## Signal files

- `Cargo.toml`, `Cargo.lock` (always present for binaries and workspaces)

## 1. Preferred tools

```bash
cargo install cargo-license
cargo license --json > notices.json
```

- Reads `Cargo.lock`; `--avoid-dev-deps` skips dev dependencies.
- `--direct` limits to direct dependencies if transitive are not shipped.

```bash
cargo install cargo-deny
cargo deny list
```

`cargo-deny` also checks license compatibility, sources, and bans (`cargo deny init` generates a config).

## 2. Fallback: parse Cargo.lock

Each `[[package]]` has `name`, `version`, `source`, `checksum`. No license field. `source` values look like `registry+https://github.com/rust-lang/crates.io-index` for registry deps.

Resolve via the crates.io API (requires a User-Agent header):

```bash
curl -A "license-notices" https://crates.io/api/v1/crates/<name>/<version>
```

→ `crate.license` (SPDX string).

Download the crate source for license files:

```text
https://static.crates.io/crates/<name>/<name>-<version>.crate
```

(a tar.gz containing `Cargo.toml` with the `license` field plus any `LICENSE*` files).

## 3. License texts

1. From `cargo vendor` output (creates `vendor/` with sources and licenses).
2. From the `.crate` archive.
3. From `~/.cargo/registry/src/.../<name>-<version>/` when sources are already fetched.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- `source` may be `git+...` or `path+...` — read the LICENSE from that repo/path.
- Dual license expressions like `MIT OR Apache-2.0` (the crates.io default): include both texts.
- Dev-dependencies: `cargo license --avoid-dev-deps`.
- Workspaces: union the members' dependencies; keep `cargo.lock` as the source of truth.
