---
title: "Kafka 05 - Kafka Streams 与流处理"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 05 - Kafka Streams 与流处理

## 什么是 Kafka Streams

Kafka Streams 是 Kafka 自带的流处理客户端库，用于构建实时流处理应用。

### 核心特点

- **无需独立集群** — 作为 Java 库嵌入应用中
- **Exactly-once 语义** — 内建的事务保证
- **状态管理** — 内置状态存储（RocksDB）
- **时间窗口** — 支持滚动/滑动/会话窗口
- **背压** — 基于 Kafka 消费拉取，自带背压控制

## 快速开始

```java
<dependency>
    <groupId>org.apache.kafka</groupId>
    <artifactId>kafka-streams</artifactId>
    <version>3.6.0</version>
</dependency>
```

```java
import org.apache.kafka.streams.*;
import org.apache.kafka.streams.kstream.*;

Properties props = new Properties();
props.put(StreamsConfig.APPLICATION_ID_CONFIG, "clickstream-app");
props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

StreamsBuilder builder = new StreamsBuilder();

// 从 Topic 读取流
KStream<String, String> clicks = builder.stream("click-events");

// 转换操作
KTable<String, Long> pageViews = clicks
    .groupBy((key, value) -> extractPage(value))        // 按页面分组
    .count(Materialized.as("page-view-counts"));         // 统计访问量

// 输出到 Topic
pageViews.toStream().to("page-stats");

KafkaStreams streams = new KafkaStreams(builder.build(), props);
streams.start();
```

## 核心概念

### KStream（记录流）

每条记录都是独立的，类似 Kafka 的原始消息流：

```
KStream: [记录A, 记录B, 记录C, ...]
```

### KTable（变更日志流）

类似数据库表，Key 是唯一的，新记录覆盖旧记录：

```
KTable: {key1→val2, key2→val4, ...}
// 等价于 upsert
```

### GlobalKTable

与 KTable 类似，但**每个节点都有完整数据副本**，适用于小数据集维表关联。

## 常用操作

### 无状态操作

```java
// 过滤
clicks.filter((key, value) -> value.contains("200"));

// 映射
clicks.mapValues(value -> value.toUpperCase());

// 分支
KStream<String, String>[] branches = clicks.branch(
    (key, value) -> value.startsWith("ERROR"),
    (key, value) -> value.startsWith("WARN"),
    (key, value) -> true // 兜底
);
```

### 有状态操作

```java
// 窗口聚合（每分钟的点击量）
KTable<Windowed<String>, Long> minuteCounts = clicks
    .groupByKey()
    .windowedBy(TimeWindows.of(Duration.ofMinutes(1)))
    .count();

// 滑动窗口（每 30s 输出过去 5 分钟的聚合）
KTable<Windowed<String>, Long> sliding = clicks
    .groupByKey()
    .windowedBy(SlidingWindows.ofTimeDifferenceAndGrace(
        Duration.ofMinutes(5), Duration.ofSeconds(30)))
    .count();

// 会话窗口（不活跃 5 分钟则结束会话）
KTable<Windowed<String>, Long> sessions = clicks
    .groupByKey()
    .windowedBy(SessionWindows.ofInactivityGapWithGrace(
        Duration.ofMinutes(5), Duration.ofMinutes(1)))
    .count();
```

## Join 操作

```java
// KStream-KStream Join（类似 inner join，窗口内匹配）
clicks.join(users,
    JoinWindows.of(Duration.ofMinutes(5)),
    (clickValue, userValue) -> clickValue + "|" + userValue
);

// KStream-KTable Join（类似左连接，查维度表）
KStream<String, String> enriched = purchases.join(
    userProfiles, // KTable
    (purchase, profile) -> purchase + "|" + profile
);

// KTable-KTable Join（类似 full outer join）
KTable<String, String> merged = table1.outerJoin(table2,
    (val1, val2) -> (val1 == null ? "" : val1) + "|" + (val2 == null ? "" : val2)
);
```

## 状态存储

Kafka Streams 使用 RocksDB（嵌入式的 LSM-Tree 引擎）存储状态：

```java
// 自定义状态存储
StoreBuilder<KeyValueStore<String, Long>> storeBuilder =
    Stores.keyValueStoreBuilder(
        Stores.persistentKeyValueStore("my-store"),
        Serdes.String(),
        Serdes.Long()
    );
builder.addStateStore(storeBuilder);

// 在 Transformer 中访问
clicks.transform(() -> new MyTransformer(), "my-store");
```

## vs Flink vs Spark Streaming

| 特性 | Kafka Streams | Flink | Spark Streaming |
|------|--------------|-------|-----------------|
| 架构 | 嵌入式库 | 独立集群 | 独立集群 |
| 部署 | 简单（嵌入 JAR） | 复杂（Flink 集群） | 复杂（Spark 集群） |
| 延迟 | 毫秒级 | 毫秒级 | 秒级 |
| 状态 | RocksDB | Heap/RocksDB | 外部存储 |
| 语义 | Exactly-once | Exactly-once | Exactly-once |
| Kafka 集成 | 原生 | 好（需 connector） | 好（需 connector） |
| 适用场景 | 中等复杂度的流处理 | 大规模复杂计算 | 批 + 流混合 |
