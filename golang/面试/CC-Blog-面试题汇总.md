---
title: CC's Blog - 面试题汇总
date: 2026-06-09
tags:
  - 面试
  - golang
  - mysql
  - redis
  - source
---

# 面试题汇总

> 来源：[xyf1111.github.io](https://xyf1111.github.io/)，整理自 CC 博客中的面试系列文章。

## Go 面试题

### CSP 并发模型 (Go Interview 09)

Go 使用 **CSP（Communicating Sequential Processes）** 模型，核心是 "**以通信方式共享内存**"。

**GMP 模型**：
- **G (Goroutine)**：用户级轻量级线程，保存上下文
- **M (Machine)**：内核线程封装，实际执行者
- **P (Processor)**：调度 G 和 M，数量由 `GOMAXPROCS` 决定

**Goroutine 阻塞处理**：
- G0 阻塞（如 IO）→ 创建 M1，P 转移到 M1
- M0 返回后尝试从其他 M "偷"上下文，偷不到则放入 Global runqueue

### 并发控制三种方式

1. **Channel 通知**：无缓冲 channel 实现同步阻塞
2. **sync.WaitGroup**：Add/Done/Wait 模式，等待一组 goroutine 完成
3. **Context 上下文**（Go 1.7+）：适用于复杂网络并发，跟踪 goroutine 状态，共享数据

### Channel 为什么线程安全

- 发送和接收都是**原子性**操作
- 设计思想："通过通信来共享内存"，而非"通过共享内存来通信"
- 无缓冲 channel 同步阻塞，有缓冲 channel 满才阻塞

### Go GC 详解

三色标记清除，4 个阶段。优化关键是缩小 STW。

### Data Race 解决

- 使用 `sync.Mutex` 互斥锁
- 使用 Channel 传递数据（效率更高）
- `go run -race` 检测竞态条件

### JSON 对 nil slice 和空 slice 区别

- `nil slice`：`var slice []int`，JSON 序列化为 `null`
- `empty slice`：`make([]int, 0)`，JSON 序列化为 `[]`
- 两者**不一致**，需要注意区分

### 协程、线程、进程区别

| 维度 | 进程 | 线程 | 协程 |
|------|------|------|------|
| 调度 | OS | OS | 用户态 |
| 内存 | 独立空间 | 共享进程内存 | 用户栈 |
| 切换开销 | 大（寄存器、虚拟内存、文件句柄） | 较小 | 最小 |
| 通信 | IPC | 共享内存 | Channel/共享变量 |

### 死锁

**四个必要条件**（全满足才死锁）：
1. 互斥条件
2. 请求和保持
3. 不可剥夺
4. 循环等待

**预防**：破坏任一条件 — 资源一次分配、可剥夺、资源有序分配
**避免**：银行家算法
**检测**：资源分配表 + 进程等待表
**解除**：剥夺资源 / 撤销进程

---

## 2021秋季面试

> 原文：[2021秋季面试](https://xyf1111.github.io/2021%E7%A7%8B%E5%AD%A3%E9%9D%A2%E8%AF%95/)，2021-12-26

涉及公司：中捷、珊瑚游戏

### Gin vs Beego

| 维度 | Beego | Gin |
|------|-------|-----|
| 架构 | 完整 MVC（ORM、Session、路由） | 轻量，需自己实现 MVC |
| 路由 | 支持正则路由 | 不支持正则 |
| Session | 内置 | 需额外包 |
| 性能 | 较低 | 更高 |
| 场景 | 复杂业务、快速开发、1.0 项目 | 高性能接口、小型项目 |

### MongoDB vs Redis

| 维度 | Redis | MongoDB |
|------|-------|---------|
| 数据结构 | string/list/hash/set/zset | JSON/BSON 文档 |
| 持久化 | RDB + AOF | journal + mongofile |
| 复制 | master-slave | replica set (paxos 选举) + auto sharding |
| 事务 | 弱支持 | 不支持 |
| 场景 | 小数据量高性能运算 | 海量数据访问 |

### MySQL 数据同步到 Elasticsearch 四种方案

1. **同步双写**：简单但硬编码、强耦合、双写可能失败
2. **异步双写（MQ）**：性能好、不丢数据，但有延时
3. **定时器轮询**：无侵入、无耦合，但时效性差、有轮询压力
4. **基于 binlog 同步**（推荐）：无侵入、高性能、完全解耦，但构建 binlog 系统复杂

### MySQL 优化八法

1. 创建索引
2. 使用复合索引（最佳左前缀）
3. 索引列避免 NULL
4. 使用短索引（前缀索引）
5. 排序列建索引
6. LIKE `aaa%` 走索引，`%aaa%` 不走
7. 避免列上运算（导致索引失效）
8. 用 `NOT EXISTS` 替代 `NOT IN`，用 `OR` 替代 `<>`

---

## 相关笔记

- [[index|📚 返回知识库首页]]
- [[golang/核心原理/CC-Blog-Go语言核心原理|Go语言核心原理]] — Go 底层原理
- [[database/CC-Blog-MySQL与Redis|MySQL与Redis]] — 数据库与缓存笔记
- [[middleware/CC-Blog-消息队列与中间件|消息队列与中间件]] — RabbitMQ 与 gRPC
