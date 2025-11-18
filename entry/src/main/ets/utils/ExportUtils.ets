// 导出工具类
import { ColorScheme } from '../models/ColorScheme';

export interface ExportFormat {
  type: 'css' | 'json' | 'scss' | 'tailwind' | 'arkts';
  name: string;
  icon: string;
}

// JSON 导出数据接口
export interface ExportedColorScheme {
  name: string;
  colors: string[];
  tags: string[];
  createTime: number;
  colorCount: number;
}

export const EXPORT_FORMATS: ExportFormat[] = [
  { type: 'arkts', name: 'ArkTS 常量', icon: '🔷' },
  { type: 'css', name: 'CSS 变量', icon: '🎨' },
  { type: 'scss', name: 'SCSS 变量', icon: '💎' },
  { type: 'json', name: 'JSON 数据', icon: '📋' },
  { type: 'tailwind', name: 'Tailwind 配置', icon: '🌊' }
];

export class ExportUtils {
  /**
   * 导出为 ArkTS 常量格式
   * @param scheme 配色方案
   * @returns ArkTS 代码
   */
  static exportToArkTS(scheme: ColorScheme): string {
    const lines: string[] = [];
    lines.push(`// ${scheme.name}`);
    lines.push('// 配色方案常量');
    lines.push('');

    // 导出为常量数组
    lines.push('export const COLORS = {');
    scheme.colors.forEach((color: string, index: number) => {
      const varName = `COLOR_${index + 1}`;
      const comma = index < scheme.colors.length - 1 ? ',' : '';
      lines.push(`  ${varName}: '${color}'${comma}`);
    });
    lines.push('};');
    lines.push('');

    // 导出为数组形式
    lines.push('// 或使用数组形式');
    lines.push('export const COLOR_PALETTE: string[] = [');
    scheme.colors.forEach((color: string, index: number) => {
      const comma = index < scheme.colors.length - 1 ? ',' : '';
      lines.push(`  '${color}'${comma}`);
    });
    lines.push('];');

    return lines.join('\n');
  }

  /**
   * 导出为 CSS 变量格式
   * @param scheme 配色方案
   * @returns CSS 代码
   */
  static exportToCSS(scheme: ColorScheme): string {
    const lines: string[] = [];
    lines.push(`/* ${scheme.name} */`);
    lines.push(':root {');

    scheme.colors.forEach((color: string, index: number) => {
      const varName = `--color-${index + 1}`;
      lines.push(`  ${varName}: ${color};`);
    });

    lines.push('}');
    return lines.join('\n');
  }

  /**
   * 导出为 SCSS 变量格式
   * @param scheme 配色方案
   * @returns SCSS 代码
   */
  static exportToSCSS(scheme: ColorScheme): string {
    const lines: string[] = [];
    lines.push(`// ${scheme.name}`);
    
    scheme.colors.forEach((color: string, index: number) => {
      const varName = `$color-${index + 1}`;
      lines.push(`${varName}: ${color};`);
    });
    
    return lines.join('\n');
  }

  /**
   * 导出为 JSON 格式
   * @param scheme 配色方案
   * @returns JSON 字符串
   */
  static exportToJSON(scheme: ColorScheme): string {
    const data: ExportedColorScheme = {
      name: scheme.name,
      colors: scheme.colors,
      tags: scheme.tags ? scheme.tags.split(',') : [],
      createTime: scheme.createTime,
      colorCount: scheme.colors.length
    };
    return JSON.stringify(data, null, 2);
  }

  /**
   * 导出为 Tailwind 配置格式
   * @param scheme 配色方案
   * @returns Tailwind 配置代码
   */
  static exportToTailwind(scheme: ColorScheme): string {
    const lines: string[] = [];
    lines.push(`// ${scheme.name}`);
    lines.push('module.exports = {');
    lines.push('  theme: {');
    lines.push('    extend: {');
    lines.push('      colors: {');
    
    scheme.colors.forEach((color: string, index: number) => {
      const colorName = `custom-${index + 1}`;
      lines.push(`        '${colorName}': '${color}',`);
    });
    
    lines.push('      }');
    lines.push('    }');
    lines.push('  }');
    lines.push('}');
    return lines.join('\n');
  }

  /**
   * 根据格式类型导出
   * @param scheme 配色方案
   * @param format 导出格式
   * @returns 导出的代码字符串
   */
  static export(scheme: ColorScheme, format: 'css' | 'json' | 'scss' | 'tailwind' | 'arkts'): string {
    switch (format) {
      case 'arkts':
        return ExportUtils.exportToArkTS(scheme);
      case 'css':
        return ExportUtils.exportToCSS(scheme);
      case 'scss':
        return ExportUtils.exportToSCSS(scheme);
      case 'json':
        return ExportUtils.exportToJSON(scheme);
      case 'tailwind':
        return ExportUtils.exportToTailwind(scheme);
      default:
        return '';
    }
  }

  /**
   * 生成配色方案的纯文本描述
   * @param scheme 配色方案
   * @returns 纯文本描述
   */
  static exportToText(scheme: ColorScheme): string {
    const lines: string[] = [];
    lines.push(`配色方案：${scheme.name}`);
    lines.push(`颜色数量：${scheme.colors.length}`);
    lines.push('');
    lines.push('颜色列表：');
    
    scheme.colors.forEach((color: string, index: number) => {
      lines.push(`${index + 1}. ${color}`);
    });
    
    if (scheme.tags && scheme.tags !== '') {
      lines.push('');
      lines.push(`标签：${scheme.tags}`);
    }
    
    return lines.join('\n');
  }

  /**
   * 获取导出格式的文件扩展名
   * @param format 导出格式
   * @returns 文件扩展名
   */
  static getFileExtension(format: 'css' | 'json' | 'scss' | 'tailwind' | 'arkts' | 'text'): string {
    switch (format) {
      case 'arkts':
        return '.ets';
      case 'css':
        return '.css';
      case 'scss':
        return '.scss';
      case 'json':
        return '.json';
      case 'tailwind':
        return '.js';
      case 'text':
        return '.txt';
      default:
        return '.txt';
    }
  }
}

