---
title: "MySQL 10 - 字符串与日期格式转换"
date: 2026-07-22
tags: [mysql, date, string, conversion, oracle-migration]
source: "鱼皮·编程导航 / codefather"
---

# MySQL 10 - 字符串与日期格式转换

> MySQL 的字符串与日期互相转换函数及格式化说明，附 Oracle 迁移对照。

## 字符串转日期：STR_TO_DATE()

用于将指定格式的字符串转换为日期/时间类型。

```sql
-- 基本用法
SELECT STR_TO_DATE('28-11-2023 14:15:17', '%d-%m-%Y %H:%i:%s');
```

### Oracle 迁移对照

| 数据库 | 函数 | 示例 |
|--------|------|------|
| Oracle | `TO_DATE('28-11-2023 14:15:17', 'dd-mm-yyyy hh24:mi:ss')` |
| MySQL  | `STR_TO_DATE('28-11-2023 14:15:17', '%d-%m-%Y %H:%i:%s')` |

> 注意：MySQL 的格式化占位符以 `%` 开头，与 Oracle 不同。

### 常用格式化占位符

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `%Y` | 年份，四位数字 | 2023 |
| `%m` | 月份，两位数字 | 11 |
| `%d` | 日期，两位数字 | 28 |
| `%H` | 小时（24 小时制） | 14 |
| `%i` | 分钟 | 15 |
| `%s` | 秒 | 17 |

## 日期转字符串：DATE_FORMAT()

将日期/时间类型按指定格式输出为字符串。

```sql
-- 将日期转为指定格式字符串
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s');
-- 结果：2023-11-28 14:15:17
```

## 总结

- Oracle → MySQL：`TO_DATE` → `STR_TO_DATE`，注意将 `dd-mm-yyyy` 改为 `%d-%m-%Y`
- MySQL 日期格式化统一使用 `%` 占位符
- 反向转换（日期 → 字符串）用 `DATE_FORMAT(date, format)`

> 来源：鱼皮·编程导航 / codefather
