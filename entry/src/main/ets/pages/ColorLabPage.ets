/**
 * 配色实验室页面
 * 让用户从零创建配色方案
 */
import { ColorAnalyzer, HSLColor, ColorEmotionAnalysis } from '../utils/ColorAnalyzer';
import { ColorTheoryUtils, ColorSchemeType } from '../utils/ColorTheoryUtils';
import { DatabaseManager } from '../database/DatabaseManager';
import { ColorScheme } from '../models/ColorScheme';
import { ThemeColors } from '../utils/ThemeColors';
import promptAction from '@ohos.promptAction';

@Component
export struct ColorLabPage {
  @State colors: string[] = ['#007AFF']; // 当前配色（至少一个颜色）
  @State selectedColorIndex: number = 0; // 当前选中的颜色索引
  @State currentHue: number = 211; // 当前色相
  @State currentSaturation: number = 100; // 当前饱和度
  @State currentLightness: number = 50; // 当前亮度
  @State showAnalysis: boolean = false; // 显示分析面板
  @State analysis: ColorEmotionAnalysis | null = null; // 分析结果
  @State showSaveDialog: boolean = false; // 显示保存对话框
  @State schemeName: string = ''; // 方案名称

  private maxColors: number = 8; // 最多8个颜色

  aboutToAppear() {
    this.updateCurrentColor();
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader();

      Scroll() {
        Column({ space: 24 }) {
          // 配色预览区
          this.buildColorPreview();

          // 颜色调整区
          this.buildColorAdjuster();

          // 颜色列表
          this.buildColorList();

          // 快速操作
          this.buildQuickActions();

          // 分析结果（如果显示）
          if (this.showAnalysis && this.analysis) {
            this.buildAnalysisPanel();
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 20, bottom: 100 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 底部操作栏
      this.buildBottomActions();
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }

  // 标题栏
  @Builder
  buildHeader() {
    Column() {
      Text('配色实验室')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 4 })

      Text('激发创意，探索无限色彩可能')
        .fontSize(14)
        .fontColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 20, right: 20, top: 20, bottom: 10 })
    .backgroundColor(ThemeColors.background)
    .shadow({ radius: 0, color: 'transparent' }) // 移除默认阴影，保持清爽
  }

