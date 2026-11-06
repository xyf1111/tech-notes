---
title: "MySQL 16 - SQL 学习路线"
date: 2026-08-05
tags: [sql, learning, roadmap, database]
source: "鱼皮·编程导航 / codefather"
---

# MySQL 16 - SQL 学习路线

> 本路线基于 codefather（鱼皮·编程导航）《2026年最新SQL免费实战自学网站零基础到精通一条龙》整理的精简版：去除商业推广，保留核心知识点、学习资源与学习建议，涵盖 SQL 基础语法、进阶查询、性能优化、实战应用、求职备战 5 个阶段，以免费实战练习（闯关式网站 + 在线题库）为主线，零基础可直达精通。

## 开篇介绍

数据库是用于存储和管理数据的仓库，SQL（Structured Query Language，结构化查询语言）就是用来操作数据库的标准语言。无论你是后端开发、数据分析，还是产品经理，SQL 都是必备技能之一。通过学习 SQL，你可以轻松地对数据进行增删改查、统计分析、复杂查询等操作，更好地理解和管理数据。

### 为什么要学 SQL？

1. **应用广泛** — 几乎所有需要存储数据的系统都会用到数据库和 SQL
2. **简单易学** — SQL 语法接近自然语言，学习难度不大
3. **求职必备** — 大部分技术岗位（开发、数据分析、测试等）都要求掌握 SQL
4. **数据分析基础** — 是进行数据分析和数据科学的基础工具
5. **薪资加分项** — 熟练掌握 SQL 可显著提升求职竞争力

### 就业方向

后端开发工程师、数据分析师、数据库工程师（DBA）、数据科学家、测试工程师、产品经理（需数据分析能力）——这些岗位都需要 SQL 技能。

### 免费闯关式自学网站：SQL 之母

正式学习前，强烈推荐鱼皮开发的 **免费闯关式 SQL 自学网站 —— SQL 之母**：

- 网站地址：https://sqlfather.yupi.icu（备用：https://sqlmother.yupi.icu）
- 30+ 个精心设计的 SQL 闯关题目，实战练习快速入门 SQL，比单纯看教程效果好很多
- 项目演示视频：https://www.bilibili.com/video/BV1pV4y1i7LW
- 项目已开源：https://github.com/liyupi/sql-mother

## 整体学习建议

1. **理论结合实践** — 不要只看教程，一定要多动手写 SQL 语句，可用 SQL 之母闯关练习，或在本地安装数据库环境
2. **选择一个主流数据库** — 建议优先学习 MySQL（开源、免费、应用广泛），掌握 SQL 基础语法后再了解其他数据库的差异
3. **先学标准 SQL** — 重点学习标准 SQL 语法（增删改查、多表查询、聚合函数等），这些语法在各个数据库中都是通用的
4. **多用 AI 辅助学习** — 遇到不理解的 SQL 语法或报错，可以问 AI 工具（比如 DeepSeek）让它解释或帮你改正
5. **多看优秀的 SQL** — 阅读开源项目中的建表语句和查询语句，学习别人如何设计表结构、编写复杂查询
6. **注重查询性能** — 学会使用 EXPLAIN 分析查询计划，了解索引的作用，养成写高效 SQL 的习惯

## SQL 知识体系

### SQL 分类

| 分类 | 全称 | 作用 | 常用语句 |
| --- | --- | --- | --- |
| DDL | 数据定义语言 | 定义和管理数据库对象（库、表、索引、视图） | CREATE、ALTER、DROP、TRUNCATE |
| DML | 数据操作语言 | 对表中数据进行增删改 | INSERT、UPDATE、DELETE |
| DQL | 数据查询语言 | 查询数据（使用最频繁） | SELECT |
| DCL | 数据控制语言 | 控制访问权限和安全性 | GRANT、REVOKE |
| TCL | 事务控制语言 | 管理事务，保证数据一致性和完整性 | START TRANSACTION、COMMIT、ROLLBACK、SAVEPOINT |

```sql
CREATE DATABASE school;
CREATE TABLE student (id INT PRIMARY KEY, name VARCHAR(50), age INT);
ALTER TABLE student ADD COLUMN email VARCHAR(100);
DROP TABLE student;
INSERT INTO student (id, name, age) VALUES (1, '张三', 20);
UPDATE student SET age = 21 WHERE id = 1;
DELETE FROM student WHERE id = 1;
SELECT name, age FROM student WHERE age > 20 ORDER BY age DESC;
SELECT class, COUNT(*) as count FROM student GROUP BY class;
SELECT s.name, c.course_name FROM student s JOIN course c ON s.id = c.student_id;
START TRANSACTION;
UPDATE account SET balance = balance - 100 WHERE id = 1;
UPDATE account SET balance = balance + 100 WHERE id = 2;
COMMIT;
```

