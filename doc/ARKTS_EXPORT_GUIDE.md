# 🔷 ArkTS 代码导出功能说明

## 功能概述

ArkTS 代码导出功能专为 HarmonyOS 开发者设计，可以将配色方案导出为 ArkTS 常量代码，直接在 HarmonyOS 项目中使用。

---

## ✨ 为什么需要 ArkTS 导出？

### 1. **原生支持** 🎯
- 直接用于 HarmonyOS/OpenHarmony 项目
- 无需转换，开箱即用
- 符合 ArkTS 语法规范

### 2. **类型安全** 🛡️
- 强类型定义
- 编译时检查
- IDE 智能提示

### 3. **开发效率** ⚡
- 复制即用
- 无需手动转换
- 减少错误

### 4. **多种形式** 📦
- 对象常量形式
- 数组形式
- 灵活选择

---

## 📋 导出格式示例

### 示例配色方案
**名称**: 夏日海滩  
**颜色**: `#FF6B6B`, `#4ECDC4`, `#45B7D1`, `#FFA07A`, `#98D8C8`, `#F7DC6F`

### 导出的 ArkTS 代码

```typescript
// 夏日海滩
// 配色方案常量

export const COLORS = {
  COLOR_1: '#FF6B6B',
  COLOR_2: '#4ECDC4',
  COLOR_3: '#45B7D1',
  COLOR_4: '#FFA07A',
  COLOR_5: '#98D8C8',
  COLOR_6: '#F7DC6F'
};

// 或使用数组形式
export const COLOR_PALETTE: string[] = [
  '#FF6B6B',
  '#4ECDC4',
  '#45B7D1',
  '#FFA07A',
  '#98D8C8',
  '#F7DC6F'
];
```

---

## 🎯 使用场景

### 场景 1: 定义主题颜色
```typescript
// 导入配色方案
import { COLORS } from './colors/SummerBeach';

@Entry
@Component
struct HomePage {
  build() {
    Column() {
      Text('欢迎')
        .fontColor(COLORS.COLOR_1)
        .backgroundColor(COLORS.COLOR_2)
    }
  }
}
```

### 场景 2: 使用数组遍历
```typescript
import { COLOR_PALETTE } from './colors/SummerBeach';

@Entry
@Component
struct ColorGrid {
  build() {
    Grid() {
      ForEach(COLOR_PALETTE, (color: string, index: number) => {
        GridItem() {
          Column()
            .width(100)
            .height(100)
            .backgroundColor(color)
        }
      })
    }
  }
}
```

### 场景 3: 主题切换
```typescript
// themes/SummerTheme.ets
import { COLORS } from './colors/SummerBeach';

export const SummerTheme = {
  primary: COLORS.COLOR_1,
  secondary: COLORS.COLOR_2,
  accent: COLORS.COLOR_3,
  background: COLORS.COLOR_4,
  surface: COLORS.COLOR_5,
  text: COLORS.COLOR_6
};
```

### 场景 4: 动态配色
```typescript
import { COLOR_PALETTE } from './colors/SummerBeach';

@Entry
@Component
struct DynamicColor {
  @State currentColorIndex: number = 0;

  build() {
    Column() {
      Button('切换颜色')
        .backgroundColor(COLOR_PALETTE[this.currentColorIndex])
        .onClick(() => {
          this.currentColorIndex = (this.currentColorIndex + 1) % COLOR_PALETTE.length;
        })
    }
  }
}
```

---

## 📁 项目组织建议

### 推荐的文件结构
```
entry/src/main/ets/
├── colors/                    # 配色方案目录
│   ├── SummerBeach.ets       # 夏日海滩配色
│   ├── AutumnForest.ets      # 秋日森林配色
│   └── WinterSnow.ets        # 冬日雪景配色
├── themes/                    # 主题定义
│   ├── LightTheme.ets
│   └── DarkTheme.ets
└── pages/
    └── Index.ets
```

### 配色文件示例 (SummerBeach.ets)
```typescript
// 夏日海滩
// 配色方案常量

export const COLORS = {
  COLOR_1: '#FF6B6B',
  COLOR_2: '#4ECDC4',
  COLOR_3: '#45B7D1',
  COLOR_4: '#FFA07A',
  COLOR_5: '#98D8C8',
  COLOR_6: '#F7DC6F'
};

export const COLOR_PALETTE: string[] = [
  '#FF6B6B',
  '#4ECDC4',
  '#45B7D1',
  '#FFA07A',
  '#98D8C8',
  '#F7DC6F'
];

// 可选：添加语义化命名
export const SEMANTIC_COLORS = {
  primary: COLORS.COLOR_1,
  secondary: COLORS.COLOR_2,
  accent: COLORS.COLOR_3,
  background: COLORS.COLOR_4,
  surface: COLORS.COLOR_5,
  highlight: COLORS.COLOR_6
};
```

---

## 💡 高级用法

### 1. 结合类型定义
```typescript
// ColorTypes.ets
export interface ColorScheme {
  primary: string;
  secondary: string;
  accent: string;
}

// SummerBeach.ets
import { ColorScheme } from './ColorTypes';

export const SUMMER_THEME: ColorScheme = {
  primary: '#FF6B6B',
  secondary: '#4ECDC4',
  accent: '#45B7D1'
};
```

### 2. 颜色工具函数
```typescript
import { COLOR_PALETTE } from './colors/SummerBeach';

export class ColorUtils {
  // 获取随机颜色
  static getRandomColor(): string {
    const index = Math.floor(Math.random() * COLOR_PALETTE.length);
    return COLOR_PALETTE[index];
  }
  
  // 获取指定索引的颜色
  static getColorByIndex(index: number): string {
    return COLOR_PALETTE[index % COLOR_PALETTE.length];
  }
}
```

---

## 🆚 与其他格式对比

| 特性 | ArkTS | CSS | JSON |
|------|-------|-----|------|
| HarmonyOS 原生支持 | ✅ | ❌ | ⚠️ |
| 类型安全 | ✅ | ❌ | ❌ |
| IDE 智能提示 | ✅ | ⚠️ | ❌ |
| 直接导入使用 | ✅ | ❌ | ⚠️ |
| 适用场景 | HarmonyOS 应用 | Web 应用 | 数据交换 |

---

## 📝 使用步骤

1. **导出配色方案**
   - 在配色库中点击"导出"
   - 选择"🔷 ArkTS 常量"
   - 点击"复制代码"

2. **创建配色文件**
   - 在项目中创建 `colors` 目录
   - 创建新文件，如 `SummerBeach.ets`
   - 粘贴导出的代码

3. **在项目中使用**
   - 导入配色常量
   - 在组件中使用颜色值

---

## 🎨 最佳实践

1. **统一管理** - 将所有配色方案放在 `colors` 目录
2. **语义化命名** - 使用有意义的变量名
3. **类型定义** - 为复杂主题定义接口
4. **文档注释** - 添加注释说明配色用途
5. **版本控制** - 配色文件纳入版本管理

---

祝你开发愉快！🎉

