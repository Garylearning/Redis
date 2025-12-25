# Redis Docker 部署项目

基于 Docker 的 Redis 服务器部署方案，支持本地开发和微信云托管部署。

## 📋 项目简介

本项目提供了一个完整的 Redis Docker 部署方案，包括：
- 基于官方 Redis 7 Alpine 镜像的定制化 Dockerfile
- Docker Compose 配置文件，方便本地开发和管理
- 支持环境变量配置（密码、内存限制、持久化等）
- 适用于微信云托管部署

## ✨ 功能特性

- ✅ **基于 Redis 7 Alpine** - 轻量级、高性能
- ✅ **环境变量配置** - 支持密码、内存限制等灵活配置
- ✅ **数据持久化** - 支持 AOF 和 RDB 持久化
- ✅ **健康检查** - 自动监控 Redis 服务状态
- ✅ **端口映射** - 灵活的端口配置
- ✅ **数据卷管理** - 数据持久化存储

## 🚀 快速开始

### 前置要求

- Docker Desktop（Windows/Mac）或 Docker Engine（Linux）
- Docker Compose（通常包含在 Docker Desktop 中）

### 方式一：使用 Docker Compose（推荐）

#### 1. 启动服务

```bash
# 构建镜像并启动容器（后台运行）
docker-compose up -d

# 查看日志
docker-compose logs -f redis

# 查看服务状态
docker-compose ps
```

#### 2. 测试连接

```bash
# 测试 Redis 连接（如果设置了密码）
docker exec redis-server redis-cli -a your_password ping

# 进入交互式 CLI
docker exec -it redis-server redis-cli -a your_password
```

#### 3. 停止服务

```bash
# 停止服务（保留数据）
docker-compose stop

# 停止并删除容器（保留数据卷）
docker-compose down

# 停止并删除所有（包括数据卷）
docker-compose down -v
```

### 方式二：直接使用 Dockerfile

#### 1. 构建镜像

```bash
docker build -t redis:wechat-cloud .
```

#### 2. 运行容器

```bash
# 基本运行（无密码）
docker run -d --name redis-server -p 6379:6379 redis:wechat-cloud

# 带密码运行
docker run -d --name redis-server -p 6379:6379 \
  -e REDIS_PASSWORD=your_password \
  redis:wechat-cloud

# 完整配置运行
docker run -d --name redis-server -p 6379:6379 \
  -e REDIS_PASSWORD=your_password \
  -e REDIS_MAXMEMORY=256mb \
  -e REDIS_AOF=true \
  -v redis-data:/data \
  redis:wechat-cloud
```

## 📁 项目结构

```
Redis/
├── Dockerfile              # Redis 镜像构建文件
├── docker-compose.yml     # Docker Compose 配置文件
└── README.md             # 项目说明文档
```

## ⚙️ 配置说明

### Docker Compose 配置

编辑 `docker-compose.yml` 文件：

```yaml
services:
  redis:
    ports:
      - "6379:6379"  # 修改主机端口：容器端口
    environment:
      - REDIS_PASSWORD=your_password  # Redis 密码
      - REDIS_MAXMEMORY=256mb         # 最大内存（可选）
      - REDIS_AOF=true                # AOF 持久化（可选）
```

### 环境变量

| 变量名 | 说明 | 默认值 | 示例 |
|--------|------|--------|------|
| `REDIS_PASSWORD` | Redis 访问密码 | 无 | `your_password` |
| `REDIS_MAXMEMORY` | 最大内存限制 | 无限制 | `256mb`, `1gb` |
| `REDIS_AOF` | 是否启用 AOF 持久化 | `true` | `true`, `false` |

### 端口配置

默认端口映射：`6379:6379`

如需修改端口，编辑 `docker-compose.yml`：

```yaml
ports:
  - "6380:6379"  # 将主机端口改为 6380
```

## 💻 在 IDEA 中使用

### 方法一：使用 Docker Compose

1. 在 IDEA Terminal 中执行：

```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f redis
```

