---
title: "Java 10 - Collection与List"
date: 2026-06-11
tags: [java, 集合]
---

# Java 10 - Collection与List

## Java 集合框架

```
Collection (接口)
├── List (有序可重复)
│   ├── ArrayList
│   ├── LinkedList
│   └── Vector (线程安全)
├── Set (无序不可重复)
│   ├── HashSet
│   ├── LinkedHashSet
│   └── TreeSet
└── Queue (队列)
    ├── LinkedList
    └── PriorityQueue

Map (接口，键值对)
├── HashMap
├── LinkedHashMap
├── TreeMap
└── Hashtable (线程安全)
```

## List 接口

有序、可重复、支持索引访问。

### ArrayList

- 基于**动态数组**实现
- 查询快（O(1) 随机访问）
- 增删慢（需移动元素）
- 初始容量 10，自动扩容 1.5 倍

```java
List<String> list = new ArrayList<>();
list.add("Java");
list.add("Python");
String s = list.get(0);  // 索引访问
```

### LinkedList

- 基于**双向链表**实现
- 查询慢（O(n) 顺序访问）
- 增删快（O(1) 头尾操作）
- 实现了 Deque 接口，可作队列/栈使用

```java
LinkedList<String> list = new LinkedList<>();
list.addFirst("A");
list.addLast("B");
String first = list.removeFirst();
```

### 常用方法

| 方法 | 说明 |
|------|------|
| `add(E e)` | 添加元素 |
| `get(int index)` | 获取元素 |
| `set(int index, E e)` | 修改元素 |
| `remove(int index)` | 删除元素 |
| `size()` | 大小 |
| `contains(Object o)` | 是否包含 |
| `indexOf(Object o)` | 查找索引 |

## List 遍历方式

```java
// 1. for 循环（仅 List）
for (int i = 0; i < list.size(); i++) {
    System.out.println(list.get(i));
}

// 2. 增强 for
for (String s : list) {
    System.out.println(s);
}

// 3. Iterator
Iterator<String> it = list.iterator();
while (it.hasNext()) {
    System.out.println(it.next());
}

// 4. forEach + Lambda（Java 8+）
list.forEach(System.out::println);
```
