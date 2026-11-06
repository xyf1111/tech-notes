---
title: "Kubernetes 01 - 基础架构与核心概念"
date: 2026-06-11
tags: [devops, kubernetes]
---

# Kubernetes 01 - 基础架构与核心概念

## 什么是 Kubernetes

Kubernetes（K8s）是**容器编排平台**，自动管理容器的部署、扩缩容、服务发现和负载均衡。

## 架构组件

```
┌──────────────────┐     ┌──────────────────┐
│   Control Plane   │     │     Node (Worker) │
│                   │     │                  │
│  API Server       │◄────│  kubelet         │
│  Scheduler        │     │  kube-proxy      │
│  Controller Mgr   │     │  容器运行时 (containerd)│
│  etcd (键值存储)  │     │  Pod / Pod / Pod │
└──────────────────┘     └──────────────────┘
```

### Control Plane（主节点）

| 组件 | 作用 |
|------|------|
| **API Server** | 集群入口，所有组件通过 API 通信 |
| **Scheduler** | 将 Pod 调度到合适的 Node |
| **Controller Manager** | 运行各种控制器（Deployment、Node、Namespace 等） |
| **etcd** | 分布式键值存储，保存集群状态 |

### Worker Node（工作节点）

| 组件 | 作用 |
|------|------|
| **kubelet** | 管理 Pod 和容器的生命周期 |
| **kube-proxy** | 维护网络规则，实现 Service 负载均衡 |
| **容器运行时** | containerd / Docker / CRI-O |

## 核心资源对象

| 资源 | 说明 |
|------|------|
| **Pod** | 最小部署单元，一个或多个容器 |
| **Deployment** | 管理 Pod 副本、滚动更新、回滚 |
| **Service** | 稳定的网络入口，负载均衡到 Pod |
| **ConfigMap / Secret** | 配置和敏感信息管理 |
| **Ingress** | HTTP/HTTPS 路由到 Service |
| **PersistentVolume (PV)** | 存储资源 |
| **Namespace** | 资源隔离（逻辑集群） |
