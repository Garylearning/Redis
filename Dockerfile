# Redis Docker 镜像
# 使用说明：
#   构建镜像: docker build -t redis:wechat-cloud .
#   运行容器（映射端口）: docker run -d --name redis-server -p 6379:6379 redis:wechat-cloud
#   带密码运行: docker run -d --name redis-server -p 6379:6379 -e REDIS_PASSWORD=your_password redis:wechat-cloud

# 使用官方 Redis 镜像
FROM redis:7-alpine

# 设置工作目录
WORKDIR /data

# 创建数据目录
RUN mkdir -p /data

# 创建启动脚本，支持环境变量密码和自定义配置
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'set -e' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 如果设置了密码，添加到启动参数' >> /entrypoint.sh && \
    echo 'if [ -n "$REDIS_PASSWORD" ]; then' >> /entrypoint.sh && \
    echo '    set -- "$@" --requirepass "$REDIS_PASSWORD"' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 如果设置了最大内存，添加到启动参数' >> /entrypoint.sh && \
    echo 'if [ -n "$REDIS_MAXMEMORY" ]; then' >> /entrypoint.sh && \
    echo '    set -- "$@" --maxmemory "$REDIS_MAXMEMORY"' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 启用 AOF 持久化（默认启用，可通过 REDIS_AOF=false 禁用）' >> /entrypoint.sh && \
    echo 'if [ "$REDIS_AOF" != "false" ]; then' >> /entrypoint.sh && \
    echo '    set -- "$@" --appendonly yes' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# 执行 Redis 服务器' >> /entrypoint.sh && \
    echo 'exec redis-server "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# 暴露 Redis 默认端口
# 注意：EXPOSE 只是声明端口，真正的端口映射需要在运行容器时使用 -p 参数
# 例如：docker run -p 6379:6379 ... 将容器的 6379 端口映射到主机的 6379 端口
# 也可以映射到其他端口：docker run -p 6380:6379 ... 将容器的 6379 端口映射到主机的 6380 端口
EXPOSE 6379

# 设置数据卷（用于数据持久化）
VOLUME ["/data"]

# 使用启动脚本启动 Redis
ENTRYPOINT ["/entrypoint.sh"]

