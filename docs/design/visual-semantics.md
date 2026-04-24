# Brink Visual Semantics

[中文](#中文) | [English](#english)

## 中文

### 目标

本文件定义 Brink 的视觉语言，让用户在 1 到 3 秒内理解：

- 哪个任务最危险
- 风险差异有多大
- 现在是否需要立刻行动

它不是完整视觉设计稿，而是 MVP 阶段必须稳定的语义层。

### 核心原则

- 颜色优先表达风险，不表达分类
- 长度和面积表达相对紧迫度，不表达完成度
- 文本补足精确时间，不让颜色承担全部含义
- 主视图、紧凑视图、菜单栏和 Widget 保持同一套风险语义

### 语义元素

#### 1. 颜色

建议 MVP 采用固定风险色阶：

```text
safe      -> blue
watch     -> yellow
warning   -> orange
critical  -> red
overdue   -> deep red
done-linked -> green
none      -> empty / no fill
```

语义要求：

- 蓝色表示安全，代表有 deadline 但仍处于低风险
- 红色表示高风险，不代表“高优先级标签”
- 绿色表示已完成但仍与其他任务存在依赖或关联
- 无 deadline 使用留空，不使用灰色填充制造假信号
- 已完成但无关联的任务可弱化或隐藏，不和绿色依赖完成态混淆

#### 2. 条形长度

主列表中的横向条形表示相对风险，不表示完成比例。

要求：

- 同屏任务之间可快速比较
- 越危险，条越长、越接近饱和
- 无 deadline 任务不绘制条形，保留留白

#### 3. 文本时间

每个任务都应尽量显示一条精确时间信息，例如：

- `in 2h`
- `tomorrow 09:00`
- `in 3d`
- `overdue by 5h`
- `no due date`

要求：

- 文本必须能单独成立
- 不能只靠颜色让用户猜测

#### 4. 图标与强调

MVP 不建议依赖过多图标。图标只在以下情况使用：

- 折叠/展开层级
- 已完成状态
- 通知或静默状态

危险程度不要用额外图标堆叠，以免和颜色语义冲突。

#### 5. 外观模式适配

Brink 必须同时适配浅色与深色模式，且风险语义在两种模式下保持一致。

要求：

- 风险色阶本身不因外观模式改变语义，只允许微调承载它们的背景和描边
- 面板、卡片、编辑区和列表容器应优先使用系统语义背景色，而不是写死白色或黑色透明值
- 进度条底轨、卡片描边和阴影需要根据外观模式调整对比度，避免深色模式下发灰或脏污
- 选中态仍以 accent 或风险色为主，但必须保证正文文本在深色模式下可读
- 如果使用渐变，深色模式应落在系统背景附近，不能继续沿用浅色高亮渐变

### 视图级语义

#### 主视图

目标：

- 让用户一眼扫到最危险任务
- 保留树形结构但不丢失风险排序

建议结构：

```text
[Title                          ][time remaining]
[risk bar --------------------------------------]
[optional parent path / metadata                ]
```

要求：

- 第一行优先保证任务标题和剩余时间可读
- 第二行风险条承担“快速对比”
- 元信息保持弱化，不能压过标题和时间

#### 紧凑视图

目标：

- 在最小尺寸下只承载一个信号：当前最危险任务是谁

建议结构：

```text
[circular countdown ring]
[task title]
[time remaining]
```

要求：

- 环形颜色与主视图完全一致
- 不显示多任务平均值
- 圆环表达倒计时，不表达完成率
- 文本数量严格控制，避免变成微型列表

#### 菜单栏弹层

目标：

- 用最短交互路径查看前几个高风险任务

要求：

- 顶部立即展示当前最危险任务
- 下方可展示少量候选任务
- 视觉语义与主视图一致，不引入新颜色规则

#### Widget

目标：

- 在系统桌面层面重复 Brink 的核心语义，而不是发明第二套 UI

要求：

- 只读展示
- 根据尺寸切换展示模式
- 1x1 显示单任务倒计时圆环
- 2x1 显示按紧急程度排序的少量任务，不滚动
- 2x2 及更大显示可滚动列表，允许查看全部 deadline 信息
- 保持相同颜色等级与时间文案口径

### 树形结构语义

#### 父任务

- 父任务可以因为子任务风险而显示为高风险
- 若父任务是容器型项目，可弱化其自身装饰，但不能弱化风险颜色

#### 子任务

- 展开后应在视觉上明显缩进
- 缩进表达结构，颜色表达风险，两者不要互相替代

#### 折叠状态

- 折叠时父任务应继续暴露整个子树最早风险
- 用户不需要展开才能知道危险是否存在

### 空状态与异常状态

#### 无任务

- 文案应强调“当前没有任务”，而不是展示空白表格

#### 无 deadline

- 可显示任务，但不绘制灰色条形
- 使用留白和 `no due date` 文案

#### 全部已完成

- 使用绿色仅表示“相关依赖已完成”
- 非依赖型完成任务不与“安全”蓝色混淆

#### 逾期

- 逾期任务应有最强对比度
- 时间文案直接写明 `overdue`

### 动效建议

MVP 只建议保留少量有意义动效：

- 风险级别升级时轻微过渡
- 折叠/展开时层级动画
- 紧凑视图任务切换时柔和过渡

避免：

- 高频闪烁
- 常驻脉冲
- 过强缩放或颜色跳变

### 可访问性要求

- 不能只靠颜色表达风险，必须有文字
- 红橙黄之间的差异要有足够亮度和对比度
- 主要信息在高对比度模式下仍应成立
- 字体大小应允许在桌面常驻视图中被快速扫读

### MVP 设计冻结建议

编码前至少冻结以下内容：

- 风险颜色映射
- 横向条与环形视图的语义定义
- 时间文案格式
- 已完成与无日期任务的视觉区分
- 父子层级的缩进和折叠表现
- 尺寸变化时的展示切换规则

---

## English

### Goal

This document defines Brink's visual language so users can understand within a glance:

- which task is most dangerous
- how risk levels compare
- whether immediate action is needed

### Principles

- color expresses risk, not category
- length and area express relative urgency, not completion
- text provides exact timing
- the same semantics must carry across app, menu bar, compact view, and widget

### Risk Colors

```text
safe      -> blue
watch     -> yellow
warning   -> orange
critical  -> red
overdue   -> deep red
done-linked -> green
none      -> empty / no fill
```

Green is reserved for completed items that still matter as linked dependencies. No-due tasks should appear with empty space rather than a gray risk fill.

### Appearance Modes

Brink must preserve the same risk semantics in both light and dark appearance modes.

Requirements:

- risk colors keep their meaning across appearances; only their surrounding surfaces may adapt
- panels, cards, editors, and list containers should prefer system semantic background colors over hard-coded white or black opacity values
- progress tracks, borders, and shadows must tune contrast for dark mode so surfaces do not look muddy
- selected states can still use accent or risk tint, but text contrast must remain readable in dark mode
- gradients used in the main view should resolve near system background tones in dark mode rather than reusing a light-only highlight wash

### Main View

Suggested row structure:

```text
[Title                          ][time remaining]
[risk bar --------------------------------------]
[optional parent path / metadata                ]
```

### Compact View

Suggested structure:

```text
[circular countdown ring]
[task title]
[time remaining]
```

Show one riskiest task only in the 1x1 compact size.

### Accessibility

- do not rely on color alone
- keep urgency readable in high contrast contexts
- make overdue states explicitly textual
