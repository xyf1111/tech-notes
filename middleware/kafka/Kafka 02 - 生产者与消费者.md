---
title: "Kafka 02 - 生产者与消费者"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 02 - 生产者与消费者

## 生产者（Producer）

### 基本使用（Java）

```java
import org.apache.kafka.clients.producer.*;

Properties props = new Properties();
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
props.put(ProducerConfig.ACKS_CONFIG, "all");
props.put(ProducerConfig.RETRIES_CONFIG, 3);
props.put(ProducerConfig.LINGER_MS_CONFIG, 5); // 攒一批再发

KafkaProducer<String, String> producer = new KafkaProducer<>(props);

// 发送（异步）
producer.send(new ProducerRecord<>("orders", "order_123", "{\"id\":123}"), 
    (metadata, exception) -> {
        if (exception == null) {
            System.out.println("发送成功: " + metadata.partition() + "@" + metadata.offset());
        } else {
            System.err.println("发送失败: " + exception.getMessage());
        }
    });

// 批量发送
for (int i = 0; i < 100; i++) {
    producer.send(new ProducerRecord<>("metrics", "key_" + i, "value_" + i));
}
producer.flush(); // 强制刷出
```

### Go 版生产者

```go
import "github.com/segmentio/kafka-go"

writer := kafka.NewWriter(kafka.WriterConfig{
    Brokers:  []string{"localhost:9092"},
    Topic:    "orders",
    Balancer: &kafka.Hash{}, // 按 key 哈希分区
    BatchSize: 100,
})

ctx := context.Background()
err := writer.WriteMessages(ctx, kafka.Message{
    Key:   []byte("order_123"),
    Value: []byte(`{"id":123,"amount":99.9}`),
})
```

### 发送模式

| 模式 | 延迟 | 可靠性 | 使用场景 |
|------|------|--------|---------|
| Fire-and-Forget | 最低 | 最低 | 日志/指标 |
| 同步等待 | 最高 | 中 | 关键业务（配合 retries） |
| 异步回调 | 中 | 最高 | 推荐生产使用 |

### 重要参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `acks` | `1` | `0`=不等待, `1`=Leader确认, `all`=全部确认 |
| `batch.size` | 16KB | 批量发送大小 |
| `linger.ms` | 0 | 批量延迟（调大增加批大小，降低延迟） |
| `compression.type` | none | `gzip`/`snappy`/`lz4`/`zstd`（建议 snappy） |
| `max.in.flight.requests` | 5 | 未确认请求数，=1 保证顺序 |

## 消费者（Consumer）

### 基本使用（Java）

```java
Properties props = new Properties();
props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ConsumerConfig.GROUP_ID_CONFIG, "order-service");
props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest"); // 从最早开始消费
props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);     // 手动提交

KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
consumer.subscribe(Arrays.asList("orders"));

while (true) {
    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(100));
    for (ConsumerRecord<String, String> record : records) {
        System.out.printf("offset=%d, key=%s, value=%s%n", 
            record.offset(), record.key(), record.value());
    }
    consumer.commitSync(); // 手动提交 offset
}
```

### Go 版消费者

```go
import "github.com/segmentio/kafka-go"

reader := kafka.NewReader(kafka.ReaderConfig{
    Brokers:  []string{"localhost:9092"},
    Topic:    "orders",
    GroupID:  "order-service",
    MinBytes: 1,    // 最小拉取字节
    MaxBytes: 10e6, // 10MB
})

for {
    msg, err := reader.ReadMessage(context.Background())
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("msg: %s (partition=%d, offset=%d)\n", msg.Value, msg.Partition, msg.Offset)
    // 自动提交 offset（默认每 1s）
}
```

### Consumer Group 机制

```
Topic: orders (3 partitions)

Consumer Group: order-service
├── Consumer-1 → Partition 0 (Leader)
├── Consumer-2 → Partition 1
└── Consumer-3 → Partition 2
```

- 每个 Partition 只能被同一个 Group 内的一个 Consumer 消费
- 新增 Consumer → 触发 Rebalance（重新分配分区）
- Consumer 数量超过 Partition 数 → 多余的闲置

### 消费语义

| 语义 | 说明 | 实现方式 |
|------|------|---------|
| At-most-once | 最多一次（可能丢） | 自动提交，poll 完即提交 |
| At-least-once | 至少一次（可能重复） | 处理完再提交 / 开启 retries |
| Exactly-once | 精确一次（最可靠） | 事务 API + 幂等生产者 |

## 常见问题

1. **消息顺序**：同一 Partition 内有序；如需全局有序，Partition=1（牺牲吞吐）
2. **重复消费**：Consumer 重启后从未提交的 offset 开始消费；业务做幂等
3. **Rebalance**：Consumer 加入/退出时暂停消费；可通过 `partition.assignment.strategy` 调整策略
