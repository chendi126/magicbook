// 加载状态组件
@Component
export struct LoadingState {
  message: string = '加载中...'; // 加载提示文字
  indicatorSize: number = 48; // 加载指示器大小

  build() {
    Column() {
      // 加载指示器
      LoadingProgress()
        .width(this.indicatorSize)
        .height(this.indicatorSize)
        .color('#007DFF')
        .margin({ bottom: 16 })

      // 提示文字
      Text(this.message)
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}

// 全屏加载遮罩
@Component
export struct LoadingOverlay {
  @Link isLoading: boolean;
  message: string = '处理中...';

  build() {
    if (this.isLoading) {
      Stack() {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.3)')

        // 加载内容
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
            .color('#007DFF')
            .margin({ bottom: 16 })

          Text(this.message)
            .fontSize(16)
            .fontColor('#333333')
        }
        .width(200)
        .height(150)
        .backgroundColor('#FFFFFF')
        .borderRadius(12)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .shadow({
          radius: 20,
          color: 'rgba(0, 0, 0, 0.1)',
          offsetX: 0,
          offsetY: 4
        })
      }
      .width('100%')
      .height('100%')
    }
  }
}

