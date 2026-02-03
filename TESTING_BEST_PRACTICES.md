# HarmonyOS 单元测试最佳实践总结

基于华为官方测试规范和实际项目经验

## 📋 测试命名规范

### 1. 测试文件名

```
✅ 推荐: [ModuleName]Test.ets
   示例: DataManagerTest.ets, IndexPageTest.ets

❌ 避免: test_data_manager.ets, dataManager.test.ts
```

### 2. 测试函数命名

```typescript
// ✅ 推荐格式: test0XX_[功能]_[场景]_[预期结果]
it('test001_singleton_instance_should_be_same', 0, () => {
  // 测试代码
});

// ✅ 替代格式: should_[预期结果]_when_[场景]
it('should_return_same_instance_when_getInstance_called_twice', 0, () => {
  // 测试代码
});

// ❌ 避免: test1, test_add, addTest
```

### 3. 测试编号体系

```
001-010: 基础功能测试（单例、初始化、基本CRUD）
011-020: 业务逻辑测试（计算、分类、统计）
021-030: 边界条件测试（空值、极值、特殊字符）
031-040: 错误处理测试（异常、错误输入、恢复）
041-050: 性能基准测试（响应时间、吞吐量）
051-060: 并发与压力测试（多线程、大数据量）
061-070: 集成测试（模块间交互）
071-080: 系统测试（完整流程）
```

## 🎯 测试设计原则

### 1. FIRST 原则

```typescript
// Fast - 快速执行（< 100ms）
it('test001_quick_operation', 0, () => {
  const start = Date.now();
  const result = quickFunction();
  expect(Date.now() - start).assertLess(100);
  expect(result).assertTrue();
});

// Independent - 独立无依赖
// ✅ 每个测试自己准备数据，自己清理
beforeEach(async () => {
  await dataManager.saveTransactions([]); // 清理
});

// Repeatable - 可重复执行
// ✅ 使用固定数据，不依赖外部状态
const testData = { id: 1001, amount: 100 }; // 固定ID

// Self-validating - 自验证
// ✅ 明确的断言，不手动检查
expect(result).assertEqual(expected); // 自动验证

// Timely - 及时编写
// ✅ 与功能代码一起提交
```

### 2. AAA 模式 (Arrange-Act-Assert)

```typescript
it('test002_add_transaction_should_success', 0, async () => {
  // Arrange - 准备
  const transaction = createTestTransaction({
    title: '午餐',
    amount: 35
  });
  const initialCount = (await dataManager.getTransactions()).length;
  
  // Act - 执行
  const result = await dataManager.addTransaction(transaction);
  const finalCount = (await dataManager.getTransactions()).length;
  
  // Assert - 验证
  expect(result).assertTrue();
  expect(finalCount - initialCount).assertEqual(1);
});
```

### 3. 一个测试一个断言

```typescript
// ❌ 不推荐: 一个测试多个场景
it('test_add_and_update', 0, async () => {
  // 添加测试
  // 更新测试
  // 删除测试
});

// ✅ 推荐: 拆分为独立测试
it('test002_add_transaction_should_success', 0, async () => { ... });
it('test003_update_transaction_should_modify_data', 0, async () => { ... });
it('test004_delete_transaction_should_remove_data', 0, async () => { ... });
```

## 📝 测试数据管理

### 1. 测试数据工厂

```typescript
/**
 * 测试数据生成器
 * 确保数据一致性
 */
class TestDataFactory {
  private static idCounter = 1;
  
  static generateId(): number {
    return Date.now() + (this.idCounter++);
  }
  
  static createTransaction(overrides: Partial<Transaction> = {}): Transaction {
    return {
      id: this.generateId(),
      title: '测试交易',
      amount: 100,
      type: 'expense',
      date: '2026-02-03',
      category: '餐饮',
      ...overrides
    };
  }
  
  static createTransactions(count: number): Transaction[] {
    return Array.from({ length: count }, (_, i) => 
      this.createTransaction({
        id: this.generateId(),
        title: `交易${i}`,
        amount: (i + 1) * 10
      })
    );
  }
}

// 使用
const transaction = TestDataFactory.createTransaction({ amount: 50 });
const transactions = TestDataFactory.createTransactions(10);
```

### 2. 测试数据清理

```typescript
describe('Test Suite', () => {
  beforeEach(async () => {
    // ✅ 每个测试前清理，确保独立
    await dataManager.saveTransactions([]);
    await resetTestEnvironment();
  });
  
  afterEach(async () => {
    // ✅ 每个测试后清理，避免副作用
    await dataManager.saveTransactions([]);
    await clearTestData();
  });
});
```

