---
title: "Java 面试 01 - 26 届春招 Java 热题"
date: 2026-10-16
tags: [java, 面试, 八股, 集合, 并发]
source: "鱼皮·编程导航 / codefather"
---

# Java 面试 01 - 26 届春招 Java 热题

> 26 届春招 Java 高频面试题汇总（集合 / 并发 / 反射与代理 / JDK 新特性 / JVM / Spring 机制 / 中间件与 ORM），每题为「回答重点 + 扩展知识」结构，逐批追加。

## 一、JDK 1.8 对 HashMap 除了红黑树还进行了哪些改动？

**回答重点**：

- **改进哈希函数计算**：优化「扰动函数」，让哈希值的高低位都参与到桶的选择中，使分布更均匀、减少冲突。
- **扩容机制优化**：扩容迁移时不再对每个元素重新计算哈希值，而是根据原数组长度的高位来判断元素留在原位置还是迁移到新位置，减少计算、提升扩容效率。
- **头插法改为尾插法**：头插法插入时无需遍历链表，但扩容时会把链表逆序，多线程下可能成环导致死循环；改为尾插法后扩容顺序保持一致，规避该问题。

### 哈希函数的优化

JDK 1.7 的实现经历了四次异或，操作较多：

```java
static int hash(int h) {
    h ^= (h >>> 20) ^ (h >>> 12);
    return h ^ (h >>> 7) ^ (h >>> 4);
}
```

JDK 1.8 简化为把 key 哈希码的高 16 位与低 16 位异或，得到的 hash 值同时拥有高位和低位特性，分布更均匀、不易冲突：

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

这是 JDK 开发者在**速度、实用性、哈希质量**之间做的权衡。

### 扩容机制优化

扩容时依据原容量高位判断元素归属：因数组长度是 2 的幂，扩容后元素的新下标要么是「原下标」，要么是「原下标 + 原容量」，无需重算哈希。

> 相关：[[Java 14 - HashMap 源码解析]]

### 头插法与尾插法

- 1.7 头插法：插入无需遍历链表、直接替换头结点；缺点是扩容时链表逆序，多线程操作下可能出现环并造成死循环。
- 1.8 尾插法：每次都从尾部插入，扩容后链表顺序与之前一致，因此不会出现多线程扩容成环的情况。

延伸：**改成尾插法后 HashMap 就不会死循环了吗？** 严格说仍可能，此时问题出在红黑树（如并发 `put` 触发树化 / 退化时的结构错乱），可进一步查阅 CSDN 专题文章：`blog.csdn.net/qq_33330687/article/details/101479385`。

---

## 二、JDK 动态代理和 CGLIB 动态代理有什么区别？

**回答重点**：

- **JDK 动态代理**基于接口，要求被代理类一定有定义接口，底层用 `java.lang.reflect.Proxy` + `InvocationHandler`，通过反射调用目标方法。
- **CGLIB** 基于 ASM 字节码生成工具，通过**继承**目标类生成子类来实现代理，因此不需要接口、可代理普通类，但要注意 `final` 方法（不可继承，无法被代理）。
- 性能随 JDK 版本而变（取自 haiq 的博客实测）：
  - JDK 6：调用次数少时两者差距不明显（JDK 动态代理甚至更快）；次数增多后 CGLIB 略快。
  - JDK 7：情况逆转——次数少（100 万）时 JDK 动态代理快约 30%；次数多（5000 万）时快接近 1 倍。
  - JDK 8：与 JDK 7 基本一致。

### JDK 动态代理

基于接口，使用 `Proxy` 类 + `InvocationHandler` 接口实现。

```java
// 接口
public interface Service {
    void perform();
}

// 需要被代理的实现类
public class ServiceImpl implements Service {
    @Override
    public void perform() {
        System.out.println("target method executed");
    }
}
```

切面 / 处理类：

```java
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

public class ServiceInvocationHandler implements InvocationHandler {
    private final Object target;

    public ServiceInvocationHandler(Object target) {
        this.target = target;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("Before method invoke");
        Object result = method.invoke(target, args);
        System.out.println("After method invoke");
        return result;
    }
}
```

创建并使用代理对象：

```java
import java.lang.reflect.Proxy;

public class DynamicProxyDemo {
    public static void main(String[] args) {
        Service target = new ServiceImpl();
        Service proxy = (Service) Proxy.newProxyInstance(
                target.getClass().getClassLoader(),
                target.getClass().getInterfaces(),
                new ServiceInvocationHandler(target)
        );

        proxy.perform();
    }
}
```

实现原理：

1. 实现 `InvocationHandler` 接口得到一个切面类；
2. 通过 `Proxy` 根据目标类的类加载器、接口和切面类生成代理类；
3. 代理类把所有接口方法的调用转发到切面类的 `invoke()` 方法上，再由反射调用目标类的方法。

深入一点：代理类会在静态代码块中通过反射把接口的所有方法拿到并存入静态变量中（反编译后可见）。

### CGLIB

基于 ASM 字节码生成工具，通过继承实现代理，无需接口、可代理普通类，注意 `final` 方法不可代理。

```java
public class Service {
    public void perform() {
        System.out.println("target method executed");
    }
}
```

CGLIB 方法拦截器：

```java
import net.sf.cglib.proxy.MethodInterceptor;
import net.sf.cglib.proxy.MethodProxy;

import java.lang.reflect.Method;

public class ServiceMethodInterceptor implements MethodInterceptor {
    @Override
    public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
        System.out.println("Before method invoke");
        Object result = proxy.invokeSuper(obj, args);
        System.out.println("After method invoke");
        return result;
    }
}
```

创建并使用代理对象：

```java
import net.sf.cglib.proxy.Enhancer;

public class CglibDynamicProxyDemo {
    public static void main(String[] args) {
        Enhancer enhancer = new Enhancer();
        enhancer.setSuperclass(Service.class);
        enhancer.setCallback(new ServiceMethodInterceptor());

        Service proxy = (Service) enhancer.create();
        proxy.perform();
    }
}
```

CGLIB 通过**字节码生成技术**而非反射来实现调用逻辑。

> 相关：[[Java 19 - 反射机制]]、[[Java 31 - AOP与自定义注解实践]]、[[Java 设计 04 - 装饰者模式及JDK源码应用]]

---

## 三、JDK 8 有哪些新特性？

**回答重点**：JDK 8 较为重要、平时常被问到的特性如下：

1. 用**元空间**替代了永久代；
2. 引入了 **Lambda 表达式**；
3. 引入了新的**日期类**、接口**默认方法 / 静态方法**；
4. 新增 **Stream 流式接口**；
5. 引入 **Optional 类**；
6. 新增 **CompletableFuture、StampedLock** 等并发实现类。

回答时若对 HashMap / ConcurrentHashMap 有准备，可主动抛出「Java 8 修改了 HashMap 和 ConcurrentHashMap 的实现」来引导面试官追问。

### 元空间替代了永久代

JDK 8 要把 JRockit 虚拟机与 Hotspot 融合，而 JRockit 没有永久代，因此去掉了 Hotspot 的永久代（本质也是永久代回收效率太低）。永久代在堆内、受 `-XX:MaxPermSize` 约束，元空间移到本地内存（`-XX:MaxMetaspaceSize`），类元数据分配更加灵活。

> 相关：[[Java 17 - JVM内存模型与GC]]

### Lambda 表达式

Lambda 是 Java 8 引入的匿名函数，可理解为**一段可以传递的代码**（把代码像数据一样传递），本质是**函数式接口的实例**。

```java
// 传统方式
Runnable runnable1 = new Runnable() {
    @Override
    public void run() {
        System.out.println("run");
    }
};

// Lambda 表达式
Runnable runnable2 = () -> System.out.println("run");
```

> 相关：[[Java 34 - 函数式接口与Lambda表达式]]

### 日期类

Java 8 引入新的日期时间 API（`java.time` 包），更简洁易用，解决了旧 API 的诸多问题：

- 旧的 `Date`、`Calendar` 是**可变类且线程不安全**；新日期类**不可变**，创建后不能修改，避免意外修改、提升安全性与可维护性。
- `Date` 本身不含时区信息，必须配合 `Calendar` 处理时区，复杂且易错；新 API 提供专门的时区类（`ZonedDateTime`、`OffsetDateTime`、`ZoneId` 等），方法更直观易用。

```java
LocalDate date = LocalDate.now();
LocalTime time = LocalTime.now();
LocalDateTime dateTime = LocalDateTime.now();
```

### 接口默认方法、静态方法

默认方法允许在接口中定义方法的默认实现，实现类无需再实现这些方法；静态方法则用于把相关方法内聚在接口中，无需额外创建对象。

```java
interface MyInterface {
    default void defaultMethod() {
        System.out.println("Default Method");
    }

    static void hello() {
        System.out.println("Hello, New Static Method Here");
    }
}
```

### Stream 流式接口

Stream API 提供高效且易用的集合处理方式，支持链式操作、惰性求值和并行处理。

```java
List<String> list = Arrays.asList("a", "b", "c", "d");
List<String> result = list.stream()
                          .filter(s -> s.startsWith("a"))
                          .collect(Collectors.toList());
```

> 相关：[[Java 23 - Stream 流快速入门]]

### Optional

`Optional` 用于解决可能出现的 `NullPointerException`，提供一种优雅的方式处理可能为空的值。

```java
Optional<String> optional = Optional.of("value");
optional.ifPresent(System.out::println);
```

### CompletableFuture 与 StampedLock

`CompletableFuture` 提供了新的异步编程模型，简化异步任务的编写与管理：

```java
CompletableFuture.supplyAsync(() -> "Hello")
                 .thenApply(s -> s + " World")
                 .thenAccept(System.out::println);
```

`StampedLock` 是 JDK 8 新增的高性能读写锁（乐观读 / 悲观读 / 写三种模式），适合读多写少且对性能敏感的场景。

> 相关：[[Java 46 - CompletableFuture 异步编程]]、[[Java 50 - 四种锁实战（加入队伍功能）]]

---

## 四、Java 中 ConcurrentHashMap 1.7 和 1.8 之间有哪些区别？

**回答重点**：

- **锁的粒度**：JDK 1.7 采用**分段锁**，每个 `Segment` 独立、可并发访问，默认 16 个 `Segment`，最多 16 个线程并发执行；JDK 1.8 移除 `Segment`，锁粒度细化到链表/红黑树的**节点级别**。
- **并发控制手段**：1.8 插入用 **CAS**，只有在更新链表或红黑树时才用 `synchronized`，且只锁住链表/树的**头节点**，进一步减少锁竞争、提升并发度。
- **数据结构**：1.7 只有**数组 + 链表**；1.8 与 `HashMap` 一样引入**红黑树**。
- 此外，**扩容机制**与 **`size` 计算**的方式也不一样。

### ConcurrentHashMap 1.7 的结构（分段锁）

原理：先通过 key 的 hash 得到 `Segment` 数组下标，将该 `Segment` 上锁，再通过 key 的 hash 得到 `Segment` 内 `HashEntry` 数组的下标——此后就与 `HashMap` 一致了。因此可简化理解为：**每个 `Segment` 里存放的就是一个单独的 `HashMap`**。

- **并发度示例**：若有 6 个 `Segment`，就等于有 6 把锁，最多 6 个线程同时操作，并发度为 6；相比直接给整个 `put` 方法上锁，并发度更高，这就是分段锁。
- **上锁来源**：`Segment` **继承了 `ReentrantLock`**，自身具备加锁功能。
- **缺陷**：`Segment` 数组一旦初始化就**不扩容**，只有 `HashEntry` 数组会扩容——导致并发度过于死板，不能随数据增加而提高。

### ConcurrentHashMap 1.8 的结构（节点级锁）

- 更细粒度的锁控制：可理解为 **1.8 `HashMap` 数组的每个位置都是一把锁**，数组扩容后锁也随之变多，并发度增加。
- 思想转变：不再分段，直接把 `Node` 数组的每个节点各上一把锁。
- 不再借助 `ReentrantLock`，直接用 `synchronized`（侧面说明 JDK 1.8 对 `synchronized` 优化后性能已不亚于 `ReentrantLock`）。
- **插入流程**：计算 key 的 hash 得到下标 → 若该下标为空，用 **CAS** 塞入新 `Node`；若已有节点，用 `synchronized` 锁住该节点（其他线程无法访问该节点及其之后的所有节点）→ 判断 key 是否相等，相等则替换 value，否则新增节点（与 `HashMap` 一致）。

### 扩容的区别

**JDK 1.7**：

- **基于 Segment**：每个 `Segment` 内含一个 `HashMap`；当某个 `Segment` 达到扩容阈值时，**单独为该 `Segment` 扩容**，不影响其他 `Segment`。
- **扩容过程**：每个 `Segment` 维护自己的负载因子，超过阈值时该 `Segment` 的 `HashMap` 才扩容，整体并非一次性全部扩容。

**JDK 1.8**：

- **全局扩容**：取消 `Segment` 变成全局数组（类似 `HashMap`），任意位置元素超阈值时**整个数组扩容**。
- **基于 CAS**：扩容通过 CAS 保证线程安全，避免锁住整个数组；多个线程可同时协助扩容。
- **渐进式扩容**：不是一次性重新分配全部数据，而是多个线程共同参与、逐步迁移旧数据，降低扩容时的性能开销。

#### 渐进式扩容分析

- put 时若发现当前 node 的 hash 值为 **-1**，表明该节点正在扩容（ForwardingNode），触发**协助扩容机制**。
- 思路：扩容无非是搬迁 Node。假设数组长 32，可分段搬迁——31~16 由线程 A 搬、15~0 由线程 B 搬。
- 实现：维护一个 `transferIndex` 变量，来的线程**死循环 CAS 争抢下标**——下标已分配完就不需要搬，CAS 抢到待搬下标就去帮忙搬。

### size 逻辑的区别

**JDK 1.7**（「尝试」思想）：调用 `size` 时先**尝试三次不加锁获取**；三次总数一致说明数量没变，直接返回；不一致说明有线程在增删 map，则加锁计算，此时其他线程无法操作 map。

```java
if (retries++ == RETRIES_BEFORE_LOCK) {
    for (int j = 0; j < segments.length; ++j)
        ensureSegment(j).lock(); // force creation
}
// ...再累加数量
```

**JDK 1.8**：直接计算返回，采用**类似 `LongAdder` 的思想**——累加不再基于单个成员变量，而是搞一个数组，每个线程在各自对应下标处累加，最后统一汇总。

- put 时通过 `addCount` 方法维护 `counterCells` 数量（remove 也会调用）。
- 流程：先 CAS 修改 `baseCount`，成功即返回；失败说明有竞争，则通过 hash 选一个 `CounterCell` 修改。最终 `size = baseCount + 所有 CounterCell`。
- 本质：用 counterCell 数组**分散并发场景下对单个成员变量的竞争压力**，提高并发度——这就是 `LongAdder` 的思想。

> 相关：[[Java 11 - Set与Map]]、[[Java 14 - HashMap 源码解析]]、[[Java 16 - 锁与并发工具]]、[[Java 29 - Synchronized 关键字详解]]

---

## 五、Java 中 ConcurrentHashMap 的 get 方法是否需要加锁？

**回答重点**：

- **不需要加锁**。通过 `volatile` 关键字，`ConcurrentHashMap` 能确保 `get` 方法的线程安全——即使在写入发生时，读取线程仍能获得最新数据，不会引发并发问题。
- 具体是通过 `Unsafe#getXXXVolatile` 以及用 `volatile` 修饰节点的 `val`、`next` 指针来实现的。

### 写时加锁

写操作（`put`、`remove`）需要加锁，以保证写入时的线程安全与一致性；而 `get` 操作不需要锁。这样 `ConcurrentHashMap` 实现了**高效的读写分离**——读操作不阻塞写操作，从而提高并发性能。

### get 方法源码分析

- 主要定位逻辑在这一行：`e = tabAt(tab, (n - 1) & h)) != null`。
- `tabAt` 内部使用的就是 `Unsafe#getObjectVolatile` 来保证可见性。
- `getObjectVolatile` 实际是一个 `native` 本地方法，通过 JNI（Java Native Interface）调用底层 C++ 实现；其原理是根据对象的起始地址和字段偏移量直接从内存读取字段值，再通过**内存屏障**确保该读取具有 `volatile` 语义（读操作前后各插入一个读屏障 load barrier，保证字段值不被 CPU 缓存）。
- 因此不需加锁：利用 `Unsafe` 获取元素，再对比 hash 值与 key 即可得到 value（即普通 map 的 get 流程）。
- `Node` 节点内的 `val` 和 `next` 指针同样被 `volatile` 修饰，也能保证可见性。
- 综上，无论是 hash 映射到数组中的具体 `node`，还是 hash 冲突时借助 `next` 指针遍历链表，或是定位后再获取 `val`，这几个关键点都能保证可见性——因此不需要加锁。

### Unsafe 类

`Unsafe` 是 Java 提供的一个内部类，用于执行不安全操作，提供**直接操作内存和线程的能力**。关键功能：

- **直接内存访问**：允许直接分配、释放、读写内存。
- **对象操作**：允许直接操作对象字段（设置或获取字段值）。
- **线程操作**：包括暂停和恢复线程、管理锁等。
- **CAS 操作**：提供 compare-and-swap，支持原子性更新。

> 相关：[[Java 07 - 并发三大根源：可见性、原子性、有序性]]、[[Java 14 - HashMap 源码解析]]、[[Java 16 - 锁与并发工具]]

