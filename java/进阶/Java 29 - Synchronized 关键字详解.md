---
title: "Java 29 - Synchronized 关键字详解"
date: 2026-07-25
tags: [Java, 并发, 多线程, 锁]
source: "鱼皮·编程导航 / codefather"
---

# Java 29 - Synchronized 关键字详解

> Synchronized 是 Java 最基础的同步原语，基于 Monitor 对象实现。本文详解其用法、原理、可重入机制、字节码层面、不同锁对象的同步情况以及死锁检测。

## 核心要点

### 一、使用位置

1. **修饰实例方法** — 对象锁为当前实例对象（`this`）
2. **修饰静态方法** — 对象锁为当前类对应的 Class 对象
3. **修饰代码块** — 需手动指定对象锁

```java
// 实例方法
public synchronized void testMethod() { }

// 静态方法
public static synchronized void testMethod() { }

// 代码块 — 手动指定对象锁
synchronized(this) { }       // 当前实例
synchronized(x) { }          // x 对象
synchronized(X.class) { }    // X 类的 Class 对象
```

### 二、工作原理

每个 Java 对象对应一个 **Monitor（监视器）对象**，内含一个**计数器**和**等待队列**：

1. 线程进入 synchronized 代码块 → 检查 Monitor 计数器
2. 计数器为 0 → 获取锁，计数器 +1
3. 计数器非 0 → 线程进入等待队列
4. 线程退出 → 计数器 -1；减为 0 时释放锁，唤醒等待队列

### 三、可重入锁原理

同一线程持有锁后，再次遇到同一对象的 synchronized 代码块时，计数器再次 +1（重入）。依次退出各层代码块时计数器递减，最后归零释放锁。

### 四、字节码指令原理

- **修饰方法**：通过 `ACC_SYNCHRONIZED` flag 标记，方法调用指令检查该标记决定是否加锁
- **修饰代码块**：在代码块前后插入 `monitorenter` 和 `monitorexit` 两条字节码指令

可通过 `javap -c -v Mytest.class` 反编译查看。

### 五、不同锁对象的同步情况

| 锁类型 | 同步范围 |
|---|---|
| `synchronized(this)` | 当前实例的 synchronized 实例方法 + 当前实例的 `synchronized(this){}` 代码块 |
| `synchronized(非this对象x)` | x 对象的 synchronized 实例方法 + x 对象的 `synchronized(this){}` 代码块 |
| `synchronized(X.class)` | **所有** X 类实例的 synchronized 静态方法 + 所有 `synchronized(X.class){}` 代码块 |

> ⚠️ Class 锁陷阱：因为类对应的 Class 对象是单例的，所有实例的静态方法和 `synchronized(X.class){}` 代码块都互相同步。

### 六、线程安全判断

**共享资源需要同步**（写操作）。Java 中常见的共享资源：

1. 多线程操作同一个对象的实例变量/实例方法
2. 单例模式返回的对象（@Bean、手写单例、JDK 原生系统类）
3. `static` 修饰的方法和变量（"单例方法/变量"）

> 📌 `@Controller` 下的代码一定被多线程访问，若其中使用了单例对象则需考虑线程安全。

**检验线程安全的方法：**
1. 阅读源码（如 `System.out.println()` 因 `System.out` 是静态变量而使用了 synchronized）
2. 实验测试（创建多个线程并发操作，验证结果是否符合预期）
3. 查资料/问经验/参考项目历史版本

### 七、String 常量锁的坑

JVM 有 String 常量池，使用字符串常量作为锁对象时建议：

```java
// ✅ 推荐：每次 new 新对象，避免常量池冲突
String str = new String("a");
synchronized(str) { }

// ❌ 不推荐：字符串字面量可能被其他代码共享
String str = "a";
synchronized(str) { }
```

### 八、锁的释放时机

1. **自然释放**：线程正常执行完方法
2. **异常释放**：执行过程中抛出异常也会释放锁

### 九、继承环境下的 synchronized

- 子类继承父类的 synchronized 实例方法 — 方法 A（继承自父类）和方法 B（子类自定义）在同一子类对象上同步执行
- 子类**重写**父类方法后，需**重新添加** synchronized 修饰

### 十、死锁与检测

**死锁**：不同线程都在等待对方持有且不可能释放的锁，导致所有任务无法继续。

使用 JDK 自带工具检测：
```bash
jps          # 获取运行中的 Java 进程 ID
jstack -l <pid>   # 检测死锁
```

> 来源：鱼皮·编程导航 / codefather
