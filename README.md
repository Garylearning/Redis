# Redis Docker 部署

使用 Dockerfile 构建 Redis 服务器镜像，适用于微信云托管部署。

## Dockerfile 说明

这个 Dockerfile 会构建一个 Redis 7 服务器，支持通过环境变量设置密码。

## 在 IDEA 中运行和调试

### 方法一：使用 IDEA 的 Docker 插件（推荐）

#### 1. 安装 Docker 插件

1. 打开 IDEA，进入 `File` -> `Settings` (Windows) 或 `IntelliJ IDEA` -> `Preferences` (Mac)
2. 选择 `Plugins`
3. 搜索 "Docker" 并安装
4. 重启 IDEA

#### 2. 配置 Docker 连接

1. 进入 `File` -> `Settings` -> `Build, Execution, Deployment` -> `Docker`
2. 点击 `+` 添加 Docker 连接
3. 选择 `Docker for Windows` (Windows) 或 `Docker` (Mac/Linux)
4. 点击 `Apply` 和 `OK`

#### 3. 构建镜像

**方式 A：使用 IDEA 界面**

1. 在项目根目录找到 `Dockerfile`
2. 右键点击 `Dockerfile`
3. 选择 `Build Image...`
4. 输入镜像名称：`redis:wechat-cloud`
5. 点击 `OK` 开始构建

**方式 B：使用 Terminal**

在 IDEA 底部的 Terminal 中执行：

```bash
docker build -t redis:wechat-cloud .
```

#### 4. 运行容器

**方式 A：使用 IDEA 界面**

1. 打开 IDEA 右侧的 `Services` 窗口（`View` -> `Tool Windows` -> `Services`）
2. 展开 `Docker` 节点
3. 找到 `redis:wechat-cloud` 镜像
4. 右键点击镜像，选择 `Create Container...`
5. 配置容器：
   - **Container name**: `redis-server`
   - **Port bindings**: 点击 `+` 添加端口映射 `6379:6379`
   - **Environment variables**: 点击 `+` 添加 `REDIS_PASSWORD=your_password`（可选）
   - **Volume bindings**: 可选，添加数据持久化卷
6. 点击 `Run` 启动容器

**方式 B：使用 Terminal**

在 IDEA Terminal 中执行：

```bash
# 运行容器（带密码）
docker run -d \
  --name redis-server \
  -p 6379:6379 \
  -e REDIS_PASSWORD=your_password \
  redis:wechat-cloud

# 或运行容器（无密码）
docker run -d \
  --name redis-server \
  -p 6379:6379 \
  redis:wechat-cloud
```

#### 5. 查看日志

**在 IDEA 中：**

1. 打开 `Services` 窗口
2. 展开 `Docker` -> `Containers`
3. 找到 `redis-server` 容器
4. 右键点击，选择 `Show Logs`

**或使用 Terminal：**

```bash
docker logs redis-server
docker logs -f redis-server  # 实时查看日志
```

#### 6. 测试连接

在 IDEA Terminal 中执行：

```bash
# 测试连接（带密码）
docker exec -it redis-server redis-cli -a your_password ping

# 进入交互式 CLI（带密码）
docker exec -it redis-server redis-cli -a your_password

# 进入交互式 CLI（无密码）
docker exec -it redis-server redis-cli
```

### 方法二：创建运行配置（Run Configuration）

#### 1. 创建 Docker 运行配置

1. 点击 IDEA 顶部工具栏的 `Run` -> `Edit Configurations...`
2. 点击左上角 `+`，选择 `Docker` -> `Dockerfile`
3. 配置：
   - **Name**: `Redis Server`
   - **Dockerfile**: 选择项目中的 `Dockerfile`
   - **Image tag**: `redis:wechat-cloud`
   - **Container name**: `redis-server`
   - **Bind ports**: `6379:6379`
   - **Environment variables**: `REDIS_PASSWORD=your_password`（可选）
4. 点击 `OK` 保存

#### 2. 运行和调试

1. 选择刚创建的 `Redis Server` 配置
2. 点击运行按钮（绿色三角形）或按 `Shift + F10`
3. 在 `Services` 窗口中查看容器状态和日志

### 方法三：使用 IDEA Terminal（最简单）

直接在 IDEA 的 Terminal 中执行 Docker 命令：

```bash
# 1. 构建镜像
docker build -t redis:wechat-cloud .

# 2. 运行容器
docker run -d --name redis-server -p 6379:6379 -e REDIS_PASSWORD=your_password redis:wechat-cloud

# 3. 查看日志
docker logs -f redis-server

# 4. 测试连接
docker exec -it redis-server redis-cli -a your_password ping
```

## 常用调试命令

### 查看容器状态

```bash
# 查看运行中的容器
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 查看容器详细信息
docker inspect redis-server
```

### 进入容器调试

```bash
# 进入容器 shell
docker exec -it redis-server sh

# 在容器内执行 Redis 命令
docker exec -it redis-server redis-cli -a your_password
```

### 查看 Redis 信息

```bash
# 查看 Redis 服务器信息
docker exec redis-server redis-cli -a your_password INFO

# 查看内存使用
docker exec redis-server redis-cli -a your_password INFO memory

# 查看客户端连接
docker exec redis-server redis-cli -a your_password CLIENT LIST
```

### 停止和删除

```bash
# 停止容器
docker stop redis-server

# 启动已停止的容器
docker start redis-server

# 删除容器
docker rm redis-server

# 删除镜像
docker rmi redis:wechat-cloud
```

## 在 Java 项目中连接 Redis

### 添加依赖（Maven）

```xml
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>4.3.1</version>
</dependency>
```

### 连接示例

```java
import redis.clients.jedis.Jedis;

public class RedisTest {
    public static void main(String[] args) {
        // 连接 Redis（如果设置了密码）
        Jedis jedis = new Jedis("localhost", 6379);
        jedis.auth("your_password");
        
        // 测试连接
        String pong = jedis.ping();
        System.out.println("Ping: " + pong);
        
        // 设置和获取值
        jedis.set("test_key", "Hello Redis");
        String value = jedis.get("test_key");
        System.out.println("Value: " + value);
        
        jedis.close();
    }
}
```

## 故障排查

### 容器无法启动

```bash
# 查看详细错误日志
docker logs redis-server

# 检查端口是否被占用
netstat -ano | findstr 6379  # Windows
lsof -i :6379  # Mac/Linux
```

### 无法连接 Redis

1. 确认容器正在运行：`docker ps`
2. 检查端口映射：`docker port redis-server`
3. 查看容器日志：`docker logs redis-server`
4. 测试容器内连接：`docker exec redis-server redis-cli ping`

### 密码认证失败

```bash
# 检查环境变量
docker inspect redis-server | findstr REDIS_PASSWORD

# 尝试不使用密码连接（如果未设置密码）
docker exec -it redis-server redis-cli
```

## 部署到微信云托管

1. 将 `Dockerfile` 上传到代码仓库
2. 在微信云托管控制台创建服务
3. 选择代码部署，微信云托管会自动识别 Dockerfile
4. 设置环境变量 `REDIS_PASSWORD`（可选）
5. 部署即可

