---
title: "Go 并发 09 - Goroutine 泄漏与调试"
date: 2026-06-13
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 09"
---

# Go 并发 09 — Goroutine 泄漏与调试

## 什么是 Goroutine 泄漏

goroutine 泄漏是指 goroutine **一直阻塞无法退出**，导致其占用的栈内存和引用的堆内存永远无法释放。

```go
// 泄漏示例：goroutine 永远阻塞
func leak() {
    ch := make(chan int)
    go func() {
        val := <-ch  // ❌ 永远等待，没人发送
        fmt.Println(val)
    }()
    // 函数返回后，goroutine 仍在运行
}
```

## 常见泄漏场景

### 1. channel 阻塞未完成

```go
// ❌ 泄漏：发送者堵塞
func sendLeak() {
    ch := make(chan int)  // 无缓冲
    ch <- 1               // 主 goroutine 阻塞等待接收
    // 永远不会执行到这里
}

// ✅ 修复：使用有缓冲 channel 或 goroutine
func sendFixed() {
    ch := make(chan int, 1)
    ch <- 1  // 不会阻塞
}
```

### 2. 忘记关闭 channel

```go
// ❌ 泄漏：range 循环永不退出
func rangeLeak() {
    ch := make(chan int)
    go func() {
        for val := range ch { // 等到 channel 关闭才退出
            fmt.Println(val)
        }
    }()
    ch <- 1
    ch <- 2
    // 忘记 close(ch) → goroutine 永远等待
}

// ✅ 修复：确保关闭
func rangeFixed() {
    ch := make(chan int, 2)
    ch <- 1
    ch <- 2
    close(ch) // 发送完毕后关闭
}
```

### 3. select 缺少超时

```go
// ❌ 泄漏：select 全部阻塞
func selectLeak() {
    ch := make(chan int)
    select {
    case <-ch:          // 永远阻塞
    case <-time.After(5 * time.Second):  // ✅ 加超时
        fmt.Println("timeout")
    }
}
```

### 4. 死锁

```go
// ❌ 死锁：互相等待
func deadlock() {
    ch1 := make(chan int)
    ch2 := make(chan int)

    go func() {
        <-ch1
        ch2 <- 1
    }()

    <-ch2  // 等待 goroutine 发送
    ch1 <- 1 // 但 goroutine 等待 ch1
}
```

## 检测泄漏

### 1. runtime.NumGoroutine

```go
import "runtime"

func main() {
    fmt.Println("before:", runtime.NumGoroutine())
    leak()
    time.Sleep(time.Second)
    fmt.Println("after:", runtime.NumGoroutine()) // 增加说明泄漏
}
```

### 2. pprof 分析

```go
import (
    "net/http"
    _ "net/http/pprof"
)

func main() {
    go http.ListenAndServe(":6060", nil)
    // ... 业务代码
}
```

```bash
# 查看 goroutine 数量
go tool pprof http://localhost:6060/debug/pprof/goroutine

# 查看堆
go tool pprof http://localhost:6060/debug/pprof/heap

# 查看 CPU
go tool pprof http://localhost:6060/debug/pprof/profile
```

**pprof 交互命令：**

```bash
# 在 pprof 交互界面中
top10      # 查看最热点
traces     # 查看调用链
list func  # 查看函数详情
web        # 可视化（需 Graphviz）
```

### 3. 测试中检测

```go
func TestNoLeak(t *testing.T) {
    before := runtime.NumGoroutine()
    doSomething()
    time.Sleep(100 * time.Millisecond) // 等待 goroutine 启动
    after := runtime.NumGoroutine()

    if after > before {
        t.Errorf("goroutine leak: before=%d, after=%d", before, after)
    }
}
```

## 修复泄漏的最佳实践

### 1. 能用 context 就用 context

```go
func worker(ctx context.Context) {
    for {
        select {
        case job := <-jobCh:
            process(job)
        case <-ctx.Done():
            return  // ✅ context 取消时退出
        }
    }
}
```

### 2. 确保 channel 关闭

```go
// 发送者负责关闭
go func() {
    defer close(ch)  // 确保一定会关闭
    for _, v := range data {
        ch <- v
    }
}()
```

### 3. 使用 errgroup 管理 goroutine 生命周期

```go
g, ctx := errgroup.WithContext(context.Background())
g.Go(func() error {
    // 携带着 ctx，可被取消
    return doWork(ctx)
})
g.Wait() // 等待所有完成
```

### 4. 超时兜底

```go
select {
case result := <-ch:
    return result
case <-time.After(10 * time.Second):
    return nil, errors.New("timeout")
}
```

## 分析工具总结

| 工具 | 命令 | 用途 |
|------|------|------|
| NumGoroutine | `runtime.NumGoroutine()` | 快速检测泄漏 |
| Race Detector | `go run -race` | 检测数据竞争 |
| pprof | `go tool pprof` | 分析 CPU/内存/goroutine |
| trace | `go tool trace` | 分析调度延迟 |
| GODEBUG | `GODEBUG=gctrace=1` | GC 调试 |

## 参考资料

- [Go Blog: Profiling Go Programs](https://go.dev/blog/pprof)
- [Go Race Detector](https://go.dev/doc/articles/race_detector)
- [pprof 文档](https://pkg.go.dev/net/http/pprof)
