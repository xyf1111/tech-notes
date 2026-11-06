---
title: Java 34 - 函数式接口与Lambda表达式
date: 2026-07-28
tags: [java, 函数式接口, Consumer, Supplier, Function, Predicate, lambda, sa-token]
source: '鱼皮·编程导航 / codefather'
---

# Java 34 - 函数式接口与Lambda表达式

Java 四大核心函数式接口（Consumer、Supplier、Function、Predicate）的用法、JDK 源码解析及 Sa-Token 实战示例。

## Consumer（顾客）：消费数据，无返回值

Consumer 即消费者，接收一个泛型参数，消费数据但不返回结果。

### 示例

```java
Consumer<String> customer = food -> System.out.println("吃掉了：" + food);
customer.accept("美味牛排");
```

### JDK 源码

```java
@FunctionalInterface
public interface Consumer<T> {
    void accept(T var1);

    default Consumer<T> andThen(Consumer<? super T> after) {
        Objects.requireNonNull(after);
        return (t) -> {
            this.accept(t);
            after.accept(t);
        };
    }
}
```

核心方法 `accept(T)` 接收参数，返回 void。`andThen` 提供链式调用，连续执行多个消费操作。

### Sa-Token 实战：注解鉴权

在 Sa-Token 中，`SaCheckMethodAnnotationFunction` 继承 `Consumer<Method>`，用于对 Method 对象进行注解校验：

```java
@FunctionalInterface
public interface SaCheckMethodAnnotationFunction extends Consumer<Method> {
}

// 实现：先校验类注解，再校验方法注解
public SaCheckMethodAnnotationFunction checkMethodAnnotation = (method) -> {
    instance.checkElementAnnotation.accept(method.getDeclaringClass());
    instance.checkElementAnnotation.accept(method);
};
```

### 应用场景

| 场景 | 说明 |
|------|------|
| 数据打印 | `Consumer<String> print = System.out::println;` |
| 数据校验 | 校验字符串是否包含特定内容，不满足则抛异常 |
| 批量处理 | 对集合中每个元素执行统一操作 |

## Supplier（厨师）：提供数据，无参数

Supplier 即供应者，不接受参数，返回一个泛型结果。

### 示例

```java
Supplier<String> chef = () -> "美味牛排";
String food = chef.get();
System.out.println("厨师准备了：" + food);
```

### JDK 源码

```java
@FunctionalInterface
public interface Supplier<T> {
    T get();
}
```

极简接口：只有一个 `get()` 抽象方法，返回泛型 T。

### Sa-Token 实战：OAuth 未登录视图

```java
public Supplier<Object> notLoginView = () -> "当前会话在OAuth-Server认证中心尚未登录";
```

用于懒加载默认返回内容，只有在真正调用 `get()` 时才执行逻辑。

### 应用场景

| 场景 | 说明 |
|------|------|
| 生成随机 ID | `Supplier<String> idGen = IdUtil::simpleUUID;` |
| 对象工厂 | `Supplier<Person> factory = () -> new Person("Alice");` |
| 延迟计算 | 仅在需要时通过 `get()` 触发计算，避免提前开销 |

## Function（服务员）：数据转换，一进一出

Function<T, R> 接收类型 T 的参数，返回类型 R 的结果，典型的数据转换器。

### 示例

```java
Function<String, String> waiter = food -> "加工后的" + food;
Supplier<String> chef = () -> "美味牛排";
String processedFood = waiter.apply(chef.get());
System.out.println("服务员送来了：" + processedFood);
```

### JDK 源码

```java
@FunctionalInterface
public interface Function<T, R> {
    R apply(T var1);

    default <V> Function<V, R> compose(Function<? super V, ? extends T> before) {
        Objects.requireNonNull(before);
        return (v) -> this.apply(before.apply(v));
    }

    default <V> Function<T, V> andThen(Function<? super R, ? extends V> after) {
        Objects.requireNonNull(after);
        return (t) -> after.apply(this.apply(t));
    }

    static <T> Function<T, T> identity() {
        return (t) -> t;
    }
}
```

- `apply(T)`：抽象方法，执行转换
- `compose`：先执行入参函数，再执行当前函数
- `andThen`：先执行当前函数，再执行入参函数
- `identity`：返回输入本身

### Sa-Token 实战：创建 SaSession

```java
@FunctionalInterface
public interface SaCreateSessionFunction extends Function<String, SaSession> {
}
```

接收 SessionId 字符串，返回 SaSession 对象，用于定制 Session 创建策略。

### 应用场景

| 场景 | 说明 |
|------|------|
| 类型转换 | `Function<String, Integer> strToInt = Integer::parseInt;` |
| 函数组合 | `strToInt.andThen(intToStr)` 将多个转换串联 |
| 数据加工 | 对输入进行清洗、映射、格式化后再输出 |

## Predicate（菜单选择标准）：条件判断，返回布尔值

Predicate 即断言，接收一个参数，返回 boolean 值，用于条件过滤。

### 示例

```java
Predicate<String> isSteak = food -> food.equals("美味牛排");
Supplier<String> chef = () -> "美味牛排";
if (isSteak.test(chef.get())) {
    System.out.println("顾客点了牛排！");
}
```

### JDK 源码

```java
@FunctionalInterface
public interface Predicate<T> {
    boolean test(T var1);

    default Predicate<T> and(Predicate<? super T> other) {
        Objects.requireNonNull(other);
        return (t) -> this.test(t) && other.test(t);
    }

    default Predicate<T> negate() {
        return (t) -> !this.test(t);
    }

    default Predicate<T> or(Predicate<? super T> other) {
        Objects.requireNonNull(other);
        return (t) -> this.test(t) || other.test(t);
    }

    static <T> Predicate<T> isEqual(Object targetRef) {
        return null == targetRef ? Objects::isNull : (object) -> targetRef.equals(object);
    }

    static <T> Predicate<T> not(Predicate<? super T> target) {
        Objects.requireNonNull(target);
        return target.negate();
    }
}
```

- `test(T)`：抽象方法，执行条件判断
- `and` / `or` / `negate`：逻辑组合，类似于 `&&` / `||` / `!`
- `isEqual`：创建相等性断言
- `not`：对现有断言取反

### 应用场景

| 场景 | 说明 |
|------|------|
| 过滤集合 | `list.stream().filter(isEven).collect(...)` |
| 数据校验 | 判断数字是否为偶数、字符串是否匹配正则 |
| 组合条件 | `isEven.and(isPositive)` 实现多条件筛选 |

> 来源：鱼皮·编程导航 / codefather
