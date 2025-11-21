/**
 * 配色对比对话框
 * 支持选择2-3个配色方案进行并排对比
 */
import { ColorScheme } from '../models/ColorScheme';
import { ColorAnalyzer, HSLColor } from '../utils/ColorAnalyzer';
import { ThemeColors } from '../utils/ThemeColors';
import promptAction from '@ohos.promptAction';

@CustomDialog
export struct ColorCompareDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: ColorCompareDialog()
  });
  
  // 所有可选的配色方案
  allSchemes: ColorScheme[] = [];
  
  // 当前选中的方案（最多3个）
  @State selectedSchemes: ColorScheme[] = [];
  
  // 是否显示选择列表
  @State showSelection: boolean = true;
  
  private maxSelection: number = 3;

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('配色对比')
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

      if (this.showSelection) {
        // 选择模式
        this.buildSelectionMode();
      } else {
        // 对比模式
        this.buildCompareMode();
      }
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

  // 选择模式
  @Builder
  buildSelectionMode() {
    Column() {
      Text(`请选择要对比的配色方案（${this.selectedSchemes.length}/${this.maxSelection}）`)
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      // 已选择的方案
      if (this.selectedSchemes.length > 0) {
        Column() {
          Text('已选择')
            .fontSize(13)
            .fontColor(ThemeColors.textTertiary)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          ForEach(this.selectedSchemes, (scheme: ColorScheme, index: number) => {
            this.buildSchemeCard(scheme, true, index);
          })
        }
        .width('100%')
        .margin({ bottom: 16 })
      }

      // 可选择的方案列表
      Scroll() {
        Column() {
          Text('可选择')
            .fontSize(13)
            .fontColor(ThemeColors.textTertiary)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          ForEach(this.allSchemes.filter(s => !this.selectedSchemes.includes(s)), (scheme: ColorScheme) => {
            this.buildSchemeCard(scheme, false, -1);
          })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 开始对比按钮
      Button('开始对比')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor(this.selectedSchemes.length >= 2 ? ThemeColors.primary : ThemeColors.backgroundInput)
        .fontColor(this.selectedSchemes.length >= 2 ? '#FFFFFF' : ThemeColors.textPlaceholder)
        .borderRadius(24)
        .margin({ top: 16 })
        .enabled(this.selectedSchemes.length >= 2)
        .onClick(() => {
          if (this.selectedSchemes.length >= 2) {
            this.showSelection = false;
          } else {
            promptAction.showToast({ message: '请至少选择2个配色方案', duration: 1500 });
          }
        })
    }
    .width('100%')
    .height('100%')
  }

  // 对比模式
  @Builder
  buildCompareMode() {
    Column() {
      // 返回按钮
      Row() {
        Text('← 重新选择')
          .fontSize(14)
          .fontColor(ThemeColors.primary)
          .onClick(() => {
            this.showSelection = true;
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      Scroll() {
        Column() {
          // 并排对比
          this.buildSideBySideComparison();

          // 详细分析
          this.buildDetailedAnalysis();
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
  }

  // 方案卡片
  @Builder
  buildSchemeCard(scheme: ColorScheme, isSelected: boolean, selectedIndex: number) {
    Row() {
      // 配色预览
      Row() {
        ForEach(scheme.colors.slice(0, 5), (color: string) => {
          Column()
            .backgroundColor(color)
            .layoutWeight(1)
            .height(40)
        })
      }
      .width(120)
      .borderRadius(8)
      .clip(true)
      .margin({ right: 12 })

      // 方案信息
      Column({ space: 4 }) {
        Text(scheme.name)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(`${scheme.colors.length} 个颜色`)
          .fontSize(12)
          .fontColor(ThemeColors.textTertiary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 操作按钮
      if (isSelected) {
        Text('移除')
          .fontSize(13)
          .fontColor(ThemeColors.error)
          .backgroundColor(ThemeColors.errorLight)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(12)
          .onClick(() => {
            this.selectedSchemes.splice(selectedIndex, 1);
          })
      } else {
        Text(this.selectedSchemes.length >= this.maxSelection ? '已满' : '选择')
          .fontSize(13)
          .fontColor(this.selectedSchemes.length >= this.maxSelection ? ThemeColors.textPlaceholder : ThemeColors.primary)
          .backgroundColor(this.selectedSchemes.length >= this.maxSelection ? ThemeColors.backgroundInput : ThemeColors.primaryLight)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .borderRadius(12)
          .onClick(() => {
            if (this.selectedSchemes.length < this.maxSelection) {
              this.selectedSchemes.push(scheme);
            } else {
              promptAction.showToast({ message: `最多选择${this.maxSelection}个方案`, duration: 1500 });
            }
          })
      }
    }
    .width('100%')
    .padding(12)
    .backgroundColor(isSelected ? ThemeColors.primaryLight : ThemeColors.backgroundCard)
    .borderRadius(12)
    .margin({ bottom: 8 })
  }

  // 并排对比
  @Builder
  buildSideBySideComparison() {
    Column() {
      Text('配色预览')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      // 并排显示
      Row({ space: 8 }) {
        ForEach(this.selectedSchemes, (scheme: ColorScheme) => {
          Column() {
            // 方案名称
            Text(scheme.name)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.textPrimary)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
              .textAlign(TextAlign.Center)
              .margin({ bottom: 8 })

            // 颜色块
            Column() {
              ForEach(scheme.colors, (color: string) => {
                Column()
                  .width('100%')
                  .height(40)
                  .backgroundColor(color)
              })
            }
            .width('100%')
            .borderRadius(8)
            .clip(true)
            .shadow({
              radius: 6,
              color: ThemeColors.shadowLight,
              offsetY: 2
            })
          }
          .layoutWeight(1)
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(12)
    .margin({ bottom: 16 })
  }

  // 详细分析
  @Builder
  buildDetailedAnalysis() {
    Column() {
      Text('对比分析')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      // 颜色数量对比
      this.buildComparisonItem('颜色数量', this.selectedSchemes.map(s => `${s.colors.length} 个`));

      // 平均亮度对比
      this.buildComparisonItem('平均亮度', this.selectedSchemes.map(s => {
        const avgLightness = this.calculateAverageLightness(s.colors);
        return `${avgLightness}%`;
      }));

      // 平均饱和度对比
      this.buildComparisonItem('平均饱和度', this.selectedSchemes.map(s => {
        const avgSaturation = this.calculateAverageSaturation(s.colors);
        return `${avgSaturation}%`;
      }));

      // 色相范围对比
      this.buildComparisonItem('色相范围', this.selectedSchemes.map(s => {
        const hueRange = this.calculateHueRange(s.colors);
        return `${hueRange}°`;
      }));

      // 相似度分析（如果是2个方案）
      if (this.selectedSchemes.length === 2) {
        Column() {
          Text('相似度')
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Row() {
            Row()
              .width(`${this.calculateSimilarity(this.selectedSchemes[0].colors, this.selectedSchemes[1].colors)}%`)
              .height('100%')
              .backgroundColor(ThemeColors.primary)
              .borderRadius(4)
          }
          .width('100%')
          .height(8)
          .backgroundColor(ThemeColors.backgroundInput)
          .borderRadius(4)
          .margin({ bottom: 4 })

          Text(`${this.calculateSimilarity(this.selectedSchemes[0].colors, this.selectedSchemes[1].colors)}% 相似`)
            .fontSize(12)
            .fontColor(ThemeColors.textPlaceholder)
            .alignSelf(ItemAlign.Start)
        }
        .width('100%')
        .padding(12)
        .backgroundColor(ThemeColors.backgroundInput)
        .borderRadius(8)
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(12)
  }

  // 对比项
  @Builder
  buildComparisonItem(label: string, values: string[]) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Row({ space: 8 }) {
        ForEach(values, (value: string, index: number) => {
          Text(value)
            .fontSize(13)
            .fontColor(ThemeColors.textPrimary)
            .backgroundColor(ThemeColors.backgroundInput)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(8)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        })
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  // ========== 计算方法 ==========

  /**
   * 计算平均亮度
   */
  calculateAverageLightness(colors: string[]): number {
    let totalLightness = 0;
    colors.forEach(color => {
      const hsl = ColorAnalyzer.hexToHsl(color);
      if (hsl) {
        totalLightness += hsl.l;
      }
    });
    return Math.round(totalLightness / colors.length);
  }

  /**
   * 计算平均饱和度
   */
  calculateAverageSaturation(colors: string[]): number {
    let totalSaturation = 0;
    colors.forEach(color => {
      const hsl = ColorAnalyzer.hexToHsl(color);
      if (hsl) {
        totalSaturation += hsl.s;
      }
    });
    return Math.round(totalSaturation / colors.length);
  }

  /**
   * 计算色相范围
   */
  calculateHueRange(colors: string[]): number {
    const hues: number[] = [];
    colors.forEach(color => {
      const hsl = ColorAnalyzer.hexToHsl(color);
      if (hsl) {
        hues.push(hsl.h);
      }
    });

    if (hues.length === 0) return 0;

    const minHue = Math.min(...hues);
    const maxHue = Math.max(...hues);
    return Math.round(maxHue - minHue);
  }

  /**
   * 计算两个配色方案的相似度
   */
  calculateSimilarity(colors1: string[], colors2: string[]): number {
    // 简化算法：比较平均 HSL 值的差异
    const avg1 = this.getAverageHSL(colors1);
    const avg2 = this.getAverageHSL(colors2);

    const hueDiff = Math.min(Math.abs(avg1.h - avg2.h), 360 - Math.abs(avg1.h - avg2.h));
    const satDiff = Math.abs(avg1.s - avg2.s);
    const lightDiff = Math.abs(avg1.l - avg2.l);

    // 归一化差异（0-100）
    const normalizedDiff = (hueDiff / 180 * 100 + satDiff + lightDiff) / 3;

    // 相似度 = 100 - 差异
    return Math.round(100 - normalizedDiff);
  }

  /**
   * 获取平均 HSL 值
   */
  getAverageHSL(colors: string[]): HSLColor {
    let totalH = 0, totalS = 0, totalL = 0;
    colors.forEach(color => {
      const hsl = ColorAnalyzer.hexToHsl(color);
      if (hsl) {
        totalH += hsl.h;
        totalS += hsl.s;
        totalL += hsl.l;
      }
    });

    return {
      h: totalH / colors.length,
      s: totalS / colors.length,
      l: totalL / colors.length
    };
  }
}