---

## 六、Java 中 HashMap 的扩容机制是怎样的？

**回答重点**：

- 扩容基于**负载因子（load factor）**决定：默认 `0.75`，当已存储元素数量超过当前容量的 75% 时触发扩容。
- 例如初始容量 16、负载因子 0.75，则扩容阈值为 `16 × 0.75 = 12`，当存入第 13 个元素时就触发扩容。
- 触发扩容时，容量扩大为当前容量的**两倍**（16 → 32 → 64…）。
- 扩容时需要**重新计算所有元素的哈希值并重新分配到新的哈希桶**，这个过程称为 **rehashing**。

### rehashing 细节

直觉上，每个元素应重新 hash、逐个搬迁过去——JDK 1.7 就是这样实现的。JDK 1.8 在此做了优化，关键点在于**数组长度是 2 的次方，且扩容为 2 倍**。

- 定位下标用 `(数组长度-1) & hash`。举例：长度 16 → `16-1=15，二进制 001111`；长度 32 → `32-1=31，二进制 011111`。二者差别只在倒数第 5 位多了一个 1。
- 因此重点就在 key 的 hash 值**从右往左数第五位是否为 1**：为 1 说明需搬迁到新位置，新下标 = 原下标 + 16（原数组大小）；为 0 说明吃不到新数组长度的高位，仍留在原位、不迁移。
- 这也意味着链表数据的搬迁是一次性算完再整批搬运——扩容时节点下标**只有「原位置」或「原位置 + 老数组长度」两种可能**，不存在第三种选择。

**总结**：

- 扩容发生时，`HashMap` 并非简单地把元素复制到新数组；每个元素的哈希会按新的数组容量重新参与下标计算，存储位置会发生变化。
- Java 8 之后的扩容不需要每个节点重新 hash 算下标，因为元素的新位置只与「高位」有关，通过与老数组长度做 `&` 运算判断是否为 0 即可定位新下标，因此链表中的元素可能只需部分移动，这一优化减少了扩容时的计算开销。

### 扩容的考虑

- 每次扩容都要遍历当前所有元素、重新计算哈希并移动它们，因此扩容是比较耗时的操作；频繁扩容会明显拖累整体性能。
- **优化策略**：如果能预估 `HashMap` 大概会存多少数据，可在创建时就指定一个较大的初始容量，以减少扩容次数。例如要存 100 万个元素，可直接设置 `1024 × 1024` 的初始容量，避免多次扩容。

> 相关：[[Java 11 - Set与Map]]、[[Java 14 - HashMap 源码解析]]

---

## 七、Java 中 ReentrantLock 的实现原理是什么？

**回答重点**：

- `ReentrantLock` 本质是**基于 AQS 实现的可重入锁**，支持**公平**和**非公平**两种获取方式。
- 内部依赖一个 `state` 变量 + 两个等待队列：**同步队列**（双向链表）与**等待队列**（条件队列，单向链表）。
- 线程通过 **CAS 修改 `state`** 来争抢锁；争抢失败则进入同步队列排队等待。
- 当 `condition` 条件不满足时，线程进入等待队列等待。
- **公平锁与非公平锁的区别**：获取锁时，公平锁是「加入同步队列尾部排队」，非公平锁是「直接尝试 CAS 争抢」。

### CAS

CAS（Compare-And-Swap，比较并交换）是一种乐观锁原子操作：比较内存当前值是否等于预期值，相等才写入新值，整个过程由 CPU 指令保证原子性。它是 `ReentrantLock`、`AtomicInteger` 等并发组件的基础。

### 自旋锁

自旋锁（Spinlock）是一种**轻量级**锁机制：线程获取锁失败时不立即阻塞，而是在循环中反复尝试获取，直到成功。它避免了线程上下文切换开销，**适用于锁等待时间较短的场景**。

```java
public class SpinLock {
    private final AtomicBoolean lock = new AtomicBoolean(false);

    public void lock() {
        while (!lock.compareAndSet(false, true)) {
            // 自旋等待
        }
    }

    public void unlock() {
        lock.set(false);
    }
}
```

缺点主要有两点：

- **锁饥饿问题**：高并发场景下，可能存在某个线程一直 CAS 失败，始终抢不到锁。
- **性能问题**：多核处理器对同一变量高并发 CAS，会导致**总线风暴**问题。

### CLH 自旋锁

针对自旋锁的问题，演进出基于队列的自旋锁 **CLH**（Craig, Landin, and Hagersten），适用于多处理器环境下的高并发场景。

- 原理：维护一个**隐式队列**，使线程在等待锁时**自旋在本地变量**上，从而减少对共享变量的争用和缓存一致性流量。
- 线程按序排队争抢锁，每个线程不再 CAS 争抢同一个变量，而是**自旋判断其前驱线程的状态**；前驱释放锁后，后续线程即可抢锁。
- 优点：排队按序争抢解决了**锁饥饿**；CAS 自旋监听前驱状态避免了**总线风暴**。
- 缺点：自旋期间线程一直占用 CPU，仅适用于锁等待时间较短的场景。
- 「隐式」的含义：线程之间并没有真正用指针连接，而是用 `AtomicReference + ThreadLocal` 实现隐式关联。

```java
public class CLHLock {
    private static class CLHNode {
        volatile boolean isLocked = true; // 默认加锁状态
    }

    private final ThreadLocal<CLHNode> currentNode;
    private final ThreadLocal<CLHNode> predecessorNode;
    private final AtomicReference<CLHNode> tail;

    public CLHLock() {
        this.currentNode = ThreadLocal.withInitial(CLHNode::new);
        this.predecessorNode = new ThreadLocal<>();
        this.tail = new AtomicReference<>(new CLHNode());
    }

    public void lock() {
        CLHNode node = currentNode.get();
        CLHNode pred = tail.getAndSet(node);
        predecessorNode.set(pred);

        // 自旋等待前驱节点释放锁
        while (pred.isLocked) {
        }
    }

    public void unlock() {
        CLHNode node = currentNode.get();
        node.isLocked = false; // 释放锁
        currentNode.set(predecessorNode.get()); // 回收当前节点
    }
}
```

### AQS 对 CLH 的改造

- 因为 CLH 的自旋会占用 CPU，**AQS 把「自旋等待前驱节点」改成了「阻塞线程」**。
- 后续线程阻塞后无法主动发现前驱已释放锁，因此**前驱线程需显式通知后续线程**——这正是 AQS 需要维护**显式双向队列**的原因（前驱要能找到后继）。
- 若前驱线程等待超时或主动取消，需从队列中移除，后面的线程需要「顶」上来。

AQS 中线程的等待状态：

| 状态 | 值 | 含义 |
|------|----|------|
| 默认 | 0 | 初始化时的默认值 |
| CANCELLED | 1 | 由于超时、中断或其他原因，该节点被取消 |
| SIGNAL | -1 | 该节点准备就绪，正常等待资源 |
| CONDITION | -2 | 该节点位于条件等待队列中 |
| PROPAGATE | -3 | SHARED 情况下有效，将 releaseShared 动作传播到其他节点 |

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 07 - 并发三大根源：可见性、原子性、有序性]]

---

## 八、Java 中 volatile 关键字的作用是什么？

**回答重点**：`volatile` 主要保证变量的**可见性**和**禁止指令重排优化**。

1）**可见性（Visibility）**：当一个线程修改了 `volatile` 变量的值，新值会立即刷新到主内存，其他线程读取该变量时可立即获得最新值，从而避免线程间因缓存一致性问题导致的「看见旧值」现象。

2）**禁止指令重排序（Ordering）**：`volatile` 通过内存屏障禁止特定情况下的指令重排序，保证程序执行顺序符合预期。对 `volatile` 变量的**写**操作会在其**前面**插入一个 `StoreStore` 屏障，对 `volatile` 变量的**读**操作会在其**后面**插入一个 `LoadLoad` 屏障，确保多线程环境下某些代码块执行顺序可预测。

### 可见性问题与 volatile 的解决

Java 多线程环境中，每个线程都有自己的工作内存（CPU 缓存），会从主内存读取变量副本再操作，因此线程 A 修改某个变量后，线程 B 不一定能立即看到。`volatile` 通过强制线程直接从主内存读取或写入变量，解决了可见性问题。

示例：没有 `volatile` 时，一个线程可能永远不会看到另一个线程对共享变量的修改。

```java
private static boolean flag = false;

public static void main(String[] args) {
    new Thread(() -> {
        while (!flag) {
            // do something
        }
        System.out.println("Thread terminated.");
    }).start();

    try {
        Thread.sleep(1000);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }

    flag = true; // 没有 volatile, 这个改变对其他线程不可见
}
```

如果把 `flag` 声明为 `volatile`，线程 A 修改后线程 B 能立即看到修改并终止循环。

### 禁止指令重排序与双重检查锁定

Java 编译器和 CPU 为了优化性能可能对指令重排序。单线程程序一般不受影响，但多线程环境下重排序可能导致意外结果。经典场景是单例模式中的**双重检查锁定（Double-Checked Locking）**：

```java
public class Singleton {
    private static volatile Singleton instance;

    private Singleton() {}

    public static Singleton getInstance() {
        if (instance == null) {
            synchronized (Singleton.class) {
                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }
        return instance;
    }
}
```

上例中若不使用 `volatile`，指令重排序可能导致 `instance` 在其构造函数完成之前就被返回，使其他线程访问到一个未初始化完全的对象。

### volatile 不能保证操作的原子性

`volatile` 保证了可见性和有序性，但**不能保证操作的原子性**。原子性意味着一个操作不可分割、不能被中断。典型例子是 `i++`，它实际分为「读取 `i` 的值 → 递增 → 写回」三个步骤；若多个线程同时执行 `i++`，每个线程都可能读到相同的初始值，最终结果可能不正确。

```java
private static volatile int count = 0;

public static void main(String[] args) {
    for (int i = 0; i < 1000; i++) {
        new Thread(() -> count++).start();
    }
    System.out.println(count); // 结果可能不为 1000
}
```

解决方式是使用 `AtomicInteger` 或者 `synchronized` 块。

### volatile 与 synchronized 的对比

- **性能**：`volatile` 是轻量级的同步机制，开销较小，但只能用于变量的可见性和禁止重排序，无法实现复杂的同步逻辑；`synchronized` 是重量级同步机制，可保证代码块的原子性和可见性，但开销较大。
- **使用场景**：`volatile` 适用于简单的状态标志、标记等场景；`synchronized` 更适合复杂的临界区保护、需要确保多个操作原子性的场景。

### Java 内存模型（JMM）与 volatile

Java 内存模型（Java Memory Model, JMM）定义了多线程环境下共享变量的可见性和指令重排序规则。`volatile` 是 JMM 的关键组成部分，提供了一种简化方式来实现线程间的内存可见性。JMM 中规定：

- 对一个 `volatile` 变量的**写**操作，happens-before 于每一个后续对该 `volatile` 变量的**读**操作。
- `volatile` 变量的操作不会与其他内存操作进行重排序。

> 相关：[[Java 07 - 并发三大根源：可见性、原子性、有序性]]、[[Java 16 - 锁与并发工具]]

---

## 九、Java 中什么情况会导致死锁？如何避免？

**回答重点**：这是操作系统中的经典理论——死锁的发生必须**同时满足**以下四个条件，称为「死锁的必要条件」：

1. **互斥条件**：每个资源只能被一个线程占用。
2. **占有和等待**：线程在持有至少一个资源的同时，等待获取其他资源。
3. **不可抢占**：线程所获得的资源在未使用完毕之前不能被其他线程抢占。
4. **循环等待**：多个线程形成一种头尾相接的循环等待资源关系。

只要**打破上述任意一个条件**，就能避免死锁的发生。

### 避免死锁的方法

1. **按序申请资源**：确保所有线程在获取多个锁时，按照相同的顺序获取锁。
2. **尽量减少锁的范围**：将锁的粒度尽可能缩小，减少持有锁的时间（可通过拆分锁或使用更细粒度的锁实现）。
3. **使用尝试锁机制**：使用 `ReentrantLock` 的 `tryLock` 方法，在一段时间内尝试获取锁，若无法获取则放弃或采取其他措施，避免死锁。
4. **设置超时等待时间**：为锁操作设置超时，防止线程无限期地等待锁。
5. **避免嵌套锁**：尽量避免在一个锁的代码块中再次尝试获取另一个锁。

> 相关：[[Java 16 - 锁与并发工具]]

---

## 十、Java 中有哪些垃圾回收算法？

**回答重点**：基础算法有三类——**标记-清除**（Mark-Sweep）、**标记-整理**（Mark-Compact）、**复制**（Copying）。现代 JVM 按分代思想组合使用：新生代对象「朝生夕死」，用复制算法以极低的存活复制成本换无碎片；老年代存活率高，用标记-清除 / 标记-整理。

### 标记-清除（Mark-Sweep）

两个阶段：

- **标记阶段（tracing）**：从 GC Roots（栈、寄存器、全局变量等）出发遍历对象图，标记每一个可达对象。
- **清除阶段**：扫描堆，把未被标记的对象当作垃圾回收。

**优点**：实现简单，能处理堆中的所有对象。

**缺点**：清除阶段不移动、不整理内存，空闲空间通常以**空闲链表（双向链表）**管理，于是产生**内存碎片**——总内存明明够，却因为找不到足够大的连续块而申请失败；分配时还要遍历链表找合适的内存块，比较耗时。

针对缺点的两种工程改进：

- **多空闲链表**：按内存块大小拆成多个链表（如大分块链表、小分块链表，还可继续细分），申请时按所需大小查对应链表，加快分配。
- **位图标记法**：把标记位放在对象头里对**写时复制**不兼容——每次 GC 都要改对象，而 fork 出来的进程共享同一块内存，改对象必然触发复制。改用位图后，堆内存按块划分，由「对象地址 − 堆起始地址」算出对象落在第几块，把位图中对应 bit 置 1 即可标记。位图还能加速清除阶段的遍历：不必逐对象扫描堆找标记位。

但无论标记位放对象头还是用位图，**碎片问题都解决不了**，于是引出标记-复制与标记-整理。

### 标记-复制（Copying）

堆分成 From、To 两块，对象只在 From 上分配。发生 GC 时找出所有存活对象复制到 To，再整体回收 From 区，最后两块交换角色（To 变 From，From 变 To）。

**优点**：

- 存活对象被紧凑排列，**不产生内存碎片**；
- 不需要空闲链表，**移动指针即可分配**，效率很高；
- **CPU 缓存亲和性好**：从根开始深度优先遍历，把关联对象找齐并分配在相近地址，依据局部性原理，一个对象被加载时其引用对象往往同时进缓存，访问直接命中。

**缺点**：

- 对象只能在 From 区分配，而 From 只有堆的一半，**内存利用率 50%**；
- 存活对象多时**复制压力大**，速度会慢；
- 需要移动对象，**不适用于保守式 GC**；
- 深度优先即递归调用，有栈溢出风险 → **Cheney 算法**改用迭代的广度优先遍历规避。

### 标记-整理（Mark-Compact）

思路与复制相近，区别是不分区：在同一空间内直接把存活对象向边界整理。

**优点**：无内存碎片，且不必像复制算法那样预留一半空间，**内存利用率更高**。

**缺点**：同一空间内既要标记又要移动，需对堆做多次搜索，整体耗时更长；堆越大，这个代价越突出。

### 分代收集中的落地

新生代采用复制算法：划分为 **Eden + 两个 Survivor（S0、S1）**。对象默认在 Eden 分配，Minor GC 时把 Eden 与当前 Survivor 中的存活对象复制到另一个空闲 Survivor，两块 Survivor 交替承担 From / To 角色。这样只付出很小一块空闲区域（而非半个堆），就拿到了复制算法「无碎片 + 指针分配」的全部好处——这也是「为何新生代要分 S0/S1/Eden」的根因。

> 相关：[[Java 17 - JVM内存模型与GC]]、[[Java 56 - OOM 内存溢出排查实战]]

---

## 十一、Java 中有哪些集合类？请简单介绍

**回答重点**：Java 集合分两大体系——**Collection**（单元素集合，下分 List / Set / Queue）与 **Map**（键值对，通过 key 找 value）。这是面试开场的暖场题，先讲清体系骨架，再挑自己熟悉的实现类深入，面试官会顺着你给的点继续挖。

### List（有序、可重复）

| 实现类 | 底层结构 | 特点 |
|---|---|---|
| `ArrayList` | 动态数组 | 随机访问快，中间插入/删除慢（要搬移元素） |
| `LinkedList` | 双向链表 | 插入/删除快，查询慢 |
| `Vector` | 动态数组 | 线程安全（方法加 `synchronized`），开销大，已不推荐 |

### Set（不重复）

| 实现类 | 底层结构 | 特点 |
|---|---|---|
| `HashSet` | 哈希表 | 元素无序，不允许重复 |
| `LinkedHashSet` | 链表 + 哈希表 | 维护**插入顺序**，不允许重复 |
| `TreeSet` | 红黑树 | 元素**有序**（自然顺序或 Comparator），不允许重复 |

⚠️ 网上「Set 是无序集合」的说法不准确——有序与否要看具体实现类：`LinkedHashSet` 保插入序，`TreeSet` 保持排序。

### Queue

