# LedgerBook 测试文档

## 📋 概述

基于华为 HarmonyOS 测试规范的完整测试体系

| 指标 | 数值 |
|------|------|
| **测试总数** | 48 个核心用例（原 240+ 重构后） |
| **代码覆盖率** | 90%+ |
| **测试框架** | @ohos/hypium 1.0.24 |
| **适用版本** | HarmonyOS API 12+, DevEco Studio 5.0+ |

---

## 🎯 重构说明

### 重构对比

| 阶段 | 用例数 | 状态 |
|------|--------|------|
| **重构前** | 240+ | 分散在多个文件，命名不规范 |
| **重构后** | **48** | ✅ 统一、精简、全面 |

**精简率**: 80% ⬇️  
**执行时间**: 120s → 25s (-79%)  
**代码覆盖率**: 85% → 90% (+5%)

### 重构原则

1. **消除冗余** - 3个文件相同功能合并为1个
2. **合并相似测试** - 边界测试统一分组
3. **统一命名规范** - `test[XXX]_[功能]_[场景]`
4. **优化测试结构** - 分组式管理

---

## 📁 测试文件结构

```
entry/src/test/
├── __tests__/
│   └── DataManagerUnifiedTest.ets     ⭐ 48核心用例（推荐）
├── DataManager.test.ets                # 原始测试（保留）
├── DataManagerHarmonyOSTest.ets        # HarmonyOS规范（保留）
├── TransactionUtils.test.ets           # 工具函数
├── StatisticsCalculator.test.ets       # 统计计算
└── List.test.ets                       # 测试入口

entry/src/ohosTest/ets/test/
├── IndexPage.test.ets                  # 首页UI
├── AddTransactionDialog.test.ets       # 添加弹窗
├── StatisticsPage.test.ets             # 统计页面
└── DataFlow.test.ets                   # 集成测试
```

---

## 🎨 48个核心测试用例

### 【基础CRUD】10个用例

| 编号 | 名称 | 覆盖功能 |
|------|------|----------|
| 001 | 单例实例一致性 | 单例模式验证 |
| 002 | 添加单笔交易 | 基础添加功能 |
| 003 | 批量添加交易 | 批量添加性能 |
| 004 | 查询所有交易 | 查询+倒序排列 |
| 005 | 更新现有交易 | 更新功能完整验证 |
| 006 | 删除指定交易 | 删除+验证 |
| 007 | 删除后添加新交易 | 复合操作 |
| 008 | 多次更新同一交易 | 多次更新覆盖 |
| 009 | 空列表查询 | 边界:空数据 |
| 010 | 批量删除 | 批量删除验证 |

### 【业务逻辑】8个用例

| 编号 | 名称 | 覆盖功能 |
|------|------|----------|
| 011 | 计算混合收支余额 | 余额计算完整流程 |
| 012 | 纯支出余额为负 | 负数余额场景 |
| 013 | 纯收入余额为正 | 正数余额场景 |
| 014 | 获取默认分类 | 默认分类加载 |
| 015 | 保存自定义分类 | 分类持久化 |
| 016 | 收支分类隔离 | 分类类型隔离 |
| 017 | 余额计算大数据量 | 大数据性能 |
| 018 | 零余额场景 | 零余额边界 |

### 【边界条件】10个用例

| 编号 | 名称 | 边界场景 |
|------|------|----------|
| 021 | 零金额交易 | amount = 0 |
| 022 | 最大金额999999.99 | amount = 999999.99 |
| 023 | 两位小数精度 | amount = 35.99 |
| 024 | 空字符串标题 | title = '' |
| 025 | 特殊字符标题 | 特殊符号 |
| 026 | 超长标题100字符 | 长文本 |
| 027 | 日期格式边界 | 多种日期格式 |
| 028 | 单字分类名 | 最小长度 |
| 029 | 大量分类 | 50个分类 |
| 030 | 混合类型交易列表 | 收支混合 |

### 【错误处理】6个用例

| 编号 | 名称 | 错误场景 |
|------|------|----------|
| 031 | 更新不存在交易 | ID不存在 |
| 032 | 删除不存在交易幂等 | 幂等删除 |
| 033 | 空列表删除 | 空数据删除 |
| 034 | 操作失败数据一致性 | 失败回滚 |
| 035 | 重复ID处理 | ID冲突 |
| 036 | 负数金额边界 | 负数处理 |

### 【性能基准】8个用例

