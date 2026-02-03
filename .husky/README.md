# Git Hooks Configuration

本项目使用 Husky 管理 Git Hooks，确保代码质量。

## 🪝 已配置的 Hooks

### 1. pre-commit

**触发时机：** 执行 `git commit` 时

**功能：**
- 检查代码中是否包含 `console.log`
- 统计 TODO/FIXME 标记数量
- 运行代码格式化检查（如果 hvigorw 可用）

### 2. commit-msg

**触发时机：** 提交信息编辑完成后

**功能：**
- 验证提交信息格式
- 确保提交信息符合规范：`<type>(<scope>): <description>`

### 3. pre-push

**触发时机：** 执行 `git push` 时

**功能：**
- 检查是否有未提交的更改
- 运行所有单元测试
- 验证分支是否与远程同步

## 📝 提交信息规范

### 格式
```
<type>(<scope>): <description>

[可选的详细描述]

[可选的Footer]
```

### 示例
```
feat: add voice recording for transactions

Implement voice input feature to allow users
record transactions using voice commands.

Closes #123
```

### 类型说明

| 类型 | 说明 |
|------|------|
| feat | 新功能 |
| fix | 修复bug |
| docs | 文档更新 |
| style | 代码格式（不影响代码运行的变动）|
| refactor | 重构（既不是新增功能，也不是修复bug）|
| perf | 性能优化 |
| test | 增加测试 |
| chore | 构建过程或辅助工具的变动 |
| ci | CI/CD配置变动 |
| build | 构建系统变动 |

## 🔧 手动触发检查

如果需要跳过 hooks（不推荐）：

```bash
# 跳过 pre-commit
git commit -m "your message" --no-verify

# 跳过 pre-push
git push --no-verify
```

## 🛠️ 修改 Hooks

Hooks 文件位于 `.husky/` 目录：
- `.husky/pre-commit` - 提交前检查
- `.husky/commit-msg` - 提交信息验证
- `.husky/pre-push` - 推送前检查

修改后需要重新设置执行权限（Linux/Mac）：
```bash
chmod +x .husky/*
```

## ⚠️ 常见问题

### Windows 上 hooks 不执行

**原因：** Windows 的 Git Bash 或 PowerShell 可能没有执行权限

**解决：**
1. 使用 Git Bash 运行命令
2. 确保 hooks 文件使用 LF 换行符
3. 在 Windows 上，确保 Git 配置了正确的 shell

### 跳过所有检查

```bash
git commit --no-verify -m "your message"
```

⚠️ **不推荐在生产代码中使用！**

## 📚 参考

- [Husky 文档](https://typicode.github.io/husky/)
- [Git Hooks 文档](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)
