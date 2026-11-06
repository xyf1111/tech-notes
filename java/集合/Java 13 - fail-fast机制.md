---
title: "Java 集合 - fail-fast 机制"
date: 2026-07-26
tags: [Java, 集合, 并发, fail-fast]
source: "鱼皮·编程导航 / codefather"
---

# Java 集合 - fail-fast 机制

> Java 中的故障快速检测机制，一旦检测到集合在遍历过程中被并发修改，立即抛出 `ConcurrentModificationException`。

## 核心要点

### 什么是 fail-fast

Java 集合框架中的一种错误检测机制：当迭代器遍历集合时，如果检测到集合结构被修改（增删元素），立即抛出 `ConcurrentModificationException`，停止继续执行，而不是冒着数据不一致的风险继续运行。

**典型案例**：在增强 `for` 循环（foreach）中对 `ArrayList` 执行 `remove` 操作。

```java
List<String> list = new ArrayList<>();
list.add("2");
list.add("2");
list.add("3");
for (String str : list) {
    if ("2".equals(str)) {
        list.remove(str); // 触发 fail-fast
    }
}
// 抛出 ConcurrentModificationException
```

**例外情况**：如果删除的是倒数第二个元素，由于 `cursor == size`，不会触发 `checkForComodification()`，程序不会抛异常，但结果期望与代码逻辑不符（属于偶然正确）。

### 阿里巴巴规约

> 不要在 foreach 循环中使用集合的 `remove/add` 操作。

### 正确删除集合元素的方式

| 方案 | 代码方式 | 特点 |
|------|----------|------|
| Iterator.remove() | `iterator.remove()` | 最推荐，通过迭代器自身删除 |
| Stream filter | `list.stream().filter(...).collect(Collectors.toList())` | 函数式风格，生成新 List |
| 普通 for 循环 | `for (int i = 0; i < list.size(); i++)` | 会漏删，需谨慎 |
| foreach + break | 仅一个目标元素时可用 | 局限性大 |
| fail-safe 集合 | `CopyOnWriteArrayList`, `ConcurrentLinkedDeque` | 遍历的是集合快照，不抛异常 |

**推荐做法**：

```java
// 方案一：Iterator.remove()
Iterator<String> iterator = list.iterator();
while (iterator.hasNext()) {
    String str = iterator.next();
    if ("2".equals(str)) {
        iterator.remove();
    }
}

// 方案二：Stream.filter
list = list.stream().filter(str -> !"2".equals(str)).collect(Collectors.toList());

// 方案三：fail-safe 集合（并发安全）
ConcurrentLinkedDeque<String> deque = new ConcurrentLinkedDeque<>();
deque.add("2");
deque.add("2");
deque.add("3");
for (String str : deque) {
    if ("2".equals(str)) {
        deque.remove(str); // 不会抛异常
    }
}
```

### 实现原理

- `ArrayList` 内部维护 `modCount` 字段记录结构修改次数
- 迭代器创建时记录期望的 `expectedModCount = modCount`
- 每次 `next()` 调用时检查 `modCount != expectedModCount`
- 不一致则抛出 `ConcurrentModificationException`

### fail-safe 机制

与 fail-fast 相对的，`CopyOnWriteArrayList`、`ConcurrentHashMap` 等并发集合采用 fail-safe 机制：遍历时在集合快照上操作，原集合的修改不影响迭代，不会抛异常。

> 来源：鱼皮·编程导航 / codefather
