---
title: "RabbitMQ 09 - 集群与高可用"
date: 2024-01-01
tags: [RabbitMQ]
---

# RabbitMQ 09 - 集群与高可用

## 集群模式概述

RabbitMQ 集群由多个 Erlang 节点组成。节点之间共享：
- 交换器（Exchange）和绑定信息
- 队列的元数据（名称、配置）
- 集群用户和权限

但 **消息体默认只存在声明队列的那个节点上**（除非配置了镜像/仲裁队列）。

### 搭建简单集群

```bash
# 节点 1（主）
export RABBITMQ_NODENAME=rabbit@node1
export RABBITMQ_NODE_PORT=5672
rabbitmq-server -detached

# 节点 2
export RABBITMQ_NODENAME=rabbit@node2
export RABBITMQ_NODE_PORT=5673
rabbitmq-server -detached
rabbitmqctl -n rabbit@node2 stop_app
rabbitmqctl -n rabbit@node2 reset
rabbitmqctl -n rabbit@node2 join_cluster rabbit@node1
rabbitmqctl -n rabbit@node2 start_app

# 节点 3
export RABBITMQ_NODENAME=rabbit@node3
export RABBITMQ_NODE_PORT=5674
rabbitmq-server -detached
rabbitmqctl -n rabbit@node3 stop_app
rabbitmqctl -n rabbit@node3 reset
rabbitmqctl -n rabbit@node3 join_cluster rabbit@node1
rabbitmqctl -n rabbit@node3 start_app
```

## 队列高可用方案

### 方案 1：镜像队列（Mirrored Queues，MQ 3.8 前推荐）

通过策略将队列数据同步到集群的多个节点：

```bash
# 所有队列镜像到 2 个节点
rabbitmqctl set_policy ha-all ".*" '{"ha-mode":"exactly","ha-params":3,"ha-sync-mode":"automatic"}'
```

策略参数：

| 参数 | 值 | 含义 |
|------|----|------|
| `ha-mode` | `all` / `exactly` / `nodes` | 镜像范围 |
| `ha-params` | 数字 / 节点列表 | 镜像数量或节点 |
| `ha-sync-mode` | `automatic` / `manual` | 同步方式 |

> 镜像队列的局限：生产者和消费者都连接到 master 节点，负载不均衡。

### 方案 2：仲裁队列（Quorum Queues，MQ 3.8+ 推荐）

基于 Raft 协议的分布式队列，内建复制和自动故障恢复：

```go
// 声明仲裁队列
args := amqp.Table{
    "x-queue-type": "quorum",
    "x-quorum-initial-group-size": 3,           // 集群节点数
    "x-delivery-limit": 5,                       // 最大投递次数
}
ch.QueueDeclare("quorum.queue", true, false, false, false, args)
```

仲裁队列特性：

| 特性 | 说明 |
|------|------|
| 一致性 | Raft 协议确保强一致性 |
| 故障恢复 | 自动选举新的 leader |
| 防脑裂 | 多数节点存活才可用 |
| 持久化 | 所有消息同步写入磁盘 |
| 限制 | 不支持非持久消息、不支持独占队列、最大 1 条 ACK |

## 3. 负载均衡

### 客户端连接建议

```go
// 连接时使用负载均衡器地址，而非单个节点
conn, err := amqp.Dial("amqps://user:pass@rabbitmq-lb.internal:5671/")

// 或使用连接字符串列表（amqp091-go 不支持自动重试，需要业务处理）
```

### 推荐架构

```
          ┌──────────┐
          │  HAProxy  │  ← 负载均衡 + 健康检查
          └────┬─────┘
               │
       ┌───────┼───────┐
       │       │       │
   ┌───▼───┐┌───▼───┐┌───▼───┐
   │ Node1  ││ Node2  ││ Node3  │  ← 仲裁队列（Raft）
   │(Leader)││(Follower)│(Follower)│
   └───┬───┘└───┬───┘└───┬───┘
       │        │        │
   ┌───▼────────▼────────▼───┐
   │       磁盘存储          │
   └─────────────────────────┘
```

## 4. 故障处理

### 节点宕机场景

| 队列类型 | 行为 |
|---------|------|
| 普通队列 | 队列不可用，元数据转移到其他节点 |
| 镜像队列 | slave 自动提升为 master，可能丢消息 |
| 仲裁队列 | 重新选举 leader，不影响已 Ack 的消息 |

### 脑裂处理

网络分区时，RabbitMQ 默认**自动处理**（pause_minority），少数派节点会自动暂停：

```ini
# rabbitmq.conf
cluster_partition_handling = pause_minority
```

也可手动恢复：

```bash
# 选择一个节点作为权威节点
rabbitmqctl -n rabbit@standby stop_app
rabbitmqctl -n rabbit@standby reset
rabbitmqctl -n rabbit@standby join_cluster rabbit@main
rabbitmqctl -n rabbit@standby start_app
```

## 5. 管理和监控

```bash
# 集群状态
rabbitmqctl cluster_status

# 节点健康
rabbitmq-diagnostics node_health

# 队列状态
rabbitmqctl list_queues name messages consumers memory

# 策略列表
rabbitmqctl list_policies
```

推荐使用 **Prometheus + Grafana** 监控，RabbitMQ 3.8+ 内置了 Prometheus 端点：

```ini
# rabbitmq.conf
prometheus.return_per_object_metrics = true
```

## 性能建议

1. **连接数**：单节点建议最大 1000 个客户端连接，使用连接池复用
2. **队列数**：单个节点建议不超过 1000 个队列（仲裁队列不超过 500）
3. **消息大小**：建议 < 1MB，大消息使用对象存储 + 引用
4. **网络**：节点间延迟建议 < 10ms，仲裁队列 RTT 敏感
