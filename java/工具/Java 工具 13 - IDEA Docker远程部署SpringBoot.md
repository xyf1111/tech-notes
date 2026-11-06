---
title: "Java 工具 13 - IDEA Docker远程部署SpringBoot"
date: 2026-07-22
tags: [java, springboot, devops, docker, deployment, idea]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 13 - IDEA Docker远程部署SpringBoot

> 在 IDEA 中通过 Docker 远程一键部署 SpringBoot 项目，替代手动上传 jar + `java -jar` 的传统流程。

## 传统 Jar 包部署 vs IDEA Docker 远程部署

| 对比项 | Jar 包部署 | IDEA Docker 远程部署 |
|--------|-----------|-------------------|
| 部署操作 | 停止项目 → 上传 jar → 启动 | 点击绿色三角按钮一键完成 |
| 日志查看 | SSH 登录后 tail | IDEA 控制台直接查看 |
| 环境一致性 | 需手动安装 JDK | 容器化，依赖由 Dockerfile 声明 |

## 前置准备

- 服务器已安装 Docker
- 本地已安装 IntelliJ IDEA
- 一个可正常打包为 jar 的 SpringBoot 项目

## 配置步骤

### 1. SSH 配置

`File → Settings → SSH` 添加服务器连接：

- **推荐** 使用 `Key pair`（密钥对）连接，更稳定
- 嫌麻烦可使用 `Password` 连接，后续有问题再切换

### 2. 连接 Docker 守护进程

`File → Settings → Docker` 添加 Docker 守护进程连接，配置 TCP 地址即可。

**Docker daemon** 是运行在宿主机上的持续服务，负责容器的创建、运行、停止等操作，是 Docker 引擎的核心组件，功能包括：

| 功能 | 说明 |
|------|------|
| 容器管理 | 创建、运行、停止、删除容器的生命周期管理 |
| 镜像管理 | 从仓库下载镜像、构建、打包、发布和分发镜像 |
| 网络管理 | 为每个容器分配唯一 IP，提供容器间及容器与宿主机通信 |
| 存储管理 | 管理容器文件系统、数据卷和持久化存储 |

### 3. 编写 Dockerfile

在项目根目录创建 `Dockerfile`：

```dockerfile
# 基础镜像
FROM openjdk:17
# 复制主机 jar 包至镜像内（需与 Dockerfile 同级）
ADD target/demo-0.0.1-SNAPSHOT.jar app.jar
# 容器启动命令
ENTRYPOINT ["java","-jar", "/app.jar" , "--spring.profiles.active=prod"]
# 对外暴露端口
EXPOSE  8080
```

### 4. 创建远程部署配置

1. `Run → Edit Configurations → + → Docker → Dockerfile`
2. 选择 Dockerfile 路径，绑定容器端口到宿主机端口
3. 选择之前配置的 Docker 守护进程

### 5. 一键部署

点击绿色三角运行按钮，IDEA 自动完成：

- 构建项目（可选）
- 构建 Docker 镜像并推送到服务器
- 在服务器上运行容器
- 在 IDEA 控制台实时显示日志

> 首次配置虽然步骤较多，但后续每次部署只需点击一次即可完成。

> 来源：鱼皮·编程导航 / codefather
