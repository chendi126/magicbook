/**
 * 色彩性格数据模型
 */

// 色彩倾向维度（雷达图）
export interface ColorDimensions {
  warm: number;        // 暖色倾向 0-100
  cool: number;        // 冷色倾向 0-100
  bright: number;      // 明亮倾向 0-100
  soft: number;        // 柔和倾向 0-100
  contrast: number;    // 对比倾向 0-100
  harmony: number;     // 和谐倾向 0-100
}

// 性格标签
export enum PersonalityTag {
  CREATIVE = '创意型',
  MINIMALIST = '极简主义者',
  NATURAL = '自然系',
  ENERGETIC = '活力派',
  ELEGANT = '优雅范',
  BOLD = '大胆派',
  GENTLE = '温柔系',
  PROFESSIONAL = '专业范'
}

// 配色风格评分
export interface StyleScores {
  minimal: number;      // 极简程度
  complex: number;      // 复杂程度
  bold: number;         // 大胆程度
  conservative: number; // 保守程度
}

// 色彩性格完整数据
export class ColorPersonality {
  // 色彩DNA - 最常用的5个颜色
  topColors: string[] = [];
  
  // 六维度数据
  dimensions: ColorDimensions = {
    warm: 50,
    cool: 50,
    bright: 50,
    soft: 50,
    contrast: 50,
    harmony: 50
  };
  
  // 性格标签
  tags: PersonalityTag[] = [];
  
  // 风格评分
  styles: StyleScores = {
    minimal: 50,
    complex: 50,
    bold: 50,
    conservative: 50
  };
  
  // 统计数据
  totalSchemes: number = 0;        // 总配色数
  warmColorRatio: number = 50;     // 暖色比例
  coolColorRatio: number = 50;     // 冷色比例
  favoriteHue: number = 0;         // 最喜欢的色相（0-360）
  
  // 上次更新时间
  lastUpdated: number = Date.now();
  
  constructor() {}
}
