// 标签模型
export interface Tag {
  name: string;      // 标签名称
  color: string;     // 标签颜色（用于 UI 显示）
  isPreset: boolean; // 是否为预设标签
}

// 预设标签列表
export const PRESET_TAGS: Tag[] = [
  { name: '自然', color: '#4CAF50', isPreset: true },
  { name: '科技', color: '#2196F3', isPreset: true },
  { name: '复古', color: '#795548', isPreset: true },
  { name: '清新', color: '#00BCD4', isPreset: true },
  { name: '温暖', color: '#FF9800', isPreset: true },
  { name: '冷色调', color: '#3F51B5', isPreset: true },
  { name: '暖色调', color: '#FF5722', isPreset: true },
  { name: '简约', color: '#9E9E9E', isPreset: true },
  { name: '活力', color: '#E91E63', isPreset: true },
  { name: '优雅', color: '#9C27B0', isPreset: true },
  { name: '梦幻', color: '#BA68C8', isPreset: true },
  { name: '商务', color: '#607D8B', isPreset: true }
];

// 标签工具类
export class TagUtils {
  // 从字符串解析标签数组
  static parseTagsFromString(tagsStr: string): string[] {
    if (!tagsStr || tagsStr.trim() === '') {
      return [];
    }
    return tagsStr.split(',').map((tag: string) => tag.trim()).filter((tag: string) => tag !== '');
  }

  // 将标签数组转换为字符串
  static tagsToString(tags: string[]): string {
    return tags.join(',');
  }

  // 获取标签的显示颜色
  static getTagColor(tagName: string): string {
    const presetTag = PRESET_TAGS.find((tag: Tag) => tag.name === tagName);
    if (presetTag) {
      return presetTag.color;
    }
    // 自定义标签使用默认颜色
    return '#757575';
  }

  // 检查是否为预设标签
  static isPresetTag(tagName: string): boolean {
    return PRESET_TAGS.some((tag: Tag) => tag.name === tagName);
  }

  // 验证标签名称
  static validateTagName(tagName: string): boolean {
    if (!tagName || tagName.trim() === '') {
      return false;
    }
    // 标签名称长度限制
    if (tagName.length > 10) {
      return false;
    }
    // 不允许包含逗号（用作分隔符）
    if (tagName.includes(',')) {
      return false;
    }
    return true;
  }

  // 去重标签数组
  static uniqueTags(tags: string[]): string[] {
    return Array.from(new Set(tags));
  }
}

