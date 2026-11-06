---
title: "Java 06 - 类与对象"
date: 2026-06-11
tags: [java, 面向对象]
---

# Java 06 - 类与对象

## 面向对象三大特性

1. **封装** — 隐藏内部实现，对外暴露接口
2. **继承** — 子类复用父类属性和方法
3. **多态** — 同一方法在不同对象上有不同行为

## 类与对象的关系

- **类**：对象的模板/蓝图，定义了属性和行为
- **对象**：类的具体实例，有独立的状态

```java
public class Person {
    // 属性（成员变量）
    String name;
    int age;
    
    // 方法
    public void sayHello() {
        System.out.println("Hello, I'm " + name);
    }
}

// 创建对象
Person p = new Person();
p.name = "Alice";
p.sayHello();
```

## 构造方法

- 方法名与类名相同，无返回值
- 如果没有显式定义，JVM 提供默认无参构造
- 可以重载多个构造方法

```java
public class Person {
    String name;
    
    // 无参构造
    public Person() {}
    
    // 有参构造
    public Person(String name) {
        this.name = name;
    }
}
```

## this 关键字

- 指向当前对象的引用
- 区分成员变量和局部变量（同名时）
- 调用当前类的其他构造方法：`this()`

## static 关键字

| 修饰 | 含义 | 访问方式 |
|------|------|----------|
| `static` 属性 | 类变量，所有实例共享 | `类名.属性名` |
| `static` 方法 | 类方法，不能访问非 static 成员 | `类名.方法名()` |
| `static` 代码块 | 类加载时执行一次 | 自动执行 |

## 包 (package) 与导入 (import)

- `package` — 声明类所在的包
- `import` — 导入其他包的类
- 包名规范：域名倒置，如 `com.company.project`
