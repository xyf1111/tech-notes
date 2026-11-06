---
title: "Kafka 03 - 分区机制与消费策略"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 03 - 分区机制与消费策略

## 分区（Partition）的作用

Partition 是 Kafka 的核心抽象，提供了：

- **并行度** — 一个 Topic 的 N 个 Partition 可以被 N 个 Consumer 并行消费
- **水平扩展** — Partition 分布在多个 Broker 上，存储无上限
- **顺序保证** — 每个 Partition 内消息严格有序

### 分区写入策略

```java
// 1. 轮询（Round-Robin）— 均衡分布
// 未指定 key 时的默认策略
ProducerRecord<>("orders", "value"); // 无 key → 轮询

// 2. 哈希 — 相同 key 进入相同分区
ProducerRecord<>("orders", "user_123", "value"); // key 哈希 → 固定分区

// 3. 自定义分区器
public class OrderPartitioner implements Partitioner {
    @Override
    public int partition(String topic, Object key, byte[] keyBytes, 
                         Object value, byte[] valueBytes, Cluster cluster) {
        if (key == null) return ThreadLocalRandom.current().nextInt();
        String orderId = (String) key;
        // VIP 订单进入高优先级分区
        if (orderId.startsWith("vip")) return 0;
        return Math.abs(key.hashCode()) % cluster.partitionCountForTopic(topic);
    }
}
```

### 分区数如何确定

```
分区数 = max(目标吞吐量 / 单分区吞吐量, Consumer 数)

示例：
- 目标吞吐量: 100 MB/s
- 单分区写入: 10 MB/s（单节点）
- Consumer 数: 10
- 分区数 = max(100/10, 10) = 10
```

经验法则：
- 建议 **分区数 = Broker 数 × 2~4**
- 上限建议：单节点不超过 4000 个分区
- 分区过多 → 文件句柄、Leader 选举、Rebalance 耗时增加

## 分区分配策略

### 1. Range（默认）

按分区范围分配，类似按序均分。可能产生**分配不均**：

```
Topic A (3 partitions): [0,1,2]
Topic B (4 partitions): [0,1,2,3]

Consumer-1: A[0,1] + B[0,1]  ← 4 个分区
Consumer-2: A[2]   + B[2,3]  ← 3 个分区
```

### 2. RoundRobin

轮询分配，基本均匀：

```
Topic A: [0,1,2]
Topic B: [0,1,2,3]

Consumer-1: A[0] + A[2] + B[1] + B[3]  ← 4
Consumer-2: A[1] + B[0] + B[2]         ← 3
```

### 3. Sticky（推荐）

Kafka 2.4+ 默认策略。平衡更好，**Rebalance 时保留更多已有分区**：

```
优点：某个 Consumer 挂掉时，只有它负责的分区需要重新分配
      其他 Consumer 不会被迫重新分配（对比 Range/RoundRobin 的全量 Rebalance）
```

```java
props.put(ConsumerConfig.PARTITION_ASSIGNMENT_STRATEGY_CONFIG, 
    StickyAssignor.class.getName());

// 合作式 Rebalance（Kafka 2.4+）
props.put(ConsumerConfig.COOPERATIVE_STICKY_ASSIGNOR_CONFIG, "");
// 与 Sticky 配合，变成增量 Rebalance 而不是全量停止
```

## 分区再平衡（Rebalance）

### 触发条件

1. Consumer 加入/离开 Consumer Group
2. Consumer 订阅的 Topic 分区数变化
3. Consumer 长时间不发送心跳（`session.timeout.ms` 默认 45s）

### Rebalance 的影响

- **停止消费** — 所有 Consumer 暂停处理（Eager Rebalance）
- **重复消费** — 未提交的 offset 会在新分配者上重新消费
- **延迟** — 大型集群的 Rebalance 可能持续数秒

### 避免不必要的 Rebalance

```java
// 1. 增加心跳超时
props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, "60000"); // 默认 45s

// 2. 增加心跳间隔
props.put(ConsumerConfig.HEARTBEAT_INTERVAL_MS_CONFIG, "15000"); // 默认 3s

// 3. 增大 Max Poll Interval
props.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, "300000"); // 默认 5min
```

## 多集群与跨分区

### 扇出（Fan-out）

同一条消息被多个不相关的 Consumer Group 分别消费：

```
"orders" Topic
  ├── Group: billing-service → 账单处理（Partition 0,1,2 全量）
  └── Group: analytics       → 数据分析（Partition 0,1,2 全量）
```

### 分区扩展

已存在的 Topic 可以增加分区数，但要注意：
- **Key 到 Partition 的映射会变** — 相同 key 的消息可能进入不同分区
- 如果业务依赖 key→partition 的确定性，建议创建新 Topic 而非扩分区
- 无法减少分区数

```bash
# 增加分区数
kafka-topics.sh --bootstrap-server localhost:9092 \
  --alter --topic orders --partitions 6
```
