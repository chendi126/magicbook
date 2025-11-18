// 颜色信息模型
export interface ColorInfo {
  hex: string;          // HEX颜色值，如 #FF5733
  rgb: string;          // RGB颜色值，如 255, 87, 51
  percentage?: number;  // 颜色占比（可选）
}

