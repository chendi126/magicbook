// 数据库管理类
import relationalStore from '@ohos.data.relationalStore';
import { ColorScheme } from '../models/ColorScheme';

const DATABASE_NAME = 'ColorPicker.db';
const TABLE_COLOR_SCHEME = 'color_scheme';

// 创建表的SQL
const CREATE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS ${TABLE_COLOR_SCHEME} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    tags TEXT,
    image_path TEXT,
    colors TEXT NOT NULL,
    create_time INTEGER NOT NULL,
    is_favorite INTEGER DEFAULT 0,
    group_name TEXT
  )
`;

// 创建索引的SQL（优化查询性能）
const CREATE_INDEX_CREATE_TIME = `
  CREATE INDEX IF NOT EXISTS idx_create_time ON ${TABLE_COLOR_SCHEME}(create_time DESC)
`;

const CREATE_INDEX_IS_FAVORITE = `
  CREATE INDEX IF NOT EXISTS idx_is_favorite ON ${TABLE_COLOR_SCHEME}(is_favorite)
`;

const CREATE_INDEX_TAGS = `
  CREATE INDEX IF NOT EXISTS idx_tags ON ${TABLE_COLOR_SCHEME}(tags)
`;

export class DatabaseManager {
  private static instance: DatabaseManager;
  private store: relationalStore.RdbStore | null = null;

  private constructor() {
  }

  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager();
    }
    return DatabaseManager.instance;
  }

  /**
   * 初始化数据库
   */
  async init(context: Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DATABASE_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };

      this.store = await relationalStore.getRdbStore(context, config);
      console.info('数据库初始化成功');

      // 创建表
      await this.store.executeSql(CREATE_TABLE_SQL);
      console.info('数据表创建成功');

      // 创建索引（优化查询性能）
      await this.store.executeSql(CREATE_INDEX_CREATE_TIME);
      await this.store.executeSql(CREATE_INDEX_IS_FAVORITE);
      await this.store.executeSql(CREATE_INDEX_TAGS);
      console.info('数据库索引创建成功');
    } catch (err) {
      console.error('数据库初始化失败: ' + JSON.stringify(err));
      // 初始化失败时，store 保持为 null，后续操作会检查并返回默认值
    }
  }

  /**
   * 保存配色方案
   */
  async saveColorScheme(scheme: ColorScheme): Promise<number> {
    if (!this.store) {
      console.error('数据库未初始化');
      return -1;
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        'name': scheme.name,
        'tags': scheme.tags || '',
        'image_path': scheme.imagePath || '',
        'colors': JSON.stringify(scheme.colors),
        'create_time': scheme.createTime,
        'is_favorite': scheme.isFavorite ? 1 : 0,
        'group_name': scheme.group || ''
      };

      const rowId = await this.store.insert(TABLE_COLOR_SCHEME, valueBucket);
      console.info('保存配色方案成功，ID: ' + rowId);
      return rowId;
    } catch (err) {
      console.error('保存配色方案失败: ' + JSON.stringify(err));
      return -1;
    }
  }

  /**
   * 获取所有配色方案
   */
  async getAllColorSchemes(): Promise<ColorScheme[]> {
    if (!this.store) {
      console.error('数据库未初始化');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLOR_SCHEME);
      predicates.orderByDesc('create_time');

      const resultSet = await this.store.query(predicates);
      const schemes: ColorScheme[] = this.parseResultSet(resultSet);

      resultSet.close();
      console.info('查询到 ' + schemes.length + ' 个配色方案');
      return schemes;
    } catch (err) {
      console.error('查询配色方案失败: ' + JSON.stringify(err));
      return [];
    }
  }

  /**
   * 分页获取配色方案（性能优化）
   * @param page 页码（从0开始）
   * @param pageSize 每页数量
   */
  async getColorSchemesByPage(page: number = 0, pageSize: number = 20): Promise<ColorScheme[]> {
    if (!this.store) {
      console.error('数据库未初始化');
      return [];
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLOR_SCHEME);
      predicates.orderByDesc('create_time');
      predicates.limitAs(pageSize);
      predicates.offsetAs(page * pageSize);

      const resultSet = await this.store.query(predicates);
      const schemes: ColorScheme[] = this.parseResultSet(resultSet);

      resultSet.close();
      console.info(`查询第 ${page} 页，共 ${schemes.length} 个配色方案`);
      return schemes;
    } catch (err) {
      console.error('分页查询配色方案失败: ' + JSON.stringify(err));
      return [];
    }
  }

  /**
   * 获取配色方案总数
   */
  async getColorSchemesCount(): Promise<number> {
    if (!this.store) {
      console.error('数据库未初始化');
      return 0;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLOR_SCHEME);
      const resultSet = await this.store.query(predicates, ['COUNT(*) as count']);

      let count = 0;
      if (resultSet.goToFirstRow()) {
        count = resultSet.getLong(0);
      }

      resultSet.close();
      return count;
    } catch (err) {
      console.error('查询配色方案总数失败: ' + JSON.stringify(err));
      return 0;
    }
  }

  /**
   * 获取收藏配色方案数量
   */
  async getFavoriteCount(): Promise<number> {
    if (!this.store) {
      console.error('数据库未初始化');
      return 0;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLOR_SCHEME);
      predicates.equalTo('is_favorite', 1);
      const resultSet = await this.store.query(predicates, ['COUNT(*) as count']);

      let count = 0;
      if (resultSet.goToFirstRow()) {
        count = resultSet.getLong(0);
      }

      resultSet.close();
      return count;
    } catch (err) {
      console.error('查询收藏数量失败: ' + JSON.stringify(err));
      return 0;
    }
  }

  /**
   * 解析查询结果集（提取公共逻辑）
   */
  private parseResultSet(resultSet: relationalStore.ResultSet): ColorScheme[] {
    const schemes: ColorScheme[] = [];

    while (resultSet.goToNextRow()) {
      const scheme: ColorScheme = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        tags: resultSet.getString(resultSet.getColumnIndex('tags')),
        imagePath: resultSet.getString(resultSet.getColumnIndex('image_path')),
        colors: JSON.parse(resultSet.getString(resultSet.getColumnIndex('colors'))),
        createTime: resultSet.getLong(resultSet.getColumnIndex('create_time')),
        isFavorite: resultSet.getLong(resultSet.getColumnIndex('is_favorite')) === 1,
        group: resultSet.getString(resultSet.getColumnIndex('group_name'))
      };
      schemes.push(scheme);
    }

    return schemes;
  }

  /**
   * 删除配色方案
   */
  async deleteColorScheme(id: number): Promise<boolean> {
    if (!this.store) {
      console.error('数据库未初始化');
      return false;
    }

    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_COLOR_SCHEME);
      predicates.equalTo('id', id);

      const rows = await this.store.delete(predicates);
      console.info('删除了 ' + rows + ' 条记录');
      return rows > 0;
    } catch (err) {
      console.error('删除配色方案失败: ' + JSON.stringify(err));
      return false;
    }
  }

  /**
   * 更新配色方案
   */
  async updateColorScheme(scheme: ColorScheme): Promise<boolean> {
    if (!this.store || !scheme.id) {
      console.error('数据库未初始化或方案ID无效');
      return false;
    }

    try {
      const valueBucket: relationalStore.ValuesBucket = {
        'name': scheme.name,
        'tags': scheme.tags || '',
        'is_favorite': scheme.isFavorite ? 1 : 0,
        'group_name': scheme.group || ''
      };

      const predicates = new relationalStore.RdbPredicates(TABLE_COLOR_SCHEME);
      predicates.equalTo('id', scheme.id);

      const rows = await this.store.update(valueBucket, predicates);
      console.info('更新了 ' + rows + ' 条记录');
      return rows > 0;
    } catch (err) {
      console.error('更新配色方案失败: ' + JSON.stringify(err));
      return false;
    }
  }
}

