---
title: "DevOps 03 - 云原生学习路线"
date: 2026-08-08
tags: [devops, 云原生, kubernetes, docker, 学习路线]
source: "鱼皮·编程导航 / codefather"
---

# DevOps 03 - 云原生学习路线

> 云原生（Cloud Native）是一种构建和运行应用的**方法论**，充分利用云计算的优势，构建弹性、可扩展、易于管理的应用。核心技术包括容器化（Docker）、容器编排（Kubernetes）、微服务架构、服务网格、声明式 API 与 DevOps 方法论，其中 Kubernetes 是容器编排的事实标准。
>
> **学习前提**：Linux 基础（必学）、编程基础，至少会一门语言如 Java/Go/Python（必学）、微服务基础（建议）、网络基础 TCP/IP/HTTP（建议）。
>
> **就业方向**：云原生开发工程师、Kubernetes 工程师（集群搭建与管理）、云原生架构师、DevOps 工程师（CI/CD 与自动化运维）、SRE 工程师（可靠性工程）。

## 整体学习建议

1. **先学好 Docker** — 容器化是云原生的基础，理解容器的概念、镜像的构建、容器的运行
2. **重点学习 Kubernetes** — K8s 是云原生核心技术，概念多、难度大，要有耐心，边学边实践
3. **一定要动手实践** — 用 Minikube 或 Kind 搭建自己的 K8s 集群，部署应用观察运行效果
4. **关注 CNCF 生态** — CNCF 有大量优秀开源项目（Prometheus、Envoy、Helm 等），目标大厂或高级工程师必看

> 本路线是云原生全栈总路线；Docker、Kubernetes 的专项深入可结合 [[devops/docker/Docker 05 - 容器化学习路线]]、[[devops/kubernetes/Kubernetes 05 - 学习路线]]，以及总览 [[devops/DevOps 00 - 学习路线]]。

## 阶段 1：容器化基础（Docker）（15-25 天，仅供参考）

### 学习目标

掌握 Docker 容器技术，能够容器化应用。容器相比虚拟机更轻量、启动更快、资源利用率更高，是云原生的第一步。

### 知识点

| 分类 | 内容 |
|------|------|
| **Docker 基础**（必学） | 容器和虚拟机的区别、Docker 安装和使用、镜像（Image）和容器（Container）、常用命令（run、pull、push、build 等） |
| **Dockerfile**（必学） | 编写 Dockerfile、常用指令（FROM、RUN、COPY、CMD、ENTRYPOINT 等）、镜像的分层结构、多阶段构建 |
| **Docker Compose**（必学） | 使用、docker-compose.yml 配置、多容器应用 |
| **镜像仓库**（建议） | Docker Hub、阿里云镜像仓库、Harbor 私有仓库（可不学） |

### 学习建议

1. Dockerfile 是构建镜像的脚本，要掌握编写技巧。多阶段构建可以减小镜像体积、提高安全性
2. Docker Compose 可以定义和运行多容器应用，适合本地开发和测试；生产环境一般使用 Kubernetes

### 资源

