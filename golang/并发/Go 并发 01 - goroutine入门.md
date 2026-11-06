---
title: "Go 并发 01 - goroutine入门"
date: 2021-02-21
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 01"
  - "Go Study 14"
---

# Go 并发 01 — goroutine入门


## goroutine 是什么

goroutine 是 Go 的**轻量级线程**（协程），由 Go 运行时管理而非操作系统。

| 对比 | 操作系统线程 | goroutine |
|------|------------|-----------|
| 创建成本 | ~1MB 栈空间 | ~2KB 栈空间（可动态增长） |
| 调度 | 内核调度 | 用户态调度（Go 运行时） |
| 切换成本 | 上下文切换 ~1μs | 函数调用级别 ~几十 ns |
| 数量 | 几千个上限 | 百万级 |

### 创建 goroutine

```go
// 任何函数前加 go 关键字即可
go myFunction()
go func() {
    fmt.Println("running in goroutine")
}()
```

> 与其它语言不同：Go 不需要 `async`/`await` 关键字，任何函数都可以作为 goroutine 启动。

### 非抢占式调度

goroutine 是**协作式**的，只在以下时机发生切换：
- I/O 操作
- channel 发送/接收
- 锁等待（sync）
- 函数调用（某些情况下）
- `runtime.Gosched()`
- GC 周期

```go
// 让出 CPU
runtime.Gosched()
```

## GMP 调度模型

Go 的调度器核心是 **GMP 模型**：

```
G — goroutine（协程）
M — machine（操作系统线程）
P — processor（逻辑处理器，默认 = GOMAXPROCS）
```

### 调度流程

1. **P 的数量** = `GOMAXPROCS`（默认 CPU 核心数）
2. 每个 **P** 绑定一个 **M**（线程）
3. P 从本地队列（runq）取 **G** 执行
4. 本地队列空时从全局队列或其他 P 偷取 G（**work stealing**）

```go
// 查看/设置 GOMAXPROCS
fmt.Println(runtime.GOMAXPROCS(0))    // 当前值
runtime.GOMAXPROCS(8)                 // 设置
```

### work stealing 与 hand off

- **Work Stealing**：当 P 本地队列为空时，从其他 P 偷取一半 G
- **Hand Off**：当 M 阻塞（如 syscall）时，P 与 M 解绑，P 绑定新的 M 继续执行

## goroutine 生命周期

```go
func main() {
    go fmt.Println("goroutine 1")
    go fmt.Println("goroutine 2")

    // main goroutine 结束会销毁所有 goroutine
    time.Sleep(100 * time.Millisecond)
}
```

> ⚠️ **main goroutine 结束则程序退出**，所有其他 goroutine 都会被强制终止。

## 检测数据竞争

```go
// 编译/运行时加上 -race 标志
// go run -race main.go
// go test -race ./...

var counter int
go func() {
    counter++  // 读写冲突！
}()
counter++
```

`-race` 会在发现数据竞争时输出详细报告。

## goroutine 的切换点

```go
// I/O 操作
file.Read(buf)

// channel
ch <- val      // 发送
<-ch           // 接收

// 锁
mu.Lock()
mu.Unlock()

// select
select { ... }

// 主动让出
runtime.Gosched()

// 等待
time.Sleep()

// 函数调用（某些情况，非保证）
```

> ⚠️ 以上只是可能切换的点，**不能保证一定会切换**。

## 参考资料

- [Go Blog: Goroutines](https://go.dev/blog/gosched)
- [Go Scheduler: M, P, G](https://go.dev/src/runtime/proc.go)
- [Go 调度器设计文档](https://golang.google.cn/sched)
