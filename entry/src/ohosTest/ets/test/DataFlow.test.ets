import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DataManager, Transaction } from '../../main/ets/services/DataManager';

export default function DataFlowTest() {
  describe('Data Flow Integration Tests', () => {
    
    let dataManager: DataManager;
    let testContext: Context;

    beforeAll(async () => {
      hilog.info(0x0000, 'testTag', '%{public}s', 'Data Flow Integration test suite begin');
      dataManager = DataManager.getInstance();
      testContext = getContext(this);
      await dataManager.init(testContext);
    });

    beforeEach(async () => {
      // 每个测试前清空数据
      await dataManager.saveTransactions([]);
    });

    afterEach(async () => {
      // 每个测试后清理
      await dataManager.saveTransactions([]);
    });

    afterAll(() => {
      hilog.info(0x0000, 'testTag', '%{public}s', 'Data Flow Integration test suite end');
    });

    // ==================== 端到端数据流测试 ====================

    it('should complete full add transaction flow', 0, async () => {
      // 步骤1: 添加交易
      const transaction: Transaction = {
        id: Date.now(),
        title: '集成测试-添加',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };

      const addSuccess = await dataManager.addTransaction(transaction);
      expect(addSuccess).assertTrue();

      // 步骤2: 验证数据已保存
      const transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(1);
      expect(transactions[0].title).assertEqual('集成测试-添加');

      // 步骤3: 验证统计数据已更新
      const summary = await dataManager.calculateBalance();
      expect(summary.totalExpense).assertEqual(100);
      expect(summary.balance).assertEqual(-100);
    });

    it('should complete full edit transaction flow', 0, async () => {
      // 步骤1: 添加初始交易
      const transaction: Transaction = {
        id: 1,
        title: '原始数据',
        amount: 50,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };
      await dataManager.addTransaction(transaction);

      // 步骤2: 编辑交易
      const updatedTransaction: Transaction = {
        id: 1,
        title: '修改后数据',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '交通'
      };

      const updateSuccess = await dataManager.updateTransaction(updatedTransaction);
      expect(updateSuccess).assertTrue();

      // 步骤3: 验证数据已更新
      const transactions = await dataManager.getTransactions();
      expect(transactions[0].title).assertEqual('修改后数据');
      expect(transactions[0].amount).assertEqual(100);
      expect(transactions[0].category).assertEqual('交通');

      // 步骤4: 验证统计数据已更新
      const summary = await dataManager.calculateBalance();
      expect(summary.totalExpense).assertEqual(100);
    });

    it('should complete full delete transaction flow', 0, async () => {
      // 步骤1: 添加多个交易
      const t1: Transaction = {
        id: 1, title: '交易1', amount: 50, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      };
      const t2: Transaction = {
        id: 2, title: '交易2', amount: 100, type: 'expense',
        date: '2026-02-03', category: '交通'
      };
      
      await dataManager.addTransaction(t1);
      await dataManager.addTransaction(t2);

      let transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(2);

      // 步骤2: 删除第一个交易
      const deleteSuccess = await dataManager.deleteTransaction(1);
      expect(deleteSuccess).assertTrue();

      // 步骤3: 验证数据已删除
      transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(1);
      expect(transactions[0].id).assertEqual(2);

      // 步骤4: 验证统计数据已更新
      const summary = await dataManager.calculateBalance();
      expect(summary.totalExpense).assertEqual(100);
    });

    // ==================== 批量操作测试 ====================

    it('should handle batch add operations', 0, async () => {
      const transactions: Transaction[] = [];
      
      // 批量添加10个交易
      for (let i = 0; i < 10; i++) {
        transactions.push({
          id: i,
          title: `批量交易${i}`,
          amount: i * 10,
          type: i % 2 === 0 ? 'expense' : 'income',
          date: '2026-02-03',
          category: i % 2 === 0 ? '餐饮' : '工资'
        });
      }

      for (const t of transactions) {
        await dataManager.addTransaction(t);
      }

      // 验证所有数据已保存
      const saved = await dataManager.getTransactions();
      expect(saved.length).assertEqual(10);

      // 验证统计数据正确
      const summary = await dataManager.calculateBalance();
      const expectedExpense = [0, 2, 4, 6, 8].reduce((sum, i) => sum + i * 10, 0); // 0 + 20 + 40 + 60 + 80 = 200
      const expectedIncome = [1, 3, 5, 7, 9].reduce((sum, i) => sum + i * 10, 0); // 10 + 30 + 50 + 70 + 90 = 250
      
      expect(summary.totalExpense).assertEqual(200);
      expect(summary.totalIncome).assertEqual(250);
      expect(summary.balance).assertEqual(50);
    });

    it('should handle mixed operations sequence', 0, async () => {
      // 操作序列: 添加 → 编辑 → 添加 → 删除 → 编辑
      
      // 1. 添加
      await dataManager.addTransaction({
        id: 1, title: 'T1', amount: 100, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      });

      // 2. 编辑
      await dataManager.updateTransaction({
        id: 1, title: 'T1-修改', amount: 150, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      });

      // 3. 添加
      await dataManager.addTransaction({
        id: 2, title: 'T2', amount: 200, type: 'income',
        date: '2026-02-03', category: '工资'
      });

      // 4. 删除
      await dataManager.deleteTransaction(1);

      // 5. 添加
      await dataManager.addTransaction({
        id: 3, title: 'T3', amount: 50, type: 'expense',
        date: '2026-02-03', category: '交通'
      });

      // 验证最终状态
      const transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(2);
      expect(transactions.find(t => t.id === 1)).assertNull(); // T1已删除
      expect(transactions.find(t => t.id === 2)).assertNotNull(); // T2存在
      expect(transactions.find(t => t.id === 3)).assertNotNull(); // T3存在

      const summary = await dataManager.calculateBalance();
      expect(summary.totalIncome).assertEqual(200);
      expect(summary.totalExpense).assertEqual(50);
      expect(summary.balance).assertEqual(150);
    });

    // ==================== 数据一致性测试 ====================

    it('should maintain data consistency after multiple operations', 0, async () => {
      // 执行多次添加和删除
      for (let i = 0; i < 5; i++) {
        await dataManager.addTransaction({
          id: i,
          title: `交易${i}`,
          amount: 100,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        });
      }

      // 删除部分交易
      await dataManager.deleteTransaction(0);
      await dataManager.deleteTransaction(2);
      await dataManager.deleteTransaction(4);

      // 验证数据一致性
      const transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(2);
      expect(transactions.some(t => t.id === 1)).assertTrue();
      expect(transactions.some(t => t.id === 3)).assertTrue();

      const summary = await dataManager.calculateBalance();
      expect(summary.totalExpense).assertEqual(200); // 100 + 100
    });

    it('should handle rapid successive operations', 0, async () => {
      const operations: Promise<boolean>[] = [];

      // 快速连续添加
      for (let i = 0; i < 20; i++) {
        operations.push(dataManager.addTransaction({
          id: i,
          title: `快速交易${i}`,
          amount: 10,
          type: 'expense',
          date: '2026-02-03',
          category: '餐饮'
        }));
      }

      // 等待所有操作完成
      const results = await Promise.all(operations);
      
      // 验证所有操作都成功
      results.forEach(success => {
        expect(success).assertTrue();
      });

      // 验证数据完整
      const transactions = await dataManager.getTransactions();
      expect(transactions.length).assertEqual(20);
    });

    // ==================== 状态同步测试 ====================

    it('should sync statistics with transaction changes', 0, async () => {
      // 初始状态
      let summary = await dataManager.calculateBalance();
      expect(summary.balance).assertEqual(0);

      // 添加收入
      await dataManager.addTransaction({
        id: 1, title: '工资', amount: 5000, type: 'income',
        date: '2026-02-03', category: '工资'
      });
      summary = await dataManager.calculateBalance();
      expect(summary.totalIncome).assertEqual(5000);
      expect(summary.balance).assertEqual(5000);

      // 添加支出
      await dataManager.addTransaction({
        id: 2, title: '房租', amount: 2000, type: 'expense',
        date: '2026-02-03', category: '住房'
      });
      summary = await dataManager.calculateBalance();
      expect(summary.totalExpense).assertEqual(2000);
      expect(summary.balance).assertEqual(3000);

      // 修改支出
      await dataManager.updateTransaction({
        id: 2, title: '房租', amount: 1500, type: 'expense',
        date: '2026-02-03', category: '住房'
      });
      summary = await dataManager.calculateBalance();
      expect(summary.totalExpense).assertEqual(1500);
      expect(summary.balance).assertEqual(3500);

      // 删除收入
      await dataManager.deleteTransaction(1);
      summary = await dataManager.calculateBalance();
      expect(summary.totalIncome).assertEqual(0);
      expect(summary.totalExpense).assertEqual(1500);
      expect(summary.balance).assertEqual(-1500);
    });

    // ==================== 错误恢复测试 ====================

    it('should maintain data integrity on failed operations', 0, async () => {
      // 先添加有效数据
      await dataManager.addTransaction({
        id: 1, title: '有效数据', amount: 100, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      });

      const beforeCount = (await dataManager.getTransactions()).length;
      
      // 尝试更新不存在的记录（不应影响现有数据）
      await dataManager.updateTransaction({
        id: 999, title: '不存在', amount: 100, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      });

      const afterCount = (await dataManager.getTransactions()).length;
      const summary = await dataManager.calculateBalance();
      
      // 数据应保持不变
      expect(afterCount).assertEqual(beforeCount);
      expect(summary.totalExpense).assertEqual(100);
    });

    // ==================== 性能测试 ====================

    it('should handle data flow efficiently', 0, async () => {
      const startTime = Date.now();

      // 添加
      await dataManager.addTransaction({
        id: 1, title: '性能测试', amount: 100, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      });

      // 查询
      await dataManager.getTransactions();

      // 统计
      await dataManager.calculateBalance();

      // 更新
      await dataManager.updateTransaction({
        id: 1, title: '性能测试-更新', amount: 200, type: 'expense',
        date: '2026-02-03', category: '餐饮'
      });

      // 删除
      await dataManager.deleteTransaction(1);

      const endTime = Date.now();
      const duration = endTime - startTime;

      expect(duration).assertLess(2000); // 整个流程应在2秒内完成
    });
  });
}
