# CI 配置

## GitHub Actions

### 基础 CI 流水线

创建 `.github/workflows/ci.yml`：

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [20, 22]
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: Lint
        run: pnpm run lint

      - name: Type Check
        run: pnpm run typecheck

      - name: Test
        run: pnpm run test

      - name: Build
        run: pnpm run build
```

### 使用 npm 的版本

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [20, 22]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm

      - run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type Check
        run: npm run typecheck

      - name: Test
        run: npm run test

      - name: Build
        run: npm run build
```

### 带覆盖率的 CI

```yaml
- name: Test with Coverage
  run: pnpm run test:coverage

- name: Upload Coverage
  uses: codecov/codecov-action@v4
  with:
    files: ./coverage/lcov.info
    fail_ci_if_error: false
```

### Monorepo CI

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm

      - run: pnpm install --frozen-lockfile

      - name: Build (topological order)
        run: pnpm -r run build

      - name: Lint (all packages)
        run: pnpm -r run lint

      - name: Test (all packages)
        run: pnpm -r run test
```

---

## 自动发布（可选）

### 使用 Changesets

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
          registry-url: https://registry.npmjs.org

      - run: pnpm install --frozen-lockfile

      - uses: changesets/action@v1
        with:
          publish: pnpm -r publish
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### 使用 release-please

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: googleapis/release-please-action@v4
        with:
          release-type: node
```

---

## CI 最佳实践

1. **锁定依赖**：始终使用 `--frozen-lockfile`（pnpm）或 `npm ci`
2. **缓存**：利用 `actions/setup-node` 的 `cache` 选项缓存依赖
3. **矩阵测试**：测试多个 Node.js 版本（如 20、22）
4. **并行执行**：将 lint、typecheck、test、build 作为独立步骤（CI 会自动并行执行不相关的步骤）
5. **失败快速**：如果某一步失败，后续步骤不会执行
6. **权限最小化**：只授予必要的 `permissions`
