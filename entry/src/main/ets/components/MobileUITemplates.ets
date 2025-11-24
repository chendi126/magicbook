/**
 * 移动应用 UI 模板组件
 * 提供各种常见的移动应用界面模板
 */

import { ColorRole } from '../utils/ColorRoleMapper';
import { ThemeColors } from '../utils/ThemeColors';

/**
 * 卡片模板
 * 展示带图片的信息卡片和操作按钮
 */
@Component
export struct CardTemplate {
  @Prop colorRoles: ColorRole = {
    primary: '#007AFF',
    secondary: '#5856D6',
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#333333',
    textSecondary: '#666666',
    accent: '#FF9500',
    error: '#FF3B30',
    success: '#34C759',
    border: '#E0E0E0'
  };

  build() {
    Column() {
      Text('卡片界面')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colorRoles.text)
        .margin({ bottom: 16 })

      // 主卡片
      Column() {
        // 卡片头部 - 使用主色
        Column() {
          Row() {
            Text('精选推荐')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .layoutWeight(1)

            Text('NEW')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('rgba(255, 255, 255, 0.3)')
              .borderRadius(10)
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .height(120)
        .backgroundColor(this.colorRoles.primary)
        .borderRadius({ topLeft: 16, topRight: 16 })
        .justifyContent(FlexAlign.End)

        // 卡片内容
        Column() {
          Text('探索精彩内容')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.colorRoles.text)
            .margin({ bottom: 8 })

          Text('发现更多有趣的功能和特性，让你的体验更加丰富多彩。')
            .fontSize(14)
            .fontColor(this.colorRoles.textSecondary)
            .lineHeight(22)
            .margin({ bottom: 16 })

          // 统计信息
          Row() {
            Column() {
              Text('1,234')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.colorRoles.accent)
              Text('浏览量')
                .fontSize(12)
                .fontColor(this.colorRoles.textSecondary)
                .margin({ top: 4 })
            }
            .layoutWeight(1)

            Column() {
              Text('567')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.colorRoles.accent)
              Text('点赞')
                .fontSize(12)
                .fontColor(this.colorRoles.textSecondary)
                .margin({ top: 4 })
            }
            .layoutWeight(1)

            Column() {
              Text('89')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.colorRoles.accent)
              Text('评论')
                .fontSize(12)
                .fontColor(this.colorRoles.textSecondary)
                .margin({ top: 4 })
            }
            .layoutWeight(1)
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 操作按钮
          Row() {
            Button('查看详情')
              .fontSize(15)
              .fontColor('#FFFFFF')
              .backgroundColor(this.colorRoles.primary)
              .borderRadius(20)
              .layoutWeight(1)
              .height(44)
              .margin({ right: 8 })

            Button('分享')
              .fontSize(15)
              .fontColor(this.colorRoles.secondary)
              .backgroundColor(this.colorRoles.surface)
              .borderRadius(20)
              .layoutWeight(1)
              .height(44)
              .margin({ left: 8 })
          }
          .width('100%')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.colorRoles.surface)
        .borderRadius({ bottomLeft: 16, bottomRight: 16 })
      }
      .width('100%')
      .borderRadius(16)
      .shadow({
        radius: 12,
        color: 'rgba(0, 0, 0, 0.1)',
        offsetY: 4
      })
    }
    .width('100%')
    .padding(16)
  }
}

/**
 * 按钮模板
 * 展示各种按钮样式
 */
@Component
export struct ButtonTemplate {
  @Prop colorRoles: ColorRole = {
    primary: '#007AFF',
    secondary: '#5856D6',
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#333333',
    textSecondary: '#666666',
    accent: '#FF9500',
    error: '#FF3B30',
    success: '#34C759',
    border: '#E0E0E0'
  };

