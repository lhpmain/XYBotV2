FROM python:3.11-slim as builder

# 创建工作目录
RUN mkdir -p /app

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 文件并安装依赖
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# 安装 gunicorn 和 eventlet
RUN pip install --no-cache-dir gunicorn eventlet

# 复制其他文件
COPY . /app

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV IMAGEIO_FFMPEG_EXE=/usr/bin/ffmpeg

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    redis-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 复制 Redis 配置
COPY redis.conf /etc/redis/redis.conf

# 给 entrypoint.sh 脚本添加可执行权限
COPY entrypoint.sh /app/
RUN chmod +x entrypoint.sh

# 多阶段构建的运行部分
FROM python:3.11-slim

# 从构建阶段复制文件
COPY --from=builder /app /app

# 设置工作目录
WORKDIR /app

# 定义卷
VOLUME /app

# 暴露端口
EXPOSE 9000

# 启动应用
ENTRYPOINT ["bash", "entrypoint.sh"]