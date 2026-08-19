# C / C++ (vcpkg, Conan, CMake FetchContent)

## Signal files

- `vcpkg.json`, `vcpkg-configuration.json` (manifest mode)
- `conanfile.txt`, `conanfile.py`, `conan.lock`
- `CMakeLists.txt` with `FetchContent_*`, `ExternalProject_*`, or vendored `add_subdirectory`
- `xmake.lua` (xmake), `premake5.lua` (premake)

C/C++ dependencies are often prebuilt or vendored source, so the most reliable license source is the checked-out dependency tree itself.

## 1. Preferred tools

vcpkg (after `vcpkg install`):

```bash
vcpkg list          # installed ports + versions
# each port installs metadata under the installed tree:
#   <vcpkg>/installed/<triplet>/share/<port>/copyright
#   <vcpkg>/installed/<triplet>/share/<port>/vcpkg.spdx.json   (SPDX manifest)
```

Conan 2:

```bash
conan install .     # creates conan.lock in the project
conan list "*"      # packages in the local cache
```

Read `<cache>/p/<ref>/<pkgid>/licenses/` and metadata when available.

CMake `FetchContent` / `ExternalProject`: parse the `URL` / `GIT_REPOSITORY` + `GIT_TAG` declared in `CMakeLists.txt`, fetch that tag, and read its LICENSE.

## 2. Fallback

- `conan.lock`: `requires` entries with `ref` and revision — resolve each against the ConanCenter recipe metadata (`license` field).
- `vcpkg.json`: `dependencies` list only (versions live in the vcpkg-configuration / baseline); per-port `copyright` appears after install.
- Vendored code under `third_party/`, `extern/`, `deps/`: scan each for `LICENSE*`, `COPYING*`, `NOTICE*`, `license.h`.

## 3. License texts

1. The `copyright` file vcpkg installs per port (full license + attribution).
2. The `vcpkg.spdx.json` per port.
3. The LICENSE / COPYING file inside vendored or fetched source.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- Transitive deps are hard to enumerate — only package-manager deps and `FetchContent`/`ExternalProject` can be listed; binary blobs and system-installed libraries must be documented manually.
- Headers-only libraries still carry license obligations.
- `find_package` pulls system packages (zlib, openssl, etc.) — note their license from the system or mark them "system-provided".
