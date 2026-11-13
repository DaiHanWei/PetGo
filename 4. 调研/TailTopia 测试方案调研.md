# TailTopia 测试方案调研

> 版本：v1　|　整理日期：2026-07-29
> 用途：内部技术方案文档（现状盘点、分层方案、工具选型、落地排期）
> 关联文档：《TailTopia UIUX设计师招聘方案》第十节「漂移治理」——本文是该节第 2 层「自动化检查」的完整展开

---

## 一、问题定义与核心判断

### 1.1 提出的三个问题

| # | 问题 | 表述 |
|---|---|---|
| P1 | 无专职测试人员 | 目前没有专职 QA，测试依赖开发人员兼顾，投入度受限 |
| P2 | 自动化测不到体验维度 | 自动化能覆盖功能正确性，但覆盖不了视觉还原、交互流畅度、真机体感，而这类问题恰恰是用户反馈的高频来源 |
| P3 | 人力测试覆盖面不全 | 纯人力测试在机型、系统版本、场景组合上覆盖有限，容易漏测 |

### 1.2 核心判断

**我们缺的不是测试人力，是测试的分层。**

三个问题看起来是一个问题（"人不够"），实际上要用三套完全不同的杠杆解。混在一起想，就必然得出"只能招 QA"的结论——而这个结论是错的，因为即使招了 QA，P2 和 P3 依然存在：一个人的眼睛判断不了 1px 的漂移，一个人的手也测不完 10 种机型 × 5 个系统版本。

> **正确的方向不是补人，而是把质量成本从「发布前的人力」转移到「CI 的机器时间 + 生产侧的观测」。**

### 1.3 一个必须纠正的前提 ⚠️

P2 的表述里，把"视觉还原"归进了"自动化测不到的体验维度"。**这个归类是错的，而且代价很大。**

- **视觉还原不是体验问题，是数值问题**——设计稿到实现的偏差，本质是间距、字号、圆角、色值的数值偏差
- 数值偏差是机器最擅长的领域，**机器比人眼准得多**
- 把它误判成"只能靠人眼"，会导致我们在最容易自动化的一层上持续投入人力，同时在真正需要人的地方（手感、节奏）没有资源

这与《UIUX设计师招聘方案》10.1 的结论一致：**判断"好不好看"需要审美训练，判断"一不一样"不需要。** 视觉还原属于后者。

**真正自动化不了的只有两样：交互流畅度的主观体感、以及"这个流程别扭"这类整体感受。** 范围比想象中小得多。

---

## 二、现状盘点（基于 petgo-platform 实际代码）

### 2.1 技术栈

| 项 | 现状 |
|---|---|
| App | Flutter 3.44.1（stable），Riverpod 3.x + go_router 17.x |
| 后端 | Java / Spring（Maven） |
| CI | GitHub Actions，`frontend-ci.yml` + `backend-ci.yml` |
| 仓库 | `~/work/petgo-platform`（`main` = 线上，`stag` = 开发中版本） |

### 2.2 测试能力现状

| 能力 | 现状 | 评价 |
|---|---|---|
| 静态检查 | CI 跑 `flutter analyze`（zero warnings） | ✅ 已有，底子好于多数小团队 |
| 单元 / Widget 测试 | 87 个 test 文件，CI 跑 `flutter test` | ✅ 已有基础 |
| 构建验证 | CI 跑 `flutter build apk --debug` | ✅ 已有 |
| 视觉回归（golden） | **无** | ❌ 关键缺口，对应 P2 |
| E2E / 集成测试 | **无**（无 `integration_test` 目录） | ❌ 缺口 |
| 云真机 / 设备农场 | **无** | ❌ 缺口，对应 P3 |
| 崩溃 / 性能监控 | **无**（未见 Sentry / Crashlytics） | ❌ 关键缺口 |
| 用户会话回放 | **SDK 已装，未启用** | ⚠️ **被浪费的资产** |

### 2.3 两个重要发现

**发现 1：`posthog_flutter: ^4.0.0` 已经在依赖里。**
PostHog 的 Flutter 移动端 session replay 已支持（beta 期免费），我们只需改配置就能拥有用户会话回放能力。这是当前**投入产出比最高的一件事**——用户反馈"卡"、"点不动"时可以直接看回放，复现成本降一个数量级。

