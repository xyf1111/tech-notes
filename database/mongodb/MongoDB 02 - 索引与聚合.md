---
title: "MongoDB 02 - 索引与聚合"
date: 2024-01-01
tags: [MongoDB]
---

# MongoDB 02 - 索引与聚合

## 索引

### 索引类型

```javascript
// 单字段索引（默认，创建时自动加 _id 索引）
db.users.createIndex({ email: 1 })

// 复合索引 — 字段顺序重要
db.users.createIndex({ age: 1, name: 1 })

// 唯一索引
db.users.createIndex({ email: 1 }, { unique: true })

// 文本索引 — 全文搜索
db.articles.createIndex({ title: "text", content: "text" })

// TTL 索引 — 自动过期
db.logs.createIndex({ createdAt: 1 }, { expireAfterSeconds: 3600 })

// 哈希索引 — 分片键
db.users.createIndex({ _id: "hashed" })
```

### 索引使用建议

```javascript
// 查看查询是否用了索引
db.users.find({ age: { $gte: 25 } }).explain("executionStats")

// 列出所有索引
db.users.getIndexes()

// 删除索引
db.users.dropIndex("email_1")
```

### 索引规则

1. **ESR 原则**：Equality → Sort → Range（复合索引字段顺序）
2. 覆盖查询（Covered Query）：所有字段都在索引中，无需查文档
3. 索引不是越多越好 — 每次写入要更新所有相关索引

## 聚合管道（Aggregation Pipeline）

管道是一系列阶段（Stage），数据依次经过每个阶段处理：

```
db.collection.aggregate([
  { $match: ... },    // 过滤
  { $group: ... },    // 分组
  { $sort: ... },     // 排序
  { $project: ... },  // 投影
  { $limit: ... },    // 限制
  { $skip: ... }      // 跳过
])
```

### 常用阶段

```javascript
// $match — 过滤（等同 find 条件，尽量放最前面）
db.orders.aggregate([
  { $match: { status: "paid", amount: { $gte: 100 } } }
])

// $group — 分组聚合
db.orders.aggregate([
  { $group: {
    _id: "$status",
    totalAmount: { $sum: "$amount" },
    avgAmount:   { $avg: "$amount" },
    count:       { $sum: 1 },
    maxAmount:   { $max: "$amount" }
  }}
])

// $project — 投影和字段变换
db.orders.aggregate([
  { $project: {
    orderId: "$_id",
    total:   { $multiply: ["$amount", 1.1] },  // 含税
    status:  1,
    _id:     0
  }}
])

// $sort — 排序
db.orders.aggregate([
  { $sort: { amount: -1, createdAt: 1 } }
])

// $limit / $skip — 分页
db.orders.aggregate([
  { $sort: { createdAt: -1 } },
  { $skip: 20 },
  { $limit: 10 }
])
```

### 多表关联（$lookup）

类似 SQL 的 LEFT JOIN：

```javascript
db.orders.aggregate([
  { $lookup: {
    from: "users",              // 关联集合
    localField: "userId",       // 本地字段
    foreignField: "_id",        // 关联字段
    as: "user"                  // 结果字段名
  }},
  { $unwind: "$user" },         // 展开数组
  { $project: {
    orderId: "$_id",
    userName: "$user.name",
    amount: 1,
    _id: 0
  }}
])
```

### 数组操作

```javascript
// $unwind — 数组展开
db.articles.aggregate([
  { $unwind: "$tags" },
  { $group: {
    _id: "$tags",
    count: { $sum: 1 }
  }},
  { $sort: { count: -1 } }
])
// 结果: [{"_id":"mongodb","count":10}, {"_id":"golang","count":7}]

// $addFields — 添加计算字段
db.orders.aggregate([
  { $addFields: {
    tax: { $multiply: ["$amount", 0.13] }
  }}
])
```

## 实战示例

### 用户行为分析

```javascript
// 最近 7 天，按天统计活跃用户数
db.events.aggregate([
  { $match: {
    eventType: "page_view",
    timestamp: { $gte: new Date(Date.now() - 7 * 24 * 3600 * 1000) }
  }},
  { $group: {
    _id: { $dateToString: { format: "%Y-%m-%d", date: "$timestamp" } },
    uniqueUsers: { $addToSet: "$userId" },
    totalEvents: { $sum: 1 }
  }},
  { $project: {
    date: "$_id",
    activeUsers: { $size: "$uniqueUsers" },
    totalEvents: 1,
    _id: 0
  }},
  { $sort: { date: 1 } }
])
```
