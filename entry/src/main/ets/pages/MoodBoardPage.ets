/**
 * 配色情绪板页面
 * 将配色与故事、音乐、图片结合，创建完整的情绪板
 */
import { ColorScheme } from '../models/ColorScheme';
import { ColorStory, ColorStoryGenerator } from '../utils/ColorStoryGenerator';
import { MusicRecommendation, MusicRecommender } from '../utils/MusicRecommender';
import { MoodDiary, MoodBoardUtils } from '../models/MoodBoard';
import { DatabaseManager } from '../database/DatabaseManager';
import { ThemeColors } from '../utils/ThemeColors';
import { MoodDiaryDialog } from '../components/MoodDiaryDialog';
import promptAction from '@ohos.promptAction';

@Component
export struct MoodBoardPage {
  @State colorSchemes: ColorScheme[] = []; // 所有配色方案
  @State selectedScheme: ColorScheme | null = null; // 选中的配色方案
  @State currentStory: ColorStory | null = null; // 当前故事
  @State musicRecommendations: MusicRecommendation[] = []; // 音乐推荐
  @State moodDiaries: MoodDiary[] = []; // 心情日记
  @State filteredDiaries: MoodDiary[] = []; // 筛选后的日记
  @State currentTab: number = 0; // 当前标签页：0-故事 1-音乐 2-日记
  @State showSchemeSelector: boolean = false; // 显示配色选择器
  @State filterMood: string = '全部'; // 筛选心情
  @State sortOrder: string = '最新'; // 排序方式
  @State moodStatistics: Map<string, number> = new Map(); // 心情统计

  private dbManager: DatabaseManager = DatabaseManager.getInstance();
  private diaryDialogController: CustomDialogController | null = null;

