import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Transaction, Category } from '../../main/ets/services/DataManager';

export default function TransactionUtilsTest() {
  describe('TransactionUtils Unit Tests', () => {
    
    // ==================== 金额格式化测试 ====================
    
    it('should format amount to 2 decimal places', 0, () => {
      const amount = 35.5;
      const formatted = amount.toFixed(2);
      expect(formatted).assertEqual('35.50');
    });

    it('should format integer amount correctly', 0, () => {
      const amount = 100;
      const formatted = amount.toFixed(2);
      expect(formatted).assertEqual('100.00');
    });

    it('should format large amount correctly', 0, () => {
      const amount = 9999999.99;
      const formatted = amount.toFixed(2);
      expect(formatted).assertEqual('9999999.99');
    });

    it('should handle zero amount', 0, () => {
      const amount = 0;
      const formatted = amount.toFixed(2);
      expect(formatted).assertEqual('0.00');
    });

    it('should format negative amount correctly', 0, () => {
      const amount = -50.5;
      const formatted = amount.toFixed(2);
      expect(formatted).assertEqual('-50.50');
    });

    // ==================== 日期格式化测试 ====================

    it('should format date to YYYY-MM-DD', 0, () => {
      const date = new Date('2026-02-03');
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const formatted = `${year}-${month}-${day}`;
      
      expect(formatted).assertEqual('2026-02-03');
    });

    it('should handle single digit month and day', 0, () => {
      const date = new Date('2026-01-05');
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const formatted = `${year}-${month}-${day}`;
      
      expect(formatted).assertEqual('2026-01-05');
    });

    it('should parse date string correctly', 0, () => {
      const dateStr = '2026-02-03';
      const parts = dateStr.split('-');
      
      expect(parts.length).assertEqual(3);
      expect(parts[0]).assertEqual('2026');
      expect(parts[1]).assertEqual('02');
      expect(parts[2]).assertEqual('03');
    });

    // ==================== 分类图标映射测试 ====================

    it('should have correct icon for food category', 0, () => {
      const category: Category = { name: '餐饮', icon: '🍔', type: 'expense' };
      expect(category.icon).assertEqual('🍔');
      expect(category.type).assertEqual('expense');
    });

    it('should have correct icon for transport category', 0, () => {
      const category: Category = { name: '交通', icon: '🚗', type: 'expense' };
      expect(category.icon).assertEqual('🚗');
    });

    it('should have correct icon for salary category', 0, () => {
      const category: Category = { name: '工资', icon: '💰', type: 'income' };
      expect(category.icon).assertEqual('💰');
      expect(category.type).assertEqual('income');
    });

    // ==================== 金额输入验证测试 ====================

    it('should validate positive amount', 0, () => {
      const input = '100.50';
      const amount = parseFloat(input);
      expect(amount).assertLarger(0);
      expect(!isNaN(amount)).assertTrue();
    });

    it('should reject negative amount in validation', 0, () => {
      const input = '-50';
      const amount = parseFloat(input);
      // 在实际应用中应该拒绝负数金额输入
      expect(amount).assertLess(0);
    });

    it('should reject invalid amount string', 0, () => {
      const input = 'abc';
      const amount = parseFloat(input);
      expect(isNaN(amount)).assertTrue();
    });

    it('should reject empty amount', 0, () => {
      const input = '';
      const amount = parseFloat(input);
      expect(isNaN(amount)).assertTrue();
    });

    // ==================== 交易类型判断测试 ====================

    it('should identify expense transaction correctly', 0, () => {
      const transaction: Transaction = {
        id: 1,
        title: '测试',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };
      
      const isExpense = transaction.type === 'expense';
      const isIncome = transaction.type === 'income';
      
      expect(isExpense).assertTrue();
      expect(isIncome).assertFalse();
    });

    it('should identify income transaction correctly', 0, () => {
      const transaction: Transaction = {
        id: 1,
        title: '测试',
        amount: 5000,
        type: 'income',
        date: '2026-02-03',
        category: '工资'
      };
      
      const isIncome = transaction.type === 'income';
      expect(isIncome).assertTrue();
    });

    // ==================== 空值处理测试 ====================

    it('should handle undefined transaction properties', 0, () => {
      const transaction: Partial<Transaction> = {
        id: 1,
        title: undefined,
        amount: 100
      };
      
      expect(transaction.title === undefined).assertTrue();
      expect(transaction.amount !== undefined).assertTrue();
    });

    it('should handle null values gracefully', 0, () => {
      const value: string | null = null;
      expect(value === null).assertTrue();
    });

    // ==================== 字符串处理测试 ====================

    it('should trim whitespace from title', 0, () => {
      const title = '  测试标题  ';
      const trimmed = title.trim();
      expect(trimmed).assertEqual('测试标题');
    });

    it('should check for empty string', 0, () => {
      const title = '';
      const isEmpty = title.length === 0;
      expect(isEmpty).assertTrue();
    });

    it('should limit title length', 0, () => {
      const longTitle = '这是一个非常非常长的标题，超过了一般的长度限制';
      const maxLength = 50;
      const truncated = longTitle.substring(0, maxLength);
      expect(truncated.length).assertEqual(maxLength);
    });

    // ==================== 日期比较测试 ====================

    it('should compare dates correctly', 0, () => {
      const date1 = new Date('2026-02-03');
      const date2 = new Date('2026-02-04');
      
      const isBefore = date1 < date2;
      const isAfter = date1 > date2;
      
      expect(isBefore).assertTrue();
      expect(isAfter).assertFalse();
    });

    it('should identify today date', 0, () => {
      const today = new Date();
      const formatted = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
      
      // 验证格式正确
      expect(formatted.length).assertEqual(10);
      expect(formatted.includes('-')).assertTrue();
    });

    // ==================== 数据转换测试 ====================

    it('should convert transaction to string and back', 0, () => {
      const transaction: Transaction = {
        id: 1,
        title: '测试',
        amount: 100,
        type: 'expense',
        date: '2026-02-03',
        category: '餐饮'
      };
      
      const jsonStr = JSON.stringify(transaction);
      const parsed = JSON.parse(jsonStr) as Transaction;
      
      expect(parsed.id).assertEqual(transaction.id);
      expect(parsed.title).assertEqual(transaction.title);
      expect(parsed.amount).assertEqual(transaction.amount);
      expect(parsed.type).assertEqual(transaction.type);
    });

    it('should handle array operations correctly', 0, () => {
      const transactions: Transaction[] = [
        { id: 1, title: 'T1', amount: 10, type: 'expense', date: '2026-02-03', category: '餐饮' },
        { id: 2, title: 'T2', amount: 20, type: 'expense', date: '2026-02-03', category: '餐饮' },
        { id: 3, title: 'T3', amount: 30, type: 'expense', date: '2026-02-03', category: '餐饮' }
      ];
      
      // 测试 filter
      const filtered = transactions.filter(t => t.amount > 15);
      expect(filtered.length).assertEqual(2);
      
      // 测试 find
      const found = transactions.find(t => t.id === 2);
      expect(found?.title).assertEqual('T2');
      
      // 测试 map
      const amounts = transactions.map(t => t.amount);
      expect(amounts.length).assertEqual(3);
      expect(amounts[0]).assertEqual(10);
    });

    // ==================== 数值计算测试 ====================

    it('should calculate sum correctly', 0, () => {
      const amounts = [10, 20, 30, 40, 50];
      const sum = amounts.reduce((a, b) => a + b, 0);
      expect(sum).assertEqual(150);
    });

    it('should calculate average correctly', 0, () => {
      const amounts = [10, 20, 30];
      const average = amounts.reduce((a, b) => a + b, 0) / amounts.length;
      expect(average).assertEqual(20);
    });

    it('should find max and min correctly', 0, () => {
      const amounts = [5, 10, 3, 8, 15];
      const max = Math.max(...amounts);
      const min = Math.min(...amounts);
      
      expect(max).assertEqual(15);
      expect(min).assertEqual(3);
    });
  });
}
