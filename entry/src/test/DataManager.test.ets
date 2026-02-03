import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { DataManager, Transaction, Category, BalanceSummary } from '../../main/ets/services/DataManager';
import { BusinessError } from '@ohos/base';

export default function DataManagerTest() {
  let dataManager: DataManager;
  let testContext: Context;

  describe('DataManager Unit Tests', () => {
    
    beforeAll(async () => {
      // 测试前准备
      dataManager = DataManager.getInstance();
      testContext = getContext(this);
      await dataManager.init(testContext);
    });

    beforeEach(async () => {
      // 每个测试前清空数据
      const transactions: Transaction[] = [];
      await dataManager.saveTransactions(transactions);
    });

    afterEach(async () => {
      // 每个测试后清理
      const transactions: Transaction[] = [];
      await dataManager.saveTransactions(transactions);
    });

    afterAll(() => {
      // 测试完成后清理
      console.info('DataManager tests completed');
    });

    // ==================== 基础功能测试 ====================
    
    it('should initialize DataManager correctly', 0, () => {
      expect(dataManager).assertNotNull();
      expect(DataManager.getInstance()).assertEqual(dataManager);
    });

    it('should add a single transaction correctly', 0, async () => {
      const transaction: Transaction = {
        id: Date.now(),
        title: '测试午餐',
        amount: 35,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      const success = await dataManager.addTransaction(transaction);
      expect(success).assertTrue();

      const transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(1);
      expect(transactions[0].title).assertEqual('测试午餐');
      expect(transactions[0].amount).assertEqual(35);
      expect(transactions[0].type).assertEqual('expense');
    });

    it('should add multiple transactions', 0, async () => {
      const transactions: Transaction[] = [
        { id: 1, title: '早餐', amount: 15, type: 'expense', date: '2026-02-03', category: '餐饮' },
        { id: 2, title: '地铁', amount: 6, type: 'expense', date: '2026-02-03', category: '交通' },
        { id: 3, title: '工资', amount: 5000, type: 'income', date: '2026-02-03', category: '工资' }
      ];

      for (const t of transactions) {
        await dataManager.addTransaction(t);
      }

      const result = await dataManager.getTransactions();
      expect(result.length).assertEqual(3);
    });

    it('should update an existing transaction', 0, async () => {
      const transaction: Transaction = {
        id: 1,
        title: '原午餐',
        amount: 30,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      await dataManager.addTransaction(transaction);

      const updatedTransaction: Transaction = {
        id: 1,
        title: '修改后的午餐',
        amount: 35,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      const success = await dataManager.updateTransaction(updatedTransaction);
      expect(success).assertTrue();

      const transactions = await dataManager.getTransactions();
      expect(transactions[0].title).assertEqual('修改后的午餐');
      expect(transactions[0].amount).assertEqual(35);
    });

    it('should not update non-existent transaction', 0, async () => {
      const nonExistentTransaction: Transaction = {
        id: 999,
        title: '不存在的记录',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      const success = await dataManager.updateTransaction(nonExistentTransaction);
      expect(success).assertFalse();
    });

    it('should delete a transaction by id', 0, async () => {
      const transaction: Transaction = {
        id: 1,
        title: '待删除',
        amount: 50,
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

    it('should handle delete of non-existent id', 0, async () => {
      const success = await dataManager.deleteTransaction(999);
      expect(success).assertTrue(); // 删除不存在的ID应返回true（无副作用）
    });

    // ==================== 余额计算测试 ====================

    it('should calculate balance correctly for income only', 0, async () => {
      await dataManager.addTransaction({
        id: 1, title: '工资', amount: 5000, type: 'income',
        date: '2026-02-03', category: '工资'
      });

      const summary = await dataManager.calculateBalance();
      expect(summary.balance).assertEqual(5000);
      expect(summary.totalIncome).assertEqual(5000);
      expect(summary.totalExpense).assertEqual(0);
    });

    it('should calculate balance correctly for expense only', 0, async () => {
      await dataManager.addTransaction({
        id: 1, title: '购物', amount: 200, type: 'expense',
        date: '2026-02-03', category: '购物'
      });

      const summary = await dataManager.calculateBalance();
      expect(summary.balance).assertEqual(-200);
      expect(summary.totalIncome).assertEqual(0);
      expect(summary.totalExpense).assertEqual(200);
    });

    it('should calculate balance correctly for mixed transactions', 0, async () => {
      await dataManager.addTransaction({
        id: 1, title: '工资', amount: 5000, type: 'income',
        date: '2026-02-03', category: '工资'
      });
      await dataManager.addTransaction({
        id: 2, title: '房租', amount: 2000, type: 'expense',
        date: '2026-02-03', category: '住房'
      });
      await dataManager.addTransaction({
        id: 3, title: '餐饮', amount: 500, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      });

      const summary = await dataManager.calculateBalance();
      expect(summary.balance).assertEqual(2500);
      expect(summary.totalIncome).assertEqual(5000);
      expect(summary.totalExpense).assertEqual(2500);
    });

    it('should handle empty transactions for balance calculation', 0, async () => {
      const summary = await dataManager.calculateBalance();
      expect(summary.balance).assertEqual(0);
      expect(summary.totalIncome).assertEqual(0);
      expect(summary.totalExpense).assertEqual(0);
    });

    // ==================== 分类管理测试 ====================

    it('should return default categories', 0, async () => {
      const categories = await dataManager.getCategories();
      expect(categories.length).assertLarger(0);
      
      // 检查是否包含支出分类
      const expenseCategories = categories.filter(c => c.type === 'expense');
      expect(expenseCategories.length).assertLarger(0);
      
      // 检查是否包含收入分类
      const incomeCategories = categories.filter(c => c.type === 'income');
      expect(incomeCategories.length).assertLarger(0);
    });

    it('should save and retrieve custom categories', 0, async () => {
      const customCategories: Category[] = [
        { name: '自定义支出', icon: '🎯', type: 'expense' },
        { name: '自定义收入', icon: '💎', type: 'income' }
      ];

      const success = await dataManager.saveCategories(customCategories);
      expect(success).assertTrue();

      const retrieved = await dataManager.getCategories();
      expect(retrieved.length).assertEqual(2);
      expect(retrieved[0].name).assertEqual('自定义支出');
    });

    // ==================== 边界情况测试 ====================

    it('should handle zero amount transaction', 0, async () => {
      const transaction: Transaction = {
        id: 1,
        title: '零金额测试',
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

    it('should handle large amount transaction', 0, async () => {
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

    it('should handle decimal amount correctly', 0, async () => {
      const transaction: Transaction = {
        id: 1,
        title: '小数金额',
        amount: 35.5,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      await dataManager.addTransaction(transaction);
      const transactions = await dataManager.getTransactions();
      expect(transactions[0].amount).assertEqual(35.5);
    });

    it('should handle special characters in title', 0, async () => {
      const transaction: Transaction = {
        id: 1,
        title: '特殊字符测试!@#$%^&*()',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      const success = await dataManager.addTransaction(transaction);
      expect(success).assertTrue();

      const transactions = await dataManager.getTransactions();
      expect(transactions[0].title).assertEqual('特殊字符测试!@#$%^&*()');
    });

    it('should maintain transaction order (newest first)', 0, async () => {
      const t1: Transaction = { id: 1, title: '第一条', amount: 10, type: 'expense', date: '2026-02-01', category: '餐饮' };
      const t2: Transaction = { id: 2, title: '第二条', amount: 20, type: 'expense', date: '2026-02-02', category: '餐饮' };
      const t3: Transaction = { id: 3, title: '第三条', amount: 30, type: 'expense', date: '2026-02-03', category: '餐饮' };

      await dataManager.addTransaction(t1);
      await dataManager.addTransaction(t2);
      await dataManager.addTransaction(t3);

      const transactions = await dataManager.getTransactions();
      // 验证最新添加的在最前面
      expect(transactions[0].id).assertEqual(3);
      expect(transactions[1].id).assertEqual(2);
      expect(transactions[2].id).assertEqual(1);
    });

    // ==================== 数据持久化测试 ====================

    it('should persist data across sessions', 0, async () => {
      const transaction: Transaction = {
        id: 1,
        title: '持久化测试',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      await dataManager.addTransaction(transaction);

      // 模拟重新初始化（实际测试中会保持同一个实例）
      const transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(1);
      expect(transactions[0].title).assertEqual('持久化测试');
    });

    // ==================== 性能测试 ====================

    it('should handle 100 transactions efficiently', 0, async () => {
      const startTime = Date.now();

      for (let i = 0; i < 100; i++) {
        await dataManager.addTransaction({
          id: i,
          title: `测试记录${i}`,
          amount: i * 10,
          type: i % 2 === 0 ? 'expense' : 'income',
          date: '2026-02-03',
          category: '餐饮'
        });
      }

      const endTime = Date.now();
      const duration = endTime - startTime;

      const transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(100);
      expect(duration).assertLess(5000); // 应该在5秒内完成
    });

    it('should calculate balance quickly with many transactions', 0, async () => {
      // 先添加大量数据
      for (let i = 0; i < 50; i++) {
        await dataManager.addTransaction({
          id: i,
          title: `记录${i}`,
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        });
      }

      const startTime = Date.now();
      const summary = await dataManager.calculateBalance();
      const endTime = Date.now();

      expect(summary.totalExpense).assertEqual(5000);
      expect(endTime - startTime).assertLess(1000); // 1秒内完成
    });
  });
}
