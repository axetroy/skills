---
name: js-ts-project-infrastructure
description: 指导 Agent 搭建和配置现代 TypeScript/JavaScript 项目的基础设施，包括包管理器、Monorepo workspace、TypeScript、ESLint、Prettier、Vitest 和 CI。当用户要求初始化项目、搭建脚手架、配置开发工具链、新建项目模板、或需要从零开始搭建一个规范的前端/Node.js 项目时使用。
---

# 项目基础设施搭建

指导 Agent 从零搭建一个规范的现代 TypeScript/JavaScript 项目基础设施。

---

## 适用场景

- 用户要求创建一个新的项目或初始化项目结构
- 用户要求搭建 monorepo 或 workspace
- 用户要求配置 TypeScript、ESLint、Prettier、Vitest 等工具
- 用户要求设置 CI/CD 流水线
- 用户要求规范化现有项目的开发环境

不适用于：

- 对已有完整基础设施的项目进行小幅修改
- 纯前端框架（如 Next.js、Vite）的脚手架搭建（应使用框架自带的 CLI）
- 非 TypeScript/JavaScript 项目

---

## 决策流程

在开始搭建之前，先确认以下信息：

### 1. 确认项目类型

向用户确认（或根据上下文推断）：

- **语言**：TypeScript 还是 JavaScript？（推荐 TypeScript）
- **运行时**：Node.js、浏览器、还是两者兼有？
- **框架**：是否有特定框架（React、Vue、Express 等）？
- **用途**：应用（application）、库（library）、还是工具（CLI）？

### 2. 选择包管理器

| 包管理器       | 推荐场景                                         |
| -------------- | ------------------------------------------------ |
| **pnpm**       | 默认推荐。速度快、磁盘占用低、天然支持 workspace |
| **npm**        | 需要最大兼容性时                                 |
| **yarn (v4+)** | 团队已有 yarn 基础设施时                         |
| **bun**        | 追求极致速度、不需要严格 workspace 支持时        |

详见 [包管理器参考](references/package-manager.md)。

### 3. 判断是否需要 Workspace（Monorepo）

满足以下任一条件时推荐使用 monorepo：

- 项目包含多个相关包（如应用 + 共享库）
- 同时开发多个 npm 包
- 有共享的配置包（如 eslint-config、tsconfig）

详见 [Workspace 配置参考](references/workspace.md)。

---

## 搭建步骤

按以下顺序搭建项目基础设施：

### 步骤 1：初始化项目

```bash
# 创建目录
mkdir my-project && cd my-project

# 初始化 package.json
pnpm init  # 或 npm init / yarn init / bun init
```

设置 `package.json` 中的关键字段：

- `name`：包名（使用 scoped 格式 `@scope/name`）
- `version`：初始版本 `0.1.0`
- `type`：设为 `"module"`（使用 ESM）
- `engines.node`：指定 Node.js 版本要求
- `scripts`：预留常用脚本

### 步骤 2：配置 TypeScript

```bash
pnpm add -D typescript
```

创建 `tsconfig.json`，推荐基础配置：

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

详见 [TypeScript 配置参考](references/typescript.md)。

### 步骤 3：配置 ESLint

```bash
pnpm add -D eslint @eslint/js typescript-eslint
```

使用 flat config 格式（`eslint.config.js`）：

```js
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    ignores: ["dist/", "node_modules/"],
  },
);
```

详见 [ESLint 配置参考](references/eslint.md)。

### 步骤 4：配置 Prettier

```bash
pnpm add -D prettier
```

创建 `.prettierrc`：

```json
{
  "semi": true,
  "singleQuote": false,
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2
}
```

创建 `.prettierignore`：

```
dist
node_modules
pnpm-lock.yaml
```

详见 [Prettier 配置参考](references/prettier.md)。

### 步骤 5：配置 Vitest

```bash
pnpm add -D vitest
```

在 `package.json` 中添加脚本：

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

如果需要覆盖率报告：

```bash
pnpm add -D @vitest/coverage-v8
```

详见 [Vitest 配置参考](references/vitest.md)。

### 步骤 6：配置 CI

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
      - run: pnpm run lint
      - run: pnpm run typecheck
      - run: pnpm run test
      - run: pnpm run build
```

详见 [CI 配置参考](references/ci.md)。

### 步骤 7：配置 Git 规范

创建 `.gitignore`：

```
node_modules
dist
coverage
*.tsbuildinfo
.env
.env.*
!.env.example
```

创建 `.editorconfig`：

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

---

## package.json 脚本模板

根据项目类型，在 `package.json` 中添加合适的脚本：

**库（Library）：**

```json
{
  "scripts": {
    "build": "tsc",
    "typecheck": "tsc --noEmit",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "prepublishOnly": "pnpm run build"
  }
}
```

**应用（Application）：**

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "typecheck": "tsc --noEmit",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## 验证清单

搭建完成后，逐一验证：

- [ ] `pnpm install` 成功，无报错
- [ ] `pnpm run typecheck` 通过
- [ ] `pnpm run lint` 通过
- [ ] `pnpm run format:check` 通过
- [ ] `pnpm run test` 通过
- [ ] `pnpm run build` 成功（如果适用）
- [ ] Git 仓库已初始化，`.gitignore` 生效
- [ ] CI 配置语法正确（可通过 `actionlint` 验证）

---

## 参考文档

各工具的详细配置说明：

- [包管理器](references/package-manager.md) — npm / pnpm / yarn / bun 选择与配置
- [Workspace（Monorepo）](references/workspace.md) — 多包项目结构与 workspace 配置
- [TypeScript](references/typescript.md) — tsconfig 详细配置与项目类型适配
- [ESLint](references/eslint.md) — flat config 格式、插件选型、自定义规则
- [Prettier](references/prettier.md) — 格式化规则、与 ESLint 集成
- [Vitest](references/vitest.md) — 测试配置、覆盖率、快照测试
- [CI](references/ci.md) — GitHub Actions 流水线、多版本测试、发布自动化
