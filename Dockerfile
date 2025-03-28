FROM python:3.11-slim

COPY . /app    # 将当前目录下的文件复制到容器的 /app 目录

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV TZ=Asia/Shanghai
ENV IMAGEIO_FFMPEG_EXE=/usr/bin/ffmpeg

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    ffmpeg \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# 复制 Redis 配置
COPY redis.conf /etc/redis/redis.conf

# 复制文件
# COPY requirements.txt /app
# COPY app.py /app

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt
# 安装gunicorn和eventlet
RUN pip install --no-cache-dir gunicorn eventlet

CMD ["python", "app.py"]



