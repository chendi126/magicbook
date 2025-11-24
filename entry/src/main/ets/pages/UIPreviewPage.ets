/**
 * UI 设计预览页面
 * 提供 UI 模板预览和组件代码生成功能
 */

import { DatabaseManager } from '../database/DatabaseManager';
import { ColorScheme } from '../models/ColorScheme';
import { ColorRole, ColorRoleMapper } from '../utils/ColorRoleMapper';
import { ThemeColors } from '../utils/ThemeColors';
import { CardTemplate, ButtonTemplate, ListTemplate, DashboardTemplate } from '../components/MobileUITemplates';
import { UICodeGenerator, TemplateType } from '../utils/UICodeGenerator';
import { ClipboardUtils } from '../utils/ClipboardUtils';
import promptAction from '@ohos.promptAction';
import { EmptyState } from '../components/EmptyState';
import { SharePicker } from 'aggregated_share';

@Component
export struct UIPreviewPage {
  @State colorSchemes: ColorScheme[] = []; // 所有配色方案
  @State selectedScheme: ColorScheme | null = null; // 当前选中的配色方案
  @State currentTemplate: TemplateType = 'card'; // 当前模板类型
  @State colorRoles: ColorRole | null = null; // 颜色角色映射
  @State showCodeDialog: boolean = false; // 显示代码对话框
  @State generatedCode: string = ''; // 生成的代码
  @Consume refreshLibrary: number; // 监听配色库刷新

  async aboutToAppear() {
    await this.loadColorSchemes();
  }

