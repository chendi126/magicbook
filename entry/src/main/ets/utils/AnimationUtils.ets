// 动画工具类
// 提供常用的动画效果和配置

/**
 * 动画配置接口
 */
export interface AnimationConfig {
  duration: number;
  curve: Curve;
}

/**
 * 按钮缩放动画配置接口
 */
export interface ButtonScaleAnimationConfig extends AnimationConfig {
  scaleDown: number;
  scaleNormal: number;
}

/**
 * 列表项动画配置接口
 */
export interface ListItemAnimationConfig extends AnimationConfig {
  delay: number;
}

/**
 * TabBar 动画配置接口
 */
export interface TabBarAnimationConfig extends AnimationConfig {
  iconDuration: number;
  iconCurve: Curve;
}

/**
 * 按钮点击缩放动画配置
 */
export const BUTTON_SCALE_ANIMATION: ButtonScaleAnimationConfig = {
  duration: 150,
  curve: Curve.EaseInOut,
  scaleDown: 0.95,
  scaleNormal: 1.0
};

/**
 * 对话框弹出动画配置
 */
export const DIALOG_ANIMATION: AnimationConfig = {
  duration: 300,
  curve: Curve.FastOutSlowIn
};

/**
 * 列表项渐入动画配置
 */
export const LIST_ITEM_ANIMATION: ListItemAnimationConfig = {
  duration: 200,
  curve: Curve.EaseOut,
  delay: 50 // 每项延迟
};

/**
 * 页面切换动画配置
 */
export const PAGE_TRANSITION_ANIMATION: AnimationConfig = {
  duration: 300,
  curve: Curve.EaseInOut
};

/**
 * TabBar 切换动画配置
 */
export const TABBAR_ANIMATION: TabBarAnimationConfig = {
  duration: 300,
  curve: Curve.FastOutSlowIn,
  iconDuration: 250,
  iconCurve: Curve.FastOutSlowIn // 快出慢入效果
};

/**
 * 颜色条展开动画配置
 */
export const COLOR_BAR_ANIMATION: AnimationConfig = {
  duration: 400,
  curve: Curve.FastOutSlowIn // 快出慢入效果
};

/**
 * Toast 提示动画配置
 */
export const TOAST_ANIMATION: AnimationConfig = {
  duration: 200,
  curve: Curve.EaseOut
};

/**
 * 按钮触摸事件处理器接口
 */
export interface ButtonTouchHandler {
  onTouch: (event: TouchEvent) => void;
}

/**
 * 平移属性接口
 */
export interface TranslateProps {
  y: number;
}

/**
 * 缩放属性接口
 */
export interface ScaleProps {
  x: number;
  y: number;
}

/**
 * 列表项动画属性接口
 */
export interface ListItemAnimationProps {
  opacity: number;
  translate: TranslateProps;
  onAppear: () => void;
}

/**
 * 对话框动画属性接口
 */
export interface DialogAnimationProps {
  scale: ScaleProps;
  opacity: number;
  onAppear: () => void;
}

/**
 * 创建按钮点击动画上下文
 */
export function createButtonPressAnimation(callback?: () => void): ButtonTouchHandler {
  const handler: ButtonTouchHandler = {
    onTouch: (event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        animateTo({
          duration: BUTTON_SCALE_ANIMATION.duration,
          curve: BUTTON_SCALE_ANIMATION.curve
        }, () => {
          // 缩放动画在组件上通过 .scale() 实现
        });
      } else if (event.type === TouchType.Up) {
        animateTo({
          duration: BUTTON_SCALE_ANIMATION.duration,
          curve: BUTTON_SCALE_ANIMATION.curve
        }, () => {
          // 恢复原始大小
        });
        if (callback) {
          callback();
        }
      }
    }
  };
  return handler;
}

/**
 * 创建列表项渐入动画
 */
export function createListItemAnimation(index: number): ListItemAnimationProps {
  const translate: TranslateProps = { y: 20 };
  const props: ListItemAnimationProps = {
    opacity: 0,
    translate: translate,
    onAppear: () => {
      animateTo({
        duration: LIST_ITEM_ANIMATION.duration,
        curve: LIST_ITEM_ANIMATION.curve,
        delay: index * LIST_ITEM_ANIMATION.delay
      }, () => {
        // 动画在组件上实现
      });
    }
  };
  return props;
}

/**
 * 创建对话框弹出动画
 */
export function createDialogAnimation(): DialogAnimationProps {
  const scale: ScaleProps = { x: 0.9, y: 0.9 };
  const props: DialogAnimationProps = {
    scale: scale,
    opacity: 0,
    onAppear: () => {
      animateTo({
        duration: DIALOG_ANIMATION.duration,
        curve: DIALOG_ANIMATION.curve
      }, () => {
        // 动画在组件上实现
      });
    }
  };
  return props;
}

/**
 * 通用的淡入动画
 */
export function fadeIn(duration: number = 300) {
  animateTo({
    duration: duration,
    curve: Curve.EaseOut
  }, () => {
    // 在调用处设置 opacity
  });
}

/**
 * 通用的淡出动画
 */
export function fadeOut(duration: number = 300) {
  animateTo({
    duration: duration,
    curve: Curve.EaseIn
  }, () => {
    // 在调用处设置 opacity
  });
}

/**
 * 通用的缩放动画
 */
export function scaleAnimation(scale: number, duration: number = 300) {
  animateTo({
    duration: duration,
    curve: Curve.EaseInOut
  }, () => {
    // 在调用处设置 scale
  });
}

/**
 * 通用的滑动动画
 */
export function slideAnimation(x: number, y: number, duration: number = 300) {
  animateTo({
    duration: duration,
    curve: Curve.EaseInOut
  }, () => {
    // 在调用处设置 translate
  });
}