| 实现类 | 底层结构 | 特点 |
|---|---|---|
| `PriorityQueue` | 优先级堆 | 按自然顺序或指定 Comparator 出队 |
| `LinkedList` | 双向链表 | 同时实现 `Deque`，可作 FIFO 队列使用 |

### Map（键值对，键不重复）

| 实现类 | 底层结构 | 特点 |
|---|---|---|
| `HashMap` | 哈希表 | 键无序，允许一个 `null` 键与多个 `null` 值 |
| `LinkedHashMap` | 链表 + 哈希表 | 维护插入顺序（也可配 `accessOrder` 做 LRU） |
| `TreeMap` | 红黑树 | 按键有序 |
| `Hashtable` | 哈希表 | 线程安全（全局锁），不允许 `null` 键/值 |
| `ConcurrentHashMap` | 哈希表 | 线程安全，适合高并发，不允许 `null` 键/值 |

### 记忆抓手

按「接口 → 抽象类 → 实现类」的三层框架记忆（`AbstractList` / `AbstractSet` / `AbstractMap` 等），既方便串起整个类图，也能顺带引出「接口与抽象类的区别」这一延伸考点。

> 相关：[[Java 10 - Collection与List]]、[[Java 11 - Set与Map]]、[[Java 14 - HashMap 源码解析]]

---

## 十二、Java 中的 HashMap 和 Hashtable 有什么区别？

**回答重点**：`Hashtable` 是 JDK 1.0 的遗留类，方法级 `synchronized` 保证线程安全但性能差；`HashMap` 非线程安全但单线程性能好，且允许一个 `null` 键与多个 `null` 值。需要线程安全时用 `ConcurrentHashMap`，而不是 `Hashtable`。

| 维度 | HashMap | Hashtable |
|---|---|---|
| **线程安全性** | 非线程安全，多线程下可能数据不一致 | 线程安全，大部分方法用 `synchronized` 同步 |
| **性能** | 无同步开销，单线程优于 Hashtable | 全局锁使不同操作也被串行化，性能低 |
| **null 支持** | 允许 1 个 `null` 键、多个 `null` 值 | 不允许 `null` 键/值，插入即抛 `NullPointerException` |
| **继承结构** | 继承 `AbstractMap`，实现 `Map` | 继承已废弃的 `Dictionary`，后来才实现 `Map`；Java 2 之后逐渐被 HashMap 取代，不推荐使用 |
| **迭代器** | **快速失败**（fail-fast）的 `Iterator`，迭代中结构性修改抛 `ConcurrentModificationException` | **弱一致性**的 `Enumerator`，迭代中修改不抛异常（但同样不建议这么用） |

### 线程安全场景的正确选择

`ConcurrentHashMap` 是 `Hashtable` 的替代方案：

- `Hashtable` 用一把全局锁，读读、读写、写写全部互斥；
- `ConcurrentHashMap` 读操作无锁化，写操作只锁局部（JDK 1.7 分段锁 → JDK 1.8 桶级 CAS + synchronized），高并发下吞吐远高于 `Hashtable`；
- 代价是不支持 `null` 键/值——因为 `get` 返回 `null` 时无法区分「键不存在」与「值就是 null」，无锁读场景下这个歧义无法用 `containsKey` 补救。

> 相关：[[Java 14 - HashMap 源码解析]]、[[Java 11 - Set与Map]]、[[Java 13 - fail-fast机制]]

---

## 十三、Java 中的 LinkedHashMap 是什么？

**回答重点**：`LinkedHashMap` 继承 `HashMap`，在哈希表之上额外用一条**双向链表**串起所有节点，因此既能 O(1) 定位，又能保证遍历顺序：默认是**插入顺序**，构造时传 `accessOrder = true` 则变成**访问顺序**（即 LRU 语义）。典型用途是「需要保持插入顺序的 Map」和「本地 LRU 缓存」。

### 扩展知识

**1）实现方式：HashMap 的槽位 + 一条链表**

`LinkedHashMap.Entry` 继承 `HashMap.Node`，只多了两个指针 `before` / `after`，把所有 Entry 按顺序串成双向链表。哈希桶仍然是原来的数组 + 链表/红黑树结构，所以查找逻辑完全复用父类，链表只是「额外的顺序视图」。

内部成员 `accessOrder` 默认 `false`：

| accessOrder | 链表顺序 | 命中节点后的动作 |
|---|---|---|
| `false`（默认） | 插入顺序 | 位置不变 |
| `true` | 访问顺序 | 把该节点移到链表尾部（标记为最近访问） |

**2）靠三个回调钩子接入父类流程**

`HashMap` 在关键位置预埋了三个空实现的模板方法，`LinkedHashMap` 重写它们来维护链表：

```java
void afterNodeAccess(Node<K,V> p);      // get / put 命中已有节点后
void afterNodeInsertion(boolean evict); // 插入新节点之后
void afterNodeRemoval(Node<K,V> p);     // 删除节点之后
```

好处是 `putVal` / `getNode` / `removeNode` 一行不用改——父类只管哈希表，子类只管顺序，典型的模板方法模式。

**3）用 `removeEldestEntry` 做 LRU**

`afterNodeInsertion` 里会调用 `removeEldestEntry(eldest)`，默认实现返回 `false`（永不淘汰）。子类重写它即可在插入时淘汰链表头部最久未使用的节点：

```java
private static final class LRUCache<K, V> extends LinkedHashMap<K, V> {
    private final int maxCacheSize;

    LRUCache(int initialCapacity, int maxCacheSize) {
        super(initialCapacity, 0.75F, true); // accessOrder = true
        this.maxCacheSize = maxCacheSize;
    }

    @Override
    protected boolean removeEldestEntry(Map.Entry<K, V> eldest) {
        return this.size() > this.maxCacheSize;
    }
}
```

要点：`accessOrder` 必须为 `true`，否则链表头是「最早插入」而不是「最久未访问」，LRU 会退化成 FIFO。注意 `LinkedHashMap` 本身**不是线程安全**的，并发场景需外部加锁或换 `Collections.synchronizedMap` / Caffeine。

**4）手写 LRU（经典笔试题）**

面试常要求不用 `LinkedHashMap` 实现 O(1) 的 LRU：`HashMap` 负责 key → 节点定位，自定义双向链表负责顺序，`head` / `tail` 用哨兵节点省掉边界判断。

```java
class LRUCache<K, V> {
    class Node {
        K key; V value; Node prev, next;
        Node() {}
        Node(K key, V value) { this.key = key; this.value = value; }
    }

    private final int capacity;
    private final Map<K, Node> map = new HashMap<>();
    private final Node head = new Node(), tail = new Node();

    LRUCache(int capacity) {
        this.capacity = capacity;
        head.next = tail;
        tail.prev = head;
    }

    public V get(K key) {
        Node node = map.get(key);
        if (node == null) return null;
        moveToHead(node);
        return node.value;
    }

    public void put(K key, V value) {
        Node node = map.get(key);
        if (node != null) {
            node.value = value;
            moveToHead(node);
            return;
        }
        if (map.size() >= capacity) {
            map.remove(tail.prev.key);   // 淘汰最久未用
            unlink(tail.prev);
        }
        Node newNode = new Node(key, value);
        map.put(key, newNode);
        addToHead(newNode);
    }

    private void moveToHead(Node node) { unlink(node); addToHead(node); }

    private void addToHead(Node node) {
        node.prev = head;
        node.next = head.next;
        head.next.prev = node;
        head.next = node;
    }

    private void unlink(Node node) {
        node.prev.next = node.next;
        node.next.prev = node.prev;
    }
}
```

`get` 与 `put` 都是 O(1)；`head` 侧是最近使用、`tail.prev` 是最久未用。

> 相关：[[Java 14 - HashMap 源码解析]]、[[Java 11 - Set与Map]]、[[Java 13 - fail-fast机制]]

---

## 十四、Java 中的序列化和反序列化是什么？

**回答重点**：**序列化**是把对象转换成字节序列，使其能落盘、跨网络传输或进缓存；**反序列化**是把字节序列还原成对象。Java 原生方案要求类实现 `Serializable` 标记接口，并用 `ObjectOutputStream` / `ObjectInputStream` 读写。

### 扩展知识

**1）为什么必须"压扁"对象**

JVM 里的对象是"立体"的：字段里存的是指向堆内存地址的引用（比如 `0x1234`），对象之间还可能有循环引用。这些地址只在当前进程有效，直接传给另一台机器毫无意义。序列化的本质就是把**对象图**转成自包含的字节序列（记录类型信息 + 字段值 + 引用关系），接收端据此重建一份等价的图结构。

**2）关键 API 与约束**

| 角色 | 说明 |
|---|---|
| `java.io.Serializable` | 空标记接口，无任何方法，仅用于让序列化机制放行 |
| `ObjectOutputStream.writeObject(obj)` | 序列化入口 |
| `ObjectInputStream.readObject()` | 反序列化入口 |
| `transient` | 修饰的字段不参与序列化，反序列化后为默认值（`0` / `null` / `false`） |
| `serialVersionUID` | 版本一致性校验用的"类指纹" |

`Serializable` 只是标记：`ObjectOutputStream` 检查到类未实现该接口时直接抛 `NotSerializableException`；`String`、数组、枚举等有各自的内置处理分支，不需要走普通对象路径。

**3）`serialVersionUID` 的真实作用**

```java
private static final long serialVersionUID = 1L;
```

- 数字本身没有业务含义，`1L` 和 IDE 生成的随机长整型等价，只要**序列化端与反序列化端一致**即可；
- 不显式声明时，编译器根据类名、字段、方法签名等信息自动生成一个指纹；
- 因此「先序列化存盘 → 改了类结构（加字段、改签名）→ 再反序列化」会因指纹变化抛 `InvalidClassException`。显式固定 `serialVersionUID` 就能让新增/删除字段保持兼容（新增字段读出来是默认值）。

**4）静态变量不参与序列化**

序列化保存的是**对象实例状态**，`static` 字段属于类而非对象，不会写入字节流；反序列化后读到的静态变量值是当前 JVM 中该类的实时值，而非当初序列化时的值。

**5）性能与替代方案**

JDK 原生序列化体积大（带完整类描述）、速度慢、只适用于 Java 生态，不适合大规模分布式调用。常见替代：

- **Protobuf**：IDL 定义 schema + 二进制编码，跨语言、体积小、性能高，gRPC 默认；
- **Kryo / Hessian**：面向 Java 的高性能二进制序列化，RPC 框架常用；
- **JSON（Jackson / Fastjson2）**：可读性好，跨语言，适合对外接口与调试场景。

**6）安全风险**

反序列化会依据字节流里的类描述**自动加载并构造对象**，攻击者可构造 gadget chain 在 `readObject` 阶段触发任意代码执行——这就是 Java 反序列化漏洞（Fastjson、Shiro、WebLogic 等历史上的 RCE 多源于此）。防护要点：

- 绝不对不可信输入做原生反序列化，优先用 JSON/Protobuf 这类数据契约明确的格式；
- 必须用时设置白名单：JDK 9+ 的 `ObjectInputFilter`（`jdk.serialFilter`）限制可反序列化的类；
- 敏感字段用 `transient` 排除，避免密码等随字节流外泄。

> 相关：[[Java 14 - NIO与序列化]]、[[Java 13 - File与IO流]]

---

## 十五、Java 并发库中提供了哪些线程池实现？它们有什么区别？

**回答重点**：`Executors` 工具类提供 5 种开箱即用的线程池：`FixedThreadPool`、`CachedThreadPool`、`SingleThreadExecutor`、`ScheduledThreadPool`、`WorkStealingPool`。它们的差别本质上是**核心线程数、最大线程数、任务队列类型、空闲回收策略**这四项参数的组合不同。

| 实现 | 线程数 | 任务队列 | 核心特点 | 适用场景 |
|---|---|---|---|---|
| `FixedThreadPool` | 固定 n（core = max = n） | 无界 `LinkedBlockingQueue` | 线程复用，超出并发数的任务排队等待 | 负载稳定、需要限制并发线程数 |
| `CachedThreadPool` | 0 ~ `Integer.MAX_VALUE` | `SynchronousQueue` | 空闲线程 60s 回收，无可用线程就新建 | 大量短耗时任务、任务量波动大 |
| `SingleThreadExecutor` | 1 | 无界 `LinkedBlockingQueue` | 单线程串行执行，天然保证提交顺序 | 需要严格顺序执行的任务 |
| `ScheduledThreadPool` | 指定 core，max 无上限 | `DelayedWorkQueue` | 支持延时 / 固定频率 / 固定间隔调度 | 定时任务、周期任务 |
| `WorkStealingPool`（JDK 8+） | 默认 CPU 核数个并行度 | 每线程一个双端队列 | 空闲线程从其他队列尾部"窃取"任务，自动负载均衡 | 大量小任务、递归分治（底层是 `ForkJoinPool`） |

### 扩展知识

**1）五个池子其实是同一套骨架**

除 `WorkStealingPool`（`ForkJoinPool`）外，其余四种最终都是 `ThreadPoolExecutor`，只是构造参数不同：

```java
// FixedThreadPool
new ThreadPoolExecutor(n, n, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>());
// CachedThreadPool
new ThreadPoolExecutor(0, Integer.MAX_VALUE, 60L, TimeUnit.SECONDS, new SynchronousQueue<>());
// SingleThreadExecutor（core = max = 1）
new ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<>());
// ScheduledThreadPool
new ScheduledThreadPoolExecutor(corePoolSize);  // 内部用 DelayedWorkQueue
```

理解这一点，答题时就能从"背五个名字"升级为"讲一套调度模型"。

**2）任务提交后的流转顺序**

```
核心线程未满 → 创建核心线程执行
核心线程已满 → 任务入队等待
队列已满     → 创建非核心线程（直到 maximumPoolSize）
已达最大线程 → 交给拒绝策略
```

注意 `CachedThreadPool` 的 `SynchronousQueue` 不存储元素，所以"入队"必然失败，直接走"创建非核心线程"分支——这就是它"来一个任务开一个线程"的原因。

**3）生产环境不要直接用 `Executors`**

《阿里巴巴 Java 开发手册》明确禁止用 `Executors` 创建线程池，根因是**无界**：

- `FixedThreadPool` / `SingleThreadExecutor` 用无界 `LinkedBlockingQueue`，任务积压无上限 → `OutOfMemoryError: Java heap space`；
- `CachedThreadPool` / `ScheduledThreadPool` 的 `maximumPoolSize` 为 `Integer.MAX_VALUE`，线程无上限创建 → `OutOfMemoryError: unable to create new native thread`。

推荐显式 `new ThreadPoolExecutor(...)`，把七个参数都写清楚：

```java
ThreadPoolExecutor pool = new ThreadPoolExecutor(
    8,                              // corePoolSize
    16,                             // maximumPoolSize
    60L, TimeUnit.SECONDS,          // keepAliveTime
    new ArrayBlockingQueue<>(200),  // 有界队列，兜住背压
    new ThreadFactory() {           // 自定义线程名，便于排查
        private final AtomicInteger seq = new AtomicInteger(1);
        public Thread newThread(Runnable r) {
            return new Thread(r, "order-pool-" + seq.getAndIncrement());
        }
    },
    new ThreadPoolExecutor.CallerRunsPolicy()  // 拒绝策略：回退给调用线程
);
```

**4）线程数怎么估**

- **CPU 密集型**：`N + 1`（N 为核数），再多只会增加上下文切换；
- **IO 密集型**：`N × (1 + 平均等待时间 / 平均计算时间)`，或按并发连接数 × 单任务耗时 / 目标 QPS 反推；
- 最终以压测结果为准，不要迷信公式。

**5）运行期的四个细节**

- **默认不预创建线程**：`prestartAllCoreThreads` 默认 `false`，任务提交后才按需 `addWorker` 创建线程。想让核心线程提前就位（避免首波请求的开销抖动），可调用 `prestartAllCoreThreads()` 或 `prestartCoreThread()`，也可在构造前 `setPrestartAllCoreThreads(true)`。
- **核心线程和非核心线程没有任何标识区分**：`Worker` 里并无「是否核心」的标记，所谓核心线程只是「存活数量 ≤ corePoolSize」这层语义。因此 `allowCoreThreadTimeOut(true)` 后核心线程同样会被回收，线程池最小线程数退化为 0；默认 `false` 时 `processWorkerExit` 只销毁超出 `corePoolSize` 的那部分 worker。
- **空闲回收的统一入口**：worker 取任务时用 `getTask()` 的 `poll(keepAliveTime, unit)`，超时返回 `null` 后进入 `processWorkerExit`，由 `workerCount > corePoolSize || allowCoreThreadTimeOut` 决定是否真的移除该 worker。
- **为什么先入队而不是直接加线程**：创建线程要占用栈空间（默认保留 1MB 量级）和调度开销，而队列里放任务只是堆上的引用。先用队列吸收突发流量，队列都满了才说明是持续过载，此时付线程成本才划算。`SynchronousQueue` 不存储元素 → 入队必然失败 → `CachedThreadPool` 才表现为「来一个任务开一个线程」。

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 15 - 线程基础]]、[[Java 51 - 并发编程学什么（学习框架）]]

---

## 十六、Java 的 synchronized 是怎么实现的？

**回答重点**：`synchronized` 依赖 JVM 的 **Monitor（监视器锁）** 与**对象头 Mark Word** 实现。修饰方法时在方法访问标志上加 `ACC_SYNCHRONIZED`（0x0020），修饰代码块时由编译器在同步块前后插入 `monitorenter` / `monitorexit` 字节码。二者本质相同：都要先拿到锁对象关联的 monitor 所有权才能进入临界区。

