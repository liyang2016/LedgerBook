import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { DataManager, Transaction, Category, BalanceSummary } from '../../main/ets/services/DataManager';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@ohos/base';

/**
 * DataManager 测试套件
 * 基于 HarmonyOS 测试规范实现
 * 
 * 测试级别:
 * - L0: 快速单元测试（<100ms）
 * - L1: 完整单元测试（<500ms）
 * - L2: 集成测试（<2000ms）
 * - L3: 系统测试（<5000ms）
 */
export default function DataManagerHarmonyOSTest() {
  describe('DataManager HarmonyOS Test Suite', () => {
    
    let dataManager: DataManager;
    let testContext: Context;
    const TEST_TAG = 'DataManagerTest';

    // ==================== 测试生命周期 ====================

    beforeAll(async () => {
      hilog.info(0x0000, TEST_TAG, '开始初始化测试环境');
      
      try {
        dataManager = DataManager.getInstance();
        testContext = getContext(this);
        
        await dataManager.init(testContext);
        hilog.info(0x0000, TEST_TAG, 'DataManager 初始化成功');
      } catch (err) {
        const error = err as BusinessError;
        hilog.error(0x0000, TEST_TAG, '初始化失败: %{public}s', error.message);
        throw err;
      }
    });

    beforeEach(async () => {
      hilog.debug(0x0000, TEST_TAG, '清理测试数据');
      // 每个测试前清理数据
      await dataManager.saveTransactions([]);
    });

    afterEach(async () => {
      // 清理测试副作用
      hilog.debug(0x0000, TEST_TAG, '测试执行完成，清理数据');
      await dataManager.saveTransactions([]);
    });

    afterAll(() => {
      hilog.info(0x0000, TEST_TAG, '测试套件执行完成');
    });

    // ==================== L0: 快速单元测试 ====================

    describe('L0 - 快速单元测试', () => {
      
      it('L0-01: 单例模式验证', 0, () => {
        const instance1 = DataManager.getInstance();
        const instance2 = DataManager.getInstance();
        
        expect(instance1).assertNotNull();
        expect(instance2).assertNotNull();
        expect(instance1).assertEqual(instance2);
      });

      it('L0-02: 默认分类数量验证', 0, async () => {
        const categories = await dataManager.getCategories();
        
        expect(categories.length).assertLarger(0);
        
        const expenseCount = categories.filter(c => c.type === 'expense').length;
        const incomeCount = categories.filter(c => c.type === 'income').length;
        
        expect(expenseCount).assertLarger(0);
        expect(incomeCount).assertLarger(0);
        
        hilog.info(0x0000, TEST_TAG, '分类数量: 支出=%{public}d, 收入=%{public}d', expenseCount, incomeCount);
      });

      it('L0-03: 空数据余额计算', 0, async () => {
        const summary = await dataManager.calculateBalance();
        
        expect(summary.balance).assertEqual(0);
        expect(summary.totalIncome).assertEqual(0);
        expect(summary.totalExpense).assertEqual(0);
      });

      it('L0-04: 交易数据格式验证', 0, () => {
        const transaction: Transaction = {
          id: Date.now(),
          title: '测试',
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        expect(typeof transaction.id).assertEqual('number');
        expect(typeof transaction.title).assertEqual('string');
        expect(typeof transaction.amount).assertEqual('number');
        expect(transaction.type).assertContain('expense');
        expect(transaction.date.match(/^\d{4}-\d{2}-\d{2}$/)).assertNotNull();
      });
    });

    // ==================== L1: 完整单元测试 ====================

    describe('L1 - 完整单元测试', () => {
      
      it('L1-01: 添加单笔交易', 0, async () => {
        const transaction: Transaction = {
          id: Date.now(),
          title: '午餐',
          amount: 35,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };

        const startTime = Date.now();
        const success = await dataManager.addTransaction(transaction);
        const duration = Date.now() - startTime;

        expect(success).assertTrue();
        expect(duration).assertLess(500); // L1级别 < 500ms

        const transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(1);
        expect(transactions[0].title).assertEqual('午餐');
      });

      it('L1-02: 批量添加交易（10条）', 0, async () => {
        const transactions: Transaction[] = Array.from({ length: 10 }, (_, i) => ({
          id: Date.now() + i,
          title: `交易${i}`,
          amount: (i + 1) * 10,
          type: i % 2 === 0 ? 'expense' : 'income',
          date: '2026-02-03',
          category: i % 2 === 0 ? '餐饮' : '工资'
        }));

        const startTime = Date.now();
        
        for (const t of transactions) {
          await dataManager.addTransaction(t);
        }
        
        const duration = Date.now() - startTime;
        const saved = await dataManager.getTransactions();
        
        expect(saved.length).assertEqual(10);
        expect(duration).assertLess(1000);
        
        hilog.info(0x0000, TEST_TAG, '批量添加10条交易耗时: %{public}d ms', duration);
      });

      it('L1-03: 更新交易记录', 0, async () => {
        const original: Transaction = {
          id: 1,
          title: '原数据',
          amount: 50,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        await dataManager.addTransaction(original);
        
        const updated: Transaction = {
          id: 1,
          title: '修改后',
          amount: 75,
          type: 'expense',
          date: '2026-02-03',
          category: '交通'
        };
        
        const success = await dataManager.updateTransaction(updated);
        expect(success).assertTrue();
        
        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title).assertEqual('修改后');
        expect(transactions[0].amount).assertEqual(75);
        expect(transactions[0].category).assertEqual('交通');
      });

      it('L1-04: 删除交易记录', 0, async () => {
        const transaction: Transaction = {
          id: 1,
          title: '待删除',
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        await dataManager.addTransaction(transaction);
        let transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(1);
        
        const success = await dataManager.deleteTransaction(1);
        expect(success).assertTrue();
        
        transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(0);
      });

      it('L1-05: 余额计算准确性', 0, async () => {
        // 添加收入
        await dataManager.addTransaction({
          id: 1, title: '工资', amount: 5000, type: 'income',
          date: '2026-02-03', category: '工资'
        });
        
        // 添加支出
        await dataManager.addTransaction({
          id: 2, title: '房租', amount: 2000, type: 'expense',
          date: '2026-02-03', category: '住房'
        });
        
        await dataManager.addTransaction({
          id: 3, title: '餐饮', amount: 500, type: 'expense',
          date: '2026-02-03', category: '餐饮'
        });

        const summary = await dataManager.calculateBalance();
        
        expect(summary.totalIncome).assertEqual(5000);
        expect(summary.totalExpense).assertEqual(2500);
        expect(summary.balance).assertEqual(2500);
      });

      it('L1-06: 分类数据持久化', 0, async () => {
        const customCategories: Category[] = [
          { name: '测试分类1', icon: '🎯', type: 'expense' },
          { name: '测试分类2', icon: '💎', type: 'income' }
        ];
        
        const saveSuccess = await dataManager.saveCategories(customCategories);
        expect(saveSuccess).assertTrue();
        
        const retrieved = await dataManager.getCategories();
        expect(retrieved.length).assertEqual(2);
        expect(retrieved[0].name).assertEqual('测试分类1');
      });
    });

    // ==================== L2: 集成测试 ====================

    describe('L2 - 集成测试', () => {
      
      it('L2-01: 完整记账流程', 0, async () => {
        const startTime = Date.now();
        
        // 添加收入
        await dataManager.addTransaction({
          id: 1, title: '工资', amount: 5000, type: 'income',
          date: '2026-02-03', category: '工资'
        });
        
        // 添加多笔支出
        const expenses = [
          { id: 2, title: '早餐', amount: 15, category: '餐饮' },
          { id: 3, title: '午餐', amount: 35, category: '餐饮' },
          { id: 4, title: '地铁', amount: 6, category: '交通' },
          { id: 5, title: '购物', amount: 200, category: '购物' }
        ];
        
        for (const e of expenses) {
          await dataManager.addTransaction({
            ...e,
            type: 'expense',
            date: '2026-02-03'
          });
        }
        
        // 验证数据
        const transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(5);
        
        // 验证统计
        const summary = await dataManager.calculateBalance();
        expect(summary.totalIncome).assertEqual(5000);
        expect(summary.totalExpense).assertEqual(256); // 15 + 35 + 6 + 200
        expect(summary.balance).assertEqual(4744);
        
        const duration = Date.now() - startTime;
        expect(duration).assertLess(2000); // L2级别 < 2000ms
        
        hilog.info(0x0000, TEST_TAG, '完整流程耗时: %{public}d ms', duration);
      });

      it('L2-02: 批量操作性能测试', 0, async () => {
        const count = 50;
        const transactions: Transaction[] = Array.from({ length: count }, (_, i) => ({
          id: i,
          title: `性能测试${i}`,
          amount: Math.floor(Math.random() * 1000),
          type: Math.random() > 0.5 ? 'expense' : 'income',
          date: '2026-02-03',
          category: '餐饮'
        }));

        const startTime = Date.now();
        
        // 批量添加
        for (const t of transactions) {
          await dataManager.addTransaction(t);
        }
        
        const addDuration = Date.now() - startTime;
        
        // 验证添加成功
        const saved = await dataManager.getTransactions();
        expect(saved.length).assertEqual(count);
        
        // 计算余额
        const calcStart = Date.now();
        const summary = await dataManager.calculateBalance();
        const calcDuration = Date.now() - calcStart;
        
        expect(calcDuration).assertLess(500);
        expect(summary.totalIncome + summary.totalExpense).assertLarger(0);
        
        hilog.info(0x0000, TEST_TAG, 
          '批量添加%{public}d条耗时: %{public}d ms, 计算余额耗时: %{public}d ms',
          count, addDuration, calcDuration
        );
      });

      it('L2-03: 数据一致性验证', 0, async () => {
        // 模拟用户连续操作
        // 1. 添加
        await dataManager.addTransaction({
          id: 1, title: 'T1', amount: 100, type: 'expense',
          date: '2026-02-03', category: '餐饮'
        });
        
        // 2. 修改
        await dataManager.updateTransaction({
          id: 1, title: 'T1-修改', amount: 150, type: 'expense',
          date: '2026-02-03', category: '餐饮'
        });
        
        // 3. 添加更多
        await dataManager.addTransaction({
          id: 2, title: 'T2', amount: 200, type: 'income',
          date: '2026-02-03', category: '工资'
        });
        
        // 4. 删除
        await dataManager.deleteTransaction(1);
        
        // 验证最终状态
        const transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(1);
        expect(transactions[0].id).assertEqual(2);
        
        const summary = await dataManager.calculateBalance();
        expect(summary.totalIncome).assertEqual(200);
        expect(summary.totalExpense).assertEqual(0);
      });
    });

    // ==================== L3: 系统测试 ====================

    describe('L3 - 系统测试', () => {
      
      it('L3-01: 大数据量压力测试', 0, async () => {
        const count = 100;
        const startTime = Date.now();
        
        // 添加100条记录
        for (let i = 0; i < count; i++) {
          await dataManager.addTransaction({
            id: i,
            title: `大数据测试${i}`,
            amount: Math.floor(Math.random() * 500) + 10,
            type: i % 3 === 0 ? 'income' : 'expense',
            date: '2026-02-03',
            category: i % 3 === 0 ? '工资' : '餐饮'
          });
        }
        
        const addDuration = Date.now() - startTime;
        
        // 验证数据完整性
        const transactions = await dataManager.getTransactions();
        expect(transactions.length).assertEqual(count);
        
        // 查询性能
        const queryStart = Date.now();
        const summary = await dataManager.calculateBalance();
        const queryDuration = Date.now() - queryStart;
        
        expect(queryDuration).assertLess(1000);
        
        hilog.info(0x0000, TEST_TAG,
          '大数据量测试: 添加%{public}d条耗时%{public}d ms, 查询耗时%{public}d ms',
          count, addDuration, queryDuration
        );
        
        expect(addDuration).assertLess(5000); // L3级别 < 5000ms
      });

      it('L3-02: 异常恢复测试', 0, async () => {
        // 先添加有效数据
        await dataManager.addTransaction({
          id: 1, title: '有效数据', amount: 100, type: 'expense',
          date: '2026-02-03', category: '餐饮'
        });
        
        const beforeCount = (await dataManager.getTransactions()).length;
        
        // 尝试操作不存在的数据（不应影响现有数据）
        await dataManager.updateTransaction({
          id: 999, title: '不存在', amount: 100, type: 'expense',
          date: '2026-02-03', category: '餐饮'
        });
        
        const afterCount = (await dataManager.getTransactions()).length;
        expect(afterCount).assertEqual(beforeCount);
        
        // 验证数据完整性
        const summary = await dataManager.calculateBalance();
        expect(summary.totalExpense).assertEqual(100);
      });
    });

    // ==================== 边界测试 ====================

    describe('边界测试', () => {
      
      it('边界-01: 零金额交易', 0, async () => {
        const transaction: Transaction = {
          id: 1,
          title: '零金额',
          amount: 0,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        const success = await dataManager.addTransaction(transaction);
        expect(success).assertTrue();
        
        const summary = await dataManager.calculateBalance();
        expect(summary.totalExpense).assertEqual(0);
      });

      it('边界-02: 最大金额交易', 0, async () => {
        const transaction: Transaction = {
          id: 1,
          title: '大额交易',
          amount: 999999.99,
          type: 'income',
          date: '2026-02-03',
          category: '工资'
        };
        
        const success = await dataManager.addTransaction(transaction);
        expect(success).assertTrue();
        
        const summary = await dataManager.calculateBalance();
        expect(summary.totalIncome).assertEqual(999999.99);
      });

      it('边界-03: 特殊字符标题', 0, async () => {
        const transaction: Transaction = {
          id: 1,
          title: '特殊!@#$%^&*()字符',
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        const success = await dataManager.addTransaction(transaction);
        expect(success).assertTrue();
        
        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title).assertEqual('特殊!@#$%^&*()字符');
      });

      it('边界-04: 空字符串标题', 0, async () => {
        const transaction: Transaction = {
          id: 1,
          title: '',
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        const success = await dataManager.addTransaction(transaction);
        expect(success).assertTrue();
        
        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title).assertEqual('');
      });

      it('边界-05: 长标题（100字符）', 0, async () => {
        const longTitle = '这是一个非常非常长的标题，用于测试系统对长文本的处理能力'.repeat(2);
        const transaction: Transaction = {
          id: 1,
          title: longTitle,
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        const success = await dataManager.addTransaction(transaction);
        expect(success).assertTrue();
        
        const transactions = await dataManager.getTransactions();
        expect(transactions[0].title.length).assertEqual(longTitle.length);
      });
    });

    // ==================== 错误处理测试 ====================

    describe('错误处理测试', () => {
      
      it('错误-01: 更新不存在的交易', 0, async () => {
        const nonExistent: Transaction = {
          id: 999,
          title: '不存在',
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        const success = await dataManager.updateTransaction(nonExistent);
        expect(success).assertFalse();
      });

      it('错误-02: 删除不存在的交易', 0, async () => {
        const success = await dataManager.deleteTransaction(999);
        // 删除不存在的数据应返回 true（无副作用）
        expect(success).assertTrue();
      });

      it('错误-03: 负数金额', 0, async () => {
        // 注意：当前实现允许负数，但业务逻辑应该拒绝
        const transaction: Transaction = {
          id: 1,
          title: '负数金额',
          amount: -100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        };
        
        const success = await dataManager.addTransaction(transaction);
        // 记录当前行为（将来应该改为验证拒绝）
        hilog.warn(0x0000, TEST_TAG, '负数金额被接受，建议添加验证');
        expect(success).assertTrue();
      });
    });
  });
}
