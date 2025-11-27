/**
 * 色彩性格分析工具
 * 基于用户收藏的配色方案，分析色彩偏好并生成性格图谱
 */

import { ColorScheme } from '../models/ColorScheme';
import { ColorPersonality, PersonalityTag, ColorDimensions, StyleScores } from '../models/ColorPersonality';
import { HSLColor, WarmCoolRatio } from '../models/ColorTypes';

export class ColorPersonalityAnalyzer {
  private static instance: ColorPersonalityAnalyzer;
  
  private constructor() {}
  
  static getInstance(): ColorPersonalityAnalyzer {
    if (!ColorPersonalityAnalyzer.instance) {
      ColorPersonalityAnalyzer.instance = new ColorPersonalityAnalyzer();
    }
    return ColorPersonalityAnalyzer.instance;
  }
  
  /**
   * 分析配色方案，生成色彩性格
   */
  analyze(schemes: ColorScheme[]): ColorPersonality {
    const personality = new ColorPersonality();
    
    if (schemes.length === 0) {
      return personality;
    }
    
    personality.totalSchemes = schemes.length;
    
    // 收集所有颜色
    const allColors: string[] = [];
    schemes.forEach(scheme => {
      allColors.push(...scheme.colors);
    });
    
    // 分析色彩DNA（最常用的5个颜色）
    personality.topColors = this.getTopColors(allColors, 5);
    
    // 分析六个维度
    personality.dimensions = this.analyzeDimensions(allColors);
    
    // 生成性格标签
    personality.tags = this.generateTags(personality.dimensions, allColors.length);
    
    // 计算风格评分
    personality.styles = this.calculateStyles(schemes);
    
    // 计算暖冷色比例
    const colorRatios = this.calculateWarmCoolRatio(allColors);
    personality.warmColorRatio = colorRatios.warm;
    personality.coolColorRatio = colorRatios.cool;
    
    // 找出最喜欢的色相
    personality.favoriteHue = this.findFavoriteHue(allColors);
    
    personality.lastUpdated = Date.now();
    
    return personality;
  }
  
  /**
   * 获取出现最多的N个颜色
   */
  private getTopColors(colors: string[], count: number): string[] {
    const colorFreq = new Map<string, number>();
    
    colors.forEach(color => {
      colorFreq.set(color, (colorFreq.get(color) || 0) + 1);
    });
    
    return Array.from(colorFreq.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, count)
      .map(entry => entry[0]);
  }
  
  /**
   * 分析六个维度
   */
  private analyzeDimensions(colors: string[]): ColorDimensions {
    let warmCount = 0;
    let coolCount = 0;
    let brightCount = 0;
    let softCount = 0;
    let totalSaturation = 0;
    let totalLightness = 0;
    
    colors.forEach(color => {
      const hsl = this.hexToHSL(color);
      
      // 暖色 vs 冷色 (0-60° 和 300-360° 为暖色)
      if ((hsl.h >= 0 && hsl.h <= 60) || (hsl.h >= 300 && hsl.h <= 360)) {
        warmCount++;
      } else {
        coolCount++;
      }
      
      // 明亮 vs 柔和 (L > 60% 为明亮)
      if (hsl.l > 60) {
        brightCount++;
      } else {
        softCount++;
      }
      
      totalSaturation += hsl.s;
      totalLightness += hsl.l;
    });
    
    const total = colors.length;
    const avgSaturation = totalSaturation / total;
    const avgLightness = totalLightness / total;
    
    // 计算对比度和和谐度（基于饱和度和亮度的方差）
    let saturationVariance = 0;
    let lightnessVariance = 0;
    
    colors.forEach(color => {
      const hsl = this.hexToHSL(color);
      saturationVariance += Math.pow(hsl.s - avgSaturation, 2);
      lightnessVariance += Math.pow(hsl.l - avgLightness, 2);
    });
    
    const contrastScore = Math.min(100, (lightnessVariance / total) * 2);
    const harmonyScore = 100 - contrastScore;
    
    return {
      warm: Math.round((warmCount / total) * 100),
      cool: Math.round((coolCount / total) * 100),
      bright: Math.round((brightCount / total) * 100),
      soft: Math.round((softCount / total) * 100),
      contrast: Math.round(contrastScore),
      harmony: Math.round(harmonyScore)
    };
  }
  