### 扩展知识

**1）对象内存布局与 Mark Word**

对象 = 对象头 + 实例数据 + 对齐填充；对象头 = Mark Word + Klass Pointer（+ 数组长度，仅数组有）。Mark Word 在 64 位下复用同一块内存表达不同状态，这是锁实现的核心：

| 锁状态 | Mark Word 内容 | 锁标志位 |
|---|---|---|
| 无锁 | hashCode(31) + 分代年龄(4) + 偏向位(1) | `01` |
| 偏向锁 | 线程 ID(54) + epoch(2) + 分代年龄 + 偏向位 `1` | `101` |
| 轻量级锁 | 指向栈帧 Lock Record 的指针(62) | `00` |
| 重量级锁 | 指向 `ObjectMonitor` 的指针(62) | `10` |
| GC 标记 | 空 | `11` |

**2）锁升级路径**

无锁 → 偏向锁 → 轻量级锁 → 重量级锁。HotSpot 中锁**只能升级不能降级**（偏向锁被撤销后即回到无锁/轻量级，不会退回偏向态），所谓「动态升降级」只是状态迁移的通俗说法。

**偏向锁**：第一个线程 CAS 把自己的线程 ID 写进 Mark Word、标志位置 `101`，后续同一线程进入只做「标志位 + 线程 ID + epoch 比对」，无 CAS 开销。另一个线程来竞争时需在**安全点**撤销偏向（遍历该类的实例改 epoch）。批量重偏向阈值 `-XX:BiasedLockingBulkRebiasThreshold`（默认 20），超过 `-XX:BiasedLockingBulkRevokeThreshold`（默认 40）则该类彻底失去偏向能力。**JDK 15 起偏向锁默认禁用（JEP 374）**，因为多核高并发下撤销/重偏向的开销常常盖过收益。

**轻量级锁**：在当前栈帧划出 Lock Record，把对象头 Mark Word 拷进 `displaced header`（dhw），再 CAS 让对象头指向该 Lock Record。重入时新栈帧的 dhw 写 `null`，解锁时据此判断是否重入；解锁用 CAS 把 dhw 换回对象头，失败说明有竞争 → 膨胀为重量级锁。适用场景是「多线程交替而非同时」访问同一把锁，避免系统调用。

**重量级锁**：竞争激烈时膨胀，线程真正阻塞，靠操作系统互斥量（`pthread_mutex_lock`）实现，涉及用户态/内核态切换，开销大。

**3）ObjectMonitor 内部结构（HotSpot C++ 实现）**

| 字段 | 含义 |
|---|---|
| `_owner` | 当前持有锁的线程 |
| `_recursions` | 重入次数 |
| `_cxq` | 单向链表，CAS 竞争的入口队列 |
| `_EntryList` | 双向链表，被唤醒后等待再次争锁的线程 |
| `_WaitSet` | 调用 `wait()` 的线程（条件等待队列） |
| `_count` | 关联的锁计数 |

- **加锁 `ObjectMonitor::enter`**：CAS 把 `_owner` 设为当前线程 → 成功即持锁，`_recursions++` 表示重入；失败则先**自适应自旋**，仍失败就包装成 `ObjectWaiter` 入 `_cxq`，最后 `park()` 阻塞。
- **解锁 `ObjectMonitor::exit`**：`_recursions--`，减到 0 才真正释放 `_owner`，并按 `QMode` 策略从 `_cxq` / `_EntryList` 迁移节点、唤醒等待线程。
- **`wait()`**：线程进 `_WaitSet`，随后调用 `exit` 释放锁；**`notify()`**：从 `_WaitSet` 取节点，按策略放入 `_cxq` 或 `_EntryList` 并唤醒；`notifyAll()` 即循环处理全部。
- **为什么两个等待队列**：`_cxq` 用单向链表 + CAS 扛住高并发入队，`_EntryList` 用双向链表在唤醒时批量搬迁节点，降低 `_cxq` 尾部竞争。

**4）自旋与锁优化**

自旋 = 空转 CPU 等锁，避免「刚阻塞就被唤醒」的无谓开销；自旋次数用**自适应自旋**（依据上一次在该锁上的自旋成功率动态调整）。另外还有：**锁消除**（逃逸分析判定对象不逃逸则去掉加锁）、**锁粗化**（把相邻的多次加解锁合并成一次）。**可重入性**由 `_recursions` 计数保证，取锁 +1、释放 -1，归零才真正释放。

> 相关：[[Java 29 - Synchronized 关键字详解]]、[[Java 16 - 锁与并发工具]]、[[Java 07 - 并发三大根源：可见性、原子性、有序性]]

---

## 十七、Java 的类加载过程是怎样的？

**回答重点**：类加载是把符合格式的二进制流读进内存、解析成可用 Class 对象的过程，分为**加载 → 连接（验证 / 准备 / 解析）→ 初始化**共 5 个阶段。二进制流不限于 `.class` 文件——字节码工具生成、网络传输的流，只要格式合法 JVM 都接受。

### 扩展知识

**1）五个阶段各做什么**

| 阶段 | 动作 |
|---|---|
| 加载 | 通过类的全限定名获取二进制流，转为方法区（JDK 8+ 为元空间）运行时数据结构，并在堆中生成 `Class` 对象作为访问入口 |
| 验证 | 校验字节码格式、元数据语义、字节码指令、符号引用合法性，确保不会危害 JVM |
| 准备 | 为**静态变量**分配内存并赋**零值**（`int` → 0、引用 → null）；`static final` 常量若为编译期常量则已在常量池，此阶段直接赋真值 |
| 解析 | 把常量池中的**符号引用**替换为**直接引用**（可理解为「计划里的代号 A」换成「真实的人」），可延迟到首次使用时进行 |
| 初始化 | 执行类构造器 `<clinit>()`，即静态变量赋代码中的真实值与静态代码块，父类先于子类 |

**2）触发初始化的典型时机**（主动引用）

`new` / 读写静态字段 / 调用静态方法、反射（`Class.forName`）、初始化子类时先初始化父类、含 `main` 方法的主类、`MethodHandle` 解析结果对应的类。

**3）双亲委派模型**

类加载请求先委派给父加载器，父加载器无法完成时才由当前加载器自己加载。好处有二：**避免类重复加载**（同一个类只被加载一次）、**保护核心类库**（自定义的 `java.lang.String` 永远轮不到被加载，防止核心 API 被篡改）。

**4）类加载器层次**

| 加载器 | 职责 |
|---|---|
| Bootstrap ClassLoader | C++ 实现，加载 `JAVA_HOME/lib` 下的核心类（`rt.jar` / `java.base` 等） |
| Extension / Platform ClassLoader | JDK 9 前为 `ExtClassLoader`（`lib/ext`），JDK 9+ 改为 `PlatformClassLoader` |
| Application ClassLoader | 加载 classpath（含自定义类、第三方 jar），默认的 `ClassLoader.getSystemClassLoader()` |
| 自定义 ClassLoader | 继承 `ClassLoader` 重写 `findClass`，用于热部署、加密类、隔离加载 |

**5）打破双亲委派的场景**

- **SPI**：JDBC `DriverManager` 由 Bootstrap 加载，却要加载厂商实现类 → 用线程上下文类加载器 `Thread.currentThread().getContextClassLoader()` 反向委派。
- **Tomcat**：每个 Web 应用一个 `WebAppClassLoader`，优先自己加载应用内的类，实现应用间隔离与热部署。
- **OSGi**：网状委派，按包级别精确控制可见性。

> 相关：[[Java 18 - 类加载机制]]、[[Java 17 - JVM内存模型与GC]]、[[Java 02 - JDK JRE JVM]]

---

## 十八、Java 线程池有哪些拒绝策略？

**回答重点**：`ThreadPoolExecutor` 内置 4 种拒绝策略，在**核心线程已满 + 队列已满 + 线程数达最大值**时触发。默认是 `AbortPolicy`（抛异常）。

| 策略 | 行为 | 适用场景 |
|---|---|---|
| `AbortPolicy`（默认） | 抛 `RejectedExecutionException`，任务丢失 | 必须让调用方感知失败的场景（订单、支付） |
| `CallerRunsPolicy` | 由提交任务的线程自己执行该任务 | 希望反压、减缓提交速度以稳定系统 |
| `DiscardOldestPolicy` | 丢弃队列中最旧的任务，再重新提交当前任务 | 只关心最新数据（实时行情、监控采样） |
| `DiscardPolicy` | 静默丢弃当前任务，不抛异常 | 任务可丢、允许丢失的场景（埋点日志） |

### 扩展知识

**1）自定义拒绝策略**：实现 `RejectedExecutionHandler`，可做日志、落库、降级重排、阻塞提交等。

```java
public class CustomRejectedExecutionHandler implements RejectedExecutionHandler {
    @Override
    public void rejectedExecution(Runnable r, ThreadPoolExecutor executor) {
        System.out.println("Task " + r + " rejected");   // 生产环境应改为日志 + 告警
        // 也可以：降级执行 / 写入 MQ 稍后重试 / 阻塞等待队列有空位
    }
}

ThreadPoolExecutor pool = new ThreadPoolExecutor(
        4, 8, 60L, TimeUnit.SECONDS,
        new ArrayBlockingQueue<>(100),
        Executors.defaultThreadFactory(),
        new CustomRejectedExecutionHandler());
```

**2）三个常见坑**

- **拒绝策略根本不触发**：`Executors.newFixedThreadPool` / `newSingleThreadExecutor` 用的是**无界** `LinkedBlockingQueue`，队列永不满 → 任务无限堆积直到 OOM。生产上应手动 `new ThreadPoolExecutor` 并指定有界队列。
- **`CallerRunsPolicy` 会阻塞提交线程**（如 Tomcat 的 IO 线程），吞吐下降但起到天然限流作用；反之若提交线程也持有锁，可能引发死锁。
- **优先队列下 `DiscardOldestPolicy` 丢的是「优先级最高」的任务**：它 poll 的是队列头部，而 `PriorityBlockingQueue` 头部正是优先级最高的元素，语义与名字相反。

> 相关：[[Java 15 - 线程基础]]、[[Java 16 - 锁与并发工具]]、[[Java 51 - 并发编程学什么（学习框架）]]

---

## 十九、Spring 如何解决循环依赖？

**回答重点**：核心是**提前暴露尚未初始化完成的 Bean**——Bean 实例化完成后，立刻把「能生产该 Bean 的对象工厂」放进三级缓存；当别的 Bean 反过来依赖它时，就能拿到这个半成品，从而打破「A 等 B、B 等 A」的死循环。三个 Map 分工：`singletonObjects`（一级，完整单例）、`earlySingletonObjects`（二级，已实例化未初始化）、`singletonFactories`（三级，对象工厂，用于延迟生成早期 Bean，尤其要生成 AOP 代理时）。

### 什么是循环依赖

两个及以上 Bean 互相持有对方的引用，形成闭环：A 注入 B、B 又注入 A（自己注入自己、三个以上 Bean 串成环，本质相同）。创建 A 时发现依赖 B，于是转去创建 B；B 创建到一半又回头要 A，而 A 正卡在「等 B」的状态上——双方互相等待，初始化顺序无法确定，这就是循环依赖导致的创建死锁。字段注入 / setter 注入能被三级缓存打破，构造器注入则不行（原因见下）。

### 三个缓存的分工

| 缓存 | 字段 | 存放内容 |
|---|---|---|
| 一级 | `singletonObjects` | 完全初始化完成的单例 Bean |
| 二级 | `earlySingletonObjects` | 已实例化、但未完成属性注入与初始化的「半成品」 |
| 三级 | `singletonFactories` | `ObjectFactory`，调用 `getObject()` 才真正产出早期 Bean（可在此织入 AOP 代理） |

### 一次 A ↔ B 循环依赖的完整流程

1. `getBean(A)` → 一级缓存没有 → 标记 A「创建中」→ 进入 `doCreateBean(A)`
2. **实例化** A（`createBeanInstance`）后，立刻把工厂塞进三级缓存——此时 Spring 并不知道会不会发生循环依赖，但它一律先暴露
3. **属性注入** A 时发现依赖 B → `getBean(B)`，B 走一遍同样流程，实例化后也暴露自己的工厂
4. B 注入属性时 `getBean(A)`：一级没有，且 A 正在创建中 → 查二级（空）→ 查三级拿到工厂 → `getObject()` 得到 A（需要 AOP 时在这一步生成代理）→ 工厂从三级删除，A 放入二级缓存
5. B 完成初始化进入一级缓存，返回 A 的属性注入；A 注入 B 后完成初始化，进入一级缓存并清除二级缓存中的自己

关键一行源码（`AbstractAutowireCapableBeanFactory#doCreateBean`）：

```java
addSingletonFactory(beanName, () -> getEarlyBeanReference(beanName, mbd, bean));
```

`getSingleton(beanName, allowEarlyReference)` 的查找顺序就是一级 → 二级 → 三级；注意若第一步发现 Bean **不在创建中**，直接返回 `null`，不再继续查二级、三级。

### 能解决循环依赖的两个前提

1. 相互依赖的 Bean 必须都是**单例**
2. 注入方式**不能全是构造器注入**，且 beanName 字母序在前的那个不能是构造器注入

### 为什么必须单例、为什么不能全构造器注入

- **原型（prototype）不行**：创建 A1 要新 B1，创建 B1 又要新 A2，A2 又要 B2……无限递归，源码里 `isPrototypeCurrentlyInCreation` 判断会直接抛 `BeanCurrentlyInCreationException`。单例则「B 要的是同一个 A」，Spring 才有操作空间。
- **Bean 创建三步**：实例化 `createBeanInstance` → 属性注入 `populateBean` → 初始化 `initializeBean`（Aware 回调、init-method、AOP 代理）。构造器注入要求在**实例化阶段**就拿到依赖，而此时 A 还没进三级缓存，B 找不到「半成品 A」，双方卡死。
- **一个 set 一个构造器**：A 用 set 注入 B、B 用构造器注入 A → **成功**（A 先实例化并暴露，B 构造时能从 Map 取到 A）；反过来 A 用构造器注入 B、B 用 set 注入 A → **失败**。原因是 Spring 按 **beanName 字母序**创建 Bean，A 永远排在 B 前，字母序在前的那个必须允许「先实例化、后注入」。

### 实践建议

- 循环依赖多说明职责划分有问题，优先重构（抽公共依赖、引入事件/回调）而不是依赖三级缓存兜底。
- Spring Boot 2.6+ 默认 `spring.main.allow-circular-references=false`，循环依赖会直接启动失败；老项目升级时若报此错，先查依赖环再考虑临时打开开关。
- 构造器注入 + `@Lazy` 也能打破环（注入代理，真正使用时才初始化）。

> 相关：[[Java 31 - AOP与自定义注解实践]]、[[Java 25 - Spring Boot RESTful 接口实现与测试]]

---

## 二十、Synchronized 和 ReentrantLock 有什么区别？

**回答重点**：`synchronized` 是 Java 内置关键字，自动加锁/释放，非公平、不可中断、不支持超时与多条件；`ReentrantLock` 是 JUC 提供的 API 级锁（JDK 1.5 引入），支持超时、可中断、公平锁、多条件队列，但必须手动 `unlock()`。两者**都是可重入锁**；JDK 1.6 优化后性能基本持平——日常用 `synchronized` 更简单，需要高级能力时再用 `ReentrantLock`。

| 维度 | `synchronized` | `ReentrantLock` |
|---|---|---|
| 层次 | JVM 关键字，字节码 `monitorenter/monitorexit` | JDK 类库，基于 AQS |
| 释放 | 代码块结束/异常自动释放 | 必须 `finally` 中手动 `unlock()` |
| 公平性 | 只有非公平 | 可选公平 / 非公平 |
| 可中断 | 不支持 | `lockInterruptibly()` 支持 |
| 超时 | 不支持 | `tryLock(timeout, unit)` 支持，可规避死锁 |
| 条件队列 | 单条件（`wait/notify`） | 多 `Condition`，可分组精确唤醒 |
| 可重入 | 支持 | 支持 |

### 可重入锁

同一线程持有某把锁时可以再次获取同一把锁而不死锁。递归调用、外层方法调用内层同步方法时必需：

```java
public class ReentrantLockExample {
    private final ReentrantLock lock = new ReentrantLock();

    public void outer() {
        lock.lock();
        try {
            inner();               // 同一线程再次拿同一把锁
        } finally {
            lock.unlock();
        }
    }

    public void inner() {
        lock.lock();
        try {
            // critical section
        } finally {
            lock.unlock();
        }
    }
}
```

**实现方式**：核心是计数器——线程抢到锁计数 +1，重入再 +1；每次释放 -1，减到 0 才真正释放锁。`ReentrantLock` 用 AQS 的 `state` 字段承担这个计数，并记录 `exclusiveOwnerThread`。

### synchronized 在 JDK 1.6 后的优化

- **偏向锁**：同一线程反复获取同一把锁时，把锁标记为偏向该线程，后续进入几乎零开销（JDK 15 起默认禁用并废弃，因维护成本高于收益）。
- **轻量级锁**：无竞争时用 CAS 把 Mark Word 指向栈上的 Lock Record，避免走操作系统互斥量。
- **锁粗化**：把短时间内连续的加解锁合并成一次更大范围的锁，减少开销。
- **锁消除**：JIT 通过逃逸分析判定锁对象不会被其他线程访问，直接去掉同步。

