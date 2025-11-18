// 空状态组件 - 优化空数据展示
@Component
export struct EmptyState {
  icon?: ResourceStr; // 图标
  title: string = '暂无数据'; // 标题
  description?: string; // 描述
  actionText?: string; // 操作按钮文字
  onAction?: () => void; // 操作按钮回调

  build() {
    Column() {
      // 图标
      if (this.icon) {
        Image(this.icon)
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
          .opacity(0.4)
          .margin({ bottom: 24 })
      } else {
        // 默认图标
        Column()
          .width(120)
          .height(120)
          .backgroundColor('#F5F5F5')
          .borderRadius(60)
          .margin({ bottom: 24 })
      }

      // 标题
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#666666')
        .margin({ bottom: 8 })

      // 描述
      if (this.description) {
        Text(this.description)
          .fontSize(14)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
          .lineHeight(20)
          .margin({ bottom: 24 })
          .maxLines(3)
      }

      // 操作按钮
      if (this.actionText && this.onAction) {
        Button(this.actionText)
          .fontSize(16)
          .fontColor('#007DFF')
          .backgroundColor('#E6F2FF')
          .height(40)
          .padding({ left: 24, right: 24 })
          .stateEffect(true)
          .onClick(() => {
            if (this.onAction) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(32)
  }
}

