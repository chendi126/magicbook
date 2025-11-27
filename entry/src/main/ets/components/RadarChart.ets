/**
 * 雷达图组件
 * 用于展示色彩性格的六个维度
 */

import { ColorDimensions } from '../models/ColorPersonality';
import { ThemeColors } from '../utils/ThemeColors';

// 位置接口
interface Position {
  x: number;
  y: number;
}

@Component
export struct RadarChart {
  @Prop dimensions: ColorDimensions;
  @State private chartSize: number = 280;
  @State private centerX: number = 140;
  @State private centerY: number = 140;
  @State private maxRadius: number = 120;
  
  // 六个维度的标签和角度
  private labels: string[] = ['暖色', '冷色', '明亮', '柔和', '对比', '和谐'];
  private angles: number[] = [0, 60, 120, 180, 240, 300]; // 度数
  
  // 缓存计算好的标签位置和值
  @State private labelPositions: Position[] = [];
  @State private labelValues: number[] = [];
  
  aboutToAppear() {
    this.updateLabelData();
  }
  
  // 更新标签数据
  private updateLabelData() {
    // 计算所有标签位置
    this.labelPositions = [];
    for (let i = 0; i < 6; i++) {
      const angle = (this.angles[i] - 90) * Math.PI / 180;
      const labelRadius = this.maxRadius + 30;
      const x = this.centerX + labelRadius * Math.cos(angle);
      const y = this.centerY + labelRadius * Math.sin(angle);
      this.labelPositions.push({ x, y });
    }
    
    // 计算所有维度值
    this.labelValues = [
      this.dimensions.warm,
      this.dimensions.cool,
      this.dimensions.bright,
      this.dimensions.soft,
      this.dimensions.contrast,
      this.dimensions.harmony
    ];
  }
  
  build() {
    Stack() {
      // 背景网格层
      Canvas(this.drawBackground.bind(this))
        .width(this.chartSize)
        .height(this.chartSize)
      
      // 数据层
      Canvas(this.drawData.bind(this))
        .width(this.chartSize)
        .height(this.chartSize)
      
      // 标签层
      this.buildLabels()
    }
    .width(this.chartSize)
    .height(this.chartSize)
  }
  
  // 绘制背景网格
  private drawBackground(context: CanvasRenderingContext2D) {
    context.clearRect(0, 0, this.chartSize, this.chartSize);
    
    // 绘制5层同心正六边形
    for (let i = 1; i <= 5; i++) {
      const radius = (this.maxRadius / 5) * i;
      context.beginPath();
      
      for (let j = 0; j < 6; j++) {
        const angle = (this.angles[j] - 90) * Math.PI / 180;
        const x = this.centerX + radius * Math.cos(angle);
        const y = this.centerY + radius * Math.sin(angle);
        
        if (j === 0) {
          context.moveTo(x, y);
        } else {
          context.lineTo(x, y);
        }
      }
      
      context.closePath();
      context.strokeStyle = ThemeColors.separator;
      context.lineWidth = 1;
      context.stroke();
    }
    
    // 绘制从中心到各顶点的连线
    for (let i = 0; i < 6; i++) {
      const angle = (this.angles[i] - 90) * Math.PI / 180;
      const x = this.centerX + this.maxRadius * Math.cos(angle);
      const y = this.centerY + this.maxRadius * Math.sin(angle);
      
      context.beginPath();
      context.moveTo(this.centerX, this.centerY);
      context.lineTo(x, y);
      context.strokeStyle = ThemeColors.separatorLight;
      context.lineWidth = 1;
      context.stroke();
    }
  }
  
  // 绘制数据区域
  private drawData(context: CanvasRenderingContext2D) {
    context.clearRect(0, 0, this.chartSize, this.chartSize);
    
    // 获取六个维度的值
    const values = [
      this.dimensions.warm,
      this.dimensions.cool,
      this.dimensions.bright,
      this.dimensions.soft,
      this.dimensions.contrast,
      this.dimensions.harmony
    ];
    
    // 绘制填充区域
    context.beginPath();
    for (let i = 0; i < 6; i++) {
      const value = values[i];
      const radius = (this.maxRadius * value) / 100;
      const angle = (this.angles[i] - 90) * Math.PI / 180;
      const x = this.centerX + radius * Math.cos(angle);
      const y = this.centerY + radius * Math.sin(angle);
      
      if (i === 0) {
        context.moveTo(x, y);
      } else {
        context.lineTo(x, y);
      }
    }
    context.closePath();
    
    // 填充渐变
    const gradient = context.createLinearGradient(
      this.centerX - this.maxRadius,
      this.centerY - this.maxRadius,
      this.centerX + this.maxRadius,
      this.centerY + this.maxRadius
    );
    gradient.addColorStop(0, 'rgba(0, 122, 255, 0.3)');
    gradient.addColorStop(1, 'rgba(0, 198, 255, 0.3)');
    context.fillStyle = gradient;
    context.fill();
    
    // 绘制边框
    context.strokeStyle = ThemeColors.primary;
    context.lineWidth = 2;
    context.stroke();
    
    // 绘制数据点
    for (let i = 0; i < 6; i++) {
      const value = values[i];
      const radius = (this.maxRadius * value) / 100;
      const angle = (this.angles[i] - 90) * Math.PI / 180;
      const x = this.centerX + radius * Math.cos(angle);
      const y = this.centerY + radius * Math.sin(angle);
      
      context.beginPath();
      context.arc(x, y, 4, 0, 2 * Math.PI);
      context.fillStyle = ThemeColors.primary;
      context.fill();
    }
  }
  
  // 构建标签
  @Builder
  buildLabels() {
    Stack() {
      ForEach(this.labels, (label: string, index: number) => {
        this.buildLabel(label, index);
      })
    }
    .width(this.chartSize)
    .height(this.chartSize)
  }
  
  // 计算标签位置
  private getLabelPosition(index: number): Position {
    const angle = (this.angles[index] - 90) * Math.PI / 180;
    const labelRadius = this.maxRadius + 30;
    const x = this.centerX + labelRadius * Math.cos(angle);
    const y = this.centerY + labelRadius * Math.sin(angle);
    return { x, y };
  }
  
  // 获取维度值数组
  private getValues(): number[] {
    return [
      this.dimensions.warm,
      this.dimensions.cool,
      this.dimensions.bright,
      this.dimensions.soft,
      this.dimensions.contrast,
      this.dimensions.harmony
    ];
  }
  
  @Builder
  buildLabel(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeColors.textPrimary)
      
      Text(`${this.labelValues[index]}%`)
        .fontSize(11)
        .fontColor(ThemeColors.primary)
        .margin({ top: 2 })
    }
    .position({ 
      x: this.labelPositions[index]?.x ? this.labelPositions[index].x - 25 : 0, 
      y: this.labelPositions[index]?.y ? this.labelPositions[index].y - 20 : 0 
    })
  }
}
