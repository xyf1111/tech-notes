---
tags: [MongoDB, 学习路线, NoSQL]
date: 2026-07-31
source: 鱼皮·编程导航 / codefather
---

# MongoDB 学习路线

> 基于 CodeFather（编程导航）"2026 年最新 MongoDB 数据库学习路线" 整理的精简学习路线，涵盖 MongoDB 基础、CRUD 操作、聚合管道与索引、高级特性、面试备战五个阶段。去除了商业推广内容，保留核心技术知识点、官方文档链接和学习建议。

## 阶段 1：MongoDB 基础（10-15 天）

掌握 MongoDB 基本概念、安装配置和基础操作，能够创建数据库/集合，进行简单的文档插入和查询。

### NoSQL 数据库基础【必学】

- NoSQL 数据库分类：文档数据库、键值数据库、列族数据库、图数据库
- NoSQL vs 关系型数据库
- MongoDB 的特点和应用场景
- CAP 理论【建议学】

### MongoDB 核心概念【必学】

- 数据库（Database）
- 集合（Collection）
- 文档（Document）
- 字段（Field）
- BSON 数据格式
- `_id` 字段（主键）

### 安装和配置【必学】

- MongoDB 安装（Windows / macOS / Linux）
- 服务启动和停止
- 配置文件
- MongoDB Compass（官方图形化工具）
- Docker 快速启动或 MongoDB Atlas 免费版

### 数据库操作【必学】

| 操作 | 命令 |
|------|------|
| 创建/切换数据库 | `use <dbName>` |
| 查看数据库列表 | `show dbs` |
| 删除数据库 | `db.dropDatabase()` |

### 集合操作【必学】

| 操作 | 命令 |
|------|------|
| 创建集合 | `db.createCollection()` |
| 查看集合列表 | `show collections` |
| 删除集合 | `db.collection.drop()` |

### 文档基础【必学】

- 文档结构（键值对）
- 数据类型：字符串、数字、布尔、日期、数组、嵌套文档
- ObjectId 生成规则

### 客户端工具【建议学】

- **mongo shell**：官方命令行工具
- **MongoDB Compass**：官方图形化工具
- **Robo 3T / Studio 3T**：第三方管理工具
- **DataGrip**：JetBrains 数据库工具

### 学习建议

