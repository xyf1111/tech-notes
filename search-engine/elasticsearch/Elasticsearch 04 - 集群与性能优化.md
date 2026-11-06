---
title: "Elasticsearch 04 - 集群与性能优化"
date: 2024-01-01
tags: [Elasticsearch]
---

# Elasticsearch 04 - 集群与性能优化

## 集群部署

### 节点配置

```yaml
# elasticsearch.yml
cluster.name: production
node.name: node-1
path.data: /data/elasticsearch
path.logs: /var/log/elasticsearch

network.host: 0.0.0.0
http.port: 9200
transport.port: 9300

discovery.seed_hosts: ["node1:9300", "node2:9300", "node3:9300"]
cluster.initial_master_nodes: ["node-1", "node-2", "node-3"]

# 推荐配置
indices.memory.index_buffer_size: 10%    # 索引缓冲区
indices.fielddata.cache.size: 20%        # fielddata 缓存
indices.breaker.total.limit: 70%         # 断路器总上限
```

### 最小生产集群

```
3 个节点，每个节点的角色：
  master:   node-1, node-2, node-3  (3 个 Master，至少 2 个存活)
  data:     node-1, node-2, node-3  (所有节点都存数据)
  ingest:   node-1, node-2, node-3
```

## 分片策略

### 分片数确认

```
分片数 = max(数据总量 / 单分片容量, 期望节点数 × 分片副本)

经验值：
- 单分片建议 20-50GB
- 节点上的总分片数建议 < 1000
- 分片数在创建索引时确定，不可修改
```

### 路由

```json
// 自定义路由 — 相同路由的数据在同一分片上
PUT /orders/_doc/1?routing=user_123
{
  "user_id": "user_123",
  "order_id": 1
}

// 查询时指定路由（只查一个分片）
GET /orders/_search?routing=user_123
{
  "query": { "match": { "user_id": "user_123" } }
}
```

## 写入优化

```json
PUT /logs/_settings
{
  "index": {
    "refresh_interval": "30s",      // 增大刷新间隔
    "translog.durability": "async", // 异步 translog
    "translog.sync_interval": "5s", // 5s 刷一次 translog
    "number_of_replicas": 0         // 写时先不复制（写完后改为 1）
  }
}
```

批量写入：

```json
POST /_bulk
{ "index": { "_index": "logs", "_id": "1" } }
{ "timestamp": "...", "message": "..." }
{ "index": { "_index": "logs", "_id": "2" } }
{ "timestamp": "...", "message": "..." }
// 单次 bulk 建议 5-15MB
```

## 查询优化

```json
// 1. 使用 filter 代替 must（缓存）
{
  "bool": {
    "filter": [ ... ],
    "must": [ ... ]
  }
}

// 2. 限制返回字段
GET /products/_search
{
  "_source": ["title", "price"],
  ...
}

// 3. 精确字段用 keyword 类型
// 4. 避免 wildcard/regexp 前缀通配
// 5. 使用 search_after 替代大分页
```

### search_after（深度分页）

```json
GET /products/_search
{
  "size": 10,
  "sort": [
    { "price": "asc" },
    { "_id": "asc" }   // 需要唯一值确定位置
  ],
  "search_after": [99.99, "product_999"]  // 从上一条结果取值
}
```

## 硬件建议

| 组件 | 推荐 |
|------|------|
| CPU | 8 核以上（查询密集）/ 16 核以上（写入密集） |
| 内存 | 64GB 以上（一半给 JVM heap，一半给 OS page cache） |
| 磁盘 | SSD（NVMe 最佳），避免 NFS |
| 网络 | 10GbE |

### JVM Heap 配置

```bash
# jvm.options
-Xms31g
-Xmx31g
# 不要超过 32GB（压缩指针失效）
# 不要超过物理内存的 50%（留一半给 OS 做文件缓存）
```

## 监控指标

```json
// 关键指标
GET /_cluster/health
// status: green/yellow/red
// unassigned_shards: 0

GET /_cat/nodes?v
// cpu, load, heap.percent, ram.percent

GET /_cat/indices?v&s=docs.count:desc
// docs.count, store.size, search.query_current

GET /_nodes/stats
// 线程池、"search" 队列深度
```

### 常见问题

| 症状 | 原因 | 解决 |
|------|------|------|
| red cluster | 主分片未分配 | 检查磁盘/节点，reroute |
| slow search | 查询未优化 / 硬件不足 | 分析 explain，加节点 |
| high heap | 聚合/排序字段过多 | 增加 fielddata 限制 |
| disk full | 索引未滚动 / 保留期过长 | 使用 ILM 管理索引生命周期 |
