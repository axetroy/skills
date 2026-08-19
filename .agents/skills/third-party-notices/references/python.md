# Python (pip, pip-tools, poetry, pipenv, uv)

## Signal files

- `pyproject.toml` (PEP 621 / poetry / uv)
- `requirements*.txt`, `requirements*.in`
- `Pipfile`, `Pipfile.lock`
- `poetry.lock`, `uv.lock`

## 1. Preferred tools

Requires the project environment to be installed.

```bash
pip install pip-licenses
pip-licenses --format=json --with-urls --with-license-file --output-file notices.json
```

Poetry:

```bash
poetry run pip-licenses --format=json --with-license-file
```

uv:

```bash
uv pip install pip-licenses
uv run pip-licenses --format=json --with-license-file
```

## 2. Fallback: parse lockfiles

- `poetry.lock`: each `[[package]]` has `name`, `version`, `category` (main/dev), `optional`; newer Poetry lockfiles also include a `license` field.
- `Pipfile.lock`: entries have `name`, `version`, `hashes` — no license.
- `uv.lock`: `[[package]]` with `name`, `version`, `source` — no license.
- `requirements*.txt`: pinned names + versions only.

Resolve each package via the PyPI JSON API:

```text
https://pypi.org/pypi/<name>/<version>/json
```

Use `info.license` (free-form), `info.license_expression` (SPDX when present), and `info.license_classifiers` (Trove classifiers such as `License :: OSI Approved :: MIT License`).

## 3. License texts

1. From `pip-licenses --with-license-file` output.
2. From installed dist-info: `site-packages/<dist>-<version>.dist-info/` (licenses folder or `LICENSE*`).
3. From the PyPI wheel/sdist: the `urls[].url` fields of the JSON API — download and read the LICENSE.
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- Normalize package names (case, `_` vs `-`) when querying PyPI.
- dev / test / optional deps: filter via `pip-licenses --ignore-packages` or by `category` from poetry.lock.
- Classifier-based licenses: prefer the actual LICENSE file in the source.
- `UNKNOWN` from PyPI: fall back to the sdist LICENSE or mark UNKNOWN.
