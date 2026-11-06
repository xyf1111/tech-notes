---
title: "Redis 07 - 分布式锁"
date: 2026-06-13
tags:
  - redis
  - 缓存
  - 分布式
aliases:
  - "Redis 07"
---

# Redis 07 — 分布式锁

## 分布式锁的要求

| 要求 | 说明 |
|------|------|
| **互斥性** | 同一时刻只有一个客户端持有锁 |
| **安全性** | 不会产生死锁（有超时机制） |
| **可重入** | 同一客户端可以重复加锁 |
| **容错** | 部分 Redis 节点宕机不影响锁服务 |

## RedLock 与 SETNX

### 简单实现（单节点）

```bash
# Redis 命令
SET lock_key uuid NX PX 30000
# NX: 不存在时才设置（互斥）
# PX: 过期时间 30000ms（避免死锁）
# value: uuid（用于安全释放，防止误删其他人的锁）
```

### Go 实现

```go
import "github.com/go-redis/redis/v8"

type RedisLock struct {
    client *redis.Client
    key    string
    value  string   // UUID
    ttl    time.Duration
}

func NewLock(client *redis.Client, key string) *RedisLock {
    return &RedisLock{
        client: client,
        key:    "lock:" + key,
        value:  uuid.New().String(),
        ttl:    30 * time.Second,
    }
}

// TryLock 尝试加锁
func (l *RedisLock) TryLock(ctx context.Context) (bool, error) {
    ok, err := l.client.SetNX(ctx, l.key, l.value, l.ttl).Result()
    if err != nil {
        return false, err
    }
    return ok, nil
}

// Unlock 安全释放锁（使用 Lua 脚本保证原子性）
const unlockScript = `
if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
else
    return 0
end
`

func (l *RedisLock) Unlock(ctx context.Context) error {
    return l.client.Eval(ctx, unlockScript, []string{l.key}, l.value).Err()
}
```

### 使用

```go
lock := NewLock(rdb, "order:123")

if ok, err := lock.TryLock(ctx); err != nil {
    // 处理错误
} else if !ok {
    return errors.New("lock failed: resource busy")
}
defer lock.Unlock(ctx)

// 执行临界区代码
processOrder(ctx, 123)
```

## 看门狗（Watchdog）

防止业务时间超过锁的 TTL 导致锁提前释放：

```go
type RedisLock struct {
    // ... 基础字段
    stopCh chan struct{}
}

func (l *RedisLock) startWatchdog(ctx context.Context) {
    ticker := time.NewTicker(l.ttl / 3) // 每 10s 续约一次
    go func() {
        for {
            select {
            case <-ticker.C:
                // 续约：重置 TTL
                l.client.Expire(ctx, l.key, l.ttl)
            case <-l.stopCh:
                ticker.Stop()
                return
            }
        }
    }()
}

// 加锁时启动看门狗
func (l *RedisLock) Lock(ctx context.Context) error {
    for {
        ok, err := l.client.SetNX(ctx, l.key, l.value, l.ttl).Result()
        if err != nil {
            return err
        }
        if ok {
            l.startWatchdog(ctx)
            return nil
        }
        // 重试（退避）
        time.Sleep(50 * time.Millisecond)
    }
}

func (l *RedisLock) Unlock(ctx context.Context) error {
    close(l.stopCh)  // 停止看门狗
    return l.client.Eval(ctx, unlockScript, []string{l.key}, l.value).Err()
}
```

## 可重入锁

```go
type ReentrantLock struct {
    *RedisLock
    holder     string
    reentrant  int
    localLock  sync.Mutex
}

func (l *ReentrantLock) Lock(ctx context.Context) error {
    l.localLock.Lock()
    defer l.localLock.Unlock()

    // 检查是否当前线程已持有锁
    if l.holder == getGoroutineID() {
        l.reentrant++
        return nil
    }

    if err := l.RedisLock.Lock(ctx); err != nil {
        return err
    }
    l.holder = getGoroutineID()
    l.reentrant = 1
    return nil
}

func (l *ReentrantLock) Unlock(ctx context.Context) error {
    l.localLock.Lock()
    defer l.localLock.Unlock()

    if l.reentrant > 1 {
        l.reentrant--
        return nil
    }

    l.holder = ""
    l.reentrant = 0
    return l.RedisLock.Unlock(ctx)
}
```

## RedLock 算法（多节点）

用于多 Redis 节点时的容错：

```go
type RedLock struct {
    clients []*redis.Client
    quorum  int      // 多数派 = N/2 + 1
}

func (r *RedLock) Lock(ctx context.Context, key, value string, ttl time.Duration) (bool, error) {
    success := 0
    start := time.Now()

    for _, client := range r.clients {
        ok, err := client.SetNX(ctx, key, value, ttl).Result()
        if err == nil && ok {
            success++
        }
    }

    // 检查是否获取到多数派锁
    // 且总耗时小于 TTL（防止慢节点导致锁失效）
    elapsed := time.Since(start)
    if success >= r.quorum && elapsed < ttl {
        return true, nil
    }

    // 加锁失败，释放所有已获取的锁
    for _, client := range r.clients {
        client.Del(ctx, key)
    }
    return false, nil
}
```

## Redisson（Java 客户端）异常处理

Redisson 是 Java 生态中最常用的 Redis 分布式锁客户端。以下为两个常见问题和解决方案。

### 解锁异常："attempt to unlock lock, not locked by current thread"

**异常原因：**

1. **锁被其他线程或节点持有**：一个线程/节点获得锁后，另一个线程尝试解锁
2. **锁超时自动释放**：业务处理时间超过锁的 TTL，锁已自动释放，这时不应再手动解锁

**解决方案：**

在解锁前使用 `isHeldByCurrentThread()` 检查当前线程是否仍持有锁：

```java
RLock lock = redissonClient.getLock("myLock");
try {
    // 尝试获取锁，等待10秒，锁30秒自动释放
    boolean isLocked = lock.tryLock(10, 30, TimeUnit.SECONDS);
    if (isLocked) {
        // 执行业务代码
    } else {
        log.info("获取Redisson锁失败");
    }
} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
} finally {
    // 解锁前检查当前线程是否持有该锁
    if (lock != null && lock.isHeldByCurrentThread()) {
        lock.unlock();
    }
}
```

## 参考资料

- [Redis SETNX 文档](https://redis.io/commands/setnx/)
- [RedLock 算法](https://redis.io/docs/reference/patterns/distributed-locks/)
- [go-redis 分布式锁](https://github.com/go-redsync/redsync)
- [Redisson 官方文档](https://github.com/redisson/redisson)
