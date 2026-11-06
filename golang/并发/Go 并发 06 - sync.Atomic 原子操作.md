---
title: "Go 并发 06 - sync.Atomic 原子操作"
date: 2026-06-13
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 06"
---

# Go 并发 06 — sync.Atomic 原子操作

## 原子操作 vs 互斥锁

| 对比 | atomic | sync.Mutex |
|------|--------|------------|
| 性能 | 极快（CPU 指令级） | 慢（操作系统级） |
| 适用场景 | 简单的计数、标记 | 复杂的临界区 |
| 粒度 | 变量级别 | 代码块级别 |
| CAS 支持 | ✅ | ❌ |

```go
var counter int64

// ❌ 慢：用 Mutex 保护简单的计数器
var mu sync.Mutex
mu.Lock()
counter++
mu.Unlock()

// ✅ 快：atomic 加一
atomic.AddInt64(&counter, 1)
```

## atomic 常用函数

### 增减

```go
var counter int64

atomic.AddInt64(&counter, 1)     // counter++
atomic.AddInt64(&counter, -1)    // counter--
newVal := atomic.AddInt64(&counter, 5) // counter += 5, 返回新值
```

### 存储与加载

```go
var config atomic.Value  // 存储任意类型
var flag int64

atomic.StoreInt64(&flag, 1)     // flag = 1（安全写入）
val := atomic.LoadInt64(&flag)  // val = 1（安全读取）

// atomic.Value 适合存储大型不可变配置
config.Store(&Config{Addr: ":8080"})
cfg := config.Load().(*Config)
```

### CAS（Compare And Swap）

```go
var val int64 = 0

// 如果 val == 0，则设为 1；否则不做任何事
swapped := atomic.CompareAndSwapInt64(&val, 0, 1)
fmt.Println(swapped) // true, val = 1

swapped = atomic.CompareAndSwapInt64(&val, 0, 2)
fmt.Println(swapped) // false, val 还是 1
```

### Swap

```go
var val int64 = 10
old := atomic.SwapInt64(&val, 20)
fmt.Println(old) // 10（旧值）
fmt.Println(val) // 20（新值）
```

## 常见应用

### 1. 计数器

```go
type Counter struct {
    count int64
}

func (c *Counter) Inc()  { atomic.AddInt64(&c.count, 1) }
func (c *Counter) Dec()  { atomic.AddInt64(&c.count, -1) }
func (c *Counter) Get() int64 { return atomic.LoadInt64(&c.count) }
```

### 2. 状态标志

```go
var (
    running int64  // 0 = false, 1 = true
)

func start() {
    if atomic.CompareAndSwapInt64(&running, 0, 1) {
        go runLoop()
    }
}

func stop() {
    atomic.StoreInt64(&running, 0)
}
```

### 3. 无锁栈（Treiber Stack）

```go
type node struct {
    value interface{}
    next  unsafe.Pointer
}

type Stack struct {
    top unsafe.Pointer
}

func (s *Stack) Push(val interface{}) {
    n := &node{value: val}
    for {
        n.next = atomic.LoadPointer(&s.top)
        if atomic.CompareAndSwapPointer(&s.top, n.next, unsafe.Pointer(n)) {
            break
        }
    }
}
```

### 4. 实时指标收集

```go
var (
    requests int64
    errors   int64
    latency  int64
)

func recordRequest(dur time.Duration) {
    atomic.AddInt64(&requests, 1)
    atomic.AddInt64(&latency, int64(dur))
}

func recordError() {
    atomic.AddInt64(&errors, 1)
}

// 定期采集指标
go func() {
    for range time.Tick(10 * time.Second) {
        reqs := atomic.SwapInt64(&requests, 0)
        errs := atomic.SwapInt64(&errors, 0)
        lat := atomic.SwapInt64(&latency, 0)
        fmt.Printf("reqs=%d, errors=%d, avgLat=%d", reqs, errs, lat/max(reqs,1))
    }
}()
```

## atomic 类型速查

| 函数 | 支持的类型 |
|------|-----------|
| `AddXxx` | `Int32`, `Int64`, `Uint32`, `Uint64`, `Uintptr` |
| `LoadXxx` | `Int32`, `Int64`, `Uint32`, `Uint64`, `Uintptr`, `Pointer` |
| `StoreXxx` | 同上 |
| `CompareAndSwapXxx` | 同上（不包含 Pointer？实际上 Pointer 也有 CAS） |
| `SwapXxx` | 同上 |
| `Value` | 任意类型（`interface{}`） |

## 参考资料

- [Go sync/atomic 包文档](https://pkg.go.dev/sync/atomic)
- [Go Blog: Atomic Swaps](https://go.dev/blog/atomic-swaps)
