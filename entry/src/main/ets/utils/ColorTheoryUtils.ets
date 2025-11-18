/**
 * 颜色理论工具类
 * 提供色彩理论相关的计算功能，包括颜色空间转换、配色方案生成等
 */

/**
 * HSL 颜色表示
 */
export interface HSLColor {
  h: number; // 色相 (0-360)
  s: number; // 饱和度 (0-100)
  l: number; // 亮度 (0-100)
}

/**
 * RGB 颜色表示
 */
export interface RGBColor {
  r: number; // 红色 (0-255)
  g: number; // 绿色 (0-255)
  b: number; // 蓝色 (0-255)
}

/**
 * 配色方案类型
 */
export type ColorSchemeType = 
  | 'complementary'      // 互补色
  | 'analogous'          // 类似色
  | 'triadic'            // 三角配色
  | 'tetradic'           // 四角配色
  | 'monochromatic'      // 单色配色
  | 'split-complementary'; // 分裂互补色

export class ColorTheoryUtils {
  /**
   * RGB 转 HSL
   */
  static rgbToHsl(r: number, g: number, b: number): HSLColor {
    // 归一化 RGB 值到 0-1
    const rNorm = r / 255;
    const gNorm = g / 255;
    const bNorm = b / 255;

    const max = Math.max(rNorm, gNorm, bNorm);
    const min = Math.min(rNorm, gNorm, bNorm);
    const delta = max - min;

    let h = 0;
    let s = 0;
    const l = (max + min) / 2;

    if (delta !== 0) {
      // 计算饱和度
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);

      // 计算色相
      if (max === rNorm) {
        h = ((gNorm - bNorm) / delta + (gNorm < bNorm ? 6 : 0)) / 6;
      } else if (max === gNorm) {
        h = ((bNorm - rNorm) / delta + 2) / 6;
      } else {
        h = ((rNorm - gNorm) / delta + 4) / 6;
      }
    }

