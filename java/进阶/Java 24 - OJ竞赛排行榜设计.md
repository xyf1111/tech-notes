---
title: Java 进阶 - OJ 竞赛排行榜设计
date: 2026-07-23
tags:
  - java
  - 在线判题
  - 排行榜
  - 系统设计
  - 进阶
source: "鱼皮·编程导航 / codefather"
---

# OJ 竞赛排行榜设计

> OJ（Online Judge）竞赛排行榜的设计思路与 Java 代码实现，包括数据库表设计和统计逻辑。

## 设计要点

1. **尽可能实时**：异步处理提交，保证用户体验
2. **保留最优成绩**：维护每个用户对每道题的最优答题情况
3. **排名规则**：总分 → 总耗时 → 总空间（按优先级降序/升序）
4. **可见性控制**：竞赛前不可见；竞赛中动态变化；竞赛后冻结

## 数据库设计

### 表结构概览

| 表名 | 说明 |
|------|------|
| `game` | 竞赛基本信息 |
| `user_game` | 用户-竞赛关联 |
| `game_question` | 竞赛-题目关联（含满分） |
| `game_rank` | 竞赛排名（总分、总耗时、总空间、每题详情 JSON） |

### game_rank 表

```sql
CREATE TABLE `game_rank` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `gameId` bigint DEFAULT NULL COMMENT '竞赛id',
  `userId` bigint DEFAULT NULL COMMENT '用户id',
  `userName` varchar(255) DEFAULT NULL COMMENT '用户昵称',
  `totalMemory` int DEFAULT NULL COMMENT '总空间(kb)',
  `totalTime` int DEFAULT NULL COMMENT '总用时(ms)',
  `totalScore` int DEFAULT NULL COMMENT '总得分',
  `gameDetail` text COMMENT '竞赛详情(JSON)',
  `createTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isDelete` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `idx_gameId`(`gameId`),
  INDEX `idx_userId`(`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

`gameDetail` 字段以 JSON 存储每题最优成绩，结构：
```json
{
  "gameId": 1,
  "userId": 42,
  "submitDetail": {
    "10001": { "id": 10001, "name": "两数之和", "score": 100, "timeCost": 50, "memoryCost": 1024 },
    "10002": { "id": 10002, "name": "反转链表", "score": 80, "timeCost": 120, "memoryCost": 2048 }
  }
}
```

## 核心实体类

**GameRank** — 数据库映射实体，包含总分/总耗时/总空间和 gameDetail 详情。

**GameDetail** — 竞赛详情对象，包含 gameId、userId 和 submitDetail（Map<题目ID, GameDetailUnit>）。

**GameDetailUnit** — 每题最优成绩。提供 `isBetter()` 方法按「分数高→用时少→空间少」比较优劣。

**GameRankDetail** — 排行榜展示 VO，包含排名、用户信息和每题详情列表。

## 核心流程

### 1. 答题提交流程

用户提交题目后：
1. 校验竞赛是否在有效时间内
2. 调用判题服务（异步）
3. 异步更新排行榜信息：
   - 用户无排名记录 → 新建 GameRank，插入当前成绩
   - 已有记录但 gameDetail 为空 → 直接填入
   - 已有记录且该题已存在 → 若新成绩优于旧成绩则替换（增量更新总分/耗时/空间）

### 2. 排行榜统计流程

1. 获取指定竞赛的全部题目 ID
2. 获取参赛的全部用户 ID
3. 遍历每个用户，查询其 GameRank 记录
4. 无记录 → 创建空记录并初始化各题为 0 分
5. 有记录 → 解析 gameDetail JSON，统计总分/总耗时/总空间
6. 排序：`总分降序 → 总耗时升序 → 总空间升序`
7. 分配名次

```java
// 排序逻辑
List<GameRankDetail> sorted = rankDetails.stream()
    .sorted(Comparator.comparing(GameRankDetail::getTotalScore).reversed()
        .thenComparing(GameRankDetail::getTotalTime)
        .thenComparing(GameRankDetail::getTotalMemory))
    .collect(Collectors.toList());
```

