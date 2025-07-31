# Docker构建问题解决指南

## 常见构建错误及解决方案

### 1. 退出代码1 - Gradle构建失败

**错误信息：**
```
Error: buildx failed with: ERROR: failed to build: failed to solve: process "/bin/sh -c ./gradlew :sonar-application:zip" did not complete successfully: exit code: 1
```

**可能原因：**
- 内存不足
- 网络连接问题
- 依赖下载失败
- Gradle配置问题

**解决方案：**

#### 方案A：增加内存配置
```bash
# 在Dockerfile中设置
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=true -Dorg.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=1g"
```

#### 方案B：使用简化构建
```bash
# 使用简化版Dockerfile
docker build -f Dockerfile.simple -t sonarqube-test .
```

#### 方案C：分步构建
```bash
# 1. 预热Gradle
./gradlew --version

# 2. 清理缓存
./gradlew clean

# 3. 构建
./gradlew :sonar-application:zip --no-daemon --parallel=false
```

### 2. 退出代码126 - 权限和换行符问题

**错误信息：**
```
exit code: 126
```

**可能原因：**
- gradlew文件没有执行权限
- Windows和Linux换行符不匹配
- gradlew文件损坏

**解决方案：**

#### 方案A：使用修复脚本
```bash
chmod +x scripts/fix-gradlew.sh
./scripts/fix-gradlew.sh
```

#### 方案B：在Dockerfile中修复
```dockerfile
# 安装dos2unix工具
RUN apt-get update && apt-get install -y dos2unix

# 修复gradlew权限和换行符
RUN chmod +x ./gradlew && \
    dos2unix ./gradlew 2>/dev/null || true && \
    file ./gradlew
```

#### 方案C：使用测试Dockerfile
```bash
docker build -f Dockerfile.test -t sonarqube-test .
```

### 3. 网络超时问题

**解决方案：**
```bash
# 使用国内镜像源
export GRADLE_OPTS="-Dorg.gradle.daemon=false -Dgradle.user.home=/tmp/.gradle"

# 或使用代理
export HTTP_PROXY=http://proxy:port
export HTTPS_PROXY=http://proxy:port
```

### 4. 内存不足问题

**解决方案：**
```bash
# 增加Docker内存限制
docker build --memory=8g --memory-swap=8g -t sonarqube .

# 或使用更保守的Gradle设置
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Dorg.gradle.parallel=false -Dorg.gradle.jvmargs=-Xmx2g"
```

## 调试步骤

### 1. 使用调试脚本
```bash
chmod +x scripts/build-debug.sh
./scripts/build-debug.sh
```

### 2. 检查系统资源
```bash
# 检查内存
free -h

# 检查磁盘空间
df -h

# 检查Docker资源
docker system df
```

### 3. 分步测试
```bash
# 测试Gradle是否正常
docker run --rm -v $(pwd):/app -w /app eclipse-temurin:17-jdk-jammy ./gradlew --version

# 测试依赖下载
docker run --rm -v $(pwd):/app -w /app eclipse-temurin:17-jdk-jammy ./gradlew dependencies
```

## 优化建议

### 1. 构建优化
- 使用多阶段构建
- 启用Gradle缓存
- 并行构建
- 增量构建

### 2. 资源优化
- 增加内存配置
- 使用SSD存储
- 优化网络连接
- 使用构建缓存

### 3. 网络优化
- 使用国内镜像源
- 配置代理
- 使用CDN加速

## 常见问题FAQ

### Q: 构建时间太长怎么办？
A: 
- 启用Gradle缓存
- 使用并行构建
- 使用构建缓存
- 优化网络连接

### Q: 内存不足怎么办？
A:
- 增加Docker内存限制
- 减少并行任务数
- 使用更保守的JVM设置
- 使用更大的构建机器

### Q: 网络问题怎么办？
A:
- 使用国内镜像源
- 配置代理
- 重试构建
- 使用VPN

### Q: 依赖下载失败怎么办？
A:
- 检查网络连接
- 使用镜像源
- 清理缓存重试
- 检查依赖版本

## 相关文件

- `Dockerfile` - 主构建文件
- `Dockerfile.simple` - 简化版构建文件
- `scripts/build-debug.sh` - 调试脚本
- `gradle.properties` - Gradle配置
- `.github/workflows/ci.yml` - CI工作流

## 获取帮助

如果问题仍然存在，请：

1. 运行调试脚本获取详细信息
2. 检查构建日志
3. 提供错误信息和系统环境
4. 尝试使用简化版Dockerfile 