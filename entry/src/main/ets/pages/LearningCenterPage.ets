/**
 * 配色学习中心
 * 提供配色理论教程和案例分析
 */
import { ThemeColors } from '../utils/ThemeColors';
import { ColorScheme } from '../models/ColorScheme';
import { ColorAnalyzer } from '../utils/ColorAnalyzer';
import promptAction from '@ohos.promptAction';

// 教程类型
interface Tutorial {
  id: string;
  title: string;
  subtitle: string;
  icon: string;
  content: string[];
  examples: string[][];
}

// 案例类型
interface ColorCase {
  id: string;
  name: string;
  colors: string[];
  category: string;
  description: string;
  analysis: string;
}

@Component
export struct LearningCenterPage {
  @State currentTab: number = 0; // 0: 教程, 1: 案例
  @State selectedTutorial: Tutorial | null = null;
  @State selectedCase: ColorCase | null = null;

  // 教程数据
  private tutorials: Tutorial[] = [
    {
      id: 'color-wheel',
      title: '色彩基础',
      subtitle: '了解色轮与色彩关系',
      icon: '🎨',
      content: [
        '色轮是理解色彩关系的基础工具，由12种基本颜色组成。',
        '三原色：红、黄、蓝 - 无法通过其他颜色混合得到',
        '三间色：橙、绿、紫 - 由两种原色混合而成',
        '六复色：由原色和间色混合而成',
        '理解色轮可以帮助你创建和谐的配色方案。'
      ],
      examples: [
        ['#FF0000', '#FFFF00', '#0000FF'], // 三原色
        ['#FF8800', '#00FF00', '#8800FF']  // 三间色
      ]
    },
    {
      id: 'complementary',
      title: '互补色配色',
      subtitle: '对比强烈的配色方案',
      icon: '⚡',
      content: [
        '互补色是色轮上相对的两种颜色，如红与绿、蓝与橙。',
        '互补色搭配产生强烈的视觉对比，充满活力和张力。',
        '适用场景：需要吸引注意力的设计，如广告、海报。',
        '使用技巧：一种颜色作为主色，另一种作为强调色。',
        '注意：避免等量使用，会产生视觉疲劳。'
      ],
      examples: [
        ['#FF0000', '#00FF00'], // 红绿
        ['#0000FF', '#FFA500'], // 蓝橙
        ['#FFFF00', '#8800FF']  // 黄紫
      ]
    },
    {
      id: 'analogous',
      title: '类似色配色',
      subtitle: '和谐统一的配色方案',
      icon: '🌈',
      content: [
        '类似色是色轮上相邻的颜色，通常包含3-5种颜色。',
        '类似色搭配和谐统一，给人舒适、自然的感觉。',
        '适用场景：需要营造温馨、平和氛围的设计。',
        '使用技巧：选择一种主色，其他颜色作为辅助。',
        '常见组合：蓝-蓝绿-绿、红-橙-黄等。'
      ],
      examples: [
        ['#0066CC', '#0099CC', '#00CCCC'], // 蓝色系
        ['#FF6600', '#FF9900', '#FFCC00'], // 橙黄系
        ['#CC0066', '#FF0066', '#FF3399']  // 红粉系
      ]
    },
    {
      id: 'triadic',
      title: '三角配色',
      subtitle: '平衡活泼的配色方案',
      icon: '△',
      content: [
        '三角配色使用色轮上等距的三种颜色。',
        '这种配色既有对比又保持平衡，充满活力但不失和谐。',
        '适用场景：需要丰富色彩但保持平衡的设计。',
        '使用技巧：选择一种主色，其他两种作为辅助色。',
        '经典组合：红-黄-蓝、橙-绿-紫等。'
      ],
      examples: [
        ['#FF0000', '#FFFF00', '#0000FF'], // 红黄蓝
        ['#FF8800', '#00FF00', '#8800FF'], // 橙绿紫
        ['#FF0066', '#00FF66', '#6600FF']  // 粉绿紫
      ]
    },
    {
      id: 'monochromatic',
      title: '单色配色',
      subtitle: '优雅简约的配色方案',
      icon: '◉',
      content: [
        '单色配色使用同一色相的不同明度和饱和度。',
        '这种配色简洁优雅，容易营造统一的视觉效果。',
        '适用场景：需要专业、简约风格的设计。',
        '使用技巧：通过明暗对比创造层次感。',
        '注意：避免过于单调，适当增加对比度。'
      ],
      examples: [
        ['#003366', '#0066CC', '#3399FF', '#99CCFF'], // 蓝色单色
        ['#660033', '#CC0066', '#FF3399', '#FFCCDD'], // 粉色单色
        ['#336600', '#66CC00', '#99FF33', '#CCFF99']  // 绿色单色
      ]
    },
    {
      id: 'tetradic',
      title: '四角配色',
      subtitle: '丰富多彩的配色方案',
      icon: '◇',
      content: [
        '四角配色使用色轮上形成矩形的四种颜色。',
        '这种配色最为丰富，但也最难掌握平衡。',
        '适用场景：需要丰富色彩的创意设计。',
        '使用技巧：选择一种主色，其他颜色作为点缀。',
        '注意：避免所有颜色等量使用，保持主次关系。'
      ],
      examples: [
        ['#FF0000', '#FFAA00', '#00FF00', '#0055FF'], // 红橙绿蓝
        ['#FF0066', '#FFCC00', '#00FF99', '#6600FF']  // 粉黄青紫
      ]
    }
  ];

