// 圆形色块组件
import { ColorInfo } from '../models/ColorInfo';

/**
 * 单个圆形色块
 */
@Component
export struct ColorCircle {
  color: string = '#007AFF';
  circleSize: number = 50;
  showBorder: boolean = true;
  circleBorderColor: string = 'rgba(255, 255, 255, 0.3)';
  circleBorderWidth: number = 2;
  onCircleClick?: () => void = undefined;
  
  build() {
    Stack() {
      // 色块
      Column()
        .width(this.circleSize)
        .height(this.circleSize)
        .backgroundColor(this.color)
        .borderRadius(this.circleSize / 2)
        .border(this.showBorder ? {
          width: this.circleBorderWidth,
          color: this.circleBorderColor
        } : undefined)
        .shadow({
          radius: 8,
          color: this.color + '40',
          offsetY: 4
        })
    }
    .width(this.circleSize)
    .height(this.circleSize)
    .onClick(() => {
      if (this.onCircleClick) {
        this.onCircleClick();
      }
    })
    .transition({
      type: TransitionType.All,
      scale: { x: 1.1, y: 1.1 }
    })
    .animation({
      duration: 200,
      curve: Curve.FastOutSlowIn
    })
  }
}

/**
 * 重叠的圆形色块组
 * 类似头像组的效果
 */
@Component
export struct OverlappingColorCircles {
  colors: string[] = [];
  circleSize: number = 40;
  overlapOffset: number = -12; // 负值表示重叠
  maxDisplay: number = 5; // 最多显示数量
  showCount: boolean = true; // 是否显示剩余数量
  
  build() {
    Row() {
      // 显示的颜色圆圈
      ForEach(this.colors.slice(0, this.maxDisplay), (color: string, index: number) => {
        ColorCircle({
          color: color,
          circleSize: this.circleSize,
          showBorder: true,
          circleBorderColor: 'rgba(255, 255, 255, 0.5)',
          circleBorderWidth: 2
        })
          .margin({ left: index === 0 ? 0 : this.overlapOffset })
          .zIndex(this.colors.length - index) // 后面的在上面
      }, (color: string, index: number) => `${color}_${index}`)
      
      // 如果还有更多颜色，显示数量
      if (this.showCount && this.colors.length > this.maxDisplay) {
        Stack() {
          Column()
            .width(this.circleSize)
            .height(this.circleSize)
            .backgroundColor('rgba(0, 0, 0, 0.6)')
            .borderRadius(this.circleSize / 2)
            .border({
              width: 2,
              color: 'rgba(255, 255, 255, 0.5)'
            })
            .backgroundBlurStyle(BlurStyle.Thin)
          
          Text(`+${this.colors.length - this.maxDisplay}`)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .width(this.circleSize)
        .height(this.circleSize)
        .margin({ left: this.overlapOffset })
        .zIndex(0)
      }
    }
    .alignItems(VerticalAlign.Center)
  }
}

/**
 * 网格排列的圆形色块
 */
@Component
export struct ColorCircleGrid {
  colors: string[] = [];
  circleSize: number = 50;
  spacing: number = 12;
  columns: number = 4; // 每行显示数量
  onColorClick?: (color: string, index: number) => void = undefined;
  
  build() {
    Flex({
      wrap: FlexWrap.Wrap,
      justifyContent: FlexAlign.Start
    }) {
      ForEach(this.colors, (color: string, index: number) => {
        ColorCircle({
          color: color,
          circleSize: this.circleSize,
          onCircleClick: () => {
            if (this.onColorClick) {
              this.onColorClick(color, index);
            }
          }
        })
          .margin({
            right: (index + 1) % this.columns === 0 ? 0 : this.spacing,
            bottom: this.spacing
          })
      }, (color: string, index: number) => `${color}_${index}`)
    }
    .width('100%')
  }
}

/**
 * 大色块展示（主色）+ 小色块（其他色）
 */
@Component
export struct PrimaryColorDisplay {
  primaryColor: string = '#007AFF';
  secondaryColors: string[] = [];
  primarySize: number = 80;
  secondarySize: number = 40;
  
  build() {
    Row() {
      // 主色块（大）
      ColorCircle({
        color: this.primaryColor,
        circleSize: this.primarySize,
        showBorder: true,
        circleBorderColor: 'rgba(255, 255, 255, 0.5)',
        circleBorderWidth: 3
      })
        .margin({ right: 12 })

      // 其他色块（小，重叠排列）
      if (this.secondaryColors.length > 0) {
        OverlappingColorCircles({
          colors: this.secondaryColors,
          circleSize: this.secondarySize,
          overlapOffset: -10,
          maxDisplay: 5,
          showCount: true
        })
      }
    }
    .height(this.primarySize)
    .alignItems(VerticalAlign.Center)
  }
}

