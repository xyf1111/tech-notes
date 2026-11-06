---
title: "Java 11 - Set与Map"
date: 2026-06-11
tags: [java, 集合]
---

# Java 11 - Set与Map

## Set 接口

无序、不可重复。

### HashSet
- 基于 **HashMap** 实现（内部使用 HashMap 的 key）
- 无序（不保证顺序）
- 允许 null
- 判断重复：先 `hashCode()`，再 `equals()`

```java
Set<String> set = new HashSet<>();
set.add("Java");
set.add("Python");
set.add("Java");  // 不会添加成功
```

### LinkedHashSet
- 继承 HashSet
- 维护**插入顺序**（双向链表）
- 性能略低于 HashSet

### TreeSet
- 基于**红黑树**实现（TreeMap 的 key）
- **自动排序**（自然顺序或 Comparator）
- 不能存 null

```java
Set<Integer> sorted = new TreeSet<>();
sorted.add(3);
sorted.add(1);
sorted.add(2);  // 遍历顺序：1, 2, 3
```

## Map 接口

键值对（key-value），key 不可重复。

### HashMap
- 基于**数组 + 链表 + 红黑树**（Java 8+）
- 允许 key/value 为 null
- 初始容量 16，负载因子 0.75
- 链表达 8 且容量达 64 时转红黑树
- 无序

```java
Map<String, Integer> map = new HashMap<>();
map.put("Apple", 10);
map.put("Banana", 20);
int count = map.get("Apple");
```

### LinkedHashMap
- 维护**插入顺序**或**访问顺序**（LRU 缓存常用）
- 基于 HashMap + 双向链表

### TreeMap
- 基于**红黑树**
- 按 key **自动排序**
- 不能存 null key

### Hashtable
- 线程安全（方法上 synchronized）
- 不允许 null key/value
- 性能较低，已被 `ConcurrentHashMap` 取代

### 常用方法

| 方法 | 说明 |
|------|------|
| `put(K, V)` | 添加/修改键值对 |
| `get(Object key)` | 获取值 |
| `remove(Object key)` | 删除 |
| `containsKey(Object key)` | 是否包含 key |
| `keySet()` | 返回所有 key 的 Set |
| `values()` | 返回所有 value 的 Collection |
| `entrySet()` | 返回所有 Entry 的 Set |

### Map 遍历

```java
// 遍历 key
for (String key : map.keySet()) {
    System.out.println(key + "=" + map.get(key));
}

// 遍历 entry（推荐）
for (Map.Entry<String, Integer> entry : map.entrySet()) {
    System.out.println(entry.getKey() + "=" + entry.getValue());
}

// forEach + Lambda
map.forEach((k, v) -> System.out.println(k + "=" + v));
```
