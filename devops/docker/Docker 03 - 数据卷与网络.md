---
title: "Docker 03 - 数据卷与网络"
date: 2026-06-11
tags: [devops, docker]
---

# Docker 03 - 数据卷与网络

## 数据持久化

### Volumes（推荐）

由 Docker 管理，存储在 `/var/lib/docker/volumes/`：

```bash
# 创建卷
docker volume create my-data

# 挂载卷
docker run -d -v my-data:/data nginx

# 查看卷
docker volume ls
docker volume inspect my-data
```

### Bind Mounts

挂载宿主机目录到容器：

```bash
docker run -d -v /host/path:/container/path nginx
docker run -d --mount type=bind,source=/host/path,target=/container/path nginx

# 开发常用：源码目录挂载
docker run -d -v $(pwd):/app -w /app node npm run dev
```

### tmpfs Mounts

挂载到内存（临时文件，速度快）：

```bash
docker run -d --tmpfs /tmp:size=100M nginx
```

## Docker 网络

### 网络类型

| 网络模式 | 说明 | 适用场景 |
|----------|------|----------|
| **bridge** | 默认，容器通过虚拟网桥通信 | 单机容器间通信 |
| **host** | 直接使用宿主机网络栈 | 性能要求高 |
| **none** | 无网络 | 安全隔离 |
| **overlay** | 跨宿主机网络（Swarm/K8s） | 多机集群 |

### 自定义 bridge 网络

```bash
# 创建自定义桥接网络
docker network create my-net

# 容器加入自定义网络
docker run -d --network my-net --name web nginx
docker run -d --network my-net --name app app-image

# 自定义网络支持 DNS 解析（容器名互相访问）
docker exec app ping web  # 可通
```

### 端口映射

```bash
docker run -p 宿主机端口:容器端口 nginx
docker run -p 8080:80 -p 443:443 nginx
```
