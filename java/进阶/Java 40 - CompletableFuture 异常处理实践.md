---
title: "Java 40 - CompletableFuture 异常处理实践"
date: 2026-07-30
tags: [Java, 并发, CompletableFuture, 错误处理]
source: "鱼皮·编程导航 / codefather"
---

# Java 40 - CompletableFuture 异常处理实践

> 使用 CompletableFuture 进行异步编程时，需要区分两种不同来源的异常并分别处理。

## 异常场景分析

在异步任务中使用 CompletableFuture，可能出现两种异常：

### 1. 线程内部异常

任务线程执行过程中抛出的异常（如 AI 调用失败、数据库更新失败等）。这种异常可以通过 `.exceptionally()` 回调处理。

```java
CompletableFuture.runAsync(() -> {
    // 异步任务逻辑
    // 如果此处抛出异常，会被 exceptionally 捕获
}, threadPoolExecutor).exceptionally(throwable -> {
    // 处理异常：记录日志、更新状态、资源清理等
    log.error("异步任务执行异常", throwable);
    return null;
});
```

### 2. 任务提交异常

向线程池提交任务时抛出的异常（如线程池队列已满导致 RejectedExecutionException）。这种异常不会被 `.exceptionally()` 捕获，需要使用外层 try-catch 处理。

```java
try {
    CompletableFuture.runAsync(() -> {
        // 异步任务逻辑
    }, threadPoolExecutor).exceptionally(throwable -> {
        // 此处无法捕获任务提交阶段的异常
        log.error("异步任务执行异常", throwable);
        return null;
    });
} catch (RejectedExecutionException e) {
    // 处理任务提交异常：队列已满、线程池已关闭等
    log.error("任务提交失败：线程池资源不足", e);
} catch (Exception e) {
    // 处理其他提交阶段异常
    log.error("任务提交异常", e);
}
```

## 完整示例

将两种异常处理方式结合使用：

```java
try {
    CompletableFuture.runAsync(() -> {
        // 异步任务逻辑
        // 模拟耗时操作、远程调用、数据库写入等
    }, threadPoolExecutor).exceptionally(throwable -> {
        // 捕获线程内部异常
        log.error("异步任务内部异常", throwable);
        return null;
    });
} catch (Exception e) {
    // 捕获任务提交异常（如队列已满）
    log.error("任务提交失败", e);
}
```

## 总结

| 异常来源 | 处理方式 | 说明 |
|---------|---------|------|
| 线程内部异常 | `.exceptionally()` 回调 | 任务执行过程中抛出的异常，通过 CompletableFuture 提供的回调机制处理 |
| 任务提交异常 | 外层 `try-catch` | 向线程池提交任务时抛出的异常（如队列已满），exceptionally 无法捕获 |

- **线程内部异常** → `exceptionally()` 回调处理
- **任务提交异常** → 外层 `try-catch` 捕获