  async aboutToAppear() {
    await this.loadColorSchemes();
    await this.loadMoodDiaries();
    await this.loadMoodStatistics();
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader();

      // 配色选择区
      if (!this.selectedScheme) {
        this.buildSchemeSelector();
      } else {
        Column() {
          // 配色预览卡片
          this.buildSchemePreview();

          // 标签页切换
          this.buildTabBar();

          // 内容区域
          Scroll() {
            Column() {
              if (this.currentTab === 0) {
                this.buildStoryContent();
              } else if (this.currentTab === 1) {
                this.buildMusicContent();
              } else if (this.currentTab === 2) {
                this.buildDiaryContent();
              }
            }
            .width('100%')
            .padding(16)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Auto)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }

  // ========== 组件构建方法 ==========

  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text('配色情绪板')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
        Text('Color Mood Board')
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.selectedScheme) {
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Row({ space: 4 }) {
            Text('切换配色')
              .fontSize(14)
              .fontColor('#FFFFFF')
            Text('🎨')
              .fontSize(14)
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        }
        .backgroundColor(ThemeColors.primary)
        .height(36)
        .onClick(() => {
          animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
            this.selectedScheme = null;
            this.currentStory = null;
            this.musicRecommendations = [];
          })
        })
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 20, bottom: 16 })
    .backgroundColor(ThemeColors.background)
  }

  @Builder
  buildSchemeSelector() {
    Column({ space: 24 }) {
      Column({ space: 8 }) {
        Text('选择一个配色方案')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
        Text('开启你的情绪创作之旅')
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 24, right: 24, top: 20 })

      if (this.colorSchemes.length === 0) {
        Column({ space: 16 }) {
          Image($r('app.media.ic_screenshot_squares')) // Assuming an empty state image exists, or use emoji
            .width(120)
            .height(120)
            .opacity(0.5)
          
          Text('还没有配色方案')
            .fontSize(16)
            .fontColor(ThemeColors.textTertiary)
            .fontWeight(FontWeight.Medium)
          
          Button('去创建')
            .backgroundColor(ThemeColors.primary)
            .fontColor('#FFFFFF')
            .height(40)
            .width(120)
            .onClick(() => {
              // Navigation logic would go here
            })
        }
        .width('100%')
        .height('60%')
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 16 }) {
          ForEach(this.colorSchemes, (scheme: ColorScheme) => {
            ListItem() {
              this.buildSchemeCard(scheme);
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 24, right: 24, bottom: 24 })
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  buildSchemeCard(scheme: ColorScheme) {
    Column() {
      // 配色预览条
      Row() {
        ForEach(scheme.colors, (color: string) => {
          Rect()
            .width(`${100 / scheme.colors.length}%`)
            .height(100)
            .fill(color)
        })
      }
      .width('100%')
      .height(100)
      .clip(true)

      // 方案信息
      Row() {
        Column({ space: 4 }) {
          Text(scheme.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.textPrimary)
          Text(`${scheme.colors.length} 种颜色`)
            .fontSize(12)
            .fontColor(ThemeColors.textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
        
        Image($r('app.media.ic_public_arrow_right')) // Assuming icon exists, or use text >
          .width(20)
          .height(20)
          .fillColor(ThemeColors.textTertiary)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(ThemeColors.backgroundCard)
    }
    .width('100%')
    .borderRadius(16)
    .clip(true)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
        this.selectScheme(scheme);
      })
    })
  }

  @Builder
  buildSchemePreview() {
    Row() {
      // 方案名称
      Column({ space: 4 }) {
        Text(this.selectedScheme!.name)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
        
        Text('当前配色')
          .fontSize(12)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 配色预览 (圆形)
      Row({ space: -8 }) {
        ForEach(this.selectedScheme!.colors, (color: string) => {
          Circle({ width: 36, height: 36 })
            .fill(color)
            .stroke(ThemeColors.background)
            .strokeWidth(2)
            .shadow({
              radius: 4,
              color: 'rgba(0, 0, 0, 0.1)',
              offsetX: 0,
              offsetY: 2
            })
        })
      }
      .padding({ right: 8 })
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 16, bottom: 8 })
    .backgroundColor(ThemeColors.background)
    .margin({ bottom: 24 })
  }

  @Builder
  buildTabBar() {
    Row() {
      this.buildTabItem('📖 故事', 0);
      this.buildTabItem('🎵 音乐', 1);
      this.buildTabItem('📔 日记', 2);
    }
    .width('90%')
    .height(56)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(28)
    .shadow({
      radius: 16,
      color: 'rgba(0, 0, 0, 0.08)',
      offsetX: 0,
      offsetY: 4
    })
    .margin({ bottom: 16 })
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  buildTabItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentTab === index ? ThemeColors.primary : ThemeColors.textSecondary)
        .animation({ duration: 300 })

      if (this.currentTab === index) {
        Circle({ width: 6, height: 6 })
          .fill(ThemeColors.primary)
          .margin({ top: 4 })
      }
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.currentTab = index;
      })
    })
  }

  @Builder
  buildStoryContent() {
    if (!this.currentStory) {
      Column({ space: 16 }) {
        LoadingProgress()
          .width(48)
          .height(48)
          .color(ThemeColors.primary)
        Text('正在编织色彩故事...')
          .fontSize(14)
          .fontColor(ThemeColors.textTertiary)
      }
      .width('100%')
      .padding(60)
      .justifyContent(FlexAlign.Center)
    } else {
      Column({ space: 24 }) {
        // 故事标题卡片
        Column({ space: 16 }) {
          Text(this.currentStory.title)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.textPrimary)
            .width('100%')

          Row({ space: 8 }) {
            this.buildTag(this.currentStory.season, ThemeColors.primaryLight, ThemeColors.primary)
            this.buildTag(this.currentStory.timeOfDay, ThemeColors.backgroundSecondary, ThemeColors.textSecondary)
            this.buildTag(this.currentStory.emotion, ThemeColors.backgroundSecondary, ThemeColors.textSecondary)
          }
          .width('100%')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(ThemeColors.backgroundCard)
        .borderRadius(24)
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.05)',
          offsetX: 0,
          offsetY: 4
        })

        // 故事描述
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text('📖')
              .fontSize(20)
            Text('故事')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.textPrimary)
          }

          Text(this.currentStory.description)
            .fontSize(16)
            .fontColor(ThemeColors.textSecondary)
            .lineHeight(28)
            .letterSpacing(0.5)
        }
        .width('100%')
        .padding(24)
        .backgroundColor(ThemeColors.backgroundCard)
        .borderRadius(24)
        .alignItems(HorizontalAlign.Start)
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.05)',
          offsetX: 0,
          offsetY: 4
        })

        // 场景描述
        Column({ space: 12 }) {
          Row({ space: 8 }) {
            Text('🏞️')
              .fontSize(20)
            Text('场景')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.textPrimary)
          }

          Text(this.currentStory.scene)
            .fontSize(16)
            .fontColor(ThemeColors.textSecondary)
            .lineHeight(28)
        }
        .width('100%')
        .padding(24)
        .backgroundColor(ThemeColors.backgroundCard)
        .borderRadius(24)
        .alignItems(HorizontalAlign.Start)
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.05)',
          offsetX: 0,
          offsetY: 4
        })

        // 关键词标签云
        Column({ space: 16 }) {
          Row({ space: 8 }) {
            Text('✨')
              .fontSize(20)
            Text('灵感关键词')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.textPrimary)
          }

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.currentStory.keywords, (keyword: string) => {
              Text(keyword)
                .fontSize(14)
                .fontColor(ThemeColors.primary)
                .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                .backgroundColor(ThemeColors.primaryLight)
                .borderRadius(20)
                .margin({ right: 12, bottom: 12 })
                .fontWeight(FontWeight.Medium)
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(24)
        .backgroundColor(ThemeColors.backgroundCard)
        .borderRadius(24)
        .alignItems(HorizontalAlign.Start)
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.05)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .padding({ bottom: 24 })
    }
  }

  @Builder
  buildTag(text: string, bgColor: ResourceColor, textColor: ResourceColor) {
    Text(text)
      .fontSize(12)
      .fontColor(textColor)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .backgroundColor(bgColor)
      .borderRadius(12)
      .fontWeight(FontWeight.Medium)
  }

  @Builder
  buildMusicContent() {
    if (this.musicRecommendations.length === 0) {
      Column({ space: 16 }) {
        Text('正在生成音乐推荐...')
          .fontSize(14)
          .fontColor(ThemeColors.textTertiary)
      }
      .width('100%')
      .padding(40)
      .justifyContent(FlexAlign.Center)
    } else {
      Column({ space: 16 }) {
        Text('🎵 根据配色情感为你推荐')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .width('100%')

        ForEach(this.musicRecommendations, (music: MusicRecommendation, index: number) => {
          this.buildMusicCard(music, index);
        })
      }
      .width('100%')
    }
  }

  @Builder
  buildMusicCard(music: MusicRecommendation, index: number) {
    Column({ space: 16 }) {
      Row({ space: 16 }) {
        // 音乐封面/图标
        Stack() {
          Rect()
            .width(80)
            .height(80)
            .fill(ThemeColors.backgroundSecondary)
            .borderRadius(16)
          
          Text('🎵')
            .fontSize(32)
        }

        // 音乐信息
        Column({ space: 6 }) {
          Text(music.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.textPrimary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(music.artist)
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row({ space: 8 }) {
            this.buildTag(music.genre, ThemeColors.backgroundSecondary, ThemeColors.textTertiary)
            this.buildTag(music.mood, ThemeColors.primaryLight, ThemeColors.primary)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .justifyContent(FlexAlign.Center)
        .height(80)
      }
      .width('100%')

      // 分隔线
      Divider()
        .color(ThemeColors.backgroundSecondary)
        .strokeWidth(1)

      // 音乐描述
      Text(music.description)
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .lineHeight(22)

      // 音乐属性
      Row() {
        Row({ space: 6 }) {
          Image($r('app.media.ic_screenshot_squares')) // Assuming icon exists
            .width(16)
            .height(16)
            .fillColor(ThemeColors.textTertiary)
          Text(`节奏: ${music.tempo}`)
            .fontSize(12)
            .fontColor(ThemeColors.textSecondary)
        }
        .backgroundColor(ThemeColors.backgroundSecondary)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .borderRadius(12)
        .margin({ right: 12 })

        Row({ space: 6 }) {
          Image($r('app.media.ic_screenshot_squares')) // Assuming icon exists
            .width(16)
            .height(16)
            .fillColor(ThemeColors.textTertiary)
          Text(`能量: ${music.energy}`)
            .fontSize(12)
            .fontColor(ThemeColors.textSecondary)
        }
        .backgroundColor(ThemeColors.backgroundSecondary)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .borderRadius(12)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(24)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  buildDiaryContent() {
    Column() {
      // 顶部统计区域
      if (this.moodDiaries.length > 0) {
        this.buildMoodStatistics()
      }

      // 筛选和排序栏
      if (this.moodDiaries.length > 0) {
        Row() {
          Text(`共 ${this.filteredDiaries.length} 篇日记`)
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .fontWeight(FontWeight.Medium)
          
          Blank()
          
          Row({ space: 12 }) {
            // 新增：记一笔按钮
            Row({ space: 4 }) {
              Text('+')
                .fontSize(16)
                .fontColor(ThemeColors.primary)
                .fontWeight(FontWeight.Bold)
              Text('记一笔')
                .fontSize(14)
                .fontColor(ThemeColors.primary)
                .fontWeight(FontWeight.Medium)
            }
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(ThemeColors.primaryLight)
            .borderRadius(14)
            .onClick(() => {
              animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
                this.showDiaryDialog();
              })
            })

            // 排序按钮
            Row({ space: 4 }) {
              Text(this.sortOrder)
                .fontSize(14)
                .fontColor(ThemeColors.textSecondary)
                .fontWeight(FontWeight.Medium)
              Image($r('app.media.ic_public_download_filled')) // Using existing icon
                .width(12)
                .height(12)
                .fillColor(ThemeColors.textSecondary)
            }
            .padding({ left: 8, right: 8, top: 6, bottom: 6 })
            .onClick(() => {
              this.showSortMenu();
            })
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 12 })
      }

      // 日记列表
      if (this.filteredDiaries.length === 0 && this.moodDiaries.length === 0) {
        this.buildEmptyState()
      } else if (this.filteredDiaries.length === 0) {
        this.buildNoMatchState()
      } else {
        List({ space: 16 }) {
          ForEach(this.filteredDiaries, (diary: MoodDiary, index: number) => {
            ListItem() {
              this.buildTimelineItem(diary, index === this.filteredDiaries.length - 1);
            }
            .swipeAction({ end: this.buildSwipeActions(diary) })
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ bottom: 24, left: 16, right: 16 }) // Reduced bottom padding since FAB is gone
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildEmptyState() {
    Column({ space: 16 }) {
      Image($r('app.media.ic_screenshot_squares'))
        .width(120)
        .height(120)
        .opacity(0.5)
      Text('还没有心情日记')
        .fontSize(16)
        .fontColor(ThemeColors.textTertiary)
        .fontWeight(FontWeight.Medium)
      Text('记录每天的心情配色吧')
        .fontSize(14)
        .fontColor(ThemeColors.textPlaceholder)
      
      Button('写日记')
        .backgroundColor(ThemeColors.primary)
        .fontColor('#FFFFFF')
        .height(40)
        .width(120)
        .margin({ top: 16 })
        .onClick(() => {
          this.showDiaryDialog();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildNoMatchState() {
    Column({ space: 16 }) {
      Text('🔍')
        .fontSize(48)
        .opacity(0.5)
      Text('没有找到匹配的日记')
        .fontSize(16)
        .fontColor(ThemeColors.textTertiary)
        .fontWeight(FontWeight.Medium)
      Button('清除筛选')
        .fontSize(14)
        .fontColor(ThemeColors.primary)
        .backgroundColor(ThemeColors.primaryLight)
        .height(36)
        .onClick(() => {
          this.filterMood = '全部';
          this.applyFilter();
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildTimelineItem(diary: MoodDiary, isLast: boolean) {
    Row({ space: 16 }) {
      // 左侧：日期
      Column({ space: 4 }) {
        Text(diary.date.split(' ')[0].split('-')[2]) // Day
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
        Text(diary.date.split(' ')[0].substring(5, 7) + '月') // Month
          .fontSize(12)
          .fontColor(ThemeColors.textSecondary)
          .fontWeight(FontWeight.Medium)
      }
      .width(40)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 4 })

      // 右侧：内容卡片
      Column() {
        this.buildDiaryCardContent(diary)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  buildDiaryCardContent(diary: MoodDiary) {
    Column({ space: 12 }) {
      // 头部：心情和天气
      Row() {
        Row({ space: 8 }) {
          Text(MoodBoardUtils.getMoodIcon(diary.mood))
            .fontSize(28)
          
          Column({ space: 2 }) {
            Text(diary.mood)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.textPrimary)
            
            Text(`${diary.date.split(' ')[1] || ''} · ${diary.weather}`)
              .fontSize(12)
              .fontColor(ThemeColors.textSecondary)
          }
          .alignItems(HorizontalAlign.Start)
        }

        Blank()

        // 配色圆点预览
        Row({ space: -6 }) {
          ForEach(diary.colorScheme.colors, (color: string) => {
            Circle({ width: 16, height: 16 })
              .fill(color)
              .stroke(ThemeColors.background)
              .strokeWidth(1.5)
          })
        }
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      // 笔记内容
      if (diary.note) {
        Text(diary.note)
          .fontSize(15)
          .fontColor(ThemeColors.textPrimary)
          .lineHeight(24)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .opacity(0.9)
      }

      // 装饰性背景
      Row()
        .width('100%')
        .height(4)
        .borderRadius(2)
        .linearGradient({
          angle: 90,
          colors: diary.colorScheme.colors.map((c, i) => [c, i / (diary.colorScheme.colors.length - 1)])
        })
        .opacity(0.6)
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(20)
    .shadow({
      radius: 10,
      color: 'rgba(0, 0, 0, 0.04)',
      offsetX: 0,
      offsetY: 4
    })
  }

  @Builder
  buildSwipeActions(diary: MoodDiary) {
    Row({ space: 12 }) {
      // 编辑按钮
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_public_edit')) // Assuming icon exists, fallback to text if needed
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .backgroundColor('#81C784')
      .shadow({ radius: 8, color: 'rgba(129, 199, 132, 0.4)', offsetY: 4 })
      .onClick(() => {
        this.editDiary(diary);
      })

      // 删除按钮
      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.ic_public_delete')) // Assuming icon exists
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .backgroundColor('#E57373')
      .shadow({ radius: 8, color: 'rgba(229, 115, 115, 0.4)', offsetY: 4 })
      .onClick(() => {
        this.deleteDiary(diary);
      })
    }
    .padding({ left: 16 })
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildMoodStatistics() {
    Column({ space: 12 }) {
      Text('心情分布')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .padding({ left: 20, top: 8 })

      List({ space: 12 }) {
        ForEach(Array.from(this.moodStatistics.entries()), (entry: [string, number]) => {
          ListItem() {
            this.buildMoodStatItem(entry[0], entry[1]);
          }
        })
      }
      .listDirection(Axis.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(80)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
  }

  @Builder
  buildMoodStatItem(mood: string, count: number) {
    Column({ space: 8 }) {
      Text(MoodBoardUtils.getMoodIcon(mood))
        .fontSize(28)

      Text(`${count}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.filterMood === mood ? '#FFFFFF' : ThemeColors.textPrimary)
    }
    .width(64)
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.filterMood === mood ? ThemeColors.primary : ThemeColors.backgroundCard)
    .borderRadius(20)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      // 点击筛选逻辑
      if (this.filterMood === mood) {
        this.filterMood = '全部';
      } else {
        this.filterMood = mood;
      }
      this.applyFilter();
    })
    .animation({ duration: 200 })
  }



  // ========== 方法实现 ==========

  /**
   * 加载配色方案
   */
  async loadColorSchemes() {
    try {
      this.colorSchemes = await this.dbManager.getAllColorSchemes();
    } catch (err) {
      console.error('加载配色方案失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 选择配色方案
   */
  selectScheme(scheme: ColorScheme) {
    this.selectedScheme = scheme;

    // 生成故事
    this.currentStory = ColorStoryGenerator.generateStory(scheme.colors);

    // 生成音乐推荐
    this.musicRecommendations = MusicRecommender.recommendMusic(scheme.colors);
  }

  /**
   * 加载心情日记
   */
  async loadMoodDiaries() {
    try {
      this.moodDiaries = await this.dbManager.getAllMoodDiaries();
      this.applyFilter();
    } catch (err) {
      console.error('加载心情日记失败: ' + JSON.stringify(err));
      this.moodDiaries = [];
      this.filteredDiaries = [];
    }
  }

  /**
   * 加载心情统计
   */
  async loadMoodStatistics() {
    try {
      this.moodStatistics = await this.dbManager.getMoodStatistics();
    } catch (err) {
      console.error('加载心情统计失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 显示日记对话框
   */
  showDiaryDialog() {
    if (!this.selectedScheme) {
      promptAction.showToast({
        message: '请先选择配色方案',
        duration: 1500
      });
      return;
    }

    this.diaryDialogController = new CustomDialogController({
      builder: MoodDiaryDialog({
        selectedScheme: this.selectedScheme,
        onSave: (diary: MoodDiary) => {
          this.saveMoodDiary(diary);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.diaryDialogController.open();
  }

  /**
   * 保存心情日记
   */
  async saveMoodDiary(diary: MoodDiary) {
    try {
      const success = await this.dbManager.saveMoodDiary(diary);
      if (success) {
        await this.loadMoodDiaries();
        await this.loadMoodStatistics();
        promptAction.showToast({
          message: '心情日记已保存',
          duration: 1500
        });
      }
    } catch (err) {
      console.error('保存心情日记失败: ' + JSON.stringify(err));
      promptAction.showToast({
        message: '保存失败',
        duration: 1500
      });
    }
  }

  /**
   * 编辑日记
   */
  editDiary(diary: MoodDiary) {
    this.diaryDialogController = new CustomDialogController({
      builder: MoodDiaryDialog({
        isEditMode: true,
        existingDiary: diary,
        selectedScheme: diary.colorScheme,
        onSave: (updatedDiary: MoodDiary) => {
          this.updateMoodDiary(updatedDiary);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.diaryDialogController.open();
  }

  /**
   * 更新心情日记
   */
  async updateMoodDiary(diary: MoodDiary) {
    try {
      const success = await this.dbManager.updateMoodDiary(diary);
      if (success) {
        await this.loadMoodDiaries();
        await this.loadMoodStatistics();
        promptAction.showToast({
          message: '日记已更新',
          duration: 1500
        });
      }
    } catch (err) {
      console.error('更新心情日记失败: ' + JSON.stringify(err));
      promptAction.showToast({
        message: '更新失败',
        duration: 1500
      });
    }
  }

  /**
   * 删除日记
   */
  deleteDiary(diary: MoodDiary) {
    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这条心情日记吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#F44336',
        action: async () => {
          try {
            const success = await this.dbManager.deleteMoodDiary(diary.id);
            if (success) {
              await this.loadMoodDiaries();
              await this.loadMoodStatistics();
              promptAction.showToast({
                message: '日记已删除',
                duration: 1500
              });
            }
          } catch (err) {
            console.error('删除心情日记失败: ' + JSON.stringify(err));
            promptAction.showToast({
              message: '删除失败',
              duration: 1500
            });
          }
        }
      }
    });
  }

  /**
   * 应用筛选
   */
  applyFilter() {
    if (this.filterMood === '全部') {
      this.filteredDiaries = [...this.moodDiaries];
    } else {
      this.filteredDiaries = this.moodDiaries.filter(diary => diary.mood === this.filterMood);
    }

    this.applySorting();
  }

  /**
   * 应用排序
   */
  applySorting() {
    if (this.sortOrder === '最新') {
      this.filteredDiaries.sort((a, b) => b.createTime - a.createTime);
    } else if (this.sortOrder === '最早') {
      this.filteredDiaries.sort((a, b) => a.createTime - b.createTime);
    }
  }

  /**
   * 显示筛选菜单
   */
  showFilterMenu() {
    // 使用 AlertDialog 替代 ActionSheet
    const moods = ['全部', '开心', '平静', '忧郁', '兴奋', '放松', '焦虑', '感动', '愤怒', '期待', '满足'];
    let message = '选择要查看的心情类型:\n\n';
    moods.forEach((mood, index) => {
      message += `${index + 1}. ${mood}\n`;
    });

    promptAction.showToast({
      message: '请使用筛选按钮选择心情',
      duration: 2000
    });
  }

  /**
   * 显示排序菜单
   */
  showSortMenu() {
    // 切换排序方式
    if (this.sortOrder === '最新') {
      this.sortOrder = '最早';
    } else {
      this.sortOrder = '最新';
    }
    this.applySorting();

    promptAction.showToast({
      message: `已切换为: ${this.sortOrder}`,
      duration: 1500
    });
  }
}

