/**
 * 心情日记对话框
 */
import { ColorScheme } from '../models/ColorScheme';
import { MoodDiary, MoodBoardUtils } from '../models/MoodBoard';
import { ThemeColors } from '../utils/ThemeColors';
import promptAction from '@ohos.promptAction';

@CustomDialog
export struct MoodDiaryDialog {
  controller: CustomDialogController = new CustomDialogController({
    builder: MoodDiaryDialog()
  });
  
  // 编辑模式
  @State isEditMode: boolean = false;
  existingDiary: MoodDiary | null = null;
  
  // 配色方案
  selectedScheme: ColorScheme | null = null;
  
  // 表单数据
  @State selectedMood: string = '开心';
  @State selectedWeather: string = '☀️';
  @State diaryNote: string = '';
  @State selectedDate: string = '';
  
  // 回调
  onSave: (diary: MoodDiary) => void = () => {};
  
  // 心情选项
  private moodOptions: string[] = ['开心', '平静', '忧郁', '兴奋', '放松', '焦虑', '感动', '愤怒', '期待', '满足'];
  
  // 天气选项
  private weatherOptions: string[] = ['☀️', '⛅', '☁️', '🌧️', '⛈️', '🌨️', '🌈', '🌙', '⭐'];
  private weatherNames: string[] = ['晴天', '多云', '阴天', '雨天', '雷雨', '雪天', '彩虹', '夜晚', '星空'];

  aboutToAppear() {
    // 初始化日期为今天
    const now = new Date();
    this.selectedDate = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    
    // 如果是编辑模式，加载现有数据
    if (this.existingDiary) {
      this.isEditMode = true;
      this.selectedMood = this.existingDiary.mood;
      this.selectedWeather = this.existingDiary.weather;
      this.diaryNote = this.existingDiary.note;
      this.selectedDate = this.existingDiary.date;
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text(this.isEditMode ? '✏️ 编辑日记' : '✍️ 记录心情')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeColors.textPrimary)
          .layoutWeight(1)

        Button({ type: ButtonType.Circle }) {
          Text('×')
            .fontSize(28)
            .fontColor(ThemeColors.textSecondary)
        }
        .width(36)
        .height(36)
        .backgroundColor('transparent')
        .onClick(() => {
          this.controller.close();
        })
      }
      .width('100%')
      .padding({ bottom: 20 })

