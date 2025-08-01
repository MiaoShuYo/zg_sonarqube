# GitHub Actions 设置指南

## 快速开始

### 1. 设置Docker Hub Secrets

1. 登录GitHub，进入您的仓库
2. 点击 "Settings" 标签
3. 在左侧菜单中点击 "Secrets and variables" → "Actions"
4. 点击 "New repository secret" 按钮
5. 添加以下两个Secrets：

#### DOCKERHUB_USERNAME
- **Name**: `DOCKERHUB_USERNAME`
- **Value**: 您的Docker Hub用户名

#### DOCKERHUB_PASSWORD
- **Name**: `DOCKERHUB_PASSWORD`
- **Value**: 您的Docker Hub密码或访问令牌

> **注意**: 建议使用Docker Hub访问令牌而不是密码，更安全。

### 2. 创建访问令牌（推荐）

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → "Account Settings"
3. 点击 "Security" 标签
4. 点击 "New Access Token"
5. 输入令牌名称（如：github-actions）
6. 复制生成的令牌
7. 在GitHub Secrets中使用这个令牌作为 `DOCKERHUB_PASSWORD`

### 3. 验证Secrets配置

确保您的GitHub Secrets包含以下内容：

| Secret名称 | 描述 | 必需 |
|-----------|------|------|
| `DOCKERHUB_USERNAME` | Docker Hub用户名 | 是 |
| `DOCKERHUB_PASSWORD` | Docker Hub密码或访问令牌 | 是 |

### 4. 触发构建

推送代码到main分支即可自动触发构建：

```bash
git add .
git commit -m "Update code"
git push origin main
```

## 工作流说明

### 触发条件
- 推送到 `main` 分支
- 手动触发（workflow_dispatch）

### 构建过程
1. 检出代码
2. 设置Docker Buildx
3. 登录Docker Hub
4. 构建并推送Docker镜像

### 镜像标签
- `latest`: 最新版本
- `{commit-sha}`: 基于提交SHA的版本

## 故障排除

### 常见问题

#### 1. "Password required" 错误
**原因**: Secrets未正确配置或名称错误
**解决方案**: 
- 检查 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_PASSWORD` 是否已设置
- 确保Secrets名称拼写正确（注意大小写）
- 验证Docker Hub凭据是否有效
- 确保使用的是 `DOCKERHUB_PASSWORD` 而不是 `DOCKERHUB_TOKEN`

#### 2. "Username and password required" 错误
**原因**: Secrets未正确配置
**解决方案**: 
- 检查 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_PASSWORD` 是否已设置
- 确保Secrets名称拼写正确（注意大小写）
- 验证Docker Hub凭据是否有效

#### 3. 权限错误
**原因**: Docker Hub账户权限不足
**解决方案**:
- 确保Docker Hub账户有推送权限
- 检查仓库名称是否正确
- 验证访问令牌是否有效

#### 4. 构建失败
**原因**: Dockerfile语法错误或依赖问题
**解决方案**:
- 检查Dockerfile语法
- 验证构建上下文
- 查看详细错误日志

### 查看日志
1. 进入GitHub仓库
2. 点击 "Actions" 标签
3. 选择最新的工作流运行
4. 查看详细日志

## 自定义配置

### 修改镜像名称
编辑 `.github/workflows/docker-build.yml` 文件中的 `IMAGE_NAME` 环境变量。

### 添加更多平台
在 `platforms` 参数中添加更多架构：
```yaml
platforms: linux/amd64,linux/arm64,linux/arm/v7
```

### 修改触发条件
编辑 `on` 部分来修改触发条件：
```yaml
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
```

## 测试Secrets配置

您可以通过以下方式测试Secrets是否正确配置：

1. **手动触发工作流**:
   - 进入GitHub仓库的Actions页面
   - 选择 "Build and Push Docker Image" 工作流
   - 点击 "Run workflow" 按钮
   - 选择main分支并运行

2. **检查日志**:
   - 如果看到 "Log in to Docker Hub" 步骤成功，说明Secrets配置正确
   - 如果看到 "Password required" 或 "Username and password required" 错误，需要检查Secrets配置

3. **验证Secrets名称**:
   - 确保使用的是 `DOCKERHUB_USERNAME` 和 `DOCKERHUB_PASSWORD`
   - 不要使用 `DOCKER_USERNAME`、`DOCKER_PASSWORD` 或 `DOCKERHUB_TOKEN` 