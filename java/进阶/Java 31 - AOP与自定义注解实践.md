---
title: "Java 31 - AOP 与自定义注解实践"
date: 2026-07-27
tags: [java, aop, spring-boot, annotation]
source: "鱼皮·编程导航 / codefather"
---

# Java 31 - AOP 与自定义注解实践

## 问题背景
- 每个接口方法首尾手动加日志导致大量冗余代码
- AOP 可将日志逻辑抽取到切面，一次编写、全局生效

## 自定义注解定义
- 使用 `@interface` 关键字定义注解

```java
public @interface LogInfo {

}
```

- 关键元注解及其用途：

| 元注解 | 作用 |
|--------|------|
| `@Retention` | 保留策略：`RUNTIME`（运行时反射可读）、`CLASS`（字节码中保留，运行时丢弃）、`SOURCE`（仅源码级，编译时丢弃） |
| `@Target` | 目标类型：`METHOD`（方法）、`FIELD`（字段）、`TYPE`（类/接口）、`PARAMETER`（参数）、`CONSTRUCTOR`（构造器）等 |
| `@Documented` | 注解信息会包含在 Javadoc 文档中 |
| `@Inherited` | 子类继承父类的该注解 |
| `@Repeatable` | 允许同一目标上多次标注相同注解 |

## AOP 实现

### 引入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

### @Before + @After 方式

- `@Aspect` 声明切面类，`@Component` 注入容器
- `@Before("@annotation(LogInfo)")`：方法执行前记录类名、方法名、入参
- `@After("@annotation(LogInfo)")`：方法执行后记录结束标记
- `JoinPoint` 获取类名、方法签名、参数列表

```java
@Aspect
@Component
@Slf4j
public class LogAOP {

    @Before("@annotation(LogInfo)")
    public void logBefore(JoinPoint joinPoint) {
        String fullClassName = joinPoint.getSignature().getDeclaringTypeName();
        String methodName = joinPoint.getSignature().getName();
        String[] classNameParts = fullClassName.split("\\.");
        String className = classNameParts[classNameParts.length - 1];

        log.info(className + "****************" + methodName + "****************start");

        Object[] args = joinPoint.getArgs();
        Map<String, Object> map = new HashMap<>();
        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        String[] parameterNames = methodSignature.getParameterNames();
        if (parameterNames != null) {
            for (int i = 0; i < args.length; i++) {
                if (parameterNames.length > i) {
                    map.put(parameterNames[i], args[i]);
                }
            }
        }
        JSONObject json = new JSONObject(map);
        log.info("入参：" + json);
    }

    @After("@annotation(LogInfo)")
    public void logAfter(JoinPoint joinPoint) {
        String fullClassName = joinPoint.getSignature().getDeclaringTypeName();
        String methodName = joinPoint.getSignature().getName();
        String[] classNameParts = fullClassName.split("\\.");
        String className = classNameParts[classNameParts.length - 1];

        log.info(className + "****************" + methodName + "****************end");
    }
}
```

### @Around 统一方式

- `@Around("@annotation(LogInfo)")` 合并前后逻辑
- `Object result = joinPoint.proceed()` 分隔前置和后置代码
- 入参必须是 `ProceedingJoinPoint`

```java
@Aspect
@Component
@Slf4j
public class LogAOP {

    @Around("@annotation(LogInfo)")
    public void logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        // 前置：获取类名、方法名、入参（同 @Before 逻辑）
        String fullClassName = joinPoint.getSignature().getDeclaringTypeName();
        String methodName = joinPoint.getSignature().getName();
        String[] classNameParts = fullClassName.split("\\.");
        String className = classNameParts[classNameParts.length - 1];
        log.info(className + "****************" + methodName + "****************start");

        Object[] args = joinPoint.getArgs();
        Map<String, Object> map = new HashMap<>();
        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();
        String[] parameterNames = methodSignature.getParameterNames();
        if (parameterNames != null) {
            for (int i = 0; i < args.length; i++) {
                if (parameterNames.length > i) {
                    map.put(parameterNames[i], args[i]);
                }
            }
        }
        log.info("入参：" + new JSONObject(map));

        // 执行原方法
        Object result = joinPoint.proceed();

        // 后置
        log.info(className + "****************" + methodName + "****************end");
    }
}
```

### 使用示例

```java
@LogInfo
@GetMapping("/get")
public String get(String name, int age) {
    System.out.println("执行了get方法");
    return name;
}
```

## 实际应用场景

### 审计日志 vs 系统日志

| 类型 | 说明 | 适用方式 |
|------|------|----------|
| **系统日志** | 记录所有接口运行状态和事件，用于系统监控和故障排查 | 拦截器，按包路径匹配 |
| **审计日志** | 仅记录用户操作的关键步骤（如创建、删除、权限变更），用于合规追踪 | 自定义注解，按需标记 |

### 拦截器实现

- `@Around("execution(* com.xxx.controller.*.*(..))")` 按包路径匹配全部方法
- 无需在每个方法上加注解，适合系统级日志
- 自定义注解更灵活，适合需要选择性记录的审计场景

```java
@Around("execution(* com.xxx.controller.*.*(..))")
public void logInterceptor(ProceedingJoinPoint joinPoint) throws Throwable {
    // 内容与 logAround 方法相同
    String methodName = joinPoint.getSignature().getName();
    log.info("记录方法：" + methodName);
    Object result = joinPoint.proceed();
}
```

切点表达式解析：`execution(* com.xxx.controller.*.*(..))`

- 第一个 `*`：任意返回类型
- `com.xxx.controller.*`：该包下的任意类
- 第二个 `*`：任意方法名
- `(..)`：任意参数列表

> 来源：鱼皮·编程导航 / codefather
