---
title: "Kafka 06 - Schema Registry 与序列化"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 06 - Schema Registry 与序列化

## 为什么需要 Schema Registry

Kafka 消息是二进制 Blob，Producer 和 Consumer 需要约定消息格式。Schema Registry 提供了：

- **统一 Schema 管理** — 集中存储 Avro/JSON/Protobuf Schema
- **版本管理** — Schema 变更可追溯、可回滚
- **兼容性检查** — 防止 Producer 写入 Consumer 无法解析的格式

## Avro 序列化

### Schema 定义

```json
{
  "namespace": "com.example",
  "type": "record",
  "name": "Order",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "user_id",  "type": "string"},
    {"name": "amount",   "type": "double"},
    {"name": "status",   "type": {"type": "enum", "name": "OrderStatus",
                                   "symbols": ["PENDING", "PAID", "CANCELLED"]}},
    {"name": "items",    "type": {"type": "array", "items": "string"}}
  ]
}
```

### Producer 使用

```java
Properties props = new Properties();
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, 
    KafkaAvroSerializer.class.getName());
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, 
    KafkaAvroSerializer.class.getName());
props.put("schema.registry.url", "http://localhost:8081");

KafkaProducer<String, Order> producer = new KafkaProducer<>(props);

Order order = Order.newBuilder()
    .setOrderId("ord_123")
    .setUserId("usr_456")
    .setAmount(99.99)
    .setStatus(OrderStatus.PENDING)
    .setItems(Arrays.asList("item_a", "item_b"))
    .build();

producer.send(new ProducerRecord<>("orders", order.getOrderId(), order));
```

### Consumer 使用

```java
props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, 
    KafkaAvroDeserializer.class.getName());
props.put("schema.registry.url", "http://localhost:8081");
props.put("specific.avro.reader", "true"); // 使用具体类

KafkaConsumer<String, Order> consumer = new KafkaConsumer<>(props);
```

## 兼容性策略

Schema Registry 支持多种兼容性检查策略：

| 策略 | 说明 | 允许变更 |
|------|------|---------|
| BACKWARD（默认） | 新 Schema 可以读旧数据 | 删除字段、添加可选字段 |
| FORWARD | 旧 Schema 可以读新数据 | 添加字段、删除可选字段 |
| FULL | 双向兼容 | 添加/删除可选字段 |
| NONE | 不检查 | 任意变更 |
| BACKWARD_TRANSITIVE | 对所有历史版本向后兼容 | 同上，但检查所有版本 |
| FORWARD_TRANSITIVE | 对所有历史版本向前兼容 | 同上 |

### 兼容性变更示例

```java
// V1 Schema
{"name": "email", "type": "string"}

// V2 Schema（允许，BACKWARD 兼容 — 提供默认值）
{"name": "email", "type": "string", "default": ""}

// V2 Schema（不允许，BACKWARD 不兼容 — 无默认值）
{"name": "email", "type": ["string", "null"], "default": null}
// ✅ 这个也可行，因为 null 是合法的默认值

// V3 Schema（允许，FORWARD 兼容 — 有了默认值，可以删除）
// 但 BACKWARD 模式下不行（V2 无 email 默认值）
```

## JSON Schema 与 Protobuf

Schema Registry 从 5.5 开始支持 JSON Schema，从 5.5 开始支持 Protobuf：

```java
// JSON Schema
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, 
    KafkaJsonSchemaSerializer.class.getName());

// Protobuf
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, 
    KafkaProtobufSerializer.class.getName());
```

## Schema Registry 架构

```
Producer ──→ Schema Registry ──→ Consumer
  │              │                   │
  ├─ 注册 Schema ┘                   │
  ├─ 序列化（写入 Schema ID）─────→     │
  │              │                   ├─ 根据 ID 获取 Schema
  │              │                   └─ 反序列化
  └──────── Kafka ──────────────────→
```

消息中只包含 4 字节的 Schema ID，不包含完整 Schema，减少网络开销。