## ⏱️ 性能测试规范

### 1. 分级性能基准

```typescript
// L0 级别: < 100ms
it('test001_singleton_should_return_fast', 0, () => {
  const start = Date.now();
  DataManager.getInstance();
  const duration = Date.now() - start;
  expect(duration).assertLess(100);
});

// L1 级别: < 500ms
it('test011_add_transaction_should_complete_quickly', 0, async () => {
  const start = Date.now();
  await dataManager.addTransaction(createTestTransaction());
  const duration = Date.now() - start;
  expect(duration).assertLess(500);
});

// L2 级别: < 2000ms
it('test021_batch_add_should_handle_efficiently', 0, async () => {
  const transactions = TestDataFactory.createTransactions(10);
  const start = Date.now();
  
  for (const t of transactions) {
    await dataManager.addTransaction(t);
  }
  
  const duration = Date.now() - start;
  expect(duration).assertLess(2000);
});

// L3 级别: < 5000ms
it('test031_large_dataset_should_process_in_time', 0, async () => {
  const transactions = TestDataFactory.createTransactions(100);
  const start = Date.now();
  
  for (const t of transactions) {
    await dataManager.addTransaction(t);
  }
  
  const summary = await dataManager.calculateBalance();
  const duration = Date.now() - start;
  
  expect(duration).assertLess(5000);
});
```

### 2. 性能监控日志

```typescript
import { hilog } from '@kit.PerformanceAnalysisKit';

it('test041_performance_with_logging', 0, async () => {
  const start = Date.now();
  
  await dataManager.addTransaction(createTestTransaction());
  
  const duration = Date.now() - start;
  
  // 记录性能指标
  hilog.info(0x0000, 'PerformanceTest', 
    '操作耗时: %{public}d ms', 
    duration
  );
  
  expect(duration).assertLess(100);
});
```

## 🔍 断言最佳实践

### 1. 使用合适的断言方法

```typescript
// ✅ 相等断言
expect(actual).assertEqual(expected);

// ✅ 布尔断言
expect(isValid).assertTrue();
expect(isEmpty).assertFalse();

// ✅ 空值断言
expect(result).assertNull();
expect(result).assertNotNull();

// ✅ 范围断言
expect(count).assertLarger(0);
expect(count).assertLess(100);

// ✅ 包含断言
expect(text).assertContain('expected');

// ✅ 异常断言
try {
  await invalidOperation();
  expect(false).assertTrue(); // 应该抛出异常
} catch (err) {
  expect(err).assertNotNull();
}
```

### 2. 断言消息

```typescript
// ❌ 不推荐: 无消息
expect(result).assertEqual(expected);

// ✅ 推荐: 添加描述性消息（可选）
expect(result).assertEqual(expected);
// 或使用注释说明
// 验证计算结果符合预期
```

## 🧹 测试清理与隔离

### 1. 测试隔离原则

```typescript
describe('DataManager Test', () => {
  let dataManager: DataManager;
  let originalData: Transaction[];
  
  beforeAll(async () => {
    dataManager = DataManager.getInstance();
    // 备份原始数据
    originalData = await dataManager.getTransactions();
  });
  
  beforeEach(async () => {
    // 重置为干净状态
    await dataManager.saveTransactions([]);
  });
  
  afterEach(async () => {
    // 清理测试数据
    await dataManager.saveTransactions([]);
  });
  
  afterAll(async () => {
    // 恢复原始数据
    await dataManager.saveTransactions(originalData);
  });
});
```

### 2. Mock 与 Stub

```typescript
// 使用 Mock 隔离依赖
import { createMock } from './TestUtils';

const mockPreferences = createMock();
mockPreferences.mockReturnValue(Promise.resolve('[]'));

// 使用 Stub 替换实现
const originalGetTransactions = dataManager.getTransactions;
dataManager.getTransactions = async () => {
  return [createTestTransaction()];
};

// 测试后恢复
dataManager.getTransactions = originalGetTransactions;
```

## 🐛 错误处理测试

### 1. 异常测试

```typescript
it('test031_update_nonexistent_should_return_false', 0, async () => {
  const nonExistent = createTestTransaction({ id: 99999 });
  
  // 不应抛出异常
  const result = await dataManager.updateTransaction(nonExistent);
  
  expect(result).assertFalse();
});

it('test032_invalid_input_should_handle_gracefully', 0, async () => {
  // 测试非法输入处理
  const invalidData = null;
  
  try {
    await dataManager.addTransaction(invalidData as any);
    expect(false).assertTrue(); // 不应该执行到这里
  } catch (err) {
    // 验证错误被正确捕获
    expect(err).assertNotNull();
  }
});
```

