// 首选项管理器 - 用于存储应用设置
import preferences from '@ohos.data.preferences';
import { Context } from '@ohos.abilityAccessCtrl';

export class PreferencesManager {
  private static instance: PreferencesManager;
  private preferences: preferences.Preferences | null = null;
  private readonly STORE_NAME = 'ColorAppPreferences';

  private constructor() {}

  static getInstance(): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager();
    }
    return PreferencesManager.instance;
  }

  // 初始化
  async init(context: Context): Promise<void> {
    try {
      this.preferences = await preferences.getPreferences(context, this.STORE_NAME);
      console.info('PreferencesManager 初始化成功');
    } catch (err) {
      console.error('PreferencesManager 初始化失败: ' + JSON.stringify(err));
    }
  }

  // 检查是否首次使用
  async isFirstLaunch(): Promise<boolean> {
    if (!this.preferences) {
      return true;
    }
    try {
      const isFirst = await this.preferences.get('isFirstLaunch', true);
      return isFirst as boolean;
    } catch (err) {
      console.error('获取首次启动状态失败: ' + JSON.stringify(err));
      return true;
    }
  }

  // 设置已完成首次引导
  async setFirstLaunchCompleted(): Promise<void> {
    if (!this.preferences) {
      return;
    }
    try {
      await this.preferences.put('isFirstLaunch', false);
      await this.preferences.flush();
      console.info('首次启动标记已设置');
    } catch (err) {
      console.error('设置首次启动标记失败: ' + JSON.stringify(err));
    }
  }

  // 获取引导步骤
  async getGuideStep(): Promise<number> {
    if (!this.preferences) {
      return 0;
    }
    try {
      const step = await this.preferences.get('guideStep', 0);
      return step as number;
    } catch (err) {
      console.error('获取引导步骤失败: ' + JSON.stringify(err));
      return 0;
    }
  }

  // 设置引导步骤
  async setGuideStep(step: number): Promise<void> {
    if (!this.preferences) {
      return;
    }
    try {
      await this.preferences.put('guideStep', step);
      await this.preferences.flush();
    } catch (err) {
      console.error('设置引导步骤失败: ' + JSON.stringify(err));
    }
  }

  // 获取设置项
  async getSetting(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    if (!this.preferences) {
      return defaultValue;
    }
    try {
      return await this.preferences.get(key, defaultValue);
    } catch (err) {
      console.error(`获取设置 ${key} 失败: ` + JSON.stringify(err));
      return defaultValue;
    }
  }

  // 保存设置项
  async setSetting(key: string, value: preferences.ValueType): Promise<void> {
    if (!this.preferences) {
      return;
    }
    try {
      await this.preferences.put(key, value);
      await this.preferences.flush();
    } catch (err) {
      console.error(`保存设置 ${key} 失败: ` + JSON.stringify(err));
    }
  }

  // 获取用户头像
  async getUserAvatar(): Promise<string> {
    return await this.getSetting('userAvatar', '😀') as string;
  }

  // 设置用户头像
  async setUserAvatar(avatar: string): Promise<void> {
    await this.setSetting('userAvatar', avatar);
  }

  // 获取用户名称
  async getUserName(): Promise<string> {
    return await this.getSetting('userName', '色彩收集者') as string;
  }

  // 设置用户名称
  async setUserName(name: string): Promise<void> {
    await this.setSetting('userName', name);
  }

  // 清除所有设置
  async clear(): Promise<void> {
    if (!this.preferences) {
      return;
    }
    try {
      await this.preferences.clear();
      await this.preferences.flush();
      console.info('所有设置已清除');
    } catch (err) {
      console.error('清除设置失败: ' + JSON.stringify(err));
    }
  }
}

