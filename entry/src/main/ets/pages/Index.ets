import { LibraryPage } from './LibraryPage';
import { MinePage } from './MinePage';
import { InspirationPage } from './InspirationPage';
import picker from '@ohos.file.picker';
import { ColorInfo } from '../models/ColorInfo';
import { ColorExtractor, ColorExtractionAlgorithm } from '../utils/ColorExtractor';
import { ClipboardUtils } from '../utils/ClipboardUtils';
import { DatabaseManager } from '../database/DatabaseManager';
import { ColorScheme } from '../models/ColorScheme';
import { PRESET_TAGS, Tag, TagUtils } from '../models/Tag';
import promptAction from '@ohos.promptAction';
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';
import { GuideOverlay } from '../components/GuideOverlay';
import { EmptyState } from '../components/EmptyState';
import { LoadingOverlay } from '../components/LoadingState';
import { PreferencesManager } from '../utils/PreferencesManager';
import { ThemeColors } from '../utils/ThemeColors';
import { TABBAR_ANIMATION } from '../utils/AnimationUtils';


// 保存配色方案对话框
@CustomDialog
struct SaveSchemeDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: SaveSchemeDialog()
  });
  @State schemeName: string = '';
  @State selectedTags: string[] = [];
  @State customTagInput: string = '';
  onConfirm: (name: string, tags: string[]) => void = () => {};

  // 切换标签选择
  toggleTag(tagName: string) {
    const index = this.selectedTags.indexOf(tagName);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    } else {
      this.selectedTags.push(tagName);
    }
  }

  // 移除标签
  removeTag(tagName: string) {
    const index = this.selectedTags.indexOf(tagName);
    if (index > -1) {
      this.selectedTags.splice(index, 1);
    }
  }

  // 添加自定义标签
  addCustomTag() {
    const tagName = this.customTagInput.trim();
    if (!tagName) {
      promptAction.showToast({ message: '请输入标签名称' });
      return;
    }
    if (!TagUtils.validateTagName(tagName)) {
      promptAction.showToast({ message: '标签名称长度为1-10个字符，不能包含逗号' });
      return;
    }
    if (this.selectedTags.includes(tagName)) {
      promptAction.showToast({ message: '标签已存在' });
      return;
    }
    this.selectedTags.push(tagName);
    this.customTagInput = '';
  }

  // 标签芯片（可选择）
  @Builder
  buildTagChip(tagName: string, tagColor: string, isPreset: boolean) {
    Text(tagName)
      .fontSize(13)
      .fontColor(this.selectedTags.includes(tagName) ? '#FFFFFF' : tagColor)
      .backgroundColor(this.selectedTags.includes(tagName) ? tagColor : ThemeColors.backgroundInput)
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .borderRadius(12)
      .margin({ right: 6, bottom: 6 })
      .onClick(() => {
        this.toggleTag(tagName);
      })
  }

  // 已选标签（可移除）
  @Builder
  buildSelectedTag(tagName: string) {
    Row() {
      Text(tagName)
        .fontSize(13)
        .fontColor('#FFFFFF')
        .margin({ right: 4 })

      Text('×')
        .fontSize(16)
        .fontColor('#FFFFFF')
    }
    .padding({ left: 10, right: 10, top: 5, bottom: 5 })
    .backgroundColor(TagUtils.getTagColor(tagName))
    .borderRadius(12)
    .margin({ right: 6, bottom: 6 })
    .onClick(() => {
      this.removeTag(tagName);
    })
  }

  build() {
    Column() {
      Text('保存配色方案')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 16 })

      // 方案名称输入
      TextInput({ placeholder: '请输入方案名称', text: this.schemeName })
        .width('100%')
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.schemeName = value;
        })

      // 标签选择区域
      Column() {
        Text('选择标签（可多选）')
          .fontSize(14)
          .fontColor(ThemeColors.textTertiary)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        // 预设标签
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(PRESET_TAGS, (tag: Tag) => {
            this.buildTagChip(tag.name, tag.color, true);
          })
        }
        .width('100%')
        .margin({ bottom: 12 })

        // 自定义标签输入
        Row() {
          TextInput({ placeholder: '自定义标签', text: this.customTagInput })
            .layoutWeight(1)
            .margin({ right: 8 })
            .onChange((value: string) => {
              this.customTagInput = value;
            })

          Button('添加')
            .fontSize(14)
            .height(40)
            .stateEffect(true)
            .onClick(() => {
              this.addCustomTag();
            })
        }
        .width('100%')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 已选标签显示
      if (this.selectedTags.length > 0) {
        Column() {
          Text('已选标签')
            .fontSize(14)
            .fontColor(ThemeColors.textTertiary)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.selectedTags, (tagName: string) => {
              this.buildSelectedTag(tagName);
            })
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 16 })
      }

      // 按钮
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor(ThemeColors.backgroundInput)
          .fontColor(ThemeColors.textSecondary)
          .layoutWeight(1)
          .margin({ right: 8 })
          .stateEffect(true)
          .onClick(() => {
            this.controller.close();
          })

        Button('保存')
          .fontSize(16)
          .backgroundColor(ThemeColors.primary)
          .layoutWeight(1)
          .margin({ left: 8 })
          .stateEffect(true)
          .onClick(() => {
            if (!this.schemeName.trim()) {
              promptAction.showToast({ message: '请输入方案名称' });
              return;
            }
            this.controller.close();
            this.onConfirm(this.schemeName.trim(), this.selectedTags);
          })
      }
      .width('100%')
    }
    .width('80%')  // 设置对话框宽度为屏幕的80%
    .padding(20)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .shadow({ radius: 20, color: ThemeColors.shadowMedium, offsetY: 10 })
    .transition({
      type: TransitionType.All,
      scale: { x: 0.9, y: 0.9 },
      opacity: 0
    })
    .animation({
      duration: 300,
      curve: Curve.FastOutSlowIn
    })
  }
}

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  @State selectedImageUri: string = '';
  @State extractedColors: ColorInfo[] = [];
  @State isExtracting: boolean = false;
  @Provide refreshLibrary: number = 0; // 刷新信号
  @State showGuide: boolean = false; // 显示引导
  @State isProcessing: boolean = false; // 处理中状态

  // 手动取色相关状态
  @State pickMode: string = 'auto'; // 'auto' 自动提取 | 'manual' 手动取色
  @State manualColors: ColorInfo[] = []; // 手动选择的颜色
  @State currentPixelMap: image.PixelMap | null = null; // 当前图片的 PixelMap

  // 算法选择
  @State extractionAlgorithm: ColorExtractionAlgorithm = 'kmeans'; // 'median-cut' | 'kmeans'
  private maxManualColors: number = 8; // 最多选择8个颜色

  // 保存对话框控制器
  saveDialogController: CustomDialogController = new CustomDialogController({
    builder: SaveSchemeDialog({
      onConfirm: (name: string, tags: string[]) => {
        this.saveColorScheme(name, tags);
      }
    }),
    customStyle: true,
    autoCancel: true,
    alignment: DialogAlignment.Center
  })

  async aboutToAppear() {
    // 初始化 PreferencesManager
    await PreferencesManager.getInstance().init(getContext(this));

    // 检查是否首次启动
    const isFirst = await PreferencesManager.getInstance().isFirstLaunch();
    if (isFirst) {
      this.showGuide = true;
    }
  }

  // 页面销毁时释放资源
  aboutToDisappear() {
    if (this.currentPixelMap) {
      this.currentPixelMap.release();
      this.currentPixelMap = null;
      console.info('PixelMap 资源已释放');
    }
  }

  build() {
    Stack() {
      // 主内容
      Tabs({ index: this.currentTabIndex }) {
        // 首页 - 提取
        TabContent() {
          this.buildHomePage();
        }
        .tabBar(this.buildTabBarItem('提取', 0, $r('app.media.ic_gallery_create')))

        // 配色库
        TabContent() {
          LibraryPage();
        }
        .tabBar(this.buildTabBarItem('配色库', 1, $r('app.media.ic_public_folder')))

        // 灵感广场
        TabContent() {
          InspirationPage();
        }
        .tabBar(this.buildTabBarItem('灵感', 2, $r('app.media.ic_public_favor')))

        // 我的
        TabContent() {
          MinePage();
        }
        .tabBar(this.buildTabBarItem('我的', 3, $r('app.media.ic_public_settings')))
      }
      .barPosition(BarPosition.End)
      .onChange((index: number) => {
        animateTo({
          duration: TABBAR_ANIMATION.duration,
          curve: TABBAR_ANIMATION.curve
        }, () => {
          this.currentTabIndex = index;
        });
      })
      .animationDuration(TABBAR_ANIMATION.duration) // 页面切换动画时长
      .barBackgroundColor(ThemeColors.background) // 导航栏背景色
      .barBackgroundBlurStyle(BlurStyle.Thin) // 毛玻璃效果
      .barMode(BarMode.Fixed) // 固定模式
      .width('100%')
      .height('100%')

      // 加载遮罩
      LoadingOverlay({ isLoading: $isProcessing, message: '处理中...' })

      // 首次使用引导
      if (this.showGuide) {
        GuideOverlay({
          onComplete: () => {
            this.showGuide = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // TabBar 项
  @Builder
  buildTabBarItem(title: string, index: number, icon: Resource) {
    Column() {
      // 图标容器 - 选中时显示背景
      Column() {
        Image(icon)
          .width(this.currentTabIndex === index ? 26 : 24)
          .height(this.currentTabIndex === index ? 26 : 24)
          .fillColor(this.currentTabIndex === index ? ThemeColors.primary : ThemeColors.textPlaceholder)
          .animation({
            duration: TABBAR_ANIMATION.iconDuration,
            curve: TABBAR_ANIMATION.iconCurve
          })
      }
      .width(50)
      .height(32)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentTabIndex === index ?
        ThemeColors.primaryLight : 'transparent')
      .borderRadius(16)
      .margin({ bottom: 4 })
      .animation({
        duration: TABBAR_ANIMATION.duration,
        curve: TABBAR_ANIMATION.curve
      })

      Text(title)
        .fontSize(this.currentTabIndex === index ? 13 : 12)
        .fontWeight(this.currentTabIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentTabIndex === index ? ThemeColors.primary : ThemeColors.textPlaceholder)
        .animation({
          duration: TABBAR_ANIMATION.duration,
          curve: TABBAR_ANIMATION.curve
        })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
  }

  // 首页内容
  @Builder
  buildHomePage() {
    Column() {
      // 标题栏 - 渐变设计
      Column() {
        Row() {
          Column() {
            Text('色彩提取')
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeColors.textPrimary)

            Text('发现图片中的美丽配色')
              .fontSize(13)
              .fontColor(ThemeColors.textTertiary)
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      }
      .width('100%')
      .linearGradient({
        angle: 180,
        colors: [[ThemeColors.background, 0.0], [ThemeColors.backgroundSecondary, 1.0]]
      })

      // 主内容区
      Scroll() {
        Column() {
          // 选择图片按钮
          if (!this.selectedImageUri) {
            this.buildSelectImageButton();
          } else {
            // 显示选中的图片
            this.buildImagePreview();

            // 取色模式切换
            this.buildPickModeSwitch();

            // 算法选择（仅在自动提取模式下显示）
            if (this.pickMode === 'auto') {
              this.buildAlgorithmSwitch();
            }

            // 显示提取的颜色或加载状态
            if (this.isExtracting) {
              this.buildLoadingView();
            } else if (this.pickMode === 'auto' && this.extractedColors.length > 0) {
              this.buildColorList();
            } else if (this.pickMode === 'manual' && this.manualColors.length > 0) {
              this.buildManualColorList();
            }
          }
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 16, bottom: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      // 底部操作按钮
      if ((this.pickMode === 'auto' && this.extractedColors.length > 0) ||
        (this.pickMode === 'manual' && this.manualColors.length > 0)) {
        this.buildBottomActions();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }

  // 选择图片按钮
  @Builder
  buildSelectImageButton() {
    Column() {
      // 图标容器 - 带渐变背景
      Column() {
        Image($r('app.media.ic_public_picture'))
          .width(48)
          .height(48)
          .fillColor('#FFFFFF')
      }
      .width(96)
      .height(96)
      .borderRadius(48)
      .linearGradient({
        angle: 135,
        colors: [[ThemeColors.primary, 0.0], ['#00C6FF', 1.0]]
      })
      .justifyContent(FlexAlign.Center)
      .shadow({
        radius: 20,
        color: 'rgba(0, 122, 255, 0.3)',
        offsetX: 0,
        offsetY: 8
      })
      .margin({ bottom: 24 })

      Text('选择图片开始')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 8 })

      Text('从相册中选择一张图片提取配色')
        .fontSize(15)
        .fontColor(ThemeColors.textTertiary)
        .opacity(0.8)
    }
    .width('100%')
    .height(360)
    .justifyContent(FlexAlign.Center)
    .linearGradient({
      angle: 180,
      colors: [['rgba(0, 122, 255, 0.05)', 0.0], ['rgba(0, 198, 255, 0.05)', 1.0]]
    })
    .borderRadius(20)
    .border({
      width: 2,
      color: 'rgba(0, 122, 255, 0.1)'
    })
    .onClick(() => {
      this.selectImage();
    })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }

  // 图片预览
  @Builder
  buildImagePreview() {
    Column() {
      // 图片容器（支持点击取色）
      Stack() {
        Image(this.selectedImageUri)
          .width('100%')
          .height(280)
          .objectFit(ImageFit.Cover)
          .borderRadius(16)
          .shadow({
            radius: 16,
            color: 'rgba(0, 0, 0, 0.15)',
            offsetX: 0,
            offsetY: 4
          })
          .onClick((event: ClickEvent) => {
            if (this.pickMode === 'manual') {
              this.pickColorAtPosition(event.x, event.y);
            }
          })

        // 手动取色模式提示 - 毛玻璃效果
        if (this.pickMode === 'manual') {
          Column() {
            Text('点击图片取色')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(0, 0, 0, 0.5)')
          .backgroundBlurStyle(BlurStyle.Thin)
          .borderRadius(20)
          .margin({ top: 16 })
        }
      }
      .width('100%')
      .height(280)
      .alignContent(Alignment.Top)

      // 重新选择按钮 - 新设计
      Row() {
        Text('重新选择')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textSecondary)
      }
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .backgroundColor(ThemeColors.backgroundInput)
      .borderRadius(20)
      .margin({ top: 16 })
      .onClick(() => {
        this.selectImage();
      })
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 取色模式切换
  @Builder
  buildPickModeSwitch() {
    Row() {
      Text('取色模式')
        .fontSize(14)
        .fontColor(ThemeColors.textTertiary)
        .margin({ right: 12 })

      // 自动提取
      Row() {
        Text(this.pickMode === 'auto' ? '●' : '○')
          .fontSize(16)
          .fontColor(this.pickMode === 'auto' ? ThemeColors.primary : ThemeColors.textDisabled)
          .margin({ right: 4 })
        Text('自动提取')
          .fontSize(14)
          .fontColor(this.pickMode === 'auto' ? ThemeColors.primary : ThemeColors.textTertiary)
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.pickMode === 'auto' ? ThemeColors.primaryLight : ThemeColors.backgroundInput)
      .borderRadius(20)
      .onClick(() => {
        this.switchPickMode('auto');
      })

      // 手动取色
      Row() {
        Text(this.pickMode === 'manual' ? '●' : '○')
          .fontSize(16)
          .fontColor(this.pickMode === 'manual' ? ThemeColors.primary : ThemeColors.textDisabled)
          .margin({ right: 4 })
        Text('手动取色')
          .fontSize(14)
          .fontColor(this.pickMode === 'manual' ? ThemeColors.primary : ThemeColors.textTertiary)
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.pickMode === 'manual' ? ThemeColors.primaryLight : ThemeColors.backgroundInput)
      .borderRadius(20)
      .margin({ left: 8 })
      .onClick(() => {
        this.switchPickMode('manual');
      })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // 算法选择
  @Builder
  buildAlgorithmSwitch() {
    Row() {
      Text('提取算法')
        .fontSize(14)
        .fontColor(ThemeColors.textTertiary)
        .margin({ right: 12 })

      // K-Means 算法
      Row() {
        Text(this.extractionAlgorithm === 'kmeans' ? '●' : '○')
          .fontSize(16)
          .fontColor(this.extractionAlgorithm === 'kmeans' ? ThemeColors.success : ThemeColors.textDisabled)
          .margin({ right: 4 })
        Text('K-Means')
          .fontSize(14)
          .fontColor(this.extractionAlgorithm === 'kmeans' ? ThemeColors.success : ThemeColors.textTertiary)
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.extractionAlgorithm === 'kmeans' ? ThemeColors.successLight : ThemeColors.backgroundInput)
      .borderRadius(20)
      .onClick(() => {
        this.switchAlgorithm('kmeans');
      })

      // 中位切分算法
      Row() {
        Text(this.extractionAlgorithm === 'median-cut' ? '●' : '○')
          .fontSize(16)
          .fontColor(this.extractionAlgorithm === 'median-cut' ? ThemeColors.warning : ThemeColors.textDisabled)
          .margin({ right: 4 })
        Text('中位切分')
          .fontSize(14)
          .fontColor(this.extractionAlgorithm === 'median-cut' ? ThemeColors.warning : ThemeColors.textTertiary)
      }
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor(this.extractionAlgorithm === 'median-cut' ? ThemeColors.warningLight : ThemeColors.backgroundInput)
      .borderRadius(20)
      .margin({ left: 8 })
      .onClick(() => {
        this.switchAlgorithm('median-cut');
      })
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // 手动选择的颜色列表
  @Builder
  buildManualColorList() {
    Column() {
      Row() {
        Text('已选择颜色')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .layoutWeight(1)

        Text(`${this.manualColors.length}/${this.maxManualColors}`)
          .fontSize(14)
          .fontColor(ThemeColors.textPlaceholder)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor(ThemeColors.backgroundInput)
          .borderRadius(12)
          .margin({ right: 12 })

        if (this.manualColors.length > 0) {
          Row() {
            Text('清空')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.error)
          }
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(ThemeColors.errorLight)
          .borderRadius(16)
          .onClick(() => {
            this.clearManualColors();
          })
        }
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 配色预览条
      if (this.manualColors.length > 0) {
        Row() {
          ForEach(this.manualColors, (color: ColorInfo) => {
            Column()
              .backgroundColor(color.hex)
              .layoutWeight(1)
              .height(70)
          })
        }
        .width('100%')
        .borderRadius(12)
        .clip(true)
        .shadow({
          radius: 12,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
        .margin({ bottom: 20 })

        // 颜色详情列表
        ForEach(this.manualColors, (color: ColorInfo, index: number) => {
          this.buildManualColorItem(color, index);
        })
      } else {
        // 空状态提示 - 优化设计
        Column() {
          Text('点击图片选择颜色')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.textSecondary)
            .margin({ bottom: 6 })
          Text(`最多可选择 ${this.maxManualColors} 种颜色`)
            .fontSize(14)
            .fontColor(ThemeColors.textPlaceholder)
        }
        .width('100%')
        .padding({ top: 50, bottom: 50 })
        .backgroundColor(ThemeColors.backgroundCard)
        .borderRadius(16)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  // 手动颜色项
  @Builder
  buildManualColorItem(color: ColorInfo, index: number) {
    Row() {
      // 颜色块 - 更大更醒目
      Column()
        .width(60)
        .height(60)
        .backgroundColor(color.hex)
        .borderRadius(12)
        .shadow({
          radius: 8,
          color: color.hex + '40',
          offsetX: 0,
          offsetY: 2
        })
        .margin({ right: 14 })

      // 颜色信息
      Column({ space: 6 }) {
        Row({ space: 4 }) {
          Text('HEX')
            .fontSize(12)
            .fontColor(ThemeColors.textPlaceholder)
            .width(40)
          Text(color.hex)
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .fontWeight(FontWeight.Medium)
            .fontFamily('monospace')
        }

        Row({ space: 4 }) {
          Text('RGB')
            .fontSize(12)
            .fontColor(ThemeColors.textPlaceholder)
            .width(40)
          Text(color.rgb)
            .fontSize(14)
            .fontColor(ThemeColors.textSecondary)
            .fontFamily('monospace')
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 删除按钮 - 新设计
      Text('删除')
        .fontSize(14)
        .fontColor(ThemeColors.error)
        .fontWeight(FontWeight.Medium)
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor(ThemeColors.errorLight)
        .borderRadius(16)
        .onClick(() => {
          this.removeManualColor(index);
        })
    }
    .width('100%')
    .padding(14)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(14)
    .margin({ bottom: 10 })
    .shadow({
      radius: 6,
      color: ThemeColors.shadowLight,
      offsetX: 0,
      offsetY: 2
    })
  }

  // 加载视图
  @Builder
  buildLoadingView() {
    Column() {
      LoadingProgress()
        .width(60)
        .height(60)
        .color(ThemeColors.primary)
        .margin({ bottom: 20 })

      Text('正在提取颜色...')
        .fontSize(17)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textSecondary)

      Text('请稍候片刻')
        .fontSize(14)
        .fontColor(ThemeColors.textPlaceholder)
        .margin({ top: 6 })
    }
    .width('100%')
    .height(240)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(16)
  }

  // 颜色列表
  @Builder
  buildColorList() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.ic_gallery_free'))
            .width(24)
            .height(24)
            .fillColor(ThemeColors.textPrimary)
            .margin({ right: 8 })
          Text('提取的配色')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.textPrimary)
        }
        .layoutWeight(1)

        Text(`${this.extractedColors.length} 种颜色`)
          .fontSize(14)
          .fontColor(ThemeColors.textPlaceholder)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor(ThemeColors.backgroundInput)
          .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 配色预览条 - 增强设计
      Row() {
        ForEach(this.extractedColors, (color: ColorInfo) => {
          Column()
            .backgroundColor(color.hex)
            .layoutWeight(color.percentage || 1)
            .height(70)
        })
      }
      .width('100%')
      .borderRadius(12)
      .clip(true)
      .shadow({
        radius: 12,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetX: 0,
        offsetY: 4
      })
      .margin({ bottom: 20 })

      // 详细颜色列表
      ForEach(this.extractedColors, (color: ColorInfo, index: number) => {
        this.buildColorItem(color, index);
      })
    }
    .width('100%')
  }

  // 单个颜色项
  @Builder
  buildColorItem(color: ColorInfo, index: number) {
    Column() {
      Row() {
        // 颜色块 - 更大更醒目
        Column()
          .width(70)
          .height(70)
          .backgroundColor(color.hex)
          .borderRadius(12)
          .shadow({
            radius: 8,
            color: color.hex + '40',
            offsetX: 0,
            offsetY: 2
          })

        // 颜色信息
        Column({ space: 6 }) {
          Text(`颜色 ${index + 1}`)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.textPrimary)

          Row({ space: 4 }) {
            Text('HEX')
              .fontSize(12)
              .fontColor(ThemeColors.textPlaceholder)
              .width(40)
            Text(color.hex)
              .fontSize(14)
              .fontColor(ThemeColors.textSecondary)
              .fontWeight(FontWeight.Medium)
              .fontFamily('monospace')
          }

          Row({ space: 4 }) {
            Text('RGB')
              .fontSize(12)
              .fontColor(ThemeColors.textPlaceholder)
              .width(40)
            Text(color.rgb)
              .fontSize(14)
              .fontColor(ThemeColors.textSecondary)
              .fontFamily('monospace')
          }

          if (color.percentage !== undefined) {
            Row({ space: 4 }) {
              Text('占比')
                .fontSize(12)
                .fontColor(ThemeColors.textPlaceholder)
                .width(40)
              Text(`${color.percentage}%`)
                .fontSize(14)
                .fontColor(ThemeColors.primary)
                .fontWeight(FontWeight.Bold)
            }
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 16 })
      }
      .width('100%')

      // 复制按钮组 - 新设计
      Row({ space: 10 }) {
        Row() {
          Image($r('app.media.ic_public_copy'))
            .width(16)
            .height(16)
            .fillColor(ThemeColors.primary)
            .margin({ right: 4 })
          Text('HEX')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.primary)
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(ThemeColors.primaryLight)
        .borderRadius(20)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.copyColorValue(color.hex, 'HEX');
        })

        Row() {
          Image($r('app.media.ic_public_copy'))
            .width(16)
            .height(16)
            .fillColor(ThemeColors.success)
            .margin({ right: 4 })
          Text('RGB')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.success)
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor(ThemeColors.successLight)
        .borderRadius(20)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.copyColorValue(color.rgb, 'RGB');
        })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.backgroundCard)
    .borderRadius(16)
    .margin({ bottom: 12 })
    .shadow({
      radius: 8,
      color: ThemeColors.shadowLight,
      offsetX: 0,
      offsetY: 2
    })
  }

  // 底部操作按钮
  @Builder
  buildBottomActions() {
    Column() {
      // 渐变分割线
      Row()
        .width('100%')
        .height(1)
        .linearGradient({
          angle: 90,
          colors: [['rgba(0, 0, 0, 0)', 0.0], ['rgba(0, 0, 0, 0.1)', 0.5], ['rgba(0, 0, 0, 0)', 1.0]]
        })

      Row() {
        Button({ type: ButtonType.Normal }) {
          Row() {
            Image($r('app.media.ic_public_save'))
              .width(20)
              .height(20)
              .fillColor('#FFFFFF')
              .margin({ right: 8 })
            Text('保存配色方案')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
        }
        .width('100%')
        .height(52)
        .linearGradient({
          angle: 135,
          colors: [[ThemeColors.primary, 0.0], ['#00C6FF', 1.0]]
        })
        .borderRadius(26)
        .stateEffect(true)
        .shadow({
          radius: 16,
          color: 'rgba(0, 122, 255, 0.4)',
          offsetX: 0,
          offsetY: 6
        })
        .onClick(() => {
          this.saveDialogController.open();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor(ThemeColors.background)
  }



  // 选择图片
  async selectImage() {
    try {
      const photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select(photoSelectOptions);

      if (result && result.photoUris && result.photoUris.length > 0) {
        this.selectedImageUri = result.photoUris[0];

        // 创建 PixelMap 用于手动取色
        await this.createPixelMap(this.selectedImageUri);

        // 如果是自动模式，提取颜色
        if (this.pickMode === 'auto') {
          this.extractColors();
        }
      }
    } catch (err) {
      console.error('选择图片失败: ' + JSON.stringify(err));
    }
  }

  // 创建 PixelMap（优化版本：降采样以节省内存）
  async createPixelMap(uri: string) {
    try {
      // 打开文件获取文件描述符
      const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);

      // 使用文件描述符创建图片源
      const imageSource = image.createImageSource(file.fd);

      // 获取图片信息
      const imageInfo = await imageSource.getImageInfo();
      console.info(`原始图片尺寸: ${imageInfo.size.width}x${imageInfo.size.height}`);

      // 计算降采样尺寸（最大 1200px，用于手动取色）
      const maxSize = 1200;
      let targetWidth = imageInfo.size.width;
      let targetHeight = imageInfo.size.height;

      if (targetWidth > maxSize || targetHeight > maxSize) {
        const scale = Math.min(maxSize / targetWidth, maxSize / targetHeight);
        targetWidth = Math.floor(targetWidth * scale);
        targetHeight = Math.floor(targetHeight * scale);
        console.info(`降采样后尺寸: ${targetWidth}x${targetHeight}`);
      }

      // 创建 PixelMap（带降采样选项）
      const decodingOptions: image.DecodingOptions = {
        desiredSize: {
          width: targetWidth,
          height: targetHeight
        },
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      };

      this.currentPixelMap = await imageSource.createPixelMap(decodingOptions);
      console.info('PixelMap 创建成功（已优化）');

      // 释放资源
      await imageSource.release();
      fs.closeSync(file);
    } catch (err) {
      console.error('创建 PixelMap 失败: ' + JSON.stringify(err));
      this.currentPixelMap = null;
    }
  }

  // 切换取色模式
  switchPickMode(mode: string) {
    if (this.pickMode === mode) {
      return;
    }

    this.pickMode = mode;

    if (mode === 'auto') {
      // 切换到自动模式，清空手动颜色，重新提取
      this.manualColors = [];
      if (this.selectedImageUri) {
        this.extractColors();
      }
    } else {
      // 切换到手动模式，清空自动提取的颜色
      this.extractedColors = [];
      this.manualColors = [];
    }

    promptAction.showToast({
      message: mode === 'auto' ? '已切换到自动提取模式' : '已切换到手动取色模式',
      duration: 1500
    });
  }

  // 切换提取算法
  switchAlgorithm(algorithm: ColorExtractionAlgorithm) {
    if (this.extractionAlgorithm === algorithm) {
      return;
    }

    this.extractionAlgorithm = algorithm;

    // 重新提取颜色
    if (this.selectedImageUri && this.pickMode === 'auto') {
      this.extractColors();
    }

    const algorithmName = algorithm === 'kmeans' ? 'K-Means 算法' : '中位切分算法';
    promptAction.showToast({
      message: `已切换到 ${algorithmName}`,
      duration: 1500
    });
  }

  // 点击位置取色
  async pickColorAtPosition(x: number, y: number) {
    if (!this.currentPixelMap) {
      promptAction.showToast({ message: '图片未加载完成', duration: 1500 });
      return;
    }

    if (this.manualColors.length >= this.maxManualColors) {
      promptAction.showToast({
        message: `最多选择${this.maxManualColors}个颜色`,
        duration: 1500
      });
      return;
    }

    try {
      // 获取图片信息
      const imageInfo = await this.currentPixelMap.getImageInfo();
      console.info(`PixelMap 尺寸: ${imageInfo.size.width} x ${imageInfo.size.height}`);
      console.info(`点击坐标: x=${x}, y=${y}`);

      // 图片显示尺寸是 width='100%', height=250, objectFit=Cover
      // 需要根据 Cover 模式计算实际显示区域
      const displayHeight = 250;
      const imageAspectRatio = imageInfo.size.width / imageInfo.size.height;

      // 假设显示宽度为屏幕宽度（这里简化处理，实际应该获取组件宽度）
      // 由于是 Cover 模式，图片会被裁剪以填充整个区域
      let scaleX: number;
      let scaleY: number;

      // 简化处理：直接使用点击坐标映射到图片坐标
      // 因为图片高度固定为250，宽度为100%
      scaleX = imageInfo.size.width / displayHeight; // 假设显示区域是正方形
      scaleY = imageInfo.size.height / displayHeight;

      const pixelX = Math.floor(x * scaleX);
      const pixelY = Math.floor(y * scaleY);

      console.info(`计算的像素坐标: pixelX=${pixelX}, pixelY=${pixelY}`);

      // 确保坐标在有效范围内
      if (pixelX < 0 || pixelX >= imageInfo.size.width ||
          pixelY < 0 || pixelY >= imageInfo.size.height) {
        console.error(`坐标超出范围: (${pixelX}, ${pixelY})`);
        promptAction.showToast({ message: '点击位置无效', duration: 1500 });
        return;
      }

      // 读取单个像素的颜色
      const area: image.PositionArea = {
        pixels: new ArrayBuffer(4),
        offset: 0,
        stride: 4,
        region: {
          size: { height: 1, width: 1 },
          x: pixelX,
          y: pixelY
        }
      };

      await this.currentPixelMap.readPixels(area);
      const pixels = new Uint8Array(area.pixels);

      const r: number = pixels[0];
      const g: number = pixels[1];
      const b: number = pixels[2];

      console.info(`读取的颜色: R=${r}, G=${g}, B=${b}`);

      const colorInfo: ColorInfo = {
        hex: this.rgbToHex(r, g, b),
        rgb: `rgb(${r}, ${g}, ${b})`
      };

      this.manualColors.push(colorInfo);

      promptAction.showToast({
        message: `已添加颜色 ${colorInfo.hex}`,
        duration: 1000
      });

    } catch (err) {
      console.error('取色失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '取色失败', duration: 1500 });
    }
  }

  // RGB 转 HEX
  rgbToHex(r: number, g: number, b: number): string {
    const toHex = (n: number): string => {
      const hex = n.toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    };
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
  }

  // 移除手动选择的颜色
  removeManualColor(index: number) {
    this.manualColors.splice(index, 1);
    promptAction.showToast({ message: '已删除', duration: 1000 });
  }

  // 清空手动选择的颜色
  clearManualColors() {
    AlertDialog.show({
      title: '清空颜色',
      message: '确定要清空所有已选择的颜色吗？',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '清空',
        fontColor: '#FF3B30',
        action: () => {
          this.manualColors = [];
          promptAction.showToast({ message: '已清空', duration: 1000 });
        }
      }
    });
  }

  // 保存配色方案
  async saveColorScheme(name: string, tags: string[]) {
    // 获取当前模式的颜色
    const colors = this.pickMode === 'auto' ? this.extractedColors : this.manualColors;

    if (colors.length === 0) {
      promptAction.showToast({
        message: '没有可保存的配色',
        duration: 2000
      });
      return;
    }

    console.info('开始保存配色方案: ' + name);
    console.info('取色模式: ' + this.pickMode);
    console.info('选中的标签: ' + JSON.stringify(tags));

    const scheme: ColorScheme = {
      name: name,
      colors: colors.map((c: ColorInfo) => c.hex),
      createTime: Date.now(),
      imagePath: this.selectedImageUri,
      tags: TagUtils.tagsToString(tags),
      isFavorite: false
    };

    console.info('配色方案数据: ' + JSON.stringify(scheme));

    const rowId = await DatabaseManager.getInstance().saveColorScheme(scheme);
    console.info('保存结果 rowId: ' + rowId);

    if (rowId > 0) {
      promptAction.showToast({
        message: '保存成功',
        duration: 2000
      });

      // 触发配色库刷新
      const newRefreshTime = Date.now();
      console.info('触发刷新信号: ' + newRefreshTime);
      this.refreshLibrary = newRefreshTime;
      console.info('refreshLibrary 已更新为: ' + this.refreshLibrary);

      // 切换到配色库页面
      this.currentTabIndex = 1;
      console.info('已切换到配色库页面');
    } else {
      console.error('保存失败，rowId: ' + rowId);
      promptAction.showToast({
        message: '保存失败，请重试',
        duration: 2000
      });
    }
  }

  // 复制颜色值
  async copyColorValue(value: string, type: string) {
    const success = await ClipboardUtils.copyText(value);
    if (success) {
      promptAction.showToast({
        message: `${type} 已复制: ${value}`,
        duration: 1500
      });
    } else {
      promptAction.showToast({
        message: '复制失败',
        duration: 1500
      });
    }
  }

  // 提取颜色
  async extractColors() {
    this.isExtracting = true;
    this.isProcessing = true; // 显示加载遮罩

    try {
      // 使用选择的颜色提取算法
      const colors = await ColorExtractor.extractFromImage(this.selectedImageUri, 6, this.extractionAlgorithm);

      if (colors.length > 0) {
        this.extractedColors = colors;
        promptAction.showToast({
          message: `成功提取 ${colors.length} 种颜色`,
          duration: 2000
        });
      } else {
        promptAction.showToast({
          message: '提取颜色失败，请重试',
          duration: 2000
        });
      }
    } catch (err) {
      console.error('提取颜色失败: ' + JSON.stringify(err));
      promptAction.showToast({
        message: '提取颜色失败: ' + err,
        duration: 2000
      });
    } finally {
      this.isExtracting = false;
      this.isProcessing = false; // 隐藏加载遮罩
    }
  }
}