**发现 2：完全没有生产侧质量监控。**
这意味着我们现在对线上质量的唯一感知渠道是**用户主动反馈**。用户反馈是最滞后、最有偏、最贵的信号源——这直接解释了为什么"体验问题是用户反馈的高频来源"：不是体验问题特别多，是**只有体验问题会被用户说出来**，其他问题（崩溃、慢、卡）用户默默卸载了，我们一无所知。

---

## 三、分层方案

四层，每层解一个具体问题。**分层的意义是：每一层用最便宜的手段解决它能解决的部分，不让人力去做机器的活。**

| 层 | 解决 | 手段 | 人力依赖 |
|---|---|---|---|
| L1 功能正确性 | 主流程可用 | 单测（已有）+ E2E 冒烟 | 一次性编写 |
| L2 视觉还原 | **P2 的一半** | Golden 截图基线 + token lint | 零（机器判定） |
| L3 机型覆盖 | **P3** | 云真机 + AI 探索式代跑 | 零（机器代跑） |
| L4 真机体感 | **P2 的另一半** | 生产侧监控 + 会话回放 + 灰度 | 极低（看指标） |

四层做完，剩给人的只有**每版本 30 分钟的真机 dogfooding**——这就是 P1 的答案：不是找人，是把需要人的部分压缩到兼顾得过来的量级。

---

### L1：功能正确性 —— 补 E2E 主干，但严格克制

**现状**：单测够用，缺端到端主流程验证。

**工具选型：Maestro（YAML 描述流程，iOS / Android 共用一份脚本）**

不推荐 Flutter 自带的 `integration_test`。原因不是理论上的，是我们的依赖决定的：

| 我们用的能力 | `integration_test` 表现 |
|---|---|
| `google_sign_in` / `sign_in_with_apple` | 跳出应用，测不了 |
| `permission_handler` | 系统权限弹窗，测不了 |
| `image_picker` | 系统相册选择器，测不了 |
| `tencent_cloud_chat_sdk` | 原生 IM 层，难覆盖 |

`integration_test` 只能在 Flutter 的沙箱内操作，一碰到系统级 UI 就失效——**而我们的核心流程恰好全是它的盲区**。Maestro 走的是系统级 UI 层，这些都能覆盖，且一份 YAML 跨双端。业界报告的编写成本差距明显（有团队单条用例从 3–4 小时降到 10–15 分钟）。

**范围纪律（比工具选择更重要）：只写 6–8 条"钱路径"。**

建议覆盖：
1. 注册 / 登录（含第三方登录）
2. 创建宠物档案
3. 发帖 → 浏览 → 互动
4. IM 会话收发
5. 预约流程（V1.3.0 线下兽医预约上线后补）
6. 支付 / 关键转化路径

**不追覆盖率。** 10 条稳定用例的价值远大于 60 条 flaky 用例——flaky 用例会让开发学会无视 CI 红灯，那一刻这套体系就死了。业界数据：选择器类方案的 flaky 率在 15–20%，维护占 QA 时间的 30–50%。我们没有 QA，所以**必须把维护成本压到接近零，代价是放弃覆盖率**。

**接入方式**：CI 里 nightly 跑（不阻塞每个 PR，避免 flaky 拖慢开发），release 分支必跑。

---

### L2：视觉还原 —— 用机器替代人眼（P2 的可自动化部分）

这一层是**当前最痛、且最被低估**的一层，也是《UIUX设计师招聘方案》10.2 第 2 层的落地。

#### 2.1 Golden Test（截图基线）

**工具：`alchemist`**
（注意：`golden_toolkit` 已停止维护，2025 年起 `alchemist` 是 Flutter golden 测试的事实标准，选型时不要选错。）

**覆盖范围**：
- 设计系统组件（按钮、卡片、输入框、标签、头像……）
- Top 10 核心页面
- 每项 × 3 种屏幕尺寸 × light/dark

**CI 关键配置（做不对会白搭）** ⚠️：

| 配置 | 原因 |
|---|---|
| 固定在 **Linux x64 单一环境**跑 | 跨 OS 的字体渲染差异会产生大量像素漂移，淹没真实 diff |
| 用 `loadAppFonts()` 加载字体 | CI 环境无系统字体，不加载会全部渲染成方块 |
| 失败时把 diff 图存为 CI artifact | 让开发能直接下载对比图，否则"红了但不知道哪里红" |
| 设置合理的像素容差阈值 | 阈值太严会天天误报，太松会漏掉真实漂移 |

