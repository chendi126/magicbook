// 灵感广场页面
import { INSPIRATION_SCHEMES, INSPIRATION_CATEGORIES, InspirationScheme, CategoryItem } from '../data/InspirationData';
import { DatabaseManager } from '../database/DatabaseManager';
import { ColorScheme } from '../models/ColorScheme';
import promptAction from '@ohos.promptAction';
import { ThemeColors } from '../utils/ThemeColors';
import { GlassCard, ColorfulGlassCard } from '../components/GlassCard';
import { OverlappingColorCircles } from '../components/ColorCircle';

// 预览对话框
@CustomDialog
struct PreviewDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: PreviewDialog()
  });
  scheme: InspirationScheme = { id: '', name: '', category: '', colors: [], description: '' };
  onSave?: () => void;

  build() {
    Column() {
      // 标题
      Text(this.scheme.name)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 8 })

      // 描述
      Text(this.scheme.description)
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .margin({ bottom: 16 })

      // 颜色预览
      Column() {
        ForEach(this.scheme.colors, (color: string, index: number) => {
          Row() {
            // 颜色块
            Column()
              .width(60)
              .height(60)
              .backgroundColor(color)
              .borderRadius(8)

            // 颜色信息
            Column() {
              Text(color.toUpperCase())
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.textPrimary)

              Text(`颜色 ${index + 1}`)
                .fontSize(12)
                .fontColor(ThemeColors.textTertiary)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
            .layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(ThemeColors.backgroundSecondary)
          .borderRadius(8)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .margin({ bottom: 20 })

      // 按钮
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor(ThemeColors.textSecondary)
          .backgroundColor(ThemeColors.backgroundSecondary)
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close();
          })

        Button('保存到配色库')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor(ThemeColors.primary)
          .layoutWeight(1)
          .margin({ left: 12 })
          .onClick(() => {
            if (this.onSave) {
              this.onSave();
            }
            this.controller.close();
          })
      }
      .width('100%')
    }
    .width('90%')
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
  }
}

@Component
export struct InspirationPage {
  @State selectedCategory: string = 'all';
  @State filteredSchemes: InspirationScheme[] = INSPIRATION_SCHEMES;
  @State selectedScheme: InspirationScheme | null = null;
  @Consume refreshLibrary: number; // 接收刷新信号

  // 预览对话框控制器
  previewDialogController: CustomDialogController = new CustomDialogController({
    builder: PreviewDialog({ scheme: { id: '', name: '', category: '', colors: [], description: '' } }),
    alignment: DialogAlignment.Center,
    autoCancel: true,
    customStyle: true
  })

  aboutToAppear() {
    this.filterSchemes();
  }

  // 筛选配色方案
  filterSchemes() {
    if (this.selectedCategory === 'all') {
      this.filteredSchemes = INSPIRATION_SCHEMES;
    } else {
      this.filteredSchemes = INSPIRATION_SCHEMES.filter(scheme => scheme.category === this.selectedCategory);
    }
  }

  // 显示预览对话框
  showPreviewDialog(scheme: InspirationScheme) {
    this.previewDialogController = new CustomDialogController({
      builder: PreviewDialog({
        scheme: scheme,
        onSave: () => {
          this.saveToLibrary(scheme);
        }
      }),
      alignment: DialogAlignment.Center,
      autoCancel: true,
      customStyle: true
    });
    this.previewDialogController.open();
  }

  // 保存到配色库
  async saveToLibrary(scheme: InspirationScheme) {
    const colorScheme: ColorScheme = {
      name: scheme.name,
      tags: scheme.category,
      colors: scheme.colors,
      createTime: Date.now(),
      isFavorite: false,
      group: '灵感广场'
    };

    const result = await DatabaseManager.getInstance().saveColorScheme(colorScheme);
    if (result > 0) {
      promptAction.showToast({
        message: '已保存到配色库',
        duration: 2000
      });
      // 触发配色库刷新
      this.refreshLibrary++;
    } else {
      promptAction.showToast({
        message: '保存失败',
        duration: 2000
      });
    }
  }

