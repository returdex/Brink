# Brink Low-Fidelity Wireframes

[中文](#中文) | [English](#english)

## 中文

### 目标

本文件用低保真方式定义 Brink MVP 的四个核心界面，帮助我们在编码前验证信息架构、风险优先排序和层级结构是否成立。

低保真的重点不是美术，而是回答：

- 用户回到电脑前第一眼看什么
- 风险和层级如何同时存在
- 哪些信息必须常驻可见
- 哪些交互可以延后

### 视图 1：桌面主视图

用途：

- 常驻显示风险列表
- 支持快速扫视与进入详细编辑

草图：

```text
+--------------------------------------------------------------+
| Brink                                                        |
| Sort: Urgency-first        Filter: Open only                 |
|--------------------------------------------------------------|
| > Launch v1 landing page                          in 5h       |
|   [███████████████████████████████████████-----] critical    |
|   Project Alpha                                              |
|--------------------------------------------------------------|
| v Release prep                                    tomorrow   |
|   [██████████████████████████████--------------] warning     |
|     > QA checklist                                 in 18h    |
|       [██████████████████████████████████--------] critical  |
|     > App Store copy                               in 2d     |
|       [██████████████████████--------------------] warning   |
|--------------------------------------------------------------|
| > Backend schema migrated                         done-link  |
|   [████------------------------------------------] complete  |
|--------------------------------------------------------------|
| > Inbox cleanup                                   no due     |
|                                                    none      |
+--------------------------------------------------------------+
```

验证点：

- 第一屏能否立刻看出最危险任务
- 父任务是否既保留结构又暴露子任务风险
- 无日期任务是否自然退后但仍可见
- 依赖型完成任务是否能保留但不抢占注意力

必须元素：

- 标题
- 排序模式
- 任务标题
- 剩余时间
- 风险条
- 折叠/展开入口

可后置元素：

- 多条件筛选
- 拖拽重排
- 标签系统

### 视图 2：紧凑环形视图

用途：

- 以 1x1 最小正方形占位持续显示当前最危险任务

草图：

```text
+----------------------+
|      (██████████)    |
|                      |
|  Launch v1 landing   |
|  due in 5h           |
|  critical            |
+----------------------+
```

验证点：

- 在最小尺寸下是否仍能看懂
- 环形是否被正确理解为倒计时与风险，而非完成度
- 文案是否足够短但仍有效

必须元素：

- 环形风险信号
- 单一任务标题
- 剩余时间

不要加入：

- 多任务列表
- 复杂操作按钮
- 统计汇总

### 视图 3：2x1 横向组件

用途：

- 在更宽但较矮的组件中显示最紧急的少量任务

草图：

```text
+-----------------------------------------------+
| Brink                                         |
| Launch v1 landing page            in 5h       |
| QA checklist                      in 18h      |
| App Store copy                    in 2d       |
+-----------------------------------------------+
```

验证点：

- 是否只显示“当前最该看”的内容就足够
- 不可滚动时，信息密度是否合适
- 排序是否始终与主视图一致

### 视图 4：2x2 及更大组件

用途：

- 在更大尺寸中允许查看全部 deadline 信息

草图：

```text
+-----------------------------------------------+
| Brink                                         |
| Launch v1 landing page            in 5h       |
| QA checklist                      in 18h      |
| App Store copy                    in 2d       |
| Release prep                      tomorrow    |
| Inbox cleanup                     no due      |
|                         scroll for more v     |
+-----------------------------------------------+
```

验证点：

- 滚动是否足够自然
- 更大组件是否只扩展信息量，而不引入第二套排序逻辑
- 无 deadline 项是否以留白弱化

### 视图 5：菜单栏弹层

用途：

- 快速查看风险，不打断当前工作
- 作为进入主应用和快速新建的入口

草图：

```text
+-------------------------------------------+
| Brink                         + New Task   |
|-------------------------------------------|
| Most urgent                                |
| Launch v1 landing page        in 5h        |
| [███████████████████████████] critical     |
|-------------------------------------------|
| Next                                       |
| QA checklist                    in 18h     |
| App Store copy                  in 2d      |
| Release prep                    tomorrow   |
|-------------------------------------------|
| Open App            Notifications: On      |
+-------------------------------------------+
```

验证点：

- 是否能在 5 秒内看完关键信息
- 是否需要展示前 3 个任务而不是更多
- 快速新建是否足够轻量

### 视图 6：任务编辑面板

用途：

- 支撑最基本的任务创建与修改
- 不让数据录入复杂度破坏核心体验

草图：

```text
+-------------------------------------------+
| Edit Task                                  |
|-------------------------------------------|
| Title                                      |
| [Launch v1 landing page                ]   |
|                                            |
| Notes                                      |
| [Optional notes...                     ]   |
|                                            |
| Due Date                                   |
| [2026-04-25 18:00]                         |
|                                            |
| Parent                                     |
| [Project Alpha                        v]   |
|                                            |
| Status                                     |
| [Open                                v]    |
|                                            |
| Cancel                        Save         |
+-------------------------------------------+
```

验证点：

- 是否足够快录入一个带截止时间的任务
- 父子结构选择是否清晰
- 是否需要在 MVP 里暴露更多字段

MVP 建议只保留下列字段：

- title
- notes
- dueDate
- parent
- status

建议暂缓字段：

- startDate
- manualColor
- 自定义风险阈值
- 高级重复规则

### 关键用户流

#### Flow A：首次录入任务

```text
Open App
-> Create Task
-> Set due date
-> Save
-> Return to main list
-> Task appears in urgency order
```

#### Flow B：父任务暴露子任务风险

```text
Open list
-> See parent project near top
-> Expand project
-> Confirm the earliest child is causing the risk
```

#### Flow C：桌面扫视后进入处理

```text
Glance at desktop view
-> Identify top risk task
-> Click item
-> Open edit/detail
-> Mark complete or adjust due date
```

### 评审时需要回答的问题

- 主视图默认是否足够清晰，不需要 onboarding 就能理解
- 父子任务在风险优先排序中是否会让人迷惑
- 1x1 圆环是否太像完成环，需要额外文案校正
- 2x1 和 2x2 的尺寸切换是否足够自然
- 菜单栏弹层是否应该支持快速完成操作

### 下一步建议

在低保真评审通过后，再进入：

1. 中保真布局稿
2. 颜色与文案规范冻结
3. SwiftUI 信息架构实现
4. 数据模型与持久化落地

---

## English

### Goal

This document defines four low-fidelity MVP screens to validate Brink's information architecture before implementation.

### Core Screens

1. Desktop primary view with urgency-sorted task list
2. `1x1` compact circular countdown view
3. `2x1` urgency-only compact list
4. `2x2+` scrollable deadline list
5. Menu bar popover with quick glance access
6. Task edit panel for lightweight CRUD

### Validation Questions

- can users identify the top-risk task at a glance
- can hierarchy and urgency coexist without confusion
- does compact mode still read as risk instead of completion
- is task entry lightweight enough for frequent use
