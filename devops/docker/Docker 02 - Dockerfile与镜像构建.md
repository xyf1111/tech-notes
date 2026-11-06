---
title: "Docker 02 - Dockerfile与镜像构建"
date: 2026-06-11
tags: [devops, docker]
---

# Docker 02 - Dockerfile与镜像构建

## Dockerfile 指令

| 指令 | 说明 |
|------|------|
| `FROM` | 基础镜像 |
| `WORKDIR` | 工作目录 |
| `COPY` | 复制文件到镜像 |
| `ADD` | 复制文件（支持 tar 自动解压、URL）|
| `RUN` | 执行命令（构建时） |
| `CMD` | 容器启动时的默认命令（可被覆盖） |
| `ENTRYPOINT` | 容器启动入口（不可被覆盖） |
| `ENV` | 环境变量 |
| `EXPOSE` | 声明容器端口 |
| `ARG` | 构建参数 |

### CMD vs ENTRYPOINT

```dockerfile
# CMD 可被 docker run 命令参数覆盖
CMD ["nginx", "-g", "daemon off;"]
# docker run my-nginx -c /etc/nginx/custom.conf  # 覆盖 CMD

# ENTRYPOINT 固定入口，CMD 作为默认参数
ENTRYPOINT ["python"]
CMD ["app.py"]
# docker run my-py -m pytest  # ENTRYPOINT=python, CMD 被覆盖为 -m pytest
```

## 多阶段构建

减小最终镜像大小，构建产物与构建环境分离：

```dockerfile
# 阶段 1：构建
FROM golang:1.22 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o main .

# 阶段 2：运行（精简镜像）
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
CMD ["./main"]
```

## 镜像体积优化

1. **选择小基础镜像** — `alpine` (5MB) vs `ubuntu` (200MB+)
2. **多阶段构建** — 构建环境与运行环境分离
3. **合并 RUN 命令** — 减少镜像层数
4. **清理缓存** — `rm -rf /var/lib/apt/lists/*`
5. **`.dockerignore`** — 排除无关文件

```dockerfile
# 优化前
FROM ubuntu
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get clean

# 优化后
FROM alpine:latest
RUN apk --no-cache add curl
```