1. 优先动手实践，本地安装或使用 Docker / MongoDB Atlas 免费版
2. 先熟悉 mongo shell，再使用图形化工具
3. MongoDB 使用 JavaScript 作为查询语言，前端开发者上手快
4. BSON（Binary JSON）支持更多数据类型，查询效率更高
5. 同一集合中文档字段可不同，灵活但需注意数据一致性
6. 善用 [MongoDB 官方中文文档](https://www.mongodb.com/zh-cn/docs/manual/)

### 推荐资源

- ⭐ [MongoDB 官方中文文档](https://www.mongodb.com/zh-cn/docs/manual/)
- [MongoDB University](https://university.mongodb.com/)（官方免费课程）
- 2025 MongoDB 从入门到进阶（B站零基础保姆级教程）
- 黑马程序员 MongoDB 教程（B站系统教程）

---

## 阶段 2：CRUD 操作和查询（10-15 天）

熟练掌握 MongoDB 增删改查，能够使用各种查询操作符进行复杂查询。

### 插入文档【必学】

- `insertOne()`：插入单个文档
- `insertMany()`：插入多个文档

### 查询文档【必学】

- `find()` / `findOne()`
- 查询条件：相等、不等、大于、小于（`$gt`、`$lt`、`$gte`、`$lte`）
- 逻辑操作符：`$and`、`$or`、`$not`、`$nor`
- 数组查询：`$in`、`$nin`、`$all`、`$size`
- 元素查询：`$exists`、`$type`
- 正则表达式查询：`$regex`
- 投影（字段包含/排除、嵌套字段投影）
- 排序：`sort()`；分页：`limit()` + `skip()`

### 更新文档【必学】

| 操作 | 说明 |
|------|------|
| `updateOne()` | 更新单个文档 |
| `updateMany()` | 更新多个文档 |
| `replaceOne()` | 替换整个文档 |
| `$set` / `$unset` | 设置/删除字段 |
| `$inc` / `$mul` | 字段增减/乘法运算 |
| `$rename` / `$min` / `$max` | 重命名/条件更新 |
| `$push` / `$pop` / `$pull` / `$pullAll` / `$addToSet` | 数组更新操作符 |

### 删除文档【必学】

- `deleteOne()`：删除单个文档
- `deleteMany()`：删除多个文档

### 嵌套文档和数组查询【必学】

- 点表示法（dot notation）查询嵌套字段
- 数组元素查询
- `$elemMatch` 操作符

### 学习建议

1. MongoDB 查询语法使用 JSON 对象表示条件，与 SQL 完全不同，需转变思维方式
2. 更新操作灵活：`$set` 部分更新，`$inc`/`$mul` 字段运算
3. 重点学习数组的查询和更新操作
4. 学习点表示法查询嵌套字段
5. 建议创建示例数据库（电商、博客系统）进行大量练习

### 推荐资源

- ⭐ [MongoDB CRUD 操作官方文档](https://www.mongodb.com/zh-cn/docs/manual/crud/)
- [MongoDB 查询官方教程](https://www.mongodb.com/zh-cn/docs/manual/tutorial/)

---

## 阶段 3：聚合管道和索引（15-20 天）

掌握聚合管道进行复杂数据统计分析；掌握索引创建和查询优化。

### 聚合管道【必学，面试重点】

| 阶段 | 说明 |
|------|------|
| `$match` | 过滤文档（类似 SQL WHERE） |
| `$project` | 投影字段 |
| `$group` | 分组聚合 |
| `$sort` | 排序 |
| `$limit` / `$skip` | 分页 |
| `$unwind` | 展开数组 |
| `$lookup` | 关联查询（类似 SQL JOIN） |
| `$facet` | 多个聚合管道并行处理 |
| 聚合表达式 | `$sum`、`$avg`、`$max`、`$min`、`$first`、`$last` |

### 索引【必学，面试重点】

- 索引的作用和原理
- 单字段索引
- 复合索引（多字段索引）
- 唯一索引
- 文本索引（全文搜索，支持中文分词）
- 地理空间索引（2d、2dsphere）
- TTL 索引（自动过期）
- 部分索引（Partial Index）
- 稀疏索引（Sparse Index）

### 索引管理【必学】

| 操作 | 方法 |
|------|------|
| 创建索引 | `createIndex()` |
| 删除索引 | `dropIndex()` |
| 查看索引 | `getIndexes()` |
| 分析查询 | `explain()` |

### 查询性能优化【必学】

- 使用 `explain()` 分析查询执行计划
- 覆盖查询（Covered Query）
- 索引选择和优化策略
- 查询优化技巧

### 学习建议

1. 聚合管道由多个阶段组成，重点掌握 `$match`、`$group`、`$project`、`$sort`
2. `$lookup` 性能相对较差，MongoDB 更推荐使用嵌套文档或数组替代 JOIN
3. 根据实际查询需求选择合适的索引类型
4. 文本索引支持中文分词（设置 language 为 "chinese"）
5. `explain()` 是查询优化的重要工具，必须掌握

### 推荐资源

- ⭐ [MongoDB 聚合管道官方文档](https://www.mongodb.com/zh-cn/docs/manual/core/aggregation-pipeline/)
- ⭐ [MongoDB 索引官方文档](https://www.mongodb.com/zh-cn/docs/manual/indexes/)
- [MongoDB 聚合管道完整教程](https://www.mongodb.com/zh-cn/docs/manual/tutorial/aggregation-complete-examples/)

---

## 阶段 4：高级特性和优化（10-15 天）

掌握 MongoDB 事务、副本集、分片集群等高级特性，理解架构和优化方法。

### 事务【建议学】

- MongoDB 4.0+ 多文档事务支持
- 单文档事务 vs 多文档事务
- ACID 特性
- `startSession()` + `commitTransaction()`
- 注意：事务影响性能，推荐通过合理数据建模避免使用事务

### 数据建模【必学】

- 嵌套文档 vs 引用（Reference）
- 一对一、一对多、多对多关系建模
- 反范式设计
- 根据查询模式设计数据模型，不套用关系型设计方式

### 副本集【建议学】

- 概念与作用（高可用）
- 主节点（Primary）与从节点（Secondary）
- 选举机制
- 读写分离
- 配置和管理（至少 3 节点：1 主 2 从）

### 分片集群【建议学】

- 概念与作用（水平扩展）
- 分片键选择（查询频繁且数据分布均匀的字段）
- 分片策略：范围分片、哈希分片
- Config Server 和 Mongos 路由
- 配置和管理

### 备份和恢复【建议学】

- `mongodump`：逻辑备份
- `mongorestore`：逻辑恢复
- 文件系统快照
- MongoDB Atlas 自动备份

### 安全性【建议学】

- 用户认证
- 角色和权限管理
- 网络加密（TLS/SSL）
- 审计日志

### 监控和诊断【可不学】

- MongoDB 监控指标
- `db.serverStatus()`：服务器状态
- `db.currentOp()`：当前操作
- MongoDB Atlas 云监控

### 性能优化【建议学】

- 查询优化
- 索引优化
- 写入优化
- 连接池优化
- 硬件优化

### 学习建议

1. MongoDB 4.0+ 支持多文档事务，但推荐通过数据建模（嵌套文档）减少事务使用
2. 数据建模根据查询模式设计，推荐嵌套文档存储相关数据以减少查询次数
3. 副本集至少 3 节点，实现自动故障转移
4. 分片键选择至关重要，需选查询频繁且数据分布均匀的字段
5. 后端开发者可先了解概念，DBA 方向建议系统学习副本集和分片集群

### 推荐资源

- ⭐ [MongoDB 事务官方文档](https://www.mongodb.com/zh-cn/docs/manual/core/transactions/)
- [MongoDB 副本集官方文档](https://www.mongodb.com/zh-cn/docs/manual/replication/)
- [MongoDB 分片集群官方文档](https://www.mongodb.com/zh-cn/docs/manual/sharding/)
- [MongoDB University](https://university.mongodb.com/)（官方免费课程）

---

## 阶段 5：经典面试题（面试前突击）

### 基础理论

1. MongoDB 是什么？有什么特点？
2. MongoDB 和关系型数据库有什么区别？
3. 什么时候使用 MongoDB？什么时候使用 MySQL？
4. BSON 是什么？和 JSON 有什么区别？

### CRUD 操作

1. `insertOne` 和 `insertMany` 有什么区别？
2. `find` 和 `findOne` 有什么区别？
3. `$set` 和 `$inc` 有什么区别？
4. 如何查询嵌套文档和数组？

### 聚合和索引

1. 什么是聚合管道？常用的聚合阶段有哪些？
2. `$lookup` 是什么？如何使用？
3. MongoDB 支持哪些索引类型？如何创建索引？
4. 如何优化 MongoDB 查询性能？

### 数据建模

1. MongoDB 的数据建模原则是什么？
2. 嵌套文档和引用有什么区别？如何选择？
3. 如何在 MongoDB 中表示一对多关系？
4. 如何在 MongoDB 中表示多对多关系？

### 高级特性

1. 副本集是什么？有什么作用？
2. 分片集群是什么？如何选择分片键？
3. MongoDB 支持事务吗？和关系型数据库的事务有什么区别？
4. MongoDB 如何进行备份和恢复？

### 面试准备建议

- 理解 NoSQL 优势，能说出 MongoDB 与 MySQL 的对比及适用场景
- 简历上准备能体现 MongoDB 能力的项目经历（数据模型设计、性能优化案例）
- 准备实际案例：如何用 MongoDB 设计某系统，说明设计思路

---

### 持续学习资源

- ⭐ [MongoDB 官方中文文档](https://www.mongodb.com/zh-cn/docs/manual/)
- [MongoDB University](https://university.mongodb.com/)（官方免费课程）
- [MongoDB Blog](https://www.mongodb.com/blog)（官方技术博客）
- [MongoDB GitHub](https://github.com/mongodb)（开源项目）
- [MongoDB 中文社区](https://mongoing.com/)
- [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)（官方云服务，含免费版）
- [MongoDB Compass](https://www.mongodb.com/products/compass)（官方图形化工具）
- 技术博客：Uber Engineering Blog、eBay Tech Blog、美团技术团队（NoSQL 实践）

> 来源：鱼皮·编程导航 / codefather — "2026 年最新 MongoDB 数据库学习路线"
