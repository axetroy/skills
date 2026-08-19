---
name: third-party-notices
description: 扫描项目并收集其全部第三方依赖，生成 THIRD_PARTY_NOTICES.md（开源许可合规 / 第三方声明 / attribution 文件）。支持 JavaScript/npm、pnpm、yarn、bun、Python/pip、poetry、uv、Go、Rust/Cargo、Java/Kotlin (Maven/Gradle)、.NET/NuGet、PHP/Composer、Ruby/Bundler、C/C++ (vcpkg/Conan/CMake)、Swift/SPM、Dart/Flutter、Elixir/Hex、Haskell/Cabal 等主流生态，并附完整许可文本。当用户要求列出依赖、生成第三方许可声明、做开源许可合规审计、生成 attribution / THIRD_PARTY_NOTICES / NOTICE / legal notices 文件或准备发布包时使用。
---

# Third-Party Notices 生成器

## 目的

发现当前项目所依赖的全部第三方库，收集其版本、许可证、版权声明与完整许可文本，并生成 `THIRD_PARTY_NOTICES.md`，用于开源许可合规（attribution / license compliance / 第三方声明）。

### 适用场景

- 用户要求列出 / 统计项目第三方依赖
- 生成 `THIRD_PARTY_NOTICES.md`、`THIRD-PARTY.txt`、`NOTICE`、attribution 文件
- 发布软件包前的开源许可合规检查
- 审计某个依赖使用了什么许可证

### 不适用

- 无任何第三方依赖的项目（直接报告即可）
- 需要法律意见的许可选择 / 商业合规判断（本技能只做归集与呈现，不构成法律意见）

## 输出约定

- 输出文件：项目根目录 `THIRD_PARTY_NOTICES.md`（用户指定路径则用指定路径）
- 若文件已存在：更新版本，保留手工维护的条目，不整体覆盖
- 只读收集依赖信息，绝不修改依赖清单（package.json、go.mod 等）
- 需要网络访问注册表；离线时退回本地模块缓存 / vendor 目录，并在文件中注明

## 工作流程

### Step 1 检测生态

搜索项目中的清单 / 锁定文件，按下表确定需要处理的生态。`monorepo / workspace` 项目必须扫描所有子目录，而不只是根目录。

| 生态         | 信号文件                                                                   | 参考文档                                                 |
| ------------ | -------------------------------------------------------------------------- | -------------------------------------------------------- |
| JS/Node.js   | package.json + (package-lock.json / pnpm-lock.yaml / yarn.lock / bun.lock) | [references/js-node.md](references/js-node.md)           |
| Python       | pyproject.toml、requirements\*.txt、Pipfile、poetry.lock、uv.lock          | [references/python.md](references/python.md)             |
| Go           | go.mod、go.sum                                                             | [references/go.md](references/go.md)                     |
| Rust         | Cargo.toml、Cargo.lock                                                     | [references/rust.md](references/rust.md)                 |
| Java/Kotlin  | pom.xml、build.gradle(.kts)                                                | [references/java-kotlin.md](references/java-kotlin.md)   |
| .NET         | \*.csproj、packages.lock.json、project.assets.json                         | [references/dotnet.md](references/dotnet.md)             |
| PHP          | composer.json、composer.lock                                               | [references/php.md](references/php.md)                   |
| Ruby         | Gemfile、Gemfile.lock                                                      | [references/ruby.md](references/ruby.md)                 |
| C/C++        | vcpkg.json、conanfile.\*、conan.lock、CMakeLists.txt                       | [references/cpp.md](references/cpp.md)                   |
| Swift        | Package.swift、Package.resolved                                            | [references/swift.md](references/swift.md)               |
| Dart/Flutter | pubspec.yaml、pubspec.lock                                                 | [references/dart-flutter.md](references/dart-flutter.md) |
| Elixir       | mix.exs、mix.lock                                                          | [references/elixir.md](references/elixir.md)             |
| Haskell      | \*.cabal、stack.yaml、cabal.project.freeze                                 | [references/haskell.md](references/haskell.md)           |

**依赖范围（重要决策点）**

- 发布到注册表的库 / 包 → 只收集运行时（生产）依赖，排除 dev / test
- 应用、CLI、服务 → 收集全部会打进交付物的依赖
- 无法判断时，默认包含全部，并在文件中注明；必要时向用户确认

### Step 2 按生态收集依赖

对每个检测到的生态，打开对应的 `references/*.md`，按其命令执行。原则：

- 优先使用生态自带或社区标准工具（如 `composer licenses`、`pnpm licenses list`、`cargo-license`）；工具未安装时优先解析锁定文件，不要未经用户同意就安装新工具
- 每个依赖记录：包名、精确版本（来自锁定文件）、许可证（SPDX 标识）、版权行、仓库地址
- 锁定文件记录的是解析后的完整依赖树，天然包含传递依赖，务必一并收集

### Step 3 解析许可文本

按以下优先级获取许可证信息与全文：

1. 锁定文件 / 清单中已带的 SPDX 标识
2. 包注册表 API（npm registry、crates.io、PyPI、Maven Central、NuGet、Packagist、RubyGems、Hex、pub.dev、Hackage 等，具体见 references/\*.md）
3. 包自带的 LICENSE / COPYING 文件（模块缓存、vendor 目录、下载的归档）
4. SPDX 规范全文：https://spdx.org/licenses/<SPDX_ID>.json

要求：

- 每种许可证附完整文本；MIT / BSD / Apache / ISC 等要求署名的许可证必须原样保留版权声明行（verbatim）
- 无法确定为开源许可的包（UNLICENSED、proprietary、查不到）归入 "Unknown / Unlicensed" 章节，并尽量从源码仓库抓取 LICENSE 补充
- 遇到 `OR` 形式的双许可（如 `MIT OR Apache-2.0`）时，两个许可文本都收录

### Step 4 生成 THIRD_PARTY_NOTICES.md

使用模板 [assets/third-party-notices.template.md](assets/third-party-notices.template.md) 生成，包含：

1. 头部：项目名、仓库地址、生成日期
2. 摘要：各生态包数量、总包数、不同许可证数量
3. 依赖表：按生态分组，列 Package / Version / License (SPDX) / Copyright / Repository
4. 许可证全文：按许可证去重，每个许可证下列出 "Used by: ..."
5. Unknown / Unlicensed 章节
6. 说明与免责声明

### Step 5 校验

- 每个依赖在表中有行，且许可证字段非空（或明确标记 UNKNOWN）
- 每种出现过的许可证全文都包含在文件中
- MIT / BSD / Apache / ISC 等版权声明已原样收录
- 无重复行；版本与锁定文件一致
- 汇总行数与实际依赖数一致

完成时向用户报告：N 个包 / M 个生态 / X 种许可证 / 输出路径。

## 合规提醒

- 本技能只做归集，不构成法律意见
- GPL / AGPL / LGPL / MPL 等 copyleft 许可仅有署名声明可能不足，还可能有"提供源代码"等义务——遇到时向用户单独提示
- 工具可能需要安装（如 cargo-license、pip-licenses、go-licenses），安装前征得用户同意
