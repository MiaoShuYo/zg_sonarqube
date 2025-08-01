# SonarQube Community Edition with Branch Support

这是一个修改版的SonarQube Community Edition，移除了对分支功能的限制，允许Community Edition支持非main分支和Pull Request的分析。

## 🚀 主要改进

### 分支支持
- ✅ **非main分支分析**：支持分析任意分支
- ✅ **Pull Request分析**：支持分析Pull Request
- ✅ **分支功能**：移除了Community Edition的分支限制

## 📦 Docker镜像

### 自动构建
每次推送到main分支时，GitHub Actions会自动构建并推送Docker镜像到Docker Hub。

### 手动构建
```bash
docker build -t zgsonarqube:latest .
```

### 运行容器
```bash
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  your-dockerhub-username/zg_sonarqube:latest
```

### 使用Docker Compose
```yaml
version: '3.8'
services:
  sonarqube:
    image: your-dockerhub-username/zg_sonarqube:latest
    ports:
      - "9000:9000"
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true

volumes:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:
```

## 🔧 GitHub Actions设置

### 必需的Secrets
在GitHub仓库设置中添加以下Secrets：

1. **DOCKER_USERNAME**: 您的Docker Hub用户名
2. **DOCKER_PASSWORD**: 您的Docker Hub密码或访问令牌

### 设置步骤
1. 进入GitHub仓库设置
2. 点击 "Secrets and variables" → "Actions"
3. 添加上述两个Secrets
4. 推送代码到main分支即可触发自动构建

## 📋 使用方法

### 分析特定分支
```bash
sonar-scanner \
  -Dsonar.branch.name=feature-branch \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src
```

### 分析Pull Request
```bash
sonar-scanner \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature-branch \
  -Dsonar.pullrequest.base=main \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src
```

## 🔍 修改内容

主要修改了以下文件：
- `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/analysis/AnalysisMetadataHolderImpl.java`
- `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/component/BranchLoader.java`
- `server/sonar-ce-task-projectanalysis/src/main/java/org/sonar/ce/task/projectanalysis/component/CommunityBranchImpl.java`
- `sonar-scanner-engine/src/main/java/org/sonar/scanner/scan/ProjectReactorValidator.java`
- `sonar-scanner-engine/src/main/java/org/sonar/scanner/scan/ScanProperties.java`

## 📝 许可证

本项目基于LGPL-3.0许可证开源。