  // 配色预览区
  @Builder
  buildColorPreview() {
    Column() {
      Row() {
        ForEach(this.colors, (color: string, index: number) => {
          Column()
            .backgroundColor(color)
            .layoutWeight(1)
            .height(120)
            .animation({ duration: 300, curve: Curve.EaseInOut })
            .onClick(() => {
              this.selectColor(index);
            })
        })
      }
      .width('100%')
      .borderRadius(16)
      .clip(true)
      .shadow({
        radius: 24,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetY: 8
      })

      // 选中指示器
      Row() {
        ForEach(this.colors, (color: string, index: number) => {
          Column() {
            if (this.selectedColorIndex === index) {
              Circle({ width: 6, height: 6 })
                .fill(ThemeColors.textPrimary)
                .margin({ top: 8 })
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        })
      }
      .width('100%')
    }
    .width('100%')
  }

  // 颜色列表
  @Builder
  buildColorList() {
    Column() {
      Row() {
        Text('色板')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .layoutWeight(1)

        Text(`${this.colors.length}/${this.maxColors}`)
          .fontSize(14)
          .fontColor(ThemeColors.textPlaceholder)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(ThemeColors.backgroundInput)
          .borderRadius(8)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 颜色卡片网格
      Grid() {
        ForEach(this.colors, (color: string, index: number) => {
          GridItem() {
            this.buildColorCard(color, index);
          }
        })
        
        // 添加按钮
        if (this.colors.length < this.maxColors) {
          GridItem() {
            this.buildAddColorButton();
          }
        }
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height(Math.ceil((this.colors.length + (this.colors.length < this.maxColors ? 1 : 0)) / 4) * 80)
    }
    .width('100%')
  }

  // 颜色卡片
  @Builder
  buildColorCard(color: string, index: number) {
    Stack() {
      // 颜色块
      Column()
        .width('100%')
        .height(70)
        .backgroundColor(color)
        .borderRadius(12)
        .shadow({
          radius: 4,
          color: 'rgba(0,0,0,0.1)',
          offsetY: 2
        })
        .border({
          width: this.selectedColorIndex === index ? 2 : 0,
          color: ThemeColors.textPrimary
        })
        .onClick(() => {
          this.selectColor(index);
        })

      // 删除按钮 (仅在选中且数量>1时显示)
      if (this.selectedColorIndex === index && this.colors.length > 1) {
        Column() {
          Text('×')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .width(20)
        .height(20)
        .backgroundColor('rgba(0,0,0,0.3)')
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 4, y: 4 })
        .onClick(() => {
          this.removeColor(index);
        })
      }
    }
    .width('100%')
    .height(70)
  }

  // 添加颜色按钮
  @Builder
  buildAddColorButton() {
    Column() {
      Text('+')
        .fontSize(24)
        .fontColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .height(70)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(12)
    .border({
      width: 1,
      color: ThemeColors.border,
      style: BorderStyle.Dashed
    })
    .onClick(() => {
      this.addColor();
    })
  }

  // 颜色调整区
  @Builder
  buildColorAdjuster() {
    Column() {
      Text('参数调整')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 16 })

      Column({ space: 20 }) {
        // 色相调整
        this.buildSlider('色相', this.currentHue, 0, 360, [
          ['#FF0000', 0.0], ['#FFFF00', 0.17], ['#00FF00', 0.33],
          ['#00FFFF', 0.5], ['#0000FF', 0.67], ['#FF00FF', 0.83], ['#FF0000', 1.0]
        ], (value: number) => {
          this.currentHue = Math.round(value);
          this.updateSelectedColor();
        });

        // 饱和度调整
        this.buildSlider('饱和度', this.currentSaturation, 0, 100, [
          ['#808080', 0.0], [ColorAnalyzer.hslToHex(this.currentHue, 100, 50), 1.0]
        ], (value: number) => {
          this.currentSaturation = Math.round(value);
          this.updateSelectedColor();
        });

        // 亮度调整
        this.buildSlider('亮度', this.currentLightness, 0, 100, [
          ['#000000', 0.0], [ColorAnalyzer.hslToHex(this.currentHue, this.currentSaturation, 50), 0.5], ['#FFFFFF', 1.0]
        ], (value: number) => {
          this.currentLightness = Math.round(value);
          this.updateSelectedColor();
        });
      }
      .padding(20)
      .backgroundColor(ThemeColors.backgroundCard)
      .borderRadius(16)
      .shadow({
        radius: 12,
        color: 'rgba(0,0,0,0.05)',
        offsetY: 4
      })
    }
    .width('100%')
  }

  // 滑块组件
  @Builder
  buildSlider(label: string, value: number, min: number, max: number, gradientColors: [string, number][], onChange: (value: number) => void) {
    Column() {
      Row() {
        Text(label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textSecondary)
        
        Blank()

        Text(value.toString())
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .fontFamily('monospace')
      }
      .width('100%')
      .margin({ bottom: 10 })

      Stack() {
        // 渐变背景条
        Row()
          .width('100%')
          .height(6)
          .borderRadius(3)
          .linearGradient({
            angle: 90,
            colors: gradientColors
          })

        // 滑块
        Slider({
          value: value,
          min: min,
          max: max,
          style: SliderStyle.OutSet
        })
          .width('100%')
          .trackColor('transparent') // 透明轨道，显示下方的渐变
          .selectedColor('transparent')
          .blockColor('#FFFFFF')
          .trackThickness(20) // 增加触摸区域
          .onChange((value: number, mode: SliderChangeMode) => {
            onChange(value);
          })
      }
      .height(24)
      .alignContent(Alignment.Center)
    }
    .width('100%')
  }

  // 快速操作
  @Builder
  buildQuickActions() {
    Column() {
      Text('智能生成')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 16 })

      Grid() {
        GridItem() {
          this.buildActionButton('随机生成', $r('app.media.ic_public_quickstart'), () => { this.randomizeCurrentColor() })
        }
        GridItem() {
          this.buildActionButton('互补色', $r('app.media.ic_public_ok_filled'), () => { this.addComplementaryColor() })
        }
        GridItem() {
          this.buildActionButton('类似色', $r('app.media.ic_public_connection_filled'), () => { this.addAnalogousColor() })
        }
        GridItem() {
          this.buildActionButton('重置', $r('app.media.ic_public_delete'), () => { this.resetColors() })
        }
      }
      .columnsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(12)
      .width('100%')
      .height(80)
    }
    .width('100%')
  }

