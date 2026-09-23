---
name: hacker-news-top-stories
description: 获取 Hacker News 当前热门 Top 20 并返回。当用户询问 Hacker News 热点、热门新闻、首页热门、Top 20 HN stories、Hacker News top stories 或最新排名时使用此技能。
compatibility: 需要访问 Hacker News 公开 Firebase API 的网络权限。
---

# Hacker News 热门 Top 20

获取当前 Hacker News 首页排名靠前的 20 条热门 Story，并以清晰的列表形式返回。

## 数据来源

使用 Hacker News 官方公开 API：

| 用途               | URL                                                     |
| ------------------ | ------------------------------------------------------- |
| 热门 Story ID 列表 | `https://hacker-news.firebaseio.com/v0/topstories.json` |
| 单条 Story 详情    | `https://hacker-news.firebaseio.com/v0/item/<id>.json`  |

`topstories` API 返回按 Hacker News 当前排名排列的 Story ID 列表，最多包含 500 个 ID。取前 20 个 ID 即可得到当前 Top 20。每个 Story 的详细信息通过对应的 `item/<id>.json` 接口获取。

## 执行步骤

### 步骤 1：获取 Top Stories ID

请求以下接口获取热门 Story ID 列表：

```text
https://hacker-news.firebaseio.com/v0/topstories.json
```

从返回的 JSON 数组中，**按照原始顺序**取前 20 个 ID。

> ⚠️ 不得根据 score、time、comments 或其他字段重新排序。

### 步骤 2：获取 Story 详情

对这 20 个 ID 分别请求：

```text
https://hacker-news.firebaseio.com/v0/item/<id>.json
```

- 仅将 `type` 为 `story` 且未被标记为 `deleted` 或 `dead` 的项目视为有效 Story。
- 若某个 ID 请求失败、返回空值或非有效 Story，**跳过该项目**，继续处理其余 ID。
- 若因异常导致最终不足 20 条，**不得用其他来源补齐**；返回实际成功获取的数量，并在结果中说明数据不完整。

### 步骤 3：提取字段

每条有效 Story 提取以下字段：

| 字段          | 说明                 | 是否必需               |
| ------------- | -------------------- | ---------------------- |
| `title`       | 标题                 | 必需（缺失则跳过该条） |
| `url`         | 原文链接             | 可选（缺失时降级处理） |
| `by`          | Hacker News 用户名   | 可选                   |
| `score`       | 当前得分             | 可选                   |
| `descendants` | 评论总数             | 可选                   |
| `id`          | Hacker News Story ID | 必需                   |
| `time`        | Unix 时间戳          | 可选                   |

**`url` 缺失时的降级处理：**
对于没有 `url` 的 Story（例如 Ask HN），使用以下链接作为 Story 页面地址：

```text
https://news.ycombinator.com/item?id=<id>
```

### 步骤 4：输出结果

严格按照 Hacker News API 返回的排名顺序输出，**不得自行排序**。

#### 英文格式示例

```markdown
## Hacker News Top 20

1. **[Story title](story-url)**
   - Score: 123
   - Comments: 45
   - Author: username
   - HN: https://news.ycombinator.com/item?id=123456

2. **[Story title](story-url)**
   - Score: 98
   - Comments: 32
   - Author: username
   - HN: https://news.ycombinator.com/item?id=123457

...
```

#### 中文格式示例

若用户使用中文提问，使用以下中文字段格式：

```markdown
## Hacker News 热门 Top 20

1. **标题**
   - 🔥 得分：123
   - 💬 评论：45
   - 👤 作者：username
   - 🔗 原文：https://example.com/article
   - 📎 HN：https://news.ycombinator.com/item?id=123456

2. **标题**
   - 🔥 得分：98
   - 💬 评论：32
   - 👤 作者：username
   - 🔗 原文：https://example.com/another
   - 📎 HN：https://news.ycombinator.com/item?id=123457

...
```

### 步骤 5：标注数据时效

每次执行技能时都必须**实时重新请求** Hacker News API。

- 不得缓存或复用之前获取的 Top 20 结果。
- 不得声称这些结果代表某个固定时间点之后的排名。
- 应在结果开头注明：

```text
以下为刚刚从 Hacker News API 实时获取的当前 Top 20 热门。
```

