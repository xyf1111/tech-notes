---
title: "Redis 09 - 文章点赞功能设计"
date: 2026-07-23
tags: [Redis, Set, Hash, MySQL, 缓存同步]
source: "鱼皮·编程导航 / codefather"
---

# Redis 09 - 文章点赞功能设计

> 使用 Redis 存储高频点赞操作，通过定时任务同步到 MySQL，兼顾高性能与数据持久化。

## 设计要点

### 关键特性

1. **唯一性** — 每个用户对同一条内容只能点赞一次
2. **即时性** — 点赞反馈即时响应，无明显延迟
3. **可见性** — 点赞状态及时反映在用户界面上
4. **可撤销性** — 用户可以取消点赞
5. **计数与排名** — 点赞数量用于衡量内容受欢迎程度

### 数据存储方案

```
Redis:
  article:{id}:likes  →  Set<userId>        ← 存储"谁点赞了"
  article:likes       →  Hash<articleId, likesNum>  ← 存储"点赞数"

MySQL:
  article (id, solutionLikes, ...)
  article_likes (id, articleId, userId, createTime, ...)
```

| 组件 | 数据结构 | 用途 |
|------|---------|------|
| Redis Set | `article:{id}:likes` | 记录点赞用户集合，O(1) 判重 |
| Redis Hash | `article:likes` | 缓存文章点赞数，快速读取 |
| MySQL article | `solutionLikes` 字段 | 持久化点赞总数 |
| MySQL article_likes | 行记录 | 持久化点赞明细 |

### 后端核心逻辑

```java
@Service
public class ArticleLikesServiceImpl {
    private final SetOperations<String, Object> setOperations;
    private final HashOperations<String, Object, Object> hashOperations;

    // 点赞
    public void like(Long articleId, Long userId) {
        setOperations.add("article:" + articleId + ":likes", userId);
        hashOperations.increment("article:likes", articleId, 1);
    }

    // 取消点赞
    public void cancelLike(Long articleId, Long userId) {
        setOperations.remove("article:" + articleId + ":likes", userId);
        Long likes = (Long) hashOperations.get("article:likes", articleId);
        if (likes != null && likes > 0) {
            hashOperations.increment("article:likes", articleId, -1);
        }
    }

    // 查询是否点过赞
    public boolean isUserLiked(Long articleId, Long userId) {
        return Boolean.TRUE.equals(
            setOperations.isMember("article:" + articleId + ":likes", userId));
    }
}
```

### Redis ↔ MySQL 定时同步

```java
@Component
@Slf4j
public class ArticleLikesSynTask {

    @Scheduled(cron = "0 0 12 */1 * *") // 每天中午12点同步
    public void synArticleLikes() {
        // 1. 遍历所有文章
        // 2. 从 Redis 读取 set 和 hash
        // 3. 对比 MySQL 数据，计算差异
        // 4. 更新 MySQL：删除已取消的记录，新增点赞记录，更新点赞数
    }
}
```

**核心同步逻辑：**
- 如果 Redis 中的 `set` 为空 → 认为 Redis 刚重启，从 MySQL 恢复到 Redis
- 如果 Redis 中 `set` 非空 → 以 Redis 为准，同步到 MySQL
- 以集合 size 为准更新文章点赞数字段

### 前端要点

1. 进入文章页面时调用两个接口：文章信息 + 用户是否点赞
2. 点赞/取消成功后手动更新前端显示的点赞数（因 Redis 与 MySQL 有延迟）
3. 变更当前页点赞状态，无需再次调用查询接口

### 表结构参考

```sql
-- 文章表
CREATE TABLE `question_solution` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `solutionLikes` bigint DEFAULT 0 COMMENT '题解点赞数',
  `createTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isDelete` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

-- 文章点赞表
CREATE TABLE `article_likes` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `articleId` bigint DEFAULT NULL COMMENT '文章id',
  `userId` bigint DEFAULT NULL COMMENT '点赞人id',
  `createTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updateTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isDelete` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
```

### Redis 宕机处理

- 定时同步时检查 Redis 中点赞用户 Set 是否为空
- 为空 → 认为 Redis 宕机后重启，从 MySQL 向 Redis 恢复数据
- 非空 → 以 Redis 为准向 MySQL 同步

![](../image/img_redis_likes_flow.png)

*↑ 点赞功能整体方案架构图*

> 来源：鱼皮·编程导航 / codefather
