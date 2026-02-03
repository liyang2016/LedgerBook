# HarmonyOS 测试执行指南

基于华为官方测试规范的 LedgerBook 测试套件

## 📋 测试架构

### 测试级别（HarmonyOS 规范）

```
L0 (Level 0) - 快速单元测试
├─ 目标: <100ms
├─ 范围: 单个函数/方法
└─ 频率: 每次代码修改后

L1 (Level 1) - 完整单元测试
├─ 目标: <500ms
├─ 范围: 完整功能模块
└─ 频率: 每次提交前

L2 (Level 2) - 集成测试
├─ 目标: <2000ms
├─ 范围: 多模块协作
└─ 频率: 每次 PR 前

L3 (Level 3) - 系统测试
├─ 目标: <5000ms
├─ 范围: 完整用户场景
└─ 频率: 每日构建
```

### 测试分类

| 类型 | 文件数 | 用例数 | 位置 |
|------|--------|--------|------|
| 单元测试 | 4 | 80+ | `entry/src/test/` |
| UI 测试 | 4 | 95+ | `entry/src/ohosTest/` |
| 集成测试 | 1 | 15+ | `entry/src/ohosTest/` |
| **总计** | **9** | **190+** | - |

## 🚀 快速开始

### 方式 1: DevEco Studio（推荐）

#### 步骤 1: 导入项目
1. 打开 DevEco Studio 5.0+
2. `File` → `Open` → 选择 `D:\code\LedgerBook`
3. 等待项目同步完成

#### 步骤 2: 运行测试

**运行单个测试文件:**
```
右键点击 entry/src/test/DataManager.test.ets
→ Run 'DataManager.test.ets'
```

**运行所有单元测试:**
```
右键点击 entry/src/test 目录
→ Run 'Tests in test'
```

**运行所有 UI 测试:**
```
右键点击 entry/src/ohosTest 目录
→ Run 'Tests in ohosTest'
```

**运行指定测试级别:**
```
# L0 快速测试（DataManagerHarmonyOSTest.ets）
右键 → Run 'DataManagerHarmonyOSTest.ets'
选择 "L0 - 快速单元测试" 分组
```

### 方式 2: 命令行

#### 前置条件
```bash
# 安装 HarmonyOS CLI 工具
npm install -g @ohos/hvigor

# 或者使用 npx（推荐）
npx hvigorw <command>
```

#### 运行所有测试
```bash
cd D:\code\LedgerBook

# 运行全部测试
npx hvigorw test --parallel

# 仅单元测试
npx hvigorw test --module entry --target LocalUnit

# 仅 UI 测试
npx hvigorw test --module entry --target OhosTest
```

#### 运行特定测试级别
```bash
# L0 快速测试（使用过滤器）
npx hvigorw test --filter "L0-*"

# L1 完整测试
npx hvigorw test --filter "L1-*"

# L2 集成测试
npx hvigorw test --filter "L2-*"

# L3 系统测试
npx hvigorw test --filter "L3-*"
```

### 方式 3: npm 脚本

```bash
# 运行所有测试
npm run test

# 仅单元测试
npm run test:unit

# 仅 UI 测试
npm run test:ui

# 生成测试报告
npm run test:report

# 完整验证
npm run verify
```

## 📊 测试报告

### 生成报告

```bash
# 方式 1: 使用脚本
bash scripts/generate-test-report.sh

# 方式 2: npm 命令
npm run test:report
```

### 报告内容

生成的报告包含：
- ✅ 测试执行摘要
- ✅ 各测试级别详情
- ✅ 代码覆盖率分析
- ✅ 性能基准数据
- ✅ 测试日志
- ✅ 结论和建议

报告位置: `test-reports/test-report-YYYYMMDD_HHMMSS.md`

## 🎯 测试规范

### 命名规范

```typescript
// 测试文件名
[ModuleName]Test.ets          // 例如: DataManagerTest.ets
[ModuleName]HarmonyOSTest.ets // HarmonyOS 规范测试

// 测试用例命名
L0-XX: [简短描述]            // L0 级别测试
L1-XX: [功能]测试             // L1 级别测试
L2-XX: [流程]流程             // L2 级别测试
L3-XX: [场景]压力测试         // L3 级别测试
边界-XX: [边界条件]           // 边界测试
错误-XX: [错误类型]           // 错误处理测试
```

### 断言规范

```typescript
// ✅ 推荐方式
expect(actual).assertEqual(expected);
expect(actual).assertTrue();
expect(actual).assertNotNull();
expect(duration).assertLess(500);

// ✅ 使用日志
import { hilog } from '@kit.PerformanceAnalysisKit';
hilog.info(0x0000, 'TestTag', '测试消息: %{public}s', variable);
```

