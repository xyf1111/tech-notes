---
title: "Java 46 - CompletableFuture 异步编程"
date: 2026-08-06
tags: [Java, 并发, CompletableFuture, 异步编程]
source: "鱼皮·编程导航 / codefather"
---

# Java 46 - CompletableFuture 异步编程

> 一句话摘要：CompletableFuture 是 Java 8 引入的异步编程利器，实现 CompletionStage 接口，相比传统 Future 支持自动回调、多任务编排组合与异常处理，是项目中高频使用的异步工具。

## 一、简介
CompletableFuture 是 Java 8 引入的类，实现了 CompletionStage 接口，提供一组丰富的方法处理异步操作和多个任务的结果，支持链式操作，可方便地处理任务的依赖关系和结果转换，比传统 Future 更灵活、更强大。

针对 Future 的不足之处，它给出三大改进：

1. **自动回调，无需阻塞**：异步线程执行结束后可自动回调新的处理逻辑；
2. **多任务编排**：可对多个异步任务进行编排、组合或排序；
3. **异常处理**：提供完善的异常处理机制。

核心思想：每个异步任务都可看作一个步骤（CompletionStage），其他异步任务可以基于这个步骤做想做的事情。

## 二、创建异步任务

### 2.1 runAsync()：无返回值
提交异步任务最基本的方法，用于执行没有返回值的任务：

```java
CompletableFuture<Void> future = CompletableFuture.runAsync(() -> {
    // 执行没有返回值的任务
});
```

### 2.2 supplyAsync()：有返回值
与 runAsync() 不同，该方法带有返回值，任务完成时返回结果：

```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
    return "返回值";
});
```

### 2.3 指定自定义线程池
上述任务默认在 ForkJoinPool 中异步执行，也可传入自定义线程池满足特定并发需求：

```java
ExecutorService customExecutor = new ThreadPoolExecutor(
        10, 20, 5, TimeUnit.MINUTES, new LinkedBlockingDeque<>());
CompletableFuture<String> future =
        CompletableFuture.supplyAsync(() -> "返回值", customExecutor);
```

## 三、获取任务结果
### 3.1 join() 方法
阻塞当前线程直到任务完成并返回结果。与 get() 相似，但不会抛出 InterruptedException 和 ExecutionException，而是将异常包装在 CompletionException 中抛出，更适合在 Lambda 表达式或流式操作中使用：

```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> "返回值");
String result = future.join();
```

### 3.2 get() 方法
同样阻塞等待结果，但会抛出 InterruptedException 和 ExecutionException，需显式进行异常处理：

```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> "返回值");
try {
    String result = future.get();
} catch (InterruptedException | ExecutionException e) {
    // 异常处理逻辑
}
```

> 结论：get() 异常处理较繁琐，在 Lambda 表达式或流式操作中推荐使用 join()。

## 四、异步回调方法
各回调方法区别如下：

| 方法 | 输入参数 | 返回值 | 功能 |
| --- | --- | --- | --- |
| thenApply(Function) | 上阶段任务结果 T | 新结果 U | 对结果做转换，返回新的 CompletableFuture |
| thenAccept(Consumer) | 上阶段任务结果 T | 无 | 消费任务结果，无返回值 |
| thenRun(Runnable) | 无 | 无 | 上阶段完成后执行 Runnable，无输入无返回值 |
| thenCombine(CompletionStage, BiFunction) | 两个任务结果 T、U | V | 两个任务都完成时组合结果 |

### 4.1 thenApply()：结果转换
```java
CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 42)
        .thenApply(result -> result * 2)
        .thenApply(result -> result + 1);
```

每个 thenApply() 都返回一个新的 CompletableFuture 对象，可继续链式调用。

### 4.2 thenAccept()：消费结果
```java
CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 42)
        .thenAccept(result -> System.out.println("任务结果：" + result));
```

仅用于消费任务结果，没有返回值。

### 4.3 thenRun()：完成后执行
```java
CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 42)
        .thenRun(() -> System.out.println("任务执行完毕"));
```

### 4.4 Async 版本：thenRunAsync() / thenApplyAsync() / thenAcceptAsync()
这三个回调方法都有对应的 Async 版本，区别在于执行线程：

- `thenRun()` 等：回调任务使用与上一个任务**同一个线程**执行；
- `thenRunAsync()` 等：使用**新线程**执行，默认从 ForkJoinPool 取线程，也可自定义线程池。

## 五、多任务组合回调
### 5.1 thenCombine()：组合两个任务的结果
当两个 CompletableFuture 都完成时，将任务结果传给 BiFunction 组合处理：

```java
CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(() -> 10);
CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(() -> 20);
// 返回结果：10 + 20 = 30
CompletableFuture<Integer> combinedFuture =
        future1.thenCombine(future2, (result1, result2) -> result1 + result2);
```

