import { window } from '@kit.ArkUI';
import { CommonConstants } from '../common/Constants';

@ObservedV2
export class ShareConfigModel {
  @Trace sheetType: SheetType = SheetType.BOTTOM;
  @Trace windowBottomPadding: number = 0;
  @Trace isLayoutFullScreen: boolean = false;

  @Computed
  get bottomPadding() {
    if (this.sheetType === SheetType.BOTTOM) {
      return this.windowBottomPadding;
    }
    return CommonConstants.PADDING_L;
  }

  /**
   * 主动获取底部避让区域高度
   */
  public queryWindowBottomPadding: () => void = () => {
    window.getLastWindow(getContext()).then(currentWindow => {
      const area = currentWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      this.windowBottomPadding = px2vp(area.bottomRect.height);
    })
  }
  /**
   * 监听avoidAreaChange的回调函数
   * @param options
   */
  private setWindowBottomPadding: (options: window.AvoidAreaOptions) => void = (options: window.AvoidAreaOptions) => {
    if (options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
      this.windowBottomPadding = px2vp(options.area.bottomRect.height)
    }
  }

  /**
   * 监听底部避让区域变化
   */
  public registerWindowBottomPadding() {
    this.queryWindowBottomPadding();
    window.getLastWindow(getContext()).then(currentWindow => {
      currentWindow.on('avoidAreaChange', this.setWindowBottomPadding);
    })
  }

  /**
   * 取消监听底部避让区域变化
   */
  public unRegisterWindowBottomPadding() {
    window.getLastWindow(getContext()).then(currentWindow => {
      currentWindow.off('avoidAreaChange', this.setWindowBottomPadding);
    })
  }

  /**
   * 还原应用窗口模式
   */
  public restoreWindowLayout() {
    window.getLastWindow(getContext()).then(currentWindow => {
      currentWindow.setWindowLayoutFullScreen(this.isLayoutFullScreen);
    })
  }
}