      Scroll() {
        Column({ space: 24 }) {
          // 配色预览
          if (this.selectedScheme) {
            Column({ space: 12 }) {
              Text('配色方案')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeColors.textSecondary)
                .alignSelf(ItemAlign.Start)

              Column({ space: 8 }) {
                Row() {
                  ForEach(this.selectedScheme.colors, (color: string) => {
                    Row()
                      .width(`${100 / this.selectedScheme!.colors.length}%`)
                      .height(60)
                      .backgroundColor(color)
                  })
                }
                .width('100%')
                .borderRadius(12)
                .clip(true)

                Text(this.selectedScheme.name)
                  .fontSize(15)
                  .fontColor(ThemeColors.textPrimary)
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
          }

          // 日期选择
          Column({ space: 12 }) {
            Text('日期')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.textSecondary)
              .alignSelf(ItemAlign.Start)

            Text(this.selectedDate)
              .fontSize(16)
              .fontColor(ThemeColors.textPrimary)
              .width('100%')
              .padding(16)
              .backgroundColor(ThemeColors.backgroundSecondary)
              .borderRadius(12)
          }
          .width('100%')

          // 心情选择
          Column({ space: 12 }) {
            Text('今天的心情')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.textSecondary)
              .alignSelf(ItemAlign.Start)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.moodOptions, (mood: string) => {
                this.buildMoodOption(mood);
              })
            }
            .width('100%')
          }
          .width('100%')

          // 天气选择
          Column({ space: 12 }) {
            Text('今天的天气')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.textSecondary)
              .alignSelf(ItemAlign.Start)

            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.weatherOptions, (weather: string, index: number) => {
                this.buildWeatherOption(weather, this.weatherNames[index]);
              })
            }
            .width('100%')
          }
          .width('100%')

          // 笔记输入
          Column({ space: 12 }) {
            Text('心情笔记')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeColors.textSecondary)
              .alignSelf(ItemAlign.Start)

            TextArea({ placeholder: '记录今天的心情和想法...', text: this.diaryNote })
              .width('100%')
              .height(120)
              .fontSize(15)
              .fontColor(ThemeColors.textPrimary)
              .backgroundColor(ThemeColors.backgroundSecondary)
              .borderRadius(12)
              .padding(12)
              .onChange((value: string) => {
                this.diaryNote = value;
              })
          }
          .width('100%')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)

      // 底部按钮
      Row({ space: 12 }) {
        Button('取消')
          .fontSize(16)
          .fontColor(ThemeColors.textSecondary)
          .backgroundColor(ThemeColors.backgroundSecondary)
          .layoutWeight(1)
          .height(48)
          .borderRadius(24)
          .onClick(() => {
            this.controller.close();
          })

        Button(this.isEditMode ? '保存' : '记录')
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(ThemeColors.primary)
          .layoutWeight(1)
          .height(48)
          .borderRadius(24)
          .onClick(() => {
            this.saveDiary();
          })
      }
      .width('100%')
      .margin({ top: 20 })
    }
    .width('100%')
    .height(700)
    .padding(24)
    .backgroundColor(ThemeColors.background)
    .borderRadius(24)
  }

  @Builder
  buildMoodOption(mood: string) {
    Column({ space: 6 }) {
      Text(MoodBoardUtils.getMoodIcon(mood))
        .fontSize(32)

      Text(mood)
        .fontSize(13)
        .fontColor(this.selectedMood === mood ? ThemeColors.primary : ThemeColors.textSecondary)
        .fontWeight(this.selectedMood === mood ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('20%')
    .padding(12)
    .backgroundColor(this.selectedMood === mood ? ThemeColors.primaryLight : ThemeColors.backgroundSecondary)
    .borderRadius(16)
    .border({
      width: this.selectedMood === mood ? 2 : 0,
      color: ThemeColors.primary
    })
    .margin({ right: 8, bottom: 8 })
    .onClick(() => {
      animateTo({ duration: 200 }, () => {
        this.selectedMood = mood;
      })
    })
  }

  @Builder
  buildWeatherOption(weather: string, name: string) {
    Column({ space: 6 }) {
      Text(weather)
        .fontSize(28)

      Text(name)
        .fontSize(12)
        .fontColor(this.selectedWeather === weather ? ThemeColors.primary : ThemeColors.textSecondary)
        .fontWeight(this.selectedWeather === weather ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('30%')
    .padding(10)
    .backgroundColor(this.selectedWeather === weather ? ThemeColors.primaryLight : ThemeColors.backgroundSecondary)
    .borderRadius(12)
    .border({
      width: this.selectedWeather === weather ? 2 : 0,
      color: ThemeColors.primary
    })
    .margin({ right: 8, bottom: 8 })
    .onClick(() => {
      animateTo({ duration: 200 }, () => {
        this.selectedWeather = weather;
      })
    })
  }

  saveDiary() {
    if (!this.selectedScheme) {
      promptAction.showToast({
        message: '请先选择配色方案',
        duration: 1500
      });
      return;
    }

    let diary: MoodDiary;

    if (this.isEditMode && this.existingDiary) {
      // 更新现有日记
      diary = {
        id: this.existingDiary.id,
        date: this.selectedDate,
        mood: this.selectedMood,
        colorScheme: this.selectedScheme,
        note: this.diaryNote,
        weather: this.selectedWeather,
        createTime: this.existingDiary.createTime
      };
    } else {
      // 创建新日记
      diary = MoodBoardUtils.createMoodDiary(
        this.selectedMood,
        this.selectedScheme,
        this.diaryNote,
        this.selectedWeather
      );
      diary.date = this.selectedDate;
    }

    this.onSave(diary);
    this.controller.close();

    promptAction.showToast({
      message: this.isEditMode ? '日记已更新' : '日记已保存',
      duration: 1500
    });
  }
}

