---
title: "MongoDB 03 - 副本集与分片集群"
date: 2024-01-01
tags: [MongoDB]
---

# MongoDB 03 - 副本集与分片集群

## 副本集（Replica Set）

副本集是 MongoDB 的高可用方案，由 3 个或以上节点组成：

```
客户端 → Primary（读写）
              │
        同步 Oplog
              │
    ┌─────────┼─────────┐
    │         │         │
Secondary1  Secondary2  Arbiter（可选，仅投票）
```

### 节点类型

| 类型 | 角色 |
|------|------|
| Primary | 唯一接受写操作的节点 |
| Secondary | 从 Primary 同步，可配置为可读 |
| Arbiter | 不存数据，只参与选举投票（奇数节点时不需要） |

### 搭建副本集

```javascript
// 启动三个 mongod 实例
mongod --replSet rs0 --port 27017 --dbpath /data/rs0-1
mongod --replSet rs0 --port 27018 --dbpath /data/rs0-2
mongod --replSet rs0 --port 27019 --dbpath /data/rs0-3

// 初始化
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "localhost:27017" },
    { _id: 1, host: "localhost:27018" },
    { _id: 2, host: "localhost:27019", arbiterOnly: true }
  ]
})

// 查看状态
rs.status()
rs.isMaster()
```

### 读写配置

```javascript
// 连接字符串（客户端自动识别主节点，自动故障转移）
mongodb://host1:27017,host2:27018,host3:27019/db?replicaSet=rs0

// 允许从节点读（读写分离）
db.getMongo().setReadPref("secondaryPreferred")
```

### 故障转移

- Primary 宕机 → 自动选举新 Primary（通常 5-10 秒）
- 选举基于 Raft 协议，需要大多数节点存活（3节点集群需≥2个）
- 旧 Primary 恢复后自动降级为 Secondary

## 分片集群（Sharded Cluster）

分片用于水平扩展数据量超过单节点的场景：

```
                     mongos（路由）
                    /     |     \
          shard1        shard2        shard3
       (副本集 rs1)  (副本集 rs2)  (副本集 rs3)
                     config server（元数据）
```

### 分片键选择

```javascript
// 开启分片
sh.enableSharding("mydb")

// 基于范围分片（适合范围查询多）
sh.shardCollection("mydb.users", { _id: "hashed" })

// 基于哈希分片（数据均匀分布）
sh.shardCollection("mydb.logs", { _id: "hashed" })

// 复合分片键
sh.shardCollection("mydb.orders", { userId: 1, createdAt: 1 })
```

### 分片键选择原则

| 策略 | 适合 | 不适合 |
|------|------|--------|
| 哈希 | 写入密集、均匀分布 | 范围查询多 |
| 范围 | 按范围查询（时间、ID连续） | 写入集中在最新范围 |
| 复合 | 按用户+时间分片 | 首字段区分度低 |

### 分片集群搭建（简化）

```javascript
// 1. 启动 Config Server（副本集）
mongod --configsvr --replSet config --port 27019

// 2. 启动 mongos 路由
mongos --configdb config/host1:27019,host2:27019 --port 27017

// 3. 添加分片
sh.addShard("rs1/host1:27018")
sh.addShard("rs2/host2:27018")
```

## 对比

| 特性 | 副本集 | 分片集群 |
|------|--------|---------|
| 目的 | 高可用 | 水平扩展 |
| 数据量 | < 2TB | 无限（理论上） |
| 复杂度 | 低 | 高 |
| 节点数 | 3+ | 6+（含 config） |
| 自动故障转移 | ✅ | ✅（每个分片内） |
| 读写扩展 | 读可扩展 | 读写均可扩展 |
| 运维 | 简单 | 复杂（需要规划分片键） |

## 备份与恢复

```bash
# 全量备份
mongodump --uri="mongodb://localhost:27017/mydb" --out=/backup/2024-01

# 全量恢复
mongorestore --uri="mongodb://localhost:27017/mydb" /backup/2024-01

# 副本集备份（推荐--oplog 实现时间点恢复）
mongodump --oplog --out=/backup/2024-01
mongorestore --oplogReplay /backup/2024-01
```
