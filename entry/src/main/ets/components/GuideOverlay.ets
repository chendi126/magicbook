// 首次使用引导遮罩层
import { PreferencesManager } from '../utils/PreferencesManager';

// 目标位置接口
export interface TargetPosition {
  x: number;
  y: number;
  width: number;
  height: number;
}

// 引导步骤接口
export interface GuideStep {
  title: string;
  description: string;
  targetPosition?: TargetPosition;
}

@Component
export struct GuideOverlay {
  @State currentStep: number = 0;
  @State showGuide: boolean = false;
  onComplete?: () => void;

  // 引导步骤
  private guideSteps: GuideStep[] = [
    {
      title: '欢迎使用色彩灵感收集器！',
      description: '让我们快速了解如何使用这个应用'
    },
    {
      title: '📸 提取配色',
      description: '点击"选择图片"按钮，从照片中提取美丽的配色方案'
    },
    {
      title: '📚 配色库',
      description: '所有保存的配色方案都在这里，支持搜索、筛选和分组'
    },
    {
      title: '🎨 灵感广场',
      description: '浏览 30+ 精选配色方案，一键保存到配色库'
    },
    {
      title: '开始使用吧！',
      description: '现在你已经了解了所有功能，开始创作吧！'
    }
  ];

  aboutToAppear() {
    this.checkFirstLaunch();
  }

  // 检查是否首次启动
  async checkFirstLaunch() {
    const isFirst = await PreferencesManager.getInstance().isFirstLaunch();
    if (isFirst) {
      this.showGuide = true;
    }
  }

  // 下一步
  nextStep() {
    if (this.currentStep < this.guideSteps.length - 1) {
      this.currentStep++;
    } else {
      this.completeGuide();
    }
  }

  // 跳过引导
  skipGuide() {
    this.completeGuide();
  }

  // 完成引导
  async completeGuide() {
    this.showGuide = false;
    await PreferencesManager.getInstance().setFirstLaunchCompleted();
    if (this.onComplete) {
      this.onComplete();
    }
  }

  build() {
    if (this.showGuide) {
      Stack() {
        // 半透明遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0, 0, 0, 0.7)')

        // 引导内容
        Column() {
          // 步骤指示器
          Row() {
            ForEach(this.guideSteps, (step: GuideStep, index: number) => {
              Column()
                .width(this.currentStep === index ? 24 : 8)
                .height(8)
                .backgroundColor(this.currentStep === index ? '#007DFF' : '#CCCCCC')
                .borderRadius(4)
                .margin({ right: 8 })
                .animation({
                  duration: 300,
                  curve: Curve.EaseInOut
                })
            }, (step: GuideStep, index: number) => index.toString())
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 32 })

          // 标题
          Text(this.guideSteps[this.currentStep].title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16 })

          // 描述
          Text(this.guideSteps[this.currentStep].description)
            .fontSize(16)
            .fontColor('#FFFFFF')
            .textAlign(TextAlign.Center)
            .lineHeight(24)
            .margin({ bottom: 48 })

          // 按钮
          Row() {
            if (this.currentStep > 0) {
              Button('跳过')
                .fontSize(16)
                .fontColor('#FFFFFF')
                .backgroundColor('rgba(255, 255, 255, 0.2)')
                .width(100)
                .onClick(() => {
                  this.skipGuide();
                })
            }

            Button(this.currentStep === this.guideSteps.length - 1 ? '开始使用' : '下一步')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .backgroundColor('#007DFF')
              .width(120)
              .margin({ left: this.currentStep > 0 ? 16 : 0 })
              .onClick(() => {
                this.nextStep();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('80%')
        .padding(32)
        .backgroundColor('rgba(0, 0, 0, 0.9)')
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
    }
  }
}

