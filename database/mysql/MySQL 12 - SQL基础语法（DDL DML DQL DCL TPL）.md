---
title: "MySQL 12 - SQL基础语法（DDL DML DQL DCL TPL）"
date: 2026-07-23
tags: [mysql, sql, ddl, dml, dql, dcl, tpl]
source: "鱼皮·编程导航 / codefather"
---

# MySQL 12 - SQL基础语法（DDL DML DQL DCL TPL）

> SQL 分类速查：DDL（数据定义）、DML（数据操作）、DQL（数据查询）、DCL（数据控制）、TPL（事务处理）。

## DDL — 数据定义语言

> 操作数据库对象：数据库、表、视图等。

### 数据库操作

```sql
-- 创建
CREATE DATABASE 数据库名 [DEFAULT CHARSET utf8];

-- 删除
DROP DATABASE 数据库名;

-- 查看字符集
SELECT schema_name, default_character_set_name
FROM information_schema.schemata
WHERE schema_name = '数据库名';
```

### 表操作

```sql
-- 创建
CREATE TABLE 表名 (
  列名 数据类型(长度),
  ...
) [CHARACTER SET utf8 COLLATE utf8_general_ci];

-- 修改表名
ALTER TABLE 原表名 RENAME [TO] 新表名;

-- 修改列（列名、类型、长度）
ALTER TABLE 表名 CHANGE 原列名 新列名 新类型(新长度);

-- 新增列
ALTER TABLE 表名 ADD 新列名 新类型(新长度);

-- 删除列
ALTER TABLE 表名 DROP 原列名;

-- 删除表
DROP TABLE 表名;

-- 查看表信息
SHOW TABLE STATUS FROM 数据库名 LIKE '表名';
DESC 表名;
SHOW KEYS FROM 表名;
SHOW CREATE TABLE 表名;
```

### 列约束

| 约束类型 | 说明 | 添加语法 |
|----------|------|----------|
| **PRIMARY KEY** | 唯一且非空，每表一个 | `ALTER TABLE t ADD PRIMARY KEY (列);` |
| **UNIQUE KEY** | 值不重复，可为空，多列可用 | `ALTER TABLE t ADD UNIQUE KEY (列);` |
| **NOT NULL** | 值不能为 NULL | `ALTER TABLE t MODIFY 列 类型 NOT NULL;` |
| **CHECK** | 范围检查 | `ALTER TABLE t ADD CONSTRAINT ck_name CHECK(条件);` |
| **FOREIGN KEY** | 引用另一表的主键/唯一列 | `ALTER TABLE t ADD FOREIGN KEY (列) REFERENCES 其他表(列);` |

自增属性：

```sql
ALTER TABLE 表名 MODIFY 列名 字段类型 AUTO_INCREMENT;
ALTER TABLE 表名 AUTO_INCREMENT = 起始值;
```

删除外键约束需两步：

```sql
ALTER TABLE 表名 DROP FOREIGN KEY 约束名;
ALTER TABLE 表名 DROP KEY 约束名;
```

## DML — 数据操作语言

> 操作表中的数据（增、删、改）。

```sql
-- 插入
INSERT INTO 表名 (列1, 列2) VALUES (值1, 值2);

-- 批量插入
INSERT INTO 表名 VALUES (值1, 值2), (值3, 值4);

-- 更新（省略 WHERE 则更新全表）
UPDATE 表名 SET 列=值 WHERE 条件;

-- 删除（省略 WHERE 则删除全表数据）
DELETE FROM 表名 WHERE 条件;
```

## DQL — 数据查询语言

### 基本查询

```sql
SELECT 列1, 列2 FROM 表名 WHERE 条件;

-- 去重
SELECT DISTINCT 列 FROM 表名;

-- 别名
SELECT 列 AS 别名 FROM 表名;
```

### WHERE 条件筛选

| 类型 | 运算符 |
|------|--------|
| 比较 | `>`, `>=`, `<`, `<=`, `!=`, `=` |
| 算术 | `+`, `-`, `*`, `/` |
| 逻辑 | `AND`, `OR`, `NOT`（AND 优先级高于 OR） |
| 范围 | `[NOT] BETWEEN ... AND ...` |
| 集合 | `[NOT] IN (...)` |
| 模糊 | `[NOT] LIKE 'xxx'`（`%` 匹配 0~n 字符，`_` 匹配单个字符） |

### 排序