2. 在 `Services` 窗口中查看容器状态：
   - `View` -> `Tool Windows` -> `Services`
   - 展开 `Docker` -> `Containers`
   - 找到 `redis-server` 容器

### 方法二：使用 IDEA Docker 插件

1. **安装 Docker 插件**
   - `File` -> `Settings` -> `Plugins`
   - 搜索 "Docker" 并安装

2. **配置 Docker 连接**
   - `File` -> `Settings` -> `Build, Execution, Deployment` -> `Docker`
   - 添加 Docker 连接

3. **构建和运行**
   - 右键 `Dockerfile` -> `Build Image...`
   - 在 `Services` 窗口中管理容器

### 方法三：创建运行配置

1. `Run` -> `Edit Configurations...`
2. 点击 `+` -> `Docker` -> `Dockerfile`
3. 配置端口映射和环境变量
4. 运行配置

## 🔌 Java 项目连接示例

### 添加依赖（Maven）

```xml
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>4.3.1</version>
</dependency>
```

### 连接代码

```java
import redis.clients.jedis.Jedis;

public class RedisExample {
    public static void main(String[] args) {
        // 创建连接
        Jedis jedis = new Jedis("localhost", 6379);
        
        // 如果设置了密码
        jedis.auth("your_password");
        
        // 测试连接
        String pong = jedis.ping();
        System.out.println("连接成功: " + pong);
        
        // 基本操作
        jedis.set("key", "value");
        String value = jedis.get("key");
        System.out.println("值: " + value);
        
        // 关闭连接
        jedis.close();
    }
}
```

### 使用连接池（推荐）

```java
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;
import redis.clients.jedis.Jedis;

public class RedisPoolExample {
    public static void main(String[] args) {
        // 配置连接池
        JedisPoolConfig config = new JedisPoolConfig();
        config.setMaxTotal(10);
        config.setMaxIdle(5);
        config.setMinIdle(2);
        
        // 创建连接池
        JedisPool pool = new JedisPool(config, "localhost", 6379, 2000, "your_password");
        
        // 获取连接
        try (Jedis jedis = pool.getResource()) {
            jedis.set("key", "value");
            String value = jedis.get("key");
            System.out.println("值: " + value);
        }
        
        // 关闭连接池
        pool.close();
    }
}
```

## 📊 常用命令

### Docker Compose 命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose stop

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f redis

# 查看状态
docker-compose ps

# 停止并删除容器
docker-compose down

# 停止并删除所有（包括数据卷）
docker-compose down -v

# 重新构建并启动
docker-compose up -d --build
```

### Redis 操作命令

```bash
# 进入 Redis CLI
docker exec -it redis-server redis-cli -a your_password

# 测试连接
docker exec redis-server redis-cli -a your_password ping

# 查看 Redis 信息
docker exec redis-server redis-cli -a your_password INFO

# 查看内存使用
docker exec redis-server redis-cli -a your_password INFO memory

# 查看所有键
docker exec redis-server redis-cli -a your_password KEYS "*"

# 清空所有数据（谨慎使用）
docker exec redis-server redis-cli -a your_password FLUSHALL
```

### 容器管理命令

```bash
# 查看运行中的容器
docker ps

# 查看所有容器
docker ps -a

# 查看容器日志
docker logs redis-server
docker logs -f redis-server  # 实时日志

# 进入容器
docker exec -it redis-server sh

# 停止容器
docker stop redis-server

# 启动容器
docker start redis-server

# 删除容器
docker rm redis-server
```

## 🔍 监控和调试

### 查看 Redis 状态

```bash
# 查看服务器信息
docker exec redis-server redis-cli -a your_password INFO

# 查看客户端连接
docker exec redis-server redis-cli -a your_password CLIENT LIST

# 查看慢查询
docker exec redis-server redis-cli -a your_password SLOWLOG GET 10

# 查看配置
docker exec redis-server redis-cli -a your_password CONFIG GET "*"
```

### 数据持久化检查

```bash
# 进入容器查看数据文件
docker exec -it redis-server sh
ls -la /data

