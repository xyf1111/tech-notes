---
title: "Go 并发 03 - select多路复用"
date: 2021-07-22
tags:
  - golang
  - 并发
aliases:
  - "Go 并发 03"
  - "Go Study17"
---

# Go 并发 03 — select多路复用


## select 基础

`select` 让一个 goroutine **同时等待多个 channel 操作**：

```go
select {
case <-ch1:
    fmt.Println("received from ch1")
case ch2 <- 1:
    fmt.Println("sent to ch2")
}
```

| 特性 | 说明 |
|------|------|
| 同时就绪 | **随机选择一个**执行 |
| 无就绪 | **阻塞**直到某个 case 就绪 |
| nil channel | **永远阻塞**（相当于禁用这个 case） |
| 空 select | **永久阻塞**（`select {}`） |

## 空 select

```go
// 永久阻塞 main goroutine
// 通常用于让程序持续运行（如服务端）
select {}
```

## default — 非阻塞操作

```go
select {
case val := <-ch:
    fmt.Println("received:", val)
default:
    fmt.Println("no data available")  // 非阻塞：没有就绪立即执行 default
}
```

### 非阻塞发送

```go
select {
case ch <- val:
    fmt.Println("sent")
default:
    fmt.Println("channel full, dropping value")  // buffer 满时不阻塞
}
```

## 超时控制

```go
select {
case result := <-ch:
    fmt.Println("result:", result)
case <-time.After(3 * time.Second):
    fmt.Println("timeout after 3s")
}
```

> 注意：`time.After` 每次调用都会创建新 timer，如果在循环中使用会导致内存泄漏。循环中应该用 `time.NewTimer`。

## 循环中的 select — 多路监听

```go
ch1 := make(chan int)
ch2 := make(chan int)

go producer1(ch1)
go producer2(ch2)

for i := 0; i < 10; i++ {
    select {
    case v := <-ch1:
        fmt.Println("ch1:", v)
    case v := <-ch2:
        fmt.Println("ch2:", v)
    }
}
```

## 优先级实现

select 本身不支持优先级，但可以用嵌套 select + 循环实现：

```go
// 优先处理 ch1，ch1 没有数据才处理 ch2
for {
    select {
    case job1 := <-ch1:
        fmt.Println("high priority:", job1)
    default:
        select {
        case job1 := <-ch1:
            fmt.Println("high priority:", job1)
        case job2 := <-ch2:
            fmt.Println("normal:", job2)
        }
    }
}
```

### K8s 中的优先级 select 实战

```go
// kubernetes/pkg/controller/nodelifecycle/scheduler/taint_manager.go
func (tc *NoExecuteTaintManager) worker(worker int, done func(), stopCh <-chan struct{}) {
    defer done()
    for {
        select {
        case <-stopCh:
            return
        case nodeUpdate := <-tc.nodeUpdateChannels[worker]:
            tc.handleNodeUpdate(nodeUpdate)
            tc.nodeUpdateQueue.Done(nodeUpdate)
        case podUpdate := <-tc.podUpdateChannels[worker]:
            // 发现 Pod 需要更新时，先清空 Node 队列
        priority:
            for {
                select {
                case nodeUpdate := <-tc.nodeUpdateChannels[worker]:
                    tc.handleNodeUpdate(nodeUpdate)
                    tc.nodeUpdateQueue.Done(nodeUpdate)
                default:
                    break priority
                }
            }
            tc.handlePodUpdate(podUpdate)
            tc.podUpdateQueue.Done(podUpdate)
        }
    }
}
```

## select + for + timer — 循环中的超时

```go
// ✅ 推荐：复用 Timer
ticker := time.NewTicker(5 * time.Second)
defer ticker.Stop()

for {
    select {
    case <-ticker.C:
        fmt.Println("tick every 5s")
    case <-ch:
        fmt.Println("processed job")
    case <-ctx.Done():
        fmt.Println("stopped")
        return
    }
}
```

## select + done channel — 优雅退出

```go
func worker(stop <-chan struct{}) {
    for {
        select {
        case job := <-jobCh:
            process(job)
        case <-stop:
            fmt.Println("worker shutting down")
            return
        }
    }
}
```

## 参考资料

- [Go by Example: Select](https://gobyexample.com/select)
- [Go 语言 select 详解](https://go.dev/tour/concurrency/5)
