# TypeScript 配置

## 基础配置

适用于大多数 Node.js 项目的 `tsconfig.json`：

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

---

## 按项目类型配置

### Node.js 应用

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

### Node.js 库

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

### 浏览器应用

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

### 同时支持 Node.js 和浏览器（同构库）

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./src"
  }
}
```

---

## 严格模式选项

`"strict": true` 等价于启用以下所有选项：

```json
{
  "strictNullChecks": true,
  "strictFunctionTypes": true,
  "strictBindCallApply": true,
  "strictPropertyInitialization": true,
  "noImplicitAny": true,
  "noImplicitThis": true,
  "alwaysStrict": true,
  "useUnknownInCatchVariables": true,
  "exactOptionalPropertyTypes": false,
  "noUncheckedIndexedAccess": false
}
```

推荐额外启用：

```json
{
  "noUncheckedIndexedAccess": true,
  "noFallthroughCasesInSwitch": true,
  "noImplicitOverride": true,
  "noPropertyAccessFromIndexSignature": true,
  "exactOptionalPropertyTypes": true
}
```

---

## module / moduleResolution 选择

| 场景            | module     | moduleResolution |
| --------------- | ---------- | ---------------- |
| Node.js ESM     | `NodeNext` | `NodeNext`       |
| Node.js CJS     | `CommonJS` | `Node10`         |
| 浏览器 + 打包器 | `ESNext`   | `bundler`        |
| 同构库          | `ESNext`   | `bundler`        |

> **重要**：如果 `package.json` 中 `"type": "module"`，则 `module` 和 `moduleResolution` 应使用 `NodeNext`。

---

## 路径别名

如果需要路径别名（如 `@/` 指向 `src/`）：

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  }
}
```

注意：TypeScript 本身不会解析路径别名，需要配合打包器或运行时工具（如 `tsx`、`tsconfig-paths`）使用。

---

## Monorepo 中的配置继承

使用 `extends` 继承根配置：

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

---

## 常用 TypeScript 脚本

```json
{
  "scripts": {
    "typecheck": "tsc --noEmit",
    "build": "tsc",
    "build:watch": "tsc --watch"
  }
}
```
