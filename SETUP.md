# GitHub Actions 设置指南

## 快速开始

### 1. 设置Docker Hub Secrets

1. 登录GitHub，进入您的仓库
2. 点击 "Settings" 标签
3. 在左侧菜单中点击 "Secrets and variables" → "Actions"
4. 点击 "New repository secret" 按钮
5. 添加以下两个Secrets：

#### DOCKER_USERNAME
- **Name**: `DOCKER_USERNAME`
- **Value**: 您的Docker Hub用户名

#### DOCKER_PASSWORD
- **Name**: `DOCKER_PASSWORD`
- **Value**: 您的Docker Hub密码或访问令牌

> **注意**: 建议使用Docker Hub访问令牌而不是密码，更安全。

### 2. 创建访问令牌（推荐）

1. 登录 [Docker Hub](https://hub.docker.com/)
2. 点击右上角头像 → "Account Settings"
3. 点击 "Security" 标签
4. 点击 "New Access Token"
5. 输入令牌名称（如：github-actions）
6. 复制生成的令牌
7. 在GitHub Secrets中使用这个令牌作为 `DOCKER_PASSWORD`

### 3. 触发构建

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

#### 1. 权限错误
确保已正确设置 `DOCKER_USERNAME` 和 `DOCKER_PASSWORD` Secrets。

#### 2. 构建失败
检查Dockerfile语法和依赖项。

#### 3. 推送失败
确保Docker Hub账户有足够的权限。

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