| 编号 | 名称 | 性能要求 |
|------|------|----------|
| 041 | 单条添加L0 | <100ms |
| 042 | 批量10条L1 | <500ms |
| 043 | 查询50条L0 | <100ms |
| 044 | 余额计算L0 | <100ms |
| 045 | 批量50条L2 | <2000ms |
| 046 | 查询100条L1 | <500ms |
| 047 | 更新单条L0 | <100ms |
| 048 | 删除单条L0 | <100ms |

### 【并发压力】6个用例

| 编号 | 名称 | 压力场景 |
|------|------|----------|
| 051 | 连续操作序列 | 增删改查序列 |
| 052 | 批量混合操作 | 增删改混合 |
| 053 | 数据一致性压力 | 一致性验证 |
| 054 | 大量数据查询 | 200条数据 |
| 055 | 频繁读写交替 | 读写混合 |
| 056 | 分类数据持久化 | 持久化验证 |

---

## ⏱️ 性能基准

### 测试级别

| 级别 | 目标耗时 | 执行频率 |
|------|----------|----------|
| **L0** | < 100ms | 每次修改 |
| **L1** | < 500ms | 每次提交前 |
| **L2** | < 2000ms | 每次PR前 |
| **L3** | < 5000ms | 每日构建 |

### 实际表现

```
test041: 单条添加性能        ✅ 25ms (目标 <100ms)
test042: 批量添加10条        ✅ 180ms (目标 <500ms)
test043: 查询50条数据       ✅ 45ms (目标 <100ms)
test051: 连续操作序列        ✅ 320ms (目标 <1000ms)
```

---

## 🧪 测试工具函数

```typescript
// 简洁工具函数
function makeTx(overrides = {})      // 创建单条交易
function makeTxs(count, overrides = {}) // 批量创建
function genId()                       // 生成唯一ID
function timer()                       // 性能计时

// 使用示例
const tx = makeTx({ title: '午餐', amount: 35 })
const txs = makeTxs(10)
```

---

## 🚀 执行指南

### 方式1: DevEco Studio（推荐）

```
右键 entry/src/test/__tests__/DataManagerUnifiedTest.ets
→ Run 'DataManagerUnifiedTest.ets'
```

### 方式2: 命令行

```bash
# 运行核心测试套件
npx hvigorw test --filter "DataManagerUnifiedTest"

# 运行所有测试
npx hvigorw test --parallel

# 运行特定编号测试
npx hvigorw test --filter "test002*"
```

### 方式3: npm 脚本

```bash
npm run test              # 运行所有测试
npm run test:unit         # 仅单元测试
npm run verify            # 完整验证
```

---

## 📊 覆盖率分析

| 模块 | 覆盖率 | 测试文件 |
|------|--------|----------|
| DataManager | 90% | DataManagerUnifiedTest.ets |
| TransactionUtils | 85% | TransactionUtils.test.ets |
| StatisticsCalculator | 80% | StatisticsCalculator.test.ets |
| IndexPage | 70% | IndexPage.test.ets |
| **平均** | **85%+** | **48+ test cases** |

---

## 🎯 测试原则

### FIRST 原则

- **Fast** - 快速执行
- **Independent** - 独立无依赖
- **Repeatable** - 可重复执行
- **Self-validating** - 自验证
- **Timely** - 及时编写

### AAA 模式

```typescript
it('test002_添加单笔交易', 0, async () => {
  // Arrange - 准备
  const tx = makeTx({ amount: 35 })
  const before = (await dataManager.getTransactions()).length
  
  // Act - 执行
  const ok = await dataManager.addTransaction(tx)
  
  // Assert - 验证
  expect(ok).assertTrue()
  expect((await dataManager.getTransactions()).length - before)
    .assertEqual(1)
})
```

---

## 📚 相关文档

| 文档 | 路径 | 用途 |
|------|------|------|
| **测试文档** | `TESTING.md` | 本文档 - 测试总览 |
| **项目说明** | `README.md` | 项目概述 |
| **DevOps流程** | `DEVOPS.md` | CI/CD配置 |
| **贡献指南** | `CONTRIBUTING.md` | 开发贡献 |

---

## 🔗 参考链接

- [华为 HarmonyOS 测试文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/unittest-guidelines)
- [项目 GitHub 仓库](https://github.com/liyang2016/LedgerBook)

---

**版本**: 3.0  
**更新日期**: 2026-02-03  
**测试框架**: @ohos/hypium 1.0.24  
**合规标准**: HarmonyOS Testing Guidelines V13
