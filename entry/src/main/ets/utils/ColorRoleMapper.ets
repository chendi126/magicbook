/**
 * 颜色角色映射工具
 * 将配色方案中的颜色智能分配到不同的 UI 角色
 */

import { ColorAnalyzer, HSLColor } from './ColorAnalyzer';

// 颜色角色定义
export interface ColorRole {
  primary: string;      // 主色 - 用于主要按钮、重要元素
  secondary: string;    // 辅色 - 用于次要按钮、辅助元素
  background: string;   // 背景色 - 页面背景
  surface: string;      // 表面色 - 卡片、对话框背景
  text: string;         // 文字色 - 主要文字
  textSecondary: string; // 次要文字色
  accent: string;       // 强调色 - 用于高亮、提示
  error: string;        // 错误色 - 用于错误提示
  success: string;      // 成功色 - 用于成功提示
  border: string;       // 边框色
}

// 颜色分析结果接口
interface ColorAnalysisResult {
  color: string;
  hsl: HSLColor | null;
  lightness: number;
  saturation: number;
  hue: number;
}

export class ColorRoleMapper {
  /**
   * 智能分配颜色角色
   * @param colors 配色方案中的颜色数组
   * @returns 颜色角色映射
   */
  static assignRoles(colors: string[]): ColorRole {
    if (colors.length === 0) {
      return ColorRoleMapper.getDefaultRoles();
    }

    // 分析每个颜色的特征
    const colorAnalysis: ColorAnalysisResult[] = colors.map((color: string): ColorAnalysisResult => {
      const hsl = ColorAnalyzer.hexToHsl(color);
      return {
        color: color,
        hsl: hsl,
        lightness: hsl?.l || 50,
        saturation: hsl?.s || 50,
        hue: hsl?.h || 0
      };
    });

    // 按亮度排序
    const sortedByLightness = [...colorAnalysis].sort((a, b) => a.lightness - b.lightness);
    // 按饱和度排序
    const sortedBySaturation = [...colorAnalysis].sort((a, b) => b.saturation - a.saturation);

    // 分配角色
    const roles: ColorRole = {
      // 主色：选择饱和度最高的颜色
      primary: sortedBySaturation[0]?.color || colors[0],
      
      // 辅色：选择第二饱和的颜色，如果只有一个颜色则使用主色的变体
      secondary: colors.length > 1 ? sortedBySaturation[1]?.color : ColorRoleMapper.adjustColor(colors[0], 0, -10, 0),
      
      // 背景色：使用最亮的颜色或白色
      background: sortedByLightness[sortedByLightness.length - 1]?.lightness > 80 
        ? sortedByLightness[sortedByLightness.length - 1]?.color 
        : '#FFFFFF',
      
      // 表面色：使用次亮的颜色或浅灰色
      surface: sortedByLightness.length > 1 && sortedByLightness[sortedByLightness.length - 2]?.lightness > 70
        ? sortedByLightness[sortedByLightness.length - 2]?.color
        : '#F5F5F5',
      
      // 文字色：使用最暗的颜色或深灰色
      text: sortedByLightness[0]?.lightness < 30 
        ? sortedByLightness[0]?.color 
        : '#333333',
      
      // 次要文字色
      textSecondary: '#666666',
      
      // 强调色：选择第三个颜色或主色的变体
      accent: colors.length > 2 ? colors[2] : ColorRoleMapper.adjustColor(colors[0], 30, 0, 0),
      
      // 错误色：红色系
      error: ColorRoleMapper.findColorByHue(colorAnalysis, 0, 30) || '#FF3B30',
      
      // 成功色：绿色系
      success: ColorRoleMapper.findColorByHue(colorAnalysis, 120, 150) || '#34C759',
      
      // 边框色
      border: '#E0E0E0'
    };

    return roles;
  }

  /**
   * 查找指定色相范围内的颜色
   */
  private static findColorByHue(colorAnalysis: ColorAnalysisResult[], minHue: number, maxHue: number): string | null {
    const found = colorAnalysis.find((c: ColorAnalysisResult) => c.hue >= minHue && c.hue <= maxHue);
    return found ? found.color : null;
  }

  /**
   * 调整颜色的 HSL 值
   * @param color 原始颜色
   * @param hueShift 色相偏移（-360 到 360）
   * @param saturationShift 饱和度偏移（-100 到 100）
   * @param lightnessShift 亮度偏移（-100 到 100）
   */
  static adjustColor(color: string, hueShift: number, saturationShift: number, lightnessShift: number): string {
    const hsl = ColorAnalyzer.hexToHsl(color);
    if (!hsl) return color;

    const newHsl: HSLColor = {
      h: (hsl.h + hueShift + 360) % 360,
      s: Math.max(0, Math.min(100, hsl.s + saturationShift)),
      l: Math.max(0, Math.min(100, hsl.l + lightnessShift))
    };

    const rgb = ColorAnalyzer.hslToRgb(newHsl.h, newHsl.s, newHsl.l);
    return ColorAnalyzer.rgbToHex(rgb.r, rgb.g, rgb.b);
  }

  /**
   * 获取默认颜色角色
   */
  private static getDefaultRoles(): ColorRole {
    return {
      primary: '#007AFF',
      secondary: '#5856D6',
      background: '#FFFFFF',
      surface: '#F5F5F5',
      text: '#333333',
      textSecondary: '#666666',
      accent: '#FF9500',
      error: '#FF3B30',
      success: '#34C759',
      border: '#E0E0E0'
    };
  }

  /**
   * 生成颜色角色的 CSS 变量代码
   */
  static generateCSSVariables(roles: ColorRole): string {
    return `:root {
  --color-primary: ${roles.primary};
  --color-secondary: ${roles.secondary};
  --color-background: ${roles.background};
  --color-surface: ${roles.surface};
  --color-text: ${roles.text};
  --color-text-secondary: ${roles.textSecondary};
  --color-accent: ${roles.accent};
  --color-error: ${roles.error};
  --color-success: ${roles.success};
  --color-border: ${roles.border};
}`;
  }
}

