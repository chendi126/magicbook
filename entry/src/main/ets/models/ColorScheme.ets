import { TagUtils } from './Tag';

// 配色方案模型
export interface ColorScheme {
  id?: number;          // 数据库ID
  name: string;         // 方案名称
  tags?: string;        // 标签（逗号分隔）
  imagePath?: string;   // 原图路径
  colors: string[];     // 颜色数组（HEX格式）
  createTime: number;   // 创建时间戳
  isFavorite?: boolean; // 是否收藏
  group?: string;       // 分组
}

// 配色方案工具类
export class ColorSchemeUtils {
  // 获取配色方案的标签数组
  static getTags(scheme: ColorScheme): string[] {
    if (!scheme.tags) {
      return [];
    }
    return TagUtils.parseTagsFromString(scheme.tags);
  }

  // 设置配色方案的标签
  static setTags(scheme: ColorScheme, tags: string[]): void {
    scheme.tags = TagUtils.tagsToString(tags);
  }

  // 检查配色方案是否包含指定标签
  static hasTag(scheme: ColorScheme, tagName: string): boolean {
    const tags = ColorSchemeUtils.getTags(scheme);
    return tags.includes(tagName);
  }

  // 添加标签到配色方案
  static addTag(scheme: ColorScheme, tagName: string): void {
    const tags = ColorSchemeUtils.getTags(scheme);
    if (!tags.includes(tagName)) {
      tags.push(tagName);
      ColorSchemeUtils.setTags(scheme, tags);
    }
  }

  // 从配色方案移除标签
  static removeTag(scheme: ColorScheme, tagName: string): void {
    const tags = ColorSchemeUtils.getTags(scheme);
    const filteredTags = tags.filter((tag: string) => tag !== tagName);
    ColorSchemeUtils.setTags(scheme, filteredTags);
  }
}

