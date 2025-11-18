// 毛玻璃卡片组件
import { ThemeColors } from '../utils/ThemeColors';

/**
 * 毛玻璃卡片组件
 * 提供半透明模糊背景效果
 */
@Component
export struct GlassCard {
  // 卡片内容
  @BuilderParam content: () => void = this.buildDefaultContent;
  
  // 样式配置
  cardPadding: number = 16; // 内边距
  cardRadius: number = 20; // 圆角
  cardMargin: number = 0; // 外边距
  
  // 毛玻璃效果配置
  blurRadius: number = 30; // 模糊半径
  backgroundOpacity: number = 0.7; // 背景透明度
  
  // 渐变色配置（可选）
  gradientColors?: string[] = undefined; // 渐变色数组
  
  // 阴影配置
  shadowColor: string = ThemeColors.shadowMedium; // 阴影颜色
  shadowRadius: number = 20; // 阴影半径
  shadowOffsetY: number = 8; // 阴影Y偏移
  
  // 边框配置
  cardBorderWidth: number = 1; // 边框宽度
  cardBorderColor: string = 'rgba(255, 255, 255, 0.2)'; // 边框颜色

  // 点击事件
  onCardClick?: () => void = undefined;
  
  // 默认内容
  @Builder
  buildDefaultContent() {
    Text('GlassCard')
  }
  
  build() {
    Column() {
      this.content();
    }
    .width('100%')
    .padding(this.cardPadding)
    .backgroundColor(this.getBackgroundColor())
    .backgroundBlurStyle(BlurStyle.Thin) // 毛玻璃模糊效果
    .borderRadius(this.cardRadius)
    .border({
      width: this.cardBorderWidth,
      color: this.cardBorderColor
    })
    .linearGradient(this.gradientColors && this.gradientColors.length > 0 ? {
      angle: 135,
      colors: this.getGradientStops()
    } : undefined)
    .margin(this.cardMargin)
    .shadow({
      radius: this.shadowRadius,
      color: this.shadowColor,
      offsetY: this.shadowOffsetY
    })
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
    .transition({
      type: TransitionType.All,
      scale: { x: 0.98, y: 0.98 },
      opacity: 0.8
    })
    .animation({
      duration: 200,
      curve: Curve.FastOutSlowIn
    })
  }
  
  // 获取背景颜色
  private getBackgroundColor(): string {
    // 根据主题返回半透明背景
    const isDark = ThemeColors.background === '#000000';
    if (isDark) {
      return `rgba(28, 28, 30, ${this.backgroundOpacity})`; // 深色模式
    } else {
      return `rgba(255, 255, 255, ${this.backgroundOpacity})`; // 浅色模式
    }
  }
  
  // 获取渐变色停止点
  private getGradientStops(): Array<[string, number]> {
    if (!this.gradientColors || this.gradientColors.length === 0) {
      return [];
    }
    
    const stops: Array<[string, number]> = [];
    const step = 1.0 / (this.gradientColors.length - 1);
    
    this.gradientColors.forEach((color, index) => {
      stops.push([color, index * step]);
    });
    
    return stops;
  }
}

/**
 * 彩色毛玻璃卡片
 * 带有彩色渐变和彩色阴影
 */
@Component
export struct ColorfulGlassCard {
  @BuilderParam content: () => void = this.buildDefaultContent;
  
  // 主色（用于生成渐变和阴影）
  primaryColor: string = ThemeColors.primary;
  
  // 其他配置
  cardPadding: number = 16;
  cardRadius: number = 20;
  onCardClick?: () => void = undefined;
  
  @Builder
  buildDefaultContent() {
    Text('ColorfulGlassCard')
  }
  
  build() {
    GlassCard({
      content: this.content,
      cardPadding: this.cardPadding,
      cardRadius: this.cardRadius,
      gradientColors: [this.primaryColor, this.getSecondaryColor()],
      shadowColor: this.getColorShadow(),
      shadowRadius: 24,
      shadowOffsetY: 12,
      onCardClick: this.onCardClick
    })
  }
  
  // 生成次要颜色（主色的变体）
  private getSecondaryColor(): string {
    // 简单实现：返回稍微透明的主色
    return this.primaryColor + '80'; // 添加50%透明度
  }
  
  // 生成彩色阴影
  private getColorShadow(): string {
    // 主色的半透明版本作为阴影
    return this.primaryColor + '40'; // 25%透明度
  }
}

