---
title: "Java 19 - 反射机制"
date: 2026-06-11
tags: [java, 进阶]
---

# Java 19 - 反射机制

## 什么是反射

反射（Reflection）是在**运行时**动态获取类的信息并操作类成员的能力。

## 获取 Class 对象的三种方式

```java
// 方式一：Class.forName()（最常用）
Class<?> clazz = Class.forName("com.example.User");

// 方式二：类名.class
Class<?> clazz = User.class;

// 方式三：对象.getClass()
User user = new User();
Class<?> clazz = user.getClass();
```

## 反射常用 API

### 获取类信息

```java
Class<?> clazz = User.class;
clazz.getName();           // 完整类名
clazz.getSimpleName();     // 类名（不含包）
clazz.getModifiers();      // 访问修饰符
clazz.getPackage();        // 包
clazz.getSuperclass();     // 父类
clazz.getInterfaces();     // 实现的接口
```

### 操作字段

```java
Field[] fields = clazz.getDeclaredFields();   // 所有字段（含私有）
Field field = clazz.getDeclaredField("name");
field.setAccessible(true);  // 访问私有字段
field.set(obj, "Alice");    // 设置值
Object val = field.get(obj); // 获取值
```

### 操作方法

```java
Method[] methods = clazz.getDeclaredMethods();
Method method = clazz.getDeclaredMethod("setName", String.class);
method.setAccessible(true);
method.invoke(obj, "Bob");  // 调用方法
```

### 操作构造方法

```java
Constructor<?> constructor = clazz.getDeclaredConstructor(String.class, int.class);
constructor.setAccessible(true);
Object obj = constructor.newInstance("Alice", 25);
```

## 反射的应用场景

| 场景 | 说明 |
|------|------|
| **Spring IoC** | 通过反射实例化 Bean |
| **MyBatis** | 反射设置 SQL 参数和映射结果 |
| **JUnit** | 反射调用测试方法 |
| **动态代理** | JDK 动态代理基于反射 |
| **注解解析** | 运行时读取注解信息 |

## 反射的优缺点

| 优点 | 缺点 |
|------|------|
| 运行时动态操作类和对象 | 性能较低（有缓存优化） |
| 提高代码灵活性 | 破坏封装性（可访问私有成员） |
| 框架的基础能力 | 安全性问题 |
