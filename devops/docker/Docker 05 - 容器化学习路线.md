---
title: "Docker 05 - 容器化学习路线"
date: 2026-07-19
tags: [devops, docker]
source: "鱼皮·编程导航 / codefather"
---

# Docker 05 - 容器化学习路线

> Docker 容器化技术学习路径，从零基础到实战部署的系统路线。

## 学习前提

- **Linux 基础** — 基本命令（cd、ls、cp、mv、rm、cat、grep 等）
- **网络基础** — IP 地址、端口、HTTP 等基本概念
- **编程基础** — 至少掌握一门语言（Java、Python、Node.js 等），便于编写 Dockerfile

## 整体学习建议

1. Docker 实践性强，务必在服务器或本地安装后动手操作
2. 先运行简单容器（Nginx、MySQL）理解基本概念，再逐步深入
3. 理解 Docker 与虚拟机的本质区别：容器共享宿主机内核，非独立 OS
4. 优先使用 Docker Hub 官方镜像
5. Dockerfile 可借助 AI 生成，关注构建流程即可
6. 注意安全性：生产环境使用非 root 用户、限制容器权限
7. K8s 是 Docker 之上的编排平台，建议先掌握 Docker 再学 K8s

## 阶段 1：Docker 基础

### 知识点

**基础概念（必学）：**
- 容器化概念：容器 vs 虚拟机
- Docker 架构：Engine、Client、Daemon
- 核心概念：镜像（Image）、容器（Container）、仓库（Registry）

**环境搭建：**
- Docker 安装（Linux/Windows/macOS）
- 国内镜像加速配置
- 验证：`docker version`、`docker info`

**基础命令：**
- 镜像管理：`pull`、`images`、`rmi`
- 容器管理：`run`、`ps`、`stop`、`rm`
- 容器交互：`exec`、`logs`、`inspect`

**练手：** 运行 Hello World、Nginx、MySQL 容器

### 学习资源
- [Docker 官方文档](https://docs.docker.com/)
- [Docker 从入门到实践](https://yeasy.gitbook.io/docker_practice/)（GitHub 开源中文书籍）
- [尚硅谷 Docker 教程](https://www.bilibili.com/video/BV1gr4y1U7CY)

## 阶段 2：镜像与容器深入

### 知识点

**镜像原理：**
- 分层结构（UnionFS、写时复制）
- 标签管理（Tag）
- 镜像仓库：Docker Hub、私有仓库
- 导入导出：`docker save` / `docker load`

**容器生命周期：**
- 状态：Created → Running → Paused → Stopped → Exited
- 日志查看：`docker logs -f`
- 资源监控：`docker stats`

**宿主机交互：**
- 端口映射：`-p 宿主机端口:容器端口`
- 文件拷贝：`docker cp`
- 进入容器：`docker exec -it`
- 容器网络模式：bridge、host、none

### 学习重点

镜像分层是 Docker 高效的关键——每层镜像只读，容器运行时在顶层创建可写层。`latest` 标签不建议生产环境使用。端口映射格式 `-p 8080:80` 将容器 80 端口映射到宿主机 8080 端口。

## 阶段 3：网络与数据卷

### 知识点

**网络：**
- 四种模式：bridge、host、none、container
- 自定义网络：`docker network create`
- 容器互联：同一网络内通过容器名通信
- 网络驱动：bridge、overlay、macvlan

**数据卷：**
- 数据卷（Volume）：`docker volume create/ls/rm`
- 挂载：`-v` / `--mount`（推荐 `--mount`，语法更清晰）
- 绑定挂载（Bind Mount）：挂载宿主机目录
- 数据卷容器

**实战：** MySQL 数据持久化、Nginx 配置持久化

## 阶段 4：Dockerfile 最佳实践

### 知识点

**基础指令：** FROM、RUN、COPY、ADD、WORKDIR、EXPOSE、CMD、ENTRYPOINT
**进阶指令：** ENV、ARG、VOLUME、HEALTHCHECK、ONBUILD、多阶段构建

**最佳实践：**
- 合并 RUN 指令减少镜像层数
- 合理排列指令顺序利用构建缓存
- 使用 `.dockerignore`
- 选择合适的基础镜像：Alpine（小体积）vs Debian（稳定性）
- 使用非 root 用户运行
- 清理临时文件

**镜像优化：**
- 多阶段构建可减少 90%+ 体积（第一阶段编译，第二阶段仅运行时文件）
- 镜像安全扫描：Trivy、docker scan

> CMD vs ENTRYPOINT：CMD 定义默认命令，可被 `docker run` 参数覆盖；ENTRYPOINT 定义固定命令，不可覆盖。

## 阶段 5：Docker Compose

通过 `docker-compose.yml` 管理多容器应用，一条命令启动整个服务栈。

### 配置项

| 配置 | 说明 |
|------|------|
| services | 定义多个服务 |
| image / build | 指定镜像 / 构建 |
| ports | 端口映射 |
| volumes | 数据卷挂载 |
| environment | 环境变量 |
| depends_on | 服务依赖顺序 |
| networks | 自定义网络 |
| restart | 重启策略 |

**注意：** `depends_on` 仅保证容器启动顺序，不保证服务就绪状态。需使用 `wait-for-it.sh` 等脚本等待服务就绪。

## 阶段 6：Kubernetes 入门（可选）

### 核心概念

- Pod：最小调度单元
- Deployment：管理 Pod 副本数
- Service：服务发现与负载均衡
- ConfigMap / Secret：配置管理
- Ingress：HTTP/HTTPS 路由

> 建议先熟练掌握 Docker，再学习 K8s。若时间有限可跳过，工作中需要时再学。

## 面试题库

- [面试鸭 - Docker 面试题](https://www.mianshiya.com/bank/1812067352871829505)

> 来源：鱼皮·编程导航 / codefather
