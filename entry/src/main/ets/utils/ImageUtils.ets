// 图片处理工具类
import image from '@ohos.multimedia.image';
import fs from '@ohos.file.fs';

export interface PixelData {
  buffer: ArrayBuffer;
  width: number;
  height: number;
}

export interface RGBColor {
  r: number;
  g: number;
  b: number;
}

export class ImageUtils {
  /**
   * 从URI读取图片像素数据
   * @param uri 图片URI
   * @returns 像素数据
   */
  static async getPixelDataFromUri(uri: string): Promise<PixelData | null> {
    try {
      // 打开文件
      const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      
      // 创建图片源
      const imageSource = image.createImageSource(file.fd);
      
      // 获取图片信息
      const imageInfo = await imageSource.getImageInfo();
      console.info(`图片信息: 宽=${imageInfo.size.width}, 高=${imageInfo.size.height}`);
      
      // 创建 PixelMap（降采样以提高性能）
      const maxSize = 800; // 最大尺寸
      let targetWidth = imageInfo.size.width;
      let targetHeight = imageInfo.size.height;
      
      if (targetWidth > maxSize || targetHeight > maxSize) {
        const scale = Math.min(maxSize / targetWidth, maxSize / targetHeight);
        targetWidth = Math.floor(targetWidth * scale);
        targetHeight = Math.floor(targetHeight * scale);
      }
      
      const decodingOptions: image.DecodingOptions = {
        desiredSize: {
          width: targetWidth,
          height: targetHeight
        },
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      };
      
      const pixelMap = await imageSource.createPixelMap(decodingOptions);
      
      // 读取像素数据
      const pixelBytesNumber = pixelMap.getPixelBytesNumber();
      const buffer = new ArrayBuffer(pixelBytesNumber);
      await pixelMap.readPixelsToBuffer(buffer);
      
      // 关闭文件
      fs.closeSync(file);
      
      // 释放资源
      await imageSource.release();
      await pixelMap.release();
      
      return {
        buffer: buffer,
        width: targetWidth,
        height: targetHeight
      };
    } catch (err) {
      console.error('读取图片像素数据失败: ' + JSON.stringify(err));
      return null;
    }
  }

  /**
   * 从像素数据中获取指定位置的颜色
   * @param pixelData 像素数据
   * @param x X坐标
   * @param y Y坐标
   * @returns RGB颜色值
   */
  static getPixelColor(pixelData: PixelData, x: number, y: number): RGBColor | null {
    if (x < 0 || x >= pixelData.width || y < 0 || y >= pixelData.height) {
      return null;
    }

    const index = (y * pixelData.width + x) * 4; // RGBA 每个像素4个字节
    const uint8Array = new Uint8Array(pixelData.buffer);

    const color: RGBColor = {
      r: uint8Array[index],
      g: uint8Array[index + 1],
      b: uint8Array[index + 2]
    };
    return color;
  }

  /**
   * 采样像素数据（用于颜色提取）
   * @param pixelData 像素数据
   * @param sampleRate 采样率（每隔多少个像素采样一次）
   * @returns 采样的颜色数组
   */
  static samplePixels(pixelData: PixelData, sampleRate: number = 10): RGBColor[] {
    const colors: RGBColor[] = [];
    const uint8Array = new Uint8Array(pixelData.buffer);

    for (let y = 0; y < pixelData.height; y += sampleRate) {
      for (let x = 0; x < pixelData.width; x += sampleRate) {
        const index = (y * pixelData.width + x) * 4;

        // 跳过透明或接近透明的像素
        const alpha = uint8Array[index + 3];
        if (alpha < 128) {
          continue;
        }

        const color: RGBColor = {
          r: uint8Array[index],
          g: uint8Array[index + 1],
          b: uint8Array[index + 2]
        };
        colors.push(color);
      }
    }

    return colors;
  }
}

