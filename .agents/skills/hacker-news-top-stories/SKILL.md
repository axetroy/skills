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
| `title`       | 标题（原文）         | 必需（缺失则跳过该条） |
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

### 步骤 4：抓取文章并生成摘要

对于每条有 `url` 的有效 Story：

1. **抓取文章内容**：请求 `url` 对应的网页，提取正文内容。
   - 优先抓取文章的主体内容区域（排除导航、广告、侧边栏等噪音）。
   - 若无法确定正文区域，抓取页面全部文本并过滤短片段，保留有意义的内容段落。
   - 请求时应设置合理的超时（建议 5 秒）和 User-Agent。
2. **生成摘要**：基于抓取到的正文内容，生成一段简洁的中文摘要。
   - 摘要长度控制在 3～5 句话以内。
   - 摘要应概括文章的核心观点、主要结论或关键信息。
   - 若抓取失败、内容为空或无法生成有意义摘要，**不展示摘要字段**，继续输出其余信息。
3. **原文标题保留**：将原始英文标题完整保留，并额外提供中文翻译后的标题用于展示。若原文已是中文标题，直接使用该标题。

### 步骤 5：始终使用中文输出

无论用户使用何种语言提问，**所有输出内容必须使用中文**。

- 标题需同时展示**原文**和**中文翻译**（若原文为中文则直接使用）。
- 摘要必须为中文。
- 所有说明文字、字段标签均使用中文。
- 原文链接、作者名、HN 链接等不可翻译的字段保持原样。

### 步骤 6：标注数据时效

每次执行技能时都必须**实时重新请求** Hacker News API。

- 不得缓存或复用之前获取的 Top 20 结果。
- 不得声称这些结果代表某个固定时间点之后的排名。
- 应在结果开头注明：

```text
以下为刚刚从 Hacker News API 实时获取的当前 Top 20 热门。
```

- 若可可靠获取当前时间，可同时注明数据获取的具体时间。

### 步骤 7：输出结果

严格按照 Hacker News API 返回的排名顺序输出，**不得自行排序**。

所有输出内容必须使用中文。标题需同时展示原文与中文翻译，并附上文章摘要。格式如下：

```markdown
## Hacker News 热门 Top 20

1. **【原文】Story Title — 中文翻译标题** [原文链接](url)
   - 🔥 得分：123
   - 💬 评论：45
   - 👤 作者：username
   - 📝 摘要：这是一段对文章核心内容的中文摘要，概括主要观点或关键信息。
   - 📎 HN：https://news.ycombinator.com/item?id=123456

2. **【原文】Another Headline — 另一个标题翻译** [原文链接](url)
   - 🔥 得分：98
   - 💬 评论：32
   - 👤 作者：username
   - 📝 摘要：文章介绍了某项新技术的工作原理及其应用场景。
   - 📎 HN：https://news.ycombinator.com/item?id=123457

...
```

**特殊情况的输出：**

- 若文章摘要无法获取，省略 `- 📝 摘要：` 行，其余字段照常输出。
- 若原文标题已是中文，直接使用该标题，无需额外标注【原文】。
- 若原文链接缺失（如 Ask HN），原文部分为空，仅展示翻译后的标题（或直接使用原标题）。

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
| 文章摘要抓取失败   | 省略 `- 📝 摘要：` 行，其余字段照常输出                   |

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
10. **始终中文输出**：无论用户使用何种语言提问，所有输出内容（包括标题、摘要、说明文字）必须使用中文。原文标题需完整保留。
11. **文章摘要**：对于有原文链接的 Story，必须抓取文章正文并生成简洁的中文摘要（3～5 句话）。抓取失败时省略摘要行，不影响其他字段输出。

## 示例交互

**用户提问：**

```text
给我看看现在 Hacker News 前 20 的热点
```

**执行流程：**

1. 请求 `https://hacker-news.firebaseio.com/v0/topstories.json`，获取前 20 个 Story ID。
2. 并发或依次请求 20 个 `https://hacker-news.firebaseio.com/v0/item/<id>.json`，获取每条 Story 详情。
3. 过滤无效条目，提取所需字段。
4. 对有 `url` 的 Story，抓取文章正文并生成简洁的中文摘要（3～5 句话）。
5. 按 API 返回的原始排名顺序整理，**始终使用中文**输出 Top 20 列表，标题同时展示原文与中文翻译，并附上摘要。
6. 在结果开头附上时效说明。

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