  build() {
    Column() {
      Text('按钮样式')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colorRoles.text)
        .margin({ bottom: 16 })

      // 主要按钮（实心）
      Column() {
        Text('主要按钮')
          .fontSize(14)
          .fontColor(this.colorRoles.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Row({ space: 12 }) {
          Button('主色按钮')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(this.colorRoles.primary)
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)

          Button('辅色按钮')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(this.colorRoles.secondary)
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)

          Button('强调按钮')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(this.colorRoles.accent)
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.colorRoles.surface)
      .borderRadius(12)
      .margin({ bottom: 16 })

      // 轮廓按钮（空心）
      Column() {
        Text('轮廓按钮')
          .fontSize(14)
          .fontColor(this.colorRoles.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Row({ space: 12 }) {
          Button('主色轮廓')
            .fontSize(15)
            .fontColor(this.colorRoles.primary)
            .backgroundColor('transparent')
            .border({ width: 2, color: this.colorRoles.primary })
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)

          Button('辅色轮廓')
            .fontSize(15)
            .fontColor(this.colorRoles.secondary)
            .backgroundColor('transparent')
            .border({ width: 2, color: this.colorRoles.secondary })
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.colorRoles.surface)
      .borderRadius(12)
      .margin({ bottom: 16 })

      // 文字按钮
      Column() {
        Text('文字按钮')
          .fontSize(14)
          .fontColor(this.colorRoles.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Row({ space: 16 }) {
          Text('主色文字')
            .fontSize(15)
            .fontColor(this.colorRoles.primary)
            .fontWeight(FontWeight.Medium)

          Text('辅色文字')
            .fontSize(15)
            .fontColor(this.colorRoles.secondary)
            .fontWeight(FontWeight.Medium)

          Text('强调文字')
            .fontSize(15)
            .fontColor(this.colorRoles.accent)
            .fontWeight(FontWeight.Medium)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.colorRoles.surface)
      .borderRadius(12)

      // 状态按钮
      Column() {
        Text('状态按钮')
          .fontSize(14)
          .fontColor(this.colorRoles.textSecondary)
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Row({ space: 12 }) {
          Button('成功')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(this.colorRoles.success)
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)

          Button('错误')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(this.colorRoles.error)
            .borderRadius(22)
            .height(44)
            .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.colorRoles.surface)
      .borderRadius(12)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(16)
  }
}

/**
 * 列表模板
 * 展示列表项样式
 */
@Component
export struct ListTemplate {
  @Prop colorRoles: ColorRole = {
    primary: '#007AFF',
    secondary: '#5856D6',
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#333333',
    textSecondary: '#666666',
    accent: '#FF9500',
    error: '#FF3B30',
    success: '#34C759',
    border: '#E0E0E0'
  };

  build() {
    Column() {
      Text('列表界面')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colorRoles.text)
        .margin({ bottom: 16 })

      Column() {
        // 列表项 1
        this.buildListItem('我的收藏', '128 个配色方案', this.colorRoles.primary, true)

        Divider()
          .color(this.colorRoles.border)
          .strokeWidth(1)

        // 列表项 2
        this.buildListItem('最近使用', '15 个配色方案', this.colorRoles.secondary, true)

        Divider()
          .color(this.colorRoles.border)
          .strokeWidth(1)

        // 列表项 3
        this.buildListItem('我的创作', '42 个配色方案', this.colorRoles.accent, true)

        Divider()
          .color(this.colorRoles.border)
          .strokeWidth(1)

        // 列表项 4
        this.buildListItem('分享记录', '查看分享历史', this.colorRoles.success, false)
      }
      .width('100%')
      .backgroundColor(this.colorRoles.surface)
      .borderRadius(12)
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  buildListItem(title: string, subtitle: string, accentColor: string, showBadge: boolean) {
    Row() {
      // 左侧色条
      Column()
        .width(4)
        .height(40)
        .backgroundColor(accentColor)
        .borderRadius(2)
        .margin({ right: 12 })

      // 内容
      Column() {
        Text(title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.colorRoles.text)
          .margin({ bottom: 4 })

        Text(subtitle)
          .fontSize(14)
          .fontColor(this.colorRoles.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧
      Row() {
        if (showBadge) {
          Text('NEW')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .backgroundColor(accentColor)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .margin({ right: 8 })
        }

        Text('›')
          .fontSize(24)
          .fontColor(this.colorRoles.textSecondary)
      }
    }
    .width('100%')
    .padding(16)
  }
}

/**
 * 数据仪表盘模板
 * 展示数据统计卡片
 */
@Component
export struct DashboardTemplate {
  @Prop colorRoles: ColorRole = {
    primary: '#007AFF',
    secondary: '#5856D6',
    background: '#FFFFFF',
    surface: '#F5F5F5',
    text: '#333333',
    textSecondary: '#666666',
    accent: '#FF9500',
    error: '#FF3B30',
    success: '#34C759',
    border: '#E0E0E0'
  };

  build() {
    Column() {
      Text('数据仪表盘')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colorRoles.text)
        .margin({ bottom: 16 })

      // 统计卡片网格
      GridRow({ columns: 2, gutter: 12 }) {
        GridCol() {
          this.buildStatCard('总配色', '156', '+12', this.colorRoles.primary)
        }

        GridCol() {
          this.buildStatCard('收藏', '89', '+5', this.colorRoles.secondary)
        }

        GridCol() {
          this.buildStatCard('分享', '234', '+28', this.colorRoles.accent)
        }

        GridCol() {
          this.buildStatCard('浏览', '1.2K', '+156', this.colorRoles.success)
        }
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  buildStatCard(label: string, value: string, change: string, color: string) {
    Column() {
      Row() {
        Column()
          .width(40)
          .height(40)
          .backgroundColor(color)
          .borderRadius(20)
          .opacity(0.2)
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ bottom: 12 })

      Text(value)
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.colorRoles.text)
        .margin({ bottom: 4 })

      Text(label)
        .fontSize(14)
        .fontColor(this.colorRoles.textSecondary)
        .margin({ bottom: 8 })

      Row() {
        Text(change)
          .fontSize(12)
          .fontColor(this.colorRoles.success)
          .fontWeight(FontWeight.Medium)

        Text(' 本周')
          .fontSize(12)
          .fontColor(this.colorRoles.textSecondary)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.colorRoles.surface)
    .borderRadius(12)
    .alignItems(HorizontalAlign.Start)
  }
}