### 5.2 allOf()：等待所有任务完成
```java
CompletableFuture<Integer> future1 = CompletableFuture.supplyAsync(() -> 10);
CompletableFuture<Integer> future2 = CompletableFuture.supplyAsync(() -> 20);
// 此处阻塞，等 future1 和 future2 都执行完才继续往下执行
CompletableFuture<Void> allFutures = CompletableFuture.allOf(future1, future2);
```

### 5.3 anyOf()：获取率先完成的任务结果
添加一批任务，只要有一个任务完成就会停止阻塞并返回其结果，适用于通过不同方式计算同一个结果的场景：

```java
CompletableFuture<String> future1 = CompletableFuture.supplyAsync(() -> {
    try {
        Thread.sleep(4000);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
    return "任务1返回值";
});
CompletableFuture<String> future2 = CompletableFuture.supplyAsync(() -> "任务2返回值");
List<CompletableFuture> futureList = Arrays.asList(future1, future2);
CompletableFuture<Object> finalFuture =
        CompletableFuture.anyOf(futureList.toArray(new CompletableFuture[]{}));
System.out.println(finalFuture.join()); // 输出：任务2返回值
```

## 六、异常处理
### 6.1 exceptionally()：发生异常时处理
输入异常对象，返回值为上一个链式操作的返回值类型，可返回默认值：

```java
CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> {
    throw new RuntimeException("任务执行异常");
});
CompletableFuture<Integer> handledFuture = future.exceptionally(ex -> {
    System.out.println("异常处理：" + ex.getMessage());
    return 0; // 默认值
});
```

### 6.2 异常链处理
支持异常链：exceptionally() 之前**任意一个**链式异步任务抛出异常都会被捕获，不限于紧邻的上一步：

```java
CompletableFuture.runAsync(() -> System.out.println("第一个任务处理"))
        .thenRun(() -> System.out.println("第二个任务处理"))
        .thenRun(() -> System.out.println("第三个任务处理"))
        .thenRun(() -> System.out.println("第四个任务处理"))
        .thenRun(() -> System.out.println("第五个任务处理"))
        .exceptionally((e) -> {
            e.printStackTrace();
            return null;
        });
```

### 6.3 handle()：异常与结果同时处理
接收异常对象和上一个任务的返回值，没有异常时可直接返回上阶段结果：

```java
CompletableFuture<Integer> future = CompletableFuture.supplyAsync(() -> 42);
CompletableFuture<String> handledFuture = future.handle((result, ex) -> {
    if (ex != null) {
        System.out.println("异常处理：" + ex.getMessage());
        return "默认值";
    } else {
        return "结果：" + result;
    }
});
```

> handle() 与 exceptionally() 的区别：handle() 会接收上一个任务的返回值，未出现异常时可以将该返回值返回。

## 七、资源管理与任务取消
### 7.1 关闭自定义线程池
使用自定义线程池时需及时关闭以释放资源，可使用 shutdown() 或 shutdownNow()：

```java
ExecutorService customExecutor = new ThreadPoolExecutor(
        10, 20, 5, TimeUnit.MINUTES, new LinkedBlockingDeque<>());
// 异步任务代码...
customExecutor.shutdown();
```

### 7.2 cancel()：取消任务
```java
CompletableFuture<String> future = CompletableFuture.supplyAsync(() -> {
    // 异步任务的代码
});
boolean canceled = future.cancel(true); // 布尔值表示是否中断正在执行的任务
```

## 八、使用场景
### 8.1 与 IO 操作结合
将 IO 操作封装为 CompletableFuture 任务，利用异步特性提高 IO 效率，链式组织「读取 → 处理 → 写入」流程：

```java
CompletableFuture<String> readData = CompletableFuture.supplyAsync(() -> {
    return "读取的数据"; // 执行读取数据的 IO 操作
});
CompletableFuture<Void> processData = readData.thenAccept(data -> {
    System.out.println("读取到的数据：" + data); // 处理读取到的数据
});
CompletableFuture<Void> writeData = processData.thenRun(() -> {
    System.out.println("数据写入完成"); // 执行写入数据的 IO 操作
});
writeData.join();
```

### 8.2 与网络请求结合
发起多个网络请求，用 allOf() 等待所有请求完成后统一处理结果：

```java
CompletableFuture<String> request1 = CompletableFuture.supplyAsync(() -> "请求1结果");
CompletableFuture<String> request2 = CompletableFuture.supplyAsync(() -> "请求2结果");
CompletableFuture<String> request3 = CompletableFuture.supplyAsync(() -> "请求3结果");
CompletableFuture<Void> allRequests = CompletableFuture.allOf(request1, request2, request3);
allRequests.thenRun(() -> {
    // 所有请求完成后的处理逻辑
    String result1 = request1.join();
    String result2 = request2.join();
    String result3 = request3.join();
    // 对请求结果进行处理
});
```

### 8.3 实战案例：电商售后流程
业务背景：客服收到用户售后申请后，需查询订单信息、查询 ERP 中的商品信息、查询用户信息，并创建售后工单。三个查询相互独立，可并行执行：

