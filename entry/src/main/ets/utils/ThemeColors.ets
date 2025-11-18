// 主题颜色工具类
import { ConfigurationConstant } from '@kit.AbilityKit';
import { ThemeManager } from './ThemeManager';

/**
 * 主题颜色管理类
 * 根据当前主题模式返回适配的颜色值
 */
export class ThemeColors {
  /**
   * 判断是否为深色模式
   */
  private static isDark(): boolean {
    const themeManager = ThemeManager.getInstance();
    return themeManager.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  // ========== 背景颜色 ==========

  /** 主背景色 */
  static get background(): string {
    return ThemeColors.isDark() ? '#000000' : '#FFFFFF';
  }

  /** 次级背景色 */
  static get backgroundSecondary(): string {
    return ThemeColors.isDark() ? '#1C1C1E' : '#F5F5F5';
  }

  /** 卡片背景色 */
  static get backgroundCard(): string {
    return ThemeColors.isDark() ? '#1C1C1E' : '#F9F9F9';
  }

  /** 输入框背景色 */
  static get backgroundInput(): string {
    return ThemeColors.isDark() ? '#2C2C2E' : '#F0F0F0';
  }

  /** 悬浮背景色 */
  static get backgroundElevated(): string {
    return ThemeColors.isDark() ? '#2C2C2E' : '#F8F8F8';
  }

  // ========== 文字颜色 ==========

  /** 主文字颜色 */
  static get textPrimary(): string {
    return ThemeColors.isDark() ? '#FFFFFF' : '#000000';
  }

  /** 次级文字颜色 */
  static get textSecondary(): string {
    return ThemeColors.isDark() ? '#EBEBF5' : '#333333';
  }

  /** 三级文字颜色 */
  static get textTertiary(): string {
    return ThemeColors.isDark() ? '#AEAEB2' : '#666666';
  }

  /** 占位符文字颜色 */
  static get textPlaceholder(): string {
    return ThemeColors.isDark() ? '#8E8E93' : '#999999';
  }

  /** 禁用文字颜色 */
  static get textDisabled(): string {
    return ThemeColors.isDark() ? '#636366' : '#CCCCCC';
  }

  // ========== 分割线颜色 ==========

  /** 分割线颜色 */
  static get divider(): string {
    return ThemeColors.isDark() ? '#38383A' : '#E0E0E0';
  }

  /** 边框颜色 */
  static get border(): string {
    return ThemeColors.isDark() ? '#38383A' : '#E0E0E0';
  }

  // ========== 品牌颜色（不随主题变化） ==========

  /** 主题色 - 蓝色 */
  static get primary(): string {
    return '#007AFF';
  }

  /** 成功色 - 绿色 */
  static get success(): string {
    return '#34C759';
  }

  /** 警告色 - 橙色 */
  static get warning(): string {
    return '#FF9500';
  }

  /** 错误色 - 红色 */
  static get error(): string {
    return '#FF3B30';
  }

  /** 紫色 */
  static get purple(): string {
    return '#5856D6';
  }

  // ========== 品牌颜色的浅色背景 ==========

  /** 主题色浅色背景 */
  static get primaryLight(): string {
    return ThemeColors.isDark() ? '#1A3A5C' : '#E5F2FF';
  }

  /** 成功色浅色背景 */
  static get successLight(): string {
    return ThemeColors.isDark() ? '#1A3A2C' : '#E8F5E9';
  }

  /** 警告色浅色背景 */
  static get warningLight(): string {
    return ThemeColors.isDark() ? '#3A2C1A' : '#FFF3E0';
  }

  /** 错误色浅色背景 */
  static get errorLight(): string {
    return ThemeColors.isDark() ? '#3A1A1A' : '#FFEBEE';
  }

  // ========== 阴影颜色 ==========

  /** 阴影颜色 - 轻 */
  static get shadowLight(): string {
    return ThemeColors.isDark() ? 'rgba(0, 0, 0, 0.3)' : 'rgba(0, 0, 0, 0.1)';
  }

  /** 阴影颜色 - 中 */
  static get shadowMedium(): string {
    return ThemeColors.isDark() ? 'rgba(0, 0, 0, 0.5)' : 'rgba(0, 0, 0, 0.2)';
  }

  /** 阴影颜色 - 重 */
  static get shadowHeavy(): string {
    return ThemeColors.isDark() ? 'rgba(0, 0, 0, 0.7)' : 'rgba(0, 0, 0, 0.3)';
  }
}

