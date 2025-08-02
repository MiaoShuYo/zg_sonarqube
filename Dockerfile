# 使用OpenJDK 17作为基础镜像
FROM openjdk:17-jdk-slim

# 设置工作目录
WORKDIR /opt/sonarqube

# 安装必要的工具
RUN apt-get update && apt-get install -y \
    curl \
    wget \
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

# 构建SonarQube应用（跳过测试和问题模块）
RUN ./gradlew :sonar-application:shadowJar :sonar-core:jar :sonar-plugin-api-impl:jar --no-daemon --info -x test -x :sonar-scanner-engine:compileJava

# 验证构建结果
RUN ls -la sonar-application/build/libs/ || echo "Build directory not found"

# 创建运行时目录结构
RUN mkdir -p /opt/sonarqube/bin/linux-x86-64 /opt/sonarqube/conf /opt/sonarqube/lib /opt/sonarqube/logs /opt/sonarqube/data /opt/sonarqube/extensions /opt/sonarqube/temp /opt/sonarqube/elasticsearch /opt/sonarqube/elasticsearch/data

# 复制JAR文件到lib目录并重命名
RUN cp sonar-application/build/libs/*.jar /opt/sonarqube/lib/sonar-application.jar

# 复制其他必要的JAR文件
RUN cp sonar-core/build/libs/*.jar /opt/sonarqube/lib/ 2>/dev/null || echo "No sonar-core JARs found"
RUN cp sonar-plugin-api-impl/build/libs/*.jar /opt/sonarqube/lib/ 2>/dev/null || echo "No sonar-plugin-api-impl JARs found"

# 验证JAR文件
RUN ls -la /opt/sonarqube/lib/ || echo "Lib directory not found"

# 创建JDBC目录并复制驱动
RUN mkdir -p /opt/sonarqube/lib/jdbc/postgresql /opt/sonarqube/lib/jdbc/h2

# 下载PostgreSQL JDBC驱动
RUN wget -q https://jdbc.postgresql.org/download/postgresql-42.7.2.jar -O /opt/sonarqube/lib/jdbc/postgresql/postgresql-42.7.2.jar

# 下载H2 JDBC驱动
RUN wget -q https://repo1.maven.org/maven2/com/h2database/h2/2.2.224/h2-2.2.224.jar -O /opt/sonarqube/lib/jdbc/h2/h2-2.2.224.jar

# 创建sonar.properties配置文件
RUN echo '# SonarQube Configuration\n\
    # Database (H2 by default)\n\
    sonar.jdbc.username=sonar\n\
    sonar.jdbc.password=sonar\n\
    sonar.jdbc.url=jdbc:h2:${SONAR_DATA_DIR}/sonar\n\
    \n\
    # Web Server\n\
    sonar.web.host=0.0.0.0\n\
    sonar.web.port=9000\n\
    sonar.web.context=/\n\
    \n\
    # Search Engine\n\
    sonar.search.javaOpts=-Xmx512m -Xms512m -XX:MaxDirectMemorySize=256m -XX:+HeapDumpOnOutOfMemoryError\n\
    \n\
    # Compute Engine\n\
    sonar.ce.javaOpts=-Xmx512m -Xms128m -XX:+HeapDumpOnOutOfMemoryError\n\
    \n\
    # Web Server\n\
    sonar.web.javaOpts=-Xmx512m -Xms128m -XX:+HeapDumpOnOutOfMemoryError\n\
    ' > /opt/sonarqube/conf/sonar.properties

# 创建启动脚本
RUN echo '#!/bin/bash\n\
    cd /opt/sonarqube\n\
    \n\
    # 设置默认数据库配置（如果未提供环境变量）\n\
    if [ -z "$SONAR_JDBC_URL" ]; then\n\
    export SONAR_JDBC_URL="jdbc:h2:${SONAR_DATA_DIR}/sonar"\n\
    fi\n\
    \n\
    if [ -z "$SONAR_JDBC_USERNAME" ]; then\n\
    export SONAR_JDBC_USERNAME="sonar"\n\
    fi\n\
    \n\
    if [ -z "$SONAR_JDBC_PASSWORD" ]; then\n\
    export SONAR_JDBC_PASSWORD="sonar"\n\
    fi\n\
    \n\
    # 确保数据目录存在并设置权限\n\
    mkdir -p ${SONAR_DATA_DIR} ${SONAR_LOGS_DIR} ${SONAR_TEMP_DIR} ${SONAR_EXTENSIONS_DIR}\n\
    chmod 755 ${SONAR_DATA_DIR} ${SONAR_LOGS_DIR} ${SONAR_TEMP_DIR} ${SONAR_EXTENSIONS_DIR}\n\
    \n\
    # 启动SonarQube\n\
    exec java -jar lib/sonar-application.jar\n\
    ' > /opt/sonarqube/bin/linux-x86-64/sonar.sh && \
    chmod +x /opt/sonarqube/bin/linux-x86-64/sonar.sh

# 设置环境变量
ENV SONAR_HOME=/opt/sonarqube
ENV SONAR_DATA_DIR=/opt/sonarqube/data
ENV SONAR_LOGS_DIR=/opt/sonarqube/logs
ENV SONAR_TEMP_DIR=/opt/sonarqube/temp
ENV SONAR_EXTENSIONS_DIR=/opt/sonarqube/extensions

# 设置目录权限
RUN chown -R 1000:1000 /opt/sonarqube
USER 1000

# 暴露端口
EXPOSE 9000

# 设置健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/api/system/status || exit 1

# 启动命令 - 使用启动脚本
CMD ["/opt/sonarqube/bin/linux-x86-64/sonar.sh"] 