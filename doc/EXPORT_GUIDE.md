# 📤 多格式导出功能使用指南

## 功能概述

多格式导出功能让你可以将配色方案导出为多种格式，方便在不同场景下使用。

---

## ✨ 支持的导出格式

### 1. 🎨 CSS 变量
导出为 CSS 自定义属性（CSS Variables）格式，可直接用于网页开发。

**示例输出**：
```css
/* 夏日海滩 */
:root {
  --color-1: #FF6B6B;
  --color-2: #4ECDC4;
  --color-3: #45B7D1;
  --color-4: #FFA07A;
  --color-5: #98D8C8;
  --color-6: #F7DC6F;
}
```

**使用场景**：
- 网页开发
- HTML/CSS 项目
- 前端框架（React、Vue、Angular）

---

### 2. 💎 SCSS 变量
导出为 SCSS/Sass 变量格式，适用于使用预处理器的项目。

**示例输出**：
```scss
// 夏日海滩
$color-1: #FF6B6B;
$color-2: #4ECDC4;
$color-3: #45B7D1;
$color-4: #FFA07A;
$color-5: #98D8C8;
$color-6: #F7DC6F;
```

**使用场景**：
- SCSS/Sass 项目
- Bootstrap 自定义主题
- 需要变量计算的场景

---

### 3. 📋 JSON 数据
导出为 JSON 格式，包含完整的配色方案信息。

**示例输出**：
```json
{
  "name": "夏日海滩",
  "colors": [
    "#FF6B6B",
    "#4ECDC4",
    "#45B7D1",
    "#FFA07A",
    "#98D8C8",
    "#F7DC6F"
  ],
  "tags": ["自然", "温暖", "清新"],
  "createTime": 1699876543210,
  "colorCount": 6
}
```

**使用场景**：
- 数据交换
- API 接口
- 配置文件
- 跨平台使用

---

### 4. 🌊 Tailwind 配置
导出为 Tailwind CSS 配置格式，可直接添加到 tailwind.config.js。

**示例输出**：
```javascript
// 夏日海滩
module.exports = {
  theme: {
    extend: {
      colors: {
        'custom-1': '#FF6B6B',
        'custom-2': '#4ECDC4',
        'custom-3': '#45B7D1',
        'custom-4': '#FFA07A',
        'custom-5': '#98D8C8',
        'custom-6': '#F7DC6F',
      }
    }
  }
}
```

**使用场景**：
- Tailwind CSS 项目
- 自定义 Tailwind 主题
- 实用优先的 CSS 框架

---

## 📱 使用步骤

### 步骤 1: 打开配色库
1. 启动应用
2. 切换到"配色库"标签
3. 找到要导出的配色方案

---

### 步骤 2: 点击导出按钮
1. 在配色方案卡片上找到"导出"按钮
2. 点击"导出"按钮
3. 导出对话框将打开

---

### 步骤 3: 选择导出格式
1. 在对话框中查看配色预览
2. 点击选择导出格式：
   - 🎨 CSS 变量
   - 💎 SCSS 变量
   - 📋 JSON 数据
   - 🌊 Tailwind 配置
3. 代码预览区会实时更新

---

### 步骤 4: 复制代码
1. 查看代码预览
2. 点击"复制代码"按钮
3. 代码已复制到剪贴板
4. 可以粘贴到你的项目中使用

---

## 💡 使用技巧

### 快速工作流
1. **提取配色** → 从图片提取颜色
2. **保存方案** → 保存到配色库
3. **导出使用** → 导出为需要的格式
4. **粘贴到项目** → 直接在项目中使用

### 格式选择建议
- **网页项目** → 使用 CSS 变量（兼容性好）
- **Sass 项目** → 使用 SCSS 变量（支持计算）
- **Tailwind 项目** → 使用 Tailwind 配置
- **跨平台/数据交换** → 使用 JSON 格式

### 命名规范
- CSS/SCSS 变量：`--color-1`, `$color-1`
- Tailwind 类名：`custom-1`（使用时：`bg-custom-1`）
- 可以根据需要修改变量名

---

## 🎯 实际应用示例

### 示例 1: 在网页中使用 CSS 变量
```html
<style>
  /* 粘贴导出的 CSS 代码 */
  :root {
    --color-1: #FF6B6B;
    --color-2: #4ECDC4;
  }
  
  /* 使用变量 */
  .header {
    background-color: var(--color-1);
  }
  
  .button {
    background-color: var(--color-2);
  }
</style>
```

---

## 📊 技术实现

### 核心文件
- `entry/src/main/ets/utils/ExportUtils.ets` - 导出工具类
- `entry/src/main/ets/pages/LibraryPage.ets` - 导出对话框

### 导出方法
- `exportToCSS()` - CSS 变量格式
- `exportToSCSS()` - SCSS 变量格式
- `exportToJSON()` - JSON 数据格式
- `exportToTailwind()` - Tailwind 配置格式

---

## 🔮 未来计划

- [ ] 导出为图片（配色卡片）
- [ ] 导出为 PDF
- [ ] 保存到文件
- [ ] 分享到其他应用
- [ ] 更多格式支持（Less、Stylus 等）

---

祝你使用愉快！🎉