```java
public CompletableFuture<Void> processAfterSalesRequest(String orderId, String customerId) {
    CompletableFuture<Order> orderFuture =
            CompletableFuture.supplyAsync(() -> getOrderInfo(orderId));
    CompletableFuture<Inventory> inventoryFuture =
            CompletableFuture.supplyAsync(() -> getInventoryInfo(orderId));
    CompletableFuture<User> userFuture =
            CompletableFuture.supplyAsync(() -> getUserInfo(customerId));
    return CompletableFuture.allOf(orderFuture, inventoryFuture, userFuture)
            .thenApplyAsync(ignored -> {
                Order order = orderFuture.join();
                Inventory inventory = inventoryFuture.join();
                User user = userFuture.join();
                createAfterSalesTicket(order, inventory, user); // 创建售后工单
                return null;
            });
}
```

三个查询并行执行，allOf() 等待全部完成后，通过 join() 获取各查询结果，传给 createAfterSalesTicket() 创建售后工单。

### 8.4 实战案例：循环内批量查询并发化（N+1 查询优化）

背景：某项目单元测试整体执行时间长达近 20 分钟，逐一观察各用例耗时后，定位到单个查询接口竟执行了近 10 分钟——测试数据库量级不过千，却慢得离谱。

**根因分析（两层问题叠加）：**

1. **测试数据设计缺陷**：每次测试插入资产数据时都固定指定所属用户 id = 1，日积月累导致该用户名下资产多达近千条，恰好查询接口又查的就是这个用户；
2. **N+1 循环查询**：接口逻辑是 for 循环内逐条查询资产详情，每个资产详情又要查多个表（getDetail/getXX/getYY/getZZ）才能拼出完整数据，耗时随资产数线性增加。业务上数据要全部返回给前端展示、用户资产数一般不多，所以不适合分页。

**解决方案**：把顺序查询改为并发查询——开一个线程池，每个资产详情查询封装成一个 CompletableFuture 任务并发执行，最后 allOf() 等待所有任务完成再整体返回：

```java
// 开个线程池
ExecutorService executor = new ThreadPoolExecutor(
    8, 100, 5,
    TimeUnit.MINUTES,
    new ArrayBlockingQueue<>(10000)
);
// 任务列表
List<CompletableFuture<Asset>> fList = new ArrayList<>();
for (int id : assetIds) {
    // 每个资产详情查询创建独立任务，并发执行
    CompletableFuture<Asset> f = CompletableFuture.supplyAsync(() -> {
        Asset asset = getDetail();
        asset.xx = getXX();
        asset.yy = getYY();
        asset.zz = getZZ();
        return asset;
    }, executor);
    fList.add(f);
}
// 阻塞，等待所有任务执行完成
CompletableFuture.allOf(fList.toArray(new CompletableFuture[0])).get();
```

**经验教训**：

- 单元测试不仅能验证功能正确性，还能**侧面暴露系统性能风险**——测试执行时间异常变长往往指向真实性能隐患（本例是 N+1 查询）；
- 测试数据要避免**固定主键堆积**：每次测试都往同一个 userId 下插数据，长期累积会让特定数据量远超正常水平，掩盖/放大真实性能问题；
- 循环内逐条查库（N+1）是常见性能杀手，数据量大时优先考虑并发查询（CompletableFuture）或批量查询（IN 查询）改写。

## 九、方法速查总结
| 分类 | 方法 | 说明 |
| --- | --- | --- |
| 创建任务 | runAsync() | 无返回值，适用于无返回结果的任务 |
| 创建任务 | supplyAsync() | 有返回值，适用于有返回结果的任务 |
| 获取结果 | get() | 需处理 InterruptedException / ExecutionException |
| 获取结果 | join() | 无需处理受检异常（包装为 CompletionException） |
| 回调 | thenApply() | 可访问上阶段结果，方法结束有返回值 |
| 回调 | thenAccept() | 可访问上阶段结果，方法结束无返回值 |
| 回调 | thenRun() | 不能访问上阶段结果，方法结束无返回值 |
| 回调（新线程） | thenApplyAsync() / thenAcceptAsync() / thenRunAsync() | 启用新线程处理回调任务 |
| 异常处理 | exceptionally() | 发生异常时处理，可返回默认值 |
| 异常处理 | handle() | 接收异常与上阶段返回值，无异常时可返回结果 |
| 多任务组合 | thenCombine() | 组合多个任务的结果 |
| 多任务组合 | allOf() | 等待所有任务完成后再继续操作 |
| 多任务组合 | anyOf() | 任一任务完成即停止阻塞，返回率先完成的任务结果 |
| 中断取消 | cancel() | 取消任务执行，可传布尔值决定是否中断正在执行的任务 |

## 相关文档
异常处理的两种场景详见 [[Java 40 - CompletableFuture 异常处理实践]]

> 来源：鱼皮·编程导航 / codefather
