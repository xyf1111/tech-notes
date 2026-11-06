---
title: "MySQL 06 - 慢查询与Explain"
date: 2021-03-08
tags: [mysql]
aliases:
  - "Mysql Optimize 01"
---

# MySQL 06 - 慢查询与Explain


## 优化的方面


1. 表设计


- 范式
- 存储引擎
- 字段类型


1. 功能


- 索引
- 缓存
- 分区


1. sql语句


- 合理的sql
- 经验


1. 架构


- 主从复制
- 负载均衡
- 读写分离

## ORDER BY 排序的实现（索引排序与 filesort）

排序结果只有两种来源：**索引本身有序**直接读，或**主动排序**（filesort）。

| 方式 | 触发条件 | Explain 特征 | 代价 |
|------|---------|-------------|------|
| 索引排序 | ORDER BY 字段已在索引中，且索引列顺序、升降序与 ORDER BY 完全一致 | 不出现 `Using filesort` | 最低，零排序开销 |
| filesort | 排序字段未命中索引，或顺序/方向与索引不一致 | `Extra: Using filesort` | 需要额外内存或磁盘排序 |

filesort 的执行路径按数据量分三档：

1. **内存排序（数据量 ≤ `sort_buffer_size`）**
   - **单路排序（Single-Pass Sort）**：select 列总长度 ≤ `max_length_for_sort_data`（默认 4096 字节）时，把查询用到的所有列都放进 `sort_buffer`，排完直接出结果集，无需回表。
   - **双路排序（Two-Pass Sort / row_id 排序）**：select 列过长（超过 `max_length_for_sort_data`）时，为省空间只把 row_id（有主键即主键值）+ 排序字段放进 `sort_buffer` 排序，排完再**逐行按 id 回表**取其余列，相当于多一轮查询。
   - 单路排序是后续优化版本，减少了回表动作，因此通常更快；但列越长占用 `sort_buffer` 越多，容易退化为磁盘排序。
2. **磁盘临时文件排序（数据量 > `sort_buffer_size`）**
   - 内存放不下时走外部排序，一般是**归并排序**：把数据切成多份临时文件各自排序，再合并成一个有序大文件。
   - 性能明显下降，可通过调大 `sort_buffer_size` 规避（注意是每连接独占内存，不能盲目调大）。

优化要点：让 ORDER BY 走索引（where 与 order by 使用同一索引列、保持索引列顺序、避免在排序列上做函数/表达式运算）；无法避免 filesort 时再考虑增大 `sort_buffer_size` 或减少 select 列宽以启用单路排序。