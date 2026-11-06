---
title: "MongoDB 01 - 基础概念与CRUD"
date: 2024-01-01
tags: [MongoDB]
---

# MongoDB 01 - 基础概念与 CRUD

## 什么是 MongoDB

MongoDB 是一个文档型 NoSQL 数据库，由 MongoDB Inc. 开发。

### 核心特性

- **文档模型** — JSON-like BSON 格式，天然匹配对象
- **Schema-less** — 动态模式，灵活迭代
- **分布式** — 原生分片 + 副本集
- **聚合管道** — 链式数据处理
- **索引丰富** — 单字段/复合/文本/地理/TTL 索引

### 与关系型数据库的类比

| MongoDB | MySQL |
|---------|-------|
| Database（数据库） | Database |
| Collection（集合） | Table（表） |
| Document（文档） | Row（行） |
| Field（字段） | Column（列） |
| $lookup | JOIN（左连接） |
| 聚合管道 | GROUP BY + 子查询 |

## 数据类型

```
String     → "hello"
Integer    → 42
Double     → 3.14
Boolean    → true / false
Array      → [1, 2, 3]
Object     → {"nested": "value"}
ObjectId   → ObjectId("...")   # 自动生成的 12 字节唯一 ID
Date       → ISODate("2024-01-15")
Null       → null
Binary     → BinData(...)
```

## 基本 CRUD

### 创建

```javascript
// 插入单条
db.users.insertOne({
  name: "张三",
  email: "zhangsan@example.com",
  age: 28,
  tags: ["developer", "golang"],
  createdAt: new Date()
})

// 批量插入
db.users.insertMany([
  { name: "李四", age: 25 },
  { name: "王五", age: 32 }
])
```

### 查询

```javascript
// 查询所有
db.users.find()

// 条件查询
db.users.find({ age: { $gte: 25, $lte: 35 } })

// 多条件（AND）
db.users.find({ age: { $gte: 25 }, tags: "golang" })

// OR 条件
db.users.find({
  $or: [
    { age: { $lt: 20 } },
    { age: { $gt: 30 } }
  ]
})

// 字段筛选
db.users.find(
  { age: { $gte: 25 } },
  { name: 1, email: 1, _id: 0 }  // 1=显示, 0=隐藏
)

// 排序+分页
db.users.find()
  .sort({ age: -1 })    // -1 降序, 1 升序
  .skip(10)              // 跳过前 10 条
  .limit(10)             // 取 10 条
```

### 更新

```javascript
// 更新单个文档
db.users.updateOne(
  { email: "zhangsan@example.com" },
  { $set: { age: 29 } }
)

// 批量更新
db.users.updateMany(
  { age: { $lt: 20 } },
  { $set: { status: "minor" } }
)

// 替换整个文档
db.users.replaceOne(
  { _id: ObjectId("...") },
  { name: "新用户", email: "new@example.com" }
)

// 原子递增
db.users.updateOne(
  { _id: ObjectId("...") },
  { $inc: { score: 10 } }
)
```

### 删除

```javascript
// 删除单条
db.users.deleteOne({ email: "old@example.com" })

// 批量删除
db.users.deleteMany({ status: "inactive" })

// 清空集合
db.users.deleteMany({})
```

## 查询操作符

### 比较操作符

| 操作符 | 含义 |
|--------|------|
| `$eq` | 等于 |
| `$ne` | 不等于 |
| `$gt` / `$gte` | 大于 / 大于等于 |
| `$lt` / `$lte` | 小于 / 小于等于 |
| `$in` / `$nin` | 在列表中 / 不在列表中 |

### 数组操作符

```javascript
// 包含某个值
db.articles.find({ tags: "mongodb" })

// 精确数组匹配
db.articles.find({ tags: ["mongodb", "database"] })

// 所有值匹配
db.articles.find({ tags: { $all: ["mongodb", "nosql"] } })

// 数组长度
db.articles.find({ tags: { $size: 3 } })
```

## Go 驱动使用

```go
import "go.mongodb.org/mongo-driver/mongo"
import "go.mongodb.org/mongo-driver/bson"

// 连接
client, _ := mongo.Connect(context.Background(),
    options.Client().ApplyURI("mongodb://localhost:27017"))
defer client.Disconnect(context.Background())

// 获取集合
coll := client.Database("testdb").Collection("users")

// 插入
result, _ := coll.InsertOne(context.Background(), bson.M{
    "name": "张三",
    "age":  28,
})

// 查询
var user bson.M
coll.FindOne(context.Background(), bson.M{"name": "张三"}).Decode(&user)

// 聚合
pipeline := mongo.Pipeline{
    {{"$match", bson.M{"age": bson.M{"$gte": 25}}}},
    {{"$group", bson.M{"_id": "$status", "count": bson.M{"$sum": 1}}}},
}
cursor, _ := coll.Aggregate(context.Background(), pipeline)
```
