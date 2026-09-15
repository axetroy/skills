# 包管理器选择与配置

## 选择指南

### pnpm（推荐）

**优势：**

- 速度快，安装效率高
- 磁盘占用低（content-addressable store）
- 天然支持 workspace（monorepo）
- 严格的依赖提升策略，避免幽灵依赖
- 支持 `pnpm-workspace.yaml` 配置

**适用场景：**

- 新项目（默认推荐）
- Monorepo 项目
- 需要严格依赖隔离的项目

**配置：**

```yaml
# .npmrc
auto-install-peers=true
```

### npm

**优势：**

- Node.js 自带，无需额外安装
- 最大的社区兼容性

**适用场景：**

- 需要最大兼容性
- CI 环境中不允许安装额外工具

**配置：**

```json
// .npmrc
engine-strict=true
```

### yarn (v4+)

**优势：**

- Plug'n'Play（PnP）可选，零安装
- 支持 workspace
- 缓存机制优秀

**适用场景：**

- 团队已有 yarn 基础设施
- 需要 PnP 的项目

**配置：**

```yaml
# .yarnrc.yml
nodeLinker: node-modules # 推荐，兼容性更好
```

### bun

**优势：**

- 极致的安装和启动速度
- 内置 bundler 和 test runner

**适用场景：**

- 追求极致性能
- 不需要严格 workspace 支持

**注意事项：**

- workspace 支持相对有限
- 部分 npm 生态工具可能不兼容

---

## package.json 关键字段

```json
{
  "name": "@scope/package-name",
  "version": "0.1.0",
  "type": "module",
  "engines": {
    "node": ">=20"
  },
  "packageManager": "pnpm@9.0.0"
}
```

### 字段说明

- **name**：使用 scoped 格式 `@scope/name`，避免与已有包名冲突
- **type**：设为 `"module"` 启用 ESM
- **engines.node**：指定最低 Node.js 版本
- **packageManager**：指定包管理器及版本（Corepack 会使用此字段）

---

## 版本固定策略

推荐使用 Corepack 管理包管理器版本：

```bash
corepack enable
corepack prepare pnpm@9.0.0 --activate
```

在 CI 中激活 Corepack：

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 22
- run: corepack enable
```

---

## lockfile 管理

- **pnpm**：`pnpm-lock.yaml` — 必须提交到 Git
- **npm**：`package-lock.json` — 必须提交到 Git
- **yarn**：`yarn.lock` — 必须提交到 Git
- **bun**：`bun.lockb` — 必须提交到 Git

在 CI 中使用 `--frozen-lockfile` 确保一致性：

```bash
pnpm install --frozen-lockfile
npm ci
yarn install --immutable
bun install --frozen-lockfile
```
