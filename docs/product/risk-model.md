# Brink Risk Model

[中文](#中文) | [English](#english)

## 中文

### 目标

本文件把 Brink 的 `deadline risk` 规则从概念描述收敛为可实现、可验证、可复用的产品规格。

它服务于三个场景：

- 任务列表排序
- 主视图与紧凑视图的风险表达
- 通知触发与节流判断

### 设计原则

- 以 `dueDate` 为主，不在 MVP 阶段把模型做复杂
- 用同一套派生字段支撑列表、菜单栏、Widget 和通知
- 先保证“稳定可解释”，再追求“高度智能”
- 允许未来扩展 `startDate`、用户自定义阈值和更细分风险算法

### 输入字段

MVP 期风险计算只依赖下列字段：

```text
Task
- dueDate: Date?
- status: TaskStatus
- parentID: UUID?
- isCollapsed: Bool
- createdAt: Date
- updatedAt: Date
```

说明：

- `startDate` 在 MVP 中不参与风险计算
- 已完成任务不参与父任务 `effectiveDue` 计算
- 没有 `dueDate` 的任务视为“无 deadline”，默认排在所有有 deadline 的任务之后
- 已完成但仍被其他未完成任务引用的任务不会消失，而是作为依赖完成指示保留显示

### 核心派生字段

#### 1. effectiveDue

定义：

```text
effectiveDue(task) =
  min(task.dueDate, all incomplete descendants' dueDate)
```

规则：

- 若任务自身没有 `dueDate`，则只看未完成后代
- 若任务与其未完成后代都没有 `dueDate`，则 `effectiveDue = nil`
- 已完成后代不参与计算
- 已完成父任务默认不出现在主风险列表中

#### 2. timeRemaining

定义：

```text
timeRemaining = effectiveDue - now
```

规则：

- 以系统当前时间为基准，实时或按刷新周期重新计算
- 若 `effectiveDue = nil`，则 `timeRemaining = nil`
- 逾期任务会得到负值

#### 3. riskLevel

MVP 建议采用固定阈值离散分层：

```text
if task is completed and referenced        -> done-linked
if effectiveDue == nil                     -> none
if timeRemaining <= 0h                     -> overdue
if timeRemaining <= 24h                    -> critical
if timeRemaining <= 72h                    -> warning
if timeRemaining <= 168h (7d)              -> watch
else                                       -> safe
```

分层说明：

- `done-linked`: 已完成但仍作为依赖关系中的已完成节点显示
- `none`: 无 deadline，不参与高风险颜色排序
- `overdue`: 已逾期
- `critical`: 24 小时内到期
- `warning`: 3 天内到期
- `watch`: 7 天内到期
- `safe`: 7 天以后

这样做的原因：

- 用户容易理解
- 便于通知阈值复用
- 在 MVP 阶段比连续评分更可预测

#### 4. urgencyRank

用于排序的主键建议为：

```text
1. status != completed
2. effectiveDue ascending, nil last
3. riskLevel severity descending as tie helper
4. sortIndex ascending
5. createdAt ascending
```

说明：

- 实际排序核心仍然是 `effectiveDue`
- `riskLevel` 只作为补充，不应该反向覆盖 `effectiveDue`
- `sortIndex` 保留手动顺序能力
- `done-linked` 项默认排在所有未完成任务之后，但在所属依赖上下文中保持可见

### 父子任务规则

#### 父任务风险继承

- 父任务颜色与风险等级默认继承其 `effectiveDue`
- 这意味着父任务可能因为子任务临近截止而显示为高风险，即使自己没有 `dueDate`
- 该规则适用于主视图、菜单栏和 Widget

#### 展开规则

- 顶层父任务按 `effectiveDue` 排序
- 展开后保持树形结构，不在子树内部再次做全局重排
- 子节点可按各自 `effectiveDue` 在同层内部升序展示

#### 严格层级模式

作为后续视图模式预留：

- 任务先按父子层级组织
- 风险只影响颜色和辅助提示
- 不改变树根层级的原始手动顺序

MVP 默认主模式仍应为 `Urgency-first`

### 已完成依赖任务规则

- 已完成任务默认可以从主风险序列中退出
- 若该任务仍被其他未完成任务引用、依赖或关联，则应继续显示
- 此类任务使用 `done-linked` 语义，而不是 `safe`
- 颜色使用绿色，用于表达“相关事项已完成，可作为依赖完成指示”
- 这类任务仍可保留标题、关联关系说明和完成状态，但不应继续参与最紧急内容竞争

### 主视图条形规则

Brink 的横向条形不是完成百分比，而是风险可视化。

MVP 建议：

- 颜色表达风险等级或依赖完成状态
- 文本表达具体剩余时间
- 长度表达相对紧迫程度，但只在当前可见列表内做比较

建议长度映射：

```text
overdue     -> 100%
critical    -> 88-100%
warning     -> 64-87%
watch       -> 36-63%
safe        -> 12-35%
done-linked -> 12%
none        -> 0%
```

说明：

- 不要求精确线性映射
- 保持视觉上“越危险越接近满条”即可
- `none` 任务默认不渲染风险条，保留留白
- `done-linked` 任务可以使用很短的绿色指示条或绿色状态标记

### 组件尺寸规则

Brink 的组件需要内建尺寸自适应能力。

#### 1x1

- 使用圆环视图
- 只显示单一最危险任务
- 圆环表达倒计时进度与风险状态
- 适合最小正方形桌面组件

#### 2x1

- 使用横向列表视图
- 只按最紧急内容排序显示当前能容纳的少量任务
- 不提供滚动，优先保证一眼扫读

#### 2x2 及更大

- 使用可滚动列表视图
- 默认仍按最紧急内容排序
- 用户可通过鼠标滚动查看全部 deadline 信息
- 更大尺寸只增加可见信息量，不改变核心排序语义

### 紧凑视图规则

- 只显示单一最危险任务
- 选择规则与主列表第一项一致
- 使用与主视图相同的 `riskLevel` 颜色
- 1x1 组件中的圆环表达倒计时进度，不表达任务完成度
- 若没有任何带 deadline 的未完成任务，则显示“无临近 deadline”空状态

### 通知规则

通知应由风险升级触发，而不是简单到点提醒。

MVP 建议阈值：

- 进入 `watch` 时可选提醒一次
- 进入 `warning` 时提醒一次
- 进入 `critical` 时提醒一次
- 进入 `overdue` 时提醒一次

节流规则：

- 同一任务在同一风险级别内不重复提醒
- 默认 6 小时内不对同一任务发送第二条升级外提醒
- 若用户手动标记静默，则不再提醒该任务

### 边界案例

#### 案例 1：父任务无日期，子任务有日期

- 父任务 `effectiveDue` 继承最早子任务日期
- 父任务进入风险排序

#### 案例 2：父任务日期晚于子任务

- 父任务 `effectiveDue` 取更早的子任务日期
- 父任务显示更高风险，避免隐藏真实压力

#### 案例 3：子任务全部完成

- 父任务重新只看自身 `dueDate`
- 若自身也无日期，则 `effectiveDue = nil`

#### 案例 4：无日期任务很多

- 仍排在所有有 `effectiveDue` 的未完成任务之后
- 默认不显示风险条，留空显示

#### 案例 5：任务已完成但存在依赖关系

- 任务不会消失
- 使用绿色完成指示
- 不参与未完成任务的最紧急排序

#### 案例 6：多个任务同一截止时间

- 按 `sortIndex` 和 `createdAt` 稳定打破平局
- 避免 UI 顺序频繁跳动

### MVP 冻结建议

进入编码前，建议把以下内容视为 v1 风险基线：

- `effectiveDue` 的定义
- 蓝色安全、绿色依赖完成、无日期留空不填充的颜色规则
- 固定时间阈值
- `Urgency-first` 为默认排序模式
- 组件按尺寸切换展示模式
- 通知由风险升级驱动

### 待后续验证的问题

- 是否允许用户自定义风险阈值
- `startDate` 是否应参与排序或仅参与提醒
- 条形长度是否需要更连续的映射公式
- 是否要给“今天到期”和“已逾期”单独更强视觉区分

---

## English

### Goal

This document turns Brink's `deadline risk` concept into an implementable, testable specification.

It supports three surfaces:

- task ordering
- risk presentation in the main and compact views
- notification triggers and throttling

### Principles

- keep MVP centered on `dueDate`
- reuse one derived model across app, menu bar, widget, and notifications
- optimize for stable and explainable behavior before cleverness

### Inputs

MVP risk computation depends on:

```text
Task
- dueDate: Date?
- status: TaskStatus
- parentID: UUID?
- isCollapsed: Bool
- createdAt: Date
- updatedAt: Date
```

### Derived Fields

#### effectiveDue

```text
effectiveDue(task) =
  min(task.dueDate, all incomplete descendants' dueDate)
```

Completed descendants are excluded. If neither the task nor its incomplete descendants have a due date, `effectiveDue = nil`.

#### timeRemaining

```text
timeRemaining = effectiveDue - now
```

#### riskLevel

```text
if task is completed and referenced        -> done-linked
if effectiveDue == nil                     -> none
if timeRemaining <= 0h                     -> overdue
if timeRemaining <= 24h                    -> critical
if timeRemaining <= 72h                    -> warning
if timeRemaining <= 168h (7d)              -> watch
else                                       -> safe
```

#### urgencyRank

```text
1. status != completed
2. effectiveDue ascending, nil last
3. riskLevel severity descending as tie helper
4. sortIndex ascending
5. createdAt ascending
```

### Parent-Child Rules

- parents inherit risk from the earliest incomplete descendant
- top-level parents sort by `effectiveDue`
- expanded trees preserve structure instead of globally reshuffling descendants

### Main View

- bar color expresses risk level
- text expresses exact remaining time
- bar length expresses relative urgency, not completion

Suggested width bands:

```text
overdue     -> 100%
critical    -> 88-100%
warning     -> 64-87%
watch       -> 36-63%
safe        -> 12-35%
done-linked -> 12%
none        -> 0%
```

### Compact View

- show exactly one riskiest task in the 1x1 compact surface
- selection must match the first item in the main urgency list
- use the same risk colors as the main view

### Size Rules

- `1x1`: circular countdown ring for the single riskiest task
- `2x1`: non-scrollable urgency list showing only the most urgent items that fit
- `2x2` and larger: scrollable urgency list that lets users browse all deadline items

### Notifications

Notifications should be triggered by risk escalation:

- optional once on entering `watch`
- once on entering `warning`
- once on entering `critical`
- once on entering `overdue`

Throttle rules:

- do not repeat within the same level
- default minimum repeat interval: 6 hours for the same task

### Open Questions

- should users customize thresholds
- should `startDate` affect ordering later
- should bars adopt a more continuous formula
