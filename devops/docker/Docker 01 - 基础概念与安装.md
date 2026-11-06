---
title: "Docker 01 - 基础概念与安装"
date: 2026-06-11
tags: [devops, docker]
---

# Docker 01 - 基础概念与安装

## 什么是 Docker

Docker 是一个**容器化平台**，将应用及其依赖打包到轻量级、可移植的容器中运行。

### 容器 vs 虚拟机

| 对比 | 容器 (Docker) | 虚拟机 (VM) |
|------|-------------|-------------|
| 启动速度 | 秒级 | 分钟级 |
| 内核 | 共享宿主机内核 | 独立内核 |
| 资源占用 | 低（MB 级） | 高（GB 级） |
| 隔离性 | 进程级隔离 | 完全隔离 |
| 镜像大小 | MB 级 | GB 级 |

## 核心概念

| 概念 | 说明 |
|------|------|
| **镜像 (Image)** | 只读模板，包含运行环境 + 应用代码 |
| **容器 (Container)** | 镜像的运行实例，可启动/停止/删除 |
| **仓库 (Registry)** | 存储和分发镜像：Docker Hub、阿里云 ACR、Harbor |
| **Dockerfile** | 构建镜像的自动化脚本 |
| **Volumes** | 持久化数据存储 |

## 常用命令

```bash
# 镜像管理
docker image pull nginx:latest     # 拉取镜像
docker image ls                    # 查看镜像
docker image rmi nginx             # 删除镜像
docker image build -t my-app .     # 构建镜像

# 容器管理
docker container run -d --name web -p 80:80 nginx   # 运行容器
docker container ls                # 查看运行中容器（-a 含停止的）
docker container stop web          # 停止容器
docker container rm web            # 删除容器
docker container exec -it web bash # 进入容器

# 日志与监控
docker logs -f web                 # 查看日志
docker stats                       # 查看资源占用

# 简写（大部分命令可省略 container）
docker ps -a
docker run -d -p 8080:80 nginx
docker stop <container_id>
docker rm <container_id>
```