**收益**：AI 写代码时顺手把间距从 16 改成 14、把圆角从 12 改成 8，**当场被 CI 拦住**，而不是等三周后用户反馈"这页看着怪"。

#### 2.2 Token 化 + Lint 禁魔法数值（源头治理）

Golden 抓的是**结果**，lint 抓的是**源头**，两者必须配套：

- 字号 / 行高 / 间距 / 圆角 / 颜色收敛到唯一来源（Flutter `ThemeData` / 统一 token 文件）
- 加 lint 规则：代码中出现硬编码 `fontSize: 15`、`padding: 18` 直接报错
- 规范写进 `petgo-platform/CLAUDE.md`，确保每次 AI 开发都读到

> 这两件事合起来，把视觉漂移从"必然发生"变成"写不出来 + 写出来也过不了 CI"。

#### 2.3 为什么这一层优先级最高

- 成本最低：一次性搭建 1–2 天，之后每个新页面 +10 分钟
- 收益最持久：不随版本反复，不依赖任何人的视觉敏感度
- **它同时解决了"AI 编码漂移"这个更根本的问题**——我们的开发方式高度依赖 AI，而 AI 每次写代码都会重新猜一个数值，这是结构性的漂移源，只能用结构性手段挡

---

### L3：机型 / 系统覆盖 —— 用数据选机型，用 AI agent 代跑（P3）

#### 3.1 机型选择：用数据，不要猜 ⚠️

**不要追求"覆盖尽量多机型"**，那是无底洞。正确做法：

1. 从 **PostHog 拉真实设备型号 / 系统版本分布**
2. 取**覆盖 80% DAU 的 Top 8–10 机型**
3. 加上**最低支持系统版本**的一台
4. **必须加一台低端 Android**（关键，见下）

**印尼市场特别提示**：入门级 Android、低内存、弱网的用户占比通常**远高于团队直觉**。团队手上的测试机（大概率是中高端机）严重不具代表性——我们感受不到的卡顿，可能是大部分用户的日常。这一条不要凭印象定，用 PostHog 的实际数据定。

同时应覆盖的场景变量：弱网（3G / 高延迟）、低内存、深色模式、系统字体放大。

#### 3.2 执行工具（按性价比排序）

| 优先级 | 工具 | 说明 | 成本 |
|---|---|---|---|
| 1 | **Firebase Test Lab + App Testing Agent** | Google 2025/2026 推出，**用自然语言写测试目标**，Gemini 驱动 agent 自己决定点什么、输入什么、观察什么，跑在 Test Lab 真机上 | 按用量计费，门槛最低 |
| 2 | **Robo test**（Test Lab 自带） | 免配置自动爬虫，做崩溃 / ANR 兜底，每个 release 分支跑一轮 | 极低 |
| 3 | BrowserStack App Automate / LambdaTest / Sauce Labs / AWS Device Farm | 商业设备云，3000+ 真机 | BrowserStack 约 $249/月起 |

**结论：先用 1 + 2，现阶段不要买 3。** 我们的规模撑不起商业设备云的月费，而 Test Lab 按量计费 + App Testing Agent 的自然语言门槛，恰好匹配"没有专职 QA"的团队——**写测试目标的能力，产品经理就具备，不需要会写代码**。

这一层的本质是：**用机器的"耐心"替代人的"覆盖面"**。人测不完 10 机型 × 5 系统版本 × 8 条流程 = 400 种组合，机器可以。

---

### L4：真机体感 —— 把测试后移到灰度（P2 的不可自动化部分 + P1 的最大杠杆）

流畅度和体感确实**测**不出来，但**可以量化地观测出来**。这一层是无 QA 团队最重要的一层保险。

#### 4.1 会话回放（立即可做，成本近乎为零）

- **打开 PostHog session replay**——`posthog_flutter` 已在依赖里，改配置即可
- 支持 wireframe（默认）和 screenshot 两种模式
- Flutter 移动端 replay 处于 beta，**免费**
- ⚠️ **必须同时配置隐私脱敏**：宠物医疗信息、支付页、IM 会话内容都要 mask。这是合规底线，不是可选项