### SQL 方言

| 数据库 | 特点 | 分页写法 | 字符串拼接 |
| --- | --- | --- | --- |
| MySQL | 最流行开源数据库，语法简单，适合入门 | `LIMIT 10 OFFSET 0` | `CONCAT(a, b)` |
| PostgreSQL | 功能强大的开源数据库，支持复杂查询和扩展 | `LIMIT 10 OFFSET 0` | `a \|\| b` |
| Oracle | 企业级商业数据库，使用 PL/SQL | `ROWNUM <= 10` / `FETCH FIRST 10 ROWS ONLY` | `a \|\| b` |
| SQL Server | 微软商业数据库，使用 T-SQL | `TOP 10` / `OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY` | `a + b` |

建议先学习标准 SQL 语法，再根据工作需要学习特定数据库的方言特性。

## 阶段 1：SQL 基础语法

### 学习目标

掌握 SQL 的基本语法，能够进行简单的数据库和表操作、数据的增删改查。

### 知识点

**1、数据库基础概念【必学】**

- 什么是数据库、数据库管理系统（DBMS）
- 关系型数据库的基本概念：表、行、列、主键、外键
- SQL 的作用和分类

**2、数据定义语言（DDL）【必学】**

- 创建/删除/选择数据库：`CREATE DATABASE`、`DROP DATABASE`、`USE`
- 创建表 `CREATE TABLE`：数据类型（INT、VARCHAR、DATE、DATETIME 等）、约束（PRIMARY KEY、NOT NULL、UNIQUE、DEFAULT、AUTO_INCREMENT）
- 修改表 `ALTER TABLE`、删除表 `DROP TABLE`、清空表 `TRUNCATE TABLE`

**3、数据操作语言（DML）【必学】**

- 插入数据：`INSERT INTO`
- 更新数据：`UPDATE ... SET ... WHERE`
- 删除数据：`DELETE FROM ... WHERE`

**4、数据查询语言（DQL）基础【必学】**

- 查询所有/指定列：`SELECT * FROM`、`SELECT col1, col2 FROM`
- 条件查询 `WHERE`：比较运算符（`=`、`>`、`<`、`>=`、`<=`、`!=`、`<>`）、逻辑运算符（AND、OR、NOT）、模糊查询（LIKE、`%`、`_`）、范围查询（BETWEEN ... AND、IN）、空值判断（IS NULL / IS NOT NULL）
- 去重 `DISTINCT`、排序 `ORDER BY`（ASC、DESC）、限制数量 `LIMIT`

### 学习建议

1. 先了解数据库基本概念，理解什么是表、行、列、主键，这是学习 SQL 的基础
2. 动手实践最重要：每学一个语法都要实际操作一遍，可用 SQL 之母闯关练习
3. 从简单开始：先学会创建表、插入数据、查询数据，再逐步学习更复杂的操作
4. 熟记常用数据类型：重点掌握 INT、VARCHAR、TEXT、DATE、DATETIME、DECIMAL
5. 理解约束的作用：主键、外键、唯一约束、非空约束等保证数据的完整性和一致性

### 学习资源

