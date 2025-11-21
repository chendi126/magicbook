/**
 * 颜色格式工具类
 * 支持 HEX、RGB、HSL 格式之间的转换和格式化
 */

export type ColorFormat = 'HEX' | 'RGB' | 'HSL';

export class ColorFormatUtils {
  /**
   * 格式化颜色值
   * @param hex HEX 颜色值
   * @param format 目标格式
   * @returns 格式化后的颜色字符串
   */
  static formatColor(hex: string, format: ColorFormat): string {
    switch (format) {
      case 'HEX':
        return hex.toUpperCase();
      case 'RGB':
        return this.hexToRgbString(hex);
      case 'HSL':
        return this.hexToHslString(hex);
      default:
        return hex.toUpperCase();
    }
  }

  /**
   * HEX 转 RGB 对象
   */
  static hexToRgb(hex: string): { r: number, g: number, b: number } {
    // 移除 # 号
    hex = hex.replace('#', '');
    
    // 解析 RGB 值
    const r = parseInt(hex.substring(0, 2), 16);
    const g = parseInt(hex.substring(2, 4), 16);
    const b = parseInt(hex.substring(4, 6), 16);
    
    return { r, g, b };
  }

  /**
   * HEX 转 RGB 字符串
   */
  static hexToRgbString(hex: string): string {
    const rgb = this.hexToRgb(hex);
    return `rgb(${rgb.r}, ${rgb.g}, ${rgb.b})`;
  }

  /**
   * HEX 转 HSL 对象
   */
  static hexToHsl(hex: string): { h: number, s: number, l: number } {
    const rgb = this.hexToRgb(hex);
    
    // 归一化 RGB 值到 0-1
    const r = rgb.r / 255;
    const g = rgb.g / 255;
    const b = rgb.b / 255;
    
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    const delta = max - min;
    
    let h = 0;
    let s = 0;
    const l = (max + min) / 2;
    
    if (delta !== 0) {
      // 计算饱和度
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);
      
      // 计算色相
      if (max === r) {
        h = ((g - b) / delta + (g < b ? 6 : 0)) / 6;
      } else if (max === g) {
        h = ((b - r) / delta + 2) / 6;
      } else {
        h = ((r - g) / delta + 4) / 6;
      }
    }
    
    return {
      h: Math.round(h * 360),
      s: Math.round(s * 100),
      l: Math.round(l * 100)
    };
  }

  /**
   * HEX 转 HSL 字符串
   */
  static hexToHslString(hex: string): string {
    const hsl = this.hexToHsl(hex);
    return `hsl(${hsl.h}°, ${hsl.s}%, ${hsl.l}%)`;
  }

  /**
   * RGB 转 HEX
   */
  static rgbToHex(r: number, g: number, b: number): string {
    const toHex = (n: number) => {
      const hex = Math.round(n).toString(16);
      return hex.length === 1 ? '0' + hex : hex;
    };
    
    return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
  }

  /**
   * HSL 转 HEX
   */
  static hslToHex(h: number, s: number, l: number): string {
    // 归一化 HSL 值
    h = h / 360;
    s = s / 100;
    l = l / 100;
    
    let r, g, b;
    
    if (s === 0) {
      r = g = b = l; // 灰色
    } else {
      const hue2rgb = (p: number, q: number, t: number) => {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
      };
      
      const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      const p = 2 * l - q;
      
      r = hue2rgb(p, q, h + 1/3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1/3);
    }
    
    return this.rgbToHex(r * 255, g * 255, b * 255);
  }

  /**
   * 获取格式显示名称
   */
  static getFormatLabel(format: ColorFormat): string {
    switch (format) {
      case 'HEX':
        return 'HEX';
      case 'RGB':
        return 'RGB';
      case 'HSL':
        return 'HSL';
      default:
        return 'HEX';
    }
  }
}

