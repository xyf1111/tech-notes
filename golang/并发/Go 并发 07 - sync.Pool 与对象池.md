---
title: "Go 并发 07 - sync.Pool 与对象池"
date: 2026-06-13
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 07"
---

# Go 并发 07 — sync.Pool 与对象池

## sync.Pool 是什么

`sync.Pool` 是一个**临时对象池**，用于缓存可复用的对象，减少内存分配和 GC 压力。

```go
var pool = sync.Pool{
    New: func() interface{} {
        return &bytes.Buffer{}
    },
}

// 获取对象
buf := pool.Get().(*bytes.Buffer)
buf.Reset()             // 重置状态
// ... 使用 buf ...

// 放回池中
pool.Put(buf)
```

| 方法 | 说明 |
|------|------|
| `Get()` | 从池中获取对象（有则取，无则调用 New 创建） |
| `Put(x)` | 将对象放回池中 |
| `New` | 当池为空时创建新对象的函数 |

## 典型应用

### 1. bytes.Buffer 复用

```go
var bufferPool = sync.Pool{
    New: func() interface{} {
        return new(bytes.Buffer)
    },
}

func writeJSON(w io.Writer, v interface{}) error {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer bufferPool.Put(buf)
    buf.Reset()

    if err := json.NewEncoder(buf).Encode(v); err != nil {
        return err
    }
    _, err := io.Copy(w, buf)
    return err
}
```

### 2. 结构体复用（高频创建的场景）

```go
type Request struct {
    Method string
    Path   string
    Body   []byte
    // ... 其他字段
}

var reqPool = sync.Pool{
    New: func() interface{} {
        return &Request{
            Body: make([]byte, 0, 4096), // 预分配
        }
    },
}

func handle(w http.ResponseWriter, r *http.Request) {
    req := reqPool.Get().(*Request)
    defer reqPool.Put(req)

    req.Method = r.Method
    req.Path = r.URL.Path
    // ... 处理
}
```

### 3. fmt 包中的实际应用

```go
// Go 标准库 fmt 包内部就使用了 sync.Pool
// 用于复用打印缓冲区
var ppFree = sync.Pool{
    New: func() interface{} { return new(pp) },
}
```

## Pool 的工作原理

```
P 1        P 2        P N
┌────┐    ┌────┐    ┌────┐
│private│  │private│  │private│  ← 每个 P 私有（无锁）
├────┤    ├────┤    ├────┤
│shared│  │shared│  │shared│  ← 共享列表（有锁）
└────┘    └────┘    └────┘
```

- **Get()** 优先从当前 P 的私有池取，再取共享池，最后从其他 P 偷
- **Put()** 放回当前 P 的私有池或共享池
- **GC**：每次 GC 时 Pool 中的对象会被清空

## 注意事项

⚠️ **Pool 不适合做持久连接池**（如数据库连接池），因为 GC 会回收对象！

```go
// ✅ 适合：可丢弃的临时对象
var bufPool sync.Pool // bytes.Buffer、结构体

// ❌ 不适合：有状态、需要持久连接
// 数据库连接、TCP 连接 → 用 channel 实现连接池
```

### 误区示例

```go
// ❌ 错误：假设 Get 一定返回之前 Put 的对象
obj := pool.Get()
// GC 后 Get 返回的是 nil（然后触发 New 创建新对象）
```

## 性能对比

```go
func BenchmarkWithoutPool(b *testing.B) {
    for i := 0; i < b.N; i++ {
        buf := new(bytes.Buffer)
        buf.WriteString("hello")
        // ... 使用后丢弃
    }
}

func BenchmarkWithPool(b *testing.B) {
    pool := sync.Pool{New: func() interface{} { return new(bytes.Buffer) }}
    for i := 0; i < b.N; i++ {
        buf := pool.Get().(*bytes.Buffer)
        buf.Reset()
        buf.WriteString("hello")
        pool.Put(buf)
    }
}
```

> 在高并发场景下，Pool 能显著减少内存分配次数（减少 50%-90% allocs/op）。

## 参考资料

- [Go sync 包文档](https://pkg.go.dev/sync)
- [Go Blog: sync.Pool](https://go.dev/src/sync/pool.go)
- [sync.Pool 设计原理](https://go.dev/src/sync/pool.go)