- 若可可靠获取当前时间，可同时注明数据获取的具体时间。

## 错误处理

### Top Stories API 请求失败

若以下请求失败：

```text
https://hacker-news.firebaseio.com/v0/topstories.json
```

- 应直接告知用户无法获取 Hacker News 当前热门列表。
- 提供可获得的失败原因（如网络超时、HTTP 状态码等）。
- **不得使用**搜索引擎结果或第三方 Hacker News 排行榜替代官方 API 数据。

### 单个 Story 请求失败

单条 Story 获取失败时的处理流程：

1. 跳过该 Story；
2. 继续获取其余 Story；
3. 最终返回成功获取的结果列表；
4. 若条数少于 20，在结果末尾注明「实际获取 X 条」（X 为实际数量）。

### 字段缺失处理

| 字段               | 处理方式                                                  |
| ------------------ | --------------------------------------------------------- |
| `url` 缺失         | 使用 `https://news.ycombinator.com/item?id=<id>` 作为链接 |
| `by` 缺失          | 显示 `unknown`                                            |
| `score` 缺失       | 显示 `N/A`                                                |
| `descendants` 缺失 | 显示 `N/A`                                                |
| `title` 缺失       | **跳过该条 Story**，不展示                                |

## 重要规则

1. **数据来源**：必须是 Hacker News 官方 Firebase API（`hacker-news.firebaseio.com`）。
2. **排名依据**：Top 20 排名以 `/v0/topstories.json` 返回的顺序为准，不得自行排序。
3. **禁止重新排序**：不得按 score、发布时间、评论数等任何维度重新排列。
4. **禁止混入其他数据**：不得混入 `/newstories`、`/beststories`、`/askstories`、`/showstories` 或 `jobstories` 的结果。
5. **禁止第三方替代**：不得使用第三方网站（如 HackerNews.cn 等）的数据替代官方 API。
6. **实时请求**：每次执行都必须实时请求 API，禁止缓存或复用历史结果。
7. **无需获取评论树**：`descendants` 字段已提供 Story 的评论总数，无需进一步获取评论详情。
8. **无需获取用户详情**：`by` 字段已提供作者用户名，无需额外请求用户接口。
9. **HTML 安全处理**：Hacker News API 的 Story 标题可能包含 HTML 内容；展示时应进行适当的 HTML 解码，并将特殊字符转义以防止 XSS。

## 示例交互

**用户提问：**

```text
给我看看现在 Hacker News 前 20 的热点
```

**执行流程：**

1. 请求 `https://hacker-news.firebaseio.com/v0/topstories.json`，获取前 20 个 Story ID。
2. 并发或依次请求 20 个 `https://hacker-news.firebaseio.com/v0/item/<id>.json`，获取每条 Story 详情。
3. 过滤无效条目，提取所需字段。
4. 按 API 返回的原始排名顺序整理，输出中文格式的 Top 20 列表。
5. 在结果开头附上时效说明。

> ⚠️ 不要将 API 的原始 JSON 数据直接输出给用户，除非用户明确要求查看原始接口数据。

## 附录：API 响应字段说明

### topstories.json 响应格式

```json
[1, 2, 3, 4, 5, ...]
```

返回一个整数数组，每个整数代表一条 Story 的 ID，数组顺序即为当前排名顺序。

### item/<id>.json 响应格式（常用字段）

```json
{
  "id": 123456,
  "type": "story",
  "by": "username",
  "title": "Story Title",
  "url": "https://example.com/article",
  "score": 150,
  "descendants": 42,
  "time": 1690000000,
  "deleted": false
}
```

| 字段          | 类型        | 说明                                      |
| ------------- | ----------- | ----------------------------------------- |
| `id`          | integer     | Story 唯一 ID                             |
| `type`        | string      | 内容类型，`story` 为文章                  |
| `by`          | string      | 发布者用户名                              |
| `title`       | string      | 文章标题                                  |
| `url`         | string/null | 原文链接，部分 Story（如 Ask HN）无此字段 |
| `score`       | integer     | 当前得分数                                |
| `descendants` | integer     | 评论总数                                  |
| `time`        | integer     | 发布时间（Unix 时间戳，秒）               |
| `deleted`     | boolean     | 是否已被删除                              |
