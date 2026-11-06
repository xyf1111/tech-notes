---
title: "Java 50 - 四种锁实战（加入队伍功能）"
date: 2026-08-18
tags: [java, 多线程, 锁]
source: "鱼皮·编程导航 / codefather"
---

> 本文以"加入队伍"功能为例，实战讲解四种锁方案：单机锁 / 分布式锁 × 所有用户共享 / 同一用户独享，解决并发场景下的线程安全问题。

## 核心要点

### 为什么需要上锁

SpringBoot 中 Controller 默认是单例对象，多个 HTTP 请求会同时访问同一个 Controller 实例，方法内的代码默认线程不安全。同一个用户多次点击、或不同用户同时点击"加入队伍"，都会触发多线程并发访问。

加入队伍的伪代码：
1. 从 MySQL 读取队伍人数
2. 判断队伍是否满员
3. 不满员则插入数据，满员则返回失败

竞态场景：队伍人数 4/5 时，两个用户同时点击加入，两个请求同时通过第 2 步的满员检查，再同时执行第 3 步插入，导致队伍变成 6/5。因此必须上锁，让"检查 + 插入"成为原子操作。

### 四种锁策略对比

| 锁粒度 \ 部署方式 | 单机部署 | 多机分布式部署 |
| --- | --- | --- |
| 所有用户共享一把锁 | synchronized(this) | Redisson RLock（固定 key） |
| 同一用户独享一把锁 | synchronized(userId.toString().intern()) | Redisson RLock（key 拼接 userId） |

选择依据：
- 功能只涉及队伍维度（如判断队伍是否满员）→ 所有用户共享一把锁；
- 功能只涉及用户自身维度（如判断用户加入队伍数量、是否重复入队）→ 按用户粒度加锁，并发度更高。

### 方式一：单机锁 —— 所有用户共享一把锁

**实现方式**：使用 `synchronized(this)`，this 是 @Service 创建的 TeamServiceImpl 单例对象，保证所有用户的请求竞争同一把锁。

**应用场景**：判断队伍是否满员、满员不允许加入等"队伍维度"的功能。

**关键代码**：

```java
synchronized (this) {
    // 从 MySQL 读取队伍人数
    long teamUserNums = this.countTeamUserByTeamId(teamId);
    // 判断是否满员
    if (teamUserNums >= team.getMaxNum()) {
        throw new BusinessException(ErrorCode.PARAMS_ERROR, "队伍已满");
    }
    UserTeam userTeam = new UserTeam();
    userTeam.setTeamId(teamId);
    userTeam.setUserId(userId);
    userTeam.setJoinTime(new Date());
    return userTeamService.save(userTeam);
}
```

### 方式二：单机锁 —— 同一用户独享一把锁

**实现方式**：用每个用户独有的信息作为锁对象：`synchronized (userId.toString().intern())`。intern() 取出字符串常量池中的字符串对象，常量池中相同字符串唯一，保证同一 userId 每次请求拿到的锁对象相同。

**常见疑问**：
- 为什么不用 `synchronized(userId)`？每次请求的 userId 都是 new 出来的新 Long 对象，地址不同，锁不住。
- 为什么不用 `synchronized(userId.toString())`？toString() 会 new 一个新 String 对象而非从常量池取引用，每次引用都不同。

**替代实现**：也可用 `ConcurrentHashMap<String, Object>` 按 userId 缓存锁对象（如 `map.computeIfAbsent(userId, k -> new Object())`），效果等价，不依赖 intern() 的常量池语义。

**应用场景**：判断一个用户最多加入几个队伍、是否重复加入某队伍等"用户维度"功能——用户之间互不影响，一个用户一把锁即可，并发度更高。

**关键代码**：

```java
Long userId = loginUser.getId();
synchronized (userId.toString().intern()) {
    // 判断加入队伍数量是否已超出 5 个
    LambdaQueryWrapper<UserTeam> wrapper = new LambdaQueryWrapper<>();
    wrapper.eq(UserTeam::getUserId, userId);
    long hasJoinNum = userTeamService.count(wrapper);
    if (hasJoinNum > 5) {
        throw new BusinessException(ErrorCode.PARAMS_ERROR, "最多创建和加入5个队伍");
    }
    return userTeamService.save(userTeam);
}
```

### 方式三：分布式锁 —— 所有用户共享一把锁（多机部署）

**实现方式**：使用 Redis + Redisson 组件实现分布式锁，锁 key 固定，多机环境下所有用户的请求竞争同一把锁。

**应用场景**：与方式一相同（队伍维度），但用于多机部署的分布式场景。

**关键代码**：

```java
RLock lock = redissonClient.getLock("yupao:team:joinTeam");
try {
    while (true) {
        if (lock.tryLock(0, -1, TimeUnit.MILLISECONDS)) {
            // 判断队伍是否已满
            long teamUserNums = this.countTeamUserByTeamId(teamId);
            if (teamUserNums >= team.getMaxNum()) {
                throw new BusinessException(ErrorCode.PARAMS_ERROR, "队伍已满");
            }
            UserTeam userTeam = new UserTeam();
            userTeam.setTeamId(teamId);
            userTeam.setUserId(userId);
            userTeam.setJoinTime(new Date());
            return userTeamService.save(userTeam);
        }
    }
} catch (InterruptedException e) {
    log.error("The lock 'yupao:team:joinTeam' had a error ", e);
    return false;
} finally {
    // 释放锁，只能释放自己的锁
    if (lock.isHeldByCurrentThread()) {
        lock.unlock();
    }
}
```

### 方式四：分布式锁 —— 同一用户独享一把锁（多机部署）

**实现方式**：同样是 Redisson 分布式锁，在锁的 key 上拼接 userId，实现"一个用户一把锁"。

**应用场景**：与方式二相同（用户维度），但用于多机部署的分布式场景。

**关键代码**：

```java
Long userId = loginUser.getId();
RLock lock = redissonClient.getLock("yupao:team:joinTeam:userId");
try {
    while (true) {
        if (lock.tryLock(0, -1, TimeUnit.MILLISECONDS)) {
            // 判断加入队伍数量是否已超出 5 个
            LambdaQueryWrapper<UserTeam> wrapper = new LambdaQueryWrapper<>();
            wrapper.eq(UserTeam::getUserId, userId);
            long hasJoinNum = userTeamService.count(wrapper);
            if (hasJoinNum > 5) {
                throw new BusinessException(ErrorCode.PARAMS_ERROR, "最多创建和加入5个队伍");
            }
            return userTeamService.save(userTeam);
        }
    }
} catch (InterruptedException e) {
    log.error("The lock 'yupao:team:joinTeam' had a error ", e);
    return false;
} finally {
    if (lock.isHeldByCurrentThread()) {
        lock.unlock();
    }
}
```

### 测试方式要点

- 在插入数据之前加 `Thread.sleep(5000)`，保证两次请求能同时执行到插入代码，从而复现竞态。
- 用两个浏览器分别模拟两个用户同时点击"加入队伍"。伙伴匹配系统基于 session 保存用户信息，一个浏览器对应一个 sessionId（即一个用户）；同一浏览器的多个窗口共享 sessionId，模拟不了两个用户。
- 与原始代码对比验证：原始代码会出现超员，加锁后不会。

### 待完善

- 单机锁（方式一、方式二）的问题：若拿到锁的线程出现阻塞，整个功能会卡住，后续请求全部得不到响应。可给锁添加"使用时间"，超时后自动释放，防止持锁线程阻塞导致功能不可用。
