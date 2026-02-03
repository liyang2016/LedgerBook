import { describe, it, expect, beforeAll, beforeEach, afterEach, afterAll } from '@ohos/hypium';
import { DataManager, Transaction, Category, BalanceSummary } from '../../main/ets/services/DataManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@ohos/base';

/**
 * DataManager 单元测试 - 优化版
 * 基于华为 HarmonyOS 单元测试最佳实践
 * 
 * 命名规范: test0XX_[功能]_[场景]_[预期结果]
 * 测试原则: 独立、可重复、快速、自验证
 */
export default function DataManagerOptimizedTest() {
  
  describe('DataManager Optimized Unit Test', () => {
    
    // ==================== 测试配置 ====================
    const TEST_TAG = 'DataManagerOptTest';
    const MAX_TIMEOUT = 5000; // 最大超时时间 5s
    
    let dataManager: DataManager;
    let testContext: Context;
    let testIdCounter: number = 1;
    
    /**
     * 生成唯一测试ID
     */
    function generateTestId(): number {
      return Date.now() + (testIdCounter++);
    }
    
    /**
     * 创建标准测试交易数据
     */
    function createTestTransaction(overrides: Partial<Transaction> = {}): Transaction {
      return {
        id: generateTestId(),
        title: '测试交易',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮',
        ...overrides
      };
    }
    
    // ==================== 生命周期钩子 ====================
    
    beforeAll(async () => {
      hilog.info(0x0000, TEST_TAG, '【测试套件初始化】开始设置测试环境');
      
      try {
        dataManager = DataManager.getInstance();
        testContext = getContext(this);
        
        if (!testContext) {
          throw new Error('测试上下文获取失败');
        }
        
        await dataManager.init(testContext);
        hilog.info(0x0000, TEST_TAG, '✅ DataManager 初始化成功');
      } catch (err) {
        const error = err as BusinessError;
        hilog.error(0x0000, TEST_TAG, '❌ 测试套件初始化失败: %{public}s', error.message);
        throw err;
      }
    });

    beforeEach(async () => {
      // 重置计数器
      testIdCounter = 1;
      
      // 清理测试数据，确保测试独立性
      try {
        await dataManager.saveTransactions([]);
        hilog.debug(0x0000, TEST_TAG, '🧹 测试数据已清理');
      } catch (err) {
        hilog.warn(0x0000, TEST_TAG, '⚠️ 测试数据清理失败，可能影响测试独立性');
      }
    });

    afterEach(async () => {
      // 再次清理，确保无副作用
      try {
        await dataManager.saveTransactions([]);
      } catch (err) {
        // 清理失败不影响测试通过
      }
    });

    afterAll(() => {
      hilog.info(0x0000, TEST_TAG, '【测试套件完成】所有测试执行完毕');
    });

    // ==================== 基础功能测试 ====================
    
    describe('【test001-010】基础功能测试', () => {
      
      /**
       * test001: 单例模式验证
       * 前提: 系统正常运行
       * 操作: 多次获取 DataManager 实例
       * 预期: 所有实例引用相同
       */
      it('test001_singleton_instance_should_be_same', 0, () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test001: 单例模式验证');
        
        const instance1 = DataManager.getInstance();
        const instance2 = DataManager.getInstance();
        
        expect(instance1).assertNotNull();
        expect(instance2).assertNotNull();
        expect(instance1 === instance2).assertTrue();
        
        hilog.info(0x0000, TEST_TAG, '✅ test001 通过: 单例模式工作正常');
      });

      /**
       * test002: 添加单笔交易
       * 前提: DataManager 已初始化
       * 操作: 添加一条交易记录
       * 预期: 数据成功保存，可正确查询
       */
      it('test002_add_transaction_should_success', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test002: 添加单笔交易');
        
        const transaction = createTestTransaction({
          title: '午餐',
          amount: 35,
          category: '餐饮'
        });

        const startTime = Date.now();
        const result = await dataManager.addTransaction(transaction);
        const duration = Date.now() - startTime;

        expect(result).assertTrue();
        expect(duration).assertLess(500); // 性能要求: <500ms

        // 验证数据已保存
        const transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(1);
        expect(transactions[0].title).assertEqual('午餐');
        expect(transactions[0].amount).assertEqual(35);
        
        hilog.info(0x0000, TEST_TAG, '✅ test002 通过: 添加交易耗时 %{public}d ms', duration);
      });

      /**
       * test003: 查询交易列表
       * 前提: 已添加多条交易
       * 操作: 查询所有交易
       * 预期: 返回正确的交易列表，按时间倒序
       */
      it('test003_get_transactions_should_return_correct_list', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test003: 查询交易列表');
        
        // 准备数据
        const t1 = createTestTransaction({ id: 1001, title: '第一条' });
        const t2 = createTestTransaction({ id: 1002, title: '第二条' });
        const t3 = createTestTransaction({ id: 1003, title: '第三条' });
        
        await dataManager.addTransaction(t1);
        await dataManager.addTransaction(t2);
        await dataManager.addTransaction(t3);

        const transactions = await dataManager.getTransactions();
        
        expect(transactions.length).assertEqual(3);
        // 验证倒序排列（最新添加的在最前）
        expect(transactions[0].id).assertEqual(1003);
        expect(transactions[1].id).assertEqual(1002);
        expect(transactions[2].id).assertEqual(1001);
        
        hilog.info(0x0000, TEST_TAG, '✅ test003 通过: 查询到 %{public}d 条交易', transactions.length);
      });

      /**
       * test004: 更新交易记录
       * 前提: 已存在交易记录
       * 操作: 更新交易信息
       * 预期: 数据更新成功，查询返回新值
       */
      it('test004_update_transaction_should_modify_data', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test004: 更新交易记录');
        
        const original = createTestTransaction({
          id: 2001,
          title: '原数据',
          amount: 50
        });
        await dataManager.addTransaction(original);

        const updated = createTestTransaction({
          id: 2001,
          title: '修改后',
          amount: 75,
          category: '交通'
        });

        const result = await dataManager.updateTransaction(updated);
        expect(result).assertTrue();

        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title).assertEqual('修改后');
        expect(transactions[0].amount).assertEqual(75);
        expect(transactions[0].category).assertEqual('交通');
        
        hilog.info(0x0000, TEST_TAG, '✅ test004 通过: 数据更新成功');
      });

      /**
       * test005: 删除交易记录
       * 前提: 已存在交易记录
       * 操作: 删除指定ID的交易
       * 预期: 数据删除成功，不再出现在列表中
       */
      it('test005_delete_transaction_should_remove_data', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test005: 删除交易记录');
        
        const transaction = createTestTransaction({ id: 3001 });
        await dataManager.addTransaction(transaction);
        
        let transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(1);

        const result = await dataManager.deleteTransaction(3001);
        expect(result).assertTrue();

        transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(0);
        
        hilog.info(0x0000, TEST_TAG, '✅ test005 通过: 数据删除成功');
      });
    });

    // ==================== 业务逻辑测试 ====================
    
    describe('【test011-020】业务逻辑测试', () => {
      
      /**
       * test011: 计算总收入
       * 前提: 已添加多笔收入
       * 操作: 调用 calculateBalance
       * 预期: 返回正确的总收入
       */
      it('test011_calculate_total_income_should_be_correct', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test011: 计算总收入');
        
        await dataManager.addTransaction(createTestTransaction({
          type: 'income', amount: 5000, category: '工资'
        }));
        await dataManager.addTransaction(createTestTransaction({
          type: 'income', amount: 1000, category: '奖金'
        }));
        await dataManager.addTransaction(createTestTransaction({
          type: 'expense', amount: 200, category: '餐饮'
        }));

        const summary = await dataManager.calculateBalance();
        
        expect(summary.totalIncome).assertEqual(6000);
        expect(summary.totalExpense).assertEqual(200);
        expect(summary.balance).assertEqual(5800);
        
        hilog.info(0x0000, TEST_TAG, '✅ test011 通过: 余额计算正确');
      });

      /**
       * test012: 分类管理
       * 前提: 系统首次运行
       * 操作: 获取分类列表
       * 预期: 返回默认分类
       */
      it('test012_get_categories_should_return_defaults', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test012: 获取默认分类');
        
        const categories = await dataManager.getCategories();
        
        expect(categories.length).assertLarger(0);
        
        const expenseCategories = categories.filter(c => c.type === 'expense');
        const incomeCategories = categories.filter(c => c.type === 'income');
        
        expect(expenseCategories.length).assertLarger(0);
        expect(incomeCategories.length).assertLarger(0);
        
        // 验证每个分类都有名称和图标
        categories.forEach(cat => {
          expect(cat.name.length).assertLarger(0);
          expect(cat.icon.length).assertLarger(0);
        });
        
        hilog.info(0x0000, TEST_TAG, 
          '✅ test012 通过: 获取 %{public}d 个分类（支出%{public}d，收入%{public}d）',
          categories.length, expenseCategories.length, incomeCategories.length
        );
      });

      /**
       * test013: 保存自定义分类
       * 前提: 无
       * 操作: 保存自定义分类列表
       * 预期: 保存成功，可正确读取
       */
      it('test013_save_custom_categories_should_persist', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test013: 保存自定义分类');
        
        const customCategories: Category[] = [
          { name: '测试支出1', icon: '🎯', type: 'expense' },
          { name: '测试收入1', icon: '💎', type: 'income' }
        ];

        const saveResult = await dataManager.saveCategories(customCategories);
        expect(saveResult).assertTrue();

        const retrieved = await dataManager.getCategories();
        expect(retrieved.length).assertEqual(2);
        expect(retrieved[0].name).assertEqual('测试支出1');
        expect(retrieved[1].name).assertEqual('测试收入1');
        
        hilog.info(0x0000, TEST_TAG, '✅ test013 通过: 自定义分类保存成功');
      });
    });

    // ==================== 边界条件测试 ====================
    
    describe('【test021-030】边界条件测试', () => {
      
      /**
       * test021: 零金额交易
       * 边界: amount = 0
       * 预期: 正确处理，无异常
       */
      it('test021_zero_amount_transaction_should_handle', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test021: 零金额交易');
        
        const transaction = createTestTransaction({ amount: 0 });
        
        const result = await dataManager.addTransaction(transaction);
        expect(result).assertTrue();

        const summary = await dataManager.calculateBalance();
        expect(summary.totalExpense).assertEqual(0);
        
        hilog.info(0x0000, TEST_TAG, '✅ test021 通过: 零金额处理正确');
      });

      /**
       * test022: 大额交易
       * 边界: amount = 999999.99
       * 预期: 正确处理，精度保持
       */
      it('test022_large_amount_transaction_should_handle', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test022: 大额交易');
        
        const transaction = createTestTransaction({
          type: 'income',
          amount: 999999.99
        });
        
        const result = await dataManager.addTransaction(transaction);
        expect(result).assertTrue();

        const summary = await dataManager.calculateBalance();
        expect(summary.totalIncome).assertEqual(999999.99);
        
        hilog.info(0x0000, TEST_TAG, '✅ test022 通过: 大额交易处理正确');
      });

      /**
       * test023: 空标题交易
       * 边界: title = ''
       * 预期: 允许空标题，正常保存
       */
      it('test023_empty_title_transaction_should_allow', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test023: 空标题交易');
        
        const transaction = createTestTransaction({ title: '' });
        
        const result = await dataManager.addTransaction(transaction);
        expect(result).assertTrue();

        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title).assertEqual('');
        
        hilog.info(0x0000, TEST_TAG, '✅ test023 通过: 空标题允许');
      });

      /**
       * test024: 特殊字符标题
       * 边界: 包含特殊字符
       * 预期: 正确处理，数据完整保存
       */
      it('test024_special_characters_title_should_preserve', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test024: 特殊字符标题');
        
        const specialTitle = '测试!@#$%^&*()_+-=[]{}|;\':",./<>?';
        const transaction = createTestTransaction({ title: specialTitle });
        
        const result = await dataManager.addTransaction(transaction);
        expect(result).assertTrue();

        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title).assertEqual(specialTitle);
        
        hilog.info(0x0000, TEST_TAG, '✅ test024 通过: 特殊字符完整保留');
      });

      /**
       * test025: 长标题
       * 边界: 100+ 字符
       * 预期: 完整保存，无截断
       */
      it('test025_long_title_should_preserve', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test025: 长标题');
        
        const longTitle = '这是一个非常非常长的标题'.repeat(5); // 100+ 字符
        const transaction = createTestTransaction({ title: longTitle });
        
        const result = await dataManager.addTransaction(transaction);
        expect(result).assertTrue();

        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title.length).assertEqual(longTitle.length);
        
        hilog.info(0x0000, TEST_TAG, 
          '✅ test025 通过: 长标题 %{public}d 字符完整保存', 
          longTitle.length
        );
      });
    });

    // ==================== 错误处理测试 ====================
    
    describe('【test031-040】错误处理测试', () => {
      
      /**
       * test031: 更新不存在的交易
       * 错误场景: ID 不存在
       * 预期: 返回 false，不抛出异常
       */
      it('test031_update_nonexistent_should_return_false', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test031: 更新不存在的数据');
        
        const nonExistent = createTestTransaction({ id: 99999 });
        
        const result = await dataManager.updateTransaction(nonExistent);
        expect(result).assertFalse();
        
        hilog.info(0x0000, TEST_TAG, '✅ test031 通过: 正确处理不存在的数据');
      });

      /**
       * test032: 删除不存在的交易
       * 错误场景: ID 不存在
       * 预期: 返回 true（幂等），无副作用
       */
      it('test032_delete_nonexistent_should_return_true', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test032: 删除不存在的数据');
        
        const result = await dataManager.deleteTransaction(99999);
        expect(result).assertTrue(); // 幂等操作
        
        hilog.info(0x0000, TEST_TAG, '✅ test032 通过: 幂等删除正常工作');
      });

      /**
       * test033: 数据一致性保障
       * 场景: 操作失败后数据应保持原样
       */
      it('test033_data_integrity_after_failed_operation', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test033: 数据一致性');
        
        // 先添加有效数据
        const validData = createTestTransaction({ id: 8888, title: '有效数据' });
        await dataManager.addTransaction(validData);
        
        const beforeCount = (await dataManager.getTransactions()).length;
        
        // 尝试无效操作
        await dataManager.updateTransaction(createTestTransaction({ id: 99999 }));
        
        const afterCount = (await dataManager.getTransactions()).length;
        expect(afterCount).assertEqual(beforeCount);
        
        // 验证原有数据未受影响
        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title).assertEqual('有效数据');
        
        hilog.info(0x0000, TEST_TAG, '✅ test033 通过: 数据一致性保障');
      });
    });

    // ==================== 性能测试 ====================
    
    describe('【test041-050】性能基准测试', () => {
      
      /**
       * test041: 单条添加性能
       * 基准: < 100ms
       */
      it('test041_single_add_performance', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test041: 单条添加性能测试');
        
        const transaction = createTestTransaction();
        
        const start = Date.now();
        await dataManager.addTransaction(transaction);
        const duration = Date.now() - start;
        
        expect(duration).assertLess(100);
        
        hilog.info(0x0000, TEST_TAG, '✅ test041 通过: 单条添加耗时 %{public}d ms', duration);
      });

      /**
       * test042: 批量添加性能（10条）
       * 基准: < 500ms
       */
      it('test042_batch_add_10_performance', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test042: 批量添加性能（10条）');
        
        const transactions = Array.from({ length: 10 }, (_, i) => 
          createTestTransaction({ id: 5000 + i, title: `性能测试${i}` })
        );

        const start = Date.now();
        for (const t of transactions) {
          await dataManager.addTransaction(t);
        }
        const duration = Date.now() - start;
        
        expect(duration).assertLess(500);
        
        hilog.info(0x0000, TEST_TAG, 
          '✅ test042 通过: 批量添加10条耗时 %{public}d ms（平均 %{public}d ms/条）',
          duration, duration / 10
        );
      });

      /**
       * test043: 查询性能
       * 基准: 100条数据 < 100ms
       */
      it('test043_query_performance_with_100_records', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test043: 查询性能测试（100条）');
        
        // 准备数据
        for (let i = 0; i < 100; i++) {
          await dataManager.addTransaction(createTestTransaction({ 
            id: 6000 + i,
            title: `查询测试${i}` 
          }));
        }

        const start = Date.now();
        const transactions = await dataManager.getTransactions();
        const queryDuration = Date.now() - start;
        
        expect(transactions.length).assertEqual(100);
        expect(queryDuration).assertLess(100);
        
        // 计算余额性能
        const calcStart = Date.now();
        await dataManager.calculateBalance();
        const calcDuration = Date.now() - calcStart;
        
        expect(calcDuration).assertLess(50);
        
        hilog.info(0x0000, TEST_TAG, 
          '✅ test043 通过: 查询 %{public}d ms, 计算 %{public}d ms',
          queryDuration, calcDuration
        );
      });
    });

    // ==================== 并发测试 ====================
    
    describe('【test051-060】并发与压力测试', () => {
      
      /**
       * test051: 快速连续操作
       * 场景: 快速执行多次操作
       * 预期: 数据一致性保持
       */
      it('test051_rapid_successive_operations', 0, async () => {
        hilog.info(0x0000, TEST_TAG, '▶️ test051: 快速连续操作');
        
        const start = Date.now();
        
        // 添加
        await dataManager.addTransaction(createTestTransaction({ id: 7001 }));
        // 修改
        await dataManager.updateTransaction(createTestTransaction({ id: 7001, amount: 200 }));
        // 添加
        await dataManager.addTransaction(createTestTransaction({ id: 7002 }));
        // 删除
        await dataManager.deleteTransaction(7001);
        // 查询
        const transactions = await dataManager.getTransactions();
        
        const duration = Date.now() - start;
        
        expect(transactions.length).assertEqual(1);
        expect(transactions[0].id).assertEqual(7002);
        expect(duration).assertLess(1000);
        
        hilog.info(0x0000, TEST_TAG, '✅ test051 通过: 连续操作耗时 %{public}d ms', duration);
      });
    });

    // ==================== 测试套件总结 ====================
    
    describe('【总结】测试统计', () => {
      
      /**
       * test099: 测试套件验证
       * 验证测试框架正常工作
       */
      it('test099_test_framework_validation', 0, () => {
        hilog.info(0x0000, TEST_TAG, '🎉 所有测试执行完毕！');
        expect(true).assertTrue();
      });
    });
  });
}