### 2. 数据一致性测试

```typescript
it('test033_data_integrity_after_failure', 0, async () => {
  // 添加有效数据
  const validData = createTestTransaction({ id: 8888 });
  await dataManager.addTransaction(validData);
  const beforeCount = (await dataManager.getTransactions()).length;
  
  // 执行失败操作
  try {
    await dataManager.updateTransaction(createTestTransaction({ id: 99999 }));
  } catch (err) {
    // 忽略错误
  }
  
  // 验证数据完整性
  const afterCount = (await dataManager.getTransactions()).length;
  expect(afterCount).assertEqual(beforeCount);
});
```

## 📝 测试文档规范

### 1. 测试类注释

```typescript
/**
 * DataManager 单元测试 - 优化版
 * 
 * 测试范围:
 * - 基础CRUD操作
 * - 业务逻辑计算
 * - 边界条件处理
 * - 错误恢复机制
 * - 性能基准测试
 * 
 * 执行环境:
 * - DevEco Studio 5.0+
 * - HarmonyOS API 12
 * - @ohos/hypium 1.0.24
 * 
 * 维护记录:
 * 2026-02-03: 初始版本，基于华为测试规范
 */
export default function DataManagerOptimizedTest() {
  // 测试实现
}
```

### 2. 测试函数注释

```typescript
/**
 * test001: 单例模式验证
 * 
 * 前提条件:
 * - 系统正常运行
 * 
 * 操作步骤:
 * 1. 多次调用 DataManager.getInstance()
 * 
 * 预期结果:
 * - 所有调用返回同一实例引用
 * 
 * 性能要求:
 * - < 100ms
 */
it('test001_singleton_instance_should_be_same', 0, () => {
  // 测试代码
});
```

## 🚀 持续集成配置

### 1. Git Hooks

```bash
# .husky/pre-commit
#!/bin/sh

# 运行测试
echo "Running tests..."
npx hvigorw test --parallel

if [ $? -ne 0 ]; then
  echo "Tests failed! Commit aborted."
  exit 1
fi
```

### 2. GitHub Actions

```yaml
# .github/workflows/test.yml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: ohpm install
      
      - name: Run unit tests
        run: npx hvigorw test --module entry --target LocalUnit
      
      - name: Run UI tests
        run: npx hvigorw test --module entry --target OhosTest
```

## 📊 测试报告

### 1. 生成测试报告

```bash
# 运行测试并生成报告
bash scripts/generate-test-report.sh

# 或使用 npm
npm run test:report
```

### 2. 报告内容

```markdown
# 测试报告

## 统计
- 总测试数: 190+
- 通过率: 100%
- 代码覆盖率: 85%+
- 执行时间: 45s

## 分级统计
- L0 (快速): 30+ tests, 100% passed
- L1 (完整): 50+ tests, 100% passed
- L2 (集成): 20+ tests, 100% passed
- L3 (系统): 15+ tests, 100% passed

## 性能基准
- 单条添加: < 100ms ✅
- 批量添加(10条): < 500ms ✅
- 查询(100条): < 100ms ✅
- 计算余额: < 50ms ✅

## 结论
所有测试通过，代码质量符合发布标准 ✅
```

## 🎉 最佳实践检查清单

### 提交前检查

- [ ] 所有测试通过（`npm run test`）
- [ ] 代码覆盖率 > 80%
- [ ] L0/L1 测试 < 500ms
- [ ] 无 console.log 调试代码
- [ ] 测试命名符合规范
- [ ] 测试数据已清理
- [ ] 测试文档已更新

### 代码审查检查

- [ ] AAA 模式正确应用
- [ ] 断言清晰明确
- [ ] 测试独立性保障
- [ ] 性能基准达标
- [ ] 边界条件覆盖
- [ ] 错误处理测试

---

## 📚 参考资源

- [HarmonyOS 单元测试指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/unittest-guidelines)
- [Hypium 测试框架文档](https://gitee.com/openharmony/test_developer_test)
- [JUnit 最佳实践](https://junit.org/junit5/docs/current/user-guide/)
- [测试驱动开发 (TDD)](https://martinfowler.com/bliki/TestDrivenDevelopment.html)

---

**版本**: 1.0  
**更新日期**: 2026-02-03  
**适用范围**: HarmonyOS API 12+, DevEco Studio 5.0+
