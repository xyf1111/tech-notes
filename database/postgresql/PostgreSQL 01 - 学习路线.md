---
title: "PostgreSQL 01 - 学习路线"
date: 2026-08-01
tags:
  - PostgreSQL
  - 数据库
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# PostgreSQL 学习路线

> 本路线基于 codefather（鱼皮·编程导航）《2026年最新PostgreSQL数据库学习路线》整理的精简版：去除商业推广，保留核心知识点、官方文档链接与学习建议，涵盖 PostgreSQL 基础、SQL 实战与进阶、高级特性、性能优化与运维、求职备战 5 个阶段。PostgreSQL 支持完整 SQL 标准与 JSON、数组等非关系型特性，已在 Stack Overflow 2024 开发者调查中取代 MySQL 成为最流行数据库。

## 开篇：为什么学 PostgreSQL

PostgreSQL（简称 PG）是世界上最先进的开源关系型数据库之一，以强大的功能、高度的可扩展性、严格的数据完整性和优秀的性能闻名，被称为"数据库界的瑞士军刀"。它支持完整 SQL 标准，提供事务、外键、视图、触发器、存储过程等高级特性，还可作为文档数据库使用，支持自定义数据类型、函数、操作符，甚至可用 Python、JavaScript、C 等语言编写存储过程。

相比 MySQL，PG 在数据完整性、复杂查询、并发控制等方面更优，Instagram、Reddit、Uber、Apple 等大型公司都在使用。在 AI 时代，PG 的向量扩展 pgvector 使其成为 AI 应用的理想数据库，可存储和检索嵌入向量（embeddings），支撑语义搜索、推荐系统、RAG 等应用。

### 就业方向

1. **数据库管理员（DBA）** — 负责 PostgreSQL 的管理、维护、备份恢复、性能优化
2. **后端开发工程师** — 使用 PostgreSQL 作为数据存储，开发业务系统
3. **数据开发工程师** — 编写复杂 SQL 查询，进行数据处理和分析
4. **数据分析师** — 使用 PostgreSQL 进行数据分析和报表开发
5. **大数据工程师** — 使用 PostgreSQL 进行数据仓库建设
6. **AI 工程师** — 使用 PostgreSQL + pgvector 开发 AI 应用

## 整体学习建议

1. **边学边练是王道** — 数据库学习最忌讳只看不练，每个 SQL 语句都要亲手敲一遍，可用在线 SQL 练习平台刷题
2. **先会用再深入** — 先把前 3 个阶段（PostgreSQL 基础、SQL 实战、高级特性）学完即可满足日常开发，性能优化和运维部分遇到实际问题时再深入学习
3. **学过 MySQL 可快速过基础** — 如果已学 MySQL，基础部分快速过一遍，重点学习 PG 特有的高级特性（窗口函数、CTE、JSON 操作、全文搜索等）
4. **善用 AI 工具辅助学习** — 用 ChatGPT、Claude、Kimi 等辅助理解概念、生成 SQL 语句、优化 SQL 性能
5. **多看官方文档** — PG 官方文档非常详细且中文翻译质量高，遇到问题优先查阅官方文档

## 阶段 1：PostgreSQL 基础（12-20 天，仅供参考）

### 学习目标

理解关系型数据库的基本概念，掌握 PostgreSQL 的安装和基本操作，能够通过命令行或可视化工具创建数据库、设计表结构、进行简单的增删改查操作。

### 知识点

- **数据库基本概念【必学】** — 关系型数据库概念；数据库、表、字段、记录；主键、外键、索引；SQL 语言分类（DDL、DML、DQL、DCL）
- **安装和配置【必学】** — Windows/macOS/Linux 安装；初始化数据库集群；配置文件（postgresql.conf、pg_hba.conf）；服务启动和停止
- **数据库操作【必学】** — CREATE DATABASE、DROP DATABASE、`\l` 查看列表、`\c` 切换数据库
- **数据表操作【必学】** — CREATE TABLE、ALTER TABLE、DROP TABLE、`\d` 查看表结构
- **数据类型【必学】** — 数字（INTEGER、BIGINT、NUMERIC、REAL、DOUBLE PRECISION）；字符（CHAR、VARCHAR、TEXT）；日期时间（DATE、TIME、TIMESTAMP、INTERVAL）；布尔（BOOLEAN）；JSON / JSONB、数组（ARRAY）【建议学】
- **数据操作【必学】** — INSERT、DELETE、UPDATE、SELECT
- **约束【必学】** — PRIMARY KEY、FOREIGN KEY、UNIQUE、NOT NULL、CHECK、DEFAULT
- **客户端工具【建议学】** — psql 命令行工具；pgAdmin 官方图形化工具；DBeaver；DataGrip

