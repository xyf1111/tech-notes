---
title: "Java 07 - 继承与多态"
date: 2026-06-11
tags: [java, 面向对象]
---

# Java 07 - 继承与多态

## 继承 (Inheritance)

使用 `extends` 关键字实现继承，Java 只支持**单继承**。

```java
public class Animal {
    public void eat() { System.out.println("吃东西"); }
}

public class Dog extends Animal {
    public void bark() { System.out.println("汪汪"); }
}
```

### super 关键字

- `super.属性/方法` — 访问父类成员
- `super()` — 调用父类构造方法（必须放在子类构造方法第一行）

### 方法重写 (Override)

子类重新实现父类方法：
- 方法名、参数列表必须相同
- 返回值类型是父类返回值的子类型
- 访问权限不能更严格（public → public，不能 public → protected）

## 多态 (Polymorphism)

同一方法调用在不同对象上表现出不同行为。

### 多态三个必要条件
1. 继承关系
2. 方法重写（Override）
3. 父类引用指向子类对象

```java
Animal a = new Dog();
a.eat();   // 调用 Dog 的 eat()
```

### 向上转型 vs 向下转型

| 方向 | 说明 | 安全性 |
|------|------|--------|
| **向上转型** | 子类→父类（自动） | 安全，会丢失子类特有方法 |
| **向下转型** | 父类→子类（强制） | 不安全，需 `instanceof` 判断 |

```java
// 向上转型（自动）
Animal a = new Dog();

// 向下转型（强制）
if (a instanceof Dog) {
    Dog d = (Dog) a;
}
```

### instanceof 关键字

判断对象是否是某个类的实例：
```java
if (obj instanceof Dog) {
    // obj 是 Dog 类型
}
```
