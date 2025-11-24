/**
 * 音乐推荐器
 * 根据配色的情感特征推荐背景音乐
 */
import { ColorAnalyzer, HSLColor } from './ColorAnalyzer';

/**
 * 音乐推荐
 */
export interface MusicRecommendation {
  title: string; // 音乐标题
  artist: string; // 艺术家
  genre: string; // 音乐类型
  mood: string; // 音乐情绪
  description: string; // 描述
  tempo: string; // 节奏（慢/中/快）
  energy: string; // 能量（低/中/高）
}

/**
 * 音乐推荐器
 */
export class MusicRecommender {
  /**
   * 根据配色推荐音乐
   */
  static recommendMusic(colors: string[]): MusicRecommendation[] {
    if (!colors || colors.length === 0) {
      return MusicRecommender.getDefaultRecommendations();
    }

    const recommendations: MusicRecommendation[] = [];

    // 分析配色特征
    const avgLightness = MusicRecommender.getAverageLightness(colors);
    const avgSaturation = MusicRecommender.getAverageSaturation(colors);
    const dominantHue = MusicRecommender.getDominantHue(colors);

    // 根据特征推荐音乐
    recommendations.push(MusicRecommender.getMusicByHue(dominantHue, avgSaturation, avgLightness));
    recommendations.push(MusicRecommender.getMusicByLightness(avgLightness, avgSaturation));
    recommendations.push(MusicRecommender.getMusicBySaturation(avgSaturation, avgLightness));

    return recommendations;
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
   * 获取主导色相
   */
  private static getDominantHue(colors: string[]): number {
    const hsl = ColorAnalyzer.hexToHsl(colors[0]);
    return hsl ? hsl.h : 0;
  }

  /**
   * 根据色相推荐音乐
   */
  private static getMusicByHue(hue: number, saturation: number, lightness: number): MusicRecommendation {
    // 红色系 (0-30, 330-360)
    if ((hue >= 0 && hue < 30) || hue >= 330) {
      return {
        title: saturation > 60 ? '热情探戈' : '温暖爵士',
        artist: saturation > 60 ? 'Astor Piazzolla' : 'Norah Jones',
        genre: saturation > 60 ? '探戈' : '爵士',
        mood: saturation > 60 ? '热情' : '温暖',
        description: saturation > 60 ? '充满激情的探戈舞曲，如同燃烧的火焰' : '温暖柔和的爵士乐，像壁炉旁的温馨时光',
        tempo: saturation > 60 ? '快' : '中',
        energy: saturation > 60 ? '高' : '中'
      };
    }
    
    // 橙黄色系 (30-60)
    if (hue >= 30 && hue < 60) {
      return {
        title: '阳光海岸',
        artist: 'Jack Johnson',
        genre: '民谣',
        mood: '愉悦',
        description: '轻快的民谣吉他，带来阳光般的愉悦心情',
        tempo: '中',
        energy: '中'
      };
    }
    
    // 绿色系 (60-150)
    if (hue >= 60 && hue < 150) {
      return {
        title: lightness > 60 ? '森林晨曲' : '雨林之声',
        artist: lightness > 60 ? 'Ludovico Einaudi' : 'Ólafur Arnalds',
        genre: '新古典',
        mood: '清新',
        description: lightness > 60 ? '清新的钢琴曲，如同森林中的第一缕阳光' : '深邃的氛围音乐，仿佛置身雨林深处',
        tempo: lightness > 60 ? '中' : '慢',
        energy: lightness > 60 ? '中' : '低'
      };
    }
    
    // 蓝色系 (150-210)
    if (hue >= 150 && hue < 210) {
      return {
        title: saturation > 60 ? '深海之旅' : '宁静海湾',
        artist: saturation > 60 ? 'Hans Zimmer' : 'Enya',
        genre: saturation > 60 ? '电影配乐' : '新世纪',
        mood: saturation > 60 ? '深邃' : '宁静',
        description: saturation > 60 ? '史诗般的配乐，如同探索深海的奇幻之旅' : '空灵的新世纪音乐，带来内心的平静',
        tempo: saturation > 60 ? '中' : '慢',
        energy: saturation > 60 ? '中' : '低'
      };
    }
    
    // 紫色系 (210-330)
    if (hue >= 210 && hue < 330) {
      return {
        title: lightness < 40 ? '午夜梦回' : '薰衣草田',
        artist: lightness < 40 ? 'Chopin' : 'Yiruma',
        genre: lightness < 40 ? '古典' : '钢琴',
        mood: lightness < 40 ? '神秘' : '浪漫',
        description: lightness < 40 ? '神秘优雅的夜曲，充满浪漫的想象' : '浪漫的钢琴曲，如同漫步薰衣草田',
        tempo: '慢',
        energy: '低'
      };
    }

    return MusicRecommender.getDefaultRecommendations()[0];
  }

  /**
   * 根据亮度推荐音乐
   */
  private static getMusicByLightness(lightness: number, saturation: number): MusicRecommendation {
    if (lightness > 70) {
      return {
        title: '晨光序曲',
        artist: 'Vivaldi',
        genre: '古典',
        mood: '明亮',
        description: '明亮欢快的古典乐，如同清晨的第一缕阳光',
        tempo: '快',
        energy: '高'
      };
    } else if (lightness < 30) {
      return {
        title: '夜的钢琴曲',
        artist: '石进',
        genre: '钢琴',
        mood: '深沉',
        description: '深沉静谧的钢琴曲，适合夜晚聆听',
        tempo: '慢',
        energy: '低'
      };
    } else {
      return {
        title: '午后时光',
        artist: 'Yann Tiersen',
        genre: '电影配乐',
        mood: '舒适',
        description: '温暖舒适的旋律，完美的午后伴侣',
        tempo: '中',
        energy: '中'
      };
    }
  }

  /**
   * 根据饱和度推荐音乐
   */
  private static getMusicBySaturation(saturation: number, lightness: number): MusicRecommendation {
    if (saturation > 70) {
      return {
        title: '活力节拍',
        artist: 'Daft Punk',
        genre: '电子',
        mood: '活力',
        description: '充满活力的电子音乐，激发创造力',
        tempo: '快',
        energy: '高'
      };
    } else if (saturation < 30) {
      return {
        title: '极简主义',
        artist: 'Max Richter',
        genre: '极简',
        mood: '淡雅',
        description: '极简主义音乐，纯净而优雅',
        tempo: '慢',
        energy: '低'
      };
    } else {
      return {
        title: '和谐之声',
        artist: 'Sigur Rós',
        genre: '后摇',
        mood: '平衡',
        description: '和谐平衡的后摇音乐，带来内心的宁静',
        tempo: '中',
        energy: '中'
      };
    }
  }

  /**
   * 获取默认推荐
   */
  private static getDefaultRecommendations(): MusicRecommendation[] {
    return [
      {
        title: '色彩交响曲',
        artist: 'Various Artists',
        genre: '综合',
        mood: '探索',
        description: '探索色彩与音乐的奇妙结合',
        tempo: '中',
        energy: '中'
      },
      {
        title: '灵感之源',
        artist: 'Various Artists',
        genre: '氛围',
        mood: '创造',
        description: '激发创造力的氛围音乐',
        tempo: '慢',
        energy: '低'
      },
      {
        title: '设计师的一天',
        artist: 'Various Artists',
        genre: '轻音乐',
        mood: '专注',
        description: '适合工作时聆听的轻音乐',
        tempo: '中',
        energy: '中'
      }
    ];
  }

  /**
   * 根据情绪获取音乐类型
   */
  static getMusicGenreByMood(mood: string): string {
    const moodToGenre: Record<string, string> = {
      '热情': '探戈',
      '温暖': '爵士',
      '愉悦': '民谣',
      '清新': '新古典',
      '宁静': '新世纪',
      '深邃': '电影配乐',
      '神秘': '古典',
      '浪漫': '钢琴',
      '活力': '电子',
      '淡雅': '极简',
      '平和': '后摇'
    };

    return moodToGenre[mood] || '综合';
  }

  /**
   * 获取音乐情绪描述
   */
  static getMoodDescription(mood: string): string {
    const descriptions: Record<string, string> = {
      '热情': '充满激情和能量，适合激发创造力',
      '温暖': '温馨舒适，带来安全感',
      '愉悦': '轻快明亮，提升心情',
      '清新': '自然纯净，让人放松',
      '宁静': '平静安详，适合冥想',
      '深邃': '深沉有力，引人思考',
      '神秘': '优雅神秘，充满想象',
      '浪漫': '柔美动人，触动心弦',
      '活力': '充满活力，激发动力',
      '淡雅': '简约优雅，纯净美好',
      '平和': '和谐平衡，内心宁静'
    };

    return descriptions[mood] || '探索音乐与色彩的美妙结合';
  }
}