    return {
      h: Math.round(h * 360),
      s: Math.round(s * 100),
      l: Math.round(l * 100)
    };
  }

  /**
   * HSL 转 RGB
   */
  static hslToRgb(h: number, s: number, l: number): RGBColor {
    // 归一化 HSL 值
    const hNorm = h / 360;
    const sNorm = s / 100;
    const lNorm = l / 100;

    let r: number;
    let g: number;
    let b: number;

    if (sNorm === 0) {
      // 无饱和度，灰色
      r = g = b = lNorm;
    } else {
      const hue2rgb = (p: number, q: number, t: number): number => {
        let tNormalized = t;
        if (tNormalized < 0) tNormalized += 1;
        if (tNormalized > 1) tNormalized -= 1;
        if (tNormalized < 1 / 6) return p + (q - p) * 6 * tNormalized;
        if (tNormalized < 1 / 2) return q;
        if (tNormalized < 2 / 3) return p + (q - p) * (2 / 3 - tNormalized) * 6;
        return p;
      };

      const q = lNorm < 0.5 ? lNorm * (1 + sNorm) : lNorm + sNorm - lNorm * sNorm;
      const p = 2 * lNorm - q;

      r = hue2rgb(p, q, hNorm + 1 / 3);
      g = hue2rgb(p, q, hNorm);
      b = hue2rgb(p, q, hNorm - 1 / 3);
    }

    return {
      r: Math.round(r * 255),
      g: Math.round(g * 255),
      b: Math.round(b * 255)
    };
  }

  /**
   * RGB 转 HEX
   */
  static rgbToHex(r: number, g: number, b: number): string {
    const toHex = (n: number): string => {
      const hex = Math.round(n).toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    };
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
  }

  /**
   * HEX 转 RGB
   */
  static hexToRgb(hex: string): RGBColor | null {
    const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    if (!result) {
      return null;
    }
    return {
      r: parseInt(result[1], 16),
      g: parseInt(result[2], 16),
      b: parseInt(result[3], 16)
    };
  }

  /**
   * 旋转色相
   */
  static rotateHue(hsl: HSLColor, degrees: number): HSLColor {
    let newHue = (hsl.h + degrees) % 360;
    if (newHue < 0) {
      newHue += 360;
    }
    return {
      h: newHue,
      s: hsl.s,
      l: hsl.l
    };
  }

  /**
   * 调整饱和度
   */
  static adjustSaturation(hsl: HSLColor, amount: number): HSLColor {
    const newS = Math.max(0, Math.min(100, hsl.s + amount));
    return {
      h: hsl.h,
      s: newS,
      l: hsl.l
    };
  }

  /**
   * 调整亮度
   */
  static adjustLightness(hsl: HSLColor, amount: number): HSLColor {
    const newL = Math.max(0, Math.min(100, hsl.l + amount));
    return {
      h: hsl.h,
      s: hsl.s,
      l: newL
    };
  }

  /**
   * 生成互补色配色方案（2个颜色）
   * 色轮上相距 180° 的颜色
   */
  static generateComplementary(baseColor: string): string[] {
    const rgb = ColorTheoryUtils.hexToRgb(baseColor);
    if (!rgb) return [baseColor];

    const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
    const complementary = ColorTheoryUtils.rotateHue(hsl, 180);

    const rgb2 = ColorTheoryUtils.hslToRgb(complementary.h, complementary.s, complementary.l);

    return [
      baseColor,
      ColorTheoryUtils.rgbToHex(rgb2.r, rgb2.g, rgb2.b)
    ];
  }

  /**
   * 生成类似色配色方案（3个颜色）
   * 色轮上相邻的颜色（±30°）
   */
  static generateAnalogous(baseColor: string): string[] {
    const rgb = ColorTheoryUtils.hexToRgb(baseColor);
    if (!rgb) return [baseColor];

    const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
    const analogous1 = ColorTheoryUtils.rotateHue(hsl, -30);
    const analogous2 = ColorTheoryUtils.rotateHue(hsl, 30);

    const rgb1 = ColorTheoryUtils.hslToRgb(analogous1.h, analogous1.s, analogous1.l);
    const rgb2 = ColorTheoryUtils.hslToRgb(analogous2.h, analogous2.s, analogous2.l);

    return [
      ColorTheoryUtils.rgbToHex(rgb1.r, rgb1.g, rgb1.b),
      baseColor,
      ColorTheoryUtils.rgbToHex(rgb2.r, rgb2.g, rgb2.b)
    ];
  }

  /**
   * 生成三角配色方案（3个颜色）
   * 色轮上等距 120° 的三个颜色
   */
  static generateTriadic(baseColor: string): string[] {
    const rgb = ColorTheoryUtils.hexToRgb(baseColor);
    if (!rgb) return [baseColor];

    const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
    const triadic1 = ColorTheoryUtils.rotateHue(hsl, 120);
    const triadic2 = ColorTheoryUtils.rotateHue(hsl, 240);

    const rgb1 = ColorTheoryUtils.hslToRgb(triadic1.h, triadic1.s, triadic1.l);
    const rgb2 = ColorTheoryUtils.hslToRgb(triadic2.h, triadic2.s, triadic2.l);

    return [
      baseColor,
      ColorTheoryUtils.rgbToHex(rgb1.r, rgb1.g, rgb1.b),
      ColorTheoryUtils.rgbToHex(rgb2.r, rgb2.g, rgb2.b)
    ];
  }

  /**
   * 生成四角配色方案（4个颜色）
   * 色轮上等距 90° 的四个颜色
   */
  static generateTetradic(baseColor: string): string[] {
    const rgb = ColorTheoryUtils.hexToRgb(baseColor);
    if (!rgb) return [baseColor];

    const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
    const tetradic1 = ColorTheoryUtils.rotateHue(hsl, 90);
    const tetradic2 = ColorTheoryUtils.rotateHue(hsl, 180);
    const tetradic3 = ColorTheoryUtils.rotateHue(hsl, 270);

    const rgb1 = ColorTheoryUtils.hslToRgb(tetradic1.h, tetradic1.s, tetradic1.l);
    const rgb2 = ColorTheoryUtils.hslToRgb(tetradic2.h, tetradic2.s, tetradic2.l);
    const rgb3 = ColorTheoryUtils.hslToRgb(tetradic3.h, tetradic3.s, tetradic3.l);

    return [
      baseColor,
      ColorTheoryUtils.rgbToHex(rgb1.r, rgb1.g, rgb1.b),
      ColorTheoryUtils.rgbToHex(rgb2.r, rgb2.g, rgb2.b),
      ColorTheoryUtils.rgbToHex(rgb3.r, rgb3.g, rgb3.b)
    ];
  }

  /**
   * 生成单色配色方案（5个颜色）
   * 同一色相的不同明度和饱和度
   */
  static generateMonochromatic(baseColor: string): string[] {
    const rgb = ColorTheoryUtils.hexToRgb(baseColor);
    if (!rgb) return [baseColor];

    const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
    const colors: string[] = [];

    // 生成 5 个不同亮度的颜色
    const lightnessValues = [20, 40, 60, 80, 90];
    lightnessValues.forEach((lightness: number) => {
      const newHsl: HSLColor = {
        h: hsl.h,
        s: hsl.s,
        l: lightness
      };
      const newRgb = ColorTheoryUtils.hslToRgb(newHsl.h, newHsl.s, newHsl.l);
      colors.push(ColorTheoryUtils.rgbToHex(newRgb.r, newRgb.g, newRgb.b));
    });

    return colors;
  }

  /**
   * 生成分裂互补色配色方案（3个颜色）
   * 互补色的相邻色（互补色 ±30°）
   */
  static generateSplitComplementary(baseColor: string): string[] {
    const rgb = ColorTheoryUtils.hexToRgb(baseColor);
    if (!rgb) return [baseColor];

    const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
    const split1 = ColorTheoryUtils.rotateHue(hsl, 150); // 180 - 30
    const split2 = ColorTheoryUtils.rotateHue(hsl, 210); // 180 + 30

    const rgb1 = ColorTheoryUtils.hslToRgb(split1.h, split1.s, split1.l);
    const rgb2 = ColorTheoryUtils.hslToRgb(split2.h, split2.s, split2.l);

    return [
      baseColor,
      ColorTheoryUtils.rgbToHex(rgb1.r, rgb1.g, rgb1.b),
      ColorTheoryUtils.rgbToHex(rgb2.r, rgb2.g, rgb2.b)
    ];
  }

  /**
   * 根据类型生成配色方案
   */
  static generateColorScheme(baseColor: string, type: ColorSchemeType): string[] {
    switch (type) {
      case 'complementary':
        return ColorTheoryUtils.generateComplementary(baseColor);
      case 'analogous':
        return ColorTheoryUtils.generateAnalogous(baseColor);
      case 'triadic':
        return ColorTheoryUtils.generateTriadic(baseColor);
      case 'tetradic':
        return ColorTheoryUtils.generateTetradic(baseColor);
      case 'monochromatic':
        return ColorTheoryUtils.generateMonochromatic(baseColor);
      case 'split-complementary':
        return ColorTheoryUtils.generateSplitComplementary(baseColor);
      default:
        return [baseColor];
    }
  }

  /**
   * 分析配色方案的整体特征
   * 返回主色调（平均色相、饱和度、亮度）
   */
  static analyzeColorScheme(colors: string[]): HSLColor | null {
    if (colors.length === 0) return null;

    let totalH = 0;
    let totalS = 0;
    let totalL = 0;
    let validCount = 0;

    colors.forEach((color: string) => {
      const rgb = ColorTheoryUtils.hexToRgb(color);
      if (rgb) {
        const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
        totalH += hsl.h;
        totalS += hsl.s;
        totalL += hsl.l;
        validCount++;
      }
    });

    if (validCount === 0) return null;

    return {
      h: Math.round(totalH / validCount),
      s: Math.round(totalS / validCount),
      l: Math.round(totalL / validCount)
    };
  }

  /**
   * 基于整体配色方案生成新配色（智能模式）
   * 保留原方案的色调和风格特征
   */
  static generateFromScheme(colors: string[], type: ColorSchemeType): string[] {
    // 分析原配色方案的特征
    const avgHSL = ColorTheoryUtils.analyzeColorScheme(colors);
    if (!avgHSL) {
      // 如果分析失败，使用第一个颜色
      return colors.length > 0 ? ColorTheoryUtils.generateColorScheme(colors[0], type) : [];
    }

    // 将平均 HSL 转换为 HEX 作为基础颜色
    const avgRGB = ColorTheoryUtils.hslToRgb(avgHSL.h, avgHSL.s, avgHSL.l);
    const baseColor = ColorTheoryUtils.rgbToHex(avgRGB.r, avgRGB.g, avgRGB.b);

    // 基于平均色调生成配色方案
    let generatedColors = ColorTheoryUtils.generateColorScheme(baseColor, type);

    // 调整生成的颜色，使其饱和度和亮度更接近原方案
    generatedColors = generatedColors.map((color: string) => {
      const rgb = ColorTheoryUtils.hexToRgb(color);
      if (!rgb) return color;

      const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);

      // 保留色相，但调整饱和度和亮度更接近原方案
      const adjustedHSL: HSLColor = {
        h: hsl.h,
        s: Math.round((hsl.s + avgHSL.s) / 2), // 平均饱和度
        l: Math.round((hsl.l + avgHSL.l) / 2)  // 平均亮度
      };

      const adjustedRGB = ColorTheoryUtils.hslToRgb(adjustedHSL.h, adjustedHSL.s, adjustedHSL.l);
      return ColorTheoryUtils.rgbToHex(adjustedRGB.r, adjustedRGB.g, adjustedRGB.b);
    });

    return generatedColors;
  }

  /**
   * 获取配色方案中最主要的颜色（饱和度最高的颜色）
   */
  static getDominantColor(colors: string[]): string | null {
    if (colors.length === 0) return null;

    let maxSaturation = -1;
    let dominantColor: string | null = null;

    colors.forEach((color: string) => {
      const rgb = ColorTheoryUtils.hexToRgb(color);
      if (rgb) {
        const hsl = ColorTheoryUtils.rgbToHsl(rgb.r, rgb.g, rgb.b);
        if (hsl.s > maxSaturation) {
          maxSaturation = hsl.s;
          dominantColor = color;
        }
      }
    });

    return dominantColor;
  }
}