### 学习建议

- PG 安装相对简单，建议本地安装一个练习；不想安装可用 Docker 快速启动容器
- 先熟悉 psql 基本命令，再使用图形化工具（pgAdmin、DBeaver）
- PG 数据类型比 MySQL 丰富很多（JSON、JSONB、数组），重点学习这些高级类型
- 以实践为主，参考官方文档教程示例，动手创建数据库、建表、插入数据

### 学习资源

- [PostgreSQL 官方中文文档](http://www.postgres.cn/docs/current/index.html)：最权威的学习资料
- [零基础入门 PostgreSQL 教程 2025 最新版（B站）](https://www.bilibili.com/video/BV1Wp4y1K7QN/)：系统教程
- [PostgreSQL 教程 - Redrock Postgres](https://www.rockdata.net/zh-cn/tutorial/)：详细教程

### 练习平台

- [SQL 自学网](https://sqlmother.yupi.icu/)：在线刷 SQL 题（支持标准 SQL 语法）

## 阶段 2：SQL 实战和进阶（10-15 天，仅供参考）

### 学习目标

熟练掌握 SQL 语句的各种语法，能够独立编写复杂的多表查询、子查询、聚合查询，根据业务需求快速写出高效的 SQL 语句。

### 知识点

- **基础查询【必学】** — SELECT、WHERE 条件过滤、ORDER BY 排序、LIMIT/OFFSET 分页、DISTINCT 去重
- **聚合函数【必学】** — COUNT、SUM、AVG、MAX、MIN；GROUP BY 分组；HAVING 分组过滤
- **多表查询【必学，面试重点】** — INNER JOIN、LEFT JOIN、RIGHT JOIN、FULL OUTER JOIN、CROSS JOIN、自连接（Self JOIN）
- **子查询【必学】** — WHERE 子查询、FROM 子查询、SELECT 子查询、EXISTS 子查询
- **集合操作【建议学】** — UNION（去重合并）、UNION ALL（不去重合并）、INTERSECT（交集）、EXCEPT（差集）
- **窗口函数【必学，PG 特色】** — ROW_NUMBER、RANK、DENSE_RANK；SUM OVER、AVG OVER；LAG、LEAD；FIRST_VALUE、LAST_VALUE
- **通用表表达式 CTE【建议学，PG 特色】** — WITH 语句、递归 CTE
- **SQL 函数【建议学】** — 字符串（CONCAT、SUBSTRING、LENGTH、UPPER、LOWER）；日期时间（NOW、CURRENT_DATE、EXTRACT、DATE_TRUNC）；数学（ROUND、CEIL、FLOOR、ABS）；条件（CASE WHEN、COALESCE、NULLIF）

### 学习重点

- SQL 是数据库学习的核心，一定要多练习，从简单到复杂逐步提升
- 窗口函数和 CTE 是 PG 的强大特性，比 MySQL 更灵活强大，在数据分析、报表开发中非常常用
- 多表查询（JOIN）是难点也是面试重点，理解各种 JOIN 的区别和使用场景
- 子查询性能一般不如 JOIN，实际开发中能用 JOIN 就不用子查询
- 善用 EXPLAIN 分析 SQL 执行计划，理解执行过程，为性能优化打基础

### 学习资源

- [PostgreSQL 窗口函数官方教程](https://www.postgresql.org/docs/current/tutorial-window.html)：官方文档
- [LeetCode 数据库题目](https://leetcode.cn/problemset/database/)：SQL 刷题
- [SQL 自学网](https://sqlmother.yupi.icu/)：在线刷 SQL 题

## 阶段 3：PostgreSQL 高级特性（12-20 天，仅供参考）

### 学习目标

掌握 PostgreSQL 的高级特性，能够使用视图、存储过程、触发器、JSON 操作、全文搜索等功能，根据业务需求选择合适的技术方案。

### 知识点

- **视图（View）【必学】** — CREATE VIEW；物化视图（MATERIALIZED VIEW）；视图的更新和删除
- **索引【必学，面试重点】** — B-Tree（默认）；Hash；GiST（地理空间数据）；GIN（全文搜索、JSON、数组）；部分索引；表达式索引；多列索引
- **事务【必学，面试重点】** — ACID 特性；BEGIN、COMMIT、ROLLBACK；事务隔离级别（Read Uncommitted、Read Committed、Repeatable Read、Serializable）；MVCC 多版本并发控制
- **存储过程和函数【建议学】** — CREATE FUNCTION；PL/pgSQL 语言；CREATE PROCEDURE
- **触发器【建议学】** — CREATE TRIGGER；BEFORE / AFTER；FOR EACH ROW / FOR EACH STATEMENT
- **JSON 操作【必学，PG 特色】** — JSON 和 JSONB 的区别；插入和查询；操作符（`->`、`->>`、`#>`、`#>>`）；函数（jsonb_set、jsonb_insert、jsonb_array_elements）；GIN 索引
- **数组操作【建议学】** — 数组创建和查询；操作符（`&&`、`@>`、`<@`）；函数（array_append、array_prepend、unnest）
- **全文搜索【建议学，PG 特色】** — tsvector / tsquery 类型；to_tsvector / to_tsquery 函数；GIN 索引；中文分词（zhparser 扩展）
- **范围类型【可不学】** — INT4RANGE、INT8RANGE；TSRANGE、TSTZRANGE；范围操作符
- **枚举类型【可不学】** — CREATE TYPE ... AS ENUM；枚举类型的使用

### 学习建议

- 高级特性非常丰富，**不需要全部学完**：视图、索引、事务、JSON 操作必学，其他了解概念、用到时再深入
- JSONB 查询性能非常好，很多场景下可替代 MongoDB 等文档数据库
- 全文搜索可实现类似 Elasticsearch 的搜索功能，需要搜索功能时可优先考虑 PG 而不是引入 ES
- 存储过程和触发器会增加系统复杂度，建议谨慎使用；**现代应用更推荐把业务逻辑放在应用层**
- 根据查询需求选索引：B-Tree 适合范围查询，GIN 适合全文搜索和 JSON 查询

### 学习资源

- [PostgreSQL 官方文档 - 高级特性](http://www.postgres.cn/docs/current/tutorial-advanced.html)：官方文档
- [PostgreSQL JSON 操作教程](https://www.postgresql.org/docs/current/datatype-json.html)：JSON 操作
- [PostgreSQL 全文搜索教程](https://www.postgresql.org/docs/current/textsearch.html)：全文搜索

## 阶段 4：性能优化和运维（10-15 天，仅供参考）

### 学习目标

理解 PostgreSQL 的执行原理和性能优化方法，能够分析和解决性能问题，掌握备份恢复、主从复制等运维技能。

### 知识点

- **性能优化【建议学，面试重点】** — EXPLAIN 执行计划分析；慢查询日志分析；SQL 优化（避免全表扫描、优化 JOIN、减少子查询）；索引优化（合理创建、避免失效）；查询缓存
- **PG 架构【建议学】** — 进程模型；共享内存和缓冲区；WAL（Write-Ahead Logging）；VACUUM 和 AUTOVACUUM
- **配置优化【建议学】** — shared_buffers；work_mem；maintenance_work_mem；effective_cache_size；max_connections
- **备份和恢复【建议学】** — pg_dump 逻辑备份；pg_basebackup 物理备份；PITR（时间点恢复）
- **主从复制和高可用【建议学】** — 流复制；逻辑复制；主从切换；读写分离
- **分区表【可不学】** — 范围分区（Range）、列表分区（List）、哈希分区（Hash）
- **监控和诊断【可不学】** — pg_stat_activity、pg_stat_statements、pg_locks；监控工具（pgAdmin、Prometheus + Grafana）

### 学习建议

- 性能优化是重点也是面试重点，优先学 EXPLAIN 执行计划分析和 SQL 优化，最实用
- 理解 VACUUM / AUTOVACUUM 的工作原理，负责回收被删除或更新行所占空间，避免表膨胀
- 想往 DBA 方向发展，深入学习主从复制的配置和管理
- 配置优化按实际硬件资源和业务场景调整，先默认配置，遇瓶颈再优化
- 后端开发可先了解概念、工作中遇到再深入；DBA 方向建议系统学习

### 学习资源

- [PostgreSQL 性能优化官方文档](https://www.postgresql.org/docs/current/performance-tips.html)：官方文档
- [PostgreSQL 主从复制官方文档](https://www.postgresql.org/docs/current/warm-standby.html)：官方文档

## 阶段 5：求职备战（面试前 1 个月突击）

### 学习目标

熟练掌握 PostgreSQL 常见面试题，能够流畅回答面试官提问，准备好简历上的项目经历，顺利通过 PostgreSQL 相关的面试环节。

### 学习建议

- 提前做规划，建议至少提前 3 个月准备，先看目标公司的招聘要求，了解对 PostgreSQL 的要求
- 打磨简历：简历上要有能体现 PostgreSQL 能力的项目经历（做过什么系统、设计了哪些表、写过哪些复杂 SQL、遇到过什么性能问题及如何优化）
- 面试题要理解而不是死记硬背：PG 面试侧重高级特性（窗口函数、CTE、JSON 操作、全文搜索等），先理解原理再看面试题
- 面试常问 PG 和 MySQL 的区别，要能说出 PG 的优势（更强的 ACID 保证、丰富的数据类型、强大的扩展性等）

### 经典面试题

**基础理论：**

1. PostgreSQL 和 MySQL 有什么区别？各有什么优缺点？
2. PostgreSQL 支持哪些数据类型？JSONB 和 JSON 有什么区别？
3. 什么是 MVCC？PostgreSQL 是如何实现 MVCC 的？
4. PostgreSQL 的事务隔离级别有哪些？默认是什么级别？

**SQL 相关：**

1. 什么是窗口函数？如何使用？
2. 什么是 CTE？CTE 和子查询有什么区别？
3. PostgreSQL 的 LEFT JOIN 和 RIGHT JOIN 有什么区别？
4. 如何编写递归查询？

**索引相关：**

1. PostgreSQL 支持哪些索引类型？各有什么特点？
2. GIN 索引和 B-Tree 索引有什么区别？
3. 什么是部分索引？什么时候使用部分索引？
4. 如何优化 PostgreSQL 的索引？

**高级特性：**

1. PostgreSQL 如何进行全文搜索？
2. PostgreSQL 的 JSONB 如何查询和索引？
3. PostgreSQL 的数组类型如何使用？
4. PostgreSQL 的存储过程和函数有什么区别？

**性能优化：**

1. 如何使用 EXPLAIN 分析 SQL 执行计划？
2. PostgreSQL 的慢查询如何优化？
3. 什么是 VACUUM？为什么需要 VACUUM？
4. PostgreSQL 如何进行主从复制？

## 持续学习资源

### PostgreSQL 专题资源

- [PostgreSQL Wiki](https://wiki.postgresql.org/)：PG 百科全书
- [Planet PostgreSQL](https://planet.postgresql.org/)：PG 博客聚合
- [PostgreSQL 邮件列表](https://www.postgresql.org/list/)：官方邮件列表

### 技术博客

- [Uber Engineering Blog](https://www.uber.com/blog/engineering/)：Uber PostgreSQL 实践
- [Netflix TechBlog](https://netflixtechblog.com/)：Netflix 数据库架构
- [Instagram Engineering](https://instagram-engineering.com/)：Instagram PostgreSQL 优化

### 扩展推荐

- [pgvector](https://github.com/pgvector/pgvector)：向量数据库扩展，支持 AI 应用
- [PostGIS](https://postgis.net/)：地理空间数据扩展
- [TimescaleDB](https://www.timescale.com/)：时序数据库扩展
- [Citus](https://www.citusdata.com/)：分布式 PostgreSQL 扩展
- [zhparser](https://github.com/amutu/zhparser)：中文分词扩展

## 写在最后

PostgreSQL 功能强大、扩展性高，被誉为"世界上最先进的开源数据库"。虽然 MySQL 的市场份额更大，但 PG 在数据完整性、复杂查询、高级特性等方面更有优势。学习 PG 不仅能提升求职竞争力，还能处理更复杂的业务场景；AI 时代 pgvector 使其成为 AI 应用（RAG 等）的理想数据库。如果已学过 MySQL，两者基础 SQL 语法相通，重点学习 PG 特有的高级特性即可。

> 来源：鱼皮·编程导航 / codefather「2026年最新PostgreSQL数据库学习路线零基础到精通一条龙」，已去推广、去图片，保留核心技术内容。