  // 案例数据
  private cases: ColorCase[] = [
    {
      id: 'case-1',
      name: '科技蓝',
      colors: ['#0066FF', '#00AAFF', '#FFFFFF', '#F5F5F5'],
      category: '企业品牌',
      description: '专业、可靠、创新的科技公司配色',
      analysis: '以蓝色为主色调，传达专业和信任感。白色和浅灰色作为辅助色，营造简洁现代的视觉效果。'
    },
    {
      id: 'case-2',
      name: '活力橙',
      colors: ['#FF6600', '#FF9933', '#FFCC00', '#FFFFFF'],
      category: '运动健身',
      description: '充满活力和激情的运动品牌配色',
      analysis: '橙色系传达活力和热情，渐变的橙黄色增加层次感，白色提供视觉呼吸空间。'
    },
    {
      id: 'case-3',
      name: '自然绿',
      colors: ['#2E7D32', '#66BB6A', '#A5D6A7', '#E8F5E9'],
      category: '环保健康',
      description: '清新自然的环保品牌配色',
      analysis: '绿色系传达自然和健康，从深到浅的渐变营造舒适的视觉体验。'
    }
  ];

  build() {
    Column() {
      // 标题栏
      this.buildHeader();

      // 使用 Tabs 组件
      Tabs({ barPosition: BarPosition.Start, index: this.currentTab }) {
        TabContent() {
          this.buildTutorialContent();
        }
        .tabBar(this.buildTabBarItem('理论教程', 0))

        TabContent() {
          this.buildCaseContent();
        }
        .tabBar(this.buildTabBarItem('案例分析', 1))
      }
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .barHeight(56)
      .animationDuration(300)
      .onChange((index: number) => {
        this.currentTab = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }

  // 标题栏
  @Builder
  buildHeader() {
    Column() {
      Text('配色学习中心')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 4 })

      Text('掌握配色理论，提升设计能力')
        .fontSize(14)
        .fontColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 20, bottom: 10 })
    .backgroundColor(ThemeColors.background)
  }