锁状态升级路径：无锁 → 偏向锁 → 轻量级锁（CAS 自旋）→ 重量级锁（OS mutex，线程挂起）。

### 选型建议

- 默认 `synchronized`：代码短、不会忘记解锁、异常安全，JVM 还会持续优化。
- 需要 `tryLock` 超时避免死锁、需要响应中断取消任务、需要公平锁、需要多个 `Condition` 分组唤醒（如生产者/消费者分别唤醒）时用 `ReentrantLock`。
- 用 `ReentrantLock` 时 `lock()` 要写在 `try` **之前**，`unlock()` 放在 `finally`；写在 try 内部一旦加锁失败，finally 里的 `unlock` 会抛 `IllegalMonitorStateException`。

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 15 - 线程基础]]、[[Java 51 - 并发编程学什么（学习框架）]]

---

## 二十一、为什么 HashMap 的容量必须是 2 的 n 次方？

**回答重点**：为了让 `(n - 1) & hash` 能替代 `hash % n` 定位桶——**位运算比取模快得多**；同时 `n - 1` 的低位全为 1，能让哈希码的低位充分参与运算，分布更均匀；扩容时还能只靠「原容量那一位」判断元素留在原位还是迁移，省去重新计算哈希。

### 为什么 (n - 1) & hash 分布均匀

`n = 64` 时二进制是 `0100 0000`，`n - 1 = 0011 1111`，低位全 1，与哈希码做 `&` 能完整保留哈希低位的随机性；若直接用 `0100 0000` 去与，结果低位恒为 0，所有元素只能落在极少数桶里，冲突爆炸。

### 位运算 vs 取模

按哈希码算下标，直觉写法是 `hash % n`（如长度 5 就 `% 5`），但除法指令开销明显高于位与。当且仅当 `n` 是 2 的幂时成立：

```
a % (2^n) == a & (2^n - 1)
```

这也是 `HashMap` 默认容量 16、`tableSizeFor()` 把任意初始容量向上取整到 2 的幂的原因。

### 扩容时的便利

容量 16 → 32 时，元素新下标只可能是「原下标」或「原下标 + 16」，判断依据就是哈希值在**原容量那一位**上是 0 还是 1（`e.hash & oldCap`）：0 留在低位链（lo），1 迁到高位链（hi）。因此扩容不需要重算哈希、不需要重新取模，JDK 1.8 直接把一条链表拆成 lo/hi 两条（红黑树同理拆分），这也是「2 的幂」带来的实际性能收益。

> 相关：[[Java 14 - HashMap 源码解析]]

---

## 二十二、为什么 JDK 1.8 对 HashMap 进行了红黑树的改动？

**回答重点**：链表只能顺序遍历，一旦哈希冲突集中到同一个桶，查找/插入/删除就从 O(1) 退化为 O(n)。JDK 1.8 因此在**链表长度 ≥ 8 且数组容量 ≥ 64** 时把链表树化为红黑树，最坏情况降到 O(log n)；节点数 ≤ 6 时再退回链表，用 6/8 之间的差值留出缓冲，避免反复树化与反树化。

### 树化的两个门槛

- 阈值常量：`TREEIFY_THRESHOLD = 8`、`UNTREEIFY_THRESHOLD = 6`、`MIN_TREEIFY_CAPACITY = 64`
- `putVal` 里 `binCount` 从 0 开始累加，`binCount >= 7`（即桶内已有 8 个节点）才进入 `treeifyBin`
- `treeifyBin` 内部还要再判一次数组长度：`tab.length < MIN_TREEIFY_CAPACITY` 时**只扩容、不树化**（`resize()` 后冲突自然被摊开）

### 为什么容量不到 64 不树化

1. **避免白做工**：小数组冲突多，但一扩容元素就散到新桶里，刚树化完就扩容，树化开销全浪费。
2. **省内存**：`TreeNode` 比普通 `Node` 多出父/左/右/前驱指针，内存约为普通节点的两倍，小规模数据下不划算。

### 为什么阈值偏偏是 8

源码注释给了概率依据：在负载因子 0.75 的假设下，一个桶内节点数达到 8 的概率约为 `0.00000006`（千万分之一）。也就是说正常情况下几乎不会树化，红黑树只是**兜底**——防劣质 `hashCode()` 或刻意构造的哈希碰撞攻击把查询拖成 O(n)。

### 为什么退化阈值是 6 而不是 8

留缓冲区防「反复横跳」：若树化与退化都用 8，元素在 8/9 之间增删就会不停地在链表和红黑树之间转换，而两个方向的转换都有开销。取 6 后，只有真正删到足够少才退化。

### 为什么不干脆全部用红黑树

`TreeNode` 内存约为 `Node` 的两倍，而绝大多数桶只有 0~1 个元素；短链表遍历本身很快且占用小。用「链表为主 + 红黑树兜底」是时间与空间的折中。

> 相关：[[Java 14 - HashMap 源码解析]]

---

## 二十三、为什么 Java 中 HashMap 的默认负载因子是 0.75？

**回答重点**：负载因子 = 元素数量 / 容量，决定「装多满就扩容」。0.75 是**时间与空间的折中值**：调低则扩容频繁（rehash 开销大、空间浪费），调高则哈希冲突增多（桶内链表/红黑树变长，查询退化），0.75 在两者之间取得较好平衡。

### 扩容何时触发

- 阈值 `threshold = capacity × loadFactor`，`size > threshold` 时扩容为两倍并迁移元素
- 例：容量 16、负载因子 0.75 → 阈值 12，存入第 13 个元素时扩容
- 无参构造只记录 `loadFactor = 0.75`，数组容量延迟到**首次 put** 才分配为 16（懒加载）

### 为什么不是 1.0 或 0.5

| 负载因子 | 空间利用率 | 冲突概率 | 代价 |
|---|---|---|---|
| 0.5 | 低（一半空间闲置） | 低，查询快 | 扩容频繁、rehash 开销大 |
| **0.75** | 较高 | 可接受 | 平衡点 |
| 1.0 | 最高 | 高，桶内链表/红黑树变长 | 查询最坏退化到 O(n) |

0.75 还是二进制可精确表示的值（3/4）：容量为 2 的幂时 `capacity × 0.75` 必为整数，阈值计算不会因浮点舍入产生偏差。

### 场景化调整

- **读多写少 / 延迟敏感**：可降到 0.5，冲突更少、查询更快，代价是更多扩容
- **内存受限**：可升到 0.85 甚至更高，减少扩容次数与空桶，代价是冲突与查询开销上升
- 注意负载因子只能在**构造时**传入，运行中无法修改；已知元素规模时更有效的做法是预设初始容量（`expectedSize / 0.75 + 1`），一次性分配到位、彻底避免扩容

> 相关：[[Java 14 - HashMap 源码解析]]

---

## 二十四、为什么 Spring 循环依赖需要三级缓存，二级不够吗？

**回答重点**：二级缓存足以**打破循环依赖**，但解决不了 **AOP 代理的生成时机**。若二级缓存里只放原始对象，其他 Bean 注入到的就是未代理的「裸对象」；若实例化后立刻把代理对象放进二级缓存，又等于在 Bean 初始化之前就生成了代理，违背 Bean 生命周期。三级缓存存的是 `ObjectFactory`，**只有真的发生循环依赖时才调用它**去提前暴露（必要时生成代理），没发生依赖就永不调用，生命周期因此不被破坏。

### 二级缓存方案的两个死结

1. **放原始对象**：B 注入到的是未经 AOP 增强的 A，事务、日志、权限等切面全部失效，且最终一级缓存里是代理对象、B 手里却是原始对象，同一 Bean 出现两个身份。
2. **直接放代理对象**：看似可行，但代理是在**初始化后期**由后置处理器（`AbstractAutoProxyCreator#wrapIfNecessary`）生成的；实例化完就代理，等于对所有 Bean 无条件提前代理——既违背生命周期，又对没有循环依赖的 Bean 白付代理成本。

### 工厂里到底做了什么

```java
protected Object getEarlyBeanReference(String beanName, RootBeanDefinition mbd, Object bean) {
    Object exposedObject = bean;
    if (!mbd.isSynthetic() && hasInstantiationAwareBeanPostProcessors()) {
        for (SmartInstantiationAwareBeanPostProcessor bp : getBeanProcessorCache().smartInstantiationAware) {
            exposedObject = bp.getEarlyBeanReference(exposedObject, beanName);
        }
    }
    return exposedObject;
}
```

- 没有可用的 `SmartInstantiationAwareBeanPostProcessor` → 原样返回传入的 bean（不代理）
- 有则交给它决定，`AnnotationAwareAspectJAutoProxyCreator` 在这里判断是否需要代理、需要就返回代理对象
- 也就是说：**是否代理由工厂在「被真正需要」的那一刻决定**，而不是在实例化时盲猜

### 缓存不会堆积

单例 Bean 创建完成后会放入一级缓存 `singletonObjects`，同时从二级 `earlySingletonObjects`、三级 `singletonFactories` 中移除自己。没有循环依赖时三级缓存里的工厂从未被调用，随 Bean 完成即清理，不存在长期占用。

### 与「十九」的分工

「十九」讲循环依赖的整体流程与前提（单例、非全构造器注入、beanName 字母序），本节只回答**「两级为什么不够」**这一个追问点；两节配合看即可。

> 相关：[[Java 31 - AOP与自定义注解实践]]

---

## 二十五、什么是 Hash 碰撞？怎么解决哈希碰撞？

**回答重点**：Hash 碰撞是指不同的输入数据经哈希函数计算后得到**相同的哈希值**，从而被映射到哈希表的同一个槽位。常见解决方式有三类：

1. **拉链法（链地址法）**：每个槽位挂一条链表，哈希值相同的元素放进同一链表
2. **开放寻址法**：槽位被占就按规则找下一个可用槽位（线性探查 / 平方探查 / 双散列）
3. **再哈希法（双重哈希）**：碰撞时用第二个哈希函数重算索引，降低再次碰撞的概率

### 拉链法

每个 bucket 存的是指向链表头的指针，所有哈希值相同的元素进入同一链表。

- 优点：实现简单、扩展性好；数据量大时性能相对稳定（不像开放寻址会因装填过满而急剧退化）
- 缺点：碰撞频繁时链表变长，查询从 O(1) 退化到 O(n)；链表节点需要额外内存

**红黑树优化**：当单条链表长度超过阈值（JDK 8 HashMap 为 8，且表容量 ≥ 64）时把链表转成红黑树，查找从 O(n) 降到 O(log n)，可避免哈希被恶意构造导致的长链拖垮查询。代价是实现复杂、内存占用更高。JDK 8 的 HashMap 即采用此方案，详见 [[Java 14 - HashMap 源码解析]]。

### 开放寻址法

碰撞时在表中寻找下一个空闲槽位，探查序列常见三种：

| 方式 | 探查步长 | 特点 |
|------|----------|------|
| 线性探查 | `(h + 1, h + 2, …) % n` | 最简单，但易产生**一次聚集**（连续占用区不断变长） |
| 平方探查 | `(h ± 1², ± 2², …) % n` | 减轻一次聚集，但可能探查不到部分槽位（表长需为质数或 2 的幂且配合特定规则） |
| 双散列 | 第二个哈希函数决定步长 | 分布最均匀，聚集最少，代价是多一次哈希计算 |

- 优点：不需要额外的指针/链表结构，内存紧凑、缓存友好；负载因子低时查找插入都很快
- 缺点：装填度上升后探查次数增加，性能下降明显；**删除不能真删**，只能打删除标记（tombstone），否则会截断后续元素的探查链导致查找失败；新元素插入到标记位时才能复用该槽位

JDK 中 `ThreadLocalMap` 就是用开放寻址（线性探查）实现的，因此它的删除同样采用「清理陈旧 entry」的策略。

### 再哈希法（双重哈希）

准备两个哈希函数：`h1` 决定初始位置，碰撞后由 `h2` 计算新的索引（`index = (h1 + i·h2) % n`）。相当于把探查步长也做成「因 key 而异」，从而打散聚集。

- 优点：冲突概率显著降低，分布均匀
- 缺点：每次冲突都要额外算一次哈希，且第二个哈希函数的质量直接决定效果；本质上仍是开放寻址，装填率过高时依旧会退化

> 相关：[[Java 14 - HashMap 源码解析]]

---

## 二十六、什么是 Java 中的 ABA 问题？

**回答重点**：ABA 问题指多线程环境下，共享变量的值在一段时间内经历了 `A → B → A` 的变化，而 CAS 只比较「当前值是否等于预期值」，因此会误判为「没被改过」并成功执行更新。它常出现在基于 **CAS（Compare-And-Swap）** 的无锁并发编程中。

CAS 的语义是：比较内存值与预期值一致才写入新值。问题在于——**它只能看到最终的值，看不到中间的变化过程**。

### 一个会出错的例子：无锁栈

```java
public class LockFreeStack<T> {
    private AtomicReference<Node<T>> head = new AtomicReference<>();

    public T pop() {
        Node<T> oldHead;
        Node<T> newHead;
        do {
            oldHead = head.get();
            if (oldHead == null) {
                return null;
            }
            newHead = oldHead.next;
        } while (!head.compareAndSet(oldHead, newHead));
        return oldHead.value;
    }
}
```

线程 A 读到栈顶 `oldHead`（节点 X）后暂停；线程 B 连续 pop 掉 X、Y，又把**新节点**压栈并恰好复用了同一块内存地址；线程 A 恢复执行 `compareAndSet(oldHead, newHead)`，比较的是引用地址——地址相同，CAS 成功，栈顶被错误地指向了已失效的 `newHead`，栈结构被破坏。

同类问题也出现在「余额从 100 扣到 50 又充回 100」这类业务判断上：值看着没变，但中间发生过扣款，基于旧快照的决策可能失效。

### 解决方法

**1）引入版本号（最常用）**：每次写不仅更新值，还递增版本号；CAS 时同时比较值与版本号。值绕回原值，版本号也已经变了。

Java 用 `AtomicStampedReference` 实现：

```java
AtomicStampedReference<Integer> stampedRef = new AtomicStampedReference<>(1, 0);
int[] stampHolder = new int[1];
Integer ref = stampedRef.get(stampHolder);   // 值与版本号一起取出
boolean ok = stampedRef.compareAndSet(ref, 2, stampHolder[0], stampHolder[0] + 1);
```

注意版本号 `int` 也会溢出回绕（约 21 亿次写），只是概率极低；极端场景可用 `AtomicMarkableReference` 的布尔标记或自行维护 `long` 版本。

**2）`AtomicMarkableReference`**：在引用上附带一个布尔标记，只关心「是否被改过」而不关心改了几次，适合只需要区分两种状态的场景。

```java
AtomicMarkableReference<Integer> markableRef = new AtomicMarkableReference<>(1, false);
```

> 相关：[[Java 16 - 锁与并发工具]]

---

## 二十七、什么是 Java 中的不可变类？

**回答重点**：不可变类指对象创建后其状态（字段）无法再被修改的类，实例在整个生命周期内保持不变。

**五个关键特征**：

1. 类声明为 `final`，禁止子类继承后改写行为
2. 所有字段 `private final`，初始化后不可赋值
3. 通过构造函数一次性初始化全部字段
4. 不提供任何修改状态的方法（无 setter）
5. 若字段引用了可变对象，必须在出入两个方向上都做防御：构造时拷贝入参、getter 返回副本

经典不可变类：`String`、包装类（`Integer` 等）、`BigDecimal`、`LocalDate` / `LocalDateTime`、`java.time` 大部分类型。

### 优缺点

**优点**

1. **天生线程安全**：状态不可变，无需加锁即可安全共享（不可变对象发布本身即安全发布）
2. **可安全缓存与复用**：如 `String` 常量池、`Integer` 的 `-128~127` 缓存
3. **可作为 HashMap 的 key**：hashCode 稳定，不会因状态变化而「找不到自己」
4. 避免意外修改导致的状态不一致，便于推理与调试

**缺点**

1. **每次「修改」都要新建对象**：频繁变更场景下产生大量临时对象，带来 GC 压力（典型如 `String` 用 `+` 循环拼接）
2. 对象较大且变更频繁时，拷贝成本高
3. 需要配套可变版本时（如 `StringBuilder`）要额外设计 API

### String 是如何做到的

- `String` 类被 `final` 修饰，无法被继承
- 内部存储被 `private final` 修饰（JDK 8 为 `char[] value`，JDK 9 起改为 `byte[] value` + `byte coder`，配合 Latin-1 压缩节省内存）
- `final` 只能保证**引用**不变，挡不住数组内容被改，所以 `value` 必须 `private` 且不对外暴露；JDK 8 中任何返回内部数组的方法都没有公开
- 需要「修改」的方法（`replace`、`substring`、`concat`、`toUpperCase` 等）一律**返回新对象**，原对象保持不变

```java
String s = "a";
s += "b";      // 等价于 s = new StringBuilder(s).append("b").toString();
// 原 "a" 对象未被修改，只是 s 的引用指向了新的 "ab"
```

因此频繁拼接应使用 `StringBuilder`（单线程）或 `StringBuffer`（多线程），最后再 `toString()` 一次性生成不可变结果。

### 自己实现一个不可变类的检查清单

