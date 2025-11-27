/**
 * 主题颜色常量
 * 定义应用中使用的所有颜色
 */
export class ThemeColors {
  // 主色调
  static readonly primary: string = '#007AFF';
  static readonly primaryLight: string = 'rgba(0, 122, 255, 0.15)';
  static readonly primaryDark: string = '#0051D5';

  // 语义颜色
  static readonly success: string = '#34C759';
  static readonly successLight: string = 'rgba(52, 199, 89, 0.15)';
  static readonly warning: string = '#FF9500';
  static readonly warningLight: string = 'rgba(255, 149, 0, 0.15)';
  static readonly error: string = '#FF3B30';
  static readonly errorLight: string = 'rgba(255, 59, 48, 0.15)';
  static readonly info: string = '#5AC8FA';
  static readonly infoLight: string = 'rgba(90, 200, 250, 0.15)';

  // 文本颜色
  static readonly textPrimary: string = '#000000';
  static readonly textSecondary: string = '#666666';
  static readonly textTertiary: string = '#999999';
  static readonly textPlaceholder: string = '#C7C7CC';
  static readonly textDisabled: string = '#D1D1D6';

  // 背景颜色
  static readonly background: string = '#FFFFFF';
  static readonly backgroundSecondary: string = '#F5F5F5';
  static readonly backgroundTertiary: string = '#EEEEEE';
  static readonly backgroundElevated: string = '#FFFFFF';
  static readonly backgroundCard: string = '#FFFFFF';
  static readonly backgroundInput: string = '#F2F2F7';
  static readonly backgroundOverlay: string = 'rgba(0, 0, 0, 0.4)';

  // 分隔线颜色
  static readonly separator: string = '#E5E5EA';
  static readonly separatorLight: string = '#F2F2F7';

  // 阴影颜色
  static readonly shadowLight: string = 'rgba(0, 0, 0, 0.05)';
  static readonly shadowMedium: string = 'rgba(0, 0, 0, 0.1)';
  static readonly shadowHeavy: string = 'rgba(0, 0, 0, 0.2)';

  // 特殊颜色
  static readonly purple: string = '#AF52DE';
  static readonly purpleLight: string = 'rgba(175, 82, 222, 0.15)';
  static readonly teal: string = '#5AC8FA';
  static readonly tealLight: string = 'rgba(90, 200, 250, 0.15)';
  static readonly pink: string = '#FF2D55';
  static readonly pinkLight: string = 'rgba(255, 45, 85, 0.15)';
  static readonly orange: string = '#FF9500';
  static readonly orangeLight: string = 'rgba(255, 149, 0, 0.15)';
  static readonly green: string = '#34C759';
  static readonly greenLight: string = 'rgba(52, 199, 89, 0.15)';
  static readonly blue: string = '#007AFF';
  static readonly blueLight: string = 'rgba(0, 122, 255, 0.15)';
  static readonly indigo: string = '#5856D6';
  static readonly indigoLight: string = 'rgba(88, 86, 214, 0.15)';
  static readonly yellow: string = '#FFCC00';
  static readonly yellowLight: string = 'rgba(255, 204, 0, 0.15)';
  static readonly red: string = '#FF3B30';
  static readonly redLight: string = 'rgba(255, 59, 48, 0.15)';

  // 边框颜色
  static readonly border: string = '#E5E5EA';
  static readonly borderLight: string = '#F2F2F7';
  static readonly borderDark: string = '#D1D1D6';

  // 透明度
  static readonly transparent: string = 'transparent';
  static readonly white: string = '#FFFFFF';
  static readonly black: string = '#000000';

  // 渐变色
  static readonly gradientPrimary: string[] = ['#007AFF', '#00C6FF'];
  static readonly gradientSecondary: string[] = ['#AF52DE', '#FF2D55'];
  static readonly gradientWarning: string[] = ['#FF9500', '#FF3B30'];
  static readonly gradientSuccess: string[] = ['#34C759', '#30D158'];
}
