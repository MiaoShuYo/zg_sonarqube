# GitHub Actions构建指南

## 概述

本指南介绍如何在GitHub Actions中构建SonarQube Docker镜像。

## 工作流文件

### 主要工作流

- `.github/workflows/ci.yml` - 持续集成工作流
- `.github/workflows/docker-build.yml` - Docker构建和推送工作流
- `.github/workflows/release.yml` - 发布工作流

## 构建配置

### 专用Dockerfile

使用 `Dockerfile.github-actions` 进行构建，该文件针对GitHub Actions环境进行了优化：

- 使用保守的Gradle设置
- 减少内存使用
- 避免复杂的工具依赖
- 优化构建缓存

### 关键优化

```dockerfile
# GitHub Actions优化设置
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Dorg.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m"

# 保守的构建命令
RUN ./gradlew :sonar-application:zip --no-daemon --parallel=false --max-workers=1 --info
```

## 触发条件

### CI工作流
```yaml
on:
  push:
    branches: [ main, master, develop ]
  pull_request:
    branches: [ main, master ]
```

### 构建工作流
```yaml
on:
  push:
    branches: [ main, master ]
    tags: [ 'v*' ]
  pull_request:
    branches: [ main, master ]
  workflow_dispatch:
```

## 构建步骤

### 1. 检出代码
```yaml
- name: Checkout code
  uses: actions/checkout@v4
```

### 2. 设置Docker Buildx
```yaml
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
```

### 3. 构建Docker镜像
```yaml
- name: Build Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    platforms: linux/amd64
    push: false
    tags: ${{ env.REGISTRY }}/${{ secrets.DOCKERHUB_USERNAME }}/${{ env.IMAGE_NAME }}:ci-${{ github.sha }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
    build-args: |
      BUILDKIT_INLINE_CACHE=1
      GRADLE_OPTS=-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Dorg.gradle.jvmargs=-Xmx2g
    file: Dockerfile.github-actions
```

## 必要的Secrets

在GitHub仓库设置中配置以下Secrets：

| Secret名称 | 说明 | 必需 |
|-----------|------|------|
| `DOCKERHUB_USERNAME` | Docker Hub用户名 | 是 |
| `DOCKERHUB_TOKEN` | Docker Hub访问令牌 | 是 |

## 构建优化

### 1. 缓存策略
- 使用GitHub Actions缓存
- 启用Docker层缓存
- 优化Gradle缓存

### 2. 资源优化
- 限制内存使用（2GB）
- 禁用并行构建
- 使用单工作线程

### 3. 网络优化
- 使用GitHub Actions网络
- 启用构建缓存
- 优化依赖下载

## 故障排除

### 常见问题

1. **构建超时**
   - 增加构建时间限制
   - 使用更保守的设置
   - 检查网络连接

2. **内存不足**
   - 减少JVM内存设置
   - 禁用并行构建
   - 使用更大的运行器

3. **权限问题**
   - 检查Secrets配置
   - 验证Docker Hub权限
   - 确认工作流权限

### 调试步骤

1. **检查构建日志**
   ```bash
   # 在GitHub Actions中查看详细日志
   ```

2. **本地测试**
   ```bash
   # 使用相同的Dockerfile本地构建
   docker build -f Dockerfile.github-actions -t sonarqube-test .
   ```

3. **验证配置**
   ```bash
   # 检查Dockerfile语法
   docker build --dry-run -f Dockerfile.github-actions .
   ```

## 性能优化

### 构建时间优化
- 使用多阶段构建
- 启用缓存
- 优化层顺序

### 镜像大小优化
- 使用Alpine基础镜像
- 清理构建缓存
- 合并RUN命令

### 安全性优化
- 使用非root用户
- 扫描安全漏洞
- 更新依赖

## 监控和维护

### 构建监控
- 监控构建时间
- 跟踪成功率
- 分析失败原因

### 定期维护
- 更新基础镜像
- 更新依赖版本
- 清理旧缓存

## 相关文件

- `Dockerfile.github-actions` - GitHub Actions专用Dockerfile
- `.github/workflows/ci.yml` - CI工作流
- `.github/workflows/docker-build.yml` - 构建工作流
- `GITHUB_ACTIONS_SETUP.md` - 设置指南
- `BUILD_TROUBLESHOOTING.md` - 故障排除指南 