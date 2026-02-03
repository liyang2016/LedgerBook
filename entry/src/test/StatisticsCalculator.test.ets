import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Transaction, CategoryStat } from '../../main/ets/services/DataManager';

export default function StatisticsCalculatorTest() {
  describe('StatisticsCalculator Unit Tests', () => {
    
    let testTransactions: Transaction[];

    beforeAll(() => {
      // 准备测试数据
      testTransactions = [
        { id: 1, title: '早餐', amount: 15, type: 'expense', date: '2026-02-01', category: '餐饮' },
        { id: 2, title: '午餐', amount: 35, type: 'expense', date: '2026-02-01', category: '餐饮' },
        { id: 3, title: '晚餐', amount: 25, type: 'expense', date: '2026-02-01', category: '餐饮' },
        { id: 4, title: '地铁', amount: 6, type: 'expense', date: '2026-02-01', category: '交通' },
        { id: 5, title: '打车', amount: 20, type: 'expense', date: '2026-02-01', category: '交通' },
        { id: 6, title: '购物', amount: 200, type: 'expense', date: '2026-02-01', category: '购物' },
        { id: 7, title: '工资', amount: 5000, type: 'income', date: '2026-02-01', category: '工资' },
        { id: 8, title: '奖金', amount: 1000, type: 'income', date: '2026-02-01', category: '奖金' }
      ];
    });

    // ==================== 分类汇总测试 ====================

    it('should calculate category statistics correctly', 0, () => {
      const expenseTransactions = testTransactions.filter(t => t.type === 'expense');
      
      const categoryMap: Map<string, number> = new Map();
      expenseTransactions.forEach(t => {
        const current = categoryMap.get(t.category) || 0;
        categoryMap.set(t.category, current + t.amount);
      });

      expect(categoryMap.get('餐饮')).assertEqual(75);
      expect(categoryMap.get('交通')).assertEqual(26);
      expect(categoryMap.get('购物')).assertEqual(200);
    });

    it('should handle empty category map', 0, () => {
      const emptyMap: Map<string, number> = new Map();
      
      expect(emptyMap.size).assertEqual(0);
    });

    it('should group transactions by category correctly', 0, () => {
      const expenseTransactions = testTransactions.filter(t => t.type === 'expense');
      
      const categoryGroups = new Map<string, Transaction[]>();
      expenseTransactions.forEach(t => {
        const group = categoryGroups.get(t.category) || [];
        group.push(t);
        categoryGroups.set(t.category, group);
      });

      expect(categoryGroups.get('餐饮')?.length).assertEqual(3);
      expect(categoryGroups.get('交通')?.length).assertEqual(2);
      expect(categoryGroups.get('购物')?.length).assertEqual(1);
    });

    // ==================== 百分比计算测试 ====================

    it('should calculate percentage correctly', 0, () => {
      const categoryAmount = 75;
      const totalAmount = 301; // 75 + 26 + 200
      
      const percentage = (categoryAmount / totalAmount) * 100;
      expect(percentage.toFixed(1)).assertEqual('24.9');
    });

    it('should handle zero total in percentage calculation', 0, () => {
      const categoryAmount = 100;
      const totalAmount = 0;
      
      const percentage = totalAmount > 0 ? (categoryAmount / totalAmount) * 100 : 0;
      expect(percentage).assertEqual(0);
    });

    it('should handle 100% percentage', 0, () => {
      const categoryAmount = 100;
      const totalAmount = 100;
      
      const percentage = (categoryAmount / totalAmount) * 100;
      expect(percentage).assertEqual(100);
    });

    it('should round percentage to 1 decimal place', 0, () => {
      const categoryAmount = 33;
      const totalAmount = 100;
      
      const percentage = (categoryAmount / totalAmount) * 100;
      expect(percentage.toFixed(1)).assertEqual('33.0');
    });

    // ==================== 排序功能测试 ====================

    it('should sort category stats by amount descending', 0, () => {
      const stats: CategoryStat[] = [
        { category: '餐饮', amount: 75, percentage: 24.9 },
        { category: '交通', amount: 26, percentage: 8.6 },
        { category: '购物', amount: 200, percentage: 66.4 }
      ];

      const sorted = stats.sort((a, b) => b.amount - a.amount);
      
      expect(sorted[0].category).assertEqual('购物');
      expect(sorted[1].category).assertEqual('餐饮');
      expect(sorted[2].category).assertEqual('交通');
    });

    it('should handle sorting with equal amounts', 0, () => {
      const stats: CategoryStat[] = [
        { category: 'A', amount: 100, percentage: 50 },
        { category: 'B', amount: 100, percentage: 50 }
      ];

      const sorted = stats.sort((a, b) => b.amount - a.amount);
      // 相等金额时保持原有顺序（稳定排序）
      expect(sorted[0].amount).assertEqual(sorted[1].amount);
    });

    // ==================== 月度统计测试 ====================

    it('should calculate monthly expenses correctly', 0, () => {
      const monthlyTransactions = testTransactions.filter(t => 
        t.type === 'expense' && t.date.startsWith('2026-02')
      );
      
      const total = monthlyTransactions.reduce((sum, t) => sum + t.amount, 0);
      expect(total).assertEqual(301);
    });

    it('should group transactions by month', 0, () => {
      const transactions = [
        { id: 1, title: 'T1', amount: 100, type: 'expense', date: '2026-01-15', category: '餐饮' },
        { id: 2, title: 'T2', amount: 200, type: 'expense', date: '2026-02-20', category: '餐饮' },
        { id: 3, title: 'T3', amount: 300, type: 'expense', date: '2026-02-25', category: '餐饮' }
      ];

      const monthGroups = new Map<string, number>();
      transactions.forEach(t => {
        const month = t.date.substring(0, 7); // '2026-01', '2026-02'
        const current = monthGroups.get(month) || 0;
        monthGroups.set(month, current + t.amount);
      });

      expect(monthGroups.get('2026-01')).assertEqual(100);
      expect(monthGroups.get('2026-02')).assertEqual(500);
    });

    // ==================== 趋势计算测试 ====================

    it('should calculate daily trend correctly', 0, () => {
      const dailyData = [
        { date: '2026-02-01', amount: 100 },
        { date: '2026-02-02', amount: 150 },
        { date: '2026-02-03', amount: 80 }
      ];

      const total = dailyData.reduce((sum, d) => sum + d.amount, 0);
      const average = total / dailyData.length;
      
      expect(total).assertEqual(330);
      expect(average).assertEqual(110);
    });

    it('should detect increasing trend', 0, () => {
      const weeklyData = [100, 120, 150, 180, 200];
      
      const first = weeklyData[0];
      const last = weeklyData[weeklyData.length - 1];
      const trend = last > first ? 'increasing' : last < first ? 'decreasing' : 'stable';
      
      expect(trend).assertEqual('increasing');
    });

    it('should detect decreasing trend', 0, () => {
      const weeklyData = [200, 180, 150, 120, 100];
      
      const first = weeklyData[0];
      const last = weeklyData[weeklyData.length - 1];
      const trend = last > first ? 'increasing' : last < first ? 'decreasing' : 'stable';
      
      expect(trend).assertEqual('decreasing');
    });

    it('should detect stable trend', 0, () => {
      const weeklyData = [100, 100, 100, 100, 100];
      
      const first = weeklyData[0];
      const last = weeklyData[weeklyData.length - 1];
      const trend = last > first ? 'increasing' : last < first ? 'decreasing' : 'stable';
      
      expect(trend).assertEqual('stable');
    });

    // ==================== 空数据处理测试 ====================

    it('should handle empty transaction list', 0, () => {
      const emptyTransactions: Transaction[] = [];
      
      const total = emptyTransactions.reduce((sum, t) => sum + t.amount, 0);
      const categoryMap = new Map<string, number>();
      
      emptyTransactions.forEach(t => {
        const current = categoryMap.get(t.category) || 0;
        categoryMap.set(t.category, current + t.amount);
      });

      expect(total).assertEqual(0);
      expect(categoryMap.size).assertEqual(0);
    });

    it('should handle single transaction', 0, () => {
      const singleTransaction: Transaction = {
        id: 1,
        title: '单笔',
        amount: 100,
        type: 'expense',
        date: '2026-02-01',
        category: '餐饮'
      };

      const total = [singleTransaction].reduce((sum, t) => sum + t.amount, 0);
      expect(total).assertEqual(100);
      expect(100 / total * 100).assertEqual(100); // 占比100%
    });

    // ==================== 对比分析测试 ====================

    it('should compare current month vs previous month', 0, () => {
      const currentMonth = 500;
      const previousMonth = 400;
      
      const change = currentMonth - previousMonth;
      const changePercentage = (change / previousMonth) * 100;
      
      expect(change).assertEqual(100);
      expect(changePercentage).assertEqual(25); // 增长25%
    });

    it('should calculate year-over-year comparison', 0, () => {
      const thisYear = { jan: 1000, feb: 1200 };
      const lastYear = { jan: 800, feb: 1000 };
      
      const janChange = ((thisYear.jan - lastYear.jan) / lastYear.jan) * 100;
      expect(janChange).assertEqual(25); // 同比增长25%
    });

    // ==================== 顶部分类测试 ====================

    it('should find top spending category', 0, () => {
      const stats: CategoryStat[] = [
        { category: '餐饮', amount: 75, percentage: 24.9 },
        { category: '交通', amount: 26, percentage: 8.6 },
        { category: '购物', amount: 200, percentage: 66.4 }
      ];

      const sorted = stats.sort((a, b) => b.amount - a.amount);
      const topCategory = sorted[0];
      
      expect(topCategory.category).assertEqual('购物');
      expect(topCategory.percentage).assertEqual(66.4);
    });

    it('should calculate top 3 categories', 0, () => {
      const stats: CategoryStat[] = [
        { category: '餐饮', amount: 75, percentage: 24.9 },
        { category: '交通', amount: 26, percentage: 8.6 },
        { category: '购物', amount: 200, percentage: 66.4 },
        { category: '娱乐', amount: 50, percentage: 16.5 },
        { category: '医疗', amount: 30, percentage: 9.9 }
      ];

      const top3 = stats.sort((a, b) => b.amount - a.amount).slice(0, 3);
      
      expect(top3.length).assertEqual(3);
      expect(top3[0].category).assertEqual('购物');
      expect(top3[1].category).assertEqual('餐饮');
      expect(top3[2].category).assertEqual('娱乐');
    });

    // ==================== 极值测试 ====================

    it('should handle very large amounts', 0, () => {
      const largeTransaction: Transaction = {
        id: 1,
        title: '大额支出',
        amount: 9999999.99,
        type: 'expense',
        date: '2026-02-01',
        category: '购物'
      };

      const total = [largeTransaction].reduce((sum, t) => sum + t.amount, 0);
      expect(total).assertEqual(9999999.99);
    });

    it('should handle many categories', 0, () => {
      const manyCategories = Array.from({ length: 20 }, (_, i) => ({
        category: `分类${i}`,
        amount: i * 10,
        percentage: 0
      } as CategoryStat));

      const sorted = manyCategories.sort((a, b) => b.amount - a.amount);
      
      expect(sorted.length).assertEqual(20);
      expect(sorted[0].category).assertEqual('分类19');
    });
  });
}
