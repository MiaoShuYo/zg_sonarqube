# Docker 构建和推送 GitHub Action

这个GitHub Action工作流用于自动构建SonarQube Docker镜像并推送到Docker Hub。

## 功能特性

- 自动构建Docker镜像
- 推送到Docker Hub
- 支持多种标签策略
- 使用GitHub Actions缓存优化构建速度
- 健康检查支持

## 触发条件

工作流会在以下情况下触发：
- 推送到 `main` 或 `master` 分支
- 创建版本标签（格式：`v*`）
- 创建Pull Request到 `main` 或 `master` 分支

## 必需的Secrets

在GitHub仓库设置中需要配置以下Secrets：

### DOCKERHUB_TOKEN
Docker Hub的访问令牌。获取方法：
1. 登录Docker Hub
2. 进入Account Settings > Security
3. 创建新的Access Token

### DOCKERHUB_USERNAME
Docker Hub的用户名

## 配置Secrets

1. 进入GitHub仓库页面
2. 点击 "Settings" 标签
3. 在左侧菜单中点击 "Secrets and variables" > "Actions"
4. 点击 "New repository secret"
5. 添加以下两个secrets：
   - `DOCKERHUB_TOKEN`: 你的Docker Hub访问令牌
   - `DOCKERHUB_USERNAME`: 你的Docker Hub用户名

## 标签策略

工作流会自动为镜像添加以下标签：

- **分支标签**: 基于Git分支名称
- **PR标签**: 基于Pull Request编号
- **版本标签**: 基于语义化版本号
- **SHA标签**: 基于Git提交SHA

## 使用方法

### 手动触发构建

1. 进入GitHub仓库的 "Actions" 页面
2. 选择 "Build and Push Docker Image" 工作流
3. 点击 "Run workflow"
4. 选择目标分支
5. 点击 "Run workflow"

### 通过标签触发

创建版本标签来触发构建：

```bash
git tag v1.0.0
git push origin v1.0.0
```

## 镜像名称

镜像将使用以下格式命名：
```
docker.io/{DOCKERHUB_USERNAME}/{REPOSITORY_NAME}:{TAG}
```

## 本地测试

在推送之前，可以在本地测试Docker构建：

```bash
# 构建镜像
docker build -t sonarqube:latest .

# 运行容器
docker run -p 9000:9000 sonarqube:latest
```

## 注意事项

1. 确保Docker Hub账户有足够的权限推送镜像
2. 构建过程可能需要较长时间，因为需要编译整个SonarQube项目
3. 建议在Docker Hub中创建对应的仓库
4. 首次构建可能需要更长时间，后续构建会利用缓存加速

## 故障排除

### 构建失败
- 检查Docker Hub的Secrets配置是否正确
- 确认Docker Hub账户有推送权限
- 查看GitHub Actions日志获取详细错误信息

### 推送失败
- 验证DOCKERHUB_TOKEN是否有效
- 确认DOCKERHUB_USERNAME是否正确
- 检查Docker Hub仓库是否存在

## 自定义配置

如需修改构建配置，可以编辑以下文件：
- `.github/workflows/docker-build-push.yml`: GitHub Action工作流配置
- `Dockerfile`: Docker镜像构建配置
- `.dockerignore`: Docker构建忽略文件配置 