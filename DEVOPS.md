# DevOps 快速参考

## 🚀 完整 DevOps 流程已配置

### 1️⃣ GitHub Actions CI/CD (`.github/workflows/ci.yml`)

**自动触发条件：**
- Push 到 `main` 或 `dev` 分支
- Pull Request 到 `main` 分支

**包含任务：**

| 任务 | 说明 | 触发条件 |
|------|------|----------|
| Code Quality | 代码检查、格式验证 | 每次Push/PR |
| Unit Tests | 运行单元测试 | 代码检查通过后 |
| Build HAP | 构建应用包 | main分支Push |
| Security Scan | CodeQL安全扫描 | 每次Push/PR |
| Auto Release | 自动创建Release | main分支Push |

**查看运行状态：**
https://github.com/liyang2016/LedgerBook/actions

---

### 2️⃣ Git Hooks (`.husky/`)

| Hook | 触发时机 | 功能 |
|------|----------|------|
| pre-commit | git commit | 检查console.log、TODO、代码格式 |
| commit-msg | 编辑提交信息后 | 验证提交信息格式规范 |
| pre-push | git push | 检查未提交更改、运行测试、分支同步 |

**使用示例：**
```bash
# 正常提交（自动触发hooks）
git commit -m "feat: add search functionality"

# 跳过检查（不推荐）
git commit -m "quick fix" --no-verify
```

---

### 3️⃣ 分支保护规则

**需要手动在GitHub配置：**

访问：https://github.com/liyang2016/LedgerBook/settings/branches

**main 分支保护：**
- ✅ 必须通过PR合并
- ✅ 需要2个审批
- ✅ 要求状态检查通过
- ✅ 禁止强制推送
- ✅ 禁止删除

**dev 分支保护：**
- ✅ 必须通过PR合并
- ✅ 需要1个审批
- ✅ 要求状态检查通过

**详细配置步骤：** 参见 `.github/BRANCH_PROTECTION.md`

---

## 📝 开发工作流

```
1. Fork/Clone 仓库
   ↓
2. 从 dev 创建功能分支
   git checkout -b feature/name dev
   ↓
3. 开发代码
   ↓
4. 提交代码（自动触发hooks）
   git commit -m "feat: description"
   ↓
5. 推送到远程
   git push -u origin feature/name
   ↓
6. 创建 PR 到 dev
   ↓
7. CI自动运行检查
   ↓
8. 代码审查（1人）
   ↓
9. 合并到 dev
   ↓
10. 创建 PR 到 main
   ↓
11. CI自动运行 + 代码审查（2人）
   ↓
12. 合并到 main，自动发布
```

---

## 🔧 常用命令

### 本地验证
```bash
# 代码检查
hvigorw code-lint

# 运行测试
hvigorw test

# 构建HAP
hvigorw assembleHap

# 完整验证
hvigorw code-lint && hvigorw test && hvigorw assembleHap
```

### Git操作
```bash
# 创建功能分支
git checkout -b feature/name dev

# 提交代码（带hooks）
git commit -m "feat: description"

# 跳过hooks（不推荐）
git commit -m "message" --no-verify

# 推送
git push -u origin feature/name
```

### 提交信息规范
```bash
# 新功能
git commit -m "feat: add voice recording"

# 修复bug
git commit -m "fix(api): resolve timeout issue"

# 文档更新
git commit -m "docs: update README"

# 测试
git commit -m "test: add unit tests for DataManager"
```

---

## 📂 相关文件

| 文件 | 说明 |
|------|------|
| `.github/workflows/ci.yml` | CI/CD流水线配置 |
| `.github/BRANCH_PROTECTION.md` | 分支保护设置指南 |
| `.husky/pre-commit` | 提交前检查脚本 |
| `.husky/commit-msg` | 提交信息验证脚本 |
| `.husky/pre-push` | 推送前检查脚本 |
| `.husky/README.md` | Git Hooks说明文档 |
| `CONTRIBUTING.md` | 贡献指南 |
| `DEVOPS.md` | 本文档 |

---

## 🐛 故障排除

### CI检查失败
1. 查看详细日志：https://github.com/liyang2016/LedgerBook/actions
2. 本地复现：`hvigorw code-lint`
3. 修复问题后重新Push

### Hooks不执行（Windows）
1. 确保使用Git Bash而非PowerShell
2. 检查文件换行符为LF
3. 重新安装hooks：`git config core.hooksPath .husky`

### 无法推送到main
这是正常的！必须通过PR流程：
1. 推送到功能分支
2. 创建PR到dev
3. 审查通过后合并
4. 从dev创建PR到main

---

## 🎯 下一步

### 立即执行：
- [ ] 访问GitHub启用Actions（如果未启用）
- [ ] 配置分支保护规则（`.github/BRANCH_PROTECTION.md`）
- [ ] 创建dev分支（如果需要）

### 后续优化：
- [ ] 补充单元测试
- [ ] 配置代码覆盖率报告
- [ ] 添加自动化部署到测试环境
- [ ] 集成Slack/钉钉通知

---

## 📞 需要帮助？

- 查看 `.github/BRANCH_PROTECTION.md` 分支保护配置
- 查看 `CONTRIBUTING.md` 开发流程
- 查看 `.husky/README.md` Git Hooks详情
- 创建GitHub Issue提问

---

**DevOps流程配置完成！开始享受自动化开发体验吧！** 🎉
