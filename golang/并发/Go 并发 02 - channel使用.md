---
title: "Go 并发 02 - channel使用"
date: 2021-02-22
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 02"
  - "Go Study 15"
---

# Go 并发 02 — channel使用


## 理论基础：CSP

Go 的并发模型基于 **CSP（Communicating Sequential Processes）**：

> Don't communicate by sharing memory; share memory by communicating.
> *— 不要通过共享内存来通信，而要通过通信来共享内存。*

## channel 类型

| 类型 | 声明 | 说明 |
|------|------|------|
| 双向 | `chan T` | 可发送和接收 |
| 只发送 | `chan<- T` | 只能发送 |
| 只接收 | `<-chan T` | 只能接收 |

```go
ch := make(chan int)           // 双向
var sendOnly chan<- int = ch   // 只发送
var recvOnly <-chan int = ch   // 只接收
```

> 单向 channel 通常用在函数参数中，表达意图并限制滥用。

### 创建 channel

```go
// 无缓冲 channel（同步）
ch := make(chan int)

// 有缓冲 channel（异步）
ch := make(chan int, 10)

// nil channel
var ch chan int  // nil，不能收发
```

## 无缓冲 channel

```go
ch := make(chan int)

go func() {
    ch <- 42      // 阻塞直到 main goroutine 接收
}()

val := <-ch      // 接收，阻塞直到 goroutine 发送
fmt.Println(val) // 42
```

> 无缓冲 channel 保证**发送完成发生在接收之前**（同步语义）。

## 有缓冲 channel

```go
ch := make(chan int, 3)

ch <- 1           // 不阻塞
ch <- 2           // 不阻塞
ch <- 3           // 不阻塞
// ch <- 4        // 阻塞：缓冲区满了

fmt.Println(<-ch) // 1
fmt.Println(<-ch) // 2
fmt.Println(<-ch) // 3
// fmt.Println(<-ch) // 阻塞：缓冲区空了
```

### len 与 cap

```go
ch := make(chan int, 10)
ch <- 1
ch <- 2

fmt.Println(len(ch)) // 2（当前元素数）
fmt.Println(cap(ch)) // 10（缓冲区容量）
```

## 关闭 channel

```go
ch := make(chan int, 3)
ch <- 1
ch <- 2
close(ch)           // 关闭后不能再发送

// 方式1：ok 模式
for {
    val, ok := <-ch
    if !ok {
        break      // channel 已关闭
    }
    fmt.Println(val)
}

// 方式2：range 自动检测关闭
for val := range ch {
    fmt.Println(val)
}
```

### 关闭原则

> ⚠️ **谁发送谁关闭**，接收方不要关闭 channel。

```go
// ✅ 正确：发送方关闭
go func() {
    for _, v := range data {
        ch <- v
    }
    close(ch)       // 发送者关闭
}()

// ❌ 错误：接收方关闭（可能导致发送方 panic）
go func() {
    close(ch)       // 发送方还在往 ch 里发数据
}()
```

## nil channel

```go
var ch chan int   // nil

// ch <- 1        // ❌ 永远阻塞
// <-ch           // ❌ 永远阻塞
// close(ch)      // ❌ panic: close of nil channel

// 应用：在 select 中动态开关 channel
var ch chan int
select {
case ch <- 1:     // 永远不会执行（nil channel 永远阻塞）
}
```

## channel 常见用法

### 作为信号量

```go
// 通知 goroutine 结束
done := make(chan struct{})
go func() {
    // do work
    close(done)   // 通知完成
}()
<-done            // 等待完成
```

### 限制并发数

```go
sem := make(chan struct{}, 10)  // 最大 10 个并发

for _, task := range tasks {
    sem <- struct{}{}            // 获取令牌
    go func(t Task) {
        defer func() { <-sem }() // 释放令牌
        process(t)
    }(task)
}
```

### 超时控制

```go
ch := make(chan int, 1)
go func() {
    time.Sleep(2 * time.Second)
    ch <- result
}()

select {
case val := <-ch:
    fmt.Println("result:", val)
case <-time.After(1 * time.Second):
    fmt.Println("timeout")
}
```

## 参考资料

- [Go Blog: Share Memory By Communicating](https://go.dev/blog/codelab-share)
- [Go by Example: Channels](https://gobyexample.com/channels)
- [Channel 关闭原则](https://go101.org/article/channel-closing.html)
