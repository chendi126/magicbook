/**
 * 颜色分析工具类
 * 提供色彩情感分析、和谐度评分、可访问性检查等功能
 */

// 色彩情感分析结果
export interface ColorEmotionAnalysis {
  warmth: number; // 温暖度 0-100
  energy: number; // 活力度 0-100
  professionalism: number; // 专业度 0-100
  harmony: number; // 和谐度 0-100
  emotionTags: string[]; // 情感标签
  suitableScenes: string[]; // 适用场景
}

// HSL 颜色
export interface HSLColor {
  h: number; // 色相 0-360
  s: number; // 饱和度 0-100
  l: number; // 亮度 0-100
}

// 对比度检查结果
export interface ContrastCheckResult {
  ratio: number; // 对比度比值
  wcagAA: boolean; // 是否符合 WCAG AA 标准
  wcagAAA: boolean; // 是否符合 WCAG AAA 标准
  level: 'excellent' | 'good' | 'fair' | 'poor'; // 等级
}

// RGB 颜色
export interface RGBColor {
  r: number;
  g: number;
  b: number;
}

export class ColorAnalyzer {
  /**
   * HEX 转 RGB
   */
  static hexToRgb(hex: string): RGBColor | null {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    if (!result) {
      return null;
    }
    const rgb: RGBColor = {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    };
    return rgb;
  }

  /**
   * RGB 转 HSL
   */
  static rgbToHsl(r: number, g: number, b: number): HSLColor {
    r /= 255;
    g /= 255;
    b /= 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h = 0;
    let s = 0;
    const l = (max + min) / 2;

    if (max !== min) {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      switch (max) {
        case r:
          h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
          break;
        case g:
          h = ((b - r) / d + 2) / 6;
          break;
        case b:
          h = ((r - g) / d + 4) / 6;
          break;
      }
    }

    return {
      h: Math.round(h * 360),
      s: Math.round(s * 100),
      l: Math.round(l * 100)
    };
  }

