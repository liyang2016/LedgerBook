# Branch Protection Rules Configuration

## 🛡️ 分支保护规则设置

GitHub分支保护需要在仓库设置页面手动配置，以下是需要配置的详细步骤：

### 配置路径
Settings → Branches → Add rule

### 需要保护的规则

#### 1. **main 分支保护规则**

```
Branch name pattern: main
```

**✅ 启用的选项：**

- [x] **Require a pull request before merging**  
  需要Pull Request才能合并
  - [x] Require approvals (2)  
    需要2个审批人
  - [x] Dismiss stale PR approvals when new commits are pushed  
    推送新代码时取消旧的审批
  - [x] Require review from code owners  
    需要代码所有者审查

- [x] **Require status checks to pass before merging**  
  要求状态检查通过
  - [x] Require branches to be up to date before merging  
    要求分支在合并前是最新的
  - 检查列表（在GitHub Actions运行后可选）:
    - [x] `Code Quality Check`
    - [x] `Unit Tests`
    - [x] `Security Scan`

- [x] **Require conversation resolution before merging**  
  要求所有对话都已解决

- [x] **Require signed commits**  
  要求提交已签名（可选）

- [x] **Include administrators**  
  规则也适用于管理员

- [x] **Restrict pushes that create files larger than 100MB**  
  限制推送大于100MB的文件

- [ ] **Allow force pushes**  
  不允许强制推送 ❌

- [ ] **Allow deletions**  
  不允许删除分支 ❌

#### 2. **dev 分支保护规则**（可选）

```
Branch name pattern: dev
```

**✅ 启用的选项：**

- [x] Require a pull request before merging
  - [x] Require approvals (1)
  
- [x] Require status checks to pass before merging
  - [x] `Code Quality Check`
  - [x] `Unit Tests`

- [ ] Allow force pushes
- [ ] Allow deletions

---

## 📋 配置截图指南

### 步骤1: 访问设置页面
```
https://github.com/liyang2016/LedgerBook/settings/branches
```

### 步骤2: 点击 "Add rule" 按钮

### 步骤3: 输入分支模式
在 "Branch name pattern" 输入: `main`

### 步骤4: 配置保护规则
按照上面的复选框逐一勾选

### 步骤5: 保存规则
点击 "Create" 或 "Save changes" 按钮

---

## 🔒 推荐的分支策略

### Git Flow 工作流

```
main (生产环境)
  ↑
dev (开发环境)
  ↑
feature/* (功能分支)
```

### 工作流程

1. **创建功能分支**
   ```bash
   git checkout -b feature/add-search main
   ```

2. **开发并提交**
   ```bash
   git add .
   git commit -m "feat: add search functionality"
   git push -u origin feature/add-search
   ```

3. **创建Pull Request**
   - 在GitHub上从 `feature/add-search` 到 `dev` 创建PR
   - 等待代码审查和CI检查通过
   - 合并到dev分支

4. **发布到main**
   - 从 `dev` 到 `main` 创建PR
   - 需要2个审批
   - 所有检查必须通过
   - 合并后自动触发发布

---

## 📝 代码审查清单

Pull Request审查时应检查：

- [ ] 代码风格符合项目规范
- [ ] 有适当的单元测试
- [ ] 文档已更新
- [ ] 没有 console.log 等调试代码
- [ ] 提交信息符合规范
- [ ] 功能测试通过
- [ ] 没有引入安全漏洞

---

## 🔧 相关文件

- `.github/workflows/ci.yml` - CI/CD流水线配置
- `.husky/pre-commit` - 提交前检查
- `.husky/commit-msg` - 提交信息验证
- `.husky/pre-push` - 推送前检查

---

## 📞 故障排除

### 常见问题

**Q: 无法推送，显示 "protected branch"**
A: 必须通过Pull Request合并代码，不能直接推送到main分支

**Q: CI检查一直等待**
A: 检查GitHub Actions是否已启用，路径：Settings → Actions → General

**Q: 如何绕过保护规则（紧急情况）**
A: 只有仓库管理员可以临时禁用规则，但不推荐

---

配置完成后，您的项目将拥有完整的质量保障流程！🎉
