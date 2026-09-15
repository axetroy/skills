# ESLint 配置

## Flat Config 格式（ESLint v9+）

从 ESLint v9 开始，使用 `eslint.config.js`（Flat Config）替代 `.eslintrc`。

### 基础配置

```js
// eslint.config.js
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  {
    ignores: ["dist/", "node_modules/", "coverage/"],
  },
);
```

### 推荐完整配置

```js
// eslint.config.js
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";

export default tseslint.config(
  // 基础规则
  eslint.configs.recommended,

  // TypeScript 规则
  ...tseslint.configs.recommended,

  // 自定义规则
  {
    rules: {
      // 优先使用 const
      "prefer-const": "error",

      // 禁止未使用的变量（允许 _ 前缀）
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
        },
      ],

      // 禁止 console.log（允许 warn/error）
      "no-console": [
        "warn",
        {
          allow: ["warn", "error"],
        },
      ],
    },
  },

  // 忽略目录
  {
    ignores: ["dist/", "node_modules/", "coverage/"],
  },
);
```

---

## 插件推荐

### 必装

| 包                  | 用途                 |
| ------------------- | -------------------- |
| `eslint`            | 核心                 |
| `@eslint/js`        | 基础 JavaScript 规则 |
| `typescript-eslint` | TypeScript 支持      |

### 按需安装

| 包                          | 用途                       |
| --------------------------- | -------------------------- |
| `eslint-config-prettier`    | 禁用与 Prettier 冲突的规则 |
| `eslint-plugin-import`      | 导入排序和规范             |
| `eslint-plugin-react`       | React 规则                 |
| `eslint-plugin-react-hooks` | React Hooks 规则           |
| `eslint-plugin-vue`         | Vue 规则                   |

---

## 与 Prettier 集成

```bash
pnpm add -D eslint-config-prettier
```

```js
// eslint.config.js
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";
import prettier from "eslint-config-prettier";

export default tseslint.config(
  eslint.configs.recommended,
  ...tseslint.configs.recommended,
  prettier, // 放在最后，禁用冲突规则
  {
    ignores: ["dist/", "node_modules/"],
  },
);
```

---

## npm 脚本

```json
{
  "scripts": {
    "lint": "eslint .",
    "lint:fix": "eslint . --fix"
  }
}
```

---

## 常用规则说明

| 规则                                         | 说明              | 推荐值                      |
| -------------------------------------------- | ----------------- | --------------------------- |
| `no-console`                                 | 限制 console 使用 | `warn`，允许 `warn`/`error` |
| `prefer-const`                               | 优先使用 const    | `error`                     |
| `no-var`                                     | 禁止 var          | `error`                     |
| `eqeqeq`                                     | 要求 ===          | `error`                     |
| `@typescript-eslint/no-unused-vars`          | 禁止未使用变量    | `error`，忽略 `_` 前缀      |
| `@typescript-eslint/no-explicit-any`         | 禁止 any          | `warn`                      |
| `@typescript-eslint/consistent-type-imports` | 统一类型导入      | `error`，使用 `type` 导入   |
