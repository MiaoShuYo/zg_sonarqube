# 使用OpenJDK 17作为基础镜像
FROM openjdk:17-jdk-slim

# 设置工作目录
WORKDIR /opt/sonarqube

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# 复制Gradle包装器
COPY gradlew ./
COPY gradle/ gradle/

# 复制构建文件
COPY build.gradle ./
COPY settings.gradle ./
COPY gradle.properties ./

# 复制源代码
COPY . .

# 设置执行权限
RUN chmod +x gradlew

# 构建SonarQube应用
RUN ./gradlew :sonar-application:shadowJar --no-daemon --info

# 验证构建结果
RUN ls -la sonar-application/build/libs/ || echo "Build directory not found"
RUN find . -name "*.jar" -type f || echo "No JAR files found"

# 创建运行时目录
RUN mkdir -p /opt/sonarqube/logs /opt/sonarqube/data /opt/sonarqube/extensions /opt/sonarqube/temp

# 设置环境变量
ENV SONAR_HOME=/opt/sonarqube
ENV SONAR_DATA_DIR=/opt/sonarqube/data
ENV SONAR_LOGS_DIR=/opt/sonarqube/logs
ENV SONAR_TEMP_DIR=/opt/sonarqube/temp
ENV SONAR_EXTENSIONS_DIR=/opt/sonarqube/extensions

# 暴露端口
EXPOSE 9000

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/api/system/status || exit 1

# 启动命令 - 使用更灵活的方式查找JAR文件
CMD ["sh", "-c", "java -jar $(find sonar-application/build/libs -name '*.jar' | head -1)"] 