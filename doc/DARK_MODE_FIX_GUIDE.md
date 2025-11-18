# 🌓 深色模式修复指南

## 问题描述

深色模式功能已实现，但部分页面使用了硬编码的颜色值，导致切换到深色模式后颜色不会自动适配。

### 问题示例
```typescript
// ❌ 硬编码颜色 - 不会随主题变化
.backgroundColor('#FFFFFF')
.fontColor('#333333')

// ✅ 使用 ThemeColors - 会随主题自动适配
.backgroundColor(ThemeColors.background)
.fontColor(ThemeColors.textSecondary)
```

---

## 解决方案

### 1. ThemeColors 工具类

已创建 `entry/src/main/ets/utils/ThemeColors.ets` 工具类，提供动态主题颜色。

**核心功能：**
- 根据当前主题模式（深色/浅色）返回对应的颜色值
- 提供统一的颜色命名规范
- 自动适配深色模式

---

## ThemeColors 颜色列表

### 背景颜色

| 属性 | 浅色模式 | 深色模式 | 用途 |
|------|---------|---------|------|
| `background` | #FFFFFF | #000000 | 主背景色 |
| `backgroundSecondary` | #F5F5F5 | #1C1C1E | 次级背景色（标题栏等） |
| `backgroundCard` | #F9F9F9 | #1C1C1E | 卡片背景色 |
| `backgroundInput` | #F0F0F0 | #2C2C2E | 输入框背景色 |
| `backgroundElevated` | #F8F8F8 | #2C2C2E | 悬浮背景色 |

### 文字颜色

| 属性 | 浅色模式 | 深色模式 | 用途 |
|------|---------|---------|------|
| `textPrimary` | #000000 | #FFFFFF | 主文字颜色 |
| `textSecondary` | #333333 | #EBEBF5 | 次级文字颜色 |
| `textTertiary` | #666666 | #AEAEB2 | 三级文字颜色 |
| `textPlaceholder` | #999999 | #8E8E93 | 占位符文字颜色 |
| `textDisabled` | #CCCCCC | #636366 | 禁用文字颜色 |

### 分割线颜色

| 属性 | 浅色模式 | 深色模式 | 用途 |
|------|---------|---------|------|
| `divider` | #E0E0E0 | #38383A | 分割线颜色 |
| `border` | #E0E0E0 | #38383A | 边框颜色 |

### 品牌颜色（不随主题变化）

| 属性 | 颜色值 | 用途 |
|------|-------|------|
| `primary` | #007AFF | 主题色（蓝色） |
| `success` | #34C759 | 成功色（绿色） |
| `warning` | #FF9500 | 警告色（橙色） |
| `error` | #FF3B30 | 错误色（红色） |
| `purple` | #5856D6 | 紫色 |

### 品牌颜色浅色背景

| 属性 | 浅色模式 | 深色模式 | 用途 |
|------|---------|---------|------|
| `primaryLight` | #E5F2FF | #1A3A5C | 主题色浅色背景 |
| `successLight` | #E8F5E9 | #1A3A2C | 成功色浅色背景 |
| `warningLight` | #FFF3E0 | #3A2C1A | 警告色浅色背景 |
| `errorLight` | #FFEBEE | #3A1A1A | 错误色浅色背景 |

### 阴影颜色

| 属性 | 浅色模式 | 深色模式 | 用途 |
|------|---------|---------|------|
| `shadowLight` | rgba(0,0,0,0.1) | rgba(0,0,0,0.3) | 轻阴影 |
| `shadowMedium` | rgba(0,0,0,0.2) | rgba(0,0,0,0.5) | 中阴影 |
| `shadowHeavy` | rgba(0,0,0,0.3) | rgba(0,0,0,0.7) | 重阴影 |

---

## 使用方法

### 1. 导入 ThemeColors

```typescript
import { ThemeColors } from '../utils/ThemeColors';
```

### 2. 替换硬编码颜色

