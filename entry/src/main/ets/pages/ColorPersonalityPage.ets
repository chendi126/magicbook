/**
 * 色彩性格图谱页面
 * 展示用户的色彩DNA、性格分析和风格偏好
 */

import { ColorPersonality, PersonalityTag } from '../models/ColorPersonality';
import { ColorPersonalityAnalyzer } from '../utils/ColorPersonalityAnalyzer';
import { DatabaseManager } from '../database/DatabaseManager';
import { ThemeColors } from '../utils/ThemeColors';
import { RadarChart } from '../components/RadarChart';
import router from '@ohos.router';

@Entry
@Component
struct ColorPersonalityPage {
  @State personality: ColorPersonality = new ColorPersonality();
  @State isLoading: boolean = true;
  
  async aboutToAppear() {
    await this.loadPersonality();
  }
  
  async loadPersonality() {
    this.isLoading = true;
    
    try {
      // 获取所有配色方案
      const schemes = await DatabaseManager.getInstance().getAllColorSchemes();
      
      // 分析生成性格图谱
      const analyzer = ColorPersonalityAnalyzer.getInstance();
      this.personality = analyzer.analyze(schemes);
      
      console.info('色彩性格分析完成', JSON.stringify(this.personality));
    } catch (err) {
      console.error('加载色彩性格失败: ' + JSON.stringify(err));
    }
    
    this.isLoading = false;
  }
  
  build() {
    Column() {
      // 顶部导航栏
      this.buildNavBar();
      
      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color(ThemeColors.primary)
          
          Text('正在分析您的色彩性格...')
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.personality.totalSchemes === 0) {
        // 空状态
        this.buildEmptyState();
      } else {
        // 内容区
        Scroll() {
          Column() {
            // 色彩DNA卡片
            this.buildColorDNA();
            
            // 雷达图卡片
            this.buildRadarCard();
            
            // 性格标签卡片
            this.buildPersonalityTags();
            
            // 风格评分卡片
            this.buildStyleScores();
            
            // 数据统计卡片
            this.buildStatistics();
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
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
      
      Text('色彩性格图谱')
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
  
  // 色彩DNA卡片
  @Builder
  buildColorDNA() {
    Column() {
      Text('我的色彩DNA')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .width('100%')
        .margin({ bottom: 16 })
      
      // 色彩球展示
      Row() {
        ForEach(this.personality.topColors, (color: string, index: number) => {
          Column() {
            // 颜色球
            Column()
              .width(50)
              .height(50)
              .backgroundColor(color)
              .borderRadius(25)
              .shadow({
                radius: 8,
                color: 'rgba(0, 0, 0, 0.15)',
                offsetY: 4
              })
            
            // 颜色值
            Text(color.toUpperCase())
              .fontSize(10)
              .fontColor(ThemeColors.textTertiary)
              .margin({ top: 8 })
          }
          .margin({ right: index < this.personality.topColors.length - 1 ? 12 : 0 })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: 8, bottom: 8 })
      
      Text('这是您最常使用的5种颜色')
        .fontSize(13)
        .fontColor(ThemeColors.textSecondary)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: ThemeColors.shadowLight,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }
  
  // 雷达图卡片
  @Builder
  buildRadarCard() {
    Column() {
      Text('性格维度分析')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .width('100%')
        .margin({ bottom: 20 })
      
      // 雷达图
      Row() {
        RadarChart({ dimensions: this.personality.dimensions })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: 16 })
      
      Text('六维度展示您的色彩偏好特征')
        .fontSize(13)
        .fontColor(ThemeColors.textSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: ThemeColors.shadowLight,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }
  
  // 性格标签卡片
  @Builder
  buildPersonalityTags() {
    Column() {
      Text('性格标签')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .width('100%')
        .margin({ bottom: 16 })
      
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.personality.tags, (tag: PersonalityTag) => {
          Text(tag)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(ThemeColors.primary)
            .borderRadius(20)
            .margin({ right: 8, bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: ThemeColors.shadowLight,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }
  
  // 风格评分卡片
  @Builder
  buildStyleScores() {
    Column() {
      Text('风格倾向')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .width('100%')
        .margin({ bottom: 16 })
      
      this.buildStyleBar('极简', this.personality.styles.minimal, ThemeColors.primary);
      this.buildStyleBar('复杂', this.personality.styles.complex, ThemeColors.purple);
      this.buildStyleBar('大胆', this.personality.styles.bold, ThemeColors.warning);
      this.buildStyleBar('保守', this.personality.styles.conservative, ThemeColors.success);
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: ThemeColors.shadowLight,
      offsetY: 2
    })
    .margin({ bottom: 16 })
  }
  
  @Builder
  buildStyleBar(label: string, score: number, color: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor(ThemeColors.textPrimary)
          .layoutWeight(1)
        
        Text(`${score}%`)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(color)
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      // 进度条
      Row() {
        Row()
          .width(`${score}%`)
          .height('100%')
          .backgroundColor(color)
          .borderRadius(4)
      }
      .width('100%')
      .height(8)
      .backgroundColor(ThemeColors.backgroundInput)
      .borderRadius(4)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }
  
  // 数据统计卡片
  @Builder
  buildStatistics() {
    Column() {
      Text('色彩统计')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .width('100%')
        .margin({ bottom: 16 })
      
      Row() {
        this.buildStatItem('总配色数', this.personality.totalSchemes.toString());
        this.buildStatItem('暖色倾向', `${this.personality.warmColorRatio}%`);
        this.buildStatItem('冷色倾向', `${this.personality.coolColorRatio}%`);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: ThemeColors.shadowLight,
      offsetY: 2
    })
  }
  
  @Builder
  buildStatItem(label: string, value: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.primary)
      
      Text(label)
        .fontSize(12)
        .fontColor(ThemeColors.textSecondary)
        .margin({ top: 4 })
    }
  }
  
  // 空状态
  @Builder
  buildEmptyState() {
    Column() {
      Text('🎨')
        .fontSize(80)
        .margin({ bottom: 20 })
      
      Text('还没有足够的数据')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 8 })
      
      Text('至少收藏5个配色方案后\n我们才能为您生成专属的色彩性格图谱')
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .textAlign(TextAlign.Center)
        .lineHeight(22)
        .margin({ bottom: 32 })
      
      Button('去探索配色')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .backgroundColor(ThemeColors.primary)
        .height(44)
        .padding({ left: 32, right: 32 })
        .borderRadius(22)
        .onClick(() => {
          // 切换到配色库 Tab (Index = 1)
          AppStorage.SetOrCreate('CurrentTabIndex', 1);
          router.back();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}
