# TailTopia · Icon System V1.0.0

**产品**：TailTopia 宠物社区 App  
**平台**：React Native (iOS + Android)  
**创建**：2026-06-15  
**状态**：已锁定，可进入实现阶段

---

## 一、图标库

**选用：Phosphor Icons**（`phosphor-react-native`）

```bash
npm install phosphor-react-native
```

选型理由：Phosphor 是唯一在同一图标集内同时提供 `regular`（轮廓线）和 `fill`（填充）两种变体的主流库，且两种形态路径完全对齐，保证 inactive → active 状态切换时视觉锚点稳定，不跳形。

---

## 二、设计语言

### 核心方向

| 维度 | 定义 |
|---|---|
| 线条流（默认态） | 轮廓线图标，内部不填充，强调空气感与呼吸感 |
| 填充流（激活态） | 实心填充图标，与 Pop Art 错位套色配合 |
| 风格参照 | 新粗野主义（Neo-Brutalism）—— 冷淡、克制、带张力的错位感 |
| 错位手法 | Pop Art 丝网印刷套色偏位 —— 双层叠加，下层色块向右下偏移 3px |

### 风格原则

- 图标系统内只使用**一种描边风格**（Phosphor regular，1.5px 等效描边），不混用粗细
- 错位偏移色**全局统一**使用 `--red-500`（`#F0425A`），不随 Tab 变化
- Pop Art 效果**专属于 4 个导航 Tab**，[+] 发布按钮不参与
- 不使用 emoji 作为任何功能性图标

---

## 三、Tab Bar 图标映射

| Tab | 位置 | Inactive 图标 | Active 图标 | 需要登录 |
|---|---|---|---|---|
| 首页 | 1（最左） | `<House weight="regular" />` | `<House weight="fill" />` | 否 |
| 成长档案 | 2 | `<BookOpen weight="regular" />` | `<BookOpen weight="fill" />` | 是 |
| [+] 发布 | 3（中间） | 特殊处理，见第六节 | — | 是 |
| 问诊 | 4 | `<Stethoscope weight="regular" />` | `<Stethoscope weight="fill" />` | 是 |
| 我的 | 5（最右） | `<User weight="regular" />` | `<User weight="fill" />` | 是 |

---

## 四、Inactive 态规格（线条流）

```
图标变体:     regular（轮廓线）
尺寸:         26pt
描边粗细:     1.5px（Phosphor 库默认，不覆盖）
颜色:         --ink-700  (#544864)
不透明度:     0.55
图层结构:     单层，无偏移
```

**空气感来源**：26pt 轮廓线图标在 44pt 触摸区内保留充足负空间，0.55 透明度使图标视觉退入背景，形成轻盈悬浮感。

---

## 五、Active 态规格（填充流 + Pop Art 错位套色）

### 双层结构

容器尺寸：`32 × 32pt`，`overflow: visible`（确保偏移层不被裁切）

```
┌─────────────────────────────────┐
│  容器 32×32pt, overflow:visible │
│                                 │
│  [Layer 1] 错位偏移层 (Z-bottom) │  ← position: absolute
│    weight:    fill               │
│    size:      26pt               │
│    color:     #F0425A (red-500)  │
│    transform: translateX(+3pt)   │
│               translateY(+3pt)   │
│    opacity:   1.0                │
│                                 │
│  [Layer 2] 主体填充层 (Z-top)    │  ← position: absolute
│    weight:    fill               │
│    size:      26pt               │
│    color:     #845EC9 (violet-500│
│    transform: none               │
│    opacity:   1.0                │
└─────────────────────────────────┘
```

### 视觉效果

```
     red500 填充影 (offset +3,+3)
          ↘
          [■] ← violet500 填充主体（遮盖红色，右下角露出 3pt 红色「错位边」）
```

右下角裸露 3pt 的红色边缘模拟丝网印刷套色偏位。紫色（冷）+ 玫红（热）撞色，在新粗野主义克制框架下形成张力。

---

## 六、[+] 发布按钮规格（独立于图标系统）

[+] 是全局主 CTA，不参与线条/填充/错位逻辑，保持绝对干净以维持视觉层级。

```
形状:       圆形
直径:       56pt
背景色:     --violet-500  (#845EC9)
图标:       <Plus weight="bold" size={28} color="#FFFFFF" />
阴影:       --shadow-brand  0 8px 20px 0 rgba(125,22,255,0.20)
垂直位置:   中心比 Tab Bar 顶部上凸 14pt（负 marginTop）
按压动画:   scale 0.93 → 1.0，100ms，spring
Label:      无
Active 态:  无选中样式（点击后直接触发导航，不改变按钮外观）
```

---

## 七、状态机与过渡动画

### 状态定义

```
INACTIVE ──── tap ────▶ ACTIVE
  │                       │
  │ 线条图标               │ Pop Art 双层图标
  │ opacity: 0.55          │ 偏移层 opacity: 1.0
  │ color: ink700          │ 主体: violet500
  │                        │ label: violet500, weight 600
  │◀──── tap other tab ────┘
```

### Animated API 实现（React Native 内置，不引入 Reanimated）

```typescript
// 每个 Tab 维护一个 Animated.Value
const animValue = useRef(new Animated.Value(isActive ? 1 : 0)).current;

// 触发动画
Animated.timing(animValue, {
  toValue: isActive ? 1 : 0,
  duration: 150,          // --duration-fast
  easing: Easing.out(Easing.quad),  // --easing-enter
  useNativeDriver: true,  // 仅 opacity / transform 可用 native driver
}).start();
```

### 各属性动画映射

