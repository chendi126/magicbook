// 我的页面
import { ThemeManager, ThemeMode } from '../utils/ThemeManager';
import { ThemeColors } from '../utils/ThemeColors';

import promptAction from '@ohos.promptAction';
import { PreferencesManager } from '../utils/PreferencesManager';
import router from '@ohos.router';

// 预设表情头像
const PRESET_AVATARS = ['😀', '😃', '😄', '😁', '😊', '😇', '🙂', '🙃', '😉', '😌',
  '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜',
  '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏', '😒', '😞'];

@Component
export struct MinePage {
  private themeManager: ThemeManager = ThemeManager.getInstance();
  private prefsManager: PreferencesManager = PreferencesManager.getInstance();

  @State currentThemeMode: ThemeMode = ThemeMode.AUTO;
  @State showAvatarSheet: boolean = false;
  @State showNameSheet: boolean = false;
  @State showThemeSheet: boolean = false;
  @State showHelpSheet: boolean = false;
  @State showFeedbackSheet: boolean = false;

  // 用户信息
  @State userAvatar: string = '😀';
  @State userName: string = '色彩收集者';
  @State userNameInput: string = '';

  async aboutToAppear() {
    console.info('MinePage aboutToAppear - 页面初始化');
    // 初始化时获取当前主题模式
    this.currentThemeMode = this.themeManager.currentThemeMode;

    // 加载用户信息
    await this.loadUserInfo();
  }

  // 加载用户信息
  async loadUserInfo() {
    try {
      const avatar = await this.prefsManager.getUserAvatar();
      const name = await this.prefsManager.getUserName();
      if (avatar) {
        this.userAvatar = avatar;
      }
      if (name) {
        this.userName = name;
      }
      console.info(`用户信息加载成功: 头像=${this.userAvatar}, 昵称=${this.userName}`);
    } catch (err) {
      console.error('加载用户信息失败: ' + JSON.stringify(err));
    }
  }

  build() {
    Column() {
      // 标题栏 - 简洁样式
      Row() {
        Text('我的')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .padding(16)
      }
      .width('100%')
      .backgroundColor(ThemeColors.background)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])

      // 内容区
      Scroll() {
        Column() {
          // 用户信息卡片
          this.buildUserCard();

          // 创新功能分组标题
          Text('探索')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.textSecondary)
            .margin({ top: 24, bottom: 12, left: 4 })

          // 色彩性格图谱入口
          this.buildColorPersonalityCard();

          // 成就中心入口
          this.buildAchievementCard();

          // 设置分组标题
          Text('设置')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.textSecondary)
            .margin({ top: 24, bottom: 12, left: 4 })

          // 主题设置
          this.buildThemeSettingItem();

