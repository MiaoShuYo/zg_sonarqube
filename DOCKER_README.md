# SonarQube Docker 镜像构建指南

本文档说明如何将SonarQube项目构建为Docker镜像。

## 文件说明

- `Dockerfile` - 主要的Docker构建文件
- `docker-compose.yml` - Docker Compose配置文件
- `build-docker.sh` - Linux/macOS构建脚本
- `build-docker.bat` - Windows构建脚本
- `.dockerignore` - Docker构建忽略文件

## 快速开始

### 1. 构建Docker镜像

#### Linux/macOS用户
使用构建脚本（推荐）：
```bash
# 给脚本执行权限
chmod +x build-docker.sh

# 构建默认镜像
./build-docker.sh

# 构建自定义名称和标签的镜像
./build-docker.sh -n my-zgsonarqube -t v1.0

# 构建并推送到仓库
./build-docker.sh -p
```

#### Windows用户
使用批处理文件：
```cmd
# 构建默认镜像
build-docker.bat

# 构建自定义名称和标签的镜像
build-docker.bat -n my-zgsonarqube -t v1.0

# 构建并推送到仓库
build-docker.bat -p
```

#### 直接使用Docker命令
```bash
docker build -t zgsonarqube:latest .
```

### 2. 运行SonarQube

#### 使用Docker命令
```bash
# 基本运行
docker run -p 9000:9000 zgsonarqube:latest

# 使用数据卷持久化数据
docker run -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_temp:/opt/sonarqube/temp \
  zgsonarqube:latest
```

#### 使用Docker Compose（推荐）
```bash
# 启动SonarQube（使用内置H2数据库）
docker-compose up -d

# 启动SonarQube和PostgreSQL
docker-compose --profile postgres up -d

# 查看日志
docker-compose logs -f sonarqube

# 停止服务
docker-compose down
```

## 配置说明

### 环境变量

可以通过环境变量配置SonarQube：

```bash
docker run -p 9000:9000 \
  -e SONAR_WEB_JAVAOPTS="-Xmx1g -Xms512m" \
  -e SONAR_CE_JAVAOPTS="-Xmx1g -Xms512m" \
  -e SONAR_SEARCH_JAVAOPTS="-Xmx1g -Xms512m" \
  zgsonarqube:latest
```

### 数据卷

重要的数据卷：
- `/opt/sonarqube/data` - 数据库数据
- `/opt/sonarqube/logs` - 日志文件
- `/opt/sonarqube/extensions` - 插件和扩展
- `/opt/sonarqube/temp` - 临时文件

### 端口

- `9000` - SonarQube Web界面

## 生产环境建议

### 1. 使用外部数据库

修改`docker-compose.yml`中的SonarQube服务配置：

```yaml
services:
  sonarqube:
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/sonarqube
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
    depends_on:
      - postgres
```

### 2. 调整JVM内存设置

根据服务器配置调整内存：

```yaml
services:
  sonarqube:
    environment:
      - SONAR_WEB_JAVAOPTS=-Xmx2g -Xms1g
      - SONAR_CE_JAVAOPTS=-Xmx2g -Xms1g
      - SONAR_SEARCH_JAVAOPTS=-Xmx2g -Xms1g
```

### 3. 使用反向代理

在生产环境中，建议使用Nginx或Apache作为反向代理。

## 故障排除

### 1. 构建失败

- 确保有足够的内存（建议8GB+）
- 检查网络连接，确保能下载依赖
- 查看构建日志：`docker build -t sonarqube . 2>&1 | tee build.log`

### 2. 启动失败

- 检查端口是否被占用：`netstat -tulpn | grep 9000`
- 查看容器日志：`docker logs <container_id>`
- 检查数据卷权限

### 3. 性能问题

- 增加JVM内存设置
- 使用SSD存储
- 配置足够的内存给Elasticsearch

## 安全注意事项

1. **更改默认密码**：首次启动后立即更改admin密码
2. **使用HTTPS**：在生产环境中配置SSL/TLS
3. **网络隔离**：使用Docker网络隔离服务
4. **定期备份**：备份数据卷中的重要数据

## 版本管理

建议为不同版本创建标签：

```bash
# 构建特定版本
./build-docker.sh -n my-registry/zgsonarqube -t 9.9.0

# 推送多个标签
docker tag zgsonarqube:latest my-registry/zgsonarqube:latest
docker push my-registry/zgsonarqube:latest
```

## 监控和日志

### 健康检查

Dockerfile包含健康检查，可以通过以下命令查看：

```bash
docker inspect --format='{{.State.Health.Status}}' <container_id>
```

### 日志查看

```bash
# 查看实时日志
docker logs -f <container_id>

# 查看特定时间段的日志
docker logs --since="2023-01-01T00:00:00" <container_id>
```

## 支持

如果遇到问题，请检查：
1. Docker和Docker Compose版本
2. 系统资源（内存、磁盘空间）
3. 网络连接
4. 防火墙设置 