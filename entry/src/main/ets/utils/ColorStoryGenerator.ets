/**
 * 配色故事生成器
 * 为配色方案生成诗意的故事和描述
 */
import { ColorAnalyzer, HSLColor } from './ColorAnalyzer';

/**
 * 配色故事
 */
export interface ColorStory {
  title: string; // 故事标题
  description: string; // 故事描述
  keywords: string[]; // 关键词
  emotion: string; // 情感标签
  scene: string; // 场景描述
  season: string; // 季节
  timeOfDay: string; // 时间段
}

/**
 * 配色故事生成器
 */
export class ColorStoryGenerator {
  /**
   * 生成配色故事
   */
  static generateStory(colors: string[]): ColorStory {
    if (!colors || colors.length === 0) {
      return ColorStoryGenerator.getDefaultStory();
    }

    // 分析配色特征
    const dominantColor = colors[0];
    const hsl = ColorAnalyzer.hexToHsl(dominantColor);

    if (!hsl) {
      return ColorStoryGenerator.getDefaultStory();
    }

    // 分析整体色调
    const avgLightness = ColorStoryGenerator.getAverageLightness(colors);
    const avgSaturation = ColorStoryGenerator.getAverageSaturation(colors);
    const colorCount = colors.length;

    // 生成故事元素
    const season = ColorStoryGenerator.getSeason(hsl);
    const timeOfDay = ColorStoryGenerator.getTimeOfDay(avgLightness);
    const emotion = ColorStoryGenerator.getEmotion(hsl, avgSaturation);
    const scene = ColorStoryGenerator.getScene(hsl, avgLightness, avgSaturation);
    const keywords = ColorStoryGenerator.getKeywords(hsl, avgLightness, avgSaturation, colorCount);

    // 生成标题和描述
    const title = ColorStoryGenerator.generateTitle(season, timeOfDay, emotion);
    const description = ColorStoryGenerator.generateDescription(scene, emotion, season, timeOfDay, colorCount);

    return {
      title,
      description,
      keywords,
      emotion,
      scene,
      season,
      timeOfDay
    };
  }

  /**
   * 获取平均亮度
   */
  private static getAverageLightness(colors: string[]): number {
    let total = 0;
    let count = 0;
    
    colors.forEach(color => {
      const hsl = ColorAnalyzer.hexToHsl(color);
      if (hsl) {
        total += hsl.l;
        count++;
      }
    });
    
    return count > 0 ? total / count : 50;
  }

  /**
   * 获取平均饱和度
   */
  private static getAverageSaturation(colors: string[]): number {
    let total = 0;
    let count = 0;
    
    colors.forEach(color => {
      const hsl = ColorAnalyzer.hexToHsl(color);
      if (hsl) {
        total += hsl.s;
        count++;
      }
    });
    
    return count > 0 ? total / count : 50;
  }

  /**
   * 根据色相判断季节
   */
  private static getSeason(hsl: HSLColor): string {
    const h = hsl.h;
    const s = hsl.s;
    const l = hsl.l;

    // 春天：绿色、粉色系
    if ((h >= 80 && h <= 140) || (h >= 330 && h <= 360)) {
      return '春天';
    }
    // 夏天：蓝色、青色系
    else if (h >= 180 && h <= 240) {
      return '夏天';
    }
    // 秋天：橙色、黄色系
    else if (h >= 20 && h <= 60) {
      return '秋天';
    }
    // 冬天：低饱和度或高亮度
    else if (s < 20 || l > 80 || l < 20) {
      return '冬天';
    }
    
    return '四季';
  }

  /**
   * 根据亮度判断时间段
   */
  private static getTimeOfDay(lightness: number): string {
    if (lightness >= 80) {
      return '正午';
    } else if (lightness >= 60) {
      return '清晨';
    } else if (lightness >= 40) {
      return '黄昏';
    } else if (lightness >= 20) {
      return '夜晚';
    } else {
      return '深夜';
    }
  }

  /**
   * 根据色相和饱和度判断情感
   */
  private static getEmotion(hsl: HSLColor, avgSaturation: number): string {
    const h = hsl.h;
    const s = avgSaturation;

    if (s < 20) {
      return '宁静';
    }

    if (h >= 0 && h < 30) {
      return s > 60 ? '热情' : '温暖';
    } else if (h >= 30 && h < 60) {
      return s > 60 ? '活力' : '愉悦';
    } else if (h >= 60 && h < 150) {
      return s > 60 ? '清新' : '平和';
    } else if (h >= 150 && h < 210) {
      return s > 60 ? '冷静' : '理性';
    } else if (h >= 210 && h < 270) {
      return s > 60 ? '深邃' : '优雅';
    } else if (h >= 270 && h < 330) {
      return s > 60 ? '神秘' : '浪漫';
    } else {
      return s > 60 ? '激情' : '柔和';
    }
  }

