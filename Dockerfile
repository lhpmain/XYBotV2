# 使用更小的基础镜像
FROM python:3.11-slim-buster

# 创建工作目录并设置工作目录
WORKDIR /app

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV IMAGEIO_FFMPEG_EXE=/usr/bin/ffmpeg
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# 安装系统依赖并清理缓存
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# 检查 redis-server 是否安装成功
RUN which redis-server

# 复制 Redis 配置
COPY redis.conf /etc/redis/redis.conf

# 复制依赖文件并安装 Python 依赖
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn eventlet

# 复制应用代码
COPY . /app/

# 定义卷
VOLUME /app/resource
VOLUME /app/logs
VOLUME /app/flask_session

# 暴露端口
EXPOSE 9000

# 创建启动脚本
RUN echo '#!/bin/bash \n \
redis-server /etc/redis/redis.conf --daemonize yes \n \
python app.py' > /app/start.sh \
    && chmod +x /app/start.sh

# 设置启动命令
CMD ["/app/start.sh"]