# Go

## Signal files

- `go.mod`, `go.sum`

## 1. Preferred tools

Requires the Go toolchain.

```bash
go install github.com/google/go-licenses@latest
go-licenses csv ./...
```

Columns: `module,version,license_type,license_file`. Add `-include_tests=false` to skip test deps.

Custom report template:

```bash
go-licenses report ./... --template '{{range .}}{{.Name}}\t{{.Version}}\t{{.LicenseName}}\n{{end}}'
```

## 2. Fallback: parse the module graph

- Direct deps: `require` blocks in `go.mod` (transitive ones carry a `// indirect` comment).
- Full resolved set:
  ```bash
  go list -m -json all
  ```
  `go mod graph` prints the edge list.

License metadata per module:

- Module cache: `$(go env GOMODCACHE)/<module>@<version>/` contains `LICENSE*`, `COPYING*`, and the `.mod` file.
- Or the Go module proxy: `https://proxy.golang.org/<module>/@v/<version>.mod` and `.zip` (the zip contains LICENSE files). Uppercase letters in module paths are escaped as `!<lowercase>` on the proxy (e.g. `github.com/!azure/...`).

## 3. License texts

1. From the module cache LICENSE files.
2. From `go-licenses` report output (it prints the license file path).
3. From the proxy zip.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- The Go standard library is not a third-party dependency — exclude it.
- `// indirect` modules are transitive deps; keep them when they are linked into the binary.
- `replace` directives: use the replacement module's license.
- Vendor mode (`vendor/`): read license files from the vendor tree.
- BSD licenses: preserve the copyright holder list from the LICENSE file.
