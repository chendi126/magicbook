// 颜色提取工具类
import { ColorInfo } from '../models/ColorInfo';
import { ImageUtils, PixelData, RGBColor } from './ImageUtils';
import { KMeansColorExtractor } from './KMeansColorExtractor';

interface ColorCluster {
  r: number;
  g: number;
  b: number;
  count: number;
}

export type ColorExtractionAlgorithm = 'median-cut' | 'kmeans';

export class ColorExtractor {
  /**
   * 从图片URI提取颜色
   * @param uri 图片URI
   * @param colorCount 要提取的颜色数量
   * @param algorithm 提取算法（'median-cut' 或 'kmeans'）
   * @returns 颜色信息数组
   */
  static async extractFromImage(
    uri: string,
    colorCount: number = 6,
    algorithm: ColorExtractionAlgorithm = 'kmeans'
  ): Promise<ColorInfo[]> {
    try {
      console.info(`开始提取颜色，URI: ${uri}，算法: ${algorithm}`);

      // 1. 读取图片像素数据
      const pixelData = await ImageUtils.getPixelDataFromUri(uri);
      if (!pixelData) {
        console.error('无法读取图片像素数据');
        return [];
      }

      // 2. 采样像素（每隔10个像素采样一次）
      const sampledColors = ImageUtils.samplePixels(pixelData, 10);
      console.info(`采样了 ${sampledColors.length} 个像素`);

      if (sampledColors.length === 0) {
        return [];
      }

      // 3. 根据选择的算法提取颜色
      let colorInfos: ColorInfo[];
      if (algorithm === 'kmeans') {
        // 使用 K-Means 算法
        colorInfos = KMeansColorExtractor.extractColors(sampledColors, colorCount);
      } else {
        // 使用中位切分算法
        const clusters = ColorExtractor.clusterColors(sampledColors, colorCount);
        const totalCount = clusters.reduce((sum: number, c: ColorCluster) => sum + c.count, 0);
        colorInfos = clusters.map((cluster: ColorCluster) => {
          const r = Math.round(cluster.r);
          const g = Math.round(cluster.g);
          const b = Math.round(cluster.b);
          const percentage = Math.round((cluster.count / totalCount) * 100);

          const colorInfo: ColorInfo = {
            hex: ColorExtractor.rgbToHex(r, g, b),
            rgb: `${r}, ${g}, ${b}`,
            percentage: percentage
          };
          return colorInfo;
        });
      }

      console.info('颜色提取完成，提取了 ' + colorInfos.length + ' 种颜色');
      return colorInfos;
    } catch (err) {
      console.error('颜色提取失败: ' + JSON.stringify(err));
      return [];
    }
  }

  /**
   * 简化的颜色聚类算法（基于颜色空间分割）
   */
  private static clusterColors(colors: RGBColor[], k: number): ColorCluster[] {
    if (colors.length === 0) return [];

    // 使用中位切分算法（Median Cut）的简化版本
    // 将颜色空间递归分割成k个区域

    const buckets: RGBColor[][] = [colors];

    while (buckets.length < k) {
      // 找到范围最大的桶
      let maxRangeBucketIndex = 0;
      let maxRange = 0;

      buckets.forEach((bucket: RGBColor[], index: number) => {
        const range = ColorExtractor.getColorRange(bucket);
        if (range > maxRange) {
          maxRange = range;
          maxRangeBucketIndex = index;
        }
      });

      // 分割这个桶
      const bucketToSplit = buckets[maxRangeBucketIndex];
      if (bucketToSplit.length < 2) break;

      const splitResult = ColorExtractor.splitBucket(bucketToSplit);
      const bucket1 = splitResult[0];
      const bucket2 = splitResult[1];
      buckets.splice(maxRangeBucketIndex, 1, bucket1, bucket2);
    }

    // 计算每个桶的平均颜色
    const clusters: ColorCluster[] = buckets.map((bucket: RGBColor[]) => {
      const avgColor = ColorExtractor.getAverageColor(bucket);
      const cluster: ColorCluster = {
        r: avgColor.r,
        g: avgColor.g,
        b: avgColor.b,
        count: bucket.length
      };
      return cluster;
    });

    clusters.sort((a: ColorCluster, b: ColorCluster) => b.count - a.count);
    return clusters;
  }