  /**
   * HSL 转 RGB
   */
  static hslToRgb(h: number, s: number, l: number): RGBColor {
    h /= 360;
    s /= 100;
    l /= 100;

    let r: number, g: number, b: number;

    if (s === 0) {
      r = g = b = l;
    } else {
      const hue2rgb = (p: number, q: number, t: number): number => {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
      };

      const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      const p = 2 * l - q;
      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    const rgb: RGBColor = {
      r: Math.round(r * 255),
      g: Math.round(g * 255),
      b: Math.round(b * 255)
    };
    return rgb;
  }

  /**
   * RGB 转 HEX
   */
  static rgbToHex(r: number, g: number, b: number): string {
    const toHex = (n: number): string => {
      const hex = Math.round(n).toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    };
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
  }

  /**
   * HEX 转 HSL
   */
  static hexToHsl(hex: string): HSLColor | null {
    const rgb = ColorAnalyzer.hexToRgb(hex);
    if (!rgb) return null;
    return ColorAnalyzer.rgbToHsl(rgb.r, rgb.g, rgb.b);
  }

  /**
   * HSL 转 HEX
   */
  static hslToHex(h: number, s: number, l: number): string {
    const rgb = ColorAnalyzer.hslToRgb(h, s, l);
    return ColorAnalyzer.rgbToHex(rgb.r, rgb.g, rgb.b);
  }

  /**
   * 分析配色方案的情感特征
   */
  static analyzeColorEmotion(colors: string[]): ColorEmotionAnalysis {
    if (colors.length === 0) {
      return {
        warmth: 50,
        energy: 50,
        professionalism: 50,
        harmony: 50,
        emotionTags: [],
        suitableScenes: []
      };
    }

    // 转换为 HSL
    const hslColors = colors.map(c => ColorAnalyzer.hexToHsl(c)).filter(c => c !== null) as HSLColor[];

    // 计算温暖度（基于色相）
    const warmth = ColorAnalyzer.calculateWarmth(hslColors);

    // 计算活力度（基于饱和度）
    const energy = ColorAnalyzer.calculateEnergy(hslColors);

    // 计算专业度（基于亮度和饱和度的平衡）
    const professionalism = ColorAnalyzer.calculateProfessionalism(hslColors);

    // 计算和谐度（基于色相分布）
    const harmony = ColorAnalyzer.calculateHarmony(hslColors);

    // 生成情感标签
    const emotionTags = ColorAnalyzer.generateEmotionTags(warmth, energy, professionalism, harmony);

    // 推荐适用场景
    const suitableScenes = ColorAnalyzer.recommendScenes(warmth, energy, professionalism, harmony);

    return {
      warmth,
      energy,
      professionalism,
      harmony,
      emotionTags,
      suitableScenes
    };
  }

  /**
   * 计算温暖度
   */
  private static calculateWarmth(colors: HSLColor[]): number {
    let warmScore = 0;
    colors.forEach(color => {
      const h = color.h;
      // 暖色：0-60（红橙黄）得分高，冷色：180-240（蓝）得分低
      if (h >= 0 && h <= 60) {
        warmScore += 100;
      } else if (h > 60 && h <= 120) {
        warmScore += 70;
      } else if (h > 120 && h <= 180) {
        warmScore += 30;
      } else if (h > 180 && h <= 240) {
        warmScore += 0;
      } else if (h > 240 && h <= 300) {
        warmScore += 30;
      } else {
        warmScore += 70;
      }
    });
    return Math.round(warmScore / colors.length);
  }

  /**
   * 计算活力度
   */
  private static calculateEnergy(colors: HSLColor[]): number {
    let energyScore = 0;
    colors.forEach(color => {
      // 高饱和度 = 高活力
      energyScore += color.s;
    });
    return Math.round(energyScore / colors.length);
  }

  /**
   * 计算专业度
   */
  private static calculateProfessionalism(colors: HSLColor[]): number {
    let profScore = 0;
    colors.forEach(color => {
      // 中等饱和度、中等亮度 = 专业
      const saturationScore = 100 - Math.abs(color.s - 50);
      const lightnessScore = 100 - Math.abs(color.l - 50);
      profScore += (saturationScore + lightnessScore) / 2;
    });
    return Math.round(profScore / colors.length);
  }

  /**
   * 计算和谐度
   */
  private static calculateHarmony(colors: HSLColor[]): number {
    if (colors.length < 2) return 100;

    // 检查是否符合常见配色规则
    const hues = colors.map(c => c.h);

    // 检查单色配色（色相相近）
    const isMonochromatic = ColorAnalyzer.checkMonochromatic(hues);
    if (isMonochromatic) return 95;

    // 检查互补色配色
    const isComplementary = ColorAnalyzer.checkComplementary(hues);
    if (isComplementary) return 90;

    // 检查类似色配色
    const isAnalogous = ColorAnalyzer.checkAnalogous(hues);
    if (isAnalogous) return 85;

    // 检查三角配色
    const isTriadic = ColorAnalyzer.checkTriadic(hues);
    if (isTriadic) return 85;

    // 默认和谐度
    return 70;
  }

  private static checkMonochromatic(hues: number[]): boolean {
    const maxDiff = Math.max(...hues) - Math.min(...hues);
    return maxDiff <= 30;
  }

  private static checkComplementary(hues: number[]): boolean {
    if (hues.length !== 2) return false;
    const diff = Math.abs(hues[0] - hues[1]);
    return Math.abs(diff - 180) <= 30;
  }

  private static checkAnalogous(hues: number[]): boolean {
    const maxDiff = Math.max(...hues) - Math.min(...hues);
    return maxDiff > 30 && maxDiff <= 60;
  }

  private static checkTriadic(hues: number[]): boolean {
    if (hues.length !== 3) return false;
    const sorted = [...hues].sort((a, b) => a - b);
    const diff1 = sorted[1] - sorted[0];
    const diff2 = sorted[2] - sorted[1];
    return Math.abs(diff1 - 120) <= 30 && Math.abs(diff2 - 120) <= 30;
  }

  /**
   * 生成情感标签
   */
  private static generateEmotionTags(warmth: number, energy: number, prof: number, harmony: number): string[] {
    const tags: string[] = [];

    // 温暖度标签
    if (warmth >= 70) tags.push('温暖');
    else if (warmth <= 30) tags.push('冷静');

    // 活力度标签
    if (energy >= 70) tags.push('活力');
    else if (energy <= 30) tags.push('柔和');

    // 专业度标签
    if (prof >= 70) tags.push('专业');
    if (harmony >= 85) tags.push('和谐');

    // 组合标签
    if (warmth >= 60 && energy >= 60) tags.push('热情');
    if (warmth <= 40 && energy <= 40) tags.push('优雅');
    if (energy >= 70 && harmony >= 80) tags.push('现代');
    if (energy <= 40 && harmony >= 80) tags.push('经典');

    return tags;
  }

  /**
   * 推荐适用场景
   */
  private static recommendScenes(warmth: number, energy: number, prof: number, harmony: number): string[] {
    const scenes: string[] = [];

    if (prof >= 70 && harmony >= 80) {
      scenes.push('企业品牌');
      scenes.push('商务演示');
    }

    if (energy >= 70) {
      scenes.push('运动健身');
      scenes.push('儿童产品');
    }

    if (warmth >= 60 && energy >= 60) {
      scenes.push('餐饮美食');
      scenes.push('节日庆典');
    }

    if (warmth <= 40 && prof >= 60) {
      scenes.push('科技产品');
      scenes.push('医疗健康');
    }

    if (harmony >= 85) {
      scenes.push('网页设计');
      scenes.push('UI界面');
    }

    if (energy <= 40 && harmony >= 80) {
      scenes.push('艺术展览');
      scenes.push('高端奢侈品');
    }

    return scenes.length > 0 ? scenes : ['通用场景'];
  }

  /**
   * 检查两个颜色的对比度
   */
  static checkContrast(color1: string, color2: string): ContrastCheckResult {
    const rgb1 = ColorAnalyzer.hexToRgb(color1);
    const rgb2 = ColorAnalyzer.hexToRgb(color2);

    if (!rgb1 || !rgb2) {
      return {
        ratio: 1,
        wcagAA: false,
        wcagAAA: false,
        level: 'poor'
      };
    }

    // 计算相对亮度
    const l1 = ColorAnalyzer.getRelativeLuminance(rgb1.r, rgb1.g, rgb1.b);
    const l2 = ColorAnalyzer.getRelativeLuminance(rgb2.r, rgb2.g, rgb2.b);

    // 计算对比度
    const ratio = (Math.max(l1, l2) + 0.05) / (Math.min(l1, l2) + 0.05);

    return {
      ratio: Math.round(ratio * 100) / 100,
      wcagAA: ratio >= 4.5,
      wcagAAA: ratio >= 7,
      level: ratio >= 7 ? 'excellent' : ratio >= 4.5 ? 'good' : ratio >= 3 ? 'fair' : 'poor'
    };
  }

  /**
   * 计算相对亮度
   */
  private static getRelativeLuminance(r: number, g: number, b: number): number {
    const rsRGB = r / 255;
    const gsRGB = g / 255;
    const bsRGB = b / 255;

    const r2 = rsRGB <= 0.03928 ? rsRGB / 12.92 : Math.pow((rsRGB + 0.055) / 1.055, 2.4);
    const g2 = gsRGB <= 0.03928 ? gsRGB / 12.92 : Math.pow((gsRGB + 0.055) / 1.055, 2.4);
    const b2 = bsRGB <= 0.03928 ? bsRGB / 12.92 : Math.pow((bsRGB + 0.055) / 1.055, 2.4);

    return 0.2126 * r2 + 0.7152 * g2 + 0.0722 * b2;
  }
}

