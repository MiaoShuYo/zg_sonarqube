# SonarQube Community Edition with Branch Support

这是一个修改版的SonarQube Community Edition，移除了对分支功能的限制，允许Community Edition支持非main分支和Pull Request的分析。

## 🚀 主要改进

### 分支支持
- ✅ **非main分支分析**：支持分析任意分支
- ✅ **Pull Request分析**：支持分析Pull Request
- ✅ **分支功能**：移除了Community Edition的分支限制

### 修改内容
1. **AnalysisMetadataHolderImpl.java** - 移除了版本检查逻辑
2. **BranchLoader.java** - 添加了分支支持
3. **CommunityBranchImpl.java** - 新增的分支实现类
4. **ProjectReactorValidator.java** - 移除了扫描器端限制
5. **ScanProperties.java** - 移除了属性验证限制

## 📦 Docker镜像

### 构建镜像
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
  zgsonarqube:latest
```

### 使用Docker Compose
```yaml
version: '3.8'
services:
  sonarqube:
    image: zgsonarqube:latest
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

## 🔧 使用方法

### 分支分析
```bash
sonar-scanner \
  -Dsonar.branch.name=feature-branch \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src \
  -Dsonar.host.url=http://localhost:9000
```

### Pull Request分析
```bash
sonar-scanner \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature-branch \
  -Dsonar.pullrequest.base=main \
  -Dsonar.projectKey=my-project \
  -Dsonar.sources=src \
  -Dsonar.host.url=http://localhost:9000
```

### GitHub Actions集成
```yaml
name: SonarQube Analysis
on: [push, pull_request]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: SonarQube Scan
      uses: sonarqube-quality-gate-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      with:
        args: >
          -Dsonar.branch.name=${{ github.head_ref }}
          -Dsonar.pullrequest.key=${{ github.event.number }}
          -Dsonar.pullrequest.branch=${{ github.head_ref }}
          -Dsonar.pullrequest.base=${{ github.base_ref }}
```

## 🛠️ 开发环境

### 本地构建
```bash
# 设置Java 17+
export JAVA_HOME=/path/to/java17

# 构建项目
./gradlew :sonar-application:zip --no-daemon --parallel --max-workers=2
```

### 运行测试
```bash
# 运行所有测试
./gradlew test

# 运行特定模块测试
./gradlew :server:sonar-ce-task-projectanalysis:test
```

## 📋 注意事项

1. **功能限制**：虽然移除了版本检查，但某些高级分支功能可能仍然不可用
2. **数据库兼容性**：确保数据库结构支持分支功能
3. **插件依赖**：某些分支相关功能可能仍需要特定的插件支持
4. **测试覆盖**：建议在部署前进行充分测试

## 🔒 免责声明

这些修改移除了SonarQube的商业限制，仅用于学习和研究目的。在生产环境中使用前，请确保符合相关的许可证条款。

## 📄 许可证

本项目基于LGPL-3.0许可证发布。详见[LICENSE](LICENSE)文件。

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目。

## 📞 支持

如果您遇到问题或有建议，请创建Issue或联系维护者。
