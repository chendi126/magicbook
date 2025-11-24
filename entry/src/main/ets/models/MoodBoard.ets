/**
 * 情绪板数据模型
 */
import { ColorScheme } from './ColorScheme';
import { ColorStory } from '../utils/ColorStoryGenerator';
import { MusicRecommendation } from '../utils/MusicRecommender';

/**
 * 情绪板项目类型
 */
export enum MoodBoardItemType {
  COLOR_SCHEME = 'color_scheme', // 配色方案
  IMAGE = 'image', // 图片
  TEXT = 'text', // 文字
  MUSIC = 'music', // 音乐
  STORY = 'story' // 故事
}

/**
 * 位置接口
 */
export interface Position {
  x: number;
  y: number;
}

/**
 * 尺寸接口
 */
export interface Size {
  width: number;
  height: number;
}

/**
 * 情绪板项目
 */
export interface MoodBoardItem {
  id: string; // 唯一标识
  type: MoodBoardItemType; // 类型
  content: string; // 内容（根据类型不同而不同）
  position: Position; // 位置
  size: Size; // 尺寸
  zIndex: number; // 层级
}

/**
 * 情绪板
 */
export interface MoodBoard {
  id: string; // 唯一标识
  name: string; // 名称
  colorScheme: ColorScheme; // 关联的配色方案
  story: ColorStory | null; // 配色故事
  music: MusicRecommendation[]; // 音乐推荐
  items: MoodBoardItem[]; // 情绪板项目
  description: string; // 描述
  tags: string[]; // 标签
  createTime: number; // 创建时间
  updateTime: number; // 更新时间
}

/**
 * 心情日记
 */
export interface MoodDiary {
  id: string; // 唯一标识
  date: string; // 日期（YYYY-MM-DD）
  mood: string; // 心情（开心、平静、忧郁等）
  colorScheme: ColorScheme; // 当天的配色
  note: string; // 笔记
  weather: string; // 天气
  createTime: number; // 创建时间
}

/**
 * 情绪板工具类
 */
export class MoodBoardUtils {
  /**
   * 创建新的情绪板
   */
  static createMoodBoard(name: string, colorScheme: ColorScheme): MoodBoard {
    return {
      id: MoodBoardUtils.generateId(),
      name,
      colorScheme,
      story: null,
      music: [],
      items: [],
      description: '',
      tags: [],
      createTime: Date.now(),
      updateTime: Date.now()
    };
  }

  /**
   * 创建心情日记
   */
  static createMoodDiary(mood: string, colorScheme: ColorScheme, note: string, weather: string = '☀️'): MoodDiary {
    const now = new Date();
    const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;

    return {
      id: MoodBoardUtils.generateId(),
      date: dateStr,
      mood,
      colorScheme,
      note,
      weather,
      createTime: Date.now()
    };
  }

  /**
   * 生成唯一 ID
   */
  private static generateId(): string {
    return `mb_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 添加项目到情绪板
   */
  static addItem(moodBoard: MoodBoard, item: MoodBoardItem): MoodBoard {
    const newItems: MoodBoardItem[] = [];
    for (let i = 0; i < moodBoard.items.length; i++) {
      newItems.push(moodBoard.items[i]);
    }
    newItems.push(item);

    return {
      id: moodBoard.id,
      name: moodBoard.name,
      colorScheme: moodBoard.colorScheme,
      story: moodBoard.story,
      music: moodBoard.music,
      items: newItems,
      description: moodBoard.description,
      tags: moodBoard.tags,
      createTime: moodBoard.createTime,
      updateTime: Date.now()
    };
  }

  /**
   * 移除项目
   */
  static removeItem(moodBoard: MoodBoard, itemId: string): MoodBoard {
    const newItems: MoodBoardItem[] = moodBoard.items.filter(item => item.id !== itemId);

    return {
      id: moodBoard.id,
      name: moodBoard.name,
      colorScheme: moodBoard.colorScheme,
      story: moodBoard.story,
      music: moodBoard.music,
      items: newItems,
      description: moodBoard.description,
      tags: moodBoard.tags,
      createTime: moodBoard.createTime,
      updateTime: Date.now()
    };
  }

  /**
   * 更新项目
   */
  static updateItem(moodBoard: MoodBoard, itemId: string, itemName: string, itemContent: string): MoodBoard {
    const newItems: MoodBoardItem[] = [];
    for (let i = 0; i < moodBoard.items.length; i++) {
      const item = moodBoard.items[i];
      if (item.id === itemId) {
        newItems.push({
          id: item.id,
          type: item.type,
          content: itemContent,
          position: item.position,
          size: item.size,
          zIndex: item.zIndex
        });
      } else {
        newItems.push(item);
      }
    }

    return {
      id: moodBoard.id,
      name: moodBoard.name,
      colorScheme: moodBoard.colorScheme,
      story: moodBoard.story,
      music: moodBoard.music,
      items: newItems,
      description: moodBoard.description,
      tags: moodBoard.tags,
      createTime: moodBoard.createTime,
      updateTime: Date.now()
    };
  }

  /**
   * 获取心情颜色
   */
  static getMoodColor(mood: string): string {
    const moodColors: Record<string, string> = {
      '开心': '#FFD700',
      '平静': '#87CEEB',
      '忧郁': '#4682B4',
      '兴奋': '#FF6347',
      '放松': '#98FB98',
      '焦虑': '#FF8C00',
      '感动': '#FFB6C1',
      '愤怒': '#DC143C',
      '期待': '#9370DB',
      '满足': '#F0E68C'
    };

    return moodColors[mood] || '#808080';
  }

  /**
   * 获取心情图标
   */
  static getMoodIcon(mood: string): string {
    const moodIcons: Record<string, string> = {
      '开心': '😊',
      '平静': '😌',
      '忧郁': '😔',
      '兴奋': '🤩',
      '放松': '😎',
      '焦虑': '😰',
      '感动': '🥺',
      '愤怒': '😠',
      '期待': '🤗',
      '满足': '😇'
    };

    return moodIcons[mood] || '😐';
  }
}

