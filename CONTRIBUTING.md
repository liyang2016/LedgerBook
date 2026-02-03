# 贡献指南

感谢您考虑为 LedgerBook 做出贡献！

## 📋 开发流程

### 1. Fork 和 Clone

```bash
# Fork 仓库（在GitHub上操作）
# 然后克隆到本地
git clone https://github.com/YOUR_USERNAME/LedgerBook.git
cd LedgerBook
```

### 2. 创建功能分支

```bash
# 从 dev 分支创建功能分支
git checkout -b feature/your-feature-name dev
```

### 3. 开发代码

- 遵循现有的代码风格
- 为新功能编写单元测试
- 确保所有测试通过
- 不要留下 `console.log` 等调试代码

### 4. 提交代码

提交信息必须符合规范：

```bash
# 格式: <type>(<scope>): <description>
git commit -m "feat: add search functionality"

# 其他示例:
git commit -m "fix(api): resolve timeout issue"
git commit -m "docs: update README"
git commit -m "test: add unit tests for DataManager"
```

**支持的类型：**
- `feat`: 新功能
- `fix`: 修复bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具相关
- `ci`: CI/CD配置
- `build`: 构建系统

### 5. 保持分支同步

```bash
# 拉取最新的 dev 分支
git fetch origin
git rebase origin/dev
```

### 6. 推送并创建 PR

```bash
git push -u origin feature/your-feature-name
```

然后在 GitHub 上创建 Pull Request 到 `dev` 分支。

## 🔄 代码审查流程

1. 创建 Pull Request 后，CI 会自动运行检查
2. 需要至少 1 个审批人审查代码
3. 所有检查必须通过
4. 审批人批准后，可以合并到 `dev` 分支

## 🧪 本地测试

```bash
# 安装依赖
ohpm install

# 运行代码检查
hvigorw code-lint

# 运行单元测试
hvigorw test

# 构建 HAP 包
hvigorw assembleHap
```

## 📋 PR 检查清单

创建 PR 前请确认：

- [ ] 代码可以正常编译
- [ ] 所有单元测试通过
- [ ] 代码风格符合规范
- [ ] 没有 `console.log` 等调试代码
- [ ] 提交信息符合规范
- [ ] 相关文档已更新
- [ ] PR 描述清楚说明改动内容

## 🐛 报告 Bug

如果您发现 Bug，请创建 Issue 并提供：

1. Bug 描述
2. 复现步骤
3. 期望行为
4. 实际行为
5. 环境信息（HarmonyOS 版本、设备型号等）

## 💡 建议新功能

建议新功能请创建 Issue 并说明：

1. 功能描述
2. 使用场景
3. 可能的实现方案（可选）

## 📄 许可证

通过贡献代码，您同意将代码在 MIT 许可证下授权。

## ❓ 获取帮助

- 查看 [README.md](./README.md)
- 创建 GitHub Issue
- 发送邮件至项目维护者

感谢您的贡献！🎉
