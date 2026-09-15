# Vitest 配置

## 基础配置

Vitest 开箱即用，通常不需要额外配置文件。

### npm 脚本

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## 配置文件

如果需要自定义配置，创建 `vitest.config.ts`：

```ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // 测试文件匹配模式
    include: ["src/**/*.test.ts", "src/**/*.spec.ts"],

    // 排除文件
    exclude: ["node_modules", "dist"],

    // 覆盖率配置
    coverage: {
      provider: "v8",
      reporter: ["text", "html", "lcov"],
      include: ["src/**/*.ts"],
      exclude: ["src/**/*.test.ts", "src/**/*.spec.ts"],
    },

    // 超时时间（毫秒）
    testTimeout: 10_000,

    // �报告器
    reporter: ["verbose"],
  },
});
```

---

## 覆盖率

```bash
pnpm add -D @vitest/coverage-v8
```

配置覆盖率报告：

```json
{
  "scripts": {
    "test:coverage": "vitest run --coverage"
  }
}
```

覆盖率阈值（可选）：

```ts
// vitest.config.ts
import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    coverage: {
      provider: "v8",
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 80,
        statements: 80,
      },
    },
  },
});
```

---

## 测试文件约定

Vitest 默认查找以下文件：

- `**/*.test.ts`
- `**/*.spec.ts`
- `**/__tests__/**/*.ts`

推荐将测试文件放在源码旁边：

```
src/
├── utils.ts
├── utils.test.ts    # 与源码同级
├── models/
│   ├── user.ts
│   └── user.test.ts
```

---

## 常用测试模式

### 基础测试

```ts
import { describe, it, expect } from "vitest";
import { add } from "./math";

describe("add", () => {
  it("should add two numbers", () => {
    expect(add(1, 2)).toBe(3);
  });
});
```

### 异步测试

```ts
import { describe, it, expect } from "vitest";
import { fetchData } from "./api";

describe("fetchData", () => {
  it("should return data", async () => {
    const data = await fetchData();
    expect(data).toBeDefined();
  });
});
```

### Mock

```ts
import { describe, it, expect, vi } from "vitest";
import { processData } from "./processor";

// Mock 模块
vi.mock("./database", () => ({
  query: vi.fn().mockResolvedValue([{ id: 1 }]),
}));

// Mock 函数
const mockLogger = vi.fn();

describe("processData", () => {
  it("should process and log", async () => {
    await processData();
    expect(mockLogger).toHaveBeenCalledWith("done");
  });
});
```

### 快照测试

```ts
import { describe, it, expect } from "vitest";
import { formatUser } from "./formatter";

describe("formatUser", () => {
  it("should format user correctly", () => {
    const user = { name: "Alice", age: 30 };
    expect(formatUser(user)).toMatchSnapshot();
  });
});
```

---

## npm 脚本汇总

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage",
    "test:ui": "vitest --ui"
  }
}
```

如果需要 UI 界面：

```bash
pnpm add -D @vitest/ui
```
