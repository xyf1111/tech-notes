---
title: "Kafka 01 - 基础概念与架构"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 01 - 基础概念与架构

## 什么是 Kafka

Apache Kafka 是一个分布式流处理平台，由 LinkedIn 开发，2011 年开源。核心能力：

- **发布/订阅消息系统** — 类似消息队列，但吞吐量高几个数量级
- **持久化存储** — 消息写入磁盘，可配置保留时间
- **流处理** — 通过 Kafka Streams 实时处理数据流

### 核心特性

| 特性 | 说明 |
|------|------|
| 高吞吐 | 单节点百万消息/秒（基准测试） |
| 持久化 | 基于磁盘的顺序读写，利用 OS Page Cache |
| 分区 | Topic 可分割为多个 Partition，支持并行消费 |
| 副本 | Partition 跨节点复制，自动故障转移 |
| 顺序保证 | 单个 Partition 内保证消息顺序 |
| Exactly-Once | 支持精确一次语义 |

## 核心概念

### Topic（主题）

消息的逻辑分类，类似数据库中的表。一个 Topic 可以有多个生产者和消费者。

### Partition（分区）

每个 Topic 被分为 1 个或多个 Partition，Partition 是 Kafka 并行度的基本单位。

```
Topic "orders"
├── Partition 0 (Leader on Broker 1)
├── Partition 1 (Leader on Broker 2)
└── Partition 2 (Leader on Broker 3)
```

每个 Partition 是一个**有序的、不可变的消息序列**，消息通过 offset（偏移量）标识位置。

### Offset（偏移量）

消息在 Partition 中的唯一位置标识。消费者通过 offset 控制消费进度，支持：

- **自动提交** — 消费者定期提交 offset（可能重复消费）
- **手动提交** — 业务代码精确控制（最少一次语义）
- **seek 到指定位置** — 回溯或跳过消息

### Broker（代理节点）

Kafka 集群中的每个服务器节点。一个集群通常有 3 个以上 Broker。

### Producer（生产者）

向 Topic 发布消息的客户端。核心参数：

```java
// 发送确认级别
props.put("acks", "all"); // 0=不等待, 1=leader确认, all=所有副本确认

// 重试
props.put("retries", 3);
props.put("retry.backoff.ms", 100);
```

### Consumer（消费者）

从 Topic 读取消息的客户端。Consumer 通过 **Consumer Group** 实现水平扩展。

## Kafka 架构图

```
Producer 1 ────┐
                ├──→ Partition 0 (Leader) ──→ Consumer A (Group G1)
Producer 2 ────┘                              │
                                               ├──→ Consumer B (Group G2)
Producer 3 ────┐                              │
                ├──→ Partition 1 (Leader) ────┘
Producer 4 ────┘
                        ┌──────────────────────┐
                        │    ZooKeeper          │
                        │  (集群协调/Leader选举) │
                        └──────────────────────┘
```

## Kafka vs RabbitMQ

| 特性 | Kafka | RabbitMQ |
|------|-------|----------|
| 设计理念 | 分布式日志/流 | 消息队列/AMQP |
| 吞吐量 | 百万级/秒 | 万级/秒 |
| 消息模型 | Pull 模式 | Push + Pull |
| 消息顺序 | Partition 内有序 | 单队列有序 |
| 消息保留 | 按时间/大小保留 | 消费后删除 |
| 路由 | 基于 Topic | 多种 Exchange 类型 |
| 延迟 | 毫秒级 | 微秒级 |
| 适用场景 | 日志/流/大数据 | 任务队列/RPC |
