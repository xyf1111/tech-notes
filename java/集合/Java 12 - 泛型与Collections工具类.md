---
title: "Java 12 - 泛型与Collections工具类"
date: 2026-06-11
tags: [java, 集合]
---

# Java 12 - 泛型与Collections工具类

## 泛型 (Generics)

Java 5 引入，提供编译时类型安全检查。

### 泛型类

```java
public class Box<T> {
    private T content;
    
    public void set(T content) {
        this.content = content;
    }
    
    public T get() {
        return content;
    }
}

// 使用
Box<String> box = new Box<>();
box.set("Hello");
String val = box.get();  // 无需强制类型转换
```

### 泛型方法

```java
public <T> T getValue(T value) {
    return value;
}
```

### 泛型通配符

| 通配符 | 含义 | 示例 |
|--------|------|------|
| `?` | 任意类型 | `List<?>` |
| `? extends T` | T 或 T 的子类 | `List<? extends Number>` |
| `? super T` | T 或 T 的父类 | `List<? super Integer>` |

### 类型擦除

- Java 泛型是**编译时**检查，运行时擦除类型信息
- `List<String>` 和 `List<Integer>` 在运行时都是 `List`

## Collections 工具类

`java.util.Collections` 提供大量静态方法操作集合。

### 排序与查找

```java
List<Integer> list = new ArrayList<>(Arrays.asList(3, 1, 2));
Collections.sort(list);           // 自然排序 [1, 2, 3]
Collections.sort(list, (a, b) -> b - a);  // 自定义排序 [3, 2, 1]
Collections.reverse(list);        // 反转
Collections.shuffle(list);        // 随机打乱
int idx = Collections.binarySearch(list, 2);  // 二分查找（需有序）
```

### 不可变集合

```java
List<String> empty = Collections.emptyList();
List<String> single = Collections.singletonList("A");
List<String> unmod = Collections.unmodifiableList(list);
// unmod.add("B");  // 抛 UnsupportedOperationException
```

### 同步包装

```java
List<String> syncList = Collections.synchronizedList(new ArrayList<>());
Map<String, String> syncMap = Collections.synchronizedMap(new HashMap<>());
```

> 推荐优先使用 `java.util.concurrent` 包中的并发集合（`ConcurrentHashMap`、`CopyOnWriteArrayList`），性能更好。

## Arrays 工具类

```java
List<String> list = Arrays.asList("A", "B", "C");  // 数组→List
Arrays.sort(arr);        // 排序
Arrays.binarySearch(arr, key);  // 二分查找
Arrays.fill(arr, val);   // 填充
Arrays.toString(arr);    // 打印数组
```
