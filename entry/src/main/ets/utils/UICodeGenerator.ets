/**
 * UI 组件代码生成器
 * 根据配色方案生成可复用的 UI 组件代码
 */

import { ColorRole } from './ColorRoleMapper';

export type TemplateType = 'card' | 'button' | 'list' | 'dashboard';

export class UICodeGenerator {
  /**
   * 生成 ArkTS 组件代码
   */
  static generateArkTSCode(templateType: TemplateType, colorRoles: ColorRole, schemeName: string): string {
    switch (templateType) {
      case 'card':
        return UICodeGenerator.generateCardCode(colorRoles, schemeName);
      case 'button':
        return UICodeGenerator.generateButtonCode(colorRoles, schemeName);
      case 'list':
        return UICodeGenerator.generateListCode(colorRoles, schemeName);
      case 'dashboard':
        return UICodeGenerator.generateDashboardCode(colorRoles, schemeName);
      default:
        return '';
    }
  }

  /**
   * 生成卡片组件代码
   */
  private static generateCardCode(colorRoles: ColorRole, schemeName: string): string {
    return `/**
 * ${schemeName} - 卡片组件
 * 自动生成的配色方案应用示例
 */

@Component
export struct ${UICodeGenerator.toPascalCase(schemeName)}Card {
  title: string = '精选推荐';
  description: string = '发现更多有趣的功能和特性';
  
  build() {
    Column() {
      // 卡片头部
      Column() {
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width('100%')
      .height(120)
      .padding(16)
      .backgroundColor('${colorRoles.primary}')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .justifyContent(FlexAlign.End)

      // 卡片内容
      Column() {
        Text(this.description)
          .fontSize(14)
          .fontColor('${colorRoles.textSecondary}')
          .margin({ bottom: 16 })

        // 操作按钮
        Row() {
          Button('查看详情')
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor('${colorRoles.primary}')
            .borderRadius(20)
            .layoutWeight(1)
            .height(44)

          Button('分享')
            .fontSize(15)
            .fontColor('${colorRoles.secondary}')
            .backgroundColor('${colorRoles.surface}')
            .borderRadius(20)
            .layoutWeight(1)
            .height(44)
            .margin({ left: 8 })
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor('${colorRoles.surface}')
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    }
    .width('100%')
    .borderRadius(16)
    .shadow({ radius: 12, color: 'rgba(0, 0, 0, 0.1)', offsetY: 4 })
  }
}`;
  }

  /**
   * 生成按钮组件代码
   */
  private static generateButtonCode(colorRoles: ColorRole, schemeName: string): string {
    return `/**
 * ${schemeName} - 按钮组件
 * 自动生成的配色方案应用示例
 */

@Component
export struct ${UICodeGenerator.toPascalCase(schemeName)}Buttons {
  build() {
    Column({ space: 12 }) {
      // 主要按钮
      Button('主色按钮')
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('${colorRoles.primary}')
        .borderRadius(22)
        .height(44)
        .width('100%')

      // 辅色按钮
      Button('辅色按钮')
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor('${colorRoles.secondary}')
        .borderRadius(22)
        .height(44)
        .width('100%')

      // 轮廓按钮
      Button('轮廓按钮')
        .fontSize(15)
        .fontColor('${colorRoles.primary}')
        .backgroundColor('transparent')
        .border({ width: 2, color: '${colorRoles.primary}' })
        .borderRadius(22)
        .height(44)
        .width('100%')
    }
    .width('100%')
  }
}`;
  }

  /**
   * 生成列表组件代码
   */
  private static generateListCode(colorRoles: ColorRole, schemeName: string): string {
    return `/**
 * ${schemeName} - 列表组件
 * 自动生成的配色方案应用示例
 */

@Component
export struct ${UICodeGenerator.toPascalCase(schemeName)}List {
  @State items: string[] = ['项目 1', '项目 2', '项目 3'];
  
  build() {
    Column() {
      ForEach(this.items, (item: string, index: number) => {
        Row() {
          // 左侧色条
          Column()
            .width(4)
            .height(40)
            .backgroundColor('${colorRoles.primary}')
            .borderRadius(2)
            .margin({ right: 12 })

          // 内容
          Text(item)
            .fontSize(16)
            .fontColor('${colorRoles.text}')
            .layoutWeight(1)

          // 箭头
          Text('›')
            .fontSize(24)
            .fontColor('${colorRoles.textSecondary}')
        }
        .width('100%')
        .padding(16)
        .backgroundColor('${colorRoles.surface}')
      })
    }
    .width('100%')
    .borderRadius(12)
  }
}`;
  }

  /**
   * 生成仪表盘组件代码
   */
  private static generateDashboardCode(colorRoles: ColorRole, schemeName: string): string {
    return `// ${schemeName} - 仪表盘组件代码
// 包含统计卡片和数据展示`;
  }

  /**
   * 转换为 PascalCase
   */
  private static toPascalCase(str: string): string {
    return str
      .replace(/[^a-zA-Z0-9\u4e00-\u9fa5]/g, ' ')
      .split(' ')
      .filter(word => word.length > 0)
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join('');
  }
}

