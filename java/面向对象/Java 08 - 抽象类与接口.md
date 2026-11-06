---
title: "Java 08 - 抽象类与接口"
date: 2026-06-11
tags: [java, 面向对象]
---

# Java 08 - 抽象类与接口

## 抽象类 (abstract class)

使用 `abstract` 关键字声明，不能直接实例化。

```java
public abstract class Shape {
    protected String color;
    
    // 抽象方法（子类必须实现）
    public abstract double area();
    
    // 普通方法
    public void setColor(String color) {
        this.color = color;
    }
}

public class Circle extends Shape {
    private double radius;
    
    public Circle(double radius) {
        this.radius = radius;
    }
    
    @Override
    public double area() {
        return Math.PI * radius * radius;
    }
}
```

### 抽象类特点
- 不能 `new` 实例化
- 可以包含构造方法（供子类调用）
- 可以有抽象方法（子类必须实现）
- 可以有普通方法（具体实现）
- 可以有成员变量

## 接口 (interface)

使用 `interface` 关键字定义，Java 支持**多实现**。

```java
public interface Flyable {
    // 常量（默认 public static final）
    int MAX_SPEED = 100;
    
    // 抽象方法
    void fly();
    
    // default 方法（Java 8+）
    default void showInfo() {
        System.out.println("可以飞行的物体");
    }
    
    // static 方法（Java 8+）
    static boolean isFlyable(Object obj) {
        return obj instanceof Flyable;
    }
}
```

### 接口特点
- 不能实例化
- 所有方法默认 `public abstract`
- 所有属性默认 `public static final`
- 类使用 `implements` 关键字实现接口，可同时实现多个接口
- 接口可以继承接口（`extends`）

```java
public class Bird implements Flyable, Singable {
    @Override
    public void fly() {
        System.out.println("鸟儿飞翔");
    }
}
```

## 抽象类 vs 接口

| 对比 | 抽象类 | 接口 |
|------|--------|------|
| 关键字 | `abstract class` | `interface` |
| 继承/实现 | `extends`（单继承） | `implements`（多实现） |
| 构造方法 | 可以有 | 不能有 |
| 成员变量 | 任意类型 | `public static final` |
| 方法实现 | 可有 | default/static 方法（Java 8+） |
| 设计思想 | is-a（是什么） | can-do（能做什么） |