- [Docker 官方文档](https://docs.docker.com/)：官方文档
- 专项深入：[[devops/docker/Docker 05 - 容器化学习路线]]

## 阶段 2：Kubernetes 容器编排（20-40 天，仅供参考）

### 学习目标

掌握 Kubernetes，能够部署和管理容器化应用。K8s 是云原生核心技术，概念多、学习曲线较陡，建议先掌握核心概念（Pod、Service、Deployment），再逐步学习高级特性。

### 知识点

| 分类 | 内容 |
|------|------|
| **Kubernetes 基础**（必学） | 架构、核心概念（Pod、Service、Deployment、Namespace）、kubectl 命令、YAML 配置文件 |
| **工作负载**（必学） | Deployment（无状态应用）、StatefulSet（有状态应用）、DaemonSet、Job 和 CronJob |
| **服务发现和负载均衡**（必学） | Service（ClusterIP、NodePort、LoadBalancer）、Ingress、Ingress Controller |
| **配置和存储**（必学） | ConfigMap 和 Secret、Volume 和 PersistentVolume、StorageClass |
| **Helm**（建议） | Helm 的使用、Chart 的编写 |

### 学习建议

1. Pod 是 K8s 的最小调度单元，一般包含一个或多个容器；Deployment 用于管理 Pod，提供滚动更新、回滚等功能
2. Service 提供服务发现和负载均衡，让 Pod 之间可以相互访问；Ingress 提供 HTTP 路由，让外部可以访问集群内的服务

### 资源

- [Kubernetes 官网](https://kubernetes.io/zh-cn/)：官方文档
- [云原生 Kubernetes 教程（B站）](https://www.bilibili.com/video/BV13Q4y1C7hS)：K8s + Docker + KubeSphere + DevOps（实战时注意部分配置可能已调整）
- [云原生实战（KubeSphere 官方教程）](https://kubesphere.io/zh/learn/)
- 专项深入：[[devops/kubernetes/Kubernetes 05 - 学习路线]]

## 阶段 3：微服务架构（15-25 天，仅供参考）

### 学习目标

云原生应用一般采用微服务架构，要理解微服务的设计原则和最佳实践，掌握微服务开发和部署。微服务是将应用拆分为多个独立服务的设计模式，配合容器和编排工具实现灵活的云原生应用。

### 知识点

| 分类 | 内容 |
|------|------|
| **微服务基础**（必学） | 微服务架构的特点、服务拆分和设计、微服务的通信（REST、gRPC） |
| **Spring Cloud / Go Micro**（建议） | 服务注册和发现、服务网关、配置中心、熔断降级 |
| **云原生应用开发**（必学） | 12 因素应用、无状态设计、配置外部化、健康检查 |

### 学习建议

1. 12 因素应用是云原生应用的设计准则，涵盖代码库、依赖管理、配置、后端服务等 12 个方面，要理解每条准则的含义
2. 云原生应用要设计为**无状态**，状态存储在外部（如数据库、缓存），这样可以方便地水平扩展和故障恢复

### 资源

- [12 因素应用](https://12factor.net/zh_cn/)：云原生应用设计准则

## 阶段 4：服务网格 Service Mesh（10-20 天，仅供参考）

### 学习目标

理解服务网格的概念，掌握 Istio 的基本使用。Service Mesh 是云原生的高级特性，用于管理微服务之间的通信，在应用无感知的情况下提供流量管理、安全、监控等功能。

### 知识点

| 分类 | 内容 |
|------|------|
| **Service Mesh 基础**（必学） | 概念、数据平面和控制平面、Sidecar 模式 |
| **Istio**（建议） | 架构、流量管理、安全（mTLS）、可观测性 |
| **其他 Service Mesh**（可不学） | Linkerd、Consul Connect |

### 学习建议

1. Istio 是最流行的 Service Mesh 实现，基于 Envoy 代理；学习曲线较陡，建议先掌握 Kubernetes 再学 Istio
2. Service Mesh 相对复杂，了解即可；实际项目中不一定需要，要根据业务规模选择

### 资源

- [Istio 官方文档](https://istio.io/latest/zh/docs/)：官方文档

## 阶段 5：可观测性（10-20 天，仅供参考）

### 学习目标

掌握云原生应用的监控、日志、追踪技术。可观测性是云原生的重要组成部分，包括监控（Metrics）、日志（Logging）、追踪（Tracing）三大支柱。

### 知识点

| 分类 | 内容 |
|------|------|
| **监控**（必学） | Prometheus（指标采集）、Grafana（可视化）、AlertManager（告警） |
| **日志**（必学） | EFK（Elasticsearch + Fluentd + Kibana）、日志采集和分析 |
| **分布式追踪**（建议） | Jaeger、链路追踪 |

### 学习建议

1. Prometheus 是云原生监控的标准，Grafana 是可视化的首选，要掌握 Prometheus 的使用和 PromQL 查询语言
2. 分布式追踪可以追踪请求在微服务之间的调用链路，帮助排查性能问题

### 资源

- [Prometheus 官方文档](https://prometheus.io/docs/introduction/overview/)：官方文档
- [Grafana 官方文档](https://grafana.com/docs/)：可视化工具
- [Prometheus + Grafana 监控视频教程（B站）](https://www.bilibili.com/video/BV1QPYDztEtW/)：大厂级别监控入门

## 阶段 6：项目实战（30-60 天，仅供参考）

### 学习目标

通过实际项目巩固所学知识，积累云原生项目经验。

### 学习建议

1. 搭建完整的云原生应用：从零开始搭建，包括容器化、K8s 部署、服务网格、监控等
2. 学习优秀开源项目：GitHub 上有很多云原生示例项目，可以学习其架构设计和实现
3. 部署到云平台：可以使用阿里云、腾讯云、AWS 等云平台，体验真实的云原生环境

### 项目推荐

| 级别 | 项目 |
|------|------|
| **入门级** | 微服务应用（Docker + K8s 部署）、云原生博客系统、在线商城（云原生架构） |
| **进阶级** | 完整的云原生平台（包括服务网格、监控等）、SaaS 平台（多租户、弹性伸缩） |

**优质开源项目：**

- [Microservices with Spring Docker Kubernetes](https://github.com/eazybytes/microservices)：基于 Spring、Docker、Kubernetes 的微服务示例项目
- [Kubernetes Examples](https://github.com/kubernetes/examples)：官方 Kubernetes 示例项目集合
- [CNCF Projects](https://github.com/CNCF)：云原生计算基金会官方项目仓库

### 资源

- [云原生实战（KubeSphere 官方教程）](https://kubesphere.io/zh/learn/)

## 阶段 7：求职备战

### 学习目标

熟练掌握云原生常见面试题，准备好简历和项目经历，顺利通过面试。

### 学习建议

1. 简历上一定要有云原生项目经历（Docker 容器化、Kubernetes 部署管理、微服务项目等），面试时要能清楚介绍项目的架构、技术选型、遇到的问题和解决方案
2. 多刷面试题：云原生面试题主要包括 Docker、Kubernetes、微服务、监控等方向

### 经典面试题

**容器化：**

1. 容器和虚拟机有什么区别？
2. Docker 的镜像是如何构建的？
3. Dockerfile 的最佳实践有哪些？
4. 如何优化 Docker 镜像体积？

**Kubernetes：**

1. Kubernetes 的架构是怎样的？
2. Pod、Service、Deployment 有什么区别？
3. 如何实现服务发现和负载均衡？
4. 如何实现应用的滚动更新？

**微服务：**

1. 什么是微服务？有什么优缺点？
2. 如何拆分微服务？
3. 微服务之间如何通信？
4. 如何保证微服务的可靠性？

**其他：**

1. 什么是云原生？有什么特点？
2. 什么是 Service Mesh？
3. 如何监控云原生应用？
4. 什么是 12 因素应用？

## 更多资源

### 云原生生态

- [CNCF 官网](https://www.cncf.io/)：云原生计算基金会
- [Kubernetes 官网](https://kubernetes.io/zh-cn/)：K8s 官方网站
- [云原生社区](https://cloudnative.to/)：中文社区
- [awesome-cloud-native](https://github.com/cubxxw/awesome-cloud-native)：云原生资源大全

### 技术博客

- [CNCF 博客](https://www.cncf.io/blog/)：云原生计算基金会官方博客
- [Google Cloud Blog](https://cloud.google.com/blog)：谷歌云原生实践
- [AWS Blog](https://aws.amazon.com/blogs/)：AWS 云原生服务
- [Netflix TechBlog](https://netflixtechblog.com/)：Netflix 云原生架构

## 尾声

云原生是当前企业级应用开发的主流方向，代表了现代应用架构和基础设施的发展趋势，可以提高应用的可靠性、可扩展性、可维护性，是每个开发者都应该了解的技术。

学习路径：先打好容器化基础（Docker），再学核心技术 Kubernetes，然后依次学习微服务、服务网格、可观测性等高级特性，最后多做实战项目，体验云原生的完整技术栈。

> 来源：鱼皮·编程导航 / codefather