## 关键设计决策

- **空间换时间**：在 game_rank 表中冗余存储总分/总耗时/总空间，避免每次查询时动态计算
- **异步更新**：使用 `CompletableFuture.runAsync()` 异步更新排行榜，不阻塞答题主流程
- **JSON 存储**：每题详情存为 JSON，灵活支持不同题型的附加字段，避免宽表设计

## 通用排行榜查询优化与 Top N 算法

> 融合自「带老弟做个实时排行榜」：通用排行榜的查询优化思路，以及海量数据下的 Top N 算法。

### 小数据量排行榜：直接排序即可

用户量不大时，取前 10 名只需要取出全部用户数据并排序即可（全排序）：

```sql
-- 按积分降序取前 10 名
SELECT * FROM `user` ORDER BY score DESC LIMIT 10;
```

查询自己的总排名时，其实不需要对全部数据排序。换个思路：只需要知道有多少人的分数比自己高。先用 SQL 查出自己的分数：

```sql
/* 只取需要的列 */
SELECT score AS myScore
FROM `user`
WHERE id = '用户id';
```

再统计分数高于自己的用户数量：

```sql
/* 统计分数大于自己的用户数量 */
SELECT COUNT(*) FROM `user`
WHERE score > myScore;
```

将查询结果 + 1 就是自己的排名。仅转换一点思路，就能省去多余排序带来的性能开销。

### Top N 问题：海量数据找前 N

用户量达到亿级时，如何从海量数据中找出前 N 个数，就是面试常见的 Top N 问题。其核心在于保证空间和时间复杂度：先考虑数据能否存入内存运算，再考虑怎样算得更快。常见方案对比：

| 方案 | 思路 | 优缺点 |
|------|------|--------|
| 全部排序 | 对所有数据直接排序（如快排）后取前 N | 需要将数据一次性全部加载进内存，慢 |
| 局部淘汰 | 内存维护一个大小为 N 的容器，剩余数据逐个进入并淘汰容器内最小值 | 省内存，但太慢 |
| 分治 | 数据分为多个小组，每组先选出前 N 名"小组长"，再让小组长同台竞技选出最终前 N | Map/Reduce 思想，可并行计算 |
| 哈希预处理 | 数据重复度高时用 hash 去重后再处理 | 如 1 亿数据一半是 0 一半是 1，取前 10 可直接淘汰 0；但预处理本身也耗时空，需先判断数据重复度 |
| 小根堆 | 取前 N 个数建小根堆，堆顶始终是最小值；遍历后续数字，大于堆顶就替换并调整堆结构 | 时间、空间（O(N)）复杂度都不错，面试高频考点 |

其中 **分治** 和 **小根堆** 是相对核心的方案。面试遇到 Top N 问题，可先答出以上几种方案，再结合具体场景分析选型。

### 海量用户场景：分库分表 + 分治并行

用户量级很大时，首先要 **分库分表**（通常是水平分表），按一定规则（比如用户 id）把用户数据行分批存储在多个数据表中。之后就可以像大数据 Map / Reduce 处理机制一样 **分治**：

1. **map**：并行计算每张表的前 10 名
2. **reduce**：把各表结果汇总到一起，再计算最终的前 10 名

用这种方式，数据量从 1 亿到 2 亿、3 亿，计算模式完全一样，加机器做水平扩容即可。

### Redis zset 方案权衡

提到"实时排行榜"，很多背过八股文的同学第一时间会想到 Redis 的有序集合 zset，这确实是一种方案，但也要结合场景分析利弊，不要秒答：

- **优点**：基于内存、运算更快；天然支持排序；使用方便
- **缺点**：数据量大时同样面临数据更新、维护、同步、持久化存储等问题
- **适用性**：对于实时性要求不高的需求属于"杀鸡用牛刀"，应结合实际业务场景选型

> 来源：鱼皮·编程导航 / codefather