- [ ] 类 `final`，或所有构造器私有 + 工厂方法
- [ ] 字段全部 `private final`
- [ ] 构造器中对可变入参做**深拷贝**
- [ ] getter 对可变字段返回**深拷贝或不可变视图**（`Collections.unmodifiableList`）
- [ ] 不暴露任何可修改内部状态的方法；「修改」类方法返回新实例

> 相关：[[Java 08 - 字符串与正则表达式转义]]

---

## 二十八、什么是 Java 中的原子性、可见性和有序性？

**回答重点**：这三者是并发安全的三大基石，分别回答「操作能不能被拆开」「一个线程的修改别的线程能不能立刻看到」「代码顺序会不会被打乱」三个问题。Java 内存模型（JMM）就是为了定义这三件事在多线程下如何成立。

| 特性 | 含义 | 典型破坏场景 | 保证手段 |
|------|------|--------------|----------|
| 原子性 | 一个（或一组）操作要么全部执行，要么全不执行，中途不被其他线程插入 | `i++` 实际是「读-改-写」三步，两线程并发会丢失更新 | `synchronized` / `Lock` / `java.util.concurrent.atomic` 原子类（底层 CAS） |
| 可见性 | 一个线程修改共享变量后，其他线程能立即看到新值 | 线程把变量缓存在工作内存/寄存器里，一直读旧值（死循环不退出） | `volatile`、`synchronized`、`final`（正确构造）、原子类 |
| 有序性 | 程序执行顺序与代码书写顺序一致 | 编译器/处理器指令重排序，导致其他线程看到「半初始化」对象 | `volatile`（内存屏障）、`synchronized`、happens-before 规则 |

### 原子性

- **锁**：`synchronized` 与 `Lock` 通过互斥把复合操作包成临界区，是保证原子性最通用的手段。
- **原子类**：`java.util.concurrent.atomic` 下的 `AtomicInteger`、`AtomicLong`、`AtomicReference` 等，把「读-改-写」封装成一条硬件原子指令，无锁实现。
- **CAS**：原子类底层依赖 CAS（Compare-And-Swap）。它是硬件级指令，比较内存当前值与预期值，相等才写入新值，整个过程不可中断，避免了锁带来的上下文切换开销。

注意：`volatile` **只保证可见性和有序性，不保证原子性**——`volatile int i; i++` 依然线程不安全，这是最常见的追问点。

### 可见性

- **`volatile`**：最轻量的同步机制。写入立即对其他线程可见，读取总是拿到最新值。语义上等价于「读写都直接作用于主内存」；物理上仍经过 CPU 缓存，靠缓存一致性协议（MESI）+ 内存屏障实现。
- **`synchronized`**：不仅保证原子性，也保证可见性。线程退出 `synchronized` 块时把修改刷新到主内存，进入时从主内存重新读取；`Lock` 的 `unlock()`/`lock()` 具有同样的内存语义。
- **JMM**：规定共享变量在线程间的可见性与有序性规则，并通过内存屏障的插入规则把这些语义落实到指令层面。

### 有序性

**指令重排序**：编译器、CPU、内存系统为了性能会调整指令顺序（编译器重排、指令级并行重排、内存系统重排）。单线程下重排不改变结果（as-if-serial），但多线程下会出问题。

经典翻车场景——双重检查锁（DCL）单例：`instance = new Singleton()` 的「分配内存 → 初始化 → 赋值引用」三步可能被重排为 1-3-2，另一线程在第一次 `instance == null` 检查时就看到**非 null 但尚未初始化完成**的对象。给 `instance` 加 `volatile` 即可禁止该重排（完整推演见 [[Java 07 - 并发三大根源：可见性、原子性、有序性]]）：

```java
private static volatile Singleton instance;   // 少了 volatile 就是 bug
```

**happens-before 原则**：JMM 定义的核心约束。若 A happens-before B，则 A 的结果对 B 可见，且 A 在 B 之前执行。常用规则：

1. **程序顺序**：同一线程内，前面的操作 happens-before 后面的操作
2. **监视器锁**：对同一个锁的 `unlock` happens-before 后续的 `lock`
3. **volatile**：对 volatile 变量的写 happens-before 后续对该变量的读
4. **线程启动/终止**：`Thread.start()` happens-before 新线程内的任何操作；线程内所有操作 happens-before 其他线程从 `join()` 返回
5. **传递性**：A hb B 且 B hb C，则 A hb C

**内存屏障**：`volatile` 的语义靠屏障落地，禁止特定重排：

| 位置 | 插入屏障 | 作用 |
|------|----------|------|
| volatile 写之前 | StoreStore | 保证前面的普通写先刷出，不会被排到 volatile 写之后 |
| volatile 写之后 | StoreLoad | 保证 volatile 写先于后续的读（开销最大的一个屏障） |
| volatile 读之后 | LoadLoad / LoadStore | 保证 volatile 读先于后续的读和写 |

x86 只在 StoreLoad 上需要实际指令（`lock addl`），因为 x86 本身是强内存模型，其余三种重排天然不发生。

> 相关：[[Java 07 - 并发三大根源：可见性、原子性、有序性]]（硬件层根因与 DCL 完整推演）、[[Java 16 - 锁与并发工具]]、[[Java 18 - 类加载机制]]

---

## 二十九、什么是 Java 的 CAS（Compare-And-Swap）操作？

**回答重点**：CAS 是一条**硬件级别的原子指令**，语义是「如果内存位置的值等于预期值，就更新为新值，否则什么都不做」。它是 Java 无锁并发（`java.util.concurrent.atomic`、AQS 的 state、ConcurrentHashMap 的节点插入）的基石。

**三个操作数**：

| 操作数 | 含义 |
|--------|------|
| V | 变量的内存地址 |
| A | 旧的预期值（expected） |
| B | 准备写入的新值（new） |

指令按地址 V 取出当前值，与 A 比较：相等则写入 B 并返回成功，不等则不写并返回失败。**比较和交换被封装成一条指令**，中间不可能被其他线程插入——这才是原子性的来源。

### 为什么需要 CAS

以「比较后再替换」为例：判断值是否为 1，是则替换为 2；是 2 则替换为 3。看起来没问题，但多线程下两个线程可能同时判断「当前值等于 1」，然后**都**把它改成 2——明明加了两次，结果却是 2。

加锁能解决，但锁有上下文切换和阻塞的代价。于是硬件层提供 `cmpxchg` 这类指令，把「判断 + 替换」合并为一个不可分割的动作，既不阻塞也能保证正确性。

典型用法是失败重试（自旋）：

```java
public final int incrementAndGet() {
    for (;;) {
        int current = get();                       // 读快照
        int next = current + 1;
        if (compareAndSet(current, next)) {         // 快照没变才提交
            return next;
        }
    }
}
```

### 优缺点

**优点**

- **无锁并发**：不阻塞线程，没有锁的获取/释放与上下文切换开销，读多写少或冲突低的场景吞吐更高
- **原子性**：单条指令完成比较+写入，天然线程安全
- **无死锁**：不存在锁的持有关系，不会有死锁和优先级反转

**缺点**

- **ABA 问题**：值从 A 变成 B 又变回 A，CAS 察觉不到「中途被改过」，详见「二十六」的推演与 `AtomicStampedReference` 解决方案
- **自旋开销**：冲突激烈时大量线程反复重试，空转烧 CPU；通常配合 `LongAdder` 分段累加或退避策略缓解
- **只能保证单个变量的原子性**：多个变量要么各自用原子类，要么封装进一个不可变对象用 `AtomicReference` 整体替换（此时又失去了对字段的独立更新能力）
- **高并发下改同一变量会出现总线风暴**（见下文）

### 在 Java 中的实现

CAS 由 `sun.misc.Unsafe` 提供（内部类，不推荐业务代码直接用），通过 JNI 调用底层硬件指令；日常使用的是并发包里的封装：

```java
boolean updated = atomicInteger.compareAndSet(expected, newValue);
if (updated) {
    System.out.println("Value updated to " + newValue);
} else {
    System.out.println("Update failed");        // 失败由调用方决定是否重试
}
```

底层落到 x86 的 `cmpxchg` 指令。由于 `cmpxchg` 本身不保证跨核原子性，还需要 `lock` 前缀：

- **JDK 9 之前**：先判断当前是否多处理器，多处理器才加 `lock` 前缀，单处理器不加（省一次总线锁定）
- **JDK 9 起**：移除该判断，**一律加 `lock` 前缀**（现实中几乎不存在单核部署）

### CAS 总线风暴

`lock` 前缀会把写缓冲区中的数据立即刷回主内存。在对称多处理器架构下，各 CPU 通过**嗅探总线**检查自己的缓存是否过期：某个 CPU 刷新数据到主存时，会经总线通知其他 CPU 让对应缓存行失效——这就是缓存一致性协议（MESI）的工作方式，也是内存屏障的实现基础。

问题在于：总线上的来回通信（cache 一致性流量）是**共享资源**。当大量线程用 CAS 争抢**同一个变量**时，每次成功写都会引发一轮全核缓存失效广播，流量激增使总线成为瓶颈，反过来拖慢本地缓存更新——这就是总线风暴，也是 CAS 在高并发写同一变量时的性能天花板。

工程上的应对：

- 分散热点：`LongAdder` / `DoubleAdder` 用 Cell 数组把累加分散到多个缓存行，求和时再汇总
- 避免伪共享：热点字段用 `@Contended` 或手工填充（padding）独占缓存行
- 减少共享写：线程本地累加后批量合并

> 相关：[[Java 16 - 锁与并发工具]]（「二十六」为本问题的 ABA 专题）

---

## 三十、什么是 Java 的 SPI（Service Provider Interface）机制？

**回答重点**：SPI 是 Java 内置的**服务发现/插件机制**——由框架定义接口，第三方提供实现，双方约定用 `META-INF/services/` 下的配置文件登记实现类，运行时由 `ServiceLoader` 动态发现并加载。核心价值是**接口与实现解耦**：换实现只改配置，不动调用方代码。

**四个核心概念**：

| 概念 | 说明 |
|------|------|
| 服务接口 | 接口或抽象类，定义服务规范（如 JDBC 的 `java.sql.Driver`） |
| 服务提供者 | 实现该接口的具体类（如 `com.mysql.cj.jdbc.Driver`） |
| `ServiceLoader` | JDK 提供的加载器，运行时扫描并实例化所有已登记的实现 |
| 配置文件 | `META-INF/services/{接口全限定名}`，内容为实现类的全限定名，一行一个 |

**优势**：

- **解耦**：调用方只依赖接口，编译期不需要知道有哪个实现存在
- **可扩展**：新增/替换实现只需加一个 jar 和配置文件，无需修改框架代码，符合开闭原则

可以类比「音乐播放器的插槽」：播放器不内置所有解码器，而是留一个标准接口，插件（MP3/WAV 解码器）按规范插入，启动时自动装载。典型真实案例是 **JDBC**：MySQL、Oracle、SQL Server 各自提供驱动实现 `java.sql.Driver`，`DriverManager` 通过 SPI 找到它们，业务代码只面向 JDBC 接口编程。

### 实现一个 SPI

**1）定义服务接口**

```java
public interface MyService {
    void execute();
}
```

**2）提供服务实现**

```java
public class MyServiceImpl implements MyService {
    @Override
    public void execute() {
        System.out.println("Executing MyServiceImpl");
    }
}
```

**3）登记配置**：在实现方（jar）的 `META-INF/services/` 下创建**以接口全限定名命名**的文件：

```text
META-INF/services/com.example.MyService
```

内容为实现类全限定名：

```text
com.example.MyServiceImpl
```

**4）通过 `ServiceLoader` 加载**

```java
ServiceLoader<MyService> loader = ServiceLoader.load(MyService.class);
for (MyService service : loader) {
    service.execute();
}
```

**5）替换实现**：新建 `MyServiceImplA implements MyService`，把配置文件内容改成 `com.example.MyServiceImplA` 即可，**调用代码一行不用改**——这就是 SPI 相对硬编码 `new` 的价值。

### 工程上的几个坑

- **`ServiceLoader` 无法按需选择**：`for` 循环会实例化**所有**登记的实现，想要「只加载某一个」做不到；Dubbo 因此自研了带 key 的 `ExtensionLoader`（`@SPI` + `@Adaptive`），按名字精确取用并支持懒加载与 IOC
- **不是懒加载**：`ServiceLoader.load()` 只做类型检查，真正的实例化发生在迭代时；配置文件写了但类不存在会抛 `ServiceConfigurationError`
- **配置文件路径/文件名写错是最常见故障**：目录必须恰好是 `META-INF/services`，文件名必须是**接口的全限定名**（不是实现类名），换行符、BOM 也可能导致解析不到
- **SPI 与双亲委派**：SPI 的接口在核心类库（由 Bootstrap 加载），实现却在应用 classpath，父加载器看不到子加载器的类，因此 JDK 用**线程上下文类加载器（TCCL）**打破双亲委派来完成加载，详见 [[Java 18 - 类加载机制]]
- **Android 上不可用**：`META-INF` 会被打包裁剪，常改用注解处理器（如 ARouter）生成映射表

---

## 三十一、你使用过哪些 Java 并发工具类？

**回答重点**：容器类 `ConcurrentHashMap`、原子类 `AtomicInteger`/`LongAdder`、队列 `BlockingQueue` 负责「让共享数据本身线程安全」；协调类 `Semaphore`、`CountDownLatch`、`CyclicBarrier` 负责「让多个线程按秩序推进」；`CompletableFuture` 负责异步编排。答题时不要只报名字，挑一个结合项目业务讲清楚「为什么用它、怎么用、踩过什么坑」，面试官通常顺着这个点继续深挖。

| 工具 | 解决的问题 | 典型场景 |
|---|---|---|
| `ConcurrentHashMap` | 线程安全的哈希表，分段/CAS + 桶头 synchronized，读不加锁 | 本地缓存、按 key 计数、并发去重 |
| `AtomicInteger` / `LongAdder` | CAS 实现无锁原子加减 | 计数器、序号生成；高并发累加优先 `LongAdder`（分段累加，减少 CAS 自旋失败） |
| `BlockingQueue` | 队列为空/满时阻塞，天然实现背压 | 生产者-消费者解耦、线程池任务队列、异步日志 |
| `Semaphore` | 控制同时访问资源的线程数（许可） | 接口限流、连接池/下载并发控制 |
| `CountDownLatch` | 一个（多个）线程等 N 个任务全部完成 | 主线程等待并行子任务汇总、服务启动预热 |
| `CyclicBarrier` | N 个线程互相等待到齐后一起继续，**可循环复用** | 分阶段并行计算、多线程对齐同一时间点起跑 |

### 使用要点与误区

- **`ConcurrentHashMap` 只保证单次操作原子**：「先 get 再 put」这类复合逻辑仍要用 `computeIfAbsent` / `merge` / `putIfAbsent`，否则照样有竞态；它也不允许 `null` 键值（无法区分「不存在」与「值为 null」，且并发下 `null` 会带来歧义）。
- **`AtomicInteger` 高并发下会退化**：大量线程 CAS 同一变量时失败重试加剧，JDK 8 的 `LongAdder` 用 Cell 数组分散热点，统计类场景吞吐明显更好；需要「读取瞬时精确值」时仍用 `AtomicLong`。
- **`Semaphore` 是许可不是锁**：`acquire()` 后必须在 `finally` 里 `release()`，否则许可泄漏会把后续线程永久挂住；它允许多个线程同时进入，别当成互斥锁用。
- **`CountDownLatch` 一次性、`CyclicBarrier` 可复用**：前者计数到 0 就作废，后者 `await()` 满员后自动重置；前者是「一个等多个」，后者是「多个等多个」。
- **别在业务线程池里无限 `await()`**：`latch.await()` 不设超时 + 子任务提交到同一个池，池被占满时会出现「等的人占着线程、被等的人排不上队」的自锁，务必用 `await(timeout, unit)` 或换用独立线程池。

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 15 - 线程基础]]

## 三十二、使用 HashMap 时，有哪些提升性能的技巧？

**回答重点**

三个抓手：初始容量、负载因子、`hashCode` 质量。

| 手段 | 做法 | 代价 / 注意 |
|---|---|---|
| 预估初始容量 | 已知元素数 n 时用 `new HashMap<>((int) (n / 0.75f) + 1)`，一步到位不扩容 | 容量过大会浪费内存，且拖慢迭代（迭代成本 ∝ 容量 + size，不是只跟元素数有关） |
| 调整负载因子 | 默认 0.75；查多写少可降到 0.5 减少冲突，内存紧张可适当调高 | 过低 → 桶大量空转、内存与迭代都变慢；过高 → 链表变长，查找从 O(1) 退化 |
| 保证 `hashCode` 均匀 | key 的 `hashCode()` 要分散，自定义 key 必须同时重写 `hashCode()` 与 `equals()` | 哈希函数质量差 → 大量 key 落进同一个桶，链表化后查询退化成 O(n) |

**扩容的性能影响**：元素数超过 `容量 × 负载因子` 触发扩容，容量翻倍并把所有节点 rehash 迁移到新桶。这一步是 O(n) 的重活，会让均摊 O(1) 的 put 出现偶发长尾；所以「能预估规模就预设容量」比事后调负载因子更有效。

**更有效的替代是换容器**（调参收益有限时优先考虑）：

