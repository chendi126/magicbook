// 配色库页面
import { ColorScheme, ColorSchemeUtils } from '../models/ColorScheme';
import { DatabaseManager } from '../database/DatabaseManager';
import { TagUtils } from '../models/Tag';
import promptAction from '@ohos.promptAction';
import { ExportUtils, EXPORT_FORMATS, ExportFormat } from '../utils/ExportUtils';
import { ClipboardUtils } from '../utils/ClipboardUtils';
import { ColorTheoryUtils, ColorSchemeType } from '../utils/ColorTheoryUtils';
import { SharePicker } from 'aggregated_share';
import { EmptyState } from '../components/EmptyState';
import { LoadingState } from '../components/LoadingState';
import { ThemeColors } from '../utils/ThemeColors';
import { GlassCard, ColorfulGlassCard } from '../components/GlassCard';
import { ColorCircle, OverlappingColorCircles, PrimaryColorDisplay } from '../components/ColorCircle';
import { ColorAnalyzer, ColorEmotionAnalysis, ContrastCheckResult } from '../utils/ColorAnalyzer';
import { ColorCompareDialog } from '../components/ColorCompareDialog';

// 列表项接口（用于 UI 预览）
interface ListItemData {
  title: string;
  subtitle: string;
  color: number;
}

// 配色分析对话框
@CustomDialog
struct ColorAnalysisDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: ColorAnalysisDialog()
  });
  scheme: ColorScheme = { name: '', colors: [], createTime: 0 };
  @State analysis: ColorEmotionAnalysis | null = null;
  @State showContrast: boolean = false;
  @State contrastResults: ContrastCheckResult[] = [];

  aboutToAppear() {
    this.performAnalysis();
  }

  performAnalysis() {
    // 执行情感分析
    this.analysis = ColorAnalyzer.analyzeColorEmotion(this.scheme.colors);

    // 检查对比度（检查第一个颜色与其他颜色的对比度）
    if (this.scheme.colors.length >= 2) {
      this.contrastResults = [];
      const baseColor = this.scheme.colors[0];
      for (let i = 1; i < this.scheme.colors.length; i++) {
        const result = ColorAnalyzer.checkContrast(baseColor, this.scheme.colors[i]);
        this.contrastResults.push(result);
      }
    }
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('配色分析报告')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .layoutWeight(1)

        Text('×')
          .fontSize(28)
          .fontColor(ThemeColors.textTertiary)
          .onClick(() => {
            this.controller.close();
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Scroll() {
        Column() {
          // 配色预览
          Column() {
            Text(this.scheme.name)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.textPrimary)
              .margin({ bottom: 8 })

            Row() {
              ForEach(this.scheme.colors, (color: string) => {
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
              color: ThemeColors.shadowLight,
              offsetY: 2
            })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(ThemeColors.backgroundCard)
          .borderRadius(12)
          .margin({ bottom: 16 })

          if (this.analysis) {
            // 情感分析部分
            Column() {
              Text('情感特征分析')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeColors.textPrimary)
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 12 })

              // 评分指标
              this.buildScoreItem('温暖度', this.analysis.warmth, ThemeColors.warning,
                this.analysis.warmth >= 70 ? '偏暖色调' : this.analysis.warmth <= 30 ? '偏冷色调' : '中性色调');
              this.buildScoreItem('活力度', this.analysis.energy, ThemeColors.error,
                this.analysis.energy >= 70 ? '充满活力' : this.analysis.energy <= 30 ? '沉稳柔和' : '适中平衡');
              this.buildScoreItem('专业度', this.analysis.professionalism, ThemeColors.primary,
                this.analysis.professionalism >= 70 ? '专业可靠' : '创意自由');
              this.buildScoreItem('和谐度', this.analysis.harmony, ThemeColors.success,
                this.analysis.harmony >= 85 ? '非常和谐' : this.analysis.harmony >= 70 ? '较为和谐' : '对比强烈');

              // 情感标签
              if (this.analysis.emotionTags.length > 0) {
                Column() {
                  Text('情感标签')
                    .fontSize(14)
                    .fontColor(ThemeColors.textTertiary)
                    .alignSelf(ItemAlign.Start)
                    .margin({ bottom: 8, top: 12 })

                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.analysis.emotionTags, (tag: string) => {
                      Text(tag)
                        .fontSize(13)
                        .fontColor(ThemeColors.primary)
                        .backgroundColor(ThemeColors.primaryLight)
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .borderRadius(12)
                        .margin({ right: 6, bottom: 6 })
                    })
                  }
                }
                .width('100%')
              }

              // 适用场景
              if (this.analysis.suitableScenes.length > 0) {
                Column() {
                  Text('推荐应用场景')
                    .fontSize(14)
                    .fontColor(ThemeColors.textTertiary)
                    .alignSelf(ItemAlign.Start)
                    .margin({ bottom: 8, top: 12 })

                  Flex({ wrap: FlexWrap.Wrap }) {
                    ForEach(this.analysis.suitableScenes, (scene: string) => {
                      Text(scene)
                        .fontSize(13)
                        .fontColor(ThemeColors.success)
                        .backgroundColor(ThemeColors.successLight)
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .borderRadius(12)
                        .margin({ right: 6, bottom: 6 })
                    })
                  }
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(ThemeColors.backgroundCard)
            .borderRadius(12)
            .margin({ bottom: 16 })

            // 可访问性检查
            if (this.contrastResults.length > 0) {
              Column() {
                Text('可访问性检查')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ThemeColors.textPrimary)
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 12 })

                Text(`基准颜色：${this.scheme.colors[0]}`)
                  .fontSize(13)
                  .fontColor(ThemeColors.textTertiary)
                  .alignSelf(ItemAlign.Start)
                  .margin({ bottom: 12 })

                ForEach(this.contrastResults, (result: ContrastCheckResult, index: number) => {
                  this.buildContrastItem(this.scheme.colors[index + 1], result);
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeColors.backgroundCard)
              .borderRadius(12)
            }
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 关闭按钮
      Button('关闭')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(ThemeColors.primary)
        .borderRadius(24)
        .margin({ top: 16 })
        .onClick(() => {
          this.controller.close();
        })
    }
    .width('90%')
    .constraintSize({ maxHeight: '85%' })
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(16)
    .shadow({
      radius: 20,
      color: ThemeColors.shadowMedium,
      offsetY: 10
    })
  }

  @Builder
  buildScoreItem(label: string, score: number, color: string, description: string) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontColor(ThemeColors.textSecondary)
          .layoutWeight(1)

        Text(`${score}`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(color)
      }
      .width('100%')
      .margin({ bottom: 4 })

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
      .margin({ bottom: 4 })

      Text(description)
        .fontSize(12)
        .fontColor(ThemeColors.textPlaceholder)
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  @Builder
  buildContrastItem(color: string, result: ContrastCheckResult) {
    Row() {
      // 颜色块
      Column()
        .width(40)
        .height(40)
        .backgroundColor(color)
        .borderRadius(8)
        .margin({ right: 12 })

      // 对比度信息
      Column({ space: 4 }) {
        Text(color)
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
          .fontFamily('monospace')

        Row({ space: 8 }) {
          Text(`对比度: ${result.ratio}:1`)
            .fontSize(12)
            .fontColor(ThemeColors.textTertiary)

          Text(result.level === 'excellent' ? '优秀' :
            result.level === 'good' ? '良好' :
            result.level === 'fair' ? '一般' : '较差')
            .fontSize(12)
            .fontColor(result.level === 'excellent' || result.level === 'good' ?
              ThemeColors.success : ThemeColors.warning)
            .backgroundColor(result.level === 'excellent' || result.level === 'good' ?
              ThemeColors.successLight : ThemeColors.warningLight)
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .borderRadius(8)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // WCAG 标准
      Column({ space: 4 }) {
        Row() {
          Text(result.wcagAA ? '✓' : '✗')
            .fontSize(14)
            .fontColor(result.wcagAA ? ThemeColors.success : ThemeColors.error)
            .margin({ right: 4 })
          Text('AA')
            .fontSize(12)
            .fontColor(ThemeColors.textTertiary)
        }

        Row() {
          Text(result.wcagAAA ? '✓' : '✗')
            .fontSize(14)
            .fontColor(result.wcagAAA ? ThemeColors.success : ThemeColors.error)
            .margin({ right: 4 })
          Text('AAA')
            .fontSize(12)
            .fontColor(ThemeColors.textTertiary)
        }
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(ThemeColors.backgroundInput)
    .borderRadius(8)
    .margin({ bottom: 8 })
  }
}

// 导出对话框
@CustomDialog
struct ExportDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: ExportDialog()
  });
  scheme: ColorScheme = { name: '', colors: [], createTime: 0 };
  @State selectedFormat: 'css' | 'json' | 'scss' | 'tailwind' | 'arkts' = 'arkts';
  @State exportedCode: string = '';

  aboutToAppear() {
    this.updateExportCode();
  }

  // 更新导出代码
  updateExportCode() {
    this.exportedCode = ExportUtils.export(this.scheme, this.selectedFormat);
  }

  // 复制代码
  async copyCode() {
    const success = await ClipboardUtils.copyText(this.exportedCode);
    if (success) {
      promptAction.showToast({ message: '已复制到剪贴板', duration: 1500 });
    } else {
      promptAction.showToast({ message: '复制失败', duration: 1500 });
    }
  }

  build() {
    Column() {
      // 标题
      Text('导出配色方案')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      // 配色预览
      Column() {
        Text(this.scheme.name)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })

        Row() {
          ForEach(this.scheme.colors, (color: string) => {
            Column()
              .backgroundColor(color)
              .layoutWeight(1)
              .height(40)
          })
        }
        .width('100%')
        .borderRadius(8)
        .clip(true)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F9F9F9')
      .borderRadius(8)
      .margin({ bottom: 16 })

      // 格式选择
      Text('选择导出格式')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(EXPORT_FORMATS, (format: ExportFormat) => {
          Row() {
            Text(format.icon)
              .fontSize(16)
              .margin({ right: 4 })
            Text(format.name)
              .fontSize(14)
              .fontColor(this.selectedFormat === format.type ? '#FFFFFF' : '#333333')
          }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.selectedFormat === format.type ? '#007AFF' : '#F0F0F0')
          .borderRadius(16)
          .margin({ right: 8, bottom: 8 })
          .onClick(() => {
            this.selectedFormat = format.type;
            this.updateExportCode();
          })
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 代码预览
      Text('代码预览')
        .fontSize(14)
        .fontColor('#666666')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Scroll() {
        Text(this.exportedCode)
          .fontSize(12)
          .fontColor('#333333')
          .fontFamily('monospace')
          .width('100%')
          .padding(12)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
      }
      .width('100%')
      .height(200)
      .margin({ bottom: 16 })

      // 按钮组
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .layoutWeight(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.controller.close();
          })

        Button('复制代码')
          .fontSize(16)
          .backgroundColor('#007AFF')
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.copyCode();
          })
      }
      .width('100%')
    }
    .width('85%')
    .constraintSize({ maxHeight: '80%' })
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}