  /**
   * 获取颜色数组的范围（最大通道差值）
   */
  private static getColorRange(colors: RGBColor[]): number {
    if (colors.length === 0) return 0;

    let minR = 255, maxR = 0;
    let minG = 255, maxG = 0;
    let minB = 255, maxB = 0;

    colors.forEach((c: RGBColor) => {
      minR = Math.min(minR, c.r);
      maxR = Math.max(maxR, c.r);
      minG = Math.min(minG, c.g);
      maxG = Math.max(maxG, c.g);
      minB = Math.min(minB, c.b);
      maxB = Math.max(maxB, c.b);
    });

    const rangeR = maxR - minR;
    const rangeG = maxG - minG;
    const rangeB = maxB - minB;

    return Math.max(rangeR, rangeG, rangeB);
  }

  /**
   * 分割颜色桶
   */
  private static splitBucket(colors: RGBColor[]): RGBColor[][] {
    // 找出范围最大的通道
    let minR = 255, maxR = 0;
    let minG = 255, maxG = 0;
    let minB = 255, maxB = 0;

    colors.forEach((c: RGBColor) => {
      minR = Math.min(minR, c.r);
      maxR = Math.max(maxR, c.r);
      minG = Math.min(minG, c.g);
      maxG = Math.max(maxG, c.g);
      minB = Math.min(minB, c.b);
      maxB = Math.max(maxB, c.b);
    });

    const rangeR = maxR - minR;
    const rangeG = maxG - minG;
    const rangeB = maxB - minB;

    // 按范围最大的通道排序
    let sortedColors: RGBColor[];
    if (rangeR >= rangeG && rangeR >= rangeB) {
      sortedColors = colors.sort((a: RGBColor, b: RGBColor) => a.r - b.r);
    } else if (rangeG >= rangeR && rangeG >= rangeB) {
      sortedColors = colors.sort((a: RGBColor, b: RGBColor) => a.g - b.g);
    } else {
      sortedColors = colors.sort((a: RGBColor, b: RGBColor) => a.b - b.b);
    }

    // 从中位数分割
    const mid = Math.floor(sortedColors.length / 2);
    const result: RGBColor[][] = [sortedColors.slice(0, mid), sortedColors.slice(mid)];
    return result;
  }

  /**
   * 计算平均颜色
   */
  private static getAverageColor(colors: RGBColor[]): RGBColor {
    if (colors.length === 0) {
      const emptyColor: RGBColor = { r: 0, g: 0, b: 0 };
      return emptyColor;
    }

    const initialSum: RGBColor = { r: 0, g: 0, b: 0 };
    const sum = colors.reduce((acc: RGBColor, c: RGBColor) => {
      const result: RGBColor = {
        r: acc.r + c.r,
        g: acc.g + c.g,
        b: acc.b + c.b
      };
      return result;
    }, initialSum);

    const avgColor: RGBColor = {
      r: sum.r / colors.length,
      g: sum.g / colors.length,
      b: sum.b / colors.length
    };
    return avgColor;
  }

  /**
   * RGB转HEX
   */
  static rgbToHex(r: number, g: number, b: number): string {
    const toHex = (n: number) => {
      const clamped = Math.max(0, Math.min(255, Math.round(n)));
      const hex = clamped.toString(16).toUpperCase();
      return hex.length === 1 ? '0' + hex : hex;
    };
    return '#' + toHex(r) + toHex(g) + toHex(b);
  }

  /**
   * HEX转RGB
   */
  static hexToRgb(hex: string): RGBColor | null {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    if (result) {
      const rgb: RGBColor = {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
      };
      return rgb;
    }
    return null;
  }
}

