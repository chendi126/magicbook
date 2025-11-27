/**
 * 成就管理器
 * 负责追踪用户行为、检查成就解锁条件、持久化数据
 */

import { Achievement, AchievementData, AchievementCategory, PRESET_ACHIEVEMENTS, AchievementStatus } from '../models/Achievement';
import { PreferencesManager } from './PreferencesManager';
import promptAction from '@ohos.promptAction';

// 保存的数据结构接口
interface AchievementSaveData {
  id: string;
  progress: number;
  status: AchievementStatus;
  unlockTime?: number;
}

export class AchievementManager {
  private static instance: AchievementManager;
  private achievementData: AchievementData = new AchievementData();
  private prefsManager: PreferencesManager = PreferencesManager.getInstance();
  
  private constructor() {
    this.initializeAchievements();
  }
  
  static getInstance(): AchievementManager {
    if (!AchievementManager.instance) {
      AchievementManager.instance = new AchievementManager();
    }
    return AchievementManager.instance;
  }
  
  /**
   * 初始化成就系统
   */
  private async initializeAchievements() {
    // 加载预设成就
    PRESET_ACHIEVEMENTS.forEach(achievement => {
      this.achievementData.achievements.set(achievement.id, achievement);
    });
    
    // 从本地存储加载进度
    await this.loadProgress();
  }
  
  /**
   * 加载成就进度
   */
  private async loadProgress() {
    try {
      const jsonStr = await this.prefsManager.getSetting('achievement_progress', '[]') as string;
      const savedList = JSON.parse(jsonStr) as AchievementSaveData[];
      
      if (savedList && savedList.length > 0) {
        let unlockedCount = 0;
        
        savedList.forEach(data => {
          const achievement = this.achievementData.achievements.get(data.id);
          if (achievement) {
            achievement.progress = data.progress;
            achievement.status = data.status;
            achievement.unlockTime = data.unlockTime;
            
            if (achievement.status === AchievementStatus.UNLOCKED) {
              unlockedCount++;
            }
          }
        });
        
        this.achievementData.totalUnlocked = unlockedCount;
        console.info(`AchievementManager: 成功加载 ${savedList.length} 条成就进度`);
      }
    } catch (err) {
      console.error('AchievementManager: 加载成就进度失败: ' + JSON.stringify(err));
    }
  }
  
  /**
   * 保存成就进度
   */
  private async saveProgress() {
    try {
      const saveList: AchievementSaveData[] = [];
      
      this.achievementData.achievements.forEach(achievement => {
        // 只保存有进度的成就，减少存储空间
        if (achievement.progress > 0 || achievement.status !== AchievementStatus.LOCKED) {
          saveList.push({
            id: achievement.id,
            progress: achievement.progress,
            status: achievement.status,
            unlockTime: achievement.unlockTime
          });
        }
      });
      
      await this.prefsManager.setSetting('achievement_progress', JSON.stringify(saveList));
      console.info('AchievementManager: 成就进度已保存');
    } catch (err) {
      console.error('AchievementManager: 保存成就进度失败: ' + JSON.stringify(err));
    }
  }
  
  /**
   * 获取所有成就
   */
  getAllAchievements(): Achievement[] {
    return Array.from(this.achievementData.achievements.values());
  }
  
  /**
   * 按分类获取成就
   */
  getAchievementsByCategory(category: AchievementCategory): Achievement[] {
    return this.getAllAchievements().filter(a => a.category === category);
  }
  
  /**
   * 获取已解锁成就数量
   */
  getUnlockedCount(): number {
    return this.getAllAchievements().filter(a => a.status === 'unlocked').length;
  }
  
  /**
   * 获取总成就数量
   */
  getTotalCount(): number {
    return this.achievementData.achievements.size;
  }
  
  /**
   * 检查并更新成就进度
   */
  async checkAchievement(achievementId: string, currentValue: number): Promise<boolean> {
    const achievement = this.achievementData.achievements.get(achievementId);
    if (!achievement) {
      return false;
    }
    
    const justUnlocked = achievement.updateProgress(currentValue);
    
    if (justUnlocked) {
      this.achievementData.totalUnlocked++;
      await this.saveProgress();
      
      // 显示解锁通知
      this.showUnlockNotification(achievement);
      
      return true;
    }
    
    return false;
  }
  
  /**
   * 显示解锁通知
   */
  private showUnlockNotification(achievement: Achievement) {
    promptAction.showToast({
      message: `🎉 解锁成就：${achievement.icon} ${achievement.title}`,
      duration: 2000
    });
  }
  
  /**
   * 追踪配色收藏行为
   */
  async trackSchemeSaved(totalSchemes: number) {
    await this.checkAchievement('first_scheme', totalSchemes >= 1 ? 1 : 0);
    await this.checkAchievement('collector_10', totalSchemes);
    await this.checkAchievement('collector_50', totalSchemes);
    await this.checkAchievement('color_master', totalSchemes);
  }
  
  /**
   * 追踪每日签到
   */
  async trackDailyCheckin(consecutiveDays: number) {
    await this.checkAchievement('daily_7', consecutiveDays);
    await this.checkAchievement('daily_30', consecutiveDays);
    await this.checkAchievement('daily_100', consecutiveDays);
  }
  
  /**
   * 追踪夜间使用
   */
  async trackNightUsage(nightCount: number) {
    await this.checkAchievement('night_owl', nightCount);
  }
  
  /**
   * 追踪早晨使用
   */
  async trackMorningUsage(morningCount: number) {
    await this.checkAchievement('early_bird', morningCount);
  }
  
  /**
   * 追踪特定颜色风格收藏
   */
  async trackStyleCollection(styleType: string, count: number) {
    const achievementMap: Record<string, string> = {
      'minimalist': 'minimalist',
      'pink': 'pink_lover',
      'blue': 'blue_master',
      'green': 'green_nature',
      'warm': 'warm_heart'
    };
    
    const achievementId = achievementMap[styleType];
    if (achievementId) {
      await this.checkAchievement(achievementId, count);
    }
  }
  
  /**
   * 检查彩虹成就（收集全色系）
   */
  async checkRainbowAchievement(collectedHues: Set<string>) {
    const requiredHues = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet'];
    const collectedCount = requiredHues.filter(hue => collectedHues.has(hue)).length;
    await this.checkAchievement('rainbow_hunter', collectedCount);
  }
  
  /**
   * 追踪分享行为
   */
  async trackShare(shareCount: number) {
    await this.checkAchievement('share_master', shareCount);
  }
  
  /**
   * 获取最近解锁的成就（用于MinePage展示）
   */
  getRecentUnlocked(count: number = 3): Achievement[] {
    return this.getAllAchievements()
      .filter(a => a.status === 'unlocked' && a.unlockTime)
      .sort((a, b) => (b.unlockTime || 0) - (a.unlockTime || 0))
      .slice(0, count);
  }
  
  /**
   * 获取进行中的成就
   */
  getInProgress(): Achievement[] {
    return this.getAllAchievements()
      .filter(a => a.status === 'progress')
      .sort((a, b) => b.getProgressPercentage() - a.getProgressPercentage());
  }
}
