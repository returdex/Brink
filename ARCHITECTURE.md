# Brink Architecture

[中文](#中文) | [English](#english)

## 中文

### 架构目标

Brink 的技术架构应服务于三个核心原则：

- 本地优先
- 视图可快速刷新
- 桌面、菜单栏、Widget 共用同一套风险语义

### 建议技术栈

- 平台：`macOS`
- UI：`SwiftUI`
- 桌面与系统能力补充：`AppKit`
- Widget：`WidgetKit`
- 通知：`UserNotifications`
- 本地存储：MVP 期优先 `SQLite + GRDB`，必要时通过 `App Group` 共享
- 系统集成：`EventKit` 用于 Apple Reminders 研究与接入

说明：

- 不建议 MVP 以 Electron、Tauri 或 Flutter 起步
- 主要原因是 Widget、系统通知、Sandbox 适配和原生 macOS 体验要求较高
- Brink 的差异化来自系统级存在感，而不是跨端代码复用率

### 当前实现快照

当前原型实现采用：

- `SwiftUI` 作为主界面框架
- `xcodegen + Xcode project` 维护工程配置
- 本地 `JSON` 文件持久化到 `Application Support`
- `UserNotifications` 用于本地提醒调度入口

当前代码位置：

- `Sources/BrinkApp`
- `Resources`
- `project.yml`

说明：

- 文档里提到的 `SQLite + GRDB` 仍然是推荐的下一步演进方向
- 当前 `JSON` 存储用于加速 MVP 原型验证和本机实验

### 顶层模块

#### 1. App Shell

职责：

- 生命周期管理
- 窗口与场景协调
- 权限请求
- 全局设置注入

#### 2. Task Domain

职责：

- 任务实体定义
- 层级关系维护
- `effectiveDue` 计算
- 排序、过滤、折叠规则

#### 3. Persistence Layer

职责：

- 任务持久化
- 查询和索引
- 导入导出
- 数据迁移

当前实现：

- 使用 `tasks.json` 保存任务树
- 已支持 `JSON/CSV` 导入导出
- 尚未切换到 `SQLite + GRDB`

#### 4. Urgency Engine

职责：

- 将截止时间映射为风险等级
- 生成颜色语义
- 生成主视图条长、`1x1` 倒计时环形数据和多尺寸组件展示模型
- 为通知触发提供判断依据

#### 5. Presentation Layer

职责：

- 主视图列表
- 紧凑视图
- 菜单栏弹层
- Widget 展示模型

#### 6. Integration Layer

职责：

- Apple Reminders 接入
- 文件导入导出
- 后续 Shortcuts / URL Scheme / Automation 扩展

### 数据模型草案

#### Task

建议最小字段：

```text
Task
- id: UUID
- parentID: UUID?
- title: String
- notes: String?
- sortIndex: Int
- dueDate: Date?
- startDate: Date?
- priority: Int?
- status: TaskStatus
- isCollapsed: Bool
- manualColor: String?
- linkedTaskIDs: [UUID]?
- source: TaskSource
- createdAt: Date
- updatedAt: Date
```

#### 派生字段

```text
effectiveDue = min(self.dueDate, descendants.dueDate)
```

说明：

- 父任务排序不只看自身截止时间，也要看未完成后代任务中的最早截止时间
- 这让树形结构与风险优先排序可以同时成立
- 已完成但仍被其他任务引用的任务需要额外保留可见状态

### 排序策略

默认策略建议为：

1. 父任务按 `effectiveDue` 排序
2. 同级任务按 `effectiveDue` 升序
3. 展开节点时保留树形顺序，不在子层级内做二次全局打散
4. 提供两种视图模式：`Urgency-first` 与 `Strict hierarchy`

### 风险语义

Brink 不应把主条形图定义为“完成百分比”，而应定义为“剩余时间风险可视化”。

建议：

- 长度用于相对比较
- 颜色用于表达紧迫度
- 文本用于表达精确剩余时间

建议风险分层：

- Blue: 安全
- Yellow: 需要关注
- Orange: 接近风险
- Red: 高风险 / 逾期
- Green: 已完成但仍关联的依赖内容
- Empty: 无 deadline，不绘制风险填充

组件尺寸语义建议：

- `1x1`: 单任务倒计时环
- `2x1`: 不滚动的最紧急任务短列表
- `2x2+`: 可滚动的完整 deadline 列表

### Widget 与主 App 的关系

建议共享：

- 任务只读快照
- `effectiveDue`
- 任务状态
- 颜色等级
- 组件尺寸对应的展示模式

建议方式：

- 主 App 作为唯一写入口
- Widget 从共享存储读取裁剪后的视图数据
- 不让 Widget 直接承担复杂写操作

### 通知策略

通知不是简单的到点提醒，而是风险升级机制的一部分。

建议规则：

- 首次接近截止时提醒
- 逾期时单独提醒
- 短期内避免重复轰炸
- 支持按任务静默或全局节流

### 集成边界

Apple Reminders 接入建议为渐进式：

1. 先做只读导入或一次性导入
2. 再做受控同步
3. 最后评估双向同步

原因：

- Reminders 的数据模型未必与 Brink 的风险语义完全对齐
- 若过早以第三方系统为核心，会反向污染本地模型设计

### 风险与取舍

#### 风险 1：SwiftData 在 Widget 共享和 schema 演化上的不确定性

建议：MVP 优先使用 `SQLite + GRDB`，避免后续共享与迁移受限。

#### 风险 2：树形结构与风险排序冲突

建议：使用 `effectiveDue` 统一父节点排序语义，并提供双视图模式。

#### 风险 3：把产品做成“大而全待办”

建议：所有架构决策都应优先支持“可视化风险前端”这一定位。

---

## English

### Architecture Goals

Brink's architecture should serve three core principles:

- local-first behavior
- fast view refresh
- one urgency model shared by desktop, menu bar, and widget surfaces

### Recommended Stack

- Platform: `macOS`
- UI: `SwiftUI`
- System-level desktop integration: `AppKit`
- Widget: `WidgetKit`
- Notifications: `UserNotifications`
- Local persistence: prefer `SQLite + GRDB` for MVP, with `App Group` sharing when needed
- System integration: `EventKit` for Apple Reminders exploration

Notes:

- Electron, Tauri, or Flutter are not recommended as the MVP starting point
- Widget support, notifications, sandboxing, and native desktop presence matter more than cross-platform reuse

### Top-Level Modules

#### 1. App Shell

- lifecycle management
- scene and window coordination
- permission requests
- settings injection

#### 2. Task Domain

- task entity definitions
- hierarchy maintenance
- `effectiveDue` computation
- sorting, filtering, and collapse rules

#### 3. Persistence Layer

- persistence
- querying and indexing
- import/export
- migrations

#### 4. Urgency Engine

- map due dates to urgency levels
- produce color semantics
- feed primary bars, `1x1` countdown rings, and larger size-class list presentations
- support notification triggers

#### 5. Presentation Layer

- primary list view
- compact view
- menu bar popover
- widget display models

#### 6. Integration Layer

- Apple Reminders integration
- file import/export
- future Shortcuts, URL Scheme, and automation hooks

### Draft Data Model

#### Task

```text
Task
- id: UUID
- parentID: UUID?
- title: String
- notes: String?
- sortIndex: Int
- dueDate: Date?
- startDate: Date?
- priority: Int?
- status: TaskStatus
- isCollapsed: Bool
- manualColor: String?
- source: TaskSource
- createdAt: Date
- updatedAt: Date
```

#### Derived Field

```text
effectiveDue = min(self.dueDate, descendants.dueDate)
```

This allows parent items to carry descendant urgency without destroying hierarchy.

### Ordering Strategy

Recommended default behavior:

1. sort parent items by `effectiveDue`
2. sort peers by `effectiveDue`
3. preserve tree order within expanded children
4. support two view modes: `Urgency-first` and `Strict hierarchy`

### Urgency Semantics

Brink should not present the main bar as completion percentage.  
It should present a remaining-time risk visualization.

Recommended mapping:

- length for relative comparison
- color for urgency
- text for exact time remaining

Recommended color semantics:

- Blue: safe
- Yellow: watch
- Orange: warning
- Red: critical or overdue
- Green: completed but still relevant linked dependency
- Empty: no due date, no risk fill

Recommended size behavior:

- `1x1`: one riskiest task with a countdown ring
- `2x1`: a non-scrollable urgency list of the items that fit
- `2x2+`: a scrollable deadline list that preserves urgency ordering

### Widget Relationship

Suggested approach:

- the main app is the single write authority
- the widget reads trimmed shared snapshots
- the widget should not be responsible for complex writes
- the widget should switch presentation by size class without changing urgency ordering

### Notification Strategy

Notifications are part of risk escalation, not just alarms.

Recommended rules:

- notify on first meaningful urgency threshold
- notify separately on overdue transition
- avoid repeated short-window spam
- support per-task silence and global throttling

### Integration Boundary

Apple Reminders should be integrated progressively:

1. read-only or one-time import first
2. controlled sync second
3. bidirectional sync only if justified later

### Risks and Tradeoffs

- `SwiftData` may be less predictable for widget sharing and schema evolution in this use case
- hierarchy and urgency sorting naturally conflict without `effectiveDue`
- the project can drift into a generic task app if the architecture stops reinforcing the risk-visualization core
