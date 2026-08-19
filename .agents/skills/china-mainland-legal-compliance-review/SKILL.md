---
name: china-mainland-legal-compliance-review
description: 审查软件项目、App、网站和在线服务是否符合中国大陆法律法规（不含港澳台）。覆盖个人信息保护（个人信息保护法/PIPL）、数据安全（数据安全法/DSL）、网络安全（网络安全法/CSL）、等级保护、数据出境、内容平台治理、算法推荐备案、生成式人工智能与深度合成监管、知识产权与开源许可、电子商务与广告规则、未成年人保护、ICP备案与行业准入、以及第三方合同。输出结构化合规审查报告，含风险定级与整改建议。当用户要求对产品或代码库进行中国大陆法律合规检查、评估、合规审查、数据合规、个人信息保护合规、App 上架合规、备案或出海中国大陆时使用。
---

# 中国大陆法律合规审查

## 目的

审查软件项目、App、网站或在线服务是否符合中国大陆（不含港澳台，除非用户明确要求）适用的法律法规。

本技能产出一份**合规审查报告**，功能如下：

1. 判断哪些中国大陆法律法规适用于该项目。
2. 扫描代码库、文档和产品表面，收集合规信号。
3. 找出项目现状与法律要求之间的差距。
4. 按严重程度与可能性对每项发现进行定级。
5. 给出具体整改建议与优先级。

本技能是**筛查与评估工具，不构成法律意见**。法律结论必须以评估语气表述（"看似"、"很可能需要"、"存在……风险"），不得作出保证。

## 使用时机

当用户出现以下需求时触发：

- 要求对项目进行中国大陆法律合规审查/检查/评估（合规审查、数据合规、个人信息保护合规）。
- 计划在中国大陆上线 App、网站或服务。
- 准备应用商店上架（App Store 中国区、应用宝、华为等）或 ICP 备案。
- 询问 PIPL、DSL、CSL、等级保护、数据出境、算法备案、生成式 AI 监管或未成年人保护。
- 要求对照中国法律审查隐私政策、用户协议或第三方 SDK 集成。

## 输入

- 待审查的项目目录或代码库。
- 产品描述、目标市场与用户群体。
- 可选：URL、隐私政策文本，或用户关心的具体问题。

若目标市场或用户群体未知，先向用户确认产品是否面向中国大陆，再进行完整审查。

## 工作流

### 1. 界定审查范围

