// 主题管理器
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import preferences from '@ohos.data.preferences';

/**
 * 主题模式枚举
 */
export enum ThemeMode {
  AUTO = 0,    // 跟随系统
  LIGHT = 1,   // 浅色模式
  DARK = 2     // 深色模式
}

/**
 * 主题管理器
 * 负责管理应用的深色/浅色主题切换和持久化
 */
@Observed
export class ThemeManager {
  private static instance: ThemeManager;
  private context: common.UIAbilityContext | null = null;
  private preferencesStore: preferences.Preferences | null = null;
  private readonly PREFERENCES_NAME = 'theme_preferences';
  private readonly KEY_THEME_MODE = 'theme_mode';

  /**
   * 当前主题模式
   */
  currentThemeMode: ThemeMode = ThemeMode.AUTO;

  /**
   * 当前系统颜色模式
   */
  currentColorMode: ConfigurationConstant.ColorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;

  /**
   * 获取单例实例
   */
  static getInstance(): ThemeManager {
    if (!ThemeManager.instance) {
      ThemeManager.instance = new ThemeManager();
    }
    return ThemeManager.instance;
  }

  /**
   * 初始化主题管理器
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    
    // 初始化 Preferences
    try {
      this.preferencesStore = await preferences.getPreferences(context, this.PREFERENCES_NAME);
      
      // 读取保存的主题模式
      const savedMode = await this.preferencesStore.get(this.KEY_THEME_MODE, ThemeMode.AUTO);
      this.currentThemeMode = savedMode as ThemeMode;
      
      // 应用主题
      this.applyTheme(this.currentThemeMode);
      
      console.info('[ThemeManager] 初始化成功，当前主题模式: ' + this.currentThemeMode);
    } catch (err) {
      console.error('[ThemeManager] 初始化失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 设置主题模式
   */
  async setThemeMode(mode: ThemeMode): Promise<void> {
    this.currentThemeMode = mode;
    
    // 应用主题
    this.applyTheme(mode);
    
    // 保存到 Preferences
    if (this.preferencesStore) {
      try {
        await this.preferencesStore.put(this.KEY_THEME_MODE, mode);
        await this.preferencesStore.flush();
        console.info('[ThemeManager] 主题模式已保存: ' + mode);
      } catch (err) {
        console.error('[ThemeManager] 保存主题模式失败: ' + JSON.stringify(err));
      }
    }
  }

  /**
   * 应用主题
   */
  private applyTheme(mode: ThemeMode): void {
    if (!this.context) {
      console.error('[ThemeManager] Context 未初始化');
      return;
    }

    let colorMode: ConfigurationConstant.ColorMode;

    switch (mode) {
      case ThemeMode.AUTO:
        colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
        break;
      case ThemeMode.LIGHT:
        colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
        break;
      case ThemeMode.DARK:
        colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
        break;
      default:
        colorMode = ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
    }

    try {
      this.context.getApplicationContext().setColorMode(colorMode);
      this.currentColorMode = colorMode;
      console.info('[ThemeManager] 主题已应用: ' + colorMode);
    } catch (err) {
      console.error('[ThemeManager] 应用主题失败: ' + JSON.stringify(err));
    }
  }

  /**
   * 获取主题模式名称
   */
  getThemeModeName(mode: ThemeMode): string {
    switch (mode) {
      case ThemeMode.AUTO:
        return '跟随系统';
      case ThemeMode.LIGHT:
        return '浅色模式';
      case ThemeMode.DARK:
        return '深色模式';
      default:
        return '未知';
    }
  }

  /**
   * 是否为深色模式
   */
  isDarkMode(): boolean {
    return this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  /**
   * 是否为浅色模式
   */
  isLightMode(): boolean {
    return this.currentColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
  }
}

