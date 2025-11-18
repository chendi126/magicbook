// 灵感广场 - 精选配色方案数据

export interface InspirationScheme {
  id: string;
  name: string;
  category: string; // 分类：自然、科技、复古、现代、温暖、冷色、中性
  colors: string[];
  description: string;
}

// 分类接口
export interface CategoryItem {
  name: string;
  value: string;
  icon: string;
}

// 配色分类
export const INSPIRATION_CATEGORIES: CategoryItem[] = [
  { name: '全部', value: 'all', icon: '🌟' },
  { name: '自然', value: 'nature', icon: '🌿' },
  { name: '科技', value: 'tech', icon: '💻' },
  { name: '复古', value: 'vintage', icon: '🏛️' },
  { name: '现代', value: 'modern', icon: '🏙️' },
  { name: '温暖', value: 'warm', icon: '🔥' },
  { name: '冷色', value: 'cool', icon: '❄️' },
  { name: '中性', value: 'neutral', icon: '⚪' }
];

// 精选配色方案数据
export const INSPIRATION_SCHEMES: InspirationScheme[] = [
  // 自然系列
  {
    id: 'nature_001',
    name: '森林晨曦',
    category: 'nature',
    colors: ['#2D5016', '#4A7C2E', '#7FB069', '#C9E4A4', '#F4F9E9'],
    description: '清新的森林绿色，带来自然的宁静感'
  },
  {
    id: 'nature_002',
    name: '海洋之心',
    category: 'nature',
    colors: ['#003049', '#0077B6', '#00B4D8', '#90E0EF', '#CAF0F8'],
    description: '深邃的海洋蓝，展现大海的广阔'
  },
  {
    id: 'nature_003',
    name: '日落余晖',
    category: 'nature',
    colors: ['#6A040F', '#9D0208', '#D00000', '#E85D04', '#FFBA08'],
    description: '温暖的日落色调，充满活力'
  },
  {
    id: 'nature_004',
    name: '樱花盛开',
    category: 'nature',
    colors: ['#FFB3C6', '#FF8FAB', '#FB6F92', '#C9184A', '#A4133C'],
    description: '浪漫的粉色系，如樱花般柔美'
  },
  {
    id: 'nature_005',
    name: '秋日枫叶',
    category: 'nature',
    colors: ['#641220', '#85182A', '#A11D33', '#BD1F36', '#DA1E37'],
    description: '深红枫叶色，展现秋天的韵味'
  },

  // 科技系列
  {
    id: 'tech_001',
    name: '赛博朋克',
    category: 'tech',
    colors: ['#0A0E27', '#1B2845', '#2E4057', '#FF006E', '#00F5FF'],
    description: '未来感十足的霓虹配色'
  },
  {
    id: 'tech_002',
    name: '数字蓝',
    category: 'tech',
    colors: ['#03045E', '#023E8A', '#0077B6', '#0096C7', '#48CAE4'],
    description: '科技感的蓝色渐变'
  },
  {
    id: 'tech_003',
    name: '矩阵绿',
    category: 'tech',
    colors: ['#001219', '#005F73', '#0A9396', '#94D2BD', '#E9D8A6'],
    description: '黑客帝国风格的绿色系'
  },
  {
    id: 'tech_004',
    name: '霓虹夜',
    category: 'tech',
    colors: ['#10002B', '#240046', '#5A189A', '#9D4EDD', '#E0AAFF'],
    description: '紫色霓虹灯效果'
  },
  {
    id: 'tech_005',
    name: '电路板',
    category: 'tech',
    colors: ['#1A1A2E', '#16213E', '#0F3460', '#533483', '#E94560'],
    description: '电子电路的配色灵感'
  },

  // 复古系列
  {
    id: 'vintage_001',
    name: '复古海报',
    category: 'vintage',
    colors: ['#582F0E', '#7F4F24', '#936639', '#A68A64', '#B6AD90'],
    description: '70年代海报风格'
  },
  {
    id: 'vintage_002',
    name: '老照片',
    category: 'vintage',
    colors: ['#3D2C2E', '#5A4A42', '#8B7E74', '#B8AE9C', '#E8DCC4'],
    description: '泛黄老照片的色调'
  },
  {
    id: 'vintage_003',
    name: '古典玫瑰',
    category: 'vintage',
    colors: ['#641220', '#85182A', '#A11D33', '#BD1F36', '#DA1E37'],
    description: '优雅的古典玫瑰色'
  },
  {
    id: 'vintage_004',
    name: '怀旧橙',
    category: 'vintage',
    colors: ['#7C2D12', '#9A3412', '#C2410C', '#EA580C', '#FB923C'],
    description: '温暖的怀旧橙色调'
  },
  {
    id: 'vintage_005',
    name: '复古绿松石',
    category: 'vintage',
    colors: ['#134E4A', '#115E59', '#0F766E', '#14B8A6', '#5EEAD4'],
    description: '复古的绿松石配色'
  },

  // 现代系列
  {
    id: 'modern_001',
    name: '极简黑白',
    category: 'modern',
    colors: ['#000000', '#333333', '#666666', '#CCCCCC', '#FFFFFF'],
    description: '经典的黑白灰配色'
  },
  {
    id: 'modern_002',
    name: '莫兰迪',
    category: 'modern',
    colors: ['#A8DADC', '#457B9D', '#1D3557', '#F1FAEE', '#E63946'],
    description: '高级的莫兰迪色系'
  },
  {
    id: 'modern_003',
    name: '北欧风',
    category: 'modern',
    colors: ['#264653', '#2A9D8F', '#E9C46A', '#F4A261', '#E76F51'],
    description: '清新的北欧配色'
  },
  {
    id: 'modern_004',
    name: '简约蓝',
    category: 'modern',
    colors: ['#14213D', '#FCA311', '#E5E5E5', '#FFFFFF', '#000000'],
    description: '现代简约风格'
  },
  {
    id: 'modern_005',
    name: '工业风',
    category: 'modern',
    colors: ['#2B2D42', '#8D99AE', '#EDF2F4', '#EF233C', '#D90429'],
    description: '工业设计风格配色'
  },

  // 温暖系列
  {
    id: 'warm_001',
    name: '暖阳',
    category: 'warm',
    colors: ['#FFBE0B', '#FB5607', '#FF006E', '#8338EC', '#3A86FF'],
    description: '温暖明亮的阳光色'
  },
  {
    id: 'warm_002',
    name: '焦糖拿铁',
    category: 'warm',
    colors: ['#6F1D1B', '#BB9457', '#432818', '#99582A', '#FFE6A7'],
    description: '温暖的咖啡色调'
  },
  {
    id: 'warm_003',
    name: '蜜桃',
    category: 'warm',
    colors: ['#FFADAD', '#FFD6A5', '#FDFFB6', '#CAFFBF', '#9BF6FF'],
    description: '甜美的蜜桃色系'
  },
  {
    id: 'warm_004',
    name: '秋日暖阳',
    category: 'warm',
    colors: ['#D4A373', '#FAEDCD', '#E9EDC9', '#CCD5AE', '#FEFAE0'],
    description: '温暖的秋日色调'
  },
  {
    id: 'warm_005',
    name: '火焰',
    category: 'warm',
    colors: ['#370617', '#6A040F', '#9D0208', '#D00000', '#DC2F02'],
    description: '热情的火焰红'
  },

  // 冷色系列
  {
    id: 'cool_001',
    name: '冰川',
    category: 'cool',
    colors: ['#03045E', '#0077B6', '#00B4D8', '#90E0EF', '#CAF0F8'],
    description: '清冷的冰川蓝'
  },
  {
    id: 'cool_002',
    name: '薄荷',
    category: 'cool',
    colors: ['#081C15', '#1B4332', '#2D6A4F', '#52B788', '#B7E4C7'],
    description: '清新的薄荷绿'
  },
  {
    id: 'cool_003',
    name: '深海',
    category: 'cool',
    colors: ['#001219', '#005F73', '#0A9396', '#94D2BD', '#E9D8A6'],
    description: '神秘的深海色'
  },
  {
    id: 'cool_004',
    name: '紫罗兰',
    category: 'cool',
    colors: ['#240046', '#3C096C', '#5A189A', '#7209B7', '#9D4EDD'],
    description: '优雅的紫罗兰'
  },
  {
    id: 'cool_005',
    name: '月光',
    category: 'cool',
    colors: ['#1E1E24', '#3E3E4A', '#5E5E6A', '#9E9EAA', '#DEDEDF'],
    description: '冷静的月光灰蓝'
  },

  // 中性系列
  {
    id: 'neutral_001',
    name: '大地',
    category: 'neutral',
    colors: ['#3D2C2E', '#5A4A42', '#8B7E74', '#B8AE9C', '#E8DCC4'],
    description: '沉稳的大地色'
  },
  {
    id: 'neutral_002',
    name: '水泥',
    category: 'neutral',
    colors: ['#2D3142', '#4F5D75', '#BFC0C0', '#FFFFFF', '#EF8354'],
    description: '现代水泥灰'
  },
  {
    id: 'neutral_003',
    name: '米色',
    category: 'neutral',
    colors: ['#F8F9FA', '#E9ECEF', '#DEE2E6', '#CED4DA', '#ADB5BD'],
    description: '温和的米色系'
  },
  {
    id: 'neutral_004',
    name: '咖啡',
    category: 'neutral',
    colors: ['#3E2723', '#5D4037', '#795548', '#A1887F', '#D7CCC8'],
    description: '经典咖啡色'
  },
  {
    id: 'neutral_005',
    name: '石墨',
    category: 'neutral',
    colors: ['#212529', '#343A40', '#495057', '#6C757D', '#ADB5BD'],
    description: '专业的石墨灰'
  }
];

