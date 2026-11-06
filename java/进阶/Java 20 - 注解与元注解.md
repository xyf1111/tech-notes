---
title: "Java 20 - 注解与元注解"
date: 2026-06-11
tags: [java, 进阶]
---

# Java 20 - 注解与元注解

## 注解 (Annotation)

Java 5 引入，为代码添加元数据（metadata），可被编译器或运行时读取。

## 内置注解

| 注解 | 作用 |
|------|------|
| `@Override` | 标记重写父类方法（编译期检查） |
| `@Deprecated` | 标记废弃方法/类 |
| `@SuppressWarnings` | 抑制编译器警告 |
| `@FunctionalInterface` | 标记函数式接口（Java 8+） |
| `@SafeVarargs` | 抑制可变参数泛型警告（Java 7+） |

## 元注解

用于注解**其他注解**的注解。

| 元注解 | 说明 | 取值 |
|--------|------|------|
| `@Retention` | 注解保留策略 | `SOURCE` / `CLASS` / `RUNTIME` |
| `@Target` | 注解应用目标 | `METHOD` / `FIELD` / `TYPE` 等 |
| `@Documented` | 是否包含在 javadoc 中 | — |
| `@Inherited` | 是否被子类继承 | — |
| `@Repeatable` | 是否可重复使用（Java 8+） | — |

### @Retention 策略

| 策略 | 说明 |
|------|------|
| `RetentionPolicy.SOURCE` | 编译时丢弃，仅源码（如 `@Override`） |
| `RetentionPolicy.CLASS` | 保留在 class 文件，运行时不可读（默认） |
| `RetentionPolicy.RUNTIME` | 保留到运行时，可通过反射读取 |

### @Target 类型

`ElementType.TYPE` / `FIELD` / `METHOD` / `PARAMETER` / `CONSTRUCTOR` / `LOCAL_VARIABLE` / `ANNOTATION_TYPE` / `PACKAGE` / `TYPE_PARAMETER` / `TYPE_USE`

## 自定义注解

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Log {
    String value() default "";
    boolean enable() default true;
}
```

## 读取注解（反射）

```java
// 获取类上的注解
Class<?> clazz = MyService.class;
if (clazz.isAnnotationPresent(MyAnnotation.class)) {
    MyAnnotation anno = clazz.getAnnotation(MyAnnotation.class);
    System.out.println(anno.value());
}

// 获取方法上的注解
Method method = clazz.getMethod("doSomething");
if (method.isAnnotationPresent(Log.class)) {
    Log log = method.getAnnotation(Log.class);
    System.out.println(log.value());
}
```

## 注解的应用场景

| 框架 | 注解示例 | 用途 |
|------|----------|------|
| Spring | `@Component` `@Autowired` | 依赖注入 |
| Spring Boot | `@SpringBootApplication` | 自动配置 |
| JPA/Hibernate | `@Entity` `@Table` | ORM 映射 |
| MyBatis | `@Select` `@Insert` | SQL 映射 |
| JUnit | `@Test` `@Before` | 单元测试 |
| Lombok | `@Data` `@Getter` | 代码生成 |
