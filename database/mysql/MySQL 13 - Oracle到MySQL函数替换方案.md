---
title: MySQL - Oracle 到 MySQL 函数替换方案
date: 2026-07-23
tags:
  - mysql
  - oracle
  - 数据库迁移
  - sql
source: "鱼皮·编程导航 / codefather"
---

# Oracle 到 MySQL 函数替换方案

> Oracle 迁移到 MySQL 5.7 的常用函数和语法对照表。

## 函数对照表

| 功能 | Oracle 语法 | MySQL 语法 |
|------|-------------|------------|
| 空值处理 | `NVL(col, 0)` | `IFNULL(col, 0)` |
| 转字符串 | `to_char(col)` | `CONVERT(col, CHAR)` |
| 行号递增 | `rownum` | `(@i:=@i+1)` + 初始化 `(SELECT @i:=0)` |
| DELETE 别名 | `DELETE FROM t WHERE ...` | `DELETE t FROM t WHERE ...` |
| 日期转字符串 | `to_char(date, 'fmt')` | `DATE_FORMAT(date, '%Y-%m-%d')` |
| 字符串转日期 | `to_date(str, 'fmt')` | `STR_TO_DATE(str, '%Y-%m-%d %H:%i:%s')` |
| 生成 UUID | `sys_guid()` | `REPLACE(UUID(), '-', '')` |
| 数字格式化 | `to_char(num, 'FM9999990.00')` | `FORMAT(num, 2)` |
| 拼音排序 | `nlssort(name, 'NLS_SORT=SCHINESE_PINYIN_M')` | `CONVERT(name USING gbk) ASC` |
| 月初截取 | `trunc(sysdate, 'mm')` | `DATE_ADD(SYSDATE(), INTERVAL -DAY(SYSDATE())+1 DAY)` |
| 截取日期 | `trunc(sysdate)` | `STR_TO_DATE(DATE_FORMAT(SYSDATE(), '%Y%m%d'), '%Y%m%d%H')` |
| 日期加减 | `sysdate - 1` | `DATE_ADD(@dt, INTERVAL 1 DAY)` |
| 条件取值 | `DECODE(col, v1, r1, v2, r2, ...)` | `CASE WHEN col=v1 THEN r1 WHEN col=v2 THEN r2 ELSE ... END` |
| NULL 排序末 | `ORDER BY col NULLS LAST` | `ORDER BY IF(ISNULL(col), 1, 0), col` |
| NULL 排序首 | `ORDER BY col NULLS FIRST` | `ORDER BY IF(ISNULL(col), 0, 1), col` |
| MERGE | `MERGE INTO t USING s ON(...)` | 拆分为 `UPDATE` + `INSERT` |
| 文本拼接 | `'a' \|\| 'b'` | `CONCAT('a', 'b')` |
| 时间差 | 直接相减（单位：天） | `TIMESTAMPDIFF(unit, start, end)` |
| 开窗排名 | `ROW_NUMBER() OVER(PARTITION BY col ORDER BY col2)` | 使用用户变量模拟（见下方） |

## 特殊说明

### SUBSTR 起始位置
MySQL 中 SUBSTR 不能将 0 作为起始点，需要改成 1。

### ROW_NUMBER OVER 的 MySQL 实现

**Oracle 写法**：
```sql
SELECT a.*,
ROW_NUMBER() OVER(PARTITION BY a.orderchildId ORDER BY a.CheckEndTime DESC) AS rum_num
FROM biz_qa_check_first a
```

**MySQL 写法**：
```sql
SELECT @rownum:=@rownum+1 AS rownum, a.*,
  IF(@orderchildId = a.orderchildId, @rank:=@rank+1, @rank:=1) AS rum_num,
  @orderchildId := a.orderchildId
FROM (
  SELECT * FROM biz_qa_check_first ORDER BY orderchildId, CheckEndTime DESC
) a,
(SELECT @rownum:=0, @orderchildId:=NULL, @rank:=0) b
```

### MERGE INTO 的替代方案

**Oracle 写法**：
```sql
MERGE INTO target t USING source s ON (t.id = s.id)
WHEN MATCHED THEN UPDATE SET t.name = s.name
WHEN NOT MATCHED THEN INSERT (id, name) VALUES (s.id, s.name)
```

**MySQL 写法**：
```sql
-- 拆分为 UPDATE + INSERT
UPDATE target t JOIN source s ON t.id = s.id SET t.name = s.name;
INSERT INTO target (id, name)
SELECT s.id, s.name FROM source s
WHERE NOT EXISTS (SELECT 1 FROM target t WHERE t.id = s.id);
```

> 来源：鱼皮·编程导航 / codefather
