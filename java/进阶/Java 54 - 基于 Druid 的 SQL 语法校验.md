---
title: "Java 54 - 基于 Druid 的 SQL 语法校验"
date: 2026-08-27
tags: [Java, SQL, Druid, 参数校验, 实战]
source: "鱼皮·编程导航 / codefather"
---

# Java 54 - 基于 Druid 的 SQL 语法校验

> 数据分析看板允许用户任意输入 SQL 并保存为看板配置，必须在校验 SQL 合法性后才能入库。没有现成校验库时，用 Druid 连接池自带的 `SQLUtils.parseStatements`「移花接木」完成语法校验，几分钟搞定。

## 场景：SQL 看板

内部数据分析系统：用户输入 SQL 查询语句 → 保存为「数据看板」→ 之后打开看板即可浏览该 SQL 查询出的最新数据，无需反复输入。

关键风险：写 SQL 的用户与看数据的用户可能不是同一人。若配置时 SQL 写错（语法错误、`sleetc * from table` 之类），后端直接执行必然失败，后续看板用户只会看到查不出数据，且根本不会想到是配置的 SQL 本身错了。

因此**必须在保存配置时就校验 SQL 是否合法**。

## 校验位置：后端

前端、后端校验都重要，但后端是直接操作数据库的**最后一道防线**，校验逻辑应放在后端。

## 方案演进对比

| 方案 | 思路 | 问题 |
|------|------|------|
| 找现成校验库 | 搜索开箱即用的 SQL 校验类库 | 没有找到能直接用的 PostgreSQL 校验库 |
| 模拟查询 | 保存时用该 SQL 实际查一次库，报错即非法 | 配置时数据表可能还没准备好，无论语句是否正确都查不出数据；需先确认表存在才可用 |
| 正则表达式 | 按 `SELECT ... FROM ... WHERE ...` 结构匹配 | 真实业务 SQL 含四则运算、IF/CASE WHEN 分支、日期与聚合函数等，正则难以覆盖 |
| 自写解析器 | 类编译原理，把 SQL 解析成抽象语法树（AST）逐节点校验 | 实现成本极高，需要专业知识，不划算 |
| **Druid 移花接木** ✅ | 利用 Druid 连接池自带的 SQL 解析能力 | 无——解析失败抛异常即判定非法 |

## 最终实现：Druid SQLUtils

阿里的 Druid 数据库连接池类库自带 SQL 格式化功能，说明其内部能解析 SQL。其 `SQLUtils.parseStatements` 方法支持多种 SQL 方言（MySQL、PostgreSQL 等）的解析：

```java
// 解析，接受 sql 语句和数据库方言为参数；解析失败会抛异常
SQLUtils.parseStatements(sql, POSTGRESQL);
```

校验逻辑：

```java
try {
  String sql = "select * from a";
  SQLUtils.parseStatements(sql, POSTGRESQL);
  return true;   // 解析成功 → SQL 合法
} catch (ParserException e) {
  LOGGER.error("解析失败", e);
  return false;  // 解析失败 → SQL 非法
}
```

几分钟完成代码，再用各种 SQL 语句测试。虽只实现基本语法校验，但综合效果与成本已足够。前端暂用 `CodeMirror` 做 SQL 代码高亮即可，无需前端校验。

## 经验思考

1. **移花接木：从整体转向局部**。找不到直接满足需求的库时，想想其他类库是否包含该功能——就像查词典找不到单词 `apple`，但目录里有 `a`，翻进去 `apple` 就藏在其中。Druid 的「SQL 格式化」功能背后就是「SQL 解析」能力。
2. **前人栽树，后人乘凉**。网上现成代码很多，不是为学习的话没必要重复造轮子。
3. **注重积累**。写代码时多学多总结，把技术沉淀进自己的武器库，否则「前人栽的树」找不到就可惜了。

> 来源：鱼皮·编程导航 / codefather
