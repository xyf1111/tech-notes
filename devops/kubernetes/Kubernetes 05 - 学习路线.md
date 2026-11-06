---
title: "DevOps - Kubernetes 学习路线"
date: 2026-07-25
tags: [Kubernetes, K8s, DevOps, 容器编排, 学习路线]
source: "鱼皮·编程导航 / codefather"
---

# DevOps - Kubernetes 学习路线

> Kubernetes（K8s）是 Google 开源的容器编排平台，云原生计算基金会核心项目。自动化部署、扩展和管理容器化应用，是云计算时代的基础设施。

## 学习前提

- **Docker 基础**：容器创建、镜像、Dockerfile（必须）
- **Linux 基础**：Linux 命令、Shell 脚本（建议）
- **网络基础**：TCP/IP、HTTP（建议）
- **YAML 语法**：K8s 配置文件使用 YAML（必须）

## 学习路线图

![](../../image/img_k8s_roadmap.png)

## 就业方向

| 岗位 | 说明 |
|------|------|
| DevOps 工程师 | 持续集成/持续部署 |
| 云原生工程师 | 云原生应用开发和运维 |
| 运维工程师 | K8s 集群部署和管理 |
| 后端开发工程师 | 使用 K8s 部署后端服务 |
| 架构师 | 设计云原生架构 |

## 整体学习建议

1. 先掌握 Docker 基础，再学习 K8s
2. 学习必须结合实践，本地或云上搭建集群

**本地学习环境选择：**
| 工具 | 适用场景 | 要求 |
|------|----------|------|
| Minikube | 功能最完整 | 8GB+ 内存 |
| k3s | 资源占用低 | 4-8GB，推荐低配 |
| Kind | 启动快，基于 Docker | 快速测试 |

3. 优先查阅官方文档，AI 辅助理解概念

## 阶段 1：Kubernetes 基础（5-10 天）

**核心概念：**
- 容器编排 vs Docker Swarm、云原生概念

**K8s 架构：**
| 组件 | 角色 |
|------|------|
| **Master 节点** | 控制平面 |
| ├ API Server | 集群入口 |
| ├ Controller Manager | 控制器管理器 |
| ├ Scheduler | 调度器 |
| └ etcd | 分布式键值存储 |
| **Worker 节点** | 工作节点 |
| ├ Kubelet | 节点代理 |
| ├ Kube-proxy | 网络代理 |
| └ Container Runtime | 容器运行时 |

**集群搭建：**
- 本地：Minikube / Kind / k3s
- 生产：Kubeadm / Rancher
- 云平台：阿里云 ACK、腾讯云 TKE、华为云 CCE

**kubectl 命令：** 安装配置、get/describe/create/delete/apply、logs、exec

## 阶段 2：核心对象（7-15 天）

**Pod [必学]：** 最小调度单元，可包含一个或多个容器，理解生命周期
**Deployment [必学]：** Pod 控制器，管理副本数、滚动更新、回滚
**Service [必学]：** 稳定网络入口，类型（ClusterIP、NodePort、LoadBalancer），服务发现
**Namespace [必学]：** 资源隔离
**Label 和 Selector [必学]：** 资源标签和选择

## 阶段 3：服务发现和负载均衡（3-7 天）

**Ingress [必学]：** 七层负载均衡，域名/路径路由
- Ingress Controller（Nginx Ingress Controller）
- Service 是四层负载均衡，Ingress 是七层

## 阶段 4：存储和配置（3-7 天）

**ConfigMap 和 Secret [必学]：** 配置管理和敏感信息管理
**存储 [建议学]：** Volume、PersistentVolume、PersistentVolumeClaim、StorageClass

## 阶段 5：求职备战

**经典面试题：**
- K8s 与 Docker 区别、架构（Master/Worker 节点）
- Pod、Deployment、Service、Ingress 概念和区别
- 自动扩缩容实现、服务发现机制
- ConfigMap 与 Secret 区别

> 来源：鱼皮·编程导航 / codefather
