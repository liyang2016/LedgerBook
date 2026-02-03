import { describe, it, expect, beforeAll, beforeEach, afterEach, afterAll } from '@ohos/hypium';
import { DataManager, Transaction, Category, BalanceSummary } from '../../main/ets/services/DataManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * DataManager 兼容 ArkTS 规范的测试套件
 * 修复所有编译错误，符合 HarmonyOS API 12 标准
 */
export default function DataManagerUnifiedTest() {
  
  describe('DataManager Unified Test Suite', () => {
    
    let dataManager: DataManager;
    let testContext: Context;
    let idSeed: number = 1;
    const TEST_TAG: string = 'DMUnifiedTest';

    // 生成唯一ID
    function genId(): number {
      return Date.now() + (idSeed++);
    }

    // 创建标准测试数据
    function makeTx(title: string, amount: number, type: string, category: string, overrides: Record<string, Object>): Transaction {
      let tx: Transaction = {
        id: genId(),
        title: title,
        amount: amount,
        type: type as 'income' | 'expense',
        date: '2026-02-03',
        category: category
      };
      
      // 手动合并覆盖属性
      if (overrides['id'] !== undefined) {
        tx.id = overrides['id'] as number;
      }
      if (overrides['date'] !== undefined) {
        tx.date = overrides['date'] as string;
      }
      
      return tx;
    }

    // 批量创建测试数据
    function makeTxs(count: number, baseTitle: string, baseAmount: number): Transaction[] {
      let txs: Transaction[] = [];
      for (let i: number = 0; i < count; i++) {
        let t: Transaction = {
          id: genId(),
          title: baseTitle + i,
          amount: baseAmount * (i + 1),
          type: (i % 2 === 0) ? 'expense' : 'income',
          date: '2026-02-03',
          category: '餐饮'
        };
        txs.push(t);
      }
      return txs;
    }

    // 生命周期钩子
    beforeAll(async () => {
      hilog.info(0x0000, TEST_TAG, '🚀 测试套件初始化');
      try {
        dataManager = DataManager.getInstance();
        testContext = getContext();
        await dataManager.init(testContext);
        hilog.info(0x0000, TEST_TAG, '✅ 初始化完成');
      } catch (err) {
        hilog.error(0x0000, TEST_TAG, '❌ 初始化失败');
        throw err;
      }
    });

    beforeEach(async () => {
      idSeed = 1;
      await dataManager.saveTransactions([]);
    });

    afterEach(async () => {
      await dataManager.saveTransactions([]);
    });

    afterAll(() => {
      hilog.info(0x0000, TEST_TAG, '🏁 测试套件完成');
    });

    // ==================== 基础CRUD测试 ====================
    describe('基础CRUD测试', () => {
      
      it('test001_单例实例一致性', 0, () => {
        let i1: DataManager = DataManager.getInstance();
        let i2: DataManager = DataManager.getInstance();
        expect(i1 === i2).assertTrue();
      });

      it('test002_添加单笔交易', 0, async () => {
        let t: Transaction = makeTx('午餐', 35, 'expense', '餐饮', {});
        let ok: boolean = await dataManager.addTransaction(t);
        expect(ok).assertTrue();
        
        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs.length).assertEqual(1);
        expect(txs[0].title).assertEqual('午餐');
      });

      it('test003_批量添加交易', 0, async () => {
        let txs: Transaction[] = makeTxs(5, '交易', 10);
        for (let i: number = 0; i < txs.length; i++) {
          await dataManager.addTransaction(txs[i]);
        }
        
        let saved: Transaction[] = await dataManager.getTransactions();
        expect(saved.length).assertEqual(5);
      });

      it('test004_查询所有交易', 0, async () => {
        await dataManager.addTransaction(makeTx('T1', 10, 'expense', '餐饮', { 'id': 101 }));
        await dataManager.addTransaction(makeTx('T2', 20, 'expense', '餐饮', { 'id': 102 }));

        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs.length).assertEqual(2);
      });

      it('test005_更新现有交易', 0, async () => {
        await dataManager.addTransaction(makeTx('原', 50, 'expense', '餐饮', { 'id': 201 }));
        let updated: Transaction = makeTx('新', 75, 'expense', '交通', { 'id': 201 });
        let ok: boolean = await dataManager.updateTransaction(updated);
        expect(ok).assertTrue();
        
        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs[0].title).assertEqual('新');
      });

      it('test006_删除指定交易', 0, async () => {
        await dataManager.addTransaction(makeTx('待删', 100, 'expense', '餐饮', { 'id': 301 }));
        let ok: boolean = await dataManager.deleteTransaction(301);
        expect(ok).assertTrue();
        
        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs.length).assertEqual(0);
      });

      it('test007_删除后添加新交易', 0, async () => {
        await dataManager.addTransaction(makeTx('', 0, 'expense', '餐饮', { 'id': 401 }));
        await dataManager.deleteTransaction(401);
        await dataManager.addTransaction(makeTx('新', 100, 'expense', '餐饮', { 'id': 402 }));

        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs.length).assertEqual(1);
        expect(txs[0].id).assertEqual(402);
      });

      it('test008_多次更新同一交易', 0, async () => {
        let id: number = 501;
        await dataManager.addTransaction(makeTx('', 100, 'expense', '餐饮', { 'id': id }));
        await dataManager.updateTransaction(makeTx('', 200, 'expense', '餐饮', { 'id': id }));
        await dataManager.updateTransaction(makeTx('', 300, 'expense', '餐饮', { 'id': id }));

        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs[0].amount).assertEqual(300);
      });

      it('test009_空列表查询', 0, async () => {
        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs.length).assertEqual(0);
      });

      it('test010_批量删除', 0, async () => {
        for (let i: number = 0; i < 5; i++) {
          await dataManager.addTransaction(makeTx('', 0, 'expense', '餐饮', { 'id': 600 + i }));
        }
        
        await dataManager.deleteTransaction(600);
        await dataManager.deleteTransaction(602);
        await dataManager.deleteTransaction(604);

        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs.length).assertEqual(2);
      });
    });

    // ==================== 业务逻辑测试 ====================
    describe('业务逻辑测试', () => {
      
      it('test011_计算混合收支余额', 0, async () => {
        await dataManager.addTransaction(makeTx('工资', 5000, 'income', '工资', {}));
        await dataManager.addTransaction(makeTx('房租', 2000, 'expense', '住房', {}));
        await dataManager.addTransaction(makeTx('餐饮', 500, 'expense', '餐饮', {}));

        let summary: BalanceSummary = await dataManager.calculateBalance();
        expect(summary.totalIncome).assertEqual(5000);
        expect(summary.totalExpense).assertEqual(2500);
        expect(summary.balance).assertEqual(2500);
      });

      it('test012_纯支出余额为负', 0, async () => {
        await dataManager.addTransaction(makeTx('', 100, 'expense', '餐饮', {}));
        await dataManager.addTransaction(makeTx('', 200, 'expense', '餐饮', {}));

        let summary: BalanceSummary = await dataManager.calculateBalance();
        expect(summary.balance).assertEqual(-300);
      });

      it('test013_纯收入余额为正', 0, async () => {
        await dataManager.addTransaction(makeTx('', 3000, 'income', '工资', {}));
        await dataManager.addTransaction(makeTx('', 2000, 'income', '奖金', {}));

        let summary: BalanceSummary = await dataManager.calculateBalance();
        expect(summary.balance).assertEqual(5000);
      });

      it('test014_获取默认分类', 0, async () => {
        let cats: Category[] = await dataManager.getCategories();
        expect(cats.length > 0).assertTrue();
        
        let expense: Category[] = [];
        let income: Category[] = [];
        for (let i: number = 0; i < cats.length; i++) {
          if (cats[i].type === 'expense') {
            expense.push(cats[i]);
          } else {
            income.push(cats[i]);
          }
        }
        
        expect(expense.length > 0).assertTrue();
        expect(income.length > 0).assertTrue();
      });

      it('test015_保存自定义分类', 0, async () => {
        let custom: Category[] = [
          { name: '自定义1', icon: '🎯', type: 'expense' },
          { name: '自定义2', icon: '💎', type: 'income' }
        ];
        
        let ok: boolean = await dataManager.saveCategories(custom);
        expect(ok).assertTrue();
        
        let saved: Category[] = await dataManager.getCategories();
        expect(saved.length).assertEqual(2);
      });

      it('test016_零余额场景', 0, async () => {
        await dataManager.addTransaction(makeTx('', 1000, 'income', '工资', {}));
        await dataManager.addTransaction(makeTx('', 1000, 'expense', '餐饮', {}));

        let summary: BalanceSummary = await dataManager.calculateBalance();
        expect(summary.balance).assertEqual(0);
      });
    });

    // ==================== 边界条件测试 ====================
    describe('边界条件测试', () => {
      
      it('test021_零金额交易', 0, async () => {
        let t: Transaction = makeTx('', 0, 'expense', '餐饮', {});
        let ok: boolean = await dataManager.addTransaction(t);
        expect(ok).assertTrue();
      });

      it('test022_最大金额', 0, async () => {
        let t: Transaction = makeTx('', 999999.99, 'income', '工资', {});
        let ok: boolean = await dataManager.addTransaction(t);
        expect(ok).assertTrue();
        
        let summary: BalanceSummary = await dataManager.calculateBalance();
        expect(summary.totalIncome).assertEqual(999999.99);
      });

      it('test023_两位小数精度', 0, async () => {
        let t: Transaction = makeTx('', 35.99, 'expense', '餐饮', {});
        await dataManager.addTransaction(t);
        
        let txs: Transaction[] = await dataManager.getTransactions();
        expect(txs[0].amount).assertEqual(35.99);
      });

      it('test024_空字符串标题', 0, async () => {
        let t: Transaction = makeTx('', 100, 'expense', '餐饮', {});
        let ok: boolean = await dataManager.addTransaction(t);
        expect(ok).assertTrue();
      });

      it('test025_特殊字符标题', 0, async () => {
        let special: string = '测试123';
        let t: Transaction = makeTx(special, 100, 'expense', '餐饮', {});
        let ok: boolean = await dataManager.addTransaction(t);
        expect(ok).assertTrue();
      });
    });

    // ==================== 错误处理测试 ====================
    describe('错误处理测试', () => {
      
      it('test031_更新不存在交易', 0, async () => {
        let t: Transaction = makeTx('', 100, 'expense', '餐饮', { 'id': 99999 });
        let ok: boolean = await dataManager.updateTransaction(t);
        expect(ok).assertFalse();
      });

      it('test032_删除不存在交易幂等', 0, async () => {
        let ok: boolean = await dataManager.deleteTransaction(88888);
        expect(ok).assertTrue();
      });

      it('test033_操作失败数据一致性', 0, async () => {
        await dataManager.addTransaction(makeTx('保留', 100, 'expense', '餐饮', { 'id': 777 }));
        let before: number = (await dataManager.getTransactions()).length;

        await dataManager.updateTransaction(makeTx('', 100, 'expense', '餐饮', { 'id': 99999 }));
        
        let after: number = (await dataManager.getTransactions()).length;
        expect(after).assertEqual(before);
      });
    });

    // ==================== 性能基准测试 ====================
    describe('性能基准测试', () => {
      
      it('test041_单条添加性能', 0, async () => {
        let start: number = Date.now();
        await dataManager.addTransaction(makeTx('', 100, 'expense', '餐饮', {}));
        let ms: number = Date.now() - start;
        
        expect(ms < 100).assertTrue();
        hilog.info(0x0000, TEST_TAG, 'L0单条添加: %{public}d ms', ms);
      });

      it('test042_批量10条性能', 0, async () => {
        let txs: Transaction[] = makeTxs(10, 'T', 10);
        let start: number = Date.now();
        
        for (let i: number = 0; i < txs.length; i++) {
          await dataManager.addTransaction(txs[i]);
        }
        
        let ms: number = Date.now() - start;
        expect(ms < 500).assertTrue();
      });

      it('test043_查询50条性能', 0, async () => {
        let txs: Transaction[] = makeTxs(50, 'Q', 10);
        for (let i: number = 0; i < txs.length; i++) {
          await dataManager.addTransaction(txs[i]);
        }

        let start: number = Date.now();
        let saved: Transaction[] = await dataManager.getTransactions();
        let ms: number = Date.now() - start;

        expect(saved.length).assertEqual(50);
        expect(ms < 100).assertTrue();
      });

      it('test044_余额计算性能', 0, async () => {
        let txs: Transaction[] = makeTxs(100, 'B', 10);
        for (let i: number = 0; i < txs.length; i++) {
          await dataManager.addTransaction(txs[i]);
        }

        let start: number = Date.now();
        await dataManager.calculateBalance();
        let ms: number = Date.now() - start;

        expect(ms < 100).assertTrue();
      });
    });

    // ==================== 测试总结 ====================
    describe('测试总结', () => {
      
      it('test099_测试套件验证', 0, () => {
        hilog.info(0x0000, TEST_TAG, '✅ 所有测试用例执行完毕！');
        expect(true).assertTrue();
      });
    });
  });
}
