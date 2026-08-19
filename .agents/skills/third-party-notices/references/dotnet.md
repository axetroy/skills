# .NET / C# (NuGet)

## Signal files

- `*.csproj`, `*.fsproj`, `*.vbproj`
- `packages.lock.json` (restore lock), `project.assets.json`, `paket.lock`

## 1. Preferred tools

```bash
dotnet restore --use-lock-file          # generates packages.lock.json
dotnet list <project>.csproj package    # direct dependencies
dotnet list <project>.csproj package --include-transitive
```

License-specific tool:

```bash
dotnet tool install --global dotnet-project-licenses
dotnet-project-licenses -i . -o licenses.txt -j   # -j = json, -u = include urls
```

## 2. Fallback: parse lockfiles

- `packages.lock.json`: `dependencies` → `runtime.<rid>/<project>` → `{ Package, version, resolved, contentHash }`. No licenses.
- `project.assets.json`: `libraries` → `{ type, resolved, sha512 }`. No licenses.

Resolve via the NuGet API (lowercase package id):

```text
https://api.nuget.org/v3-flatcontainer/<id>/<version>/<id>.<version>.nuspec
```

The nuspec carries `<license type="expression">MIT</license>` (SPDX), or `<licenseUrl>`, or `<license type="file">` with an embedded file.

## 3. License texts

1. `dotnet-project-licenses` output.
2. From the nupkg: `https://api.nuget.org/v3-flatcontainer/<id>/<version>/<id>.<version>.nupkg` (a zip; read the embedded license when `type="file"`).
3. From the restore cache: `~/.nuget/packages/<id>/<version>/`.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- Older packages use `licenseUrl` pointing to a generic page — treat as best-effort and cross-check the SPDX id.
- Multi-targeting / multiple csproj: aggregate all project lock files.
- Framework refs (e.g. `Microsoft.NETCore.App`) are part of the runtime, not third-party — exclude.
