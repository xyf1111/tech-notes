---
title: "Go 并发 05 - sync.WaitGroup 与协同"
date: 2026-06-13
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 05"
---

# Go 并发 05 — sync.WaitGroup 与协同

## WaitGroup 基础

`sync.WaitGroup` 用于**等待一组 goroutine 完成**：

```go
var wg sync.WaitGroup

for i := 0; i < 5; i++ {
    wg.Add(1)
    go func(id int) {
        defer wg.Done()
        fmt.Printf("worker %d done\n", id)
    }(i)
}

wg.Wait()  // 等待所有 worker 完成
fmt.Println("all done")
```

| 方法 | 说明 |
|------|------|
| `Add(delta int)` | 计数器 +delta |
| `Done()` | 计数器 -1（等价于 `Add(-1)`） |
| `Wait()` | 阻塞直到计数器为 0 |

### 注意事项

```go
// ✅ Add 必须在 goroutine 启动前调用
wg.Add(1)
go func() {
    defer wg.Done()
    // work
}()

// ❌ Add 在 goroutine 内部——Wait 可能在 Add 之前执行
go func() {
    wg.Add(1)    // 太晚了！
    defer wg.Done()
    // work
}()
wg.Wait()
```

### 批量 Add

```go
// 知道总数时一次性 Add
workers := 10
wg.Add(workers)
for i := 0; i < workers; i++ {
    go func(id int) {
        defer wg.Done()
        // work
    }(i)
}
wg.Wait()
```

## 常见模式

### 收集多个 goroutine 的结果

```go
type Result struct {
    Value int
    Err   error
}

results := make([]Result, 10)
var wg sync.WaitGroup

for i := 0; i < 10; i++ {
    wg.Add(1)
    go func(idx int) {
        defer wg.Done()
        results[idx] = fetchData(idx) // 预分配数组直接写
    }(i)
}

wg.Wait()
// 此时 results 已全部填充
```

### WaitGroup 与 recover

```go
go func() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("recovered:", r)
        }
        wg.Done()
    }()
    panic("something went wrong")
}()
```

## errgroup — 带错误传播的 WaitGroup

`golang.org/x/sync/errgroup` 是 WaitGroup 的增强版：

```go
import "golang.org/x/sync/errgroup"

g, ctx := errgroup.WithContext(context.Background())

for _, url := range urls {
    url := url
    g.Go(func() error {
        resp, err := http.Get(url)
        if err != nil {
            return err    // 第一个 error 会取消其他 goroutine
        }
        defer resp.Body.Close()
        // process response
        return nil
    })
}

// 等待所有完成或第一个错误
if err := g.Wait(); err != nil {
    fmt.Println("error:", err)
}
```

### errgroup 的特性

- **错误传播**：第一个非 nil error 会被返回
- **自动取消**：`WithContext` 返回的 ctx 在第一个错误时自动取消
- **并发限制**：可以设置最大并发数 `g.SetLimit(10)`

## 并发编排模式

### 扇出（Fan-Out）

```go
// 一个生产，多个消费
jobs := []int{1, 2, 3, 4, 5}
var wg sync.WaitGroup

for _, job := range jobs {
    wg.Add(1)
    go func(j int) {
        defer wg.Done()
        process(j)
    }(job)
}
wg.Wait()
```

### 流水线（Pipeline）

```go
func gen(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        for _, n := range nums {
            out <- n
        }
        close(out)
    }()
    return out
}

func sq(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        for n := range in {
            out <- n * n
        }
        close(out)
    }()
    return out
}

// pipeline: gen -> sq -> sq
for n := range sq(sq(gen(1, 2, 3))) {
    fmt.Println(n) // 1, 16, 81
}
```

## 参考资料

- [Go sync 包文档](https://pkg.go.dev/sync)
- [Go Blog: Pipelines](https://go.dev/blog/pipelines)
- [errgroup 文档](https://pkg.go.dev/golang.org/x/sync/errgroup)