- 要保留插入顺序 → `LinkedHashMap`：在 HashMap 之上多维护一条双向链表，直接遍历即插入序，省掉「取出再排序」；
- 要按 key 有序、支持范围查询 → `TreeMap`：红黑树实现，O(log n)；
- 多线程读写 → `ConcurrentHashMap`：桶级 synchronized + CAS，别用 `Collections.synchronizedMap()` 这种全表锁。

> 相关：[[Java 14 - HashMap 源码解析]]、[[Java 11 - Set与Map]]、[[Java 13 - fail-fast机制]]

## 三十三、如何合理地设置 Java 线程池的线程数？

**回答重点**

先判断任务类型，再套经验公式。

| 任务类型 | 特征 | 经验公式 |
|---|---|---|
| CPU 密集型 | 纯计算（如数学运算），几乎不阻塞，能把 CPU 跑满 | `核心数 + 1`；再多只会增加上下文切换开销 |
| I/O 密集型 | 文件、数据库、RPC 等读写，线程大部分时间在等 I/O，CPU 空闲 | `核心数 × 2` 或更多；更准确的写法是 `N × (1 + 等待时间 / 计算时间)` |

必须补的一句：**以上公式只是纯理论值**。生产上要结合机器硬件配置、预期 CPU 利用率与负载，通过压测不断调整，最终以实测参数为准。

> 相关：[[Java 16 - 锁与并发工具]]；更完整的推导与七参数配置示例见本文档「十五、Java 并发库中提供了哪些线程池实现？」一节。

## 三十四、如何在 Java 中控制多个线程的执行顺序？

**回答重点**

| 手段 | 机制 | 适用场景 |
|---|---|---|
| `CompletableFuture` | `thenRun` / `thenAccept` 把任务串成链，前一阶段完成后才触发下一阶段 | 有返回值的异步流水线，日常首选 |
| `synchronized` + `wait()` / `notify()` | 对象锁 + 线程间通信，按共享状态轮流放行 | 理解原理、维护老代码 |
| `ReentrantLock` + `Condition` | 显式锁可建多个条件队列，能精确唤醒某一组线程 | 多路等待、需要精细控制 |
| `Thread#join()` | 调用线程阻塞到目标线程终止 | 主线程等子线程，最简单 |
| `CountDownLatch` | 计数归零放行，一次性 | 一个/多个线程等 N 个任务都完成 |
| `CyclicBarrier` | 满员后互相放行并重置，可复用 | 多阶段并行计算的同步点 |
| `Semaphore` | 许可数量控制同时进入的线程数 | 限流、限制并发度 |
| 单线程线程池 | 唯一 worker 按提交顺序串行取任务 | 既要排队串行、又要复用线程 |

`CompletableFuture` 串行编排（T1 → T2 → T3）：

```java
CompletableFuture.runAsync(() -> doT1())
    .thenRun(() -> doT2())
    .thenRun(() -> doT3());
```

**扩展知识**

- **`join()` 底层就是 `synchronized` + `wait`**：`Thread#join` 内部对线程对象加锁后 `while (isAlive()) wait(0)`；线程终止时 JVM 调用 `notifyAll` 唤醒所有等待者。因此 `join()` 返回时能看到目标线程的全部写入（天然带 happens-before 语义）。
- **`CompletableFuture` 默认不换线程**：不传 `Executor` 时用 `ForkJoinPool.commonPool()`，且链上的下一阶段通常由刚完成上一阶段的线程就地执行；想隔离线程池必须显式传 `Executor`。
- **顺序控制不等于线程安全**：让 T1/T2/T3 依次执行只是编排，共享变量仍要靠 `volatile`、锁或原子类保证可见性与原子性。

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 46 - CompletableFuture 异步编程]]、[[Java 15 - 线程基础]]

---

## 三十五、数组和链表在 Java 中的区别是什么？

**回答重点**

| 维度 | 数组 | 链表 |
|---|---|---|
| 存储结构 | 一块**连续**内存，元素大小固定 | 节点分散在堆上，靠指针串联，不要求连续 |
| 容量 | 创建时固定，扩容要重新申请 + 拷贝 | 动态增减，按需申请节点 |
| 随机访问 | **O(1)**，下标直接定位 | **O(n)**，必须从头（双向链表可从尾）遍历 |
| 插入/删除 | 中间位置 **O(n)**，需搬移后续元素 | 已知节点位置时 **O(1)**，只改指针 |
| 内存开销 | 无额外指针，但可能预留空洞、浪费空间 | 每个节点额外存前驱/后继指针，占用更大 |
| 缓存友好度 | 高（连续内存可被 CPU 预读） | 低（节点地址跳跃，预读命中差） |

一句话必答：数组是「连续内存 + 下标寻址」，赢在随机访问和遍历；链表是「节点 + 指针」，赢在动态增删。

**扩展知识**

- **O(1) 随机访问从哪来**：数组只保存一个基地址，元素大小固定，`地址 = 基地址 + 下标 × 元素大小`，一次乘加就定位，无需比较和跳转。
- **删除为什么慢**：要保持内存连续，删掉中间元素后必须把后面的元素整体前移，本质是一次内存拷贝（`System.arraycopy`）。
- **链表删除真的 O(1) 吗**：改指针本身是 O(1)，但「找到要删的节点」仍需 O(n)——只有已持有节点引用（如迭代器的 `remove()`）时才是真 O(1)。
- **空间局部性决定实际差距**：CPU 按缓存行预读连续内存，遍历数组时后续元素早已被加载进缓存；链表节点地址跳跃，几乎每次都缓存未命中。所以同样是 O(n) 遍历，数组常常快一个数量级。
- **Java 中的落地**：`ArrayList` = 动态数组（满后扩容并 `Arrays.copyOf` 搬迁），`LinkedList` = 双向链表（同时实现 `Deque`，可当栈/队列/双端队列用）。日常首选 `ArrayList`，只有频繁在两端增删、且不做随机访问时才考虑 `LinkedList`。

> 相关：[[Java 10 - Collection与List]]、[[Java 14 - HashMap 源码解析]]

---

## 三十六、线程的生命周期在 Java 中是如何定义的？

**回答重点**

Java 线程状态由 `Thread.State` 枚举定义，共 6 种，可用 `getState()` 观察——只能靠 `start`/`sleep`/加锁/等待等操作**间接驱动**，不能直接设置：

| 状态 | 进入条件 | 退出条件 |
|---|---|---|
| `NEW` | `new Thread()` 后，尚未启动 | 调用 `start()` |
| `RUNNABLE` | `start()` 之后（就绪 + 运行中合并） | 等锁失败 / 等待 / `run()` 结束 |
| `BLOCKED` | 等待 `synchronized` 监视器锁 | 拿到锁 → `RUNNABLE` |
| `WAITING` | `wait()`、`join()`、`LockSupport.park()`（无超时） | `notify`/`notifyAll`/`unpark`/目标线程终止 |
| `TIMED_WAITING` | `sleep(n)`、`wait(n)`、`join(n)`、`parkNanos` | 超时或被唤醒 → `RUNNABLE` |
| `TERMINATED` | `run()` 正常返回或抛异常退出 | 终态，不可复活 |

必答句：**Java 把操作系统的「就绪」和「运行」合并为一个 `RUNNABLE`**（线程是否真的在 CPU 上由 OS 调度，JVM 不区分）；而操作系统意义上的「阻塞」在 Java 里被拆成 `BLOCKED`（等监视器锁）、`WAITING`（无限等）、`TIMED_WAITING`（限时等）三种。

**扩展知识**

- 操作系统课程的 5 态（新建 / 就绪 / 运行 / 阻塞 / 终止）与 Java 6 态的差异就来自上面这一「合并」一「拆分」；被追问时先讲映射关系，再讲原因。
- `BLOCKED` 专指**等待监视器锁**；`wait()`、`park()` 造成的是 `WAITING`，二者不要混说。

> 相关：[[Java 15 - 线程基础]]、[[Java 16 - 锁与并发工具]]

---

## 三十七、说说 AQS 吧？

**回答重点**

AQS（`AbstractQueuedSynchronizer`）是 JUC 同步器的**骨架**：把排队、入队、阻塞/唤醒、中断处理这些通用逻辑封装好，只把「什么时候能加锁、什么时候该入队」留给子类决定——典型的**模板方法模式**。

核心就两样东西：

- 一个 `volatile int state`：同步状态，具体语义由子类定义；
- 一个 **FIFO 等待队列**：AQS 对 CLH 锁队列的变体，双向链表，节点保存线程引用、等待状态、前驱/后继指针。抢不到资源的线程入队并阻塞，由前驱释放时唤醒后继。

常见实现类：`ReentrantLock`、`CountDownLatch`、`Semaphore`、`ReentrantReadWriteLock`，`ThreadPoolExecutor` 的 worker 控制也基于它。

**扩展知识**

### `state` 的语义由子类定义

| 实现类 | `state` 含义 |
|---|---|
| `ReentrantLock` | 锁的重入次数（0 = 未占用，n = 同一线程重入 n 次） |
| `Semaphore` | 当前可用许可数 |
| `CountDownLatch` | 剩余待完成计数（减到 0 放行） |
| `ReentrantReadWriteLock` | 高 16 位 = 读锁持有数，低 16 位 = 写锁重入次数 |

读写通过 `getState()`、`setState(int)`、`compareAndSetState(int, int)` 完成，最后一个基于 CAS，是并发安全的根基。

### 三层结构

| 层 | 内容 | 谁负责 |
|---|---|---|
| API 层 | `tryAcquire` / `tryRelease` / `tryAcquireShared` / `tryReleaseShared` / `isHeldExclusively` | **子类重写**，控制加锁与入队时机 |
| 排队层 | `acquire` / `release` / `acquireQueued` / `doAcquireShared`，负责入队、阻塞、唤醒、中断补偿 | AQS 已实现 |
| 数据层 | `state` + 双向队列 + CAS | AQS 已实现 |

### 五个可重写方法

| 方法 | 作用 |
|---|---|
| `tryAcquire(int)` | 独占模式尝试获取，`true` = 成功 |
| `tryRelease(int)` | 独占模式尝试释放，`true` = 成功 |
| `tryAcquireShared(int)` | 共享模式尝试获取，**负数 = 失败**，0 = 成功无剩余，正数 = 成功有剩余 |
| `tryReleaseShared(int)` | 共享模式尝试释放 |
| `isHeldExclusively()` | 当前线程是否独占持有 |

### 最小独占锁：只重写 3 个方法

```java
public class SimpleLock {
    private static class Sync extends AbstractQueuedSynchronizer {
        @Override protected boolean tryAcquire(int arg) {
            if (compareAndSetState(0, 1)) {            // CAS 抢锁
                setExclusiveOwnerThread(Thread.currentThread());
                return true;
            }
            return false;
        }
        @Override protected boolean tryRelease(int arg) {
            if (getState() == 0) throw new IllegalMonitorStateException();
            setExclusiveOwnerThread(null);
            setState(0);                               // 释放无需 CAS：只有持有者能进到这里
            return true;
        }
        @Override protected boolean isHeldExclusively() { return getState() == 1; }
    }
    private final Sync sync = new Sync();
    public void lock()   { sync.acquire(1); }   // 失败交给排队层：入队 + 阻塞
    public void unlock() { sync.release(1); }   // 成功后由排队层唤醒后继节点
}
```

### 为什么需要 `selfInterrupt`

`acquireQueued` 中线程被中断唤醒后，若前面还有排队线程，它抢不到锁会再次 `park` 睡过去——中断信号就丢了。因此 `acquireQueued` 用 `interrupted` 变量记下「等待期间是否被中断过」并返回；`acquire` 发现为 `true` 时主动调用 `selfInterrupt()` 补一次中断，把中断状态还原给上层调用者。

### 与 CLH 的关系

AQS 队列的原型是 CLH 自旋锁：把「自旋等待前驱」换成「阻塞等待前驱」，于是必须维护**显式双向队列**（前驱要能找到后继去唤醒），并引入 `waitStatus` 标记节点状态。CLH 的演进过程与 `waitStatus` 取值表见本文档「七、Java 中 ReentrantLock 的实现原理是什么？」。

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 07 - 并发三大根源：可见性、原子性、有序性]]

## 三十八、说说 Java 中 HashMap 的原理？

**回答重点**（先给一句话结论，再按「算哈希 → 定下标 → 处理冲突 → 超阈值扩容」展开）：

- **数据结构**：`HashMap` 存放键值对，底层是「数组 + 链表」，JDK 1.8 起链表过长会转红黑树，因此完整表述是「数组 + 链表 + 红黑树」。
- **定位桶**：`key.hashCode()` 先经扰动函数（`h ^ (h >>> 16)`，让高位也参与运算）处理，再用 `(n - 1) & hash` 取模得到数组下标；容量取 2 的幂，取模即等价于按位与。
- **冲突处理**：落到同一个桶的节点用链表串起来；链表长度 > 8 **且**数组容量 ≥ 64 时树化为红黑树，把最坏查找从 O(n) 降到 O(log n)，节点数降到 6 以下再退化回链表。
- **扩容**：默认初始容量 16、负载因子 0.75，元素数超过 `16 × 0.75 = 12` 触发扩容、容量翻倍。1.8 迁移时不再重算哈希，而是用 `hash & oldCap` 把一个桶拆成「留在原位」和「原位置 + 旧容量」两条链。
- **key 的约定**：必须**同时**正确实现 `hashCode()` 与 `equals()`——前者决定落在哪个桶，后者负责在桶内判定是不是同一个 key；只实现一个会出现查不到、或者插入重复 key。

| 常见追问 | 本文档对应小节 |
|---|---|
| 扩容机制细节 | 「六、Java 中 HashMap 的扩容机制是怎样的？」 |
| 容量为什么必须是 2 的 n 次方 | 「二十一、为什么 HashMap 的容量必须是 2 的 n 次方？」 |
| 默认负载因子为什么是 0.75 | 「二十三、为什么 Java 中 HashMap 的默认负载因子是 0.75？」 |
| 1.8 为什么引入红黑树 | 「二十二、为什么 JDK 1.8 对 HashMap 进行了红黑树的改动？」 |
| Hash 碰撞与解法 | 「二十五、什么是 Hash 碰撞？怎么解决哈希碰撞？」 |
| 1.7 头插法带来的扩容成环 | 「一、JDK 1.8 对 HashMap 除了红黑树还进行了哪些改动？」 |
| 提升性能的技巧 | 「三十二、使用 HashMap 时，有哪些提升性能的技巧？」 |

> 面试口径：主干 20 秒说完（结构 → 定位 → 冲突 → 扩容 → key 约定），追问再按上表跳到对应小节，避免一上来就堆源码细节。

---

## 三十九、Java 中如何创建多线程？

**回答重点**

必答句：**真正创建线程的动作只有 `Thread.start()`（线程池也是在池内做同一件事），`run()` / `call()` 只是任务描述——所以五种方式可以归纳为「三种自己起线程」+「两种交给池子」。**

| 方式 | 关键 API | 是否返回结果 | 适用场景 | 局限 |
|---|---|---|---|---|
| 实现 `Runnable` | `new Thread(r).start()` | 否 | 任务与线程解耦，日常最常用 | `run()` 不能抛检查异常 |
| 继承 `Thread` | `class T extends Thread` 重写 `run()` 后 `start()` | 否 | 教学 / 极简 demo | 占用唯一的继承位，任务与线程耦合 |
| `Callable` + `FutureTask` | `new FutureTask<>(c)` → `new Thread(task).start()` → `task.get()` | 是（可抛检查异常） | 需要返回值 / 异常需要回传 | `get()` 阻塞，结果只能取一次 |
| 线程池 `ExecutorService` | `pool.submit(r)` / `pool.execute(r)` | `submit` 返回 `Future` | 生产环境首选：复用线程、控制并发 | `Executors` 工厂可能配无界队列 |
| `CompletableFuture` | `runAsync` / `supplyAsync` + `thenApply` / `thenCombine` | 是（`join()` / `get()`） | 编排多步异步、组合依赖 | 默认共享 `ForkJoinPool.commonPool()` |

**常见追问**

- `run()` ≠ `start()`：直接调 `run()` 只是当前线程里一次普通方法调用，不会开新线程；只有 `start()` 才会让 JVM 创建线程并调度到 `RUNNABLE`。
- `Runnable.run()` 的签名没有 `throws`，检查异常只能自己 try-catch 或包成 `RuntimeException`；既要返回值、又要抛检查异常就用 `Callable`。
- `FutureTask.get()` / `Future.get()` 是**阻塞**的：在循环里逐个 `get()` 会把并行退化成串行——应先提交全部任务再统一取结果，或用 `CompletableFuture` 编排、`get(timeout)` 兜底。
- `Executors.newFixedThreadPool` / `newSingleThreadExecutor` 内部是 `LinkedBlockingQueue`（默认无界），任务积压就会 OOM；`newCachedThreadPool` 的 `maximumPoolSize` 是 `Integer.MAX_VALUE`，并发一高直接打爆机器。生产环境手写 `new ThreadPoolExecutor(core, max, keepAlive, unit, new ArrayBlockingQueue<>(cap), threadFactory, handler)` 显式指定队列容量与拒绝策略。
- `CompletableFuture` 不传 Executor 时用的是 `ForkJoinPool.commonPool()`，并行度 = **CPU 核数 - 1**，往里塞阻塞 IO 会连带拖慢整个 JVM 的 `parallelStream`，IO 密集任务必须传自己的线程池。

