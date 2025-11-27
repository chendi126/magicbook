/**
 * 成就系统数据模型
 */

// 成就分类
export enum AchievementCategory {
  COLLECTION = '收集',
  ACTIVE = '活跃',
  STYLE = '风格',
  SPECIAL = '特殊'
}

// 成就状态
export enum AchievementStatus {
  LOCKED = 'locked',       // 未解锁
  UNLOCKED = 'unlocked',   // 已解锁
  IN_PROGRESS = 'progress' // 进行中
}

// 单个成就定义
export class Achievement {
  id: string;                          // 成就ID
  icon: string;                        // 图标emoji
  title: string;                       // 标题
  description: string;                 // 描述
  category: AchievementCategory;       // 分类
  status: AchievementStatus;           // 状态
  progress: number;                    // 当前进度
  target: number;                      // 目标值
  unlockTime?: number;                 // 解锁时间戳
  rarity: 'common' | 'rare' | 'epic';  // 稀有度
  
  constructor(
    id: string,
    icon: string,
    title: string,
    description: string,
    category: AchievementCategory,
    target: number,
    rarity: 'common' | 'rare' | 'epic' = 'common'
  ) {
    this.id = id;
    this.icon = icon;
    this.title = title;
    this.description = description;
    this.category = category;
    this.target = target;
    this.rarity = rarity;
    this.status = AchievementStatus.LOCKED;
    this.progress = 0;
  }
  
  // 更新进度
  updateProgress(value: number): boolean {
    this.progress = Math.min(value, this.target);
    
    if (this.progress >= this.target && this.status !== AchievementStatus.UNLOCKED) {
      this.unlock();
      return true; // 返回true表示刚刚解锁
    }
    
    if (this.progress > 0 && this.progress < this.target) {
      this.status = AchievementStatus.IN_PROGRESS;
    }
    
    return false;
  }
  
  // 解锁成就
  unlock(): void {
    this.status = AchievementStatus.UNLOCKED;
    this.unlockTime = Date.now();
    this.progress = this.target;
  }
  
  // 获取进度百分比
  getProgressPercentage(): number {
    return Math.floor((this.progress / this.target) * 100);
  }
}

// 成就数据存储
export class AchievementData {
  achievements: Map<string, Achievement> = new Map();
  totalUnlocked: number = 0;
  lastCheckTime: number = Date.now();
  
  constructor() {}
}

// 预定义成就列表
export const PRESET_ACHIEVEMENTS: Achievement[] = [
  // 收集类
  new Achievement(
    'rainbow_hunter',
    '🌈',
    '彩虹猎人',
    '收集包含红橙黄绿蓝靛紫的配色方案',
    AchievementCategory.COLLECTION,
    7,
    'epic'
  ),
  new Achievement(
    'color_master',
    '🎨',
    '配色大师',
    '收藏100个配色方案',
    AchievementCategory.COLLECTION,
    100,
    'epic'
  ),
  new Achievement(
    'collector_10',
    '⭐',
    '初出茅庐',
    '收藏10个配色方案',
    AchievementCategory.COLLECTION,
    10,
    'common'
  ),
  new Achievement(
    'collector_50',
    '💎',
    '品味独特',
    '收藏50个配色方案',
    AchievementCategory.COLLECTION,
    50,
    'rare'
  ),
  
  // 活跃类
  new Achievement(
    'daily_7',
    '📅',
    '坚持不懈',
    '连续签到7天',
    AchievementCategory.ACTIVE,
    7,
    'common'
  ),
  new Achievement(
    'daily_30',
    '🔥',
    '热情满满',
    '连续签到30天',
    AchievementCategory.ACTIVE,
    30,
    'rare'
  ),
  new Achievement(
    'daily_100',
    '👑',
    '色彩信仰',
    '连续签到100天',
    AchievementCategory.ACTIVE,
    100,
    'epic'
  ),
  new Achievement(
    'night_owl',
    '🌙',
    '夜猫子',
    '在23:00-5:00使用应用50次',
    AchievementCategory.ACTIVE,
    50,
    'rare'
  ),
  new Achievement(
    'early_bird',
    '🌅',
    '早起鸟',
    '在5:00-7:00使用应用30次',
    AchievementCategory.ACTIVE,
    30,
    'rare'
  ),
  
  // 风格类
  new Achievement(
    'minimalist',
    '🖤',
    '极简主义',
    '收藏50个黑白灰配色',
    AchievementCategory.STYLE,
    50,
    'rare'
  ),
  new Achievement(
    'pink_lover',
    '🌸',
    '粉红控',
    '收藏30个粉色系配色',
    AchievementCategory.STYLE,
    30,
    'rare'
  ),
  new Achievement(
    'blue_master',
    '🌊',
    '蓝调大师',
    '收藏30个蓝色系配色',
    AchievementCategory.STYLE,
    30,
    'rare'
  ),
  new Achievement(
    'green_nature',
    '🌿',
    '自然之子',
    '收藏30个绿色系配色',
    AchievementCategory.STYLE,
    30,
    'rare'
  ),
  new Achievement(
    'warm_heart',
    '🔆',
    '暖色之心',
    '收藏30个暖色系配色',
    AchievementCategory.STYLE,
    30,
    'rare'
  ),
  
  // 特殊类
  new Achievement(
    'first_scheme',
    '🎉',
    '初次尝试',
    '保存第一个配色方案',
    AchievementCategory.SPECIAL,
    1,
    'common'
  ),
  new Achievement(
    'share_master',
    '📤',
    '分享达人',
    '分享配色方案20次',
    AchievementCategory.SPECIAL,
    20,
    'rare'
  ),
];