1. 确认产品面向中国大陆（或处理大陆境内个人数据）。
2. 确定法律主体：网络运营者 / 数据处理者 / 个人信息处理者，以及主体注册地是否在大陆境内。
3. 依据[领域参考](#审查领域)选择适用的审查领域。每次审查**至少**覆盖：管辖与范围、个人信息保护、数据安全。其余领域在产品具有相应特征时纳入（如社交功能→内容治理；推荐功能→算法规则；AI 功能→生成式 AI 规则；电商→消费者/广告规则；游戏/文化内容→许可证照）。
4. 若提供了代码库，运行 [scripts/scan-project.sh](scripts/scan-project.sh)。

### 2. 收集证据

1. 运行扫描脚本并记录输出。
2. 阅读产品文档：隐私政策、用户协议、EULA、数据删除/导出流程、备案/证照文件。
3. 检查扫描标记的代码信号（数据采集调用、第三方 SDK、网络端点、分析工具、定位/设备权限使用）。
4. 在撰写某领域发现之前，先阅读[审查领域](#审查领域)下对应的参考文件。
5. 不猜测事实。凡无法从项目中验证的内容，标记为"未验证"并建议核实，或向用户询问。

### 3. 对照法律分析

针对范围内每个审查领域，打开对应参考文件，按关键要求与红旗清单逐项核对项目现状。参考文件是具体法律要求的来源：

| 领域                 | 参考文件                                                                                           |
| -------------------- | -------------------------------------------------------------------------------------------------- |
| 管辖与适用范围       | [references/01-jurisdiction-and-scope.md](references/01-jurisdiction-and-scope.md)                 |
| 个人信息保护         | [references/02-personal-information.md](references/02-personal-information.md)                     |
| 数据安全与数据出境   | [references/03-data-security-cross-border.md](references/03-data-security-cross-border.md)         |
| 网络安全             | [references/04-cybersecurity.md](references/04-cybersecurity.md)                                   |
| 内容平台治理         | [references/05-content-platform-governance.md](references/05-content-platform-governance.md)       |
| 算法推荐             | [references/06-algorithm-recommendation.md](references/06-algorithm-recommendation.md)             |
| 生成式 AI 与深度合成 | [references/07-generative-ai-deep-synthesis.md](references/07-generative-ai-deep-synthesis.md)     |
| 知识产权与开源       | [references/08-ip-open-source.md](references/08-ip-open-source.md)                                 |
| 消费者、电商与广告   | [references/09-consumer-ecommerce-advertising.md](references/09-consumer-ecommerce-advertising.md) |
| 未成年人保护         | [references/10-minors.md](references/10-minors.md)                                                 |
| 许可证照与行业准入   | [references/11-licensing-industry.md](references/11-licensing-industry.md)                         |
| 合同与第三方         | [references/12-contracts-third-party.md](references/12-contracts-third-party.md)                   |

### 4. 定级与出报告

1. 使用 [references/risk-rating.md](references/risk-rating.md) 对每项发现定级（严重程度 × 可能性，采用 P0–P4 或 高/中/低 标签）。
2. 按 [references/report-template.md](references/report-template.md) 撰写报告。
3. 优先呈现最高风险发现。每项发现必须引用具体法律法规条文与项目中的具体证据。
4. 给出可执行的整改措施与优先级顺序。

## 审查领域

十二个参考文件各覆盖：适用法律、关键要求、审查要点、红旗清单。分析每个领域前先阅读对应文件。参见工作流第 3 步的表格。

## 必须（ALWAYS）

- 完整审查前必须确认项目面向中国大陆（或处理大陆境内个人数据）；否则必须明确说明范围假设。
- 每次审查必须包含管辖与范围、个人信息保护、数据安全三个领域。
- 提供代码库时必须运行 [scripts/scan-project.sh](scripts/scan-project.sh)，并以输出作为证据。
- 撰写某领域发现前，必须阅读对应参考文件。
- 每项发现必须引用具体法律法规条文（如"《个人信息保护法》第 X 条"）和项目中的具体证据。
- 必须按 [references/risk-rating.md](references/risk-rating.md) 定级，并按 [references/report-template.md](references/report-template.md) 出报告。
- 必须区分事实（项目可验证）、评估（法律解释）与未验证项。
- 必备文档（隐私政策、用户协议、ICP 备案号、算法备案）缺失时，必须明确指出。
- 必须把法律视为动态：说明使用的法律版本/日期，并在可能存在新规时作出提示。
- 对高风险发现必须建议咨询具备资质的执业律师。

## 禁止（NEVER）

- 绝不把审查输出当作确定的法律意见或合规保证。
- 绝不虚构项目中不存在的合规文件、备案号或许可证。
- 绝不声称项目完全合规；始终以带剩余风险的评估表述。
- 绝不跳过风险定级或报告模板。
- 绝不捏造证据；每项发现必须追溯到扫描信号、文件或用户提供的事实。
- 绝不在审查过程中修改项目代码或文档；本技能只审查和报告。如需整改，先征得用户同意。
- 未经明确指示，绝不套用香港、澳门或台湾法律；默认范围仅限中国大陆。
- 绝不建议规避中国法律或规避数据出境要求；本技能识别合规义务并提供合法路径。
- 参考文件可用时，绝不只凭记忆猜测法律内容；使用参考文件，关键条文需核对现行有效文本。

## 常见场景

### 1. 中国大陆 App 的代码库审查

```bash
scripts/scan-project.sh /path/to/project
```

扫描结果报告数据采集信号、第三方 SDK、出境端点及缺失的合规文档。将扫描结果与隐私政策、用户协议的阅读结合，再按工作流进行分析。

### 2. 上线前清单审查

当用户问"在中国大陆上线前需要做什么"，进行轻量审查，覆盖：ICP 备案、等级保护、隐私政策 + 用户协议、数据出境评估（若数据离开大陆）、应用商店具体要求（如隐私合规文本、SDK 收集披露）、算法备案（如适用）、生成式 AI 服务备案（如适用）。许可证照矩阵参见 [references/11-licensing-industry.md](references/11-licensing-industry.md)。

### 3. 隐私政策差距审查

对照 [references/02-personal-information.md](references/02-personal-information.md) 审查隐私政策，核对：PIPL 第 17 条规定的隐私告知必备要素、敏感个人信息的单独同意、数据主体权利流程、保存期限、数据出境披露。

### 4. 第三方 SDK 审查

当项目集成分析、广告、推送或社交登录 SDK 时，执行 [references/12-contracts-third-party.md](references/12-contracts-third-party.md) 中的第三方检查：识别每个 SDK、其接收的数据、是否跨境传输、是否具备数据处理协议与披露声明。

## 输出

最终交付物是一份合规审查报告。使用与用户对话一致的语言撰写（中文对话→中文报告）。遵循 [references/report-template.md](references/report-template.md)，并使用 [references/risk-rating.md](references/risk-rating.md) 中的风险标签。

## 输出语言

报告使用与用户对话相同的语言撰写。中文对话用中文（法律名称保留官方中文形式，可附英文缩写）；英文对话用英文。

## 备注

- 法律依据：审查依赖的法律包括《个人信息保护法》（2021）、《数据安全法》（2021）、《网络安全法》（2017，2025 修订）、《未成年人网络保护条例》（2024）、《网络数据安全管理条例》（2025），以及数据出境、算法、生成式 AI 相关办法与规定。法律版本会变化；始终注明所用版本，重大引用需在行动前核对现行有效文本。
- 本技能属于工程技能仓库的一部分，仅为建议性内容，必须在报告中明确标注。