  build() {
    Column() {
      // 标题
      Row() {
        Text('灵感广场')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })
      .backgroundColor(ThemeColors.backgroundSecondary)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      // 分类筛选 - 毛玻璃标签
      Scroll() {
        Row({ space: 10 }) {
          ForEach(INSPIRATION_CATEGORIES, (category: CategoryItem) => {
            this.buildCategoryButton(category);
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: 16 })

      // 配色方案网格
      Scroll() {
        GridRow({ columns: 2, gutter: 12 }) {
          ForEach(this.filteredSchemes, (scheme: InspirationScheme) => {
            GridCol() {
              this.buildSchemeCard(scheme);
            }
          })
        }
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }

  // 分类按钮 - 毛玻璃设计
  @Builder
  buildCategoryButton(category: CategoryItem) {
    Row() {
      Text(`${category.icon} ${category.name}`)
        .fontSize(14)
        .fontWeight(this.selectedCategory === category.value ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.selectedCategory === category.value ? '#FFFFFF' : ThemeColors.textSecondary)
    }
    .padding({ left: 18, right: 18, top: 10, bottom: 10 })
    .backgroundColor(this.selectedCategory === category.value ?
      ThemeColors.primary : 'rgba(255, 255, 255, 0.3)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .borderRadius(20)
    .border(this.selectedCategory === category.value ? undefined : {
      width: 1,
      color: 'rgba(255, 255, 255, 0.5)'
    })
    .shadow(this.selectedCategory === category.value ? {
      radius: 12,
      color: ThemeColors.primary + '60',
      offsetY: 6
    } : undefined)
    .clip(new Rect({ width: '100%', height: '100%', radius: 20 }))
    .onClick(() => {
      this.selectedCategory = category.value;
      this.filterSchemes();
    })
  }

  // 配色方案卡片 - 毛玻璃设计
  @Builder
  buildSchemeCard(scheme: InspirationScheme) {
    ColorfulGlassCard({
      primaryColor: scheme.colors[0],
      cardPadding: 0,
      cardRadius: 20,
      content: () => {
        this.buildSchemeCardContent(scheme);
      },
      onCardClick: () => {
        this.showPreviewDialog(scheme);
      }
    })
  }

  // 配色方案卡片内容
  @Builder
  buildSchemeCardContent(scheme: InspirationScheme) {
    Column() {
      // 顶部：垂直颜色条纹
      Row({ space: 0 }) {
        ForEach(scheme.colors, (color: string) => {
          Column()
            .layoutWeight(1)
            .height(100)
            .backgroundColor(color)
        })
      }
      .width('100%')
      .borderRadius({ topLeft: 20, topRight: 20 })
      .clip(true)

      // 信息区域
      Column() {
        // 名称
        Text(scheme.name)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 4 })

        // 描述
        Text(scheme.description)
          .fontSize(12)
          .fontColor(ThemeColors.textTertiary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ bottom: 10 })

        // 圆形色块展示
        OverlappingColorCircles({
          colors: scheme.colors,
          circleSize: 32,
          overlapOffset: -10,
          maxDisplay: 5,
          showCount: true
        })
          .margin({ bottom: 10 })

        // 操作按钮
        Row({ space: 8 }) {
          Button('预览')
            .fontSize(12)
            .fontColor(ThemeColors.primary)
            .backgroundColor('rgba(0, 125, 255, 0.15)')
            .backgroundBlurStyle(BlurStyle.Thin)
            .height(32)
            .layoutWeight(1)
            .stateEffect(true)
            .onClick(() => {
              this.showPreviewDialog(scheme);
            })

          Button('保存')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .backgroundColor(ThemeColors.primary)
            .height(32)
            .layoutWeight(1)
            .stateEffect(true)
            .onClick(() => {
              this.saveToLibrary(scheme);
            })
        }
        .width('100%')
      }
      .width('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
  }
}

