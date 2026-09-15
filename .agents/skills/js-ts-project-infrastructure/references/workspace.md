# Workspace（Monorepo）配置

## 何时使用 Monorepo

满足以下条件时推荐使用 monorepo：

- 同时开发多个相关包（如应用 + 共享库）
- 需要在多个包之间共享配置（eslint-config、tsconfig 等）
- 希望统一管理依赖版本和构建流程

不推荐 monorepo 的情况：

- 只有一个独立的包
- 包之间没有共享代码
- 团队规模小且包之间无关联

---

## 目录结构

```
my-monorepo/
├── package.json
├── pnpm-workspace.yaml
├── tsconfig.json          # 基础 tsconfig
├── packages/
│   ├── app/               # 应用
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   ├── shared/            # 共享库
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── src/
│   └── eslint-config/     # 共享配置
│       ├── package.json
│       └── index.js
└── README.md
```

---

## pnpm workspace

创建 `pnpm-workspace.yaml`：

```yaml
packages:
  - "packages/*"
```

### 根 package.json

```json
{
  "name": "my-monorepo",
  "private": true,
  "scripts": {
    "build": "pnpm -r run build",
    "typecheck": "pnpm -r run typecheck",
    "lint": "pnpm -r run lint",
    "test": "pnpm -r run test",
    "clean": "pnpm -r run clean"
  }
}
```

### 子包引用

子包之间通过 `workspace:*` 协议引用：

```json
{
  "dependencies": {
    "@my-monorepo/shared": "workspace:*"
  }
}
```

---

## npm workspace

```json
// 根 package.json
{
  "workspaces": ["packages/*"]
}
```

---

## yarn workspace

```yaml
# .yarnrc.yml
nodeLinker: node-modules
```

```json
// 根 package.json
{
  "workspaces": ["packages/*"]
}
```

---

## TypeScript 项目引用

在 monorepo 中使用 TypeScript 的项目引用（Project References）功能：

### 根 tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "declaration": true,
    "declarationMap": true,
    "composite": true
  },
  "references": [
    { "path": "packages/shared" },
    { "path": "packages/app" }
  ],
  "files": []
}
```

### 子包 tsconfig.json（如 packages/shared）

```json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src"]
}
```

### 子包 package.json

```json
{
  "name": "@my-monorepo/shared",
  "version": "0.1.0",
  "type": "module",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "import": "./dist/index.js"
    }
  },
  "scripts": {
    "build": "tsc",
    "typecheck": "tsc --noEmit"
  }
}
```

---

## Turborepo（可选）

如果需要更强大的构建编排，可以使用 Turborepo：

```bash
pnpm add -D turbo
```

```json
// 根 package.json
{
  "scripts": {
    "build": "turbo run build",
    "test": "turbo run test",
    "lint": "turbo run lint"
  }
}
```

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"]
    },
    "lint": {},
    "typecheck": {
      "dependsOn": ["^build"]
    }
  }
}
```

---

## 常用 pnpm workspace 命令

```bash
# 在所有包中运行命令
pnpm -r run build

# 在指定包中运行命令
pnpm --filter @my-monorepo/shared run build

# 添加共享依赖到根
pnpm add -D -w typescript

# 添加依赖到指定包
pnpm --filter @my-monorepo/app add lodash

# 列出所有包
pnpm ls -r --depth 0
```
