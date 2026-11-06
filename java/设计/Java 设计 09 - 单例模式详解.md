---
title: "Java 设计 09 - 单例模式详解"
date: 2026-08-29
tags: [设计模式, 创建型模式, 单例模式, Java]
source: "鱼皮·编程导航 / codefather"
---

# Java 设计 09 - 单例模式详解

> 单例模式保证一个类只有一个实例对象，是面试高频考点；核心在于私有化构造函数 + 全局唯一访问点，难点在于线程安全与懒加载的取舍。

## 什么是单例模式

单例模式是 OOP 语言的一种概念：**一个类只能有一个实例对象**。分为懒汉式和饿汉式两大类，各有传统实现与优化后的推荐实现（如双检锁、静态内部类、枚举等）。

## 懒汉式单例（时间换空间）

**特点**：需要使用时才实例化对象。由于多线程可能同时访问，必须考虑线程安全问题，防止并发生成多个实例，通常加锁解决。

### 传统实现（方法级加锁）

```java
class Singleton {
    private Singleton() {}                 // 私有构造函数
    private static Singleton obj;
    // 加锁保证 obj 只实例化一次，时间换空间
    public static synchronized Singleton getInstance() {
        if (obj == null) {
            obj = new Singleton();
        }
        return obj;
    }
}
```

缺点：每次获取实例都被 `synchronized` 串行化，即使实例已生成，性能差。

### 优化实现（双检锁 + volatile）

```java
class Singleton {
    private Singleton() {}
    // volatile 禁止指令重排序，防止拿到未初始化完成的实例
    private volatile static Singleton obj;

    public static Singleton getInstance() {
        if (obj == null) {                 // 已有实例直接返回，不走锁
            synchronized (Singleton.class) { // 仅在未生成实例时加锁
                if (obj == null) {         // 二次检查，防止并发重复实例化
                    obj = new Singleton();
                }
            }
        }
        return obj;
    }
}
```

检查了两次是否已实例化，故称 **「双检锁」**：保证线程安全的同时，提升实例化后的调用性能。

## 饿汉式单例（空间换时间）

**特点**：类加载时便实例化对象，第一时间可用，是拿空间换时间的方案。

### 传统实现

```java
class Singleton {
    private Singleton() {}
    // 类加载时就实例化对象
    private static Singleton obj = new Singleton();

    public static Singleton getInstance() {
        return obj;
    }
}
```

### 优化实现（静态内部类）

传统实现中，调用该类的其他静态方法也会触发类加载，从而提前实例化单例对象，造成空间浪费。静态内部类中的对象默认不加载，直到调用获取其属性的方法才加载：

```java
class Singleton {
    private Singleton() {}
    // 静态内部类：调用 getInstance 时才加载
    private static class SingletonHolder {
        private static Singleton instance = new Singleton();
    }

    public static Singleton getInstance() {
        return SingletonHolder.instance;
    }
}
```

**最推荐此实现**：static 保证线程安全 + 静态内部类节约空间实现懒加载（lazy-loading）+ 代码简短，一箭三雕。

## 细节深入：为什么双检锁要加 volatile

`new` 创建对象不是原子操作，会被编译成三条指令：

1. 给实例分配内存
2. 初始化实例的构造函数
3. 将对象引用指向分配的内存空间

正常按 1→2→3 执行。但 JVM 会利用处理器多级缓存、多核特性做**指令重排序**，可能按 1→3→2 执行。此时若另一线程执行到判断 null 的语句，因第 3 步已完成、对象引用非空而直接返回，但实例尚未初始化（第 2 步未执行），使用该对象就会出现错误（**引用逃逸**）。

`volatile` 通过内存屏障禁止指令重排序，保证创建对象的步骤按顺序执行，从而解决该问题。

> 注意：`final` 字段不能保证初始化过程中的可见性，也无法禁止指令重排序。

## 其他实现方式

- **Spring 容器的单例实现**：通过局部变量避免指令重排序来提高性能（一种特殊的避免重排序方法）
- **登记式注册表**：Spring 单例的一种实现方式，可自行搜索了解
- **枚举类**：天然线程安全且防止反射破坏，也是一种常见实现

> 来源：鱼皮·编程导航 / codefather
