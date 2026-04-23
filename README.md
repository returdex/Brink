# Brink

[中文](#中文) | [English](#english)

## 中文

### 项目简介

Brink 是一个面向 macOS 的、`local-first` 的 deadline 可视化桌面工具。  
它不试图成为“又一个全功能待办应用”，而是专注解决一个更窄但更高频的问题：

**让最危险、最接近截止时间的任务，持续停留在用户视线里。**

Brink 通过桌面常驻列表、颜色风险映射、最紧急任务环形视图、通知与轻量输入入口，把“离截止还有多久”压缩成一眼可读的信息。

### 为什么做这个项目

现有任务管理工具大多强在输入、组织、协作、同步，但弱在持续可见的 deadline 风险暴露。

Brink 的差异化不在“任务管理更强”，而在下面这组组合能力：

- 桌面常驻可见，而不是必须打开 App 才能查看
- 以截止风险为核心排序，而不是以项目、标签或列表为中心
- 支持父子层级，不把真实项目结构压扁
- 在主视图与缩略视图中保持一致的颜色语义

### 产品定位

Brink 是：

- 一个 `macOS-only` 的专注型生产力工具
- 一个以 `deadline risk visibility` 为核心的视觉前端
- 一个先文档、后实现、先 MVP、后扩展的产品项目

Brink 不是：

- 通用任务管理 SaaS
- 团队协作平台
- 以跨端同步为第一优先级的待办系统

### 核心体验

用户打开 Brink 后，应该立即获得以下体验：

- 看到按风险排序的任务清单，而非普通待办列表
- 在展开树形结构时保留父子关系，不牺牲项目上下文
- 在紧凑模式下聚焦“当前最危险任务”而不是平均风险
- 在通知、Widget 和桌面视图之间获得一致的 deadline 语义

### MVP 范围

首个版本只做最关键闭环：

- 本地任务存储
- 父子任务层级
- `effectiveDue` 驱动的风险排序
- 桌面主视图：横向风险条列表
- 紧凑视图：单任务环形风险指示
- 本地通知
- 菜单栏入口
- `JSON/CSV` 导入导出
- Apple Reminders 单向导入或受控同步的预研接口

明确不进入 MVP 的内容：

- 多人协作
- 自建云同步
- Web 端
- iOS 客户端
- 复杂日历调度与时间块规划

### 文档导航

- [README.md](D:/1-code/apple/README.md): 项目门面与总体说明
- [ROADMAP.md](D:/1-code/apple/ROADMAP.md): 阶段路线、里程碑与版本节奏
- [ARCHITECTURE.md](D:/1-code/apple/ARCHITECTURE.md): 技术架构、模块与数据模型
- [PRD.md](D:/1-code/apple/PRD.md): 产品需求、用户场景与验收标准

### 建议目录结构

当前阶段采用“文档先行，不建立代码骨架”的组织方式：

```text
Brink/
- README.md
- ROADMAP.md
- ARCHITECTURE.md
- PRD.md
- docs/
  - research/
  - product/
  - design/
  - decisions/
```

建议说明：

- `docs/research/` 存放原始调研、竞品分析、来源链接
- `docs/product/` 存放用户流程、术语表、版本说明
- `docs/design/` 存放信息架构、线框图、视觉语义
- `docs/decisions/` 存放 ADR、关键技术取舍和里程碑决策

### 初始开发原则

- `Document first`: 先定义产品和系统，再开始写代码
- `Single-player first`: 优先解决单个用户的高频使用场景
- `Local-first`: 数据、排序、渲染、通知优先本地完成
- `Small sharp MVP`: 小而锋利，避免过早平台化
- `Risk-first UI`: UI 服务于风险感知，不服务于功能堆叠

### 开源与商业化

Brink 计划采用：

- 社区版本：`GNU AGPL-3.0-or-later`
- 商业使用：由版权持有人提供单独商业授权

这意味着：

- 社区可以在 AGPL 条款下使用、修改和分发
- 若有闭源集成、专有发行或其他超出 AGPL 适用边界的商业场景，可联系作者获取商业许可
- 为了保证后续双授权可持续，贡献需要接受项目的贡献授权条款

### 推荐启动顺序

1. 完成并冻结 v0 文档基线
2. 先验证信息架构和风险语义
3. 再搭建 macOS App + Widget 最小骨架
4. 最后接入导入导出、通知与 Reminders 能力

---

## English

### Overview

Brink is a `local-first` macOS desktop tool for deadline visualization.  
It is not trying to be another full-featured task manager. Instead, it focuses on a narrower but higher-frequency problem:

**keeping the most dangerous, nearest-deadline task visible at all times.**

Brink turns deadline pressure into glanceable signals through a persistent desktop list, urgency color mapping, a compact circular focus view, notifications, and lightweight entry points.

### Why This Exists

Most task managers are strong at input, organization, collaboration, and sync, but weak at persistent deadline visibility.

Brink differentiates through this specific combination:

- Persistent desktop visibility instead of app-open visibility
- Risk-first sorting instead of project-first sorting
- Hierarchical parent-child task structure instead of a flattened checklist
- Consistent visual semantics across expanded and compact views

### Positioning

Brink is:

- a `macOS-only` focused productivity tool
- a visual front-end for deadline risk
- a document-first, MVP-first product effort

Brink is not:

- a general-purpose task management SaaS
- a collaboration platform
- a sync-first cross-platform system

### Core Experience

When a user opens Brink, they should immediately be able to:

- see tasks ordered by urgency and risk, not by generic list order
- preserve project hierarchy while still surfacing urgent work
- focus on the single riskiest item in compact mode
- carry the same deadline semantics across desktop, widget, and notification surfaces

### MVP Scope

The first release focuses on the smallest usable loop:

- local task storage
- parent-child task hierarchy
- `effectiveDue` based ordering
- desktop primary view with horizontal risk bars
- compact view with a single circular urgency indicator
- local notifications
- menu bar entry
- `JSON/CSV` import and export
- Apple Reminders integration research with a conservative first implementation

Explicitly out of scope for MVP:

- team collaboration
- custom cloud sync
- web app
- iOS app
- advanced calendar planning and time blocking

### Docs

- [README.md](D:/1-code/apple/README.md): project front page and summary
- [ROADMAP.md](D:/1-code/apple/ROADMAP.md): phases, milestones, and release path
- [ARCHITECTURE.md](D:/1-code/apple/ARCHITECTURE.md): system architecture and technical decisions
- [PRD.md](D:/1-code/apple/PRD.md): product requirements, scenarios, and acceptance criteria

### Suggested Directory Structure

At this stage, the repo stays document-first with no code scaffold yet:

```text
Brink/
- README.md
- ROADMAP.md
- ARCHITECTURE.md
- PRD.md
- docs/
  - research/
  - product/
  - design/
  - decisions/
```

Suggested usage:

- `docs/research/` for source research, competitor notes, and references
- `docs/product/` for flows, glossary, and release framing
- `docs/design/` for IA, wireframes, and visual semantics
- `docs/decisions/` for ADRs and major technical or product decisions

### Principles

- `Document first`: define product and system before implementation
- `Single-player first`: optimize for one user's daily flow before collaboration
- `Local-first`: keep storage, sorting, rendering, and notifications on-device
- `Small sharp MVP`: avoid premature platform ambition
- `Risk-first UI`: every visual choice should reinforce urgency comprehension

### Open Source and Commercialization

Brink is intended to use:

- community edition: `GNU AGPL-3.0-or-later`
- commercial use: separate commercial licensing from the copyright holder

That means:

- the community can use, modify, and distribute the project under AGPL terms
- closed-source integrations or other commercial arrangements outside AGPL expectations can be licensed separately
- contributions should follow contributor terms that preserve the project's ability to offer commercial licensing

### Suggested Start

1. Freeze the initial documentation baseline
2. Validate information architecture and urgency semantics
3. Build the minimum macOS app and widget shell
4. Add import/export, notifications, and Reminders integration last
