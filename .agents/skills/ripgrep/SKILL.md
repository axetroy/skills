---
name: ripgrep
description: 使用 ripgrep(rg) 在代码仓库中进行高速搜索、定位文件、查找代码引用和分析项目结构。
---

# ripgrep 搜索技能

## 用途

使用 `rg` 作为代码仓库默认搜索工具。

适用于：

- 查找函数、类、变量定义
- 查找代码引用
- 搜索配置项
- 搜索 API、环境变量
- 分析项目结构
- 辅助代码重构

## 基本规则

优先使用：

```bash
rg "关键词"
```

不要使用：

```bash
grep -r
find | grep
```

除非 rg 不适用。

## 搜索原则

### 1. 优先精确搜索

推荐：

```bash
rg "UserService"
```

不要：

```bash
rg ".*UserService.*"
```

### 2. 限制目录

已知目录时：

```bash
rg "关键词" src/
```

### 3. 限制文件类型

根据项目类型过滤：

```bash
rg "关键词" -t js
rg "关键词" -t ts
rg "关键词" -t py
```

避免扫描无关文件。

### 4. 保留忽略规则

默认遵守：

- .gitignore
- .ignore
- .rgignore

不要默认使用：

```bash
rg -uuu
```

只有明确需要搜索隐藏文件、生成文件时使用。

## 常用操作

### 查找文件

```bash
rg --files
```

### 查找定义

```bash
rg -n "class User"
rg -n "function xxx"
```

### 查找引用

```bash
rg -n "函数名"
```

### 搜索配置

```bash
rg -n "API_URL"
rg -n "TOKEN"
```

### 搜索 TODO

```bash
rg -n "TODO|FIXME"
```

## 正则规则

默认使用普通正则。

只有需要以下能力时使用：

```bash
rg -P
```

例如：

- 后向引用
- lookahead
- lookbehind

## 多行搜索

只有跨行匹配时使用：

```bash
rg -U
```

不要默认开启。

## 代码分析流程

查找功能实现时：

1. 搜索关键词
2. 找定义位置
3. 找调用位置
4. 找测试代码
5. 分析影响范围

示例：

```bash
rg -n "UserService"
```

然后检查：

- 定义文件
- 调用方
- 测试

## 大项目规则

大型仓库：

1. 先缩小目录
2. 再缩小文件类型
3. 最后搜索内容

推荐：

```bash
rg "keyword" src/ -t ts
```

避免：

```bash
rg "keyword" .
```

## 搜索不到结果

按顺序检查：

1. 关键词是否正确
2. 目录是否正确
3. 文件类型是否过滤过严
4. 是否被 ignore

最后才使用：

```bash
rg -uuu "keyword"
```

## 输出要求

结果必须包含：

- 文件路径
- 行号

默认使用：

```bash
rg -n
```

## 禁止行为

不要：

- 扫描整个系统目录
- 无限制执行超大范围搜索
- 使用复杂正则替代简单关键词搜索
- 删除 ignore 限制后直接修改文件

## 目标

使用最少扫描范围，快速定位准确代码位置。
