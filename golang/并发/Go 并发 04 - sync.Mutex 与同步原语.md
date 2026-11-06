---
title: "Go 并发 04 - sync.Mutex 与同步原语"
date: 2026-06-13
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 04"
---

# Go 并发 04 — sync.Mutex 与同步原语

## 数据竞争与互斥锁

多个 goroutine 同时读写同一变量会导致数据竞争（data race）：

```go
var counter int

for i := 0; i < 1000; i++ {
    go func() {
        counter++  // ⚠️ 数据竞争！
    }()
}
// counter 结果不确定，可能远小于 1000
```

### Mutex 基本用法

```go
var (
    counter int
    mu      sync.Mutex
)

for i := 0; i < 1000; i++ {
    go func() {
        mu.Lock()
        counter++
        mu.Unlock()
    }()
}
```

## sync.Mutex

| 方法 | 说明 |
|------|------|
| `Lock()` | 获取锁（阻塞） |
| `Unlock()` | 释放锁 |
| `TryLock()` | 尝试获取锁（不阻塞，返回 bool） |

### 使用模式

```go
type SafeCounter struct {
    mu sync.Mutex
    v  map[string]int
}

func (c *SafeCounter) Inc(key string) {
    c.mu.Lock()
    defer c.mu.Unlock()   // 确保解锁
    c.v[key]++
}

func (c *SafeCounter) Value(key string) int {
    c.mu.Lock()
    defer c.mu.Unlock()
    return c.v[key]
}
```

### defer 解锁

```go
mu.Lock()
defer mu.Unlock()
// ... 复杂逻辑 ...
// 无论中间发生什么，函数退出时自动解锁
```

### TryLock（Go 1.18+）

```go
if mu.TryLock() {
    defer mu.Unlock()
    // 成功获取锁
} else {
    // 锁已被占用，执行其他逻辑
}
```

## sync.RWMutex

读写锁：**多个读可以同时进行，写会独占**。

| 方法 | 说明 |
|------|------|
| `RLock()` | 读锁 |
| `RUnlock()` | 释放读锁 |
| `Lock()` | 写锁（排他） |
| `Unlock()` | 释放写锁 |

```go
type Cache struct {
    mu   sync.RWMutex
    data map[string]string
}

func (c *Cache) Get(key string) string {
    c.mu.RLock()
    defer c.mu.RUnlock()
    return c.data[key]
}

func (c *Cache) Set(key, val string) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.data[key] = val
}
```

> **适用场景**：读多写少。读锁不互斥，多个 goroutine 可以同时读。

## sync.Once

确保函数只执行一次（线程安全）：

```go
var (
    once   sync.Once
    config *Config
)

func GetConfig() *Config {
    once.Do(func() {
        config = loadConfig()  // 只执行一次
    })
    return config
}
```

> 常用于：单例模式、懒加载、初始化一次的资源。

## sync.Cond

条件变量：让 goroutine 等待某个条件成立再继续：

```go
var (
    mu     sync.Mutex
    cond   = sync.NewCond(&mu)
    ready  bool
)

func waitForReady() {
    mu.Lock()
    for !ready {
        cond.Wait()    // 释放锁并等待
    }
    mu.Unlock()
}

func setReady() {
    mu.Lock()
    ready = true
    cond.Broadcast()   // 通知所有等待的 goroutine
    mu.Unlock()
}
```

| 方法 | 说明 |
|------|------|
| `Wait()` | 自动解锁并等待，被唤醒后重新加锁 |
| `Signal()` | 唤醒一个等待的 goroutine |
| `Broadcast()` | 唤醒所有等待的 goroutine |

> **推荐**：大多数场景用 channel 替代 Cond，Cond 容易出错。

## 锁的性能

```go
// 基准测试对比
// Mutex > RWMutex（写多） / RWMutex > Mutex（读多）

// 锁粒度越细，并发度越高
type FineGrained struct {
    muA sync.Mutex
    muB sync.Mutex
}
```

### 锁竞争检测

```bash
# 检测死锁
GODEBUG=invalidsync=1 go run main.go

# pprof 查看锁竞争
import "net/http/pprof"
go tool pprof http://localhost:6060/debug/pprof/mutex
```

## 参考资料

- [Go sync 包文档](https://pkg.go.dev/sync)
- [Go Blog: The Go Memory Model](https://go.dev/ref/mem)
- [Go 锁竞争分析](https://go.dev/blog/race-detector)
