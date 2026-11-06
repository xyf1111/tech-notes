---
title: "Kafka 04 - 可靠性保障"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 04 - 可靠性保障

## 消息传递语义

Kafka 在三个层面提供可靠性保障：

### 1. 生产者 → Broker

```java
// 幂等生产者（EOS v1）
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true); // 默认 false
// 开启后，Kafka 自动去重 → Exactly-once 写入
// 要求：acks=all, retries>0, max.in.flight=5
```

幂等原理：每个 Producer 有唯一 `producerId`，消息有序号 `sequenceNumber`，Broker 按序去重。

### 2. Broker → Broker（副本同步）

```java
// min.insync.replicas 是 Topic 级别的关键配置
// 确保至少有 N 个副本确认后才算写入成功
props.put("min.insync.replicas", 2);

// 配合 acks=all 使用：
// acks=all 且 min.insync.replicas=2 → 至少 2 个节点确认
```

### 3. Broker → Consumer

```java
// 手动提交 + 处理完再确认
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");

while (true) {
    ConsumerRecords<String, String> records = consumer.poll(100);
    for (ConsumerRecord<String, String> record : records) {
        process(record); // 先处理业务
    }
    consumer.commitSync(); // 再提交 offset
    // 如果 process 失败 → 不提交 → 重启后重新消费
}
```

## 副本机制（Replication）

### Leader & Follower

每个 Partition 有一个 Leader 和 N-1 个 Follower：

```
Partition 0 (3 replicas on 3 brokers):
Broker 1: Leader (读写)
Broker 2: Follower (同步)
Broker 3: Follower (同步)
```

- **Leader**：处理所有读写请求
- **Follower**：仅从 Leader 拉取数据同步，不提供服务
- **ISR**（In-Sync Replicas）：与 Leader 保持同步的副本集合

### ISR 机制

```java
// Broker 配置
replica.lag.time.max.ms = 30000 // Follower 落后 30s 被踢出 ISR
min.insync.replicas = 2        // ISR 至少 2 个副本
```

ISR 之外的 Follower 称为 OSR（Out-of-Sync Replica），重新追上后会加回 ISR。

### Leader 选举

当 Leader 宕机时：
1. Controller 从 ISR 中选出一个 Follower 作为新 Leader
2. 如果 ISR 为空，根据 `unclean.leader.election.enable` 决定：
   - `true`：从 OSR 选举（可能丢数据，但可用性高）
   - `false`（默认）：等待旧 Leader 恢复（不丢数据，但不可用）

## 故障场景分析

| 场景 | 数据可靠性 | 服务可用性 |
|------|-----------|-----------|
| Leader 宕机，ISR 存在 | ✅ 不丢数据 | ✅ 秒级切换 |
| Leader 宕机，ISR 为空，`unclean.election=false` | ✅ 不丢数据 | ❌ 等待恢复 |
| Leader 宕机，ISR 为空，`unclean.election=true` | ❌ 可能丢数据 | ✅ 快速恢复 |
| Follower 全部宕机 | ✅ 不受影响 | ✅ Leader 继续服务 |

## 配置建议

### 高可靠性配置

```java
// Producer
props.put("acks", "all");
props.put("enable.idempotence", true);
props.put("retries", Integer.MAX_VALUE);
props.put("max.in.flight.requests.per.connection", 5);

// Topic
// min.insync.replicas = 2
// replication.factor = 3

// Consumer
props.put("enable.auto.commit", "false");
props.put("auto.offset.reset", "earliest"); // 或 "latest"
```

### 高吞吐配置（可牺牲少量可靠性）

```java
props.put("acks", "1");     // Leader 确认即可
props.put("compression.type", "snappy");
props.put("batch.size", "65536");   // 64KB
props.put("linger.ms", "10");       // 攒 10ms 再发
props.put("max.in.flight", "1");    // 保证顺序
```
