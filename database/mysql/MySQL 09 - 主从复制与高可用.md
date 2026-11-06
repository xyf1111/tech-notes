---
title: "MySQL 09 - 主从复制与高可用"
date: 2026-06-13
tags:
  - mysql
  - 数据库
aliases:
  - "MySQL 09"
---

# MySQL 09 — 主从复制与高可用

## 主从复制原理

```
Master                          Slave
┌─────────────┐                ┌─────────────┐
│  Binlog     │─── dump ─────→│  Relay Log   │
│ (二进制日志) │    thread      │ (中继日志)   │
└─────────────┘                └─────────────┘
       │                              │
  写操作进来                     SQL 线程读取
       │                              │
   数据变更                  回放 SQL 到从库
```

### 三个线程

| 线程 | 所在节点 | 职责 |
|------|---------|------|
| **Binlog Dump** | Master | 读取 binlog 推送给 Slave |
| **I/O Thread** | Slave | 接收 binlog 写入 relay log |
| **SQL Thread** | Slave | 读取 relay log 回放 SQL |

### 复制步骤

```
1. Master 提交事务 → 写入 Binlog
2. Slave I/O Thread 连接 Master 请求 binlog
3. Master Binlog Dump Thread 发送 binlog
4. Slave I/O Thread 写入 Relay Log
5. Slave SQL Thread 读取 Relay Log 回放
```

## 复制模式

### 异步复制（默认）

```
Master: 写入 binlog → 返回 OK → 不管 Slave 是否收到
优点：性能最好
缺点：Master 宕机时数据可能丢失
```

### 半同步复制

```
Master: 写入 binlog → 等待至少一个 Slave 确认 → 返回 OK
要求：安装 semisync_master/semisync_slave 插件
优点：数据不丢失
缺点：性能略低（增加一次网络往返）
```

### 全同步复制

```
Master: 等待所有 Slave 确认 → 返回 OK
优点：强一致性
缺点：性能很差
```

## GTID 复制

GTID（Global Transaction Identifier）是每个事务的唯一标识：

```
GTID = server_uuid:transaction_id
例：3E11FA47-71CA-11E1-9E33-C80AA9429562:1
```

### 优势

```sql
-- 传统复制：需要指定 binlog 文件名和位置
CHANGE MASTER TO
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=107;

-- GTID 复制：自动追踪事务
CHANGE MASTER TO
  MASTER_AUTO_POSITION=1;
```

### 故障切换

```sql
-- 从库提升为主库
-- 传统：需要找对 binlog 位置，容易出错
-- GTID：自动跳过已执行事务，无需手动定位
STOP SLAVE;
RESET MASTER;
```

## 高可用方案

| 方案 | 自动切换 | 一致性 | 成本 |
|------|---------|--------|------|
| **主从 + 手动切换** | ❌ | 最终一致性 | 低 |
| **MHA** | ✅ 30s | 最终一致性 | 中 |
| **Orchestrator** | ✅ 10s | 最终一致性 | 中 |
| **MySQL InnoDB Cluster** | ✅ 5s | 强一致 | 高 |
| **ProxySQL + MGR** | ✅ 5s | 强一致 | 高 |
| **Galera/Percona XtraDB** | ✅ 自动 | 强一致 | 高 |

### MHA（Master High Availability）

```
┌─────────┐  Manager  ┌─────────┐
│ Master  │ ◄────────►│ Manager │
└────┬────┘           ├─────────┤
     │                │ Monitor │
     │                └─────────┘
┌────┴────┐           ┌─────────┐
│ Slave 1 │           │ Slave 2 │
├─────────┤           ├─────────┤
│ 候选主库 │           │ 只读从库 │
└─────────┘           └─────────┘

故障切换步骤：
1. Manager 检测到 Master 宕机
2. 选择数据最完整的 Slave 作为新 Master
3. 其他 Slave 指向新 Master
4. 应用程序更新连接
```

### MySQL InnoDB Cluster

```
                ┌─────────────┐
                │  MySQL      │
                │  Router     │
                └──────┬──────┘
                       │
         ┌─────────────┼─────────────┐
         │             │             │
    ┌────┴────┐   ┌────┴────┐   ┌────┴────┐
    │ Primary │   │ Secondary│   │ Secondary│
    │ (读写)   │   │ (只读)   │   │ (只读)   │
    └─────────┘   └─────────┘   └─────────┘
                    Group Replication
```

## 延迟与数据一致性

### 主从延迟

```sql
-- 查看从库延迟 (秒)
SHOW SLAVE STATUS\G
-- Seconds_Behind_Master: 0

-- 常见原因
-- 1. Slave 硬件比 Master 差
-- 2. Slave 只有单线程回放（可开启并行复制）
-- 3. 大事务（DELETE 大量数据）
```

### 并行复制（MySQL 5.7+）

```sql
-- 开启并行复制
-- slave_parallel_workers = 4
-- slave_parallel_type = LOGICAL_CLOCK

-- 基于组提交的并行回放
-- 在 Master 上同时提交的事务可以在 Slave 上并行回放
```

## 参考资料

- [MySQL 主从复制官方文档](https://dev.mysql.com/doc/refman/8.0/en/replication.html)
- [MHA 项目](https://github.com/yoshinorim/mha4mysql-manager)
- [MySQL InnoDB Cluster](https://dev.mysql.com/doc/refman/8.0/en/mysql-innodb-cluster-introduction.html)
- [GTID 复制](https://dev.mysql.com/doc/refman/8.0/en/replication-gtids.html)