### 性能基准

```typescript
// L0 测试: <100ms
it('L0-01: 单例模式验证', 0, () => {
  const start = Date.now();
  // 测试逻辑
  const duration = Date.now() - start;
  expect(duration).assertLess(100);
});

// L1 测试: <500ms
it('L1-01: 添加单笔交易', 0, async () => {
  const start = Date.now();
  // 测试逻辑
  const duration = Date.now() - start;
  expect(duration).assertLess(500);
});
```

## 🔧 高级配置

### 配置测试超时

```typescript
// 在测试用例中设置超时（毫秒）
it('L3-01: 大数据量测试', 10000, async () => {
  // 此测试有 10 秒超时
});
```

### 并行测试配置

```bash
# 启用并行测试
npx hvigorw test --parallel

# 在 package.json 中配置
{
  "scripts": {
    "test": "hvigorw test --parallel"
  }
}
```

### 覆盖率配置

```bash
# 运行测试并生成覆盖率报告
npx hvigorw test --coverage

# 查看覆盖率报告
open entry/build/test-results/coverage/index.html
```

## 🐛 故障排除

### 常见问题 1: 测试无法启动

**症状**: 点击运行后没有反应

**解决**:
```bash
# 1. 检查 DevEco Studio 版本
devEcoStudio --version  # 需要 5.0+

# 2. 同步项目
File → Sync Project with Gradle Files

# 3. 清理并重建
Build → Clean Project → Rebuild Project

# 4. 重启 IDE
File → Invalidate Caches / Restart
```

### 常见问题 2: 测试超时

**症状**: 测试运行很长时间后失败

**解决**:
```typescript
// 增加超时时间
it('慢速测试', 10000, async () => {
  // 此测试有 10 秒超时
});
```

### 常见问题 3: 上下文初始化失败

**症状**: `getContext(this)` 返回 null

**解决**:
```typescript
// 确保正确获取上下文
import { Context } from '@ohos.abilityAccessCtrl';

beforeAll(async () => {
  const context: Context = getContext(this) as Context;
  await dataManager.init(context);
});
```

### 常见问题 4: 权限错误

**症状**: "Permission denied"

**解决**:
```json
// entry/src/main/module.json5
{
  "requestPermissions": [
    {
      "name": "ohos.permission.READ_USER_STORAGE"
    },
    {
      "name": "ohos.permission.WRITE_USER_STORAGE"
    }
  ]
}
```

## 📱 真机测试

### 连接真机

1. **启用开发者模式**
   ```
   设置 → 关于手机 → 连续点击版本号 7 次
   ```

2. **启用 USB 调试**
   ```
   设置 → 系统和更新 → 开发人员选项 → USB 调试
   ```

3. **连接设备**
   ```
   USB 线连接手机和电脑
   在 DevEco Studio 中选择设备
   ```

### 运行真机测试

```bash
# 选择真机设备
# 工具栏 → 设备下拉框 → 选择真机

# 运行测试
右键测试文件 → Run
```

## 🎉 最佳实践

### 1. 测试驱动开发 (TDD)

```
1. 编写测试用例（先写测试）
2. 运行测试（应该失败）
3. 编写实现代码
4. 运行测试（应该通过）
5. 重构代码
6. 重复
```

### 2. 持续测试

```bash
# 每次修改后运行 L0 测试
# 每次提交前运行 L1 测试
# 每次 PR 前运行全部测试
```

### 3. 测试金字塔

```
    /\
   /  \     E2E 测试 (L3)
  /____\
 /      \   集成测试 (L2)
/________\
            单元测试 (L1/L0)
```

### 4. 覆盖率目标

```
最低: 60%
推荐: 80%
优秀: 90%+
核心模块: 95%+
```

## 📚 相关文档

- [TEST_GUIDE.md](./TEST_GUIDE.md) - 测试编写指南
- [TEST_REPORT.md](./TEST_REPORT.md) - 测试报告示例
- [DEVOPS.md](./DEVOPS.md) - DevOps 流程
- [CONTRIBUTING.md](./CONTRIBUTING.md) - 贡献指南

## 🔗 参考链接

- [HarmonyOS 测试官方文档](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V13/app-testing-overview-V13)
- [Hypium 测试框架](https://gitee.com/openharmony/test_developer_test)
- [HarmonyOS 开发指南](https://developer.harmonyos.com/)

---

**版本**: 1.0  
**更新日期**: 2026-02-03  
**适用版本**: DevEco Studio 5.0+, HarmonyOS API 12
