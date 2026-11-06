---
title: "Java 23 - Stream 流快速入门"
date: 2026-07-22
tags: [java, java8, stream, lambda, functional]
source: "鱼皮·编程导航 / codefather"
---

# Java 23 - Stream 流快速入门

> Java 8 Stream API 提供了一种声明式处理集合数据的方式，支持链式操作、并行处理，让代码更简洁高效。

## 什么是 Stream

Stream（流）是一个来自数据源的元素队列，支持聚合操作。流在管道中传输，可在管道节点上进行筛选、排序、聚合等处理。

**核心组成：** 元素、数据源、聚合操作、内部迭代、Pipelining（管道化）。

## 创建 Stream

```java
// 串行流
Stream<String> stream = stringList.stream();

// 并行流
Stream<String> parallelStream = stringList.parallelStream();
```

## 常用操作

### 遍历 - forEach

```java
stringList.forEach(System.out::println);
```

### 映射 - map

```java
stringList.stream().map(i -> i.equals("juejin"));
```

### 过滤 - filter

```java
stringList.stream().filter(i -> i.equals("juejin"));
```

### 截断 - limit

```java
integerList.stream().limit(3);
```

### 跳过 - skip

```java
integerList.stream().skip(5).limit(3);
```

### 去重 - distinct

```java
integerList.stream().distinct().collect(Collectors.toList());
```

### 排序 - sorted

```java
// 自然排序
integerList.stream().sorted();
// 指定比较器
integerList.stream().sorted(Comparator.comparing(Integer::intValue));
```

## Collectors 收集器

### 恒等处理

将元素从 Stream 取出放入集合，不做内容变更：

| 方法 | 说明 |
|------|------|
| `toList()` | 收集到 List |
| `toSet()` | 收集到 Set |
| `toCollection()` | 收集到指定集合类型 |

### 归约汇总

元素逐个进入处理函数，与上一个结果合并，最终输出：

| 方法 | 说明 |
|------|------|
| `counting()` | 统计元素个数 |
| `summingInt()` | 计算 int 字段总和 |
| `averagingInt()` | 计算 int 字段平均值 |
| `joining()` | 拼接字符串，可指定分隔符 |
| `maxBy()` | 取最大值 |
| `minBy()` | 取最小值 |

### 分组分区

**基础分组：**

```java
Map<String, List<Employee>> resultMap =
    getAllEmployees().stream()
        .collect(Collectors.groupingBy(Employee::getSubCompany));
```

**分组后统计：**

```java
Map<String, Long> resultMap = getAllEmployees().stream()
    .collect(Collectors.groupingBy(Employee::getSubCompany,
            Collectors.counting()));
```

> 来源：鱼皮·编程导航 / codefather
