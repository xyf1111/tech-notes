---
title: "Go 底层原理 08 - goroutine 调度原理"
date: 2026-06-13
tags:
  - golang
  - 底层原理
aliases:
  - "Go 底层原理 08"
---

# Go 底层原理 08 — goroutine 调度原理

## GMP 模型回顾

```
全局调度
    │
    ├── P0 ── M0 ── G1, G2, G3...
    │         │
    │         └── (sysmon 监控)
    │
    ├── P1 ── M1 ── G4, G5, G6...
    │
    └── ... (GOMAXPROCS 个 P)

全局运行队列 (runqueue) ← 被偷取的 goroutine
```

| 组件 | 数量 | 说明 |
|------|------|------|
| **G** (goroutine) | 动态 | 协程，包含栈、PC、SP |
| **M** (machine) | 动态 | 操作系统线程 |
| **P** (processor) | 固定 = GOMAXPROCS | 逻辑处理器，每个 P 绑定一个 M |

## goroutine 结构体

```go
type g struct {
    stack       stack       // 栈信息（lo, hi）
    stackguard0 uintptr     // 栈扩容检测
    m           *m          // 当前绑定的 M
    sched       gobuf       // 调度信息（sp, pc, bp, ret）
    atomicstatus uint32     // 状态（_Grunning, _Grunnable, _Gwaiting...）
    goid        int64       // goroutine ID
    waitsince   int64       // 开始等待的时间
    waitreason   string     // 等待原因
    preempt      bool       // 是否被抢占
    _panic       *_panic    // 最内层的 panic
    _defer       *_defer    // defer 链表
}
```

### goroutine 状态机

```
  ┌─────────┐
  │ _Gidle   │  → 刚分配
  └────┬─────┘
       ↓
  ┌─────────┐
  │ _Grunnable│  → 在运行队列中等待
  └────┬─────┘
       ↓
  ┌─────────┐      syscall      ┌──────────┐
  │ _Grunning │  ──────────────→ │ _Gsyscall │
  └────┬─────┘                  └──────────┘
       ↓  channel/锁阻塞
  ┌─────────┐
  │ _Gwaiting│  → 等待事件就绪
  └────┬─────┘
       ↓
  ┌─────────┐
  │ _Gdead   │  → goroutine 结束
  └─────────┘
```

## 调度循环 schedule()

```go
// runtime/proc.go — 简化伪代码
func schedule() {
    // 1. 检查 GC 是否需要暂停
    gcBlackenEnabled := gcphase == _GCmark

    // 2. 获取可运行的 G
    gp, inheritTime, tryWakeP := findRunnable()

    // 3. 执行 G
    execute(gp, inheritTime)
}

func execute(gp *g, inheritTime bool) {
    // 设置当前 M 的 G
    mp := getg().m
    mp.curg = gp
    gp.m = mp

    // 切换到 G 执行
    gogo(&gp.sched)
}
```

### findRunnable 优先级

1. 从**本地 P 队列**取 G（runnext 优先）
2. 从**全局队列**取 G
3. **work stealing**：从其他 P 偷一半 G
4. 从 **netpoller** 取就绪的 G
5. 如果都没有，**自旋**或**阻塞 M**

## 抢占式调度

Go 1.14+ 实现了**基于信号的抢占式调度**：

```go
// sysmon 线程定期（10ms~20ms）检查
func sysmon() {
    for {
        usleep(20 * 1000)  // 20μs

        // 如果 G 运行超过 10ms，发送抢占信号
        if gp.running && gp.preempt {
            preemptM(gp.m)  // 发送 SIGURG 信号
        }
    }
}
```

### 抢占时机

- **函数调用**：函数 prologue 检查 stackguard0
- **循环计算**：10ms 后收到 SIGURG 信号
- **GC 标记**：标记阶段暂停所有 G

```go
// 能被抢占的代码
go func() {
    for {  // ❌ 纯计算循环，10ms 后被抢占
        compute()
    }
}()

// 包含以下操作的自动触发调度切换
// - channel 操作
// - I/O
// - time.Sleep
// - sync.Mutex
// - runtime.Gosched()
```

## 网络轮询器 netpoller

Go 使用 **epoll**（Linux）/ **kqueue**（macOS）实现网络轮询：

```go
// netpoll 从 epoll 中获取就绪的 fd
// 在 findRunnable 中被调用
func netpoll() []*g {
    // epoll_wait 获取就绪事件
    // 将等待就绪的 G 唤醒
}
```

```go
// 网络 I/O 不会阻塞 M
conn, _ := net.Dial("tcp", "example.com:80")
// goroutine 进入 _Gwaiting 状态
// M 被释放去执行其他 G
// 数据到达时 epoll 通知，G 被放回运行队列
```

## 自旋线程

当 P 本地队列为空且没有 G 可偷时：

1. M 进入**自旋状态**（spinning）
2. 自旋的 M 持续检查是否有 G 可执行
3. 如果自旋超过阈值，M 进入睡眠

> 自旋是为了降低调度延迟，但会消耗 CPU。

## 参考资料

- [Go 调度器源码：runtime/proc.go](https://github.com/golang/go/blob/master/src/runtime/proc.go)
- [Go: goroutine 调度器详解](https://golang.org/src/runtime/HACKING.md)
- [Scalable Go Scheduler Design](https://docs.google.com/document/d/1TTj4T2Aj42tI0Hr6QJX0hV2R3zQe5fT5Gg5k5g5k5g4/edit)
