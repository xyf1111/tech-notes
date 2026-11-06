---
tags: [mysql, sql]
source: "鱼皮·编程导航 / codefather"
title: MySQL 14 - 高级SQL写法技巧
created: 2026-07-29
---

# MySQL 14 - 高级SQL写法技巧

## 一、ORDER BY FIELD() 自定义排序

`ORDER BY FIELD(str, str1, str2, ...)` 可按照指定顺序对字段进行排序。

```sql
SELECT * FROM order_diy 
ORDER BY FIELD(title, '九阴真经', '降龙十八掌', '九阴白骨爪', '双手互博', '桃花岛主', '全真内功心法', '蛤蟆功', '销魂掌', '灵白山少主');
```

> 查询结果：按 title 字段的指定顺序返回记录。

## 二、CASE 表达式按条件分类

可在 SELECT 中使用 `CASE WHEN` 根据字段值动态生成分类列。

```sql
SELECT *, 
  CASE WHEN money > 60 THEN '高级' 
       WHEN money > 30 THEN '中级' 
       ELSE '低级' 
  END AS level 
FROM order_diy;
```

> 查询结果：根据 money 值新增 level 列（高级/中级/低级）。

## 三、EXISTS 子查询关联判断

`EXISTS` 根据子查询的返回结果（TRUE/FALSE）筛选主查询数据——每一行主查询数据都会传入子查询做条件验证，结果为 TRUE 则保留该行。

```sql
-- 找出 emp 表中 dept_name 与 dept 表不匹配的员工
SELECT * FROM emp e 
WHERE EXISTS (
  SELECT * FROM dept p 
  WHERE e.dept_id = p.dept_id 
    AND e.dept_name != p.dept_name
);
```

## 四、GROUP_CONCAT 组连接函数

`GROUP_CONCAT(expr)` 将分组后指定字段的值连接为一个字符串，可指定排序和分隔符，默认用英文逗号。

```sql
SELECT name, GROUP_CONCAT(title ORDER BY id DESC SEPARATOR '-') 
FROM order_diy 
GROUP BY name 
ORDER BY NULL;
```

> 查询结果：每个 name 分组下，title 值按 id 降序以 '-' 连接展示。

## 五、自连接查询（树形结构平铺）

通过表的自连接，将父子层级数据平铺为多列展示。

```sql
SELECT t1.job_name AS '一级职位', 
       t2.job_name AS '二级职位', 
       t3.job_name AS '三级职位' 
FROM tree t1 
JOIN tree t2 ON t1.id = t2.pid 
LEFT JOIN tree t3 ON t2.id = t3.pid 
WHERE t1.pid = 0;
```

> 查询结果：将树形结构展平为三级职位列。

## 六、UPDATE + JOIN 关联更新

通过多表 JOIN 实现跨表关联更新。

```sql
-- 将 emp 表中员工的 dept_name 更新为 dept 表的正确值
UPDATE emp, dept 
SET emp.dept_name = dept.dept_name 
WHERE emp.dept_id = dept.dept_id;
```

> 操作前：emp 表中 jack 的部门名称与 dept 表不一致。
> 操作后：emp 表部门名称与 dept 表保持一致。

## 七、ORDER BY 空值 NULL 排序

字段中存在 NULL 值时，可通过 `IF(ISNULL(...), 0, 1)` 控制 NULL 值排在前面还是后面。

```sql
-- NULL 值排后面，非 NULL 按 money 排序
SELECT * FROM order_diy 
ORDER BY IF(ISNULL(title), 0, 1), money;
```

> 关键点：IF(ISNULL(title), 0, 1) 将 NULL 转为 0 放在后面，非 NULL 转为 1 按后续条件排序。

## 八、WITH ROLLUP 分组汇总

在 `GROUP BY` 后使用 `WITH ROLLUP` 可在分组统计基础上增加汇总行。

```sql
SELECT name, SUM(money) AS money 
FROM order_diy 
GROUP BY name WITH ROLLUP;
```

> 查询结果：除分组统计外，末行显示所有分组的汇总总和，但 name 字段为 NULL。
>
> 可用 `COALESCE(val1, val2, ...)` 将 NULL 替换为自定义文字：
> ```sql
> SELECT COALESCE(name, '合计') AS name, SUM(money) AS money 
> FROM order_diy 
> GROUP BY name WITH ROLLUP;
> ```

## 九、WITH AS（CTE）临时表别名

当多个子查询需要重复使用同一个查询结果时，可用 `WITH AS` 提取公共查询为临时表，简化复杂 SQL。

```sql
WITH t1 AS (SELECT * FROM order_diy WHERE money > 30),
     t2 AS (SELECT * FROM order_diy WHERE money > 60)
SELECT * FROM t1 
WHERE t1.id NOT IN (SELECT id FROM t2) 
  AND t1.name = '周伯通';
```

> 说明：CTE（Common Table Expression）将共用的子查询提取别名，后续可直接引用，提高可读性和复用性。

## 十、ON DUPLICATE KEY UPDATE（存在更新 / 不存在插入）

根据主键或唯一索引判断：有冲突则执行更新，无冲突则执行插入。

```sql
-- 第一次执行：插入新记录（news_code='wx-0003' 不存在）
INSERT INTO `news` (`news_title`, `news_auth`, `news_code`) 
VALUES ('新闻3', '小花', 'wx-0003') 
ON DUPLICATE KEY UPDATE news_title = '新闻3';

-- 第二次执行：更新已有记录（news_code='wx-0003' 已存在）
INSERT INTO `news` (`news_title`, `news_auth`, `news_code`) 
VALUES ('新闻4', '小花', 'wx-0003') 
ON DUPLICATE KEY UPDATE news_title = '新闻4';
```

> 前提：`news_code` 字段需建立唯一索引。
> 机制：根据唯一索引冲突判断，冲突时执行 `ON DUPLICATE KEY UPDATE` 后的赋值语句。

---

**总结**：以上十种 SQL 高级写法在日常开发中非常实用，涵盖排序、分类、关联查询、分组汇总、CTE 以及 UPSERT 等场景，能有效提升 SQL 编写效率与表达能力。
