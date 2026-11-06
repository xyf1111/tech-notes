---
title: "Java 09 - 内部类与Lambda表达式"
date: 2026-06-11
tags: [java, 面向对象]
---

# Java 09 - 内部类与Lambda表达式

## 内部类

定义在另一个类内部的类。

### 成员内部类

```java
public class Outer {
    private int id;
    
    public class Inner {
        public void show() {
            System.out.println(id);  // 可访问外部类私有成员
        }
    }
}
```

### 静态内部类

```java
public class Outer {
    private static int count;
    
    public static class StaticInner {
        public void show() {
            System.out.println(count);
        }
    }
}
```

### 局部内部类

定义在方法中的类，只能在方法内使用。

### 匿名内部类

常用于简化事件监听、线程等场景：

```java
new Thread(new Runnable() {
    @Override
    public void run() {
        System.out.println("匿名内部类");
    }
}).start();
```

## Lambda 表达式（Java 8+）

Lambda 表达式是 Java 8 引入的重要特性，相当于一个**语法糖**——在不改变底层机制的前提下让代码更简洁。

Lambda 可视为**匿名函数**，允许在需要函数的地方以更简洁的方式定义功能。

### 函数式接口（@FunctionalInterface）

Lambda 只能用于简化**函数式接口**——有且只有一个未实现方法的接口。如果接口包含多个未实现方法，则不是函数式接口，不能使用 Lambda。

```java
// 不是函数式接口（两个未实现方法）
interface MyInterface {
    int sum(int a, int b);
    int min(int a, int b);
}

// 是函数式接口（一个未实现方法 + 一个默认方法）
interface MyCase {
    int hello();
    default int hello(int a) { return a; }
}
```

可用 `@FunctionalInterface` 注解检查接口是否符合函数式接口条件，不符合时编译报错。

### 从匿名内部类到 Lambda

以含 `sum()` 方法的接口为例，展示逐步简化过程：

```java
// 1. 传统实现类
class MyInterfaceImpl implements MyInterface {
    @Override
    public int sum(int a, int b) {
        return a + b;
    }
}

// 2. 匿名内部类（减少实现类定义）
MyInterface myInterface = new MyInterface() {
    @Override
    public int sum(int a, int b) {
        return a * a + b * b;
    }
};

// 3. Lambda 表达式（只保留参数和方法体）
MyInterface myInterface2 = (int a, int b) -> {
    return a * a + b * b;
};
```

### Lambda 语法

```java
(参数列表) -> { 方法体 }

// 无参
() -> System.out.println("Hello")

// 单参（可省略括号）
x -> x * 2

// 多参
(x, y) -> x + y

// 多条语句
(x, y) -> {
    int sum = x + y;
    return sum;
}
```

**三条简化规则：**

1. **参数类型可省略**——接口已定义参数类型，只需参数名
   ```java
   (x, y) -> { return x * x + y * y; }
   ```

2. **单参数可省略括号**——零参数必须写 `()`，多参数也必须写 `()`
   ```java
   // 单参数
   MyCase1 c = a -> { return a + 1; };
   // 零参数
   MyCase  c2 = () -> { return 1; };
   ```

3. **单语句可省略 `{}` 和 `return`**
   ```java
   // 完整写法
   MyCase1 c1 = a -> { return a + 2; };
   // 简化写法
   MyCase1 c1 = a -> a + 2;
   ```

### 常见应用场景

**比较器排序：**

```java
// 传统匿名内部类
Collections.sort(names, new Comparator<String>() {
    @Override
    public int compare(String o1, String o2) {
        return o1.compareTo(o2);
    }
});

// Lambda 写法
Collections.sort(names, (o1, o2) -> o1.compareTo(o2));

// 方法引用（进一步简化）
Collections.sort(names, String::compareTo);
```

**线程创建：**

```java
// 传统写法
new Thread() {
    @Override
    public void run() {
        System.out.println("Hello");
    }
}.start();

// Lambda 写法
new Thread(() -> System.out.println("Hello")).start();
```

### 常用函数式接口（java.util.function）

| 接口 | 参数 | 返回值 | 用途 |
|------|------|--------|------|
| `Consumer<T>` | T | void | 消费型 |
| `Supplier<T>` | 无 | T | 供给型 |
| `Function<T,R>` | T | R | 函数型 |
| `Predicate<T>` | T | boolean | 判断型 |