**价值**：用户反馈"卡"、"点不动"、"我不知道怎么弄"时，直接看回放。**从"复现用户问题"变成"观看用户问题"**——这是无 QA 团队最需要的能力。

#### 4.2 崩溃 + 性能监控（当前最大缺口）

**选型**：Sentry Flutter（符号化和性能追踪更成熟）或 Firebase Crashlytics + Performance。两者都可，Sentry 的 Flutter 支持更完整，且自带 session replay 可与 PostHog 二选一。

**必须盯的 4 条红线指标**：

| 指标 | 对应的用户感受 |
|---|---|
| 崩溃率（Crash-free rate） | "老是闪退" |
| 冷启动时长 | "打开好慢" |
| 慢帧率 / jank | "滑起来卡" |
| 关键接口 P95 延迟 | "点了没反应" |

> **这四个指标就是"流畅度"的可量化代理。人眼说不清的东西，它们说得清。**
> 这直接回应 P2 中"交互流畅度测不了"的部分——测不了，但测得出来。

#### 4.3 灰度发布 + 自动熔断

- 内测：Firebase App Distribution
- 放量：Google Play staged rollout（5% → 20% → 50% → 100%）+ App Store phased release
- **红线指标超阈值自动停止放量**

**这一层的意义是范式转变**：我们不再需要"发布前测出所有问题"，只需要"让问题在影响 5% 用户时被自动发现并止损"。对没有 QA 的团队，这是决定性的——它把不可能的目标（测全）换成了可能的目标（早发现）。

#### 4.4 剩下的人工部分

每个版本发布前，团队在真机上跑 **30 分钟 dogfooding**：
- 只记录"感觉不对"的地方，**不写用例、不填表格**
- 覆盖本版本改动的流程 + 一条主路径
- 这是全套方案里唯一无法自动化的部分，也是唯一真正需要"体感"的部分

---

## 四、补充选项：真人测试外包（按需，不养人）

| 方案 | 适用 | 成本量级 | 评价 |
|---|---|---|---|
| **印尼本地 freelance 测试员** | 按版本 / 按小时雇 | 低 | ✅ **推荐**。理解本地网络、机型、使用习惯，正好补"本地体感"，且更贴近目标用户 |
| 众包平台（uTest/Applause、Test IO、Testin） | 大版本前买一轮机型覆盖 + 真人体验 | 按轮次计费，通常数千美元/轮 | ⚠️ 现阶段偏贵，大版本可考虑 |
| 招全职 QA | — | 最高 | ❌ 不推荐，见 1.2 |

**建议**：先把 L1–L4 落地，观察 2–3 个版本后再评估是否需要真人补充。大概率只在大版本（如 V1.3.0）前需要买一轮。

---

## 五、落地排期

| 阶段 | 动作 | 投入 | 解决 |
|---|---|---|---|
| **阶段 0（本周）** | ① 开启 PostHog session replay + 配置隐私脱敏<br>② 从 PostHog 拉设备/系统分布，确定发布前机型矩阵<br>③ 接入崩溃 + 性能监控，设定 4 条红线指标阈值 | ~1 人日 | P2 体感、P3 选型依据 |
| **阶段 1（2 周内）** | ① `alchemist` golden 基线（设计系统组件 + Top 10 页面）<br>② 接入现有 `frontend-ci.yml`（固定 Linux runner + `loadAppFonts`）<br>③ token 收敛 + lint 禁魔法数值，规范写入 `CLAUDE.md` | ~2 人日 | **P2 视觉还原** |
| **阶段 2（1 个月内）** | ① Maestro 写 6–8 条主流程冒烟<br>② CI nightly 执行，release 分支必跑<br>③ Firebase Test Lab Robo test 接入 release 流程 | ~2 人日 | P1、P3 |
| **阶段 3（每版本例行）** | ① App Testing Agent 用自然语言描述本版本核心目标，跑一轮<br>② 灰度发布 + 红线熔断<br>③ 团队 30 分钟真机 dogfooding | ~0.5 人日/版本 | 全部 |

**一次性搭建总投入：约 5 人日。**
**稳态后每版本人力：从"几天"降到"半天抽检"。**

---

## 六、配套的流程约束（不做的话工具会被绕过）