  /**
   * 根据色相、亮度、饱和度生成场景描述
   */
  private static getScene(hsl: HSLColor, avgLightness: number, avgSaturation: number): string {
    const h = hsl.h;
    const l = avgLightness;
    const s = avgSaturation;

    // 高饱和度场景
    if (s > 70) {
      if (h >= 0 && h < 30) return '燃烧的篝火';
      if (h >= 30 && h < 60) return '金色的麦田';
      if (h >= 60 && h < 150) return '翠绿的森林';
      if (h >= 150 && h < 210) return '湛蓝的海洋';
      if (h >= 210 && h < 270) return '深邃的星空';
      if (h >= 270 && h < 330) return '紫色的薰衣草田';
      return '绚烂的晚霞';
    }

    // 中等饱和度场景
    if (s > 40) {
      if (l > 70) return '明亮的天空';
      if (l > 40) return '温暖的午后';
      return '宁静的夜晚';
    }

    // 低饱和度场景
    if (l > 80) return '纯白的雪景';
    if (l > 60) return '柔和的晨雾';
    if (l > 40) return '灰色的石板路';
    return '深邃的夜色';
  }

  /**
   * 生成关键词
   */
  private static getKeywords(hsl: HSLColor, avgLightness: number, avgSaturation: number, colorCount: number): string[] {
    const keywords: string[] = [];
    const h = hsl.h;
    const l = avgLightness;
    const s = avgSaturation;

    // 色相关键词
    if (h >= 0 && h < 30) keywords.push('热情', '温暖', '活力');
    else if (h >= 30 && h < 60) keywords.push('阳光', '愉悦', '明亮');
    else if (h >= 60 && h < 150) keywords.push('自然', '清新', '生机');
    else if (h >= 150 && h < 210) keywords.push('海洋', '冷静', '理性');
    else if (h >= 210 && h < 270) keywords.push('深邃', '专业', '信任');
    else if (h >= 270 && h < 330) keywords.push('神秘', '优雅', '浪漫');
    else keywords.push('激情', '力量', '热烈');

    // 亮度关键词
    if (l > 70) keywords.push('明亮', '轻盈');
    else if (l < 30) keywords.push('深沉', '厚重');

    // 饱和度关键词
    if (s > 70) keywords.push('鲜艳', '醒目');
    else if (s < 30) keywords.push('柔和', '淡雅');

    // 颜色数量关键词
    if (colorCount >= 6) keywords.push('丰富', '多彩');
    else if (colorCount <= 3) keywords.push('简约', '精致');

    return keywords.slice(0, 8); // 最多8个关键词
  }

  /**
   * 生成标题
   */
  private static generateTitle(season: string, timeOfDay: string, emotion: string): string {
    const templates = [
      `${season}的${timeOfDay}`,
      `${emotion}的${season}`,
      `${timeOfDay}·${emotion}`,
      `${season}${timeOfDay}物语`,
      `${emotion}之${season}`,
    ];

    return templates[Math.floor(Math.random() * templates.length)];
  }

  /**
   * 生成描述
   */
  private static generateDescription(scene: string, emotion: string, season: string, timeOfDay: string, colorCount: number): string {
    const templates = [
      `在${season}的${timeOfDay}，${scene}散发着${emotion}的气息。${colorCount}种颜色交织在一起，诉说着大自然的诗意。`,
      `${scene}在${timeOfDay}时分显得格外${emotion}，${colorCount}种色彩如同${season}的乐章，奏响和谐的旋律。`,
      `这是${season}特有的${emotion}，${scene}在${timeOfDay}的光影中，用${colorCount}种颜色描绘出动人的画卷。`,
      `${timeOfDay}的${scene}，带着${season}的${emotion}，${colorCount}种色彩在此刻完美融合，宛如一首无声的诗。`,
      `${emotion}的${season}，${timeOfDay}的${scene}，${colorCount}种颜色编织成一幅温柔的梦境。`,
    ];

    return templates[Math.floor(Math.random() * templates.length)];
  }

  /**
   * 获取默认故事
   */
  private static getDefaultStory(): ColorStory {
    return {
      title: '色彩的旅程',
      description: '每一种颜色都有自己的故事，等待被发现和诉说。',
      keywords: ['探索', '发现', '创造'],
      emotion: '期待',
      scene: '未知的世界',
      season: '四季',
      timeOfDay: '任何时刻'
    };
  }

  /**
   * 生成配色历史记录的故事
   */
  static generateHistoryStory(oldColors: string[], newColors: string[]): string {
    const oldHsl = ColorAnalyzer.hexToHsl(oldColors[0]);
    const newHsl = ColorAnalyzer.hexToHsl(newColors[0]);

    if (!oldHsl || !newHsl) {
      return '配色方案经历了一次美妙的蜕变。';
    }

    const hueDiff = Math.abs(newHsl.h - oldHsl.h);
    const lightnessDiff = newHsl.l - oldHsl.l;
    const saturationDiff = newHsl.s - oldHsl.s;

    let story = '从';

    // 色相变化
    if (hueDiff > 60) {
      story += '一个色系跨越到另一个色系，';
    } else if (hueDiff > 30) {
      story += '微妙的色相调整，';
    }

    // 亮度变化
    if (lightnessDiff > 20) {
      story += '变得更加明亮，';
    } else if (lightnessDiff < -20) {
      story += '沉淀出更深的韵味，';
    }

    // 饱和度变化
    if (saturationDiff > 20) {
      story += '色彩更加鲜艳夺目';
    } else if (saturationDiff < -20) {
      story += '趋向柔和淡雅';
    } else {
      story += '保持着独特的平衡';
    }

    story += '。这是一次充满创意的演变。';

    return story;
  }
}


