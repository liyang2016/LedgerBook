# LedgerBook

一款基于HarmonyOS的智能记账应用，帮助您轻松管理个人财务。

## ✨ 功能特性

- 📝 **快速记账** - 支持收入/支出记录，自定义分类
- 📊 **统计分析** - 直观的图表展示收支趋势
- 🏷️ **分类管理** - 灵活的收入/支出分类体系
- 💾 **本地存储** - 数据安全存储在本地设备
- 🔍 **智能筛选** - 按类型、日期、分类快速查找

## 🛠️ 技术栈

- **平台**: HarmonyOS API 12
- **语言**: ArkTS
- **构建工具**: Hvigor 5.1.1
- **测试框架**: @ohos/hypium 1.0.24

## 📦 项目结构

```
LedgerBook/
├── entry/src/main/ets/
│   ├── pages/              # 页面
│   │   ├── Index.ets              # 首页（账单列表）
│   │   ├── StatisticsPage.ets     # 统计页面
│   │   ├── CategoryManager.ets    # 分类管理
│   │   └── Profile.ets            # 个人中心
│   ├── components/         # 组件
│   │   ├── BottomNavBar.ets        # 底部导航
│   │   ├── AddTransactionDialog.ets  # 添加账单弹窗
│   │   └── EditTransactionDialog.ets # 编辑账单弹窗
│   └── services/           # 服务
│       └── DataManager.ets         # 数据管理
└── AppScope/              # 应用全局配置
```

## 🚀 快速开始

### 环境要求
- DevEco Studio 5.0+
- Node.js 16+
- HarmonyOS SDK API 12

### 安装依赖
```bash
ohpm install
```

### 运行项目
1. 使用 DevEco Studio 打开项目
2. 连接模拟器或真机设备
3. 点击 Run 按钮启动

## 🔧 开发命令

```bash
# 代码检查
npm run lint

# 运行测试
npm run test

# 构建HAP包
npm run build

# 完整验证（检查+测试+构建）
npm run verify
```

## 📝 待办事项

- [ ] 添加语音记账功能
- [ ] 支持云端数据同步
- [ ] 添加预算提醒功能
- [ ] 支持导出Excel报表
- [ ] 添加深色模式

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 👨‍💻 作者

[@liyang2016](https://github.com/liyang2016)

---

⭐ 如果这个项目对您有帮助，请给个 Star！