          // 设置分组标题
          Text('关于')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeColors.textSecondary)
            .margin({ top: 24, bottom: 12, left: 4 })

          // 其他设置项
          this.buildSettingItem('关于应用', '拾色师 v1.0.0', $r('app.media.ic_public_detail'), () => {});
          this.buildHelpSettingItem();
          this.buildFeedbackSettingItem();
          this.buildClickableSettingItem('隐私政策', '查看隐私保护说明', $r('app.media.ic_public_privacy'), () => {
            router.pushUrl({ url: 'pages/Yinsi' });
          });
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      }
      .layoutWeight(1)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeColors.backgroundSecondary)
  }

  // 用户信息卡片
  @Builder
  buildUserCard() {
    Column() {
      // 头像 - 表情符号（可点击）
      Column() {
        Text(this.userAvatar)
          .fontSize(64)
          .textAlign(TextAlign.Center)
      }
      .width(100)
      .height(100)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(ThemeColors.backgroundInput)
      .borderRadius(50)
      .onClick(() => {
        console.info('点击头像，打开选择面板');
        this.showAvatarSheet = true;
      })
      .bindSheet($$this.showAvatarSheet, this.buildAvatarSheetContent(), {
        detents: [SheetSize.MEDIUM, SheetSize.LARGE, 450],
        showClose: true,
        title: { title: '选择头像', subtitle: '点击表情设置为头像' }
      })

      // 用户名（可点击）
      Row() {
        Text(this.userName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)

        Image($r('app.media.ic_public_edit'))
          .width(16)
          .height(16)
          .fillColor(ThemeColors.textTertiary)
          .margin({ left: 8 })
      }
      .margin({ top: 16 })
      .onClick(() => {
        console.info('点击昵称，打开编辑面板');
        this.userNameInput = this.userName;
        this.showNameSheet = true;
      })
      .bindSheet($$this.showNameSheet, this.buildNameSheetContent(), {
        detents: [SheetSize.MEDIUM, 250],
        showClose: true,
        title: { title: '修改昵称', subtitle: '最多20个字符' }
      })

      // 签名
      Text('发现生活中的美好色彩')
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(24)
    .linearGradient({
      angle: 135,
      colors: [[ThemeColors.background, 0.0], [ThemeColors.backgroundSecondary, 1.0]]
    })
    .borderRadius(16)
    .shadow({
      radius: 12,
      color: ThemeColors.shadowMedium,
      offsetY: 4
    })
  }

  // 主题设置项
  @Builder
  buildThemeSettingItem() {
    Row() {
      // 图标
      Image($r('app.media.ic_public_themes'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.primary)
        .margin({ right: 12 })

      Column() {
        Text('主题模式')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text(this.themeManager.getThemeModeName(this.currentThemeMode))
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 4,
      color: ThemeColors.shadowLight,
      offsetY: 1
    })
    .onClick(() => {
      console.info('点击主题设置，打开选择面板');
      this.showThemeSheet = true;
    })
    .bindSheet($$this.showThemeSheet, this.buildThemeSheetContent(), {
      detents: [SheetSize.MEDIUM, SheetSize.LARGE, 320],
      showClose: true,
      title: { title: '主题设置', subtitle: '选择您喜欢的主题模式' }
    })
  }

  @Builder
  buildSettingItem(title: string, subtitle: string, icon: Resource, onClick: () => void) {
    Row() {
      // 图标
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(ThemeColors.textSecondary)
        .margin({ right: 12 })

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text(subtitle)
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 4,
      color: ThemeColors.shadowLight,
      offsetY: 1
    })
    .onClick(onClick)
  }

  // 使用帮助设置项
  @Builder
  buildHelpSettingItem() {
    Row() {
      // 图标
      Image($r('app.media.ic_public_help'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.textSecondary)
        .margin({ right: 12 })

      Column() {
        Text('使用帮助')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text('查看使用教程')
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 4,
      color: ThemeColors.shadowLight,
      offsetY: 1
    })
    .onClick(() => {
      this.showHelpSheet = true;
    })
    .bindSheet($$this.showHelpSheet, this.buildHelpSheetContent(), {
      detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      showClose: true,
      title: { title: '使用帮助', subtitle: '快速上手指南' }
    })
  }

  // 反馈建议设置项
  @Builder
  buildFeedbackSettingItem() {
    Row() {
      // 图标
      Image($r('app.media.ic_public_email'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.textSecondary)
        .margin({ right: 12 })

      Column() {
        Text('反馈建议')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text('告诉我们您的想法')
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 4,
      color: ThemeColors.shadowLight,
      offsetY: 1
    })
    .onClick(() => {
      this.showFeedbackSheet = true;
    })
    .bindSheet($$this.showFeedbackSheet, this.buildFeedbackSheetContent(), {
      detents: [SheetSize.MEDIUM, SheetSize.LARGE],
      showClose: true,
      title: { title: '反馈建议', subtitle: '联系我们' }
    })
  }

  @Builder
  buildClickableSettingItem(title: string, subtitle: string, icon: Resource, onClick: () => void) {
    Row() {
      // 图标
      Image(icon)
        .width(24)
        .height(24)
        .fillColor(ThemeColors.textSecondary)
        .margin({ right: 12 })

      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text(subtitle)
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 4,
      color: ThemeColors.shadowLight,
      offsetY: 1
    })
    .onClick(onClick)
  }

  // 1. 头像选择半模态内容
  @Builder
  buildAvatarSheetContent() {
    Column() {
      Grid() {
        ForEach(PRESET_AVATARS, (avatar: string) => {
          GridItem() {
            Text(avatar)
              .fontSize(40)
              .width(60)
              .height(60)
              .textAlign(TextAlign.Center)
              .backgroundColor(this.userAvatar === avatar ?
                ThemeColors.primaryLight : ThemeColors.backgroundInput)
              .borderRadius(30)
              .border({
                width: this.userAvatar === avatar ? 2 : 0,
                color: ThemeColors.primary
              })
              .onClick(async () => {
                this.userAvatar = avatar;
                await this.prefsManager.setUserAvatar(avatar);
                promptAction.showToast({
                  message: '头像已更新',
                  duration: 1500
                });
                this.showAvatarSheet = false;
              })
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
      .rowsGap(12)
      .columnsGap(12)
      .width('100%')
      .height(350)
    }
    .width('100%')
    .padding(16)
  }

  // 2. 名称编辑半模态内容
  @Builder
  buildNameSheetContent() {
    Column() {
      TextInput({ text: this.userNameInput, placeholder: '请输入昵称' })
        .width('100%')
        .height(48)
        .fontSize(16)
        .backgroundColor(ThemeColors.backgroundInput)
        .borderRadius(8)
        .maxLength(20)
        .onChange((value: string) => {
          this.userNameInput = value;
        })

      Button('确定')
        .width('100%')
        .height(44)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor(ThemeColors.primary)
        .borderRadius(8)
        .margin({ top: 16 })
        .onClick(async () => {
          if (this.userNameInput.trim().length === 0) {
            promptAction.showToast({
              message: '昵称不能为空',
              duration: 1500
            });
            return;
          }
          this.userName = this.userNameInput.trim();
          await this.prefsManager.setUserName(this.userName);
          promptAction.showToast({
            message: '昵称已更新',
            duration: 1500
          });
          this.showNameSheet = false;
        })
    }
    .width('100%')
    .padding(16)
  }

  // 3. 主题选择半模态内容
  @Builder
  buildThemeSheetContent() {
    Column() {
      // 跟随系统
      this.buildThemeOption(
        ThemeMode.AUTO,
        '跟随系统',
        '根据系统设置自动切换深色/浅色模式',
        $r('app.media.ic_public_themes')
      );

      // 浅色模式
      this.buildThemeOption(
        ThemeMode.LIGHT,
        '浅色模式',
        '始终使用浅色主题',
        $r('app.media.ic_controlcenter_brightness_plus')
      );

      // 深色模式
      this.buildThemeOption(
        ThemeMode.DARK,
        '深色模式',
        '始终使用深色主题',
        $r('app.media.ic_controlcenter_dark_filled')
      );
    }
    .width('100%')
    .padding(16)
  }

  // 主题选项
  @Builder
  buildThemeOption(mode: ThemeMode, title: string, subtitle: string, icon: Resource) {
    Row() {
      // 图标容器
      Column() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(this.currentThemeMode === mode ? '#FFFFFF' : ThemeColors.textSecondary)
      }
      .width(48)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.currentThemeMode === mode ? ThemeColors.primary : ThemeColors.backgroundInput)
      .borderRadius(24)
      .margin({ right: 12 })

      // 文字
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(this.currentThemeMode === mode ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text(subtitle)
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 选中标记
      if (this.currentThemeMode === mode) {
        Column() {
          Image($r('app.media.ic_public_ok_filled'))
            .width(20)
            .height(20)
            .fillColor('#FFFFFF')
        }
        .width(28)
        .height(28)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(ThemeColors.success)
        .borderRadius(14)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.currentThemeMode === mode ? ThemeColors.primaryLight : ThemeColors.background)
    .borderRadius(16)
    .margin({ bottom: 12 })
    .border({
      width: this.currentThemeMode === mode ? 2 : 0,
      color: ThemeColors.primary
    })
    .shadow({
      radius: this.currentThemeMode === mode ? 8 : 4,
      color: this.currentThemeMode === mode ? ThemeColors.shadowMedium : ThemeColors.shadowLight,
      offsetY: 2
    })
    .onClick(() => {
      this.themeManager.setThemeMode(mode);
      this.currentThemeMode = mode; // 更新本地状态
      promptAction.showToast({
        message: `已切换到${this.themeManager.getThemeModeName(mode)}`,
        duration: 1500
      });
      // 延迟关闭对话框，让用户看到选中效果
      setTimeout(() => {
        this.showThemeSheet = false;
      }, 500);
    })
  }

  // 4. 使用帮助半模态内容
  @Builder
  buildHelpSheetContent() {
    Column() {
      Scroll() {
        Column() {
          this.buildHelpStep('1. 侧边栏导航', '🎯 点击右上角悬浮按钮打开菜单，访问所有功能。长按可拖动按钮位置');
          this.buildHelpStep('2. 色彩提取', '📸 在首页选择照片，应用会自动提取主要色彩，支持多种算法');
          this.buildHelpStep('3. 配色库', '📚 保存和管理你的配色方案，支持搜索、筛选和分组');
          this.buildHelpStep('4. 情绪日记', '📝 用色彩记录每天的心情，配上天气和笔记');
          this.buildHelpStep('5. 色彩实验室', '🧪 调整色彩、生成渐变、探索配色规则');
          this.buildHelpStep('6. UI预览', '🎨 将配色应用到UI设计中，实时预览效果');
          this.buildHelpStep('7. 灵感广场', '🌈 浏览精选配色方案，一键保存到配色库');
        }
        .width('100%')
      }
      .height(400)
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  buildHelpStep(title: string, content: string) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeColors.textPrimary)
        .width('100%')
        .margin({ bottom: 8 })

      Text(content)
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .lineHeight(22)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 20 })
  }

  // 色彩性格图谱卡片
  @Builder
  buildColorPersonalityCard() {
    Row() {
      // 图标
      Image($r('app.media.ic_public_favor'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.primary)
        .margin({ right: 12 })

      Column() {
        Text('色彩性格图谱')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text('发现你的色彩DNA')
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 4,
      color: ThemeColors.shadowLight,
      offsetY: 1
    })
    .onClick(() => {
      router.pushUrl({ url: 'pages/ColorPersonalityPage' });
    })
  }

  // 成就中心卡片
  @Builder
  buildAchievementCard() {
    Row() {
      // 图标
      Image($r('app.media.ic_public_ok_filled'))
        .width(24)
        .height(24)
        .fillColor(ThemeColors.primary)
        .margin({ right: 12 })

      Column() {
        Text('成就中心')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeColors.textPrimary)
          .margin({ bottom: 4 })

        Text('解锁专属成就徽章')
          .fontSize(13)
          .fontColor(ThemeColors.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.ic_public_arrow_right'))
        .width(16)
        .height(16)
        .fillColor(ThemeColors.textTertiary)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeColors.background)
    .borderRadius(12)
    .margin({ bottom: 8 })
    .shadow({
      radius: 4,
      color: ThemeColors.shadowLight,
      offsetY: 1
    })
    .onClick(() => {
      router.pushUrl({ url: 'pages/AchievementPage' });
    })
  }

  // 5. 反馈建议半模态内容
  @Builder
  buildFeedbackSheetContent() {
    Column() {
      Text('感谢您使用本应用！')
        .fontSize(16)
        .fontColor(ThemeColors.textPrimary)
        .margin({ bottom: 16 })

      Text('如果您有任何建议或遇到问题，欢迎通过邮件与我们联系：')
        .fontSize(14)
        .fontColor(ThemeColors.textSecondary)
        .lineHeight(22)
        .margin({ bottom: 24 })

      Row() {
        Text('3403938458@qq.com')
          .fontSize(16)
          .fontColor(ThemeColors.primary)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)

        Button('复制')
          .fontSize(14)
          .height(36)
          .backgroundColor(ThemeColors.primary)
          .onClick(() => {
            // 复制邮箱地址
            promptAction.showToast({
              message: '邮箱地址已复制',
              duration: 1500
            });
          })
      }
      .width('100%')
      .padding(16)
      .backgroundColor(ThemeColors.backgroundInput)
      .borderRadius(8)

      Text('我们会认真阅读每一封邮件，并尽快回复您。')
        .fontSize(13)
        .fontColor(ThemeColors.textTertiary)
        .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
  }
}

