# SonarQube Community Edition with Branch Support

## Docker 镜像使用指南

### 快速开始

#### 1. 拉取镜像
```bash
docker pull programercat/zgsonarqube:latest
```

#### 2. 运行容器
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

### 详细配置

#### 使用Docker Compose（推荐）

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
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_logs:/opt/sonarqube/logs
      - sonarqube_extensions:/opt/sonarqube/extensions
    depends_on:
      - db
    networks:
      - sonar

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

#### 环境变量配置

| 环境变量 | 默认值 | 说明 |
|---------|--------|------|
| `SONAR_JDBC_URL` | - | 数据库连接URL |
| `SONAR_JDBC_USERNAME` | - | 数据库用户名 |
| `SONAR_JDBC_PASSWORD` | - | 数据库密码 |
| `SONAR_WEB_HOST` | 0.0.0.0 | Web服务绑定地址 |
| `SONAR_WEB_PORT` | 9000 | Web服务端口 |
| `SONAR_WEB_CONTEXT` | / | Web上下文路径 |
| `SONAR_SEARCH_JAVAOPTS` | -Xms512m -Xmx512m | Elasticsearch JVM参数 |

#### 数据持久化

重要目录说明：
- `/opt/sonarqube/data`: 数据文件（项目、规则、质量门等）
- `/opt/sonarqube/logs`: 日志文件
- `/opt/sonarqube/extensions`: 插件和扩展
- `/opt/sonarqube/temp`: 临时文件

### 访问SonarQube

1. **打开浏览器**
   - 访问 `http://localhost:9000`

2. **初始登录**
   - 默认管理员账户：`admin`
   - 默认密码：`admin`

3. **首次设置**
   - 登录后系统会提示修改密码
   - 建议立即修改默认密码

### 系统要求

#### 最低要求
- **内存**: 4GB RAM
- **CPU**: 2核
- **磁盘**: 10GB可用空间

#### 推荐配置
- **内存**: 8GB RAM
- **CPU**: 4核
- **磁盘**: 50GB可用空间

### 性能优化

#### 1. 调整JVM参数
```bash
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_WEB_JAVAOPTS="-Xmx4g -Xms2g" \
  -e SONAR_CE_JAVAOPTS="-Xmx2g -Xms1g" \
  -e SONAR_SEARCH_JAVAOPTS="-Xmx2g -Xms1g" \
  programercat/zgsonarqube:latest
```

#### 2. 使用外部数据库
```bash
# 使用PostgreSQL
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://your-db-host:5432/sonar \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=your-password \
  programercat/zgsonarqube:latest
```

### 故障排除

#### 1. 容器无法启动
```bash
# 查看容器日志
docker logs sonarqube

# 检查容器状态
docker ps -a
```

#### 2. 内存不足
```bash
# 检查系统内存
free -h

# 增加Docker内存限制
docker run -d --name sonarqube \
  -p 9000:9000 \
  --memory=4g \
  programercat/zgsonarqube:latest
```

#### 3. 端口冲突
```bash
# 使用不同端口
docker run -d --name sonarqube \
  -p 9001:9000 \
  programercat/zgsonarqube:latest
```

### 备份和恢复

#### 备份数据
```bash
# 备份数据卷
docker run --rm -v sonarqube_data:/data -v $(pwd):/backup alpine tar czf /backup/sonarqube_data_backup.tar.gz -C /data .

# 备份数据库（如果使用外部数据库）
pg_dump -h your-db-host -U sonar sonar > sonar_backup.sql
```

#### 恢复数据
```bash
# 恢复数据卷
docker run --rm -v sonarqube_data:/data -v $(pwd):/backup alpine tar xzf /backup/sonarqube_data_backup.tar.gz -C /data

# 恢复数据库
psql -h your-db-host -U sonar sonar < sonar_backup.sql
```

### 版本标签

可用的镜像标签：
- `latest`: 最新版本
- `v1.0.0`: 特定版本
- `main`: 主分支版本
- `{commit-sha}`: 特定提交版本

### 安全建议

1. **修改默认密码**
   - 首次登录后立即修改admin密码

2. **使用HTTPS**
   - 在生产环境中配置SSL证书

3. **网络隔离**
   - 使用Docker网络隔离容器
   - 限制容器访问权限

4. **定期备份**
   - 定期备份数据和配置

5. **监控日志**
   - 监控容器日志和系统资源

### 支持

如果遇到问题，请：
1. 查看容器日志：`docker logs sonarqube`
2. 检查系统资源使用情况
3. 参考SonarQube官方文档
4. 提交Issue到GitHub仓库