```sql
ORDER BY 列1 ASC, 列2 DESC   -- asc 升序（默认），desc 降序
```

### 分组

> WHERE > GROUP BY > HAVING > ORDER BY

```sql
-- 分组后只能展示分组列和聚合函数结果
SELECT 班级, COUNT(*) FROM 学生表 GROUP BY 班级;

-- 先筛选后分组
WHERE + GROUP BY

-- 先分组再筛选
GROUP BY + HAVING
```

### 嵌套查询

- 子查询结果可作为条件（同表或不同表均可）
- 子查询结果可作为临时表（需起别名）

```sql
SELECT * FROM (SELECT * FROM 表 WHERE 条件) AS 临时表;
```

### 分页

```sql
SELECT * FROM 表 LIMIT a, b;   -- a=起始行索引(0-based), b=行数
```

### 联合查询

| 类型 | 语法 | 说明 |
|------|------|------|
| 笛卡尔积 | `SELECT * FROM A, B` | 无条件拼接，行数=A×B，列数=A+B |
| 等值连接 | `SELECT * FROM A, B WHERE A.x = B.y` | 在笛卡尔积上筛选 |
| 左外连接 | `SELECT * FROM A LEFT JOIN B ON 条件` | 左表全显，右表无匹配则 NULL |
| 右外连接 | `SELECT * FROM A RIGHT JOIN B ON 条件` | 右表全显，左表无匹配则 NULL |
| 内连接 | `SELECT * FROM A INNER JOIN B ON 条件` | 结果同等值连接 |

### UNION 集合操作

```sql
SELECT ... UNION [ALL] SELECT ...
```

- UNION：合并后去重，性能较慢
- UNION ALL：直接合并，性能较快
- 前后列数必须一致

## DCL — 数据控制语言

> 控制用户权限。

### 用户管理

```sql
-- 创建用户
CREATE USER '用户名'@'IP' IDENTIFIED BY '密码';

-- 查看用户权限
SHOW GRANTS FOR '用户名'@'IP';

-- 赋予权限
GRANT 权限 ON 数据库.表 TO '用户'@'IP';
FLUSH PRIVILEGES;

-- 回收权限
REVOKE 权限 ON 数据库.表 FROM '用户名'@'IP';

-- 修改密码
ALTER USER root@localhost IDENTIFIED BY '新密码';

-- 删除用户
DROP USER '用户名'@'IP';
```

### 权限分类

| 层级 | 权限 |
|------|------|
| 数据级 | Create, Alter, Drop, Insert, Delete, Update, Select, References, Index |
| 对象级 | Create View, Create Routine, Execute, Trigger, Create User |
| 管理级 | Grant Option, Show View, Show Databases, Lock Table, File, Process, Reload, ShutDown |
| 特殊 | All（全部权限）, Usage（仅允许登录） |

## TPL — 事务处理语言

### ACID 特性

| 特性 | 说明 |
|------|------|
| **原子性** (Atomicity) | 事务中的操作要么全成功，要么全回滚 |
| **一致性** (Consistency) | 事务前后数据保持合法状态 |
| **隔离性** (Isolation) | 并发事务互不干扰 |
| **持久性** (Durability) | 提交后修改永久保存 |

### 事务操作

```sql
START TRANSACTION;  -- 或 BEGIN;
-- 执行 SQL...
COMMIT;             -- 提交
ROLLBACK;           -- 回滚
SAVEPOINT xx;       -- 保存还原点
```

MySQL 默认每条 SQL 自动提交。

### 隔离级别

| 级别 | 脏读 | 不可重复读 | 幻读 | 性能 |
|------|------|-----------|------|------|
| READ UNCOMMITTED | ✅ | ✅ | ✅ | 最高 |
| READ COMMITTED | ❌ | ✅ | ✅ | ↑ |
| REPEATABLE READ (MySQL 默认) | ❌ | ❌ | ✅ | ↓ |
| SERIALIZABLE | ❌ | ❌ | ❌ | 最低 |

```sql
-- 查看当前隔离级别
SELECT @@tx_isolation;

-- 修改隔离级别
SET SESSION TRANSACTION ISOLATION LEVEL xxx;
```

## 常用 SQL 速查

```sql
-- 数据库列表
SHOW DATABASES;

-- 选择数据库
USE database名;

-- 表列表
SHOW TABLES;
```

> 来源：鱼皮·编程导航 / codefather
