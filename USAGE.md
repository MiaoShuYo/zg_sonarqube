# SonarQube Docker 镜像使用说明

## 快速开始

### 1. 拉取镜像
```bash
docker pull programercat/zgsonarqube:latest
```

### 2. 运行容器
```bash
# 基本运行
docker run -d --name sonarqube \
  -p 9000:9000 \
  programercat/zgsonarqube:latest

# 带数据持久化
docker run -d --name sonarqube \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  programercat/zgsonarqube:latest
```

### 3. 使用Docker Compose（推荐）

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  sonarqube:
    image: programercat/zgsonarqube:latest
    container_name: sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD=sonar
      - SONAR_WEB_JAVAOPTS=-Xmx4g -Xms2g
      - SONAR_CE_JAVAOPTS=-Xmx2g -Xms1g
      - SONAR_SEARCH_JAVAOPTS=-Xmx2g -Xms1g
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
    depends_on:
      - db
    networks:
      - sonar
    restart: unless-stopped

  db:
    image: postgres:13
    container_name: sonarqube-db
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
      - POSTGRES_DB=sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data
    networks:
      - sonar
    restart: unless-stopped

volumes:
  sonarqube_data:
  sonarqube_logs:
  sonarqube_extensions:
  postgresql:
  postgresql_data:

networks:
  sonar:
    driver: bridge
```

运行：
```bash
docker-compose up -d
```

## 访问SonarQube

1. **打开浏览器**
   - 访问 `http://localhost:9000`

2. **初始登录**
   - 默认管理员账户：`admin`
   - 默认密码：`admin`

3. **首次设置**
   - 登录后系统会提示修改密码
   - 建议立即修改默认密码

## 系统要求

### 最低要求
- **内存**: 4GB RAM
- **CPU**: 2核
- **磁盘**: 10GB可用空间

### 推荐配置
- **内存**: 8GB RAM
- **CPU**: 4核
- **磁盘**: 50GB可用空间

## 故障排除

### 1. 容器无法启动
```bash
# 查看容器日志
docker logs sonarqube

# 检查容器状态
docker ps -a
```

### 2. 内存不足
```bash
# 检查系统内存
free -h

# 增加Docker内存限制
docker run -d --name sonarqube \
  -p 9000:9000 \
  --memory=4g \
  programercat/zgsonarqube:latest
```

### 3. 端口冲突
```bash
# 使用不同端口
docker run -d --name sonarqube \
  -p 9001:9000 \
  programercat/zgsonarqube:latest
```

## 版本标签

可用的镜像标签：
- `latest`: 最新版本
- `main`: 主分支版本
- `{commit-sha}`: 特定提交版本

## 注意事项

1. **首次启动时间较长**：SonarQube需要初始化数据库和索引
2. **内存使用**：确保系统有足够的内存
3. **数据持久化**：建议使用数据卷保存重要数据
4. **网络访问**：确保9000端口没有被其他服务占用

## 支持

如果遇到问题，请：
1. 查看容器日志：`docker logs sonarqube`
2. 检查系统资源使用情况
3. 参考SonarQube官方文档
4. 提交Issue到GitHub仓库 