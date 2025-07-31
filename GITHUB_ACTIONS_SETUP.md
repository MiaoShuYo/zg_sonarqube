# Fixing GitHub Actions CodeQL权限问题

## 问题描述

在GitHub Actions中运行CodeQL Action时遇到以下错误：

```
Warning: This run of the CodeQL Action does not have permission to access Code Scanning API endpoints. As a result, it will not be opted into any experimental features. This could be because the Action is running on a pull request from a fork. If not, please ensure the Action has the 'security-events: write' permission.
```

## 解决方案

### 1. 添加必要的SAM权限

在所有使用CodeQL Action的工作流文件中添加以下权限配置：

```yaml
permissions:
  security-events: write
  actions: read
  contents: read
```

### 2. 启用Code Scanning

在GitHub仓库设置中启用代码扫描：

1. 进入仓库设置 (Settings)
2. 点击 "Security" → "Code security and analysis"
3. 在 "Code scanning" 部分点击 "Set up" 或 "Configure"
4. 选择 "GitHub Advanced Security" 或 "CodeQL"
5. 点击 "Enable"

### 3. 检查仓库设置

确保以下TODO项目已完成：

- [ ] 启用GitHub Advanced Security (如果使用企业版)
- [ ] 配置代码扫描规则
- [ ] 设置安全策略
- [ ] 配置依赖扫描

### 4. 工作流文件修改

已修改以下文件：

- `.github/workflows/ci.yml` - 添加了必要的权限
- `.github/workflows/docker-build.yml` - 添加了必要的权限  
- `.github/workflows/release.yml` - 添加了必要的权限

### 5. 验证修复

修复后，CodeQL Action应该能够：

- 成功上传SARIF文件到GitHub Security tab
- 访问Code Scanning API端点
- 启用实验性功能
- 正确发送遥测数据

### 6. 常见问题

#### 问题1: 权限仍然不足
**解决方案**: 检查仓库是否为fork，如果是fork，需要确保主仓库允许fork的Actions运行。

#### 问题2: Code Scanning未启用
**解决方案**: 联系仓库管理员启用以下权限：
- `security-events: write`
- `actions: read`
- `contents: read`

#### 问题3: API访问受限
**解决方案**: 确保GitHub Token有足够的权限，或者使用更强的权限配置。

### 7. 最佳实践

1. **使用最小权限原则**: 只授予必要的权限
2. **定期更新Action版本**: 使用最新的CodeQL Action版本
3. **监控安全扫描结果**: 定期检查Security tab中的扫描结果
4. **配置通知**: 设置安全漏洞通知

### 8. 相关链接

- [GitHub Code Scanning文档](https://docs.github.com/en/code-security/code-scanning)
- [CodeQL Action文档](https://github.com/github/codeql-action)
- [GitHub Actions权限文档](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token)