  /**
   * 生成性格标签
   */
  private generateTags(dimensions: ColorDimensions, totalColors: number): PersonalityTag[] {
    const tags: PersonalityTag[] = [];
    
    // 基于维度数据生成标签
    if (dimensions.warm > 60) {
      tags.push(PersonalityTag.ENERGETIC);
    }
    if (dimensions.cool > 60) {
      tags.push(PersonalityTag.ELEGANT);
    }
    if (dimensions.bright > 70) {
      tags.push(PersonalityTag.BOLD);
    }
    if (dimensions.soft > 70) {
      tags.push(PersonalityTag.GENTLE);
    }
    if (dimensions.harmony > 70) {
      tags.push(PersonalityTag.NATURAL);
    }
    if (dimensions.contrast > 70) {
      tags.push(PersonalityTag.CREATIVE);
    }
    
    // 基于颜色数量判断
    if (totalColors < 20) {
      tags.push(PersonalityTag.MINIMALIST);
    } else if (totalColors > 100) {
      tags.push(PersonalityTag.PROFESSIONAL);
    }
    
    // 至少返回两个标签
    if (tags.length === 0) {
      tags.push(PersonalityTag.CREATIVE, PersonalityTag.NATURAL);
    } else if (tags.length === 1) {
      tags.push(PersonalityTag.CREATIVE);
    }
    
    return tags.slice(0, 3); // 最多3个标签
  }
  
  /**
   * 计算风格评分
   */
  private calculateStyles(schemes: ColorScheme[]): StyleScores {
    let minimalScore = 0;
    let complexScore = 0;
    let boldScore = 0;
    let conservativeScore = 0;
    
    schemes.forEach(scheme => {
      const colorCount = scheme.colors.length;
      
      // 极简 vs 复杂（基于颜色数量）
      if (colorCount <= 3) {
        minimalScore += 10;
      } else {
        complexScore += 10;
      }
      
      // 大胆 vs 保守（基于颜色饱和度）
      let totalSaturation = 0;
      scheme.colors.forEach(color => {
        const hsl = this.hexToHSL(color);
        totalSaturation += hsl.s;
      });
      
      const avgSat = totalSaturation / colorCount;
      if (avgSat > 60) {
        boldScore += 10;
      } else {
        conservativeScore += 10;
      }
    });
    
    const total = schemes.length * 10;
    
    return {
      minimal: Math.min(100, Math.round((minimalScore / total) * 100)),
      complex: Math.min(100, Math.round((complexScore / total) * 100)),
      bold: Math.min(100, Math.round((boldScore / total) * 100)),
      conservative: Math.min(100, Math.round((conservativeScore / total) * 100))
    };
  }
  
  /**
   * 计算暖冷色比例
   */
  private calculateWarmCoolRatio(colors: string[]): WarmCoolRatio {
    let warmCount = 0;
    
    colors.forEach(color => {
      const hsl = this.hexToHSL(color);
      if ((hsl.h >= 0 && hsl.h <= 60) || (hsl.h >= 300 && hsl.h <= 360)) {
        warmCount++;
      }
    });
    
    const warmRatio = Math.round((warmCount / colors.length) * 100);
    
    return {
      warm: warmRatio,
      cool: 100 - warmRatio
    };
  }
  
  /**
   * 找出最喜欢的色相
   */
  private findFavoriteHue(colors: string[]): number {
    const hueFreq = new Map<number, number>();
    
    colors.forEach(color => {
      const hsl = this.hexToHSL(color);
      const hueRange = Math.floor(hsl.h / 30) * 30; // 按30度分组
      hueFreq.set(hueRange, (hueFreq.get(hueRange) || 0) + 1);
    });
    
    let maxHue = 0;
    let maxCount = 0;
    hueFreq.forEach((count, hue) => {
      if (count > maxCount) {
        maxCount = count;
        maxHue = hue;
      }
    });
    
    return maxHue;
  }
  
  /**
   * HEX转HSL
   */
  private hexToHSL(hex: string): HSLColor {
    // 移除 # 号
    hex = hex.replace('#', '');
    
    // 转换为RGB
    const r = parseInt(hex.substring(0, 2), 16) / 255;
    const g = parseInt(hex.substring(2, 4), 16) / 255;
    const b = parseInt(hex.substring(4, 6), 16) / 255;
    
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
}
