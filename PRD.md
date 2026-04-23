# Brink PRD

[中文](#中文) | [English](#english)

## 中文

### 1. 产品概述

Brink 是一个面向 macOS 的 deadline 风险可视化工具，用于帮助 deadline 敏感型用户持续看到“最需要现在处理的任务”。

### 2. 背景问题

用户并不总是缺少任务管理能力，更多时候缺少的是：

- 截止风险的持续暴露
- 在复杂任务层级中快速发现真正最紧急事项
- 在不打开完整任务系统的情况下快速感知压力变化

### 3. 目标用户

核心用户：

- 独立开发者
- 设计师
- 学生
- 内容创作者
- 同时推进多个 deadline 的知识工作者

典型特征：

- 使用 macOS
- 经常同时处理多个项目
- 对“快到期”和“已经逾期”非常敏感
- 不一定愿意长期维护复杂 GTD 系统

### 4. 核心价值主张

Brink 帮用户解决的不是“怎么记录更多任务”，而是：

**怎么让最危险的任务不从眼前消失。**

### 5. 用户场景

#### 场景 A：桌面快速扫视

用户刚回到电脑前，希望在 3 秒内知道今天最危险的任务是什么。

系统应：

- 自动展示最紧急任务
- 用颜色与剩余时间提示风险程度
- 不要求用户先进入复杂项目视图

#### 场景 B：多层级项目管理

用户在一个父项目下管理多个子任务，需要既保留结构，又不遗漏最早到期项。

系统应：

- 保留树形层级
- 允许父任务继承最早子任务风险
- 提供紧急优先与严格树形两种模式

#### 场景 C：临近到期提醒

用户处于专注工作中，不希望被频繁打断，但希望在风险真正上升时收到提醒。

系统应：

- 在关键阈值提醒
- 在逾期时触发单独提醒
- 避免重复轰炸

#### 场景 D：从已有系统迁移

用户已经有 Apple Reminders 或表格中的任务，希望快速导入开始使用。

系统应：

- 支持 `JSON/CSV` 导入
- 预留 Apple Reminders 接入口
- 明确告知导入后的字段映射和限制

### 6. 功能需求

#### P0 必须具备

- 创建、编辑、完成、删除任务
- 支持父子任务
- 支持截止日期
- 支持折叠/展开层级
- 支持按 `effectiveDue` 排序
- 主视图横向风险条显示
- 紧凑模式单任务环形显示
- 菜单栏入口
- 本地通知
- 本地持久化

#### P1 应该具备

- `JSON/CSV` 导入导出
- 视图切换
- Apple Reminders 基础导入
- 基础筛选
- Widget 显示

#### P2 可延后

- 双向同步
- 高级统计
- 自动化入口
- 快捷指令
- 跨端能力

### 7. 关键交互规则

#### 排序规则

- 默认按 `effectiveDue` 升序
- 父任务的 `effectiveDue` 取自身和所有未完成后代中的最小值
- 展开后保留子树结构，不在局部再次做全局打散

#### 风险显示规则

- 长条不是完成百分比
- 长条用于相对比较
- 颜色用于表达风险等级
- 文本显示具体剩余时间

#### 紧凑模式规则

- 只显示单一最危险任务
- 不显示多个任务平均值
- 保持与主视图相同的颜色逻辑

### 8. 非功能需求

- 启动后可快速进入主视图
- 核心功能离线可用
- 在中小规模任务集下保持流畅
- Widget 与主 App 数据语义一致
- 通知行为可预期且可控制

### 9. 成功指标

早期以产品信号为主，不以下载量为主：

- 用户是否每天多次打开或查看 Brink
- 是否持续保留桌面或菜单栏入口
- 是否能在短时间内找到当前最高风险任务
- 是否愿意导入现有任务并保留使用

### 10. 非目标

- 不做团队协作
- 不做通用项目管理平台
- 不做复杂时间块和日程规划工具
- 不在 MVP 阶段追求全平台同步

### 11. MVP 验收标准

- 用户可在首次使用 5 分钟内创建或导入任务
- 系统能稳定计算并显示最危险任务
- 树形结构与风险排序不会互相破坏
- 菜单栏和主视图均可快速访问关键信息
- 断网状态下核心流程可用

### 12. 开放问题

- 风险阈值应固定还是允许用户自定义
- Apple Reminders 初期应采用一次性导入还是受控同步
- 紧凑模式是否需要支持多个尺寸等级
- 是否需要在 MVP 中引入 start date 参与风险计算

---

## English

### 1. Product Overview

Brink is a macOS deadline-risk visualization tool designed to keep the most urgent task continuously visible for deadline-sensitive users.

### 2. Problem

Users often do not lack task-management tools. What they lack is:

- continuous exposure to deadline risk
- a fast way to identify the true urgent item inside nested task structures
- a glanceable pressure signal without opening a full task system

### 3. Target Users

Core users:

- solo developers
- designers
- students
- content creators
- knowledge workers juggling multiple deadlines

### 4. Value Proposition

Brink does not primarily solve "how do I record more tasks?"  
It solves:

**how do I keep the most dangerous task from disappearing from view?**

### 5. User Scenarios

#### Scenario A: Desktop glance

The user returns to their Mac and wants to know the single riskiest task within three seconds.

#### Scenario B: Hierarchical projects

The user needs parent-child task structure without losing the earliest deadline signal.

#### Scenario C: Escalation reminders

The user wants reminders when risk materially increases, not constant interruptions.

#### Scenario D: Migration from existing tools

The user wants to import tasks from Apple Reminders or structured files and start quickly.

### 6. Functional Requirements

#### P0 Must Have

- create, edit, complete, and delete tasks
- parent-child tasks
- due dates
- collapse and expand hierarchy
- `effectiveDue` ordering
- horizontal risk-bar primary view
- single-task circular compact mode
- menu bar entry
- local notifications
- local persistence

#### P1 Should Have

- `JSON/CSV` import and export
- view switching
- baseline Apple Reminders import
- basic filtering
- widget display

#### P2 Later

- bidirectional sync
- advanced analytics
- automation hooks
- shortcuts
- cross-device surfaces

### 7. Key Interaction Rules

#### Ordering

- default order is ascending `effectiveDue`
- parent `effectiveDue` equals the earliest unfinished due date in itself or descendants
- expanded children preserve subtree order

#### Risk Display

- bars do not represent completion percentage
- bar length supports comparison
- color communicates urgency
- text communicates exact remaining time

#### Compact Mode

- show the single riskiest task only
- do not average multiple tasks
- use the same color logic as the primary view

### 8. Non-Functional Requirements

- fast entry into the main view after launch
- offline-capable core flow
- smooth performance for small to medium task sets
- semantic consistency between widget and app
- predictable and controllable notification behavior

### 9. Success Metrics

Early success should be product-signal driven rather than download driven:

- repeated daily opens or glances
- sustained use of the desktop or menu bar surface
- quick identification of the highest-risk task
- willingness to import existing tasks and keep using Brink

### 10. Non-Goals

- team collaboration
- general project-management breadth
- complex calendar or time-block planning
- full sync-first cross-platform scope in MVP

### 11. MVP Acceptance Criteria

- a new user can create or import tasks within five minutes
- the system reliably computes and displays the riskiest task
- hierarchy and urgency ordering coexist without breaking each other
- key information is accessible from both desktop and menu bar surfaces
- the core workflow works offline

### 12. Open Questions

- should urgency thresholds be fixed or user-configurable
- should Apple Reminders start as one-time import or controlled sync
- should compact mode support multiple size classes in MVP
- should `startDate` influence urgency in MVP
