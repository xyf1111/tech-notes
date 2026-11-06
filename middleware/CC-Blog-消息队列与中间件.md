---
title: CC's Blog - 消息队列与中间件
date: 2026-06-09
tags:
  - rabbitmq
  - grpc
  - 中间件
  - 消息队列
  - source
---

# 消息队列与中间件

> 来源：[xyf1111.github.io](https://xyf1111.github.io/)，整理自 CC 博客中的 RabbitMQ 和 gRPC 系列文章。

## RabbitMQ 系列

> 共 6 篇：2021-06 ~ 2021-09

### 1. 消息队列基础

- **为什么需要 MQ**：解耦、异步、削峰
- **AMQP 协议**：RabbitMQ 的核心协议
- 核心概念：
  - **Producer**：生产者
  - **Consumer**：消费者
  - **Exchange**：交换机（路由消息）
  - **Queue**：队列（存储消息）
  - **Binding**：绑定（Exchange 到 Queue 的路由规则）

### 2. 交换机类型

| 类型 | 路由规则 |
|------|----------|
| **Direct** | 精确匹配 routing key |
| **Fanout** | 广播到所有绑定队列 |
| **Topic** | 通配符匹配 `*` (一个词) `#` (零个或多个词) |
| **Headers** | 基于消息头匹配 |

### 3. 消息确认机制 (ACK)

- **生产者确认**（Publisher Confirm）：消息成功投递到 Exchange 后回调
- **消费者确认**（Consumer ACK）：
  - 自动 ACK：消费即确认，可能丢消息
  - 手动 ACK：处理后确认，`basicAck` / `basicNack` / `basicReject`
- **消息可靠性**：持久化 Exchange + 持久化 Queue + 持久化消息 + 手动 ACK

### 4. 死信队列 (DLQ)

- **死信来源**：
  - 消息被拒绝（reject/nack）且 `requeue=false`
  - 消息 TTL 过期
  - 队列达到最大长度
- **延迟队列**：利用 TTL + DLQ 实现（RabbitMQ 无内置延迟队列）

### 5. 高可用与集群

- **普通集群**：元数据共享，Queue 数据单节点存储
- **镜像队列**：Queue 数据多节点冗余，master + slave
- **Quorum Queue**（3.8+）：基于 Raft 协议，更强一致性
- **Federation/Shovel**：跨数据中心复制

### 6. 性能调优

- 连接复用、批量发送
- 合理设置 prefetch count（消费者预取数量）
- 监控队列积压、消费者速率

---

## 相关笔记

- [[index|📚 返回知识库首页]]
- [[golang/核心原理/CC-Blog-Go语言核心原理|Go语言核心原理]] — gRPC 详解
- [[database/CC-Blog-MySQL与Redis|MySQL与Redis]] — 数据库笔记
