# Brink

[中文](#中文) | [English](#english)

## 中文

### 项目简介

Brink 是一个面向 macOS 的、`local-first` 的 deadline 可视化桌面工具。  
它不试图成为“又一个全功能待办应用”，而是专注解决一个更窄但更高频的问题：

**让最危险、最接近截止时间的任务，持续停留在用户视线里。**

Brink 通过桌面常驻列表、蓝色到红色的风险映射、绿色依赖完成指示、按尺寸切换的组件视图、通知与轻量输入入口，把“离截止还有多久”压缩成一眼可读的信息。

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
- 在 `1x1` 紧凑模式下聚焦“当前最危险任务”而不是平均风险
- 在 `2x1` 与 `2x2+` 组件尺寸下按最紧急内容排序展示 deadline 信息
- 在通知、Widget 和桌面视图之间获得一致的 deadline 语义

### MVP 范围

首个版本只做最关键闭环：

- 本地任务存储
- 父子任务层级
- `effectiveDue` 驱动的风险排序
- 桌面主视图：横向风险条列表
- `1x1` 紧凑视图：单任务倒计时环形指示
- `2x1` 组件：仅显示当前可容纳的最紧急任务
- `2x2+` 组件：可滚动浏览全部 deadline 信息
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

### 当前实现状态

当前仓库已经不再是纯文档阶段，而是包含一个可本机构建与实验的 `macOS SwiftUI` 原型。

当前已完成：

- `Brink.xcodeproj` 工程与 `xcodegen` 配置
- 主窗口 + 菜单栏入口
- 本地任务 `CRUD`
- 父子任务层级
- `effectiveDue` 风险排序
- 本地 JSON 持久化
- `JSON/CSV` 导入导出
- 本地通知调度入口
- 英文与简体中文界面文案

已在本机完成的实际验证：

- App 启动
- 新建根任务
- 新建子任务
- 删除子任务
- 编辑标题并落盘
- 导出 `JSON`
- 再导入 `JSON`

当前仍在迭代中的部分：

- 可折叠树形视图
- 更稳健的通知策略
- Widget 实装
- `SQLite + GRDB` 持久化替换
- Apple Reminders 集成

### 本地开发

环境准备：

```bash
./scripts/setup-macos-dev.sh
```

生成工程：

```bash
./scripts/generate-xcodeproj.sh
```

命令行构建：

```bash
xcodebuild -project Brink.xcodeproj -scheme Brink -configuration Debug -destination 'platform=macOS,arch=arm64' build
```

主要入口：

- `Brink.xcodeproj`
- `project.yml`
- `Sources/BrinkApp`
- `Resources`

本地化资源：

- `Resources/en.lproj/Localizable.strings`
- `Resources/zh-Hans.lproj/Localizable.strings`
- `Sources/BrinkApp/Localization.swift`

本地数据位置：

- `~/Library/Application Support/Brink/tasks.json`

### 文档导航

- [README.md](README.md): 项目门面、实现状态与使用说明
- [ROADMAP.md](ROADMAP.md): 阶段路线、里程碑与版本节奏
- [ARCHITECTURE.md](ARCHITECTURE.md): 技术架构、模块与数据模型
- [PRD.md](PRD.md): 产品需求、用户场景与验收标准
- [docs/product/risk-model.md](docs/product/risk-model.md): 风险等级、排序与尺寸规则
- [docs/design/visual-semantics.md](docs/design/visual-semantics.md): 颜色语义与组件视觉规则
- [docs/design/lofi-wireframes.md](docs/design/lofi-wireframes.md): 主视图、组件与编辑面板草图
- [docs/macos-dev-environment.md](docs/macos-dev-environment.md): macOS 开发环境搭建

### 当前目录结构

当前仓库已经包含可运行的 macOS 原型：

```text
Brink/
- README.md
- ROADMAP.md
- ARCHITECTURE.md
- PRD.md
- Brink.xcodeproj
- project.yml
- Sources/
- Resources/
- scripts/
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

1. 使用 [docs/macos-dev-environment.md](docs/macos-dev-environment.md) 完成环境准备
2. 运行 `./scripts/generate-xcodeproj.sh`
3. 打开 `Brink.xcodeproj`
4. 先验证任务录入、排序、导出导入和通知权限

---

## English

### Overview

Brink is a `local-first` macOS desktop tool for deadline visualization.  
It is not trying to be another full-featured task manager. Instead, it focuses on a narrower but higher-frequency problem:

**keeping the most dangerous, nearest-deadline task visible at all times.**

Brink turns deadline pressure into glanceable signals through a persistent desktop list, blue-to-red urgency mapping, green linked-completion markers, size-adaptive widget views, notifications, and lightweight entry points.

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
- focus on the single riskiest item in `1x1` compact mode
- adapt `2x1` and `2x2+` surfaces to show urgency-sorted deadline information
- carry the same deadline semantics across desktop, widget, and notification surfaces

### MVP Scope

The first release focuses on the smallest usable loop:

- local task storage
- parent-child task hierarchy
- `effectiveDue` based ordering
- desktop primary view with horizontal risk bars
- `1x1` compact view with a single circular countdown indicator
- `2x1` widget mode with the most urgent items that fit
- `2x2+` widget mode with a scrollable urgency list
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

### Current Implementation Status

The repository now includes a locally buildable `macOS SwiftUI` prototype instead of documents only.

Implemented today:

- `Brink.xcodeproj` app project and `xcodegen` config
- primary window and menu bar entry
- local task `CRUD`
- parent-child task hierarchy
- `effectiveDue` ordering
- local JSON persistence
- `JSON/CSV` import and export
- local notification scheduling entry points
- English and Simplified Chinese UI copy

Validated locally:

- app launch
- create root task
- create child task
- delete child task
- edit task title and persist it
- export `JSON`
- import the exported `JSON`

Still in progress:

- collapsible tree UI
- more robust notification policy
- Widget implementation
- migration from JSON storage to `SQLite + GRDB`
- Apple Reminders integration

### Local Development

Prepare the machine:

```bash
./scripts/setup-macos-dev.sh
```

Generate the Xcode project:

```bash
./scripts/generate-xcodeproj.sh
```

Build from the command line:

```bash
xcodebuild -project Brink.xcodeproj -scheme Brink -configuration Debug -destination 'platform=macOS,arch=arm64' build
```

Main entry points:

- `Brink.xcodeproj`
- `project.yml`
- `Sources/BrinkApp`
- `Resources`

Localization resources:

- `Resources/en.lproj/Localizable.strings`
- `Resources/zh-Hans.lproj/Localizable.strings`
- `Sources/BrinkApp/Localization.swift`

Local data path:

- `~/Library/Application Support/Brink/tasks.json`

### Docs

- [README.md](README.md): project front page, implementation status, and usage notes
- [ROADMAP.md](ROADMAP.md): phases, milestones, and release path
- [ARCHITECTURE.md](ARCHITECTURE.md): system architecture and technical decisions
- [PRD.md](PRD.md): product requirements, scenarios, and acceptance criteria
- [docs/product/risk-model.md](docs/product/risk-model.md): risk levels, ordering, and size rules
- [docs/design/visual-semantics.md](docs/design/visual-semantics.md): color semantics and component behavior
- [docs/design/lofi-wireframes.md](docs/design/lofi-wireframes.md): lo-fi layouts for main and compact surfaces
- [docs/macos-dev-environment.md](docs/macos-dev-environment.md): local macOS development setup

### Current Directory Structure

The repository now includes a runnable macOS prototype:

```text
Brink/
- README.md
- ROADMAP.md
- ARCHITECTURE.md
- PRD.md
- Brink.xcodeproj
- project.yml
- Sources/
- Resources/
- scripts/
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
