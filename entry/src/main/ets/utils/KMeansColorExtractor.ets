// K-Means 颜色提取工具类
import { ColorInfo } from '../models/ColorInfo';
import { RGBColor } from './ImageUtils';

interface KMeansCluster {
  centroid: RGBColor;
  colors: RGBColor[];
}

export class KMeansColorExtractor {
  /**
   * 使用 K-Means 算法提取颜色
   * @param colors 颜色数组
   * @param k 要提取的颜色数量
   * @param maxIterations 最大迭代次数
   * @returns 颜色信息数组
   */
  static extractColors(colors: RGBColor[], k: number, maxIterations: number = 20): ColorInfo[] {
    if (colors.length === 0) return [];
    if (k <= 0) return [];
    if (colors.length <= k) {
      // 如果颜色数量少于k，直接返回所有颜色
      return colors.map((color: RGBColor) => {
        const colorInfo: ColorInfo = {
          hex: KMeansColorExtractor.rgbToHex(color.r, color.g, color.b),
          rgb: `${Math.round(color.r)}, ${Math.round(color.g)}, ${Math.round(color.b)}`,
          percentage: Math.round(100 / colors.length)
        };
        return colorInfo;
      });
    }

    // 1. 初始化聚类中心（使用 K-Means++ 算法）
    const initialCentroids = KMeansColorExtractor.initializeCentroidsKMeansPlusPlus(colors, k);

    // 2. 迭代优化
    let clusters = KMeansColorExtractor.createClusters(initialCentroids);
    let converged = false;
    let iteration = 0;

    while (!converged && iteration < maxIterations) {
      // 分配颜色到最近的聚类中心
      clusters = KMeansColorExtractor.assignColorsToCluster(colors, clusters);

      // 更新聚类中心
      const newClusters = KMeansColorExtractor.updateCentroids(clusters);

      // 检查是否收敛
      converged = KMeansColorExtractor.hasConverged(clusters, newClusters);
      clusters = newClusters;
      iteration++;
    }

    console.info(`K-Means 算法迭代 ${iteration} 次后收敛`);

    // 3. 转换为 ColorInfo 格式
    const totalCount = colors.length;
    const colorInfos: ColorInfo[] = clusters
      .filter((cluster: KMeansCluster) => cluster.colors.length > 0)
      .map((cluster: KMeansCluster) => {
        const centroid = cluster.centroid;
        const percentage = Math.round((cluster.colors.length / totalCount) * 100);

        const colorInfo: ColorInfo = {
          hex: KMeansColorExtractor.rgbToHex(centroid.r, centroid.g, centroid.b),
          rgb: `${Math.round(centroid.r)}, ${Math.round(centroid.g)}, ${Math.round(centroid.b)}`,
          percentage: percentage
        };
        return colorInfo;
      })
      .sort((a: ColorInfo, b: ColorInfo) => {
        const aPercentage = a.percentage ?? 0;
        const bPercentage = b.percentage ?? 0;
        return bPercentage - aPercentage;
      });

    return colorInfos;
  }

  /**
   * 使用 K-Means++ 算法初始化聚类中心
   */
  private static initializeCentroidsKMeansPlusPlus(colors: RGBColor[], k: number): RGBColor[] {
    const centroids: RGBColor[] = [];

    // 随机选择第一个中心点
    const firstIndex = Math.floor(Math.random() * colors.length);
    const firstColor = colors[firstIndex];
    centroids.push({ r: firstColor.r, g: firstColor.g, b: firstColor.b });

    // 选择剩余的 k-1 个中心点
    for (let i = 1; i < k; i++) {
      const distances: number[] = colors.map((color: RGBColor) => {
        // 计算到最近中心点的距离
        let minDist = Infinity;
        centroids.forEach((centroid: RGBColor) => {
          const dist = KMeansColorExtractor.colorDistance(color, centroid);
          minDist = Math.min(minDist, dist);
        });
        return minDist;
      });

      // 使用加权概率选择下一个中心点
      const totalDist = distances.reduce((sum: number, d: number) => sum + d, 0);
      let random = Math.random() * totalDist;
      let selectedIndex = 0;

      for (let j = 0; j < distances.length; j++) {
        random -= distances[j];
        if (random <= 0) {
          selectedIndex = j;
          break;
        }
      }

      const selectedColor = colors[selectedIndex];
      centroids.push({ r: selectedColor.r, g: selectedColor.g, b: selectedColor.b });
    }

    return centroids;
  }