**虚拟线程（Java 21 正式）**：`Thread.startVirtualThread(r)` / `Thread.ofVirtual().start(r)`，由 JVM 把成千上万个虚拟线程复用到少量载体线程上，创建与切换成本极低，适合「数量多、以阻塞 IO 为主」的任务；但它**不适合 CPU 密集任务**，且阻塞在 `synchronized` 块里会**钉住（pin）载体线程**，这类代码应改用 `ReentrantLock`。

线程数怎么定、队列怎么选见本文档「三十三、如何合理地设置 Java 线程池的线程数？」；要让多个线程按指定顺序执行见「三十四、如何在 Java 中控制多个线程的执行顺序？」；`NEW` → `RUNNABLE` → `TERMINATED` 的状态流转见「三十六、线程的生命周期在 Java 中是如何定义的？」。

> 相关：[[Java 15 - 线程基础]]、[[Java 16 - 锁与并发工具]]

---

## 四十、Java 中的 final 关键字是否能保证变量的可见性？

**回答重点**

必答句：**不能保证并发意义上的可见性**——一个线程改了值、另一个线程立刻能看到，这件事只有 `volatile`（或 `synchronized` 的锁语义）能做到。有些答案说「final 可以保证可见性」，指的是另一件事：**final 域的初始化安全发布**。

| 「可见性」的两种含义 | 含义 | 谁能保证 |
|---|---|---|
| 并发可见性（常说的那个） | 线程 A 运行期修改共享变量，线程 B 立刻读到最新值 | `volatile`、`synchronized` / `Lock`；**final 做不到** |
| 初始化可见性（安全发布） | 对象构造完成后，其他线程拿到的 final 域**必定**是构造器里写入的值 | final 域重排序规则；前提是构造期间 `this` 未逸出 |

**两条 final 重排序规则**（JSR-133 内存模型）：

1. 构造器内对 final 域的写入，与随后把该对象的引用赋给一个引用变量，**不能重排序**（编译期在 final 写之后插入 StoreStore 屏障）。
2. 初次读「指向该对象的引用」，与随后初次读该对象的 final 域，**不能重排序**（LoadLoad 屏障）。

对比非 final 字段：构造器内的写入可能被重排序到构造器之外，于是别的线程能拿到「引用已发布、字段还是默认值」的半初始化对象——这正是双重检查锁单例必须给实例字段加 `volatile` 的原因。

```java
public class YesFinalTest {
    final int a;   // 构造完成后，其他线程读到的肯定是 1
    int b;         // 可能读到 0（写操作被重排到构造器之后）
    static YesFinalTest testObj;

    YesFinalTest() { a = 1; b = 2; }

    static void newObj() { testObj = new YesFinalTest(); }   // 线程 A
    static void read()   { YesFinalTest o = testObj;          // 线程 B（引用非 null 时）
                           int x = o.a; int y = o.b; }
}
```

**常见追问**

- **前提条件**：构造函数里没有把 `this` 传递出去（注册监听器、启动线程、把 `this` 塞进静态集合都算逸出），否则 final 的保证失效。
- **只保证引用本身**：`final List<String> list` 只保证 `list` 这个引用可见，`list` 内部元素的增删仍不是线程安全的；对象若可变，内部状态照样要用 `volatile` / 锁保护。
- **配合不可变类**：「所有字段 final + 构造期不逸出」= 天然线程安全的不可变对象，可以自由共享而无需同步。

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 29 - Synchronized 关键字详解]]；三大性质总览见本文档「二十八、什么是 Java 中的原子性、可见性和有序性？」

---

## 四十一、Java 线程池核心线程数在运行过程中能修改吗？如何修改？

**回答重点**

必答句：**能，且立即生效**。`ThreadPoolExecutor` 暴露了 `setCorePoolSize(int)` 与 `setMaximumPoolSize(int)`，运行期调用即可改，不需要重建线程池。

| 方法 | 校验 | 生效方式 |
|---|---|---|
| `setCorePoolSize(n)` | `n ≥ 0` 且 `n ≤ maximumPoolSize`，否则 `IllegalArgumentException` | 调大：立即补建线程，数量 = `min(n − 原值, 队列中待处理任务数)`；调小：中断空闲线程，超出部分在空闲 `keepAliveTime` 后退出 |
| `setMaximumPoolSize(n)` | `n ≥ corePoolSize`，否则 `IllegalArgumentException` | 只影响后续「核心满 + 队列满」时的扩容上限，已存在的线程不会立刻回收 |
| `allowCoreThreadTimeOut(true)` | 必须 `keepAliveTime > 0`，否则 `IllegalArgumentException` | 核心线程空闲超时也回收，池可缩到 0 个线程 |

**关键细节**

- 缩容**不会中断正在执行的任务**：`setCorePoolSize` 里走的是 `interruptIdleWorkers()`，只唤醒空闲线程；多余线程回到 `getTask()` 后，因为 `timed = allowCoreThreadTimeOut || wc > corePoolSize` 为真，再空闲一个 `keepAliveTime` 才真正退出。所以「改完 core 但活跃线程数没降」不是没生效，而是还没到回收时机。
- 扩容是**懒**的：只有当队列里有任务时才补线程（源码里 `Math.min(delta, workQueue.size())` 上限），队列空时不会凭空创建。
- 默认核心线程常驻不回收，是为了避免频繁创建/销毁线程的开销；只有负载波动大的场景才配合 `allowCoreThreadTimeOut(true)` 让池能缩到 0。
- 生产上的「动态线程池」（Hippo4j、DynamicTp 等）本质就是**监控 `activeCount` / `queue.size()` / 拒绝次数 → 调这两个 setter**；直接暴露 JMX 指标 + 配置中心也能做到同样效果。注意调整要设上下限，线程数过大会抢 CPU 与内存，反而拖慢系统。

> 相关：[[Java 16 - 锁与并发工具]]；线程数取值公式见本文档「三十三、如何合理地设置 Java 线程池的线程数？」，七参数与队列/拒绝策略见「十五、Java 并发库中提供了哪些线程池实现？」

---

## 四十二、什么是 Java 内存模型（JMM）？

**回答重点**

必答句：**JMM 是 JVM 规范层面对「多线程如何读写共享变量」的抽象约定**——它规定线程何时从主内存读、何时把结果写回主内存，从而在存在 CPU 多级缓存与编译器/处理器重排序的真实硬件之上，仍然给出可见性、有序性（以及单个变量读写的原子性）的保证。规范落地在 JSR-133。

- **为什么需要它**：各操作系统的内存模型不同，Java 要跨平台，就必须自己定义一套规范屏蔽差异，让开发者只需用 `volatile` / `synchronized` 和 happens-before 规则就能写出并发安全的代码，不必关心底层缓存行与指令重排。
- **抽象结构**：主内存（所有线程共享，存放共享变量）+ 每个线程私有的本地内存。注意「本地内存」是抽象说法，实际对应寄存器、CPU 缓存、写缓冲区。
- **典型失效场景**：共享变量被线程 A 改过，但只更新在 A 的本地内存里，线程 B 读到的还是旧值；B 基于旧值计算并刷回主存，又把 A 的修改覆盖掉。JMM 定义的正是这两层内存之间的交互规则。
- **原子性的边界**：JMM 只保证**单个变量**的读/写是原子的（`long` / `double` 的非 volatile 读写甚至可能被拆成两次 32 位操作），`i++` 这种「读-改-写」复合操作必须靠 `synchronized`、`AtomicInteger`（CAS）保证。

**happens-before 的完整清单**：程序顺序、监视器锁（unlock → 后续 lock）、volatile 写 → 后续读、`Thread.start()` → 线程内动作、线程内动作 → 其他线程从 `join()` / `isAlive()` 感知到终止、`interrupt()` → 检测到中断的代码、对象初始化完成 → `finalize()` 开始、传递性。底层靠内存屏障（LoadLoad / StoreStore / LoadStore / StoreLoad）落实。

> 相关：[[Java 17 - JVM内存模型与GC]]；三大性质的对照表、happens-before 前四条与屏障细节见本文档「二十八、什么是 Java 中的原子性、可见性和有序性？」，volatile 的语义与 JMM 的关系见本文档「八、Java 中 volatile 关键字的作用是什么？」

---

## 四十三、如何优化 Java 中的锁的使用？

**回答重点**

必答句：优化锁只有两条主线——**让锁更小**（缩短持有时间、细化粒度、读写分离）和**根本不用锁**（CAS / 原子类 / 不可变对象 / 线程封闭）。前者降低「排队」带来的串行度，后者直接消灭竞争。

| 方向 | 具体手段 | 适用场景 | 代价 / 坑 |
|---|---|---|---|
| 缩小临界区 | 只锁必要语句，把日志、RPC、IO 移出同步块 | 任何有竞争的锁 | 拆得太碎会破坏「读-改-写」的组合原子性 |
| 细化锁粒度 | 锁分段：`ConcurrentHashMap` 1.7 拆 16 个 `Segment`、1.8 细化到桶的头节点；按业务 key 哈希取锁 | 大对象 / 大集合被多线程读写 | 分段数固定 → 热点段照样排队；锁对象变多，一次持多把锁时要防死锁 |
| 读写分离 | `ReentrantReadWriteLock`（读共享、写独占）、`StampedLock`（乐观读 + 版本戳校验） | 读多写少 | 读锁**不能**升级成写锁（必须先释放再抢）；写锁可能饥饿；`StampedLock` 不可重入、不支持 `Condition` |
| 无锁编程 | CAS + 原子类（`AtomicInteger`、`AtomicReference`），计数用 `LongAdder` 分段累加 | 计数器、状态位、单变量更新 | ABA 问题（用 `AtomicStampedReference` 加版本号）、高竞争下自旋空转 CPU 甚至总线风暴 |
| 线程封闭 | 局部变量、`ThreadLocal`、不可变对象 | 本可不必共享的状态 | `ThreadLocal` 用后必须 `remove()`——线程池复用会读到上一个请求的脏值，并造成内存泄漏 |

**扩展知识**

- **锁的类型与场景**：独占锁（`synchronized` / `ReentrantLock`）适合写多；读写锁适合读多写少；悲观锁每次操作都先加锁，乐观锁靠版本号 / CAS 做冲突检测，只在冲突概率低时划算（冲突高时自旋重试成本反而超过加锁）。
- **优化是有顺序的**：先问「这块数据非要共享吗」（改成消息队列串行化、按 key 单线程分片），再问「临界区能不能再小」，最后才考虑换更轻的锁。JVM 层的锁消除（逃逸分析）、锁粗化、自适应自旋、偏向锁 → 轻量级锁升级都是**自动**完成的，应用层不必手写。
- **别用外部锁去修补非线程安全的设计**：`HashTable`、`Collections.synchronizedMap` 是把整张表锁住，换成 `ConcurrentHashMap` 比在外面套 `synchronized` 更划算；同理「给整个方法加 `synchronized`」通常说明临界区没想清楚。

> 相关：[[Java 16 - 锁与并发工具]]、[[Java 29 - Synchronized 关键字详解]]；JVM 层的锁升级、锁消除、锁粗化、自旋见本文档「十六、Java 的 synchronized 是怎么实现的？」，CAS 原理与 ABA 见「七、Java 中 ReentrantLock 的实现原理是什么？」，分段锁到桶级锁的演进见「四、Java 中 ConcurrentHashMap 1.7 和 1.8 之间有哪些区别？」

---

## 四十四、说一下 RocketMQ 中关于事务消息的实现？

**回答重点**

必答句：RocketMQ 用**两阶段提交 + 事务回查**把「本地事务」和「发消息」绑成最终一致——先投一条消费者看不见的**半消息（Half Message）**，本地事务成功再 `Commit` 转正、失败则 `Rollback` 丢弃；生产者迟迟不表态时，Broker 主动反查本地事务状态。

- **第一阶段（发半消息）**：生产者把消息发给 Broker，消息带 `PROPERTY_TRANSACTION_PREPARED=true` 属性；Broker 在 `SendMessageProcessor#sendMessage` 里识别出这是事务消息后，把真实 topic 与队列 id 存进消息属性，**把 topic 改写成 `RMQ_SYS_TRANS_HALF_TOPIC`、队列 id 置 0** 再落盘——消费者因此完全读不到它。
- **第二阶段（跑本地事务并表态）**：生产者在 `TransactionListener#executeLocalTransaction` 里执行本地事务，返回下面三种状态之一；Commit 时 Broker 把 topic 换回来、写进真实队列让消费者可见，Rollback 时把这条半消息记进 `RMQ_SYS_TRANS_OP_HALF_TOPIC`（half_op）作为「已处理」标记。

| 状态 | 含义 | Broker 动作 |
|---|---|---|
| `COMMIT_MESSAGE` | 本地事务成功 | 半消息转正，可被消费 |
| `ROLLBACK_MESSAGE` | 本地事务失败 | 丢弃半消息，消费者永不可见 |
| `UNKNOWN` | 状态暂不可知 | 不写 half_op，稍后再次回查 |

**事务回查**：后台服务 `TransactionalMessageCheckService` 定时扫描半消息队列，对超时未决的半消息发 **oneWay** 反查请求；生产者的 `TransactionMQProducer` 线程池收到后调用 `checkLocalTransaction`，结果同样以 oneWay 回传 Broker。

**扩展知识**

- **为什么要有 half_op、为什么半消息还要重新写一遍 commitlog**：RocketMQ 的存储模型是**顺序追加、从不修改已落盘消息**，而「回查次数」必须可更新（超过上限即判定回滚）。所以每次回查前先用 `putBackHalfMsgQueue` 把半消息追加一次并推进消费位点；half_op 记录每一轮反查的结论（Commit / Rollback），下一轮扫描先按 half_op 去重，已决的直接跳过，只有 `UNKNOWN` 不落 half_op 才允许继续回查。
- **消费端必须幂等**：事务消息保证的是「本地事务成功 ⇒ 消息最终一定可被消费」，即**至少一次**；重复投递、消费失败重试都会发生，靠业务唯一键或去重表兜底，别指望「只投一次」。
- **与其它最终一致方案的取舍**：本地消息表（业务库同事务写消息表 + 定时投递）不依赖 MQ 特性、实现简单但有时延；事务消息把回查责任交给 MQ，业务代码侵入最小，代价是绑定 RocketMQ、链路更长（半消息落盘 + 回查）；最大努力通知适合跨公司场景。

> 相关：[[RocketMQ 01 - 学习路线]]、[[后端系统设计 01 - 学习路线]]

---

## 四十五、说说 MyBatis 的缓存机制？

**回答重点**

必答句：MyBatis 有两级缓存——一级缓存是 `SqlSession` 级的「会话内复用」，默认开启；二级缓存是 `namespace`（Mapper）级的跨会话共享，必须显式开启。查询顺序是**二级缓存 → 一级缓存 → 数据库**。

| 维度 | 一级缓存 | 二级缓存 |
|---|---|---|
| 作用域 | 单个 `SqlSession`（一次会话） | 同一 `namespace` 的所有 `SqlSession` |
| 缓存键 | namespace + SQL 语句 + 参数（`CacheKey`） | 同上，存进 namespace 对应的 `Cache` |
| 默认状态 | 开启，无需配置 | 关闭，需 `<cache/>` 或 `@CacheNamespace` |
| 生命周期 | 与 `SqlSession` 一致 | 与 `SqlSessionFactory` 一致 |
| 失效时机 | `commit` / `rollback` / 任何增删改 / `clearCache()` / 会话关闭 | 同 namespace 的增删改（相关语句 flushCache） |
| 存储 | 本地 `PerpetualCache`（一个 HashMap） | 可替换实现（Redis、Ehcache 等定制存储） |

**扩展知识**

- **实现是一条装饰器链**：基础 `PerpetualCache` 就是个 `HashMap`，外面逐层套 `LruCache` / `FifoCache`、`SoftReferenceCache` / `WeakCache`、`SerializedCache`（缓存对象必须可序列化）、`LoggingCache`（统计命中率）、`ScheduledCache`（定时清空）、`SynchronizedCache`、`BlockingCache`（同一 key 只放一个线程回源，防击穿）。二级缓存由 `CachingExecutor` 这层装饰器拦在 `Executor` 前面，命中即返回，不再走一级缓存与数据库。
- **脏数据的两个典型来源**：① 多 `SqlSession` 场景下 A 读到旧值、B 改库，A 仍返回缓存——分布式或多会话环境应把一级缓存收窄成语句级（`mybatis.configuration.local-cache-scope=statement`，等价于每次查询后立即清空）；② 多表联查时结果只缓存在发起查询的 namespace 里，另一张表被别的 namespace 更新并不会让它失效，形成脏读。
- **配置示例**（`readOnly="true"` 直接返回缓存对象引用，省一次拷贝，但调用方不得修改它）：

```xml
<mapper namespace="com.example.mapper.UserMapper">
    <cache eviction="LRU" flushInterval="60000" size="512" readOnly="true"/>
</mapper>
```

- **生产建议**：MyBatis 自带缓存只管单机、粒度又粗，跨节点必然不一致——线上通常**关掉二级缓存**，改用 Redis + Spring Cache 做分布式缓存，热点数据再叠一层 Caffeine / Guava 本地缓存（本地层要设短 TTL，并处理多实例失效广播）。

> 相关：[[Java 41 - MyBatis 框架学习路线]]、[[Java 工具 06 - MyBatis 多数据源整合]]

> 来源：鱼皮·编程导航 / codefather
