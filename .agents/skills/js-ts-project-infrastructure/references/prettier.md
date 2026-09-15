# Prettier 配置

## 基础配置

创建 `.prettierrc`：

```json
{
  "semi": true,
  "singleQuote": false,
  "trailingComma": "all",
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

---

## 配置项说明

| 配置项           | 推荐值     | 说明                                  |
| ---------------- | ---------- | ------------------------------------- |
| `semi`           | `true`     | 语句末尾添加分号                      |
| `singleQuote`    | `false`    | 使用双引号（可按团队习惯改为 `true`） |
| `trailingComma`  | `"all"`    | 尽可能添加尾逗号                      |
| `printWidth`     | `80`       | 每行最大字符数                        |
| `tabWidth`       | `2`        | 缩进宽度                              |
| `useTabs`        | `false`    | 使用空格缩进                          |
| `bracketSpacing` | `true`     | 对象花括号内添加空格 `{ a }`          |
| `arrowParens`    | `"always"` | 箭头函数始终加括号 `(x) => x`         |
| `endOfLine`      | `"lf"`     | 统一换行符为 LF                       |

---

## .prettierignore

创建 `.prettierignore`：

```
# 构建产物
dist
build
out

# 依赖
node_modules

# 包管理器
pnpm-lock.yaml
package-lock.json
yarn.lock

# 覆盖率
coverage

# 其他
*.min.js
*.tsbuildinfo
```

---

## 与 ESLint 集成

Prettier 负责格式化，ESLint 负责代码质量。两者分工明确：

1. 安装 `eslint-config-prettier` 禁用 ESLint 中与 Prettier 冲突的格式化规则
2. 不要在 ESLint 中使用 `eslint-plugin-prettier`（性能差）

```bash
pnpm add -D eslint-config-prettier
```

```js
// eslint.config.js
import prettier from "eslint-config-prettier";

// 将 prettier 放在 tseslint.config 数组的最后
export default tseslint.config(
  // ...其他配置
  prettier,
);
```

---

## npm 脚本

```json
{
  "scripts": {
    "format": "prettier --write .",
    "format:check": "prettier --check ."
  }
}
```

- `format`：格式化所有文件
- `format:check`：CI 中检查是否已格式化（不修改文件）

---

## 编辑器集成

推荐安装 VS Code 扩展：

- **Prettier - Code formatter**（`esbenp.prettier-vscode`）

配置 VS Code 设置（`.vscode/settings.json`）：

```json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.formatOnSave": true
}
```
