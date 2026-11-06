---
title: "Kafka 08 - 集群运维与监控"
date: 2024-01-01
tags: [Kafka]
---

# Kafka 08 - 集群运维与监控

## 集群架构

### 推荐配置

| 环境 | 节点数 | 副本因子 | min.insync.replicas | 磁盘 |
|------|--------|---------|---------------------|------|
| 开发 | 1 | 1 | 1 | 单盘 |
| 生产小规模 | 3 | 3 | 2 | 多盘 RAID 或 JBOD |
| 生产大规模 | 6+ | 3 | 2 | 每节点多 SSD |

### 硬件建议

- **CPU**：建议 16 核以上（Kafka 是 CPU 密集型——压缩、序列化）
- **内存**：至少 32GB（充分利用 Page Cache）
- **磁盘**：建议 SSD，多个磁盘目录分散 I/O（`log.dirs` 配置多个路径）
- **网络**：10GbE 网卡

## 核心配置

### Broker 配置

```properties
# server.properties
broker.id=1
listeners=PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://kafka-broker-1:9092  # 客户端连接地址
log.dirs=/data/kafka/data-1,/data/kafka/data-2         # 多个磁盘目录
num.partitions=3                                        # 默认分区数
default.replication.factor=3                            # 默认副本数

# 日志保留策略
log.retention.hours=168                                  # 7 天
log.retention.bytes=536870912000                         # 500GB
log.segment.bytes=1073741824                             # 1GB 分段
log.retention.check.interval.ms=300000                  # 检查间隔 5min

# 网络
num.network.threads=8
num.io.threads=16
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600                       # 100MB

# 限流
replication.quota.throttled.rate.replicas=200             # 副本同步带宽
```

## 常用运维命令

```bash
# Topic 管理
kafka-topics.sh --bootstrap-server localhost:9092 --create \
  --topic orders --partitions 6 --replication-factor 3
kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic orders
kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic orders --partitions 12

# 消费组查看
kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --describe --group billing-service

# 重设 offset（回溯消费）
kafka-consumer-groups.sh --bootstrap-server localhost:9092 \
  --group billing-service --reset-offsets --to-earliest \
  --topic orders --execute

# 消息查看
kafka-console-consumer.sh --bootstrap-server localhost:9092 \
  --topic orders --from-beginning --max-messages 10

# Leader 重新选举
kafka-leader-election.sh --bootstrap-server localhost:9092 \
  --topic orders --partition 0 --election-type preferred
```

## 监控指标

### JMX 指标关键指标

```bash
# 启用 JMX
export KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote \
  -Dcom.sun.management.jmxremote.authenticate=false \
  -Dcom.sun.management.jmxremote.ssl=false \
  -Djava.rmi.server.hostname=node1"

# 常用监控指标
kafka.server:type=BrokerTopicMetrics,name=MessagesInPerSec           # 写入速率
kafka.server:type=BrokerTopicMetrics,name=BytesInPerSec              # 流入带宽
kafka.server:type=BrokerTopicMetrics,name=BytesOutPerSec             # 流出带宽
kafka.controller:type=KafkaController,name=ActiveControllerCount     # 活跃 Controller
kafka.server:type=ReplicaManager,name=UnderReplicatedPartitions      # 欠副本分区
kafka.server:type=ReplicaManager,name=IsrExpandsPerSec               # ISR 扩展
kafka.server:type=ReplicaManager,name=IsrShrinksPerSec               # ISR 收缩
kafka.log:type=Log,name=NumLogSegments,topic=*,partition=*          # 日志段数
```

### 健康检查

```bash
# 检查集群
kafka-broker-api-versions.sh --bootstrap-server localhost:9092

# 模拟生产者（测端到端延迟）
kafka-producer-perf-test.sh --topic perf-test \
  --num-records 100000 --record-size 1024 \
  --throughput 10000 --producer-props bootstrap.servers=localhost:9092

# 模拟消费者（测端到端延迟）
kafka-consumer-perf-test.sh --topic perf-test \
  --messages 100000 --broker-list localhost:9092
```

## 生产故障处理

### 常见故障与排查

| 症状 | 原因 | 解决 |
|------|------|------|
| Producer 超时 | Broker 负载高 / 网络抖动 | 增大 request.timeout.ms，检查网络 |
| Consumer 延迟增加 | Consumer 处理慢 / 分区不足 | 增加 Consumer 或分区数 |
| Under-replicated | 磁盘故障 / 网络分区 | 检查磁盘，重启 Follower |
| ISR 频繁收缩 | Follower 跟不上 | 增大 replica.lag.time.max.ms |
| Leader 频繁切换 | 网络不稳定 | 增大 zookeeper.session.timeout.ms |
| 磁盘 100% | 消息积压 / 保留策略不合理 | 增大 log.retention.bytes，清理日志 |

### 滚动重启

```bash
#!/bin/bash
# 最小化影响的重启流程
BROKERS="kafka-1 kafka-2 kafka-3"

for broker in $BROKERS; do
    # 1. 关闭 Leader 选举
    kafka-leader-election.sh --bootstrap-server $broker:9092 \
      --election-type preferred --all-topic-partitions
    
    # 2. 等待所有 Partition 切换
    sleep 30
    
    # 3. 重启 Broker
    ssh $broker "systemctl restart kafka"
    
    # 4. 等待加入集群
    sleep 60
    
    # 5. 验证
    kafka-broker-api-versions.sh --bootstrap-server $broker:9092
done
```

### 数据迁移

```bash
# 将某些 Partition 迁移到新 Broker
kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --generate --topics-to-move-json-file topics.json \
  --broker-list "1,2,3"  # 生成迁移计划

# 执行迁移
kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --execute --reassignment-json-file reassign.json

# 检查状态
kafka-reassign-partitions.sh --bootstrap-server localhost:9092 \
  --verify --reassignment-json-file reassign.json
```