# 应该能看到：
# - appendonly.aof (AOF 持久化文件)
# - dump.rdb (RDB 快照文件，如果触发)
```

## 🚀 部署到微信云托管

### 部署步骤

1. **准备代码**
   - 确保项目包含 `Dockerfile`
   - 提交代码到 Git 仓库

2. **创建服务**
   - 登录 [微信云托管控制台](https://console.cloud.tencent.com/tcb)
   - 选择或创建环境
   - 点击"新建服务"
   - 选择"代码部署"

3. **配置服务**
   - **服务名称**：redis-server
   - **运行环境**：Docker
   - **代码来源**：选择代码仓库
   - **Dockerfile 路径**：`Dockerfile`

4. **环境变量配置**
   - 在"环境变量"中添加：
     - `REDIS_PASSWORD`: 你的 Redis 密码
     - `REDIS_MAXMEMORY`: 最大内存（可选）
     - `REDIS_AOF`: 持久化开关（可选）

5. **资源配置**
   - **CPU**：建议至少 0.5 核
   - **内存**：建议至少 512MB
   - **端口**：6379

6. **部署**
   - 点击"部署"按钮
   - 等待构建和部署完成

### 连接信息

部署成功后，在服务详情页获取：
- **内网地址**：`redis-server.环境名.tencentcloudapi.com`
- **端口**：`6379`
- **密码**：环境变量中设置的 `REDIS_PASSWORD`

## 🛠️ 故障排查

### 容器无法启动

```bash
# 查看详细错误日志
docker-compose logs redis
docker logs redis-server

# 检查端口是否被占用
netstat -ano | findstr 6379  # Windows
lsof -i :6379  # Mac/Linux

# 检查 Docker 是否运行
docker ps
```

### 无法连接 Redis

1. **检查容器状态**
   ```bash
   docker ps
   docker-compose ps
   ```

2. **检查端口映射**
   ```bash
   docker port redis-server
   ```

3. **测试容器内连接**
   ```bash
   docker exec redis-server redis-cli ping
   ```

4. **查看容器日志**
   ```bash
   docker logs redis-server
   ```

### 密码认证失败

```bash
# 检查环境变量
docker inspect redis-server | findstr REDIS_PASSWORD

# 尝试不使用密码连接（如果未设置密码）
docker exec -it redis-server redis-cli

# 重置密码（需要重启容器）
# 修改 docker-compose.yml 中的 REDIS_PASSWORD
docker-compose down
docker-compose up -d
```

### 数据丢失问题

```bash
# 检查数据卷
docker volume ls
docker volume inspect redis_redis-data

# 检查持久化文件
docker exec redis-server ls -la /data

# 手动触发保存
docker exec redis-server redis-cli -a your_password SAVE
```

### 内存不足

```bash
# 查看内存使用
docker exec redis-server redis-cli -a your_password INFO memory

# 设置最大内存（在 docker-compose.yml 中）
environment:
  - REDIS_MAXMEMORY=256mb
```

## 📝 注意事项

1. **安全建议**
   - ✅ 生产环境必须设置强密码
   - ✅ 仅在内网访问，不要开启公网访问
   - ✅ 定期更新 Redis 镜像版本
   - ✅ 监控异常访问

2. **性能优化**
   - 根据实际使用情况调整 `maxmemory` 和 `maxmemory-policy`
   - 合理配置 RDB 和 AOF 持久化策略
   - 使用连接池管理连接
   - 监控内存使用情况

3. **数据备份**
   - 定期备份 `/data` 目录下的数据文件
   - 使用数据卷确保数据持久化
   - 考虑使用 Redis 主从复制

## 📚 相关资源

- [Redis 官方文档](https://redis.io/documentation)
- [Docker 官方文档](https://docs.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)
- [Jedis GitHub](https://github.com/redis/jedis)
- [微信云托管文档](https://developers.weixin.qq.com/miniprogram/dev/wxcloud/basis/getting-started.html)

## 📄 许可证

本项目采用 MIT 许可证。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**如有问题，请查看故障排查部分或提交 Issue。**