  // 操作按钮
  @Builder
  buildActionButton(text: string, icon: Resource, onClick: () => void) {
    Column() {
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(ThemeColors.primary)
        .margin({ bottom: 8 })

      Text(text)
        .fontSize(12)
        .fontColor(ThemeColors.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0,0,0,0.05)',
      offsetY: 2
    })
    .onClick(onClick)
  }

  // 分析面板
  @Builder
  buildAnalysisPanel() {
    Column() {
      Row() {
        Text('AI 色彩分析')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .layoutWeight(1)

        Text('×')
          .fontSize(24)
          .fontColor(ThemeColors.textTertiary)
          .onClick(() => {
            animateTo({ duration: 300 }, () => {
              this.showAnalysis = false;
            })
          })
      }
      .width('100%')
      .margin({ bottom: 20 })

      if (this.analysis) {
        // 情感雷达图 (简化为条形图展示)
        Column({ space: 12 }) {
          this.buildScoreItem('温暖度', this.analysis.warmth, ThemeColors.warning);
          this.buildScoreItem('活力度', this.analysis.energy, ThemeColors.error);
          this.buildScoreItem('专业度', this.analysis.professionalism, ThemeColors.primary);
          this.buildScoreItem('和谐度', this.analysis.harmony, ThemeColors.success);
        }
        .padding(16)
        .backgroundColor(ThemeColors.background)
        .borderRadius(12)
        .margin({ bottom: 20 })

        // 关键词标签
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.analysis.emotionTags, (tag: string) => {
            Text(tag)
              .fontSize(12)
              .fontColor(ThemeColors.primary)
              .backgroundColor(ThemeColors.primaryLight)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(100)
              .margin({ right: 8, bottom: 8 })
          })
        }
      }
    }
    .width('100%')
    .padding(20)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(20)
    .shadow({
      radius: 20,
      color: 'rgba(0,0,0,0.1)',
      offsetY: 4
    })
    .transition({ type: TransitionType.Insert, translate: { y: 50 }, opacity: 0 })
  }

  // 评分项
  @Builder
  buildScoreItem(label: string, score: number, color: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor(ThemeColors.textSecondary)
        .width(50)

      Row() {
        Row()
          .width(`${score}%`)
          .height('100%')
          .backgroundColor(color)
          .borderRadius(4)
      }
      .layoutWeight(1)
      .height(6)
      .backgroundColor(ThemeColors.backgroundInput)
      .borderRadius(4)
      .margin({ left: 10, right: 10 })

      Text(`${score}`)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
        .width(30)
        .textAlign(TextAlign.End)
    }
    .width('100%')
  }

  // 底部操作栏
  @Builder
  buildBottomActions() {
    Row({ space: 16 }) {
      // 分析按钮
      Button() {
        Row() {
          Image($r('app.media.ic_public_detail'))
            .width(20)
            .height(20)
            .fillColor(ThemeColors.primary)
            .margin({ right: 8 })
          Text('分析')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.primary)
        }
      }
      .layoutWeight(1)
      .height(50)
      .backgroundColor(ThemeColors.primaryLight)
      .borderRadius(25)
      .onClick(() => {
        this.analyzeColors();
      })

      // 保存按钮
      Button() {
        Row() {
          Image($r('app.media.ic_public_save'))
            .width(20)
            .height(20)
            .fillColor('#FFFFFF')
            .margin({ right: 8 })
          Text('保存')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
      }
      .layoutWeight(1)
      .height(50)
      .linearGradient({
        angle: 135,
        colors: [[ThemeColors.primary, 0.0], ['#00C6FF', 1.0]]
      })
      .borderRadius(25)
      .shadow({
        radius: 10,
        color: 'rgba(0, 122, 255, 0.3)',
        offsetY: 4
      })
      .onClick(() => {
        this.showSaveDialog = true;
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 20, top: 10 })
    .backgroundColor(ThemeColors.background)
    .bindSheet($$this.showSaveDialog, this.buildSaveDialog(), {
      detents: [SheetSize.MEDIUM],
      showClose: false,
      dragBar: true,
      backgroundColor: ThemeColors.background
    })
  }

  // 保存对话框
  @Builder
  buildSaveDialog() {
    Column() {
      Text('保存配色方案')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 24, top: 10 })

      TextInput({ placeholder: '给你的配色起个名字...', text: this.schemeName })
        .width('100%')
        .height(50)
        .backgroundColor(ThemeColors.backgroundInput)
        .borderRadius(12)
        .margin({ bottom: 24 })
        .onChange((value: string) => {
          this.schemeName = value;
        })

      Button('确认保存')
        .width('100%')
        .height(50)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(ThemeColors.primary)
        .borderRadius(25)
        .onClick(() => {
          this.saveColorScheme();
        })
    }
    .width('100%')
    .padding(24)
  }

  // ========== 方法实现 ==========

  /**
   * 选择颜色
   */
  selectColor(index: number) {
    this.selectedColorIndex = index;
    this.updateCurrentColor();
  }

  /**
   * 更新当前颜色的 HSL 值
   */
  updateCurrentColor() {
    const color = this.colors[this.selectedColorIndex];
    const hsl = ColorAnalyzer.hexToHsl(color);
    if (hsl) {
      this.currentHue = hsl.h;
      this.currentSaturation = hsl.s;
      this.currentLightness = hsl.l;
    }
  }

  /**
   * 更新选中的颜色
   */
  updateSelectedColor() {
    const newColor = ColorAnalyzer.hslToHex(this.currentHue, this.currentSaturation, this.currentLightness);
    this.colors[this.selectedColorIndex] = newColor;
  }

  /**
   * 添加颜色
   */
  addColor() {
    if (this.colors.length >= this.maxColors) {
      promptAction.showToast({ message: `最多添加${this.maxColors}个颜色`, duration: 1500 });
      return;
    }

    // 添加一个随机颜色
    const randomHue = Math.floor(Math.random() * 360);
    const newColor = ColorAnalyzer.hslToHex(randomHue, 70, 50);
    this.colors.push(newColor);

    // 选中新添加的颜色
    this.selectedColorIndex = this.colors.length - 1;
    this.updateCurrentColor();
  }

  /**
   * 删除颜色
   */
  removeColor(index: number) {
    if (this.colors.length <= 1) {
      promptAction.showToast({ message: '至少保留一个颜色', duration: 1500 });
      return;
    }

    this.colors.splice(index, 1);

    // 调整选中索引
    if (this.selectedColorIndex >= this.colors.length) {
      this.selectedColorIndex = this.colors.length - 1;
    }
    this.updateCurrentColor();
  }

  /**
   * 随机化当前颜色
   */
  randomizeCurrentColor() {
    this.currentHue = Math.floor(Math.random() * 360);
    this.currentSaturation = Math.floor(Math.random() * 60) + 40; // 40-100
    this.currentLightness = Math.floor(Math.random() * 40) + 30; // 30-70
    this.updateSelectedColor();
  }

  /**
   * 添加互补色
   */
  addComplementaryColor() {
    if (this.colors.length >= this.maxColors) {
      promptAction.showToast({ message: `最多添加${this.maxColors}个颜色`, duration: 1500 });
      return;
    }

    const currentColor = this.colors[this.selectedColorIndex];
    const complementary = ColorTheoryUtils.generateComplementary(currentColor);

    if (complementary.length > 1) {
      this.colors.push(complementary[1]);
      promptAction.showToast({ message: '已添加互补色', duration: 1000 });
    }
  }

  /**
   * 添加类似色
   */
  addAnalogousColor() {
    if (this.colors.length >= this.maxColors) {
      promptAction.showToast({ message: `最多添加${this.maxColors}个颜色`, duration: 1500 });
      return;
    }

    const currentColor = this.colors[this.selectedColorIndex];
    const analogous = ColorTheoryUtils.generateAnalogous(currentColor);

    if (analogous.length > 1) {
      // 添加第一个类似色
      this.colors.push(analogous[1]);
      promptAction.showToast({ message: '已添加类似色', duration: 1000 });
    }
  }

  /**
   * 重置颜色
   */
  resetColors() {
    AlertDialog.show({
      title: '清空重置',
      message: '确定要清空所有颜色并重新开始吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        fontColor: '#FF3B30',
        action: () => {
          this.colors = ['#007AFF'];
          this.selectedColorIndex = 0;
          this.updateCurrentColor();
          promptAction.showToast({ message: '已重置', duration: 1000 });
        }
      }
    });
  }

  /**
   * 分析配色
   */
  analyzeColors() {
    this.analysis = ColorAnalyzer.analyzeColorEmotion(this.colors);
    this.showAnalysis = true;
  }

  /**
   * 保存配色方案
   */
  async saveColorScheme() {
    if (!this.schemeName.trim()) {
      promptAction.showToast({ message: '请输入方案名称', duration: 1500 });
      return;
    }

    const scheme: ColorScheme = {
      name: this.schemeName.trim(),
      colors: this.colors,
      createTime: new Date().getTime(),
      tags: '实验室'
    };

    try {
      await DatabaseManager.getInstance().saveColorScheme(scheme);
      this.showSaveDialog = false;
      this.schemeName = '';
      promptAction.showToast({ message: '保存成功', duration: 1500 });
    } catch (err) {
      promptAction.showToast({ message: '保存失败', duration: 1500 });
    }
  }
}
