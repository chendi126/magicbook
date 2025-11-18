import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { DatabaseManager } from '../database/DatabaseManager';
import { ThemeManager } from '../utils/ThemeManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化主题管理器
    ThemeManager.getInstance().init(this.context)
      .then(() => {
        hilog.info(DOMAIN, 'testTag', '主题管理器初始化成功');
      })
      .catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', '主题管理器初始化失败: %{public}s', JSON.stringify(err));
      });

    // 初始化数据库
    DatabaseManager.getInstance().init(this.context)
      .then(() => {
        hilog.info(DOMAIN, 'testTag', '数据库初始化成功');
      })
      .catch((err: Error) => {
        hilog.error(DOMAIN, 'testTag', '数据库初始化失败: %{public}s', JSON.stringify(err));
      });
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}