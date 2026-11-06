---
title: "MySQL 08 - 分库分表与读写分离"
date: 2026-06-13
tags:
  - mysql
  - 数据库
aliases:
  - "MySQL 08"
---

# MySQL 08 — 分库分表与读写分离

## 读写分离

### 原理

```
     应用程序
        │
        ├── 写操作 → Master（主库）
        │
        └── 读操作 → Slave（从库）
                        │
                 ┌──────┴──────┐
                 │ Slave 1   │ Slave 2
                 └───────────┘
```

### 实现方式

```go
// 应用层：多数据源
type DBManager struct {
    master *sql.DB
    slaves []*sql.DB
    mu     sync.RWMutex
    next   int  // 轮询计数器
}

func (m *DBManager) Master() *sql.DB { return m.master }

func (m *DBManager) Slave() *sql.DB {
    m.mu.Lock()
    idx := m.next % len(m.slaves)
    m.next++
    m.mu.Unlock()
    return m.slaves[idx]
}

// 使用
func GetUser(id int) (*User, error) {
    db := dbm.Slave()  // 读走从库
    // ...
}

func CreateUser(user *User) error {
    db := dbm.Master()  // 写走主库
    // ...
}
```

### 中间件方案

| 方案 | 说明 |
|------|------|
| **ProxySQL** | 高性能 MySQL 代理，支持查询路由 |
| **MyCAT** | 开源的分布式数据库中间件 |
| **ShardingSphere** | Apache 顶级项目，支持多种数据库 |
| **应用层** | 代码层面多数据源切换 |

## 分表（Table Sharding）

### 垂直分表

把一个表的字段拆分到多个表：

```
users_basic (高频字段)
├── id, name, email, created_at

users_ext (低频/大字段)
├── id, avatar_url, bio, settings
```

### 水平分表

按某个字段把数据分散到多个结构相同的表：

```sql
-- 按用户 ID 取模分 8 表
-- 查询时：table_idx = user_id % 8
CREATE TABLE user_0 ( ... );
CREATE TABLE user_1 ( ... );
-- ...
CREATE TABLE user_7 ( ... );
```

## 分库（Database Sharding）

### 垂直分库

按业务拆分到不同数据库：

```
db_user      ← 用户相关
db_order     ← 订单相关
db_product   ← 商品相关
```

### 水平分库

数据分散到多个数据库实例：

```sql
-- 按 user_id 范围
db_0: user_id 1-1000000
db_1: user_id 1000001-2000000

-- 按 user_id 取模（一致性哈希更好）
db_0: user_id % 2 = 0
db_1: user_id % 2 = 1
```

## 分片策略

| 策略 | 说明 | 优缺点 |
|------|------|--------|
| **范围分片** | 按 ID/时间范围 | 简单，但容易数据倾斜 |
| **哈希分片** | `hash(key) % N` | 均匀分布，但扩缩容困难 |
| **一致性哈希** | 环形哈希 | 扩缩容影响最小 |
| **时间分片** | 按年/月分表 | 适合日志类数据 |

### 一致性哈希

```
   Node C            Node A
      ●──────────────●
      │              │
      │    Ring      │
      │              │
      ●──────────────●
   Node C            Node B

key1 → hash → Node A
key2 → hash → Node B
key3 → hash → Node C

添加 Node D 时，只影响一个节点的一部分数据
```

## 分片带来的问题

| 问题 | 说明 | 解决方案 |
|------|------|---------|
| **跨库 JOIN** | 无法跨库关联查询 | 应用层聚合 / ES 宽表 |
| **全局唯一 ID** | 自增主键失效 | Snowflake / UUID / 号段模式 |
| **分页排序** | `ORDER BY ... LIMIT` | 各分片查 → 应用层合并 |
| **分布式事务** | 跨库事务 | TCC / Saga / 最终一致性 |
| **数据迁移** | 扩容需要迁移 | 一致性哈希 / 双写迁移 |

### Snowflake 算法

```go
type Snowflake struct {
    mu         sync.Mutex
    timestamp  int64
    workerID   int64
    sequence   int64
}

func (s *Snowflake) NextID() int64 {
    s.mu.Lock()
    defer s.mu.Unlock()

    now := time.Now().UnixMilli()
    if now == s.timestamp {
        s.sequence++
    } else {
        s.sequence = 0
        s.timestamp = now
    }
    // 41bit 时间戳 | 10bit 机器 | 12bit 序列号
    return (now << 22) | (s.workerID << 12) | s.sequence
}
```

## 扩缩容方案

```go
// 平滑迁移：双写
// 1. 新库就绪
// 2. 开启双写（写旧库+新库）
// 3. 历史数据迁移
// 4. 校验数据一致性
// 5. 切换读流量到新库
// 6. 停止双写
```

## 参考资料

- [MySQL 官方文档：分区](https://dev.mysql.com/doc/refman/8.0/en/partitioning.html)
- [一致性哈希算法](https://en.wikipedia.org/wiki/Consistent_hashing)
- [Snowflake ID 算法](https://github.com/twitter-archive/snowflake)
- [ShardingSphere 官方文档](https://shardingsphere.apache.org/)
