/**
 * 成就中心页面
 * 展示用户的所有成就，包括已解锁、进行中和未解锁的成就
 */

import { Achievement, AchievementCategory, AchievementStatus } from '../models/Achievement';
import { AchievementManager } from '../utils/AchievementManager';
import { ThemeColors } from '../utils/ThemeColors';
import router from '@ohos.router';

// 成就详情弹窗
@CustomDialog
struct AchievementDetailDialog {
  controller: CustomDialogController;
  @Prop achievement: Achievement;
  
  build() {
    Column() {
      // 图标背景
      Column() {
        Text(this.achievement.icon)
          .fontSize(60)
          .opacity(this.achievement.status === AchievementStatus.LOCKED ? 0.5 : 1.0)
      }
      .width(100)
      .height(100)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getBgColor())
      .borderRadius(50)
      .margin({ top: 32, bottom: 16 })
      
      // 标题
      Text(this.achievement.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 8 })
      
      // 稀有度标签
      this.buildRarityTag()
      
      // 描述
      Text(this.achievement.description)
        .fontSize(15)
        .fontColor(ThemeColors.textSecondary)
        .textAlign(TextAlign.Center)
        .margin({ top: 16, bottom: 24, left: 20, right: 20 })
        .lineHeight(22)
      
      // 进度条
      if (this.achievement.status !== AchievementStatus.LOCKED || this.achievement.progress > 0) {
        Column() {
          Row() {
            Text('当前进度')
              .fontSize(13)
              .fontColor(ThemeColors.textTertiary)
            
            Blank()
            
            Text(`${this.achievement.progress} / ${this.achievement.target}`)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.achievement.status === AchievementStatus.UNLOCKED ?
                ThemeColors.success : ThemeColors.primary)
          }
          .width('100%')
          .margin({ bottom: 8 })
          
          Progress({
            value: this.achievement.progress,
            total: this.achievement.target,
            type: ProgressType.Linear
          })
            .color(this.achievement.status === AchievementStatus.UNLOCKED ?
              ThemeColors.success : ThemeColors.primary)
            .height(8)
            .width('100%')
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .margin({ bottom: 24 })
      }
      
      // 解锁时间
      if (this.achievement.status === AchievementStatus.UNLOCKED && this.achievement.unlockTime) {
        Text(`解锁于 ${this.formatDate(this.achievement.unlockTime)}`)
          .fontSize(13)
          .fontColor(ThemeColors.textTertiary)
          .margin({ bottom: 24 })
      }
      
