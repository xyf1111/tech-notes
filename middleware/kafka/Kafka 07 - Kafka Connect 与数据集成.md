---
title: "Kafka 07 - Kafka Connect 与数据集成"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 07 - Kafka Connect 与数据集成

## 什么是 Kafka Connect

Kafka Connect 是 Kafka 的数据集成框架，用于在 Kafka 和其他系统之间**可扩展地、可靠地**传输数据。

### 核心概念

- **Source Connector** — 从外部系统导入数据到 Kafka（如 MySQL CDC → Kafka）
- **Sink Connector** — 从 Kafka 导出数据到外部系统（如 Kafka → Elasticsearch）
- **Worker** — 运行 Connector 的进程（Standalone 或 Distributed）

## 部署模式

### Standalone 模式（开发/单机）

```properties
# worker.properties
bootstrap.servers=localhost:9092
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
offset.storage.file.filename=/tmp/connect.offsets
```

```bash
# 启动
kafka-connect-standalone.sh worker.properties \
  source-connector.properties sink-connector.properties
```

### Distributed 模式（生产）

```properties
# worker.properties
bootstrap.servers=localhost:9092
group.id=connect-cluster
key.converter=org.apache.kafka.connect.json.JsonConverter
value.converter=org.apache.kafka.connect.json.JsonConverter
offset.storage.topic=connect-offsets
config.storage.topic=connect-configs
status.storage.topic=connect-status
offset.storage.replication.factor=3
```

```bash
kafka-connect-distributed.sh worker.properties

# 通过 REST API 管理 Connector
POST /connectors
{
    "name": "mysql-orders-source",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
        "connection.url": "jdbc:mysql://host:3306/db",
        "connection.user": "user",
        "connection.password": "pass",
        "table.whitelist": "orders",
        "topic.prefix": "mysql-",
        "mode": "incrementing",
        "incrementing.column.name": "id"
    }
}

GET /connectors/mysql-orders-source/status
DELETE /connectors/mysql-orders-source
```

## 常用 Connector

### JDBC Source Connector（MySQL → Kafka）

```json
{
    "name": "mysql-pg-orders",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
        "connection.url": "jdbc:postgresql://host:5432/mydb",
        "connection.user": "user",
        "connection.password": "pass",
        "table.whitelist": "orders",
        "mode": "timestamp+incrementing",
        "timestamp.column.name": "updated_at",
        "incrementing.column.name": "id",
        "topic.prefix": "pg-",
        "poll.interval.ms": 5000,
        "validate.non.null": false
    }
}
```

### Debezium Connector（CDC）

Debezium 基于 Kafka Connect 提供 CDC（Change Data Capture）能力：

```json
{
    "name": "debezium-mysql-connector",
    "config": {
        "connector.class": "io.debezium.connector.mysql.MySqlConnector",
        "database.hostname": "mysql-host",
        "database.port": "3306",
        "database.user": "debezium",
        "database.password": "pass",
        "database.server.id": "184054",
        "database.server.name": "mysql-server-1",
        "database.include.list": "ecommerce",
        "table.include.list": "ecommerce.orders",
        "snapshot.mode": "schema_only_recovery",
        "topic.prefix": "cdc",
        "key.converter": "io.confluent.connect.avro.AvroConverter"
    }
}
```

Debezium 输出：

```
Topic: cdc.ecommerce.orders
Message:
{
    "op": "u",          // c=create, u=update, d=delete, r=snapshot
    "before": {"id": 1, "status": "PENDING"},
    "after":  {"id": 1, "status": "PAID"},
    "source": {"db": "ecommerce", "table": "orders"},
    "ts_ms": 1704000000123
}
```

### Elasticsearch Sink Connector

```json
{
    "name": "elastic-sink-orders",
    "config": {
        "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
        "connection.url": "http://elasticsearch:9200",
        "topics": "search-orders",
        "key.ignore": true,
        "type.name": "_doc",
        "behavior.on.null.values": "delete",
        "batch.size": 100,
        "linger.ms": 1000,
        "write.method": "upsert"
    }
}
```

## 架构模式

### CDC + Kafka Connect 实现实时同步

```
MySQL (Orders) ──→ Debezium CDC ──→ Kafka (orders-cdc)
                                          │
                                          ├──→ Kafka Streams (转换/enrich)
                                          │         │
                                          │         ▼
                                          │    Kafka (orders-enriched)
                                          │         │
                                          │         ├──→ ES Sink → Elasticsearch
                                          │         └──→ Redis Sink → Cache
                                          │
                                          └──→ JDBC Sink → 数据仓库
```

## 监控与管理

```bash
# 检查 Connector 状态
curl localhost:8083/connectors/mysql-source/status

# 检查任务日志
curl localhost:8083/connectors/mysql-source/tasks

# 重启失败任务
curl -X POST localhost:8083/connectors/mysql-source/tasks/0/restart

# 列集群 Connector
curl localhost:8083/connectors?expand=info&expand=status
```

### 推荐配置

```properties
# 生产建议
offset.flush.interval.ms = 5000
offset.flush.timeout.ms = 5000
task.shutdown.graceful.timeout.ms = 5000
errors.tolerance = all                    # 忽略单个错误，不阻塞
errors.deadletterqueue.topic.name = dlq   # 错误消息写入死信队列
errors.deadletterqueue.context.headers.enable = true
```