  /**
   * 加载配色方案
   */
  async loadColorSchemes() {
    try {
      const schemes = await DatabaseManager.getInstance().getAllColorSchemes();
      this.colorSchemes = schemes.sort((a, b) => b.createTime - a.createTime);
      
      // 默认选中第一个
      if (this.colorSchemes.length > 0 && !this.selectedScheme) {
        this.selectScheme(this.colorSchemes[0]);
      }
    } catch (err) {
      console.error('加载配色方案失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 选择配色方案
   */
  selectScheme(scheme: ColorScheme) {
    this.selectedScheme = scheme;
    // 分配颜色角色 - 创建新对象引用以触发重新渲染
    const roles = ColorRoleMapper.assignRoles(scheme.colors);
    this.colorRoles = {
      primary: roles.primary,
      secondary: roles.secondary,
      background: roles.background,
      surface: roles.surface,
      text: roles.text,
      textSecondary: roles.textSecondary,
      accent: roles.accent,
      error: roles.error,
      success: roles.success,
      border: roles.border
    };
    console.info('选中配色方案: ' + scheme.name);
    console.info('颜色角色: ' + JSON.stringify(this.colorRoles));
  }

  /**
   * 切换模板
   */
  switchTemplate(template: TemplateType) {
    this.currentTemplate = template;
  }

  /**
   * 生成并显示代码
   */
  generateCode() {
    if (!this.selectedScheme || !this.colorRoles) {
      promptAction.showToast({ message: '请先选择配色方案', duration: 1500 });
      return;
    }

    this.generatedCode = UICodeGenerator.generateArkTSCode(
      this.currentTemplate,
      this.colorRoles,
      this.selectedScheme.name
    );
    this.showCodeDialog = true;
  }

  /**
   * 复制代码
   */
  async copyCode() {
    const success = await ClipboardUtils.copyText(this.generatedCode);
    if (success) {
      promptAction.showToast({ message: '代码已复制到剪贴板', duration: 1500 });
      this.showCodeDialog = false;
    } else {
      promptAction.showToast({ message: '复制失败', duration: 1500 });
    }
  }

  /**
   * 导出和分享预览
   */
  sharePreview() {
    if (!this.selectedScheme) {
      promptAction.showToast({ message: '请先选择配色方案', duration: 1500 });
      return;
    }

    try {
      const picker: SharePicker = new SharePicker({
        title: `${this.selectedScheme.name} - UI 预览`,
        subTitle: '拾色师配色设计',
        createTime: Date.now(),
      });

      picker.show({
        extComponentId: 'uiPreviewSnapshot',
        directPoster: true,
        posterSheetTitle: '导出预览图',
      });
    } catch (err) {
      console.error('分享失败: ' + JSON.stringify(err));
      promptAction.showToast({ message: '分享失败', duration: 1500 });
    }
  }

  build() {
    Column() {
      // 标题栏
      this.buildHeader();

      if (this.colorSchemes.length === 0) {
        // 空状态
        EmptyState({
          icon: '🎨',
          title: '暂无配色方案',
          description: '请先在"提取"或"实验室"页面创建配色方案',
          actionText: ''
        })
          .layoutWeight(1)
      } else {
        // 主内容
        Scroll() {
          Column() {
            // 配色方案选择器
            this.buildSchemeSelector();

            // 模板切换按钮
            if (this.selectedScheme) {
              this.buildTemplateSelector();

              // 预览区域
              this.buildPreviewArea();
            }
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)

        // 底部操作栏
        if (this.selectedScheme) {
          this.buildBottomActions();
        }
      }

      // 代码对话框
      if (this.showCodeDialog) {
        this.buildCodeDialog();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }

  // 标题栏
  @Builder
  buildHeader() {
    Column() {
      Text('UI 设计预览')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 4 })

      Text('预览配色在实际界面中的效果')
        .fontSize(14)
        .fontColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: 20, bottom: 16 })
    .backgroundColor(ThemeColors.background)
  }

  // 配色方案选择器
  @Builder
  buildSchemeSelector() {
    Column() {
      Text('选择配色方案')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.colorSchemes, (scheme: ColorScheme) => {
            this.buildSchemeCard(scheme);
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .margin({ top: 16, bottom: 24 })
  }

  // 配色方案卡片
  @Builder
  buildSchemeCard(scheme: ColorScheme) {
    Column() {
      // 颜色预览
      Row() {
        ForEach(scheme.colors.slice(0, 4), (color: string) => {
          Column()
            .width(`${100 / Math.min(scheme.colors.length, 4)}%`)
            .height(60)
            .backgroundColor(color)
        })
      }
      .width('100%')
      .borderRadius(8)
      .clip(true)

      // 方案名称
      Text(scheme.name)
        .fontSize(14)
        .fontColor(ThemeColors.textPrimary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ top: 8 })
    }
    .width(120)
    .padding(8)
    .backgroundColor(this.selectedScheme?.id === scheme.id ? ThemeColors.primaryLight : ThemeColors.backgroundCard)
    .borderRadius(12)
    .border({
      width: 2,
      color: this.selectedScheme?.id === scheme.id ? ThemeColors.primary : 'transparent'
    })
    .onClick(() => {
      this.selectScheme(scheme);
    })
    .animation({ duration: 200, curve: Curve.EaseInOut })
  }

  // 模板选择器
  @Builder
  buildTemplateSelector() {
    Column() {
      Text('选择模板')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      Row({ space: 10 }) {
        this.buildTemplateButton('📇 卡片', 'card')
        this.buildTemplateButton('🔘 按钮', 'button')
        this.buildTemplateButton('📋 列表', 'list')
        this.buildTemplateButton('📊 仪表盘', 'dashboard')
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 24 })
  }

  // 模板按钮
  @Builder
  buildTemplateButton(label: string, template: TemplateType) {
    Text(label)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.currentTemplate === template ? '#FFFFFF' : ThemeColors.textSecondary)
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor(this.currentTemplate === template ? ThemeColors.primary : ThemeColors.backgroundCard)
      .borderRadius(20)
      .onClick(() => {
        this.switchTemplate(template);
      })
      .animation({ duration: 200, curve: Curve.EaseInOut })
  }

  // 预览区域
  @Builder
  buildPreviewArea() {
    Column() {
      Text('预览效果')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 12 })

      // 根据选择的模板显示预览
      if (this.colorRoles && this.selectedScheme) {
        Column() {
          // 预览内容区域 - 用于截图
          Column() {
            if (this.currentTemplate === 'card') {
              CardTemplate({ colorRoles: this.colorRoles })
            } else if (this.currentTemplate === 'button') {
              ButtonTemplate({ colorRoles: this.colorRoles })
            } else if (this.currentTemplate === 'list') {
              ListTemplate({ colorRoles: this.colorRoles })
            } else if (this.currentTemplate === 'dashboard') {
              DashboardTemplate({ colorRoles: this.colorRoles })
            }
          }
          .id('uiPreviewSnapshot')
          .width('100%')
          .padding(16)
          .backgroundColor(ThemeColors.background)
        }
        .width('100%')
        .backgroundColor(ThemeColors.background)
        .borderRadius(16)
        .padding(4)
        .shadow({
          radius: 16,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetY: 4
        })
        .key(`preview-${this.selectedScheme.id}-${this.currentTemplate}`)
      }
    }
    .width('100%')
  }

  // 底部操作栏
  @Builder
  buildBottomActions() {
    Column() {
      Row()
        .width('100%')
        .height(1)
        .linearGradient({
          angle: 90,
          colors: [['rgba(0, 0, 0, 0)', 0.0], ['rgba(0, 0, 0, 0.1)', 0.5], ['rgba(0, 0, 0, 0)', 1.0]]
        })

      Row({ space: 12 }) {
        // 导出/分享按钮
        Button({ type: ButtonType.Normal }) {
          Row() {
            Text('📤')
              .fontSize(20)
              .margin({ right: 6 })
            Text('导出')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
        }
        .layoutWeight(1)
        .height(52)
        .backgroundColor(ThemeColors.purple)
        .borderRadius(26)
        .stateEffect(true)
        .shadow({
          radius: 12,
          color: 'rgba(88, 86, 214, 0.3)',
          offsetX: 0,
          offsetY: 4
        })
        .onClick(() => {
          this.sharePreview();
        })

        // 生成代码按钮
        Button({ type: ButtonType.Normal }) {
          Row() {
            Text('📋')
              .fontSize(20)
              .margin({ right: 6 })
            Text('代码')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
        }
        .layoutWeight(1)
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
          this.generateCode();
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    }
    .width('100%')
    .backgroundColor(ThemeColors.background)
  }

  // 代码对话框
  @Builder
  buildCodeDialog() {
    // 使用 Stack 实现模态对话框
    Stack() {
      // 背景遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => {
          this.showCodeDialog = false;
        })

      // 对话框内容
      Column() {
        // 标题
        Row() {
          Text('生成的组件代码')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeColors.textPrimary)
            .layoutWeight(1)

          Text('✕')
            .fontSize(24)
            .fontColor(ThemeColors.textSecondary)
            .onClick(() => {
              this.showCodeDialog = false;
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 代码内容
        Scroll() {
          Text(this.generatedCode)
            .fontSize(12)
            .fontColor(ThemeColors.textSecondary)
            .fontFamily('monospace')
            .lineHeight(18)
        }
        .width('100%')
        .height(400)
        .backgroundColor(ThemeColors.backgroundInput)
        .borderRadius(8)
        .padding(12)
        .margin({ bottom: 16 })

        // 按钮
        Row({ space: 12 }) {
          Button('取消')
            .fontSize(16)
            .fontColor(ThemeColors.textSecondary)
            .backgroundColor(ThemeColors.backgroundInput)
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              this.showCodeDialog = false;
            })

          Button('复制代码')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .backgroundColor(ThemeColors.primary)
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)
            .onClick(() => {
              this.copyCode();
            })
        }
        .width('100%')
      }
      .width('85%')
      .padding(20)
      .backgroundColor(ThemeColors.background)
      .borderRadius(16)
      .shadow({
        radius: 24,
        color: 'rgba(0, 0, 0, 0.3)',
        offsetY: 12
      })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }
}