  /**
   * 创建空的聚类
   */
  private static createClusters(centroids: RGBColor[]): KMeansCluster[] {
    return centroids.map((centroid: RGBColor) => {
      const cluster: KMeansCluster = {
        centroid: { r: centroid.r, g: centroid.g, b: centroid.b },
        colors: []
      };
      return cluster;
    });
  }

  /**
   * 将颜色分配到最近的聚类中心
   */
  private static assignColorsToCluster(colors: RGBColor[], clusters: KMeansCluster[]): KMeansCluster[] {
    const newClusters = clusters.map((cluster: KMeansCluster) => {
      const centroid = cluster.centroid;
      const newCluster: KMeansCluster = {
        centroid: { r: centroid.r, g: centroid.g, b: centroid.b },
        colors: []
      };
      return newCluster;
    });

    colors.forEach((color: RGBColor) => {
      let minDist = Infinity;
      let closestClusterIndex = 0;

      newClusters.forEach((cluster: KMeansCluster, index: number) => {
        const dist = KMeansColorExtractor.colorDistance(color, cluster.centroid);
        if (dist < minDist) {
          minDist = dist;
          closestClusterIndex = index;
        }
      });

      newClusters[closestClusterIndex].colors.push({ r: color.r, g: color.g, b: color.b });
    });

    return newClusters;
  }

  /**
   * 更新聚类中心（计算每个聚类的平均颜色）
   */
  private static updateCentroids(clusters: KMeansCluster[]): KMeansCluster[] {
    return clusters.map((cluster: KMeansCluster) => {
      if (cluster.colors.length === 0) {
        // 如果聚类为空，保持原来的中心点
        const centroid = cluster.centroid;
        const newCluster: KMeansCluster = {
          centroid: { r: centroid.r, g: centroid.g, b: centroid.b },
          colors: []
        };
        return newCluster;
      }

      // 计算平均颜色
      const initialSum: RGBColor = { r: 0, g: 0, b: 0 };
      const sum = cluster.colors.reduce((acc: RGBColor, color: RGBColor) => {
        const result: RGBColor = {
          r: acc.r + color.r,
          g: acc.g + color.g,
          b: acc.b + color.b
        };
        return result;
      }, initialSum);

      const newCentroid: RGBColor = {
        r: sum.r / cluster.colors.length,
        g: sum.g / cluster.colors.length,
        b: sum.b / cluster.colors.length
      };

      // 复制颜色数组
      const newColors: RGBColor[] = [];
      cluster.colors.forEach((color: RGBColor) => {
        newColors.push({ r: color.r, g: color.g, b: color.b });
      });

      const newCluster: KMeansCluster = {
        centroid: newCentroid,
        colors: newColors
      };
      return newCluster;
    });
  }

  /**
   * 检查是否收敛（聚类中心不再变化）
   */
  private static hasConverged(oldClusters: KMeansCluster[], newClusters: KMeansCluster[]): boolean {
    const threshold = 1.0; // 颜色距离阈值

    for (let i = 0; i < oldClusters.length; i++) {
      const oldCentroid = oldClusters[i].centroid;
      const newCentroid = newClusters[i].centroid;
      const dist = KMeansColorExtractor.colorDistance(oldCentroid, newCentroid);

      if (dist > threshold) {
        return false;
      }
    }

    return true;
  }

  /**
   * 计算两个颜色之间的欧几里得距离
   */
  private static colorDistance(c1: RGBColor, c2: RGBColor): number {
    const dr = c1.r - c2.r;
    const dg = c1.g - c2.g;
    const db = c1.b - c2.b;
    return Math.sqrt(dr * dr + dg * dg + db * db);
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
}
