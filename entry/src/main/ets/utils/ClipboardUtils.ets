// 剪贴板工具类
import pasteboard from '@ohos.pasteboard';

export class ClipboardUtils {
  /**
   * 复制文本到剪贴板
   * @param text 要复制的文本
   * @returns 是否成功
   */
  static async copyText(text: string): Promise<boolean> {
    try {
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteData);
      console.info('复制成功: ' + text);
      return true;
    } catch (err) {
      console.error('复制失败: ' + JSON.stringify(err));
      return false;
    }
  }

  /**
   * 从剪贴板读取文本
   * @returns 剪贴板中的文本
   */
  static async getText(): Promise<string> {
    try {
      const systemPasteboard = pasteboard.getSystemPasteboard();
      const pasteData = await systemPasteboard.getData();
      return pasteData.getPrimaryText();
    } catch (err) {
      console.error('读取剪贴板失败: ' + JSON.stringify(err));
      return '';
    }
  }
}