- ⭐ [SQL 之母（免费闯关式学习）](https://sqlmother.yupi.icu) — 闯关练习快速入门 SQL；[项目演示视频](https://www.bilibili.com/video/BV1pV4y1i7LW)
- ⭐ [史上最易懂 SQL 教程（10 小时）](https://www.bilibili.com/video/BV1UE41147KC/)；[SQL 数据库两小时半快速入门](https://www.bilibili.com/video/BV1yw4m1S7Be/)
- [MySQL 官方文档](https://dev.mysql.com/doc/) — 权威参考资料

## 阶段 2：SQL 进阶查询

### 学习目标

掌握复杂查询、多表查询、子查询、聚合函数等进阶技能，能够处理复杂的业务查询需求。

### 知识点

**1、聚合函数【必学】**

- `COUNT()` 计数、`SUM()` 求和、`AVG()` 平均值、`MAX()` 最大值、`MIN()` 最小值
- `GROUP BY` 分组、`HAVING` 分组后的条件筛选

**2、多表查询【必学】**

- 内连接 `INNER JOIN`、左外连接 `LEFT JOIN`、右外连接 `RIGHT JOIN`
- 全外连接 `FULL OUTER JOIN`（MySQL 不支持，可用 UNION 实现）、交叉连接 `CROSS JOIN`、自连接

**3、子查询【必学】**

- 单行子查询、多行子查询（`IN`、`ANY`、`ALL`）、相关子查询、`EXISTS` / `NOT EXISTS`

```sql
SELECT class, COUNT(*) as student_count FROM student GROUP BY class;
SELECT class, AVG(score) as avg_score FROM student GROUP BY class HAVING AVG(score) > 80;
SELECT s.name, c.course_name FROM student s INNER JOIN course c ON s.id = c.student_id;
SELECT s.name, c.course_name FROM student s LEFT JOIN course c ON s.id = c.student_id;
SELECT * FROM student WHERE score > (SELECT AVG(score) FROM student);
SELECT * FROM student WHERE id IN (SELECT DISTINCT student_id FROM course);
```

**4、高级查询技巧【建议学】**

- 联合查询 `UNION` / `UNION ALL`、条件表达式 `CASE WHEN`
- 窗口函数：`ROW_NUMBER()` 行号、`RANK()` 排名、`DENSE_RANK()` 密集排名、`PARTITION BY` 分区
- 公共表表达式（CTE）：`WITH ... AS`

```sql
SELECT name,
    CASE WHEN score >= 90 THEN '优秀'
         WHEN score >= 80 THEN '良好'
         WHEN score >= 60 THEN '及格'
         ELSE '不及格' END as grade
FROM student;

SELECT * FROM (
    SELECT name, class, score,
        ROW_NUMBER() OVER (PARTITION BY class ORDER BY score DESC) as rank
    FROM student
) as ranked WHERE rank <= 3;
```

**5、视图和索引【建议学】**

- 视图：`CREATE VIEW`、`DROP VIEW`
- 索引：`CREATE INDEX`、`DROP INDEX`；索引类型：主键索引、唯一索引、普通索引、全文索引

### 学习建议

1. 掌握多表连接是关键：左连接和内连接的区别一定要清楚，多画图理解两表连接的结果
2. 多做复杂查询练习：找包含多表关联、分组统计、条件筛选的综合题目练习
3. 理解子查询的执行顺序：子查询一般先执行，再被外层查询使用
4. 窗口函数很强大：虽然语法复杂，但能解决排名、累计等问题，值得深入学习

### 学习资源

- ⭐ [LeetCode 数据库题库](https://leetcode.cn/problemset/database/) — 大量实战练习题；[SQL 窗口函数详解](https://www.bilibili.com/video/BV1q54y1f7h6)

## 阶段 3：SQL 性能优化

### 学习目标

了解 SQL 查询的性能优化方法，能够编写高效的 SQL 语句，理解索引的原理和使用。

### 知识点

**1、查询优化基础【必学】**

- 使用 `EXPLAIN` 分析查询计划，理解查询的执行过程
- 避免全表扫描；减少子查询的使用（能用 JOIN 就用 JOIN）
- 避免在 WHERE 子句中使用函数或表达式；使用 `LIMIT` 限制返回结果

**2、索引优化【必学】**

- 索引的原理（B+ 树）
- 何时需要创建索引、索引的优缺点
- 联合索引和最左前缀原则、覆盖索引、索引失效的场景

**3、SQL 编写最佳实践【建议学】**

- 避免 `SELECT *`，只查询需要的列
- 合理使用 `EXISTS` 代替 `IN`；使用 `UNION ALL` 代替 `UNION`（不需要去重时）
- 批量操作代替单条操作；避免使用 `OR`，考虑使用 `IN` 或 `UNION`

### 学习建议

1. 性能优化是经验积累的过程：不要死记硬背优化技巧，要理解背后的原理
2. 多使用 EXPLAIN 分析：每写一个复杂查询，都用 EXPLAIN 看执行计划，观察是否用到索引
3. 索引不是越多越好：过多的索引会影响写入性能，要根据实际查询需求合理创建
4. 结合具体数据库学习：不同数据库的优化策略不同，可结合 MySQL 或 PostgreSQL 的优化专题深入学习
5. 关注慢查询日志：实际工作中通过分析慢查询日志来定位性能问题

### 学习资源

- [MySQL 索引和查询优化](https://www.bilibili.com/video/BV1iq4y1u7vj/) — 索引原理和优化；[SQL 调优实战](https://www.bilibili.com/video/BV1Kr4y1i7ru/) — 真实案例分析

## 阶段 4：SQL 实战应用

### 学习目标

将 SQL 知识应用到实际项目中，结合具体的数据库系统进行实战练习。

### 知识点

**1、结合具体数据库实战【必学】**

- 选择一个主流数据库深入学习（推荐 MySQL），学习安装和配置
- 了解数据库管理工具：Navicat、DBeaver、MySQL Workbench
- 实践数据库的备份和恢复

**2、实际业务场景练习【必学】**

- 用户管理系统（用户表、角色表、权限表）
- 电商系统（商品表、订单表、用户表）
- 学生管理系统（学生表、课程表、成绩表）
- 博客系统（文章表、评论表、标签表）

**3、结合编程语言使用 SQL【建议学】**

- 在后端代码中执行 SQL（JDBC、MyBatis、Hibernate 等）
- ORM 框架的使用、SQL 注入的防范

### 学习建议

1. 从简单项目开始：先做一个简单的学生管理系统或博客系统，设计表结构并实现增删改查
2. 关注表结构设计：良好的表结构设计是高效查询的基础，学习数据库设计三范式
3. 参加开源项目：阅读开源项目中的数据库设计和 SQL 语句，学习优秀的实践经验
4. 结合具体数据库深入：建议选择 MySQL 作为主攻方向，系统学习 MySQL 的特性和优化

### 学习资源与项目实战

- ⭐ [SQL 之母开源项目](https://github.com/liyupi/sql-mother) — 纯前端实现的 SQL 学习网站，可学习源码实现
- ⭐ [LeetCode 数据库题库](https://leetcode.cn/problemset/database/) — 大量 SQL 实战题目
- [SQL Zoo](https://sqlzoo.net/) — 在线 SQL 练习平台；[HackerRank SQL](https://www.hackerrank.com/domains/sql) — 国外 SQL 练习平台

## 阶段 5：求职备战

SQL 是大部分技术岗位面试的必考内容，尤其是后端开发、数据分析等岗位。

### 学习目标

熟练掌握常见的 SQL 面试题，能够快速准确地编写 SQL 语句，顺利通过 SQL 相关的面试环节。

### 学习建议

1. 多刷 LeetCode 数据库题：涵盖大部分面试考点，建议至少刷 50+ 道题
2. 准备手写 SQL：面试时可能要求现场手写 SQL，要能快速写出正确的查询语句；常见考点：多表连接、分组统计、排名查询、去重等
3. 理解 SQL 执行原理：面试官可能问 SQL 的执行顺序、索引原理、查询优化等，要有深入理解
4. 准备项目中的 SQL 经验：简历上的项目涉及数据库时，提前准备好如何讲解表设计、如何优化慢查询
5. 关注数据库特性：应聘特定数据库相关岗位（如 MySQL DBA），要深入学习该数据库的特性和优化

### 面试考察形式

1. 手写 SQL 查询：给定表结构和需求，现场编写 SQL 语句（最常见）
2. 口述 SQL 思路：描述如何用 SQL 实现某个复杂查询
3. SQL 优化：给一个慢查询，让你分析问题并优化
4. 数据库设计：给定业务场景，设计合理的表结构
5. 理论知识：询问索引原理、事务隔离级别、锁机制等

### 经典面试题

**理论题**

1. 说说 SQL 的执行顺序？ 2. 什么是索引？索引有哪些类型？ 3. 索引在什么情况下会失效？ 4. `INNER JOIN`、`LEFT JOIN`、`RIGHT JOIN` 的区别？
5. `WHERE` 和 `HAVING` 的区别？ 6. `UNION` 和 `UNION ALL` 的区别？ 7. 什么是事务？事务的 ACID 特性是什么？ 8. 如何优化慢查询？

**实践题（高频）**

1. 查询每个部门工资最高的员工
2. 查询每个班级成绩排名前 3 的学生
3. 查询连续登录 3 天以上的用户
4. 删除重复数据，只保留 id 最小的一条
5. 统计每个用户的累计消费金额
6. 查询至少选了两门课程的学生
7. 查询每个月的订单数量和总金额
8. 实现分页查询（考虑性能优化）

> 来源：鱼皮·编程导航 / codefather
