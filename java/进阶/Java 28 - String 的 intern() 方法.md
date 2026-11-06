---
title: "Java - String 的 intern() 方法"
date: 2026-07-24
tags:
  - java
  - string
  - jvm
  - 常量池
  - 面试
source: "鱼皮·编程导航 / codefather"
---

# String 的 intern() 方法

> `String.intern()` 是一种手动将字符串加入常量池中的方法。如果常量池已存在该字符串则返回已有引用，否则根据 JDK 版本采取不同策略。

## 常见面试问题

### 1. `String s1 = "a" + "b";` 创建了几个对象？

**最多 1 个。**

编译期优化：字符串常量拼接在编译时会被优化为 `"ab"`，然后查找常量池，不存在则创建。

### 2. `String s2 = new String("ab");` 创建了几个对象？

**1 或 2 个。**

`new` 必然在堆中创建 1 个对象；如果常量池中不存在 `"ab"`，则在常量池再创建 1 个。

### 3. `String s3 = new String("a") + new String("b");` 创建了几个对象？

**最少 4 个，最多 6 个。**

- 2 个 `new String("a")` 和 `new String("b")` 对象
- 1 个 `StringBuilder` 对象（字符串拼接的底层实现）
- 1 个 `StringBuilder.toString()` 创建的 `new String("ab")` 对象
- 可能：常量池中的 `"a"` 和 `"b"`（如第一次出现）

### 4. `String s4 = new String("a") + new String("b"); s4.intern();` 创建了几个对象？

**最少 4 个，最多 7 个。**

同上分析，额外多出调用 `intern()` 时的常量池操作。JDK 7 前后行为不同。

## intern() 的 JDK 版本差异

### JDK 6（及之前）

常量池位于 **PermGen（永久代）**，是一块大小固定的区域，主要用于存放已加载的类信息和字符串池。

**intern() 行为：** 查找常量池是否存在该字符串内容，不存在则在常量池中**创建新对象**并返回引用；存在则直接返回。

**问题：** 永久代大小固定，无用对象过多容易 OOM（栈溢出）。堆区与 PermGen 隔离，容易创建多个相同值的对象。

### JDK 7（及之后）

常量池从 PermGen 移到了 **Java 堆区**。

**intern() 行为：** 查找常量池是否存在该字符串内容：
- **已存在** → 直接返回字符串引用
- **不存在** → 复制该字符串对象的**引用**到常量池中并返回（而非复制整个对象）

### 实际应用场景

```java
// 基于用户 id 加锁，确保同一用户的操作串行
synchronized (id.toString().intern()) {
    // 一人一单业务逻辑
}
```

> `id.toString().intern()` 确保相同 id 的字符串引用相同，从而在 `synchronized` 中锁定同一个对象。但注意：大量调用 `intern()` 会增加常量池压力，生产环境需评估使用。

## 总结

| 场景 | JDK 6 | JDK 7+ |
|------|-------|--------|
| intern() 不存在时 | 常量池中创建新对象 | 常量池中存储堆中对象的引用 |
| 常量池位置 | PermGen（永久代） | Heap（堆） |
| 内存风险 | PermGen OOM | 堆内存占用增加 |

> 来源：鱼皮·编程导航 / codefather
