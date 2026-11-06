---
title: "Redis 11 - 布隆过滤器"
date: 2026-08-18
tags: [redis, 布隆过滤器, java]
source: "鱼皮·编程导航 / codefather"
---

# Redis 11 — 布隆过滤器

> 用户注册时要校验用户名是否已存在，很多人只会直查数据库或加一层缓存。本文用布隆过滤器（Bloom Filter）解决海量用户场景下「用户名是否存在」的高效判断，重点在于：位数组 + 多次哈希，用极小内存挡住绝大多数「不存在」的查询，避免打爆数据库。

## 核心要点

### 场景：用户注册校验用户名，三种方案对比

场景：用户注册时查询用户名/账户是否已存在。核心痛点——**海量用户场景下，无论用户名存在与否，所有查询请求都打到数据库，会对数据库产生巨大压力**（尤其是不存在的数据，属于典型的缓存穿透问题）。

| 方案 | 做法 | 优点 | 缺点 | 适用场景 |
| --- | --- | --- | --- | --- |
| 直接查询数据库 | 每次注册请求都查 DB 判断用户名是否存在 | 实现最简单，结果绝对准确 | 用户量变大后所有请求（存在/不存在）都打到数据库，DB 压力巨大 | 数据量小的系统 |
| Redis 缓存 | DB 前加一层缓存，缓存命中直接返回，未命中再查 DB | 命中时响应快，能分担 DB 压力 | 有效期难权衡：不设有效期 → 大批量用户名常驻内存，浪费 Redis 内存；设有效期 → 过期后需回源 DB，且用户恶意发起不存在的用户名时会反复打 DB | 热点数据 |
| 布隆过滤器 | 位数组 + 多次哈希，先快速过滤「一定不存在」的请求 | 内存占用极小、判断极快，能拦截绝大多数不存在请求 | 存在误判率，元素不可删除 | 海量用户注册、防止不存在数据打爆 DB |

### 布隆过滤器原理

- **结构**：位数组（bitmap）+ 一组哈希函数，位数组初始全部置 0。为什么用位数组？因为位存储空间极小——1 字节（Byte）= 8 位（Bit）。
- **插入**：将元素（如用户名）经过多个哈希函数映射到位数组的多个位置，把这些位置的值置为 1。
- **查询**：将元素经同样多个哈希函数映射到多个位置——如果所有位置的值都为 1，则认为元素**可能存在**；只要任一位置的值为 0，则认为元素**一定不存在**。
- **优点**：
  - 哈希函数直接定位数组下标，可高效判断元素是否属于大规模集合；
  - 位数组存储极省内存，一亿元素约只需 500MB 内存即可支撑 40 亿数据的规模，内存消耗可接受。
- **缺点**：
  - **误判**：哈希冲突可能导致本不存在的元素被判定为存在（例如数字 1 被放到位置 6，访问 6 时可能命中）；
  - **不可删除**：位数组中的 1 无法单独清除，删除元素会影响其他元素的判断结果。
- **关键参数**：初始容量（容量设置越大，冲突几率越低）与预期误判率。

### 误判分析：用户名场景能否接受

- 误判方向：只会把「不存在」误判为「存在」，不会把「存在」误判为「不存在」。
- 误判后果：用户注册时用户名被误判为已存在 → 注册被拒 → 用户只需在原名基础上加字符（如 AAA → AAAA）重新注册即可，代价极小。
- 结论：用户名不是非常重要的数据，**该场景下的误判可以容忍**。

### 实战：Redisson 实现

> 注意：Redisson 的正确拼写是 **Redisson**（源资料中的 Redission 为笔误）。

**1. 引入依赖**

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson-spring-boot-starter</artifactId>
</dependency>
```

**2. 配置 Redis 参数**

```yml
spring:
  data:
    redis:
      host: 127.0.0.1
      port: 6379
      password: 123456
```

**3. 创建布隆过滤器实例（配置类）**

```java
import org.redisson.api.RBloomFilter;
import org.redisson.api.RedissonClient;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * 布隆过滤器配置
 */
@Configuration
public class RBloomFilterConfiguration {

    /**
     * 防止用户注册查询数据库的布隆过滤器
     */
    @Bean
    public RBloomFilter<String> userRegisterCachePenetrationBloomFilter(RedissonClient redissonClient) {
        RBloomFilter<String> cachePenetrationBloomFilter = redissonClient.getBloomFilter("用户注册布隆过滤器");
        // expectedInsertions / falseProbability 按业务实际估算，不可写死为 0
        cachePenetrationBloomFilter.tryInit(1000000L, 0.01);
        return cachePenetrationBloomFilter;
    }
}
```

`tryInit` 的两个核心参数：

- `expectedInsertions`：预估布隆过滤器存储的元素数量（即用户量级）；
- `falseProbability`：允许的误判率。

**容量与误判率的权衡**：

- 错误率越低 → 位数组越长 → 内存占用越大；
- 错误率越低 → 哈希函数越多 → 计算耗时越长。

可用在线工具估算占用：[Bloom Filter Calculator](https://krisives.github.io/bloom-calculator/)

**两种使用场景**：

1. **初始使用**：注册新用户时同步向布隆过滤器中新增数据，无需额外批量初始化；
2. **使用过程中引入**：从数据源（DB）读取存量目标数据，批量刷入布隆过滤器后再上线使用。

**4. 代码中的使用（注入使用）**

```java
private final RBloomFilter<String> userRegisterCachePenetrationBloomFilter;
```

注册流程中先 `userRegisterCachePenetrationBloomFilter.contains(username)` 判断：返回 false 则用户名一定不存在、直接放行注册；返回 true 则可能存在，再回源 DB 精确校验。

### 流程图信息（文字版）

源文档中的流程图均为外部图片链接，此处以文字还原其流程：

**方案一（直查数据库）**：用户发起注册请求 → 直接查询数据库判断用户名是否存在 → 存在则拒绝注册，不存在则允许注册。所有请求无一例外都打到数据库。

**方案二（缓存 + DB）**：用户发起注册请求 → 先查 Redis 缓存 → 缓存命中直接返回判断结果 → 缓存未命中则回源查询数据库 → 将结果写回缓存。缓存过期或不存在数据会反复穿透到 DB。

**布隆过滤器初始化流程**：创建位数组并全部置 0 → 设定初始容量与预期误判率 → 将已有用户名逐个经多个哈希函数映射，把对应位数组位置置为 1。

**布隆过滤器执行（判断）流程**：用户发起注册请求 → 用户名经多个哈希函数映射到位数组 → 检查所有映射位置：任一位置为 0 → 一定不存在，放行注册；所有位置均为 1 → 可能存在，需回源 DB 精确确认。