      // 关闭按钮
      Button('关闭')
        .width('80%')
        .height(44)
        .backgroundColor(ThemeColors.backgroundInput)
        .fontColor(ThemeColors.textPrimary)
        .onClick(() => {
          this.controller.close();
        })
        .margin({ bottom: 24 })
    }
    .width('85%')
    .backgroundColor(ThemeColors.background)
    .borderRadius(24)
  }
  
  @Builder
  buildRarityTag() {
    if (this.achievement.rarity === 'epic') {
      Text('史诗')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(ThemeColors.warning)
        .borderRadius(12)
    } else if (this.achievement.rarity === 'rare') {
      Text('稀有')
        .fontSize(12)
        .fontColor('#FFFFFF')
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(ThemeColors.purple)
        .borderRadius(12)
    } else {
      Text('普通')
        .fontSize(12)
        .fontColor(ThemeColors.textSecondary)
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor(ThemeColors.backgroundInput)
        .borderRadius(12)
    }
  }
  
  getBgColor(): string {
    if (this.achievement.status === AchievementStatus.UNLOCKED) {
      if (this.achievement.rarity === 'epic') {
        return ThemeColors.orangeLight;
      } else if (this.achievement.rarity === 'rare') {
        return ThemeColors.purpleLight;
      } else {
        return ThemeColors.successLight;
      }
    }
    return ThemeColors.backgroundInput;
  }
  
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getFullYear()}/${date.getMonth() + 1}/${date.getDate()}`;
  }
}

@Entry
@Component
struct AchievementPage {
  @State allAchievements: Achievement[] = [];
  @State filteredAchievements: Achievement[] = [];
  @State currentCategory: string = 'all'; 
  @State unlockedCount: number = 0;
  @State totalCount: number = 0;
  
  // 选中的成就
  @State selectedAchievement: Achievement | null = null;
  
  // 弹窗控制器
  dialogController: CustomDialogController = new CustomDialogController({
    builder: AchievementDetailDialog({
      achievement: this.selectedAchievement || this.allAchievements[0] // 防止空引用
    }),
    autoCancel: true,
    customStyle: true,
    alignment: DialogAlignment.Center
  });
  
  private achievementManager: AchievementManager = AchievementManager.getInstance();
  
  async aboutToAppear() {
    this.loadAchievements();
  }
  
  loadAchievements() {
    this.allAchievements = this.achievementManager.getAllAchievements();
    this.unlockedCount = this.achievementManager.getUnlockedCount();
    this.totalCount = this.achievementManager.getTotalCount();
    this.filterAchievements();
  }
  
  filterAchievements() {
    if (this.currentCategory === 'all') {
      this.filteredAchievements = this.allAchievements;
    } else {
      const categoryMap: Record<string, AchievementCategory> = {
        'collection': AchievementCategory.COLLECTION,
        'active': AchievementCategory.ACTIVE,
        'style': AchievementCategory.STYLE
      };
      
      const category = categoryMap[this.currentCategory];
      this.filteredAchievements = this.achievementManager.getAchievementsByCategory(category);
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavBar();
      
      // 进度总览
      this.buildProgressOverview();
      
      // 分类Tab
      this.buildCategoryTabs();
      
      // 成就列表
      Scroll() {
        Column() {
          ForEach(this.filteredAchievements, (achievement: Achievement) => {
            this.buildAchievementCard(achievement);
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }
  
  // 顶部导航栏
  @Builder
  buildNavBar() {
    Row() {
      Image($r('app.media.ic_public_back'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.textPrimary)
        .onClick(() => {
          router.back();
        })
      
      Text('成就中心')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // 占位，保持居中
      Row()
        .width(24)
        .height(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor(ThemeColors.background)
  }
  
  // 进度总览
  @Builder
  buildProgressOverview() {
    Column() {
      // 进度环形  
      Stack() {
        // 背景圆环
        Progress({ value: 0, total: 100, type: ProgressType.Ring })
          .width(120)
          .height(120)
          .color(ThemeColors.backgroundInput)
          .style({ strokeWidth: 12 })
        
        // 进度圆环
        Progress({
          value: (this.unlockedCount / this.totalCount) * 100,
          total: 100,
          type: ProgressType.Ring
        })
          .width(120)
          .height(120)
          .color(ThemeColors.primary)
          .style({ strokeWidth: 12 })
        
        // 中心文字
        Column() {
          Text(`${this.unlockedCount}`)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.primary)
          
          Text(`/ ${this.totalCount}`)
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .margin({ top: 4 })
        }
      }
      .margin({ top: 20, bottom: 16 })
      
      Text('已解锁成就')
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
    }
    .width('100%')
    .padding({ bottom: 24 })
    .backgroundColor(ThemeColors.background)
  }
  
  // 分类Tab
  @Builder
  buildCategoryTabs() {
    Row() {
      this.buildTabItem('全部', 'all');
      this.buildTabItem('收集', 'collection');
      this.buildTabItem('活跃', 'active');
      this.buildTabItem('风格', 'style');
    }
    .width('100%')
    .height(48)
    .padding({ left: 16, right: 16 })
    .backgroundColor(ThemeColors.background)
    .margin({ bottom: 16 })
  }
  
  @Builder
  buildTabItem(label: string, category: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(this.currentCategory === category ? FontWeight.Bold : FontWeight.Normal)
      .fontColor(this.currentCategory === category ? ThemeColors.primary : ThemeColors.textSecondary)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.currentCategory === category ? ThemeColors.primaryLight : 'transparent')
      .borderRadius(16)
      .onClick(() => {
        this.currentCategory = category;
        this.filterAchievements();
      })
  }
  
  // 成就卡片
  @Builder
  buildAchievementCard(achievement: Achievement) {
    Row() {
      // 左侧图标
      Column() {
        Text(achievement.icon)
          .fontSize(40)
          .opacity(achievement.status === AchievementStatus.LOCKED ? 0.3 : 1.0)
      }
      .width(70)
      .height(70)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getAchievementBgColor(achievement))
      .borderRadius(12)
      .margin({ right: 16 })
      
      // 右侧内容
      Column() {
        Row() {
          Text(achievement.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(achievement.status === AchievementStatus.LOCKED ?
              ThemeColors.textTertiary : ThemeColors.textPrimary)
            .layoutWeight(1)
          
          // 稀有度标识
          if (achievement.rarity === 'rare') {
            Text('稀有')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(ThemeColors.purple)
              .borderRadius(4)
          } else if (achievement.rarity === 'epic') {
            Text('史诗')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor(ThemeColors.warning)
              .borderRadius(4)
          }
        }
        .width('100%')
        .margin({ bottom: 6 })
        
        Text(achievement.description)
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
          .lineHeight(18)
          .margin({ bottom: 12 })
        
        // 进度条
        if (achievement.status !== AchievementStatus.LOCKED || achievement.progress > 0) {
          Column() {
            Row() {
              Text(`${achievement.progress} / ${achievement.target}`)
                .fontSize(11)
                .fontColor(ThemeColors.textTertiary)
                .layoutWeight(1)
              
              Text(`${achievement.getProgressPercentage()}%`)
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor(achievement.status === AchievementStatus.UNLOCKED ?
                  ThemeColors.success : ThemeColors.primary)
            }
            .width('100%')
            .margin({ bottom: 6 })
            
            // 进度条
            Row() {
              Row()
                .width(`${achievement.getProgressPercentage()}%`)
                .height('100%')
                .backgroundColor(achievement.status === AchievementStatus.UNLOCKED ?
                  ThemeColors.success : ThemeColors.primary)
                .borderRadius(3)
            }
            .width('100%')
            .height(6)
            .backgroundColor(ThemeColors.backgroundInput)
            .borderRadius(3)
          }
          .width('100%')
        }
        
        // 解锁时间
        if (achievement.status === AchievementStatus.UNLOCKED && achievement.unlockTime) {
          Text(`解锁于 ${this.formatDate(achievement.unlockTime)}`)
            .fontSize(11)
            .fontColor(ThemeColors.success)
            .margin({ top: 8 })
        }
      }
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({
      radius: achievement.status === AchievementStatus.UNLOCKED ? 8 : 4,
      color: achievement.status === AchievementStatus.UNLOCKED ?
        'rgba(52, 199, 89, 0.2)' : ThemeColors.shadowLight,
      offsetY: 2
    })
    .opacity(achievement.status === AchievementStatus.LOCKED ? 0.6 : 1.0)
    .onClick(() => {
      this.selectedAchievement = achievement;
      this.dialogController.open();
    })
  }
  
  // 获取成就背景色
  getAchievementBgColor(achievement: Achievement): string {
    if (achievement.status === AchievementStatus.UNLOCKED) {
      if (achievement.rarity === 'epic') {
        return ThemeColors.orangeLight;
      } else if (achievement.rarity === 'rare') {
        return ThemeColors.purpleLight;
      } else {
        return ThemeColors.successLight;
      }
    }
    return ThemeColors.backgroundInput;
  }
  
  // 格式化日期
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${date.getFullYear()}/${month}/${day}`;
  }
}
