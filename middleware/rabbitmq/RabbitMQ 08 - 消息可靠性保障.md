---
title: "RabbitMQ 08 - 消息可靠性保障"
date: 2024-01-01
tags: [RabbitMQ]
---

# RabbitMQ 08 - 消息可靠性保障

## 消息丢失的三个环节

```
生产者 → RabbitMQ → 消费者
    ① 发送     ② 存储     ③ 消费
```

任何一环都可能丢失消息。RabbitMQ 在每一层都提供了保障机制。

## 1. 生产者端：确认机制

### Publisher Confirm

发送确认模式确保消息成功到达 Exchange：

```go
// 开启确认模式
err := ch.Confirm(false) // false = 不等待服务器回执

// 发送消息
err = ch.Publish("exchange", "routing.key", true, false, amqp.Publishing{
    ContentType: "text/plain",
    Body:        []byte("重要消息"),
})

// 等待确认（同步）
confirmation, ok := <-ch.NotifyConfirm(make(chan amqp.Confirmation, 1))
if confirmation.Ack {
    log.Println("消息确认成功")
} else {
    log.Println("消息未确认为 nack") // 需重发
}
```

### 异步批量确认（生产推荐）

```go
// 使用确认监听器 → 批量处理
ackChan := ch.NotifyConfirm(make(chan amqp.Confirmation, 100))
nackChan := ch.NotifyReturn(make(chan amqp.Return, 100))

// 协程：处理确认
go func() {
    for conf := range ackChan {
        if conf.Ack {
            // 从待确认列表移除 deliveryTag
        } else {
            // deliveryTag 对应消息重发
        }
    }
}()
```

> **Mandatory 标志**：`Publish` 的第一个 `true` 是 `mandatory`，当消息无法路由到队列时，RabbitMQ 通过 `Basic.Return` 将消息退回生产者。

## 2. Broker 端：持久化

### 持久化三件套

```go
// 1. Exchange 持久化
ch.ExchangeDeclare("exchange.persistent", "direct", true, false, false, false, nil)
                                     // durable = true

// 2. Queue 持久化
q, _ := ch.QueueDeclare("queue.persistent", true, false, false, false, nil)
                                      // durable = true

// 3. Message 持久化
ch.Publish("", q.Name, false, false, amqp.Publishing{
    DeliveryMode: amqp.Persistent, // 2 = 持久化
    ContentType:  "text/plain",
    Body:         []byte("消息体被持久化到磁盘"),
})
```

### 队列镜像（HA）

对于集群环境，队列的持久化数据默认只存在主节点上。Mirrored Queues（镜像队列）将数据同步到其他节点：

```
策略：ha-mode = exactly  ha-params = 2
```

RabbitMQ 3.8+ 推荐使用 **Quorum Queues**（仲裁队列），内建数据复制：

```go
args := amqp.Table{
    "x-queue-type": "quorum",           // 仲裁队列
    "x-quorum-initial-group-size": 3,   // 初始组大小
}
ch.QueueDeclare("quorum.queue", true, false, false, false, args)
```

## 3. 消费者端：ACK 机制

### 手动 ACK（推荐）

```go
msgs, _ := ch.Consume("queue.name", "", false, false, false, false, nil)
//                            autoAck = false

for d := range msgs {
    err := processMessage(d.Body)
    if err != nil {
        // 处理失败 → 拒绝并决定是否重新入队
        d.Nack(false, true) // multiple=false, requeue=true
        continue
    }
    d.Ack(false) // 确认处理完成
}
```

### 三种 ACK 模式

| 模式 | 参数 | 行为 |
|------|------|------|
| 自动 ACK | autoAck=true | 发给消费者即确认（可能丢失） |
| 手动 ACK | `d.Ack(false)` | 确认消息已处理完成 |
| 手动 NACK | `d.Nack(multiple, requeue)` | 拒绝消息，可选重新入队 |

### prefetch（QoS）

限制消费者未确认消息数量，防止单个消费者堆积过多：

```go
// 每次最多拉取 10 条未确认的消息
ch.Qos(10, 0, false) // prefetchCount, prefetchSize, global
```

> **prefetch=1**：最安全的设置，但吞吐量低
> **prefetch=100~300**：一般业务的推荐值
> **prefetch>1000**：高吞吐场景，但需要合理设置 TTL 防止堆积

## 4. 事务支持

AMQP 协议提供事务机制，但性能远低于 Confirm 模式，**生产推荐使用 Confirm**：

```go
// 开启事务
ch.Tx()

// 发送 → 如果失败则回滚
ch.Publish(...)
ch.TxRollback() // 或 TxCommit()
```

> Confirm 模式与事务模式互斥 — 不能同时开启。

## 5. 端到端可靠性方案总结

```
生产者                          RabbitMQ                          消费者
  │                               │                                │
  ├─ Publisher Confirm ──────────►├─ 持久化 Exchange/Queue ───────►├─ 手动 ACK
  │  ① 回调确认收到               │  ③ 消息写入磁盘                │  ⑥ 确认处理后回调
  ├─ Mandatory 标志 ────────────►├─ Quorum/镜像队列 ────────────►├─ Nack(requeue)
  │  ② 路由失败退回               │  ④ 集群节点复制                │  ⑦ 失败重试
  │                               │                                │
  └── 业务重试机制 ◄──────────────┘  ⑤ 故障转移 ◄─────────────────┘
```

### 业务层兜底

即使消息中间件层面做到万无一失，业务层仍需兜底：

- **本地消息表**：发送前写入本地 DB，确认成功后标记已发送
- **定时补偿**：扫描未确认的消息定时重发
- **幂等消费**：消费者使用业务 ID 去重，避免重复消费