| 属性 | Inactive (value=0) | Active (value=1) | Driver |
|---|---|---|---|
| 偏移层 opacity | `0` | `1` | Native ✓ |
| 图标 weight | `regular` | `fill` | 离散切换（value≥0.5 时切换） |
| 图标主色 | `#544864` | `#845EC9` | JS（interpolateColor） |
| 图标 opacity | `0.55` | `1.0` | Native ✓ |
| Label 颜色 | `#A7A7A7` | `#845EC9` | JS（interpolateColor） |
| Label fontWeight | `400` | `600` | 离散切换（value≥0.5 时切换） |
| 按压 scale | `1.0` | `0.92` | Native ✓ |

### Reduced Motion

```typescript
import { AccessibilityInfo } from 'react-native';

const prefersReducedMotion = await AccessibilityInfo.isReduceMotionEnabled();
const duration = prefersReducedMotion ? 0 : 150;
```

当 `prefersReducedMotion=true` 时，`duration=0`，状态仍然切换，仅去除动画过程。

---

## 八、Tab Bar 容器规格

```
背景色:         --color-bg-surface  (#FFFFFF)
顶部圆角:       32pt（仅左上、右上角）—— --radius-3xl
底部圆角:       0（贴底）
阴影:           朝上投影，--shadow-md（shadowOffset.height: -4）
内容区高度:     49pt
总高度:         49pt + SafeAreaInsets.bottom（动态计算）
分割线:         无（阴影替代）
5 Tab 布局:     flex: 1 等宽分布
```

---

## 九、尺寸与触摸区规格

| 元素 | 视觉尺寸 | 触摸区 | 备注 |
|---|---|---|---|
| 普通 Tab 图标 | 26pt | 44 × 44pt | hitSlop 补足差值 |
| [+] 按钮 | 56pt 圆 | 56 × 56pt | 自带充足触摸区 |
| Tab 间距 | — | ≥ 8pt | 防误触 |
| Label 字号 | 10pt (`--text-xs`) | — | Inactive: `--grey-500`，Active: `--violet-500` |

---

## 十、角标（Badge）规格

仅「问诊」Tab 使用，当有未读兽医回复消息时显示。

```
形状:     圆形红点
直径:     8pt
颜色:     --red-500  (#F0425A)
位置:     图标右上角，offset { top: -2pt, right: -4pt }
内容:     无数字（仅红点，不显示未读数量）
显示条件: hasUnreadConsultation === true
渲染:     false 时不渲染 Badge 节点（不占位）
```

---

## 十一、无障碍规格

```typescript
// 每个 Tab 必须包含：
<Pressable
  accessibilityRole="tab"
  accessibilityLabel={label}           // 见下表
  accessibilityState={{ selected: isActive }}
  accessibilityHint={authHint}         // 见下表
>
```

| Tab | accessibilityLabel | 有未读消息时追加 |
|---|---|---|
| 首页 | `"Beranda"` | — |
| 成长档案 | `"Paspor Tumbuh Kembang"` | — |
| [+] 发布 | `"Buat postingan baru"` | — |
| 问诊 | `"Konsultasi"` | `", ada pesan baru dari dokter hewan"` |
| 我的 | `"Profil saya"` | — |

未登录用户点击需要登录的 Tab 时，`accessibilityHint` 追加 `"Perlu masuk untuk mengakses"`。

---

## 十二、Token 引用速查

所有实现必须引用以下 Token 变量名，不允许硬编码值：

```typescript
// 从 tokens.json / tokens.css 中直接对应
const ICON_TOKENS = {
  // 颜色
  activeColor:    'var(--violet-500)',    // #845EC9
  offsetColor:    'var(--red-500)',       // #F0425A  ← Pop Art 偏移色
  inactiveColor:  'var(--ink-700)',       // #544864
  labelActive:    'var(--violet-500)',    // #845EC9
  labelInactive:  'var(--grey-500)',      // #A7A7A7
  badgeColor:     'var(--red-500)',       // #F0425A

  // 尺寸
  iconSize:       26,                    // pt
  offsetX:        3,                     // pt，Pop Art 偏移量
  offsetY:        3,                     // pt，Pop Art 偏移量
  containerSize:  32,                    // pt，双层图标容器

  // 动效
  duration:       150,                   // ms，--duration-fast
  easing:         'ease-out',            // --easing-enter

  // 不透明度
  inactiveOpacity: 0.55,
  activeOpacity:   1.0,
};
```

---

## 十三、QA 检查清单

实现完成后必须逐项验证：

### 视觉
- [ ] Pop Art 红色偏移层在 active 态完整可见，未被容器裁切（`overflow: visible` 生效）
- [ ] 偏移量精确为 3pt（不因设备像素比缩放而变形）
- [ ] Inactive 态图标透明度为 0.55（不是 0.5 也不是 0.6）
- [ ] [+] 按钮垂直上凸，不与其他 Tab 平齐
- [ ] Tab Bar 顶部圆角正确（仅上两角，下两角为 0）
- [ ] 问诊 Tab 红点位置正确（右上角，不遮挡图标主体）

### 交互
- [ ] 按压 scale 动画（0.92）在图标和 [+] 按钮上均生效
- [ ] 偏移层 opacity 过渡 150ms，不是瞬切
- [ ] 未登录用户点击 Tab 2/3/4/5 触发登录引导，不导航至目标页
- [ ] 问诊 Tab 角标在 `hasUnreadConsultation=false` 时完全不渲染

### 无障碍
- [ ] VoiceOver/TalkBack 读出正确 label
- [ ] `accessibilityState.selected` 在 active Tab 为 true
- [ ] Reduce Motion 开启时，切换无动画但状态正常变化

### 性能
- [ ] `useNativeDriver: true` 已启用（opacity/transform 动画）
- [ ] 无不必要的 re-render（Tab Bar 不因页面滚动重渲染）