// 分享对话框
@CustomDialog
struct ShareDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: ShareDialog()
  });
  scheme: ColorScheme = { name: '', colors: [], createTime: 0 };
  @State cardStyle: 'modern' | 'classic' | 'minimal' = 'modern'; // 卡片样式

  // 生成配色卡片（使用 Canvas 绘制）
  @Builder
  buildColorCard() {
    Column() {
      // 根据不同样式渲染不同的卡片
      if (this.cardStyle === 'modern') {
        this.buildModernCard();
      } else if (this.cardStyle === 'classic') {
        this.buildClassicCard();
      } else {
        this.buildMinimalCard();
      }
    }
    .id(`shareCard_${this.cardStyle}`) // 添加ID用于截图
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .padding(20)
  }

  // 现代风格卡片
  @Builder
  buildModernCard() {
    Column() {
      // 标题
      Text(this.scheme.name)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      Text(`${this.scheme.colors.length} 种颜色`)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ bottom: 20 })

      // 颜色条（大块）
      Column({ space: 12 }) {
        ForEach(this.scheme.colors, (color: string, index: number) => {
          Row() {
            // 颜色块
            Row()
              .width(60)
              .height(60)
              .backgroundColor(color)
              .borderRadius(8)
              .margin({ right: 16 })

            // 颜色信息
            Column() {
              Text(`颜色 ${index + 1}`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ bottom: 4 })

              Text(color.toUpperCase())
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
        })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 底部水印
      Text('色彩灵感收集器')
        .fontSize(12)
        .fontColor('#CCCCCC')
        .alignSelf(ItemAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // 经典风格卡片
  @Builder
  buildClassicCard() {
    Column() {
      // 标题区域
      Column() {
        Text(this.scheme.name)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 4 })

        Text(`${this.scheme.colors.length} Colors`)
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 颜色条（横向）
      Row() {
        ForEach(this.scheme.colors, (color: string) => {
          Column()
            .backgroundColor(color)
            .layoutWeight(1)
            .height(80)
        })
      }
      .width('100%')
      .borderRadius(8)
      .clip(true)
      .margin({ bottom: 12 })

      // 颜色值列表
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
        ForEach(this.scheme.colors, (color: string) => {
          Text(color.toUpperCase())
            .fontSize(11)
            .fontColor('#666666')
            .fontFamily('monospace')
            .margin({ bottom: 6 })
        })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 底部
      Text('色彩灵感收集器')
        .fontSize(11)
        .fontColor('#CCCCCC')
        .alignSelf(ItemAlign.Center)
    }
    .width('100%')
  }

  // 极简风格卡片
  @Builder
  buildMinimalCard() {
    Column() {
      // 颜色条（无间隙）
      Column() {
        ForEach(this.scheme.colors, (color: string) => {
          Row()
            .width('100%')
            .height(50)
            .backgroundColor(color)
        })
      }
      .width('100%')
      .borderRadius(8)
      .clip(true)
      .margin({ bottom: 16 })

      // 标题和颜色值
      Column() {
        Text(this.scheme.name)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 12 })

        Column({ space: 4 }) {
          ForEach(this.scheme.colors, (color: string) => {
            Text(color.toUpperCase())
              .fontSize(12)
              .fontColor('#666666')
              .fontFamily('monospace')
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }

  build() {
    Column() {
      // 标题
      Text('分享配色方案')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      // 样式选择
      Column() {
        Text('卡片样式')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ bottom: 8 })

        Row({ space: 8 }) {
          Button('现代')
            .fontSize(13)
            .backgroundColor(this.cardStyle === 'modern' ? '#007AFF' : '#F0F0F0')
            .fontColor(this.cardStyle === 'modern' ? '#FFFFFF' : '#666666')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.cardStyle = 'modern';
            })

          Button('经典')
            .fontSize(13)
            .backgroundColor(this.cardStyle === 'classic' ? '#007AFF' : '#F0F0F0')
            .fontColor(this.cardStyle === 'classic' ? '#FFFFFF' : '#666666')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.cardStyle = 'classic';
            })

          Button('极简')
            .fontSize(13)
            .backgroundColor(this.cardStyle === 'minimal' ? '#007AFF' : '#F0F0F0')
            .fontColor(this.cardStyle === 'minimal' ? '#FFFFFF' : '#666666')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .onClick(() => {
              this.cardStyle = 'minimal';
            })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 卡片预览（可滚动）
      Scroll() {
        this.buildColorCard();
      }
      .width('100%')
      .height(400)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .padding(16)
      .margin({ bottom: 16 })

      // 操作按钮
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(15)
          .backgroundColor('#F0F0F0')
          .fontColor('#666666')
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('保存图片')
          .fontSize(15)
          .backgroundColor('#34C759')
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .onClick(() => {
            this.saveImage();
          })

        Button('分享')
          .fontSize(15)
          .backgroundColor('#007AFF')
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .onClick(() => {
            this.shareCard();
          })
      }
      .width('100%')
    }
    .width('90%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  // 保存图片 - 使用分享组件的"保存到图库"功能
  saveImage() {
    const picker: SharePicker = new SharePicker({
      title: this.scheme.name,
      subTitle: `${this.scheme.colors.length} 种颜色`,
      createTime: this.scheme.createTime
    });

    // 直接拉起生成海报面板，并指定自定义组件ID
    picker.show({
      extComponentId: `shareCard_${this.cardStyle}`,
      directPoster: true,
      autoClose: true
    });
  }

  // 分享卡片 - 使用分享组件
  shareCard() {
    const picker: SharePicker = new SharePicker({
      title: this.scheme.name,
      subTitle: `${this.scheme.colors.length} 种颜色`,
      createTime: this.scheme.createTime
    });

    // 拉起分享面板，并指定自定义组件ID用于生成海报
    picker.show({
      extComponentId: `shareCard_${this.cardStyle}`,
      autoClose: true
    });
  }
}

// 颜色调整对话框
@CustomDialog
struct ColorAdjustDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: ColorAdjustDialog()
  });
  sourceScheme: ColorScheme = { name: '', colors: [], createTime: 0 };
  @State adjustedColors: string[] = [];
  @State schemeName: string = '';
  @State adjustMode: 'single' | 'all' = 'all'; // 调整模式：单色 | 全部
  @State selectedColorIndex: number = 0; // 选中的颜色索引

  // 调整参数（针对当前选中的颜色或全部颜色）
  @State hueAdjust: number = 0; // 色相调整 -180 ~ +180
  @State saturationAdjust: number = 0; // 饱和度调整 -100 ~ +100
  @State lightnessAdjust: number = 0; // 亮度调整 -100 ~ +100

  // 滚动控制器
  private scroller: Scroller = new Scroller();

  onSave?: (name: string, colors: string[]) => void;

  aboutToAppear() {
    this.adjustedColors = [...this.sourceScheme.colors];
    this.schemeName = `${this.sourceScheme.name} - 调整`;
  }

  // 应用调整
  applyAdjustment() {
    if (this.adjustMode === 'single') {
      // 单色模式：只调整选中的颜色
      const color = this.sourceScheme.colors[this.selectedColorIndex];
      this.adjustedColors[this.selectedColorIndex] = this.adjustColor(color);
    } else {
      // 全部模式：调整所有颜色
      this.adjustedColors = this.sourceScheme.colors.map((color: string) => {
        return this.adjustColor(color);
      });
    }
  }

  // 调整单个颜色
  adjustColor(hexColor: string): string {
    const rgb = ColorTheoryUtils.hexToRgb(hexColor);
    if (!rgb) return hexColor;

    let hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);

    // 应用调整
    hsl.h = (hsl.h + this.hueAdjust + 360) % 360;
    hsl.s = Math.max(0, Math.min(100, hsl.s + this.saturationAdjust));
    hsl.l = Math.max(0, Math.min(100, hsl.l + this.lightnessAdjust));

    const adjustedRgb = ColorTheoryUtils.hslToRgb(hsl.h, hsl.s, hsl.l);
    return ColorTheoryUtils.rgbToHex(adjustedRgb.r, adjustedRgb.g, adjustedRgb.b);
  }

  // 重置调整
  resetAdjustment() {
    this.hueAdjust = 0;
    this.saturationAdjust = 0;
    this.lightnessAdjust = 0;
    this.adjustedColors = [...this.sourceScheme.colors];
  }

  // 保存配色方案
  saveScheme() {
    if (!this.schemeName.trim()) {
      promptAction.showToast({ message: '请输入方案名称', duration: 1500 });
      return;
    }
    if (this.adjustedColors.length === 0) {
      promptAction.showToast({ message: '没有调整的颜色', duration: 1500 });
      return;
    }
    if (this.onSave) {
      this.onSave(this.schemeName, this.adjustedColors);
    }
    this.controller.close();
  }

  build() {
    Column() {
      // 标题
      Text('颜色调整工具')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      // 可滚动内容区域
      Scroll() {
        Column() {
          // 调整模式选择
          Column() {
            Text('调整模式')
              .fontSize(13)
              .fontColor('#666666')
              .margin({ bottom: 6 })

            Row() {
              // 全部模式
              Row() {
                Text(this.adjustMode === 'all' ? '●' : '○')
                  .fontSize(16)
                  .fontColor(this.adjustMode === 'all' ? '#FF6B6B' : '#CCCCCC')
                  .margin({ right: 4 })
                Text('调整全部')
                  .fontSize(14)
                  .fontColor(this.adjustMode === 'all' ? '#FF6B6B' : '#666666')
              }
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.adjustMode === 'all' ? '#FFE5E5' : '#F0F0F0')
              .borderRadius(16)
              .onClick(() => {
                this.adjustMode = 'all';
                this.applyAdjustment();
              })

              // 单色模式
              Row() {
                Text(this.adjustMode === 'single' ? '●' : '○')
                  .fontSize(16)
                  .fontColor(this.adjustMode === 'single' ? '#007AFF' : '#CCCCCC')
                  .margin({ right: 4 })
                Text('单色调整')
                  .fontSize(14)
                  .fontColor(this.adjustMode === 'single' ? '#007AFF' : '#666666')
              }
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor(this.adjustMode === 'single' ? '#E5F2FF' : '#F0F0F0')
              .borderRadius(16)
              .margin({ left: 8 })
              .onClick(() => {
                this.adjustMode = 'single';
                this.applyAdjustment();
              })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 12 })

          // 颜色选择器（仅在单色模式下显示）
          if (this.adjustMode === 'single') {
            Column() {
              Text('选择要调整的颜色')
                .fontSize(13)
                .fontColor('#666666')
                .margin({ bottom: 6 })

              Scroll() {
                Row() {
                  ForEach(this.sourceScheme.colors, (color: string, index: number) => {
                    Column() {
                      Row()
                        .width(50)
                        .height(50)
                        .backgroundColor(color)
                        .borderRadius(8)
                        .border({
                          width: this.selectedColorIndex === index ? 3 : 0,
                          color: '#007AFF'
                        })
                        .margin({ bottom: 4 })

                      Text(color)
                        .fontSize(10)
                        .fontColor('#666666')
                        .maxLines(1)
                    }
                    .width(60)
                    .margin({
                      right: index < this.sourceScheme.colors.length - 1 ? 12 : 0
                    })
                    .onClick(() => {
                      this.selectedColorIndex = index;
                      this.applyAdjustment();
                    })
                  })
                }
                .padding({ left: 2, right: 2 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Auto)
              .width('100%')
              .edgeEffect(EdgeEffect.Spring)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 12 })
          }

          // 调整滑块
          Column() {
            Text('调整参数')
              .fontSize(13)
              .fontColor('#666666')
              .margin({ bottom: 8 })

            // 色相滑块
            Column() {
              Row() {
                Text('色相')
                  .fontSize(12)
                  .fontColor('#666666')
                  .layoutWeight(1)
                Text(`${this.hueAdjust}°`)
                  .fontSize(12)
                  .fontColor('#007AFF')
              }
              .width('100%')
              .margin({ bottom: 4 })

              Slider({
                value: this.hueAdjust + 180,
                min: 0,
                max: 360,
                step: 1,
                style: SliderStyle.OutSet
              })
                .blockColor('#007AFF')
                .trackColor('#E0E0E0')
                .selectedColor('#007AFF')
                .width('100%')
                .onChange((value: number) => {
                  this.hueAdjust = value - 180;
                  this.applyAdjustment();
                })
            }
            .width('100%')
            .margin({ bottom: 8 })

            // 饱和度滑块
            Column() {
              Row() {
                Text('饱和度')
                  .fontSize(12)
                  .fontColor('#666666')
                  .layoutWeight(1)
                Text(`${this.saturationAdjust > 0 ? '+' : ''}${this.saturationAdjust}%`)
                  .fontSize(12)
                  .fontColor('#007AFF')
              }
              .width('100%')
              .margin({ bottom: 4 })

              Slider({
                value: this.saturationAdjust + 100,
                min: 0,
                max: 200,
                step: 1,
                style: SliderStyle.OutSet
              })
                .blockColor('#FF6B6B')
                .trackColor('#E0E0E0')
                .selectedColor('#FF6B6B')
                .width('100%')
                .onChange((value: number) => {
                  this.saturationAdjust = value - 100;
                  this.applyAdjustment();
                })
            }
            .width('100%')
            .margin({ bottom: 8 })

            // 亮度滑块
            Column() {
              Row() {
                Text('亮度')
                  .fontSize(12)
                  .fontColor('#666666')
                  .layoutWeight(1)
                Text(`${this.lightnessAdjust > 0 ? '+' : ''}${this.lightnessAdjust}%`)
                  .fontSize(12)
                  .fontColor('#007AFF')
              }
              .width('100%')
              .margin({ bottom: 4 })

              Slider({
                value: this.lightnessAdjust + 100,
                min: 0,
                max: 200,
                step: 1,
                style: SliderStyle.OutSet
              })
                .blockColor('#4ECDC4')
                .trackColor('#E0E0E0')
                .selectedColor('#4ECDC4')
                .width('100%')
                .onChange((value: number) => {
                  this.lightnessAdjust = value - 100;
                  this.applyAdjustment();
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#F8F8F8')
          .borderRadius(8)
          .margin({ bottom: 12 })

          // 预览
          Column() {
            Row() {
              Text('预览')
                .fontSize(13)
                .fontColor('#666666')
                .layoutWeight(1)

              Text('重置')
                .fontSize(12)
                .fontColor('#FF6B6B')
                .onClick(() => {
                  this.resetAdjustment();
                })
            }
            .width('100%')
            .margin({ bottom: 6 })

            // 对比预览
            Column() {
              // 原始颜色
              Column() {
                Text('原始')
                  .fontSize(11)
                  .fontColor('#999999')
                  .margin({ bottom: 4 })

                Scroll(this.scroller) {
                  Row() {
                    ForEach(this.sourceScheme.colors, (color: string) => {
                      Row()
                        .width(50)
                        .height(40)
                        .backgroundColor(color)
                        .borderRadius(4)
                        .margin({ right: 4 })
                    })
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 8 })

              // 调整后颜色
              Column() {
                Text('调整后')
                  .fontSize(11)
                  .fontColor('#007AFF')
                  .margin({ bottom: 4 })

                Scroll(this.scroller) {
                  Row() {
                    ForEach(this.adjustedColors, (color: string) => {
                      Row()
                        .width(50)
                        .height(40)
                        .backgroundColor(color)
                        .borderRadius(4)
                        .margin({ right: 4 })
                    })
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({ width: 1, color: '#E0E0E0' })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 12 })

          // 方案名称输入
          Column() {
            Text('方案名称')
              .fontSize(13)
              .fontColor('#666666')
              .margin({ bottom: 6 })

            TextInput({ text: $$this.schemeName })
              .width('100%')
              .fontSize(14)
              .padding({ left: 12, right: 12 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 12 })
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      // 按钮（固定在底部）
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .layoutWeight(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.controller.close();
          })

        Button('保存')
          .fontSize(16)
          .backgroundColor('#007AFF')
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.saveScheme();
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('88%')
    .height('75%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }
}

// UI 预览对话框
@CustomDialog
struct UIPreviewDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: UIPreviewDialog()
  });
  sourceScheme: ColorScheme = { name: '', colors: [], createTime: 0 };
  @State selectedTemplate: string = 'card'; // 选中的模板：card, button, list, form, dashboard

  aboutToAppear() {
    console.info(`[UI预览] 配色方案: ${this.sourceScheme.name}, 颜色数量: ${this.sourceScheme.colors.length}`);
    this.sourceScheme.colors.forEach((color: string, index: number) => {
      console.info(`[UI预览] 颜色 ${index}: ${color}`);
    });
  }

  // 获取配色（确保至少有5个颜色）
  getColor(index: number): string {
    // 如果配色方案有足够的颜色，直接返回
    if (this.sourceScheme.colors && index < this.sourceScheme.colors.length) {
      return this.sourceScheme.colors[index];
    }

    // 如果颜色不足，使用默认颜色补充
    const defaultColors: string[] = ['#007AFF', '#34C759', '#FF9500', '#FF3B30', '#5856D6'];

    // 如果配色方案有颜色，优先使用配色方案的颜色，不足的用默认颜色
    if (this.sourceScheme.colors && this.sourceScheme.colors.length > 0) {
      // 循环使用配色方案的颜色
      if (index < this.sourceScheme.colors.length) {
        return this.sourceScheme.colors[index];
      } else {
        // 超出范围，使用默认颜色
        return defaultColors[index % defaultColors.length];
      }
    }

    // 如果配色方案没有颜色，使用默认颜色
    return defaultColors[index % defaultColors.length];
  }

  // 获取带透明度的颜色
  getColorWithAlpha(index: number, alpha: string): string {
    const color: string = this.getColor(index);
    // 确保颜色是 # 开头的十六进制格式
    if (color.startsWith('#')) {
      return color + alpha;
    }
    return color;
  }

  build() {
    Column() {
      // 标题
      Text('UI 预览')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      // 模板选择
      Column() {
        Text('选择模板')
          .fontSize(13)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        Row() {
          this.buildTemplateButton('card', '卡片')
          this.buildTemplateButton('button', '按钮')
          this.buildTemplateButton('list', '列表')
          this.buildTemplateButton('form', '表单')
          this.buildTemplateButton('dashboard', '仪表盘')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })

      // 配色显示
      Column() {
        Text('当前配色')
          .fontSize(13)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        Row() {
          ForEach([0, 1, 2, 3, 4], (index: number) => {
            Column() {
              Row()
                .width(40)
                .height(40)
                .backgroundColor(this.getColor(index))
                .borderRadius(6)
                .margin({ bottom: 4 })

              Text(this.getColor(index))
                .fontSize(9)
                .fontColor('#666666')
                .maxLines(1)
            }
            .margin({ right: index < 4 ? 8 : 0 })
          })
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })

      // 预览区域（可滚动）
      Scroll() {
        Column() {
          if (this.selectedTemplate === 'card') {
            this.buildCardPreview()
          } else if (this.selectedTemplate === 'button') {
            this.buildButtonPreview()
          } else if (this.selectedTemplate === 'list') {
            this.buildListPreview()
          } else if (this.selectedTemplate === 'form') {
            this.buildFormPreview()
          } else if (this.selectedTemplate === 'dashboard') {
            this.buildDashboardPreview()
          }
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .padding(12)

      // 关闭按钮
      Button('关闭')
        .fontSize(16)
        .backgroundColor('#007AFF')
        .width('100%')
        .margin({ top: 12 })
        .onClick(() => {
          this.controller.close();
        })
    }
    .width('90%')
    .height('80%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  // 模板选择按钮
  @Builder
  buildTemplateButton(template: string, label: string) {
    Text(label)
      .fontSize(11)
      .fontColor(this.selectedTemplate === template ? '#FFFFFF' : '#666666')
      .padding({ left: 8, right: 8, top: 6, bottom: 6 })
      .backgroundColor(this.selectedTemplate === template ? '#007AFF' : '#E0E0E0')
      .borderRadius(6)
      .onClick(() => {
        this.selectedTemplate = template;
      })
  }

  // 卡片预览模板
  @Builder
  buildCardPreview() {
    Column() {
      Text('卡片模板预览')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      // 卡片 1
      Column() {
        Row()
          .width('100%')
          .height(120)
          .backgroundColor(this.getColor(0))
          .borderRadius({ topLeft: 8, topRight: 8 })

        Column() {
          Text('卡片标题')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getColor(0))
            .margin({ bottom: 4 })

          Text('这是卡片的描述文字，展示配色在卡片中的应用效果。')
            .fontSize(12)
            .fontColor('#666666')
            .margin({ bottom: 8 })

          Row() {
            Button('主要操作')
              .fontSize(12)
              .backgroundColor(this.getColor(0))
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
              .margin({ right: 8 })

            Button('次要操作')
              .fontSize(12)
              .backgroundColor(this.getColor(1))
              .padding({ left: 16, right: 16, top: 6, bottom: 6 })
          }
        }
        .width('100%')
        .padding(12)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 卡片 2
      Column() {
        Text('信息卡片')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Row() {
          Column() {
            Text('128')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getColor(0))
            Text('总数')
              .fontSize(11)
              .fontColor('#999999')
          }
          .layoutWeight(1)
          .backgroundColor(this.getColorWithAlpha(0, '20'))
          .padding(12)
          .borderRadius(6)

          Column() {
            Text('45')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getColor(1))
            Text('进行中')
              .fontSize(11)
              .fontColor('#999999')
          }
          .layoutWeight(1)
          .backgroundColor(this.getColorWithAlpha(1, '20'))
          .padding(12)
          .borderRadius(6)
          .margin({ left: 8 })

          Column() {
            Text('83')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getColor(2))
            Text('已完成')
              .fontSize(11)
              .fontColor('#999999')
          }
          .layoutWeight(1)
          .backgroundColor(this.getColorWithAlpha(2, '20'))
          .padding(12)
          .borderRadius(6)
          .margin({ left: 8 })
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
    .width('100%')
  }

  // 按钮预览模板
  @Builder
  buildButtonPreview() {
    Column() {
      Text('按钮模板预览')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      // 主要按钮
      Column() {
        Text('主要按钮')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        Row() {
          Button('按钮 1')
            .fontSize(14)
            .backgroundColor(this.getColor(0))
            .margin({ right: 8 })

          Button('按钮 2')
            .fontSize(14)
            .backgroundColor(this.getColor(1))
            .margin({ right: 8 })

          Button('按钮 3')
            .fontSize(14)
            .backgroundColor(this.getColor(2))
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 轮廓按钮
      Column() {
        Text('轮廓按钮')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        Row() {
          Button('按钮 1')
            .fontSize(14)
            .backgroundColor('#FFFFFF')
            .fontColor(this.getColor(0))
            .border({ width: 1, color: this.getColor(0) })
            .margin({ right: 8 })

          Button('按钮 2')
            .fontSize(14)
            .backgroundColor('#FFFFFF')
            .fontColor(this.getColor(1))
            .border({ width: 1, color: this.getColor(1) })
            .margin({ right: 8 })

          Button('按钮 3')
            .fontSize(14)
            .backgroundColor('#FFFFFF')
            .fontColor(this.getColor(2))
            .border({ width: 1, color: this.getColor(2) })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 文字按钮
      Column() {
        Text('文字按钮')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        Row() {
          Text('按钮 1')
            .fontSize(14)
            .fontColor(this.getColor(0))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })

          Text('按钮 2')
            .fontSize(14)
            .fontColor(this.getColor(1))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .margin({ right: 8 })

          Text('按钮 3')
            .fontSize(14)
            .fontColor(this.getColor(2))
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
  }

  // 列表预览模板
  @Builder
  buildListPreview() {
    Column() {
      Text('列表模板预览')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      Column() {
        ForEach([
          { title: '列表项 1', subtitle: '这是第一个列表项', color: 0 },
          { title: '列表项 2', subtitle: '这是第二个列表项', color: 1 },
          { title: '列表项 3', subtitle: '这是第三个列表项', color: 2 },
          { title: '列表项 4', subtitle: '这是第四个列表项', color: 0 }
        ], (item: ListItemData) => {
          Row() {
            Row()
              .width(4)
              .height(40)
              .backgroundColor(this.getColor(item.color))
              .borderRadius(2)
              .margin({ right: 12 })

            Column() {
              Text(item.title)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .margin({ bottom: 2 })

              Text(item.subtitle)
                .fontSize(12)
                .fontColor('#999999')
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Text('>')
              .fontSize(16)
              .fontColor(this.getColor(item.color))
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  // 表单预览模板
  @Builder
  buildFormPreview() {
    Column() {
      Text('表单模板预览')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      Column() {
        // 输入框 1
        Column() {
          Text('用户名')
            .fontSize(12)
            .fontColor(this.getColor(0))
            .margin({ bottom: 4 })

          TextInput({ placeholder: '请输入用户名' })
            .width('100%')
            .placeholderColor('#CCCCCC')
            .borderColor(this.getColor(0))
            .borderWidth(1)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })

        // 输入框 2
        Column() {
          Text('邮箱')
            .fontSize(12)
            .fontColor(this.getColor(1))
            .margin({ bottom: 4 })

          TextInput({ placeholder: '请输入邮箱' })
            .width('100%')
            .placeholderColor('#CCCCCC')
            .borderColor(this.getColor(1))
            .borderWidth(1)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })

        // 提交按钮
        Button('提交')
          .fontSize(16)
          .backgroundColor(this.getColor(0))
          .width('100%')
          .margin({ top: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
    .width('100%')
  }

  // 仪表盘预览模板
  @Builder
  buildDashboardPreview() {
    Column() {
      Text('仪表盘模板预览')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      // 统计卡片行
      Row() {
        Column() {
          Text('1,234')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getColor(0))
            .margin({ bottom: 4 })
          Text('总访问量')
            .fontSize(11)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 2, color: this.getColor(0) })

        Column() {
          Text('567')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getColor(1))
            .margin({ bottom: 4 })
          Text('新用户')
            .fontSize(11)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .border({ width: 2, color: this.getColor(1) })
        .margin({ left: 8 })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 进度卡片
      Column() {
        Text('项目进度')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .margin({ bottom: 8 })

        Column() {
          Row() {
            Text('设计阶段')
              .fontSize(12)
              .fontColor('#666666')
              .layoutWeight(1)
            Text('100%')
              .fontSize(12)
              .fontColor(this.getColor(0))
          }
          .width('100%')
          .margin({ bottom: 4 })

          Row()
            .width('100%')
            .height(6)
            .backgroundColor(this.getColor(0))
            .borderRadius(3)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Column() {
          Row() {
            Text('开发阶段')
              .fontSize(12)
              .fontColor('#666666')
              .layoutWeight(1)
            Text('65%')
              .fontSize(12)
              .fontColor(this.getColor(1))
          }
          .width('100%')
          .margin({ bottom: 4 })

          Row() {
            Row()
              .width('65%')
              .height(6)
              .backgroundColor(this.getColor(1))
              .borderRadius(3)
          }
          .width('100%')
          .height(6)
          .backgroundColor('#E0E0E0')
          .borderRadius(3)
        }
        .width('100%')
        .margin({ bottom: 8 })

        Column() {
          Row() {
            Text('测试阶段')
              .fontSize(12)
              .fontColor('#666666')
              .layoutWeight(1)
            Text('30%')
              .fontSize(12)
              .fontColor(this.getColor(2))
          }
          .width('100%')
          .margin({ bottom: 4 })

          Row() {
            Row()
              .width('30%')
              .height(6)
              .backgroundColor(this.getColor(2))
              .borderRadius(3)
          }
          .width('100%')
          .height(6)
          .backgroundColor('#E0E0E0')
          .borderRadius(3)
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FFFFFF')
      .borderRadius(8)
    }
    .width('100%')
  }
}

// 配色生成器对话框
@CustomDialog
struct ColorGeneratorDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: ColorGeneratorDialog()
  });
  sourceScheme: ColorScheme = { name: '', colors: [], createTime: 0 };
  @State selectedType: ColorSchemeType = 'complementary';
  @State generatedColors: string[] = [];
  @State schemeName: string = '';
  @State generationMode: 'single' | 'smart' = 'smart'; // 生成模式：单色 | 智能
  @State selectedBaseColor: string = ''; // 选中的基础颜色
  onSave?: (name: string, colors: string[]) => void;

  aboutToAppear() {
    // 初始化：智能模式使用主色调，单色模式使用第一个颜色
    if (this.sourceScheme.colors.length > 0) {
      const dominantColor = ColorTheoryUtils.getDominantColor(this.sourceScheme.colors);
      this.selectedBaseColor = dominantColor || this.sourceScheme.colors[0];
      this.generateColors();
      this.schemeName = `${this.sourceScheme.name} - ${this.getTypeName()}`;
    }
  }

  // 获取类型名称
  getTypeName(): string {
    switch (this.selectedType) {
      case 'complementary': return '互补色';
      case 'analogous': return '类似色';
      case 'triadic': return '三角配色';
      case 'tetradic': return '四角配色';
      case 'monochromatic': return '单色配色';
      case 'split-complementary': return '分裂互补';
      default: return '';
    }
  }

  // 生成配色
  generateColors() {
    if (this.sourceScheme.colors.length === 0) return;

    if (this.generationMode === 'smart') {
      // 智能模式：基于整体配色方案生成
      this.generatedColors = ColorTheoryUtils.generateFromScheme(this.sourceScheme.colors, this.selectedType);
    } else {
      // 单色模式：基于选中的颜色生成
      this.generatedColors = ColorTheoryUtils.generateColorScheme(this.selectedBaseColor, this.selectedType);
    }

    const modeText = this.generationMode === 'smart' ? '智能' : '单色';
    this.schemeName = `${this.sourceScheme.name} - ${this.getTypeName()}(${modeText})`;
  }

  // 保存配色方案
  saveScheme() {
    if (!this.schemeName.trim()) {
      promptAction.showToast({ message: '请输入方案名称', duration: 1500 });
      return;
    }
    if (this.generatedColors.length === 0) {
      promptAction.showToast({ message: '没有生成的颜色', duration: 1500 });
      return;
    }
    if (this.onSave) {
      this.onSave(this.schemeName, this.generatedColors);
    }
    this.controller.close();
  }

  build() {
    Column() {
      // 标题
      Text('配色方案生成器')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 12 })

      // 可滚动内容区域
      Scroll() {
        Column() {

      // 生成模式选择
      Column() {
        Row() {
          Text('生成模式')
            .fontSize(13)
            .fontColor('#666666')

          Text(this.generationMode === 'smart' ? '（分析整体风格）' : '（基于单个颜色）')
            .fontSize(11)
            .fontColor('#999999')
            .margin({ left: 6 })
        }
        .margin({ bottom: 6 })

        Row() {
          // 智能模式
          Row() {
            Text(this.generationMode === 'smart' ? '●' : '○')
              .fontSize(16)
              .fontColor(this.generationMode === 'smart' ? '#FF6B6B' : '#CCCCCC')
              .margin({ right: 4 })
            Text('智能生成')
              .fontSize(14)
              .fontColor(this.generationMode === 'smart' ? '#FF6B6B' : '#666666')
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.generationMode === 'smart' ? '#FFE5E5' : '#F0F0F0')
          .borderRadius(16)
          .onClick(() => {
            this.generationMode = 'smart';
            this.generateColors();
          })

          // 单色模式
          Row() {
            Text(this.generationMode === 'single' ? '●' : '○')
              .fontSize(16)
              .fontColor(this.generationMode === 'single' ? '#007AFF' : '#CCCCCC')
              .margin({ right: 4 })
            Text('单色生成')
              .fontSize(14)
              .fontColor(this.generationMode === 'single' ? '#007AFF' : '#666666')
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.generationMode === 'single' ? '#E5F2FF' : '#F0F0F0')
          .borderRadius(16)
          .margin({ left: 8 })
          .onClick(() => {
            this.generationMode = 'single';
            this.generateColors();
          })
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })

      // 基础颜色（仅在单色模式下显示）
      if (this.generationMode === 'single') {
        Column() {
          Text('选择基础颜色')
            .fontSize(13)
            .fontColor('#666666')
            .margin({ bottom: 6 })

          // 横向滚动的颜色选择器
          Scroll() {
            Row() {
              ForEach(this.sourceScheme.colors, (color: string, index: number) => {
                Column() {
                  Row()
                    .width(50)
                    .height(50)
                    .backgroundColor(color)
                    .borderRadius(8)
                    .border({
                      width: this.selectedBaseColor === color ? 3 : 0,
                      color: '#007AFF'
                    })
                    .margin({ bottom: 4 })

                  Text(color)
                    .fontSize(10)
                    .fontColor('#666666')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width(60)
                .margin({
                  right: index < this.sourceScheme.colors.length - 1 ? 12 : 0
                })
                .onClick(() => {
                  this.selectedBaseColor = color;
                  this.generateColors();
                })
              })
            }
            .padding({ left: 2, right: 2 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Auto)
          .width('100%')
          .edgeEffect(EdgeEffect.Spring)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 12 })
      }

      // 生成类型选择
      Column() {
        Text('生成类型')
          .fontSize(13)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        // 第一行
        Row() {
          this.buildTypeButton('complementary', '互补色', '🎨')
          this.buildTypeButton('analogous', '类似色', '🌈')
          this.buildTypeButton('triadic', '三角', '🔺')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })

        // 第二行
        Row() {
          this.buildTypeButton('tetradic', '四角', '🔲')
          this.buildTypeButton('monochromatic', '单色', '🎭')
          this.buildTypeButton('split-complementary', '分裂', '✨')
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })

      // 预览生成的颜色
      Column() {
        Text('预览')
          .fontSize(13)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        Row() {
          ForEach(this.generatedColors, (color: string) => {
            Column() {
              Row()
                .width(50)
                .height(50)
                .backgroundColor(color)
                .borderRadius(8)
                .margin({ bottom: 4 })

              Text(color)
                .fontSize(11)
                .fontColor('#666666')
            }
            .margin({ right: 8 })
          })
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })

      // 方案名称输入
      Column() {
        Text('方案名称')
          .fontSize(13)
          .fontColor('#666666')
          .margin({ bottom: 6 })

        TextInput({ text: $$this.schemeName })
          .width('100%')
          .fontSize(14)
          .padding({ left: 12, right: 12 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 12 })
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)

      // 按钮（固定在底部）
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F0F0F0')
          .fontColor('#333333')
          .layoutWeight(1)
          .margin({ right: 8 })
          .onClick(() => {
            this.controller.close();
          })

        Button('保存')
          .fontSize(16)
          .backgroundColor('#007AFF')
          .layoutWeight(1)
          .margin({ left: 8 })
          .onClick(() => {
            this.saveScheme();
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('88%')
    .height('75%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
  }

  @Builder
  buildTypeButton(type: ColorSchemeType, label: string, icon: string) {
    Column() {
      Text(icon)
        .fontSize(18)
        .margin({ bottom: 2 })

      Text(label)
        .fontSize(11)
        .fontColor(this.selectedType === type ? '#007AFF' : '#666666')
    }
    .width('30%')
    .padding({ top: 6, bottom: 6 })
    .backgroundColor(this.selectedType === type ? '#E5F2FF' : '#F5F5F5')
    .borderRadius(8)
    .onClick(() => {
      this.selectedType = type;
      this.generateColors();
    })
  }
}

@Component
export struct LibraryPage {
  @State colorSchemes: ColorScheme[] = [];
  @State filteredSchemes: ColorScheme[] = []; // 筛选后的方案
  @State isLoading: boolean = false;
  @State selectedFilterTag: string = ''; // 当前筛选的标签
  @State searchKeyword: string = ''; // 搜索关键词
  @State showFavoriteOnly: boolean = false; // 仅显示收藏
  @State sortBy: string = 'time_desc'; // 排序方式：time_desc, time_asc, name_asc, name_desc
  @Consume @Watch('onRefreshLibrary') refreshLibrary: number; // 接收刷新信号并监听变化

  // 导出对话框控制器
  exportDialogController: CustomDialogController = new CustomDialogController({
    builder: ExportDialog({ scheme: { name: '', colors: [], createTime: 0 } }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  // 配色生成器对话框控制器
  generatorDialogController: CustomDialogController = new CustomDialogController({
    builder: ColorGeneratorDialog({ sourceScheme: { name: '', colors: [], createTime: 0 } }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  // 颜色调整对话框控制器
  adjustDialogController: CustomDialogController = new CustomDialogController({
    builder: ColorAdjustDialog({ sourceScheme: { name: '', colors: [], createTime: 0 } }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  // UI 预览对话框控制器
  previewDialogController: CustomDialogController = new CustomDialogController({
    builder: UIPreviewDialog({ sourceScheme: { name: '', colors: [], createTime: 0 } }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  // 分享对话框控制器
  shareDialogController: CustomDialogController = new CustomDialogController({
    builder: ShareDialog({ scheme: { name: '', colors: [], createTime: 0 } }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  // 配色分析对话框控制器
  analysisDialogController: CustomDialogController = new CustomDialogController({
    builder: ColorAnalysisDialog({ scheme: { name: '', colors: [], createTime: 0 } }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  // 配色对比对话框控制器
  compareDialogController: CustomDialogController = new CustomDialogController({
    builder: ColorCompareDialog({ allSchemes: [] }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  aboutToAppear() {
    console.info('LibraryPage aboutToAppear');
    this.loadColorSchemes();
  }

  // 显示导出对话框
  showExportDialog(scheme: ColorScheme) {
    // 重新创建对话框控制器，传入当前方案
    this.exportDialogController = new CustomDialogController({
      builder: ExportDialog({ scheme: scheme }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.exportDialogController.open();
  }

  // 显示配色生成器对话框
  showGeneratorDialog(scheme: ColorScheme) {
    this.generatorDialogController = new CustomDialogController({
      builder: ColorGeneratorDialog({
        sourceScheme: scheme,
        onSave: (name: string, colors: string[]) => {
          this.saveGeneratedScheme(name, colors);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.generatorDialogController.open();
  }

  // 显示颜色调整对话框
  showAdjustDialog(scheme: ColorScheme) {
    this.adjustDialogController = new CustomDialogController({
      builder: ColorAdjustDialog({
        sourceScheme: scheme,
        onSave: (name: string, colors: string[]) => {
          this.saveAdjustedScheme(name, colors);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.adjustDialogController.open();
  }

  // 显示 UI 预览对话框
  showPreviewDialog(scheme: ColorScheme) {
    this.previewDialogController = new CustomDialogController({
      builder: UIPreviewDialog({
        sourceScheme: scheme
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.previewDialogController.open();
  }

  // 显示分享对话框
  showShareDialog(scheme: ColorScheme) {
    this.shareDialogController = new CustomDialogController({
      builder: ShareDialog({
        scheme: scheme
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.shareDialogController.open();
  }

  // 显示配色分析对话框
  showAnalysisDialog(scheme: ColorScheme) {
    this.analysisDialogController = new CustomDialogController({
      builder: ColorAnalysisDialog({
        scheme: scheme
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.analysisDialogController.open();
  }

  // 显示配色对比对话框
  showCompareDialog() {
    if (this.filteredSchemes.length < 2) {
      promptAction.showToast({ message: '至少需要2个配色方案才能对比', duration: 1500 });
      return;
    }

    this.compareDialogController = new CustomDialogController({
      builder: ColorCompareDialog({
        allSchemes: this.filteredSchemes
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.compareDialogController.open();
  }

  // 保存生成的配色方案
  async saveGeneratedScheme(name: string, colors: string[]) {
    try {
      const newScheme: ColorScheme = {
        name: name,
        colors: colors,
        createTime: Date.now()
      };

      const dbManager = DatabaseManager.getInstance();
      const id = await dbManager.saveColorScheme(newScheme);
      if (id > 0) {
        promptAction.showToast({ message: '配色方案已保存', duration: 1500 });
        this.loadColorSchemes();
      } else {
        promptAction.showToast({ message: '保存失败', duration: 1500 });
      }
    } catch (err) {
      console.error('保存生成的配色方案失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '保存失败', duration: 1500 });
    }
  }

  // 保存调整后的配色方案
  async saveAdjustedScheme(name: string, colors: string[]) {
    try {
      const newScheme: ColorScheme = {
        name: name,
        colors: colors,
        createTime: Date.now()
      };

      const dbManager = DatabaseManager.getInstance();
      const id = await dbManager.saveColorScheme(newScheme);
      if (id > 0) {
        promptAction.showToast({ message: '调整后的配色方案已保存', duration: 1500 });
        this.loadColorSchemes();
      } else {
        promptAction.showToast({ message: '保存失败', duration: 1500 });
      }
    } catch (err) {
      console.error('保存调整后的配色方案失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '保存失败', duration: 1500 });
    }
  }

  // 监听刷新信号变化
  onRefreshLibrary() {
    console.info('onRefreshLibrary 被触发，refreshLibrary = ' + this.refreshLibrary);
    this.loadColorSchemes();
  }

  // 筛选配色方案（组合筛选：搜索 + 标签 + 收藏 + 排序）
  filterSchemes() {
    let result = this.colorSchemes;

    // 1. 按搜索关键词筛选
    if (this.searchKeyword && this.searchKeyword.trim() !== '') {
      const keyword = this.searchKeyword.trim().toLowerCase();
      result = result.filter((scheme: ColorScheme) => {
        // 搜索方案名称
        const nameMatch = scheme.name.toLowerCase().includes(keyword);
        // 搜索标签
        const tags = ColorSchemeUtils.getTags(scheme);
        const tagMatch = tags.some((tag: string) => tag.toLowerCase().includes(keyword));
        return nameMatch || tagMatch;
      });
    }

    // 2. 按标签筛选
    if (this.selectedFilterTag && this.selectedFilterTag !== '') {
      result = result.filter((scheme: ColorScheme) => {
        return ColorSchemeUtils.hasTag(scheme, this.selectedFilterTag);
      });
    }

    // 3. 按收藏状态筛选
    if (this.showFavoriteOnly) {
      result = result.filter((scheme: ColorScheme) => {
        return scheme.isFavorite === true;
      });
    }

    // 4. 排序
    result = this.sortSchemes(result);

    this.filteredSchemes = result;
    console.info(`筛选结果: ${this.filteredSchemes.length} 个方案`);
  }

  // 排序方案
  sortSchemes(schemes: ColorScheme[]): ColorScheme[] {
    const sorted = [...schemes];
    switch (this.sortBy) {
      case 'time_desc': // 最新优先
        sorted.sort((a, b) => b.createTime - a.createTime);
        break;
      case 'time_asc': // 最早优先
        sorted.sort((a, b) => a.createTime - b.createTime);
        break;
      case 'name_asc': // 名称 A-Z
        sorted.sort((a, b) => a.name.localeCompare(b.name));
        break;
      case 'name_desc': // 名称 Z-A
        sorted.sort((a, b) => b.name.localeCompare(a.name));
        break;
    }
    return sorted;
  }

  // 点击标签筛选
  onTagClick(tagName: string) {
    if (this.selectedFilterTag === tagName) {
      // 再次点击同一标签，取消筛选
      this.selectedFilterTag = '';
    } else {
      // 选择新标签
      this.selectedFilterTag = tagName;
    }
    this.filterSchemes();
  }

  // 清除所有筛选
  clearAllFilters() {
    this.searchKeyword = '';
    this.selectedFilterTag = '';
    this.showFavoriteOnly = false;
    this.sortBy = 'time_desc';
    this.filterSchemes();
  }

  // 检查是否有筛选条件
  hasActiveFilters(): boolean {
    return this.searchKeyword !== '' ||
      this.selectedFilterTag !== '' ||
      this.showFavoriteOnly ||
      this.sortBy !== 'time_desc';
  }

  // 获取排序标签
  getSortLabel(): string {
    switch (this.sortBy) {
      case 'time_desc':
        return '最新优先';
      case 'time_asc':
        return '最早优先';
      case 'name_asc':
        return '名称 A-Z';
      case 'name_desc':
        return '名称 Z-A';
      default:
        return '最新优先';
    }
  }

  // 获取排序索引
  getSortIndex(): number {
    switch (this.sortBy) {
      case 'time_desc':
        return 0;
      case 'time_asc':
        return 1;
      case 'name_asc':
        return 2;
      case 'name_desc':
        return 3;
      default:
        return 0;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('配色库')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        // 对比按钮
        Button({ type: ButtonType.Normal }) {
          Row() {
            Image($r('app.media.ic_public_highlights'))
              .width(18)
              .height(18)
              .fillColor(ThemeColors.primary)
              .margin({ right: 4 })
            Text('对比')
              .fontSize(14)
              .fontColor(ThemeColors.primary)
          }
        }
        .height(36)
        .backgroundColor(ThemeColors.primaryLight)
        .borderRadius(18)
        .padding({ left: 14, right: 14 })
        .onClick(() => {
          this.showCompareDialog();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })
      .backgroundColor(ThemeColors.backgroundSecondary)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索方案名称或标签', text: this.searchKeyword })
          .layoutWeight(1)
          .height(40)
          .backgroundColor(ThemeColors.background)
          .onChange((value: string) => {
            this.searchKeyword = value;
            this.filterSchemes();
          })

        // 清除搜索按钮
        if (this.searchKeyword !== '') {
          Text('×')
            .fontSize(20)
            .fontColor(ThemeColors.textTertiary)
            .margin({ left: 8 })
            .onClick(() => {
              this.searchKeyword = '';
              this.filterSchemes();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      .backgroundColor(ThemeColors.backgroundSecondary)

      // 筛选器栏
      Row() {
        // 收藏筛选
        Row() {
          Text(this.showFavoriteOnly ? '❤️' : '🤍')
            .fontSize(16)
            .margin({ right: 4 })
          Text('收藏')
            .fontSize(14)
            .fontColor(this.showFavoriteOnly ? ThemeColors.error : ThemeColors.textSecondary)
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(this.showFavoriteOnly ? ThemeColors.errorLight : ThemeColors.backgroundInput)
        .borderRadius(16)
        .onClick(() => {
          this.showFavoriteOnly = !this.showFavoriteOnly;
          this.filterSchemes();
        })

        // 排序选择 - 使用 Select 组件
        Select([
          { value: '最新优先', icon: '' },
          { value: '最早优先', icon: '' },
          { value: '名称 A-Z', icon: '' },
          { value: '名称 Z-A', icon: '' }
        ])
          .selected(this.getSortIndex())
          .value(this.getSortLabel())
          .font({ size: 14 })
          .fontColor(ThemeColors.textSecondary)
          .selectedOptionBgColor(ThemeColors.backgroundInput)
          .optionBgColor(ThemeColors.background)
          .optionFont({ size: 14 })
          .margin({ left: 8 })
          .onSelect((index: number) => {
            switch (index) {
              case 0:
                this.sortBy = 'time_desc';
                break;
              case 1:
                this.sortBy = 'time_asc';
                break;
              case 2:
                this.sortBy = 'name_asc';
                break;
              case 3:
                this.sortBy = 'name_desc';
                break;
            }
            this.filterSchemes();
          })

        Blank()

        // 清除所有筛选
        if (this.hasActiveFilters()) {
          Text('清除筛选')
            .fontSize(14)
            .fontColor(ThemeColors.primary)
            .onClick(() => {
              this.clearAllFilters();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 8 })
      .backgroundColor(ThemeColors.backgroundSecondary)

      // 筛选状态提示
      if (this.selectedFilterTag !== '') {
        Row() {
          Text(`标签: ${this.selectedFilterTag}`)
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .margin({ right: 8 })

          Text('×')
            .fontSize(18)
            .fontColor(ThemeColors.textTertiary)
            .onClick(() => {
              this.selectedFilterTag = '';
              this.filterSchemes();
            })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(ThemeColors.backgroundInput)
        .borderRadius(16)
        .margin({ left: 16, bottom: 8 })
      }

      // 内容区
      if (this.isLoading) {
        this.buildLoadingView();
      } else if (this.colorSchemes.length === 0) {
        this.buildEmptyView();
      } else {
        this.buildSchemeList();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }



  // 加载视图
  @Builder
  buildLoadingView() {
    LoadingState({ message: '加载配色方案...' })
  }

  // 空状态视图
  @Builder
  buildEmptyView() {
    EmptyState({
      title: '还没有配色方案',
      description: '去"提取"页面从图片中提取配色，\n或在"灵感"页面保存精选配色',
      actionText: '了解更多',
      onAction: () => {
        promptAction.showToast({
          message: '请切换到"提取"或"灵感"页面开始使用',
          duration: 2000
        });
      }
    })
  }

  // 配色方案列表
  @Builder
  buildSchemeList() {
    Scroll() {
      Column() {
        // 显示筛选结果数量
        if (this.hasActiveFilters()) {
          Row() {
            Text(`找到 ${this.filteredSchemes.length} 个方案`)
              .fontSize(14)
              .fontColor('#999999')

            if (this.filteredSchemes.length === 0) {
              Text('  试试调整筛选条件')
                .fontSize(14)
                .fontColor('#CCCCCC')
            }
          }
          .margin({ bottom: 12 })
          .alignSelf(ItemAlign.Start)
        }

        // 显示筛选后的列表
        if (this.filteredSchemes.length === 0 && this.hasActiveFilters()) {
          // 无筛选结果
          Column() {
            Text('🔍')
              .fontSize(60)
              .margin({ bottom: 16 })
            Text('没有找到匹配的方案')
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ top: 60 })
          .justifyContent(FlexAlign.Center)
        } else {
          // 显示列表
          ForEach(this.filteredSchemes, (scheme: ColorScheme) => {
            this.buildSchemeItem(scheme);
          })
        }
      }
      .width('100%')
      .padding(16)
    }
    .layoutWeight(1)
  }

  // 标签芯片（可点击筛选）
  @Builder
  buildTagChip(tagName: string) {
    Text(tagName)
      .fontSize(12)
      .fontColor('#FFFFFF')
      .backgroundColor(this.selectedFilterTag === tagName ?
        '#FF6B6B' : TagUtils.getTagColor(tagName))
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .borderRadius(12)
      .margin({ right: 6, bottom: 6 })
      .onClick(() => {
        this.onTagClick(tagName);
      })
  }

  // 单个配色方案项 - 毛玻璃设计
  @Builder
  buildSchemeItem(scheme: ColorScheme) {
    ColorfulGlassCard({
      primaryColor: scheme.colors[0] || ThemeColors.primary,
      cardPadding: 14,
      cardRadius: 18,
      content: () => {
        this.buildSchemeCardContent(scheme);
      }
    })
      .margin({ bottom: 12 })
  }

  // 配色方案卡片内容
  @Builder
  buildSchemeCardContent(scheme: ColorScheme) {
    Column() {
      // 顶部：名称和日期
      Column() {
        Text(scheme.name)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 3 })
          .alignSelf(ItemAlign.Start)

        Row({ space: 6 }) {
          Text($r('app.media.day_13'))
            .fontSize(11)
          Text(this.formatDate(scheme.createTime))
            .fontSize(12)
            .fontColor(ThemeColors.textTertiary)
        }
        .alignSelf(ItemAlign.Start)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 8 })

      // 标签显示（如果有）
      if (scheme.tags && scheme.tags !== '') {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(ColorSchemeUtils.getTags(scheme), (tagName: string) => {
            Text(tagName)
              .fontSize(11)
              .fontColor('#FFFFFF')
              .backgroundColor(TagUtils.getTagColor(tagName))
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .borderRadius(12)
              .margin({ right: 6, bottom: 6 })
              .shadow({
                radius: 6,
                color: TagUtils.getTagColor(tagName) + '60',
                offsetY: 3
              })
          })
        }
        .width('100%')
        .margin({ bottom: 8 })
      }

      // 颜色展示 - 主色大圆 + 其他色小圆重叠
      PrimaryColorDisplay({
        primaryColor: scheme.colors[0] || ThemeColors.primary,
        secondaryColors: scheme.colors.slice(1),
        primarySize: 70,
        secondarySize: 44
      })
        .margin({ bottom: 8 })

      // 颜色数量
      Text(`${scheme.colors.length} 种颜色`)
        .fontSize(12)
        .fontColor(ThemeColors.textTertiary)
        .margin({ bottom: 10 })

      // 操作按钮组 - 圆形毛玻璃按钮
      Row({ space: 8 }) {
        this.buildGlassActionButton($r('app.media.ic_public_detail'), '预览', () => {
          this.showPreviewDialog(scheme);
        })

        this.buildGlassActionButton($r('app.media.ic_screenshot_penshape'), '调整', () => {
          this.showAdjustDialog(scheme);
        })

        this.buildGlassActionButton($r('app.media.ic_public_copy'), '复制', () => {
          this.duplicateScheme(scheme);
        })

        this.buildGlassActionButton($r('app.media.ic_public_highlights'), '生成', () => {
          this.showGeneratorDialog(scheme);
        })

        this.buildGlassActionButton($r('app.media.ic_public_save'), '导出', () => {
          this.showExportDialog(scheme);
        })

        this.buildGlassActionButton($r('app.media.ic_public_detail'), '分析', () => {
          this.showAnalysisDialog(scheme);
        })

        this.buildGlassActionButton($r('app.media.ic_message_forwarding'), '分享', () => {
          this.showShareDialog(scheme);
        })

        this.buildGlassActionButton($r('app.media.ic_public_delete'), '删除', () => {
          this.showDeleteConfirm(scheme);
        }, true)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
  }

  // 毛玻璃操作按钮
  @Builder
  buildGlassActionButton(icon: Resource, label: string, onClick: () => void, isDanger: boolean = false) {
    Column({ space: 3 }) {
      Button({ type: ButtonType.Circle }) {
        Image(icon)
          .width(18)
          .height(18)
          .fillColor(isDanger ? ThemeColors.error : ThemeColors.textSecondary)
      }
      .width(42)
      .height(42)
      .backgroundColor(isDanger ? 'rgba(255, 59, 48, 0.15)' : 'rgba(255, 255, 255, 0.2)')
      .backgroundBlurStyle(BlurStyle.Thin)
      .stateEffect(true)
      .onClick(onClick)

      Text(label)
        .fontSize(10)
        .fontColor(isDanger ? ThemeColors.error : ThemeColors.textTertiary)
    }
    .alignItems(HorizontalAlign.Center)
  }

  // 显示删除确认对话框（使用原生 AlertDialog）
  showDeleteConfirm(scheme: ColorScheme) {
    AlertDialog.show({
      title: '确认删除',
      message: `确定要删除配色方案"${scheme.name}"吗？`,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        action: () => {
          console.info('取消删除');
        }
      },
      secondaryButton: {
        value: '删除',
        fontColor: '#FF3B30',
        action: () => {
          this.deleteScheme(scheme);
        }
      }
    });
  }

  // 加载配色方案
  async loadColorSchemes() {
    console.info('开始加载配色方案...');
    this.isLoading = true;
    try {
      const schemes = await DatabaseManager.getInstance().getAllColorSchemes();
      console.info('从数据库获取到 ' + schemes.length + ' 个配色方案');
      this.colorSchemes = schemes;
      console.info('配色方案列表已更新，当前显示 ' + this.colorSchemes.length + ' 个方案');

      // 应用筛选
      this.filterSchemes();
    } catch (err) {
      console.error('加载配色方案失败: ' + JSON.stringify(err));
      promptAction.showToast({
        message: '加载失败',
        duration: 2000
      });
    } finally {
      this.isLoading = false;
      console.info('加载配色方案完成');
    }
  }

  /**
   * 复制配色方案
   */
  async duplicateScheme(scheme: ColorScheme) {
    try {
      // 创建副本
      const duplicatedScheme: ColorScheme = {
        id: 0, // 新ID将由数据库自动生成
        name: scheme.name + ' (副本)',
        colors: [...scheme.colors], // 深拷贝颜色数组
        tags: [...scheme.tags], // 深拷贝标签数组
        isFavorite: false, // 副本默认不收藏
        createdTime: Date.now(),
        source: scheme.source
      };

      // 保存到数据库
      const newId = await DatabaseManager.getInstance().insertColorScheme(duplicatedScheme);

      if (newId > 0) {
        promptAction.showToast({
          message: '配色方案已复制',
          duration: 2000
        });

        // 重新加载列表
        await this.loadColorSchemes();
      } else {
        promptAction.showToast({
          message: '复制失败，请重试',
          duration: 2000
        });
      }
    } catch (err) {
      console.error('复制配色方案失败: ' + JSON.stringify(err));
      promptAction.showToast({
        message: '复制失败: ' + err,
        duration: 2000
      });
    }
  }

  // 删除配色方案
  async deleteScheme(scheme: ColorScheme) {
    if (!scheme.id) return;

    try {
      const success = await DatabaseManager.getInstance().deleteColorScheme(scheme.id);
      if (success) {
        promptAction.showToast({
          message: '删除成功',
          duration: 2000
        });
        // 重新加载列表
        this.loadColorSchemes();
      } else {
        promptAction.showToast({
          message: '删除失败',
          duration: 2000
        });
      }
    } catch (err) {
      console.error('删除失败: ' + JSON.stringify(err));
      promptAction.showToast({
        message: '删除失败',
        duration: 2000
      });
    }
  }

  // 格式化日期
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')}`;
  }
}

