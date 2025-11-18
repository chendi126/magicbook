import webview from '@ohos.web.webview';

@Entry
@Component
struct ICP {
  @State message: string = 'Hello World';
  @State web_view_controller: webview.WebviewController = new webview.WebviewController();

  build() {
    Column() {
      Web({
        src: "https://agreement-drcn.hispace.dbankcloud.cn/index.html?lang=zh&agreementId=1821096092243094208",
        controller: this.web_view_controller
      })
        .width('100%')
        .height('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ top: 44 }) // 添加顶部安全区域padding
  }
}