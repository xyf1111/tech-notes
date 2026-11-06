---
title: "Java 16 - 锁与并发工具"
date: 2026-06-11
tags: [java, 多线程]
---

# Java 16 - 锁与并发工具

## synchronized 关键字

三种用法：
```java
// 1. 同步方法（锁当前实例）
public synchronized void method() { }

// 2. 静态同步方法（锁 Class 对象）
public static synchronized void staticMethod() { }

// 3. 同步代码块（锁指定对象）
public void method() {
    synchronized (this) { }
}
```

### 锁升级（Java 6+ 优化）

```
无锁 → 偏向锁 → 轻量级锁（自旋锁） → 重量级锁（OS 互斥量）
```

## volatile 关键字

- **可见性** — 强制从主内存读取，写后立即刷新到主内存
- **禁止指令重排** — 内存屏障
- ❌ 不保证原子性
```java
private volatile boolean running = true;
```

## Lock 接口（java.util.concurrent.locks）

```java
Lock lock = new ReentrantLock();
lock.lock();
try {
    // 临界区
} finally {
    lock.unlock();  // 必须在 finally 中释放
}
```

### ReentrantLock vs synchronized

| 对比 | synchronized | ReentrantLock |
|------|-------------|---------------|
| 使用 | 关键字，自动释放 | API，需手动释放 |
| 可中断 | 不支持 | `lockInterruptibly()` |
| 公平锁 | 不支持 | 可设置 |
| 条件变量 | wait/notify | Condition |
| 性能 | 优化后相近 | 相近 |

## 并发工具类（java.util.concurrent）

### CountDownLatch

让一个线程等待多个线程完成后再继续：
```java
CountDownLatch latch = new CountDownLatch(3);
// ... 3 个线程各调用 latch.countDown()
latch.await();  // 等待 count 到 0
```

### CyclicBarrier

多个线程互相等待，全部到达后再继续（可循环使用）：
```java
CyclicBarrier barrier = new CyclicBarrier(3);
// 每个线程调用 barrier.await()
```

### Semaphore

控制同时访问资源的线程数量：
```java
Semaphore sem = new Semaphore(3);
sem.acquire();  // 获取许可
// ... 使用资源
sem.release();  // 释放许可
```

### ThreadPoolExecutor

```java
ExecutorService executor = Executors.newFixedThreadPool(4);
executor.submit(() -> System.out.println("任务"));
executor.shutdown();
```