  // TabBar 项
  @Builder
  buildTabBarItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentTab === index ? ThemeColors.primary : ThemeColors.textSecondary)
        .animation({ duration: 300 })
      
      // 指示器
      if (this.currentTab === index) {
        Row()
          .width(20)
          .height(3)
          .backgroundColor(ThemeColors.primary)
          .borderRadius(1.5)
          .margin({ top: 4 })
          .transition({ type: TransitionType.Insert, opacity: 0, scale: { x: 0.5 } })
      }
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 教程内容
  @Builder
  buildTutorialContent() {
    Stack() {
      if (this.selectedTutorial) {
        this.buildTutorialDetail();
      } else {
        this.buildTutorialList();
      }
    }
    .width('100%')
    .height('100%')
  }

  // 教程列表
  @Builder
  buildTutorialList() {
    List({ space: 16 }) {
      ForEach(this.tutorials, (tutorial: Tutorial) => {
        ListItem() {
          this.buildTutorialCard(tutorial);
        }
      })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 80 })
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }

  // 教程卡片
  @Builder
  buildTutorialCard(tutorial: Tutorial) {
    Row() {
      // 图标
      Column() {
        Text(tutorial.icon)
          .fontSize(32)
      }
      .width(60)
      .height(60)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(ThemeColors.background)
      .borderRadius(16)
      .margin({ right: 16 })

      // 内容
      Column({ space: 4 }) {
        Text(tutorial.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)

        Text(tutorial.subtitle)
          .fontSize(14)
          .fontColor(ThemeColors.textTertiary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 箭头
      Image($r('app.media.ic_public_arrow_right'))
        .width(20)
        .height(20)
        .fillColor(ThemeColors.textPlaceholder)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(20)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetY: 4
    })
    .onClick(() => {
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.selectedTutorial = tutorial;
      })
    })
  }

  // 教程详情
  @Builder
  buildTutorialDetail() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.textPrimary)
          .onClick(() => {
            animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
              this.selectedTutorial = null;
            })
          })
        
        Text(this.selectedTutorial?.title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor(ThemeColors.background)

      Scroll() {
        Column() {
          if (this.selectedTutorial) {
            // 头部卡片
            Column() {
              Text(this.selectedTutorial.icon)
                .fontSize(48)
                .margin({ bottom: 16 })

              Text(this.selectedTutorial.title)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.textPrimary)
                .margin({ bottom: 8 })

              Text(this.selectedTutorial.subtitle)
                .fontSize(16)
                .fontColor(ThemeColors.textTertiary)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)
            .padding(32)
            .backgroundColor(ThemeColors.backgroundCard)
            .borderRadius(24)
            .margin({ bottom: 24 })

            // 理论知识
            Column() {
              Text('理论知识')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.textPrimary)
                .margin({ bottom: 16 })

              ForEach(this.selectedTutorial.content, (paragraph: string, index: number) => {
                Row() {
                  Text((index + 1).toString())
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(ThemeColors.primary)
                    .width(24)
                    .height(24)
                    .textAlign(TextAlign.Center)
                    .backgroundColor(ThemeColors.primaryLight)
                    .borderRadius(12)
                    .margin({ right: 12, top: 2 })

                  Text(paragraph)
                    .fontSize(15)
                    .fontColor(ThemeColors.textSecondary)
                    .lineHeight(24)
                    .layoutWeight(1)
                }
                .alignItems(VerticalAlign.Top)
                .margin({ bottom: 16 })
              })
            }
            .width('100%')
            .padding(24)
            .backgroundColor(ThemeColors.backgroundCard)
            .borderRadius(24)
            .margin({ bottom: 24 })

            // 配色示例
            Column() {
              Text('配色示例')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.textPrimary)
                .margin({ bottom: 16 })

              ForEach(this.selectedTutorial.examples, (colors: string[], index: number) => {
                Column() {
                  Row() {
                    ForEach(colors, (color: string) => {
                      Column()
                        .backgroundColor(color)
                        .layoutWeight(1)
                        .height(60)
                    })
                  }
                  .width('100%')
                  .borderRadius(12)
                  .clip(true)
                  .shadow({
                    radius: 8,
                    color: 'rgba(0,0,0,0.1)',
                    offsetY: 4
                  })

                  Row({ space: 8 }) {
                    ForEach(colors, (color: string) => {
                      Text(color)
                        .fontSize(12)
                        .fontColor(ThemeColors.textPlaceholder)
                        .fontFamily('monospace')
                        .layoutWeight(1)
                        .textAlign(TextAlign.Center)
                    })
                  }
                  .width('100%')
                  .margin({ top: 8 })
                }
                .width('100%')
                .margin({ bottom: 20 })
              })
            }
            .width('100%')
            .padding(24)
            .backgroundColor(ThemeColors.backgroundCard)
            .borderRadius(24)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
    .transition({ type: TransitionType.Insert, translate: { x: '100%' } })
  }

  // 案例内容
  @Builder
  buildCaseContent() {
    Stack() {
      if (this.selectedCase) {
        this.buildCaseDetail();
      } else {
        this.buildCaseList();
      }
    }
    .width('100%')
    .height('100%')
  }

  // 案例列表
  @Builder
  buildCaseList() {
    List({ space: 20 }) {
      // 分组显示
      ListItem() {
        this.buildCaseCategory('企业品牌');
      }
      ListItem() {
        this.buildCaseCategory('运动健身');
      }
      ListItem() {
        this.buildCaseCategory('环保健康');
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 20, right: 20, top: 16, bottom: 80 })
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }

  // 案例分类
  @Builder
  buildCaseCategory(category: string) {
    Column() {
      Text(category)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 12 })

      List({ space: 12 }) {
        ForEach(this.cases.filter(c => c.category === category), (colorCase: ColorCase) => {
          ListItem() {
            this.buildCaseCard(colorCase);
          }
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  // 案例卡片
  @Builder
  buildCaseCard(colorCase: ColorCase) {
    Column() {
      // 配色预览
      Row() {
        ForEach(colorCase.colors, (color: string) => {
          Column()
            .backgroundColor(color)
            .layoutWeight(1)
            .height(100)
        })
      }
      .width('100%')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .clip(true)

      // 信息
      Column() {
        Row() {
          Text(colorCase.name)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.textPrimary)
            .layoutWeight(1)

          Text(colorCase.category)
            .fontSize(12)
            .fontColor(ThemeColors.primary)
            .backgroundColor(ThemeColors.primaryLight)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(100)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Text(colorCase.description)
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetY: 4
    })
    .onClick(() => {
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.selectedCase = colorCase;
      })
    })
  }

  // 案例详情
  @Builder
  buildCaseDetail() {
    Column() {
      // 导航栏
      Row() {
        Image($r('app.media.ic_public_back'))
          .width(24)
          .height(24)
          .fillColor(ThemeColors.textPrimary)
          .onClick(() => {
            animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
              this.selectedCase = null;
            })
          })
        
        Text(this.selectedCase?.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })
      .backgroundColor(ThemeColors.background)

      Scroll() {
        Column() {
          if (this.selectedCase) {
            // 配色预览大图
            Column() {
              Row() {
                ForEach(this.selectedCase.colors, (color: string) => {
                  Column()
                    .backgroundColor(color)
                    .layoutWeight(1)
                    .height(160)
                })
              }
              .width('100%')
              .borderRadius(24)
              .clip(true)
              .shadow({
                radius: 20,
                color: 'rgba(0,0,0,0.15)',
                offsetY: 8
              })

              // 颜色值
              Row({ space: 12 }) {
                ForEach(this.selectedCase.colors, (color: string) => {
                  Column({ space: 6 }) {
                    Circle({ width: 24, height: 24 })
                      .fill(color)
                      .stroke(ThemeColors.border)
                      .strokeWidth(1)

                    Text(color)
                      .fontSize(12)
                      .fontColor(ThemeColors.textSecondary)
                      .fontFamily('monospace')
                  }
                  .layoutWeight(1)
                })
              }
              .width('100%')
              .margin({ top: 24 })
              .padding(16)
              .backgroundColor(ThemeColors.backgroundCard)
              .borderRadius(16)
            }
            .width('100%')
            .margin({ bottom: 24 })

            // 案例信息
            Column() {
              Text('设计理念')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.textPrimary)
                .margin({ bottom: 12 })

              Text(this.selectedCase.description)
                .fontSize(15)
                .fontColor(ThemeColors.textSecondary)
                .lineHeight(24)
                .margin({ bottom: 24 })

              Text('专业分析')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.textPrimary)
                .margin({ bottom: 12 })

              Text(this.selectedCase.analysis)
                .fontSize(15)
                .fontColor(ThemeColors.textSecondary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(24)
            .backgroundColor(ThemeColors.backgroundCard)
            .borderRadius(24)
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
    .transition({ type: TransitionType.Insert, translate: { x: '100%' } })
  }
}