没有 QA，责任就必须写进流程，否则所有工具最终都会被"这次先跳过"掉。

1. **PR 模板增加一项：golden 基线是否变更、为什么**
   逼开发对每一次视觉改动做**显式声明**。这一条比 golden test 本身更重要——它把"我没注意到改了间距"变成"我声明我改了间距"。

2. **Release captain 轮值**
   每个版本指定一名开发负责跑 checklist、看红线指标、决定是否继续放量。轮换制，避免固定负担。

3. **红线指标阈值写死在文档里，不临场商量**
   崩溃率、慢帧率的熔断阈值提前定好。发布当天讨论"这个数据算不算严重"，结论永远是"先发吧"。

---

## 七、明确不建议做的事

| 不做 | 原因 |
|---|---|
| 追单元测试覆盖率数字 | 对 P1/P2/P3 三个痛点都无效，纯粹消耗开发时间 |
| 上 Appium | 维护成本对无 QA 团队是灾难 |
| 现在采购商业设备云 | 规模不够，Test Lab 按量计费更划算 |
| 大量编写 `integration_test` | 覆盖不到我们的核心流程（见 L1） |
| 招全职 QA | 解决不了 P2 和 P3，只是把 P1 换成薪资成本 |
| 建立详尽的手工测试用例文档 | 没人会执行，也没人维护，最终变成僵尸文档 |

---

## 八、结论

**这套方案不是让测试变便宜，是把测试成本从「人的时间」换成「机器时间 + 一次性搭建时间」。**

三个问题的对应答案：

- **P1（无专职 QA）** → 不补人。把需要人的部分压缩到每版本 30 分钟 dogfooding + 看红线指标
- **P2（自动化测不到体验）** → 一半是误判（视觉还原用 golden 完全可自动化），另一半用生产侧监控 + 会话回放把"测不出来"换成"观测得出来"
- **P3（人力覆盖不全）** → 用 PostHog 数据定机型矩阵，用云真机 + AI agent 代跑组合爆炸的部分

**最优先的两件事**（如果只能做两件）：
1. 开启 PostHog session replay + 接入崩溃/性能监控（阶段 0，1 人日，立刻获得线上感知能力）
2. Golden test + token lint（阶段 1，2 人日，根治视觉漂移）

---

## 附：参考资料

**Flutter 测试与视觉回归**
- [Testing Flutter Apps in 2026: A Real-World Guide](https://testguild.com/testing-flutter-apps/)
- [Golden Tests vs Unit Tests: The 2026 UI Testing Paradigm Shift](https://zignuts.com/blog/golden-tests-vs-unit-tests)
- [Flutter Widget Testing Best Practices: Golden Tests and Screenshot Diffs](https://vibe-studio.ai/insights/flutter-widget-testing-best-practices-golden-tests-and-screenshot-diffs)

**E2E 框架**
- [Maestro: Flutter Integration Testing](https://maestro.dev/insights/maestro-flutter-integration-testing)
- [Maestro Mobile Testing: The Complete YAML-Based Guide for 2026](https://qaskills.sh/blog/maestro-mobile-testing-guide-2026)
- [How to test Flutter apps: Flutter testing tools and E2E testing framework guide (2026)](https://www.drizz.dev/post/how-to-test-flutter-apps-flutter-testing-tools-and-e2e-testing-framework)

**云真机与 AI 探索式测试**
- [Firebase App Testing agent (Android) — 官方文档](https://firebase.google.com/docs/app-distribution/android/app-testing-agent)
- [Autonomous Testing for Mobile Apps: How AI Agents Explore Your App (2026)](https://www.drizz.dev/post/autonomous-testing-for-mobile-apps-ai-agents)
- [Top Device Farms in 2026 for Mobile App Testing](https://testgrid.io/blog/best-device-farms/)

**生产侧监控**
- [PostHog Flutter session replay 安装文档](https://posthog.com/docs/session-replay/flutter)
- [Sentry Flutter Session Replay](https://docs.sentry.io/platforms/flutter/session-replay/)
- [PostHog vs Sentry 对比](https://posthog.com/blog/posthog-vs-sentry)

**众包测试**
- [Crowdtesting Platforms Compared: 7 Options for Developers in 2026](https://www.testfi.app/blog/crowdtesting-platforms-compared)