#### 背景色
```typescript
// ❌ 修改前
.backgroundColor('#FFFFFF')
.backgroundColor('#F5F5F5')
.backgroundColor('#F9F9F9')

// ✅ 修改后
.backgroundColor(ThemeColors.background)
.backgroundColor(ThemeColors.backgroundSecondary)
.backgroundColor(ThemeColors.backgroundCard)
```

#### 文字颜色
```typescript
// ❌ 修改前
.fontColor('#333333')
.fontColor('#666666')
.fontColor('#999999')

// ✅ 修改后
.fontColor(ThemeColors.textSecondary)
.fontColor(ThemeColors.textTertiary)
.fontColor(ThemeColors.textPlaceholder)
```

#### 品牌颜色
```typescript
// ✅ 品牌颜色不需要修改（不随主题变化）
.backgroundColor('#007AFF')  // 可以保持不变
.backgroundColor(ThemeColors.primary)  // 或使用 ThemeColors（推荐）
```

---

## 已修复的页面

### ✅ MinePage.ets（100%）
- ✅ 主背景色
- ✅ 次级背景色
- ✅ 卡片背景色
- ✅ 所有文字颜色
- ✅ 图标颜色
- ✅ 主题选项背景色

### 🔄 Index.ets（提取页面）（30%）
**已修复：**
- ✅ ThemeColors 导入
- ✅ SaveSchemeDialog 对话框（背景、文字、按钮）
- ✅ TabBar 图标和文字颜色
- ✅ 标题栏背景和文字
- ✅ 选择图片按钮（背景、图标、文字）
- ✅ 重新选择按钮
- ✅ 取色模式切换（背景、文字）
- ✅ 算法选择（背景、文字）

**待修复（约70%）：**
- ⏳ 颜色列表卡片
- ⏳ 手动颜色列表
- ⏳ 底部操作按钮
- ⏳ 加载状态
- ⏳ 其他对话框
- ⏳ 更多UI元素（约50+处）

---

## 待修复的页面

### ⏳ LibraryPage.ets（配色库页面）（0%）
需要替换的硬编码颜色：
- 背景色
- 文字色
- 卡片背景色
- 对话框背景色
- 筛选器背景色
- 标签颜色

### ⏳ InspirationPage.ets（灵感广场页面）（0%）
需要替换的硬编码颜色：
- 背景色
- 文字色
- 卡片背景色
- 分类标签背景色
- 按钮颜色

### ⏳ 其他组件（0%）
- GuideOverlay.ets
- EmptyState.ets
- LoadingState.ets

---

## 注意事项

### 1. 颜色选择原则
- **背景色**：使用 `background*` 系列
- **文字色**：根据重要性选择 `textPrimary/Secondary/Tertiary`
- **品牌色**：使用 `primary/success/warning/error`
- **分割线**：使用 `divider` 或 `border`

### 2. 不需要修改的颜色
- 配色方案中的颜色（用户选择的颜色）
- 品牌色（如果希望保持一致）
- 特殊效果颜色（如渐变、透明度等）

### 3. 触发重新渲染
如果颜色没有自动更新，需要添加状态变量触发重新渲染：
```typescript
@State themeUpdateFlag: number = 0;

// 切换主题时
this.themeUpdateFlag++;
```

---

## 测试建议

1. **切换主题**：在"我的"页面切换主题模式
2. **检查页面**：逐个检查每个页面的颜色是否正确适配
3. **检查组件**：检查对话框、弹窗等组件的颜色
4. **检查文字**：确保所有文字在深色模式下清晰可读

---

## 下一步

1. 修复 Index.ets 页面
2. 修复 LibraryPage.ets 页面
3. 修复 InspirationPage.ets 页面
4. 修复其他组件
5. 全面测试深色模式

---

**当前状态：** MinePage 已完成深色模式适配 ✅  
**下一步：** 修复其他页面的硬编码颜色

