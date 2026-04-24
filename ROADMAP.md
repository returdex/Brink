# Brink Roadmap

[中文](#中文) | [English](#english)

## 中文

### 路线目标

本路线图用于把研究结论转成可以执行的开发节奏。  
核心原则是：**先做“风险可视化闭环”，再做“生态连接”，最后才做“平台扩展”。**

### 阶段划分

#### Phase 0: Discovery Baseline

目标：冻结项目定义，统一术语、边界和优先级。

交付物：

- `README.md`
- `PRD.md`
- `ARCHITECTURE.md`
- `ROADMAP.md`
- 视觉语义草案
- 数据模型草案

退出条件：

- 团队对 `deadline risk`、`effectiveDue`、视图模式和 MVP 范围达成一致

#### Phase 1: Product Validation

目标：验证 Brink 的信息架构和视觉语义是否成立。

重点工作：

- 定义任务排序规则
- 定义颜色映射和风险等级
- 定义绿色依赖完成与无 deadline 留空规则
- 验证树形结构与风险排序的兼容关系
- 验证 `1x1`、`2x1`、`2x2+` 组件的尺寸切换逻辑
- 产出低保真和中保真交互稿

关键问题：

- 父任务如何表达子任务风险
- 已完成但仍相关的依赖任务如何保留显示
- `1x1` 是否只显示单一最危险任务
- 何时用长度表达对比，何时用颜色表达紧迫度

#### Phase 2: MVP Build

目标：交付第一个可用的 macOS 本地版本。

范围：

- macOS App 主界面
- 菜单栏入口
- 本地任务 CRUD
- 树形任务结构
- 风险排序与筛选
- 横向风险条主视图
- `1x1` 紧凑倒计时环形视图
- `2x1` 最紧急任务列表视图
- `2x2+` 可滚动 deadline 列表视图
- 本地通知
- `JSON/CSV` 导入导出

MVP 成功标准：

- 用户可以在 5 分钟内录入一组任务并立即感知风险排序
- 用户可以在桌面与菜单栏快速查看最紧急任务
- 无需联网即可完成核心流程

当前进展：

- macOS 原型工程已建立
- 主窗口与菜单栏入口已可运行
- 本地任务 `CRUD` 已接通
- 本地 JSON 持久化已可用
- `JSON` 导出与导入已完成本机验证
- 本地通知入口已接通

#### Phase 3: System Hardening

目标：把 MVP 提升到可公开测试的 Beta 水平。

范围：

- 性能优化
- 数据迁移策略
- 错误恢复机制
- Widget 数据刷新稳定性
- 通知去重与节流
- 可观测性与日志基础

#### Phase 4: Integrations

目标：补齐生态接口，但不牺牲本地优先架构。

候选项：

- Apple Reminders 更完整的接入
- 快速导入模板
- 快捷指令 / URL Scheme
- 自动化脚本入口

原则：

- 所有集成都不能反向决定核心数据模型
- 第三方系统仅作为输入输出边界，不成为运行前提

#### Phase 5: Expansion

目标：在核心体验成立后，评估产品延展。

可评估方向：

- iPhone/iPad 伴生端
- 只读 Web 视图
- 多窗口和多项目工作台
- CloudKit 或其他轻量同步方案

前置条件：

- Brink 已经证明存在稳定日常使用场景
- 风险可视化而非任务录入，仍是最主要使用理由

### 优先级分层

#### P0

- 风险排序模型
- 树形任务结构
- 主视图与紧凑视图的一致语义
- 组件尺寸切换的一致语义
- 本地通知
- 本地数据可靠性

#### P1

- 导入导出
- Widget 稳定刷新
- Apple Reminders 基础集成
- 过滤和视图切换

#### P2

- 自动化入口
- 更高级的视图模式
- 统计面板
- 跨设备体验

### 建议时间线

适用于单名熟悉 macOS 的开发者，保守估计：

1. 第 1-2 周：文档冻结、数据模型与视觉语义确认
2. 第 3-4 周：主界面、任务树和排序引擎
3. 第 5-6 周：多尺寸组件视图、菜单栏、通知
4. 第 7-8 周：导入导出、Widget、打磨
5. 第 9-10 周：Beta 质量修复与对外预览准备

### 当前仓库状态

仓库已从纯文档阶段进入“可本机构建原型”阶段。

推荐下一步：

1. 用 `SQLite + GRDB` 替换 JSON 持久化
2. 把任务列表升级为真正可折叠的树视图
3. 完成 `CSV` 实机导入导出回归
4. 加强通知节流、去重与任务级控制

### 非目标提醒

路线图刻意延后以下内容：

- 云后端
- 团队协作
- 实时同步
- 通用日历产品能力
- 为兼容第三方而复杂化内核

---

## English

### Goal

This roadmap translates the research into an executable development path.  
The sequencing principle is: **build the deadline-risk loop first, ecosystem connections second, platform expansion last.**

### Phases

#### Phase 0: Discovery Baseline

Goal: freeze the project definition, vocabulary, boundaries, and priorities.

Deliverables:

- `README.md`
- `PRD.md`
- `ARCHITECTURE.md`
- `ROADMAP.md`
- visual semantics draft
- data model draft

Exit criteria:

- alignment on `deadline risk`, `effectiveDue`, view modes, and MVP scope

#### Phase 1: Product Validation

Goal: validate Brink's information architecture and visual semantics.

Focus areas:

- task ordering rules
- color and urgency mapping
- green linked-completion and empty no-due treatment
- compatibility between hierarchy and risk-first ordering
- validation of `1x1`, `2x1`, and `2x2+` component behavior
- low and mid fidelity interaction design

#### Phase 2: MVP Build

Goal: ship the first usable local macOS version.

Scope:

- macOS app shell
- menu bar entry
- local task CRUD
- task hierarchy
- urgency sorting and filtering
- horizontal risk-bar primary view
- `1x1` circular countdown view
- `2x1` urgency list view
- `2x2+` scrollable deadline list view
- local notifications
- `JSON/CSV` import and export

Success criteria:

- a user can enter tasks and understand urgency within five minutes
- the most urgent item is visible from desktop and menu bar surfaces
- the core workflow works fully offline

#### Phase 3: System Hardening

Goal: raise MVP quality to a public Beta level.

Scope:

- performance optimization
- migration strategy
- recovery paths
- widget refresh stability
- notification deduplication and throttling
- basic observability and logging

#### Phase 4: Integrations

Goal: add ecosystem connections without breaking the local-first core.

Candidates:

- deeper Apple Reminders integration
- quick import templates
- Shortcuts or URL Scheme
- automation hooks

#### Phase 5: Expansion

Goal: evaluate extensions once the core product proves daily value.

Possible directions:

- iPhone/iPad companion
- read-only web surface
- multi-window project workspace
- CloudKit or other lightweight sync options

### Priority Layers

#### P0

- urgency model
- task hierarchy
- semantic consistency across primary and compact views
- semantic consistency across size changes
- local notifications
- reliable local persistence

#### P1

- import/export
- stable widget refresh
- baseline Apple Reminders integration
- filtering and view modes

#### P2

- automation hooks
- advanced view modes
- analytics panel
- cross-device experience

### Suggested Timeline

For one macOS-experienced developer, conservative estimate:

1. Weeks 1-2: documentation baseline, data model, visual semantics
2. Weeks 3-4: main UI, task tree, sorting engine
3. Weeks 5-6: multi-size widget surfaces, menu bar, notifications
4. Weeks 7-8: import/export, widget, polish
5. Weeks 9-10: Beta-quality fixes and external preview prep

### Intentional Non-Goals

- cloud backend
- team collaboration
- real-time sync
- generic calendar-product breadth
- over-complicating the core for third-party compatibility
