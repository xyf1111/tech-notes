---
title: 'Java 工具 10 - 自定义注解 Redisson 分布式锁'
date: 2026-07-29
tags: [java, spring-boot, aop, redisson, 分布式锁, 自定义注解, spel]
source: '鱼皮·编程导航 / codefather'
---

# Java 工具 10 - 自定义注解 Redisson 分布式锁

## 问题背景

使用 Redisson 分布式锁时，需手动编写获取锁、判断锁、释放锁的逻辑，导致代码重复且冗长。通过自定义 `@DistributedLock` 注解 + AOP 切面，实现声明式分布式锁——一个注解即可完成加锁、解锁全流程。

## 涉及知识

- Spring Boot + Spring AOP
- Redisson 分布式锁
- 自定义注解 + SpEL 表达式动态解析
- 统一异常处理

## 代码实现

### 引入依赖

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
  <groupId>org.redisson</groupId>
  <artifactId>redisson</artifactId>
  <version>3.21.3</version>
</dependency>
<dependency>
  <groupId>org.projectlombok</groupId>
  <artifactId>lombok</artifactId>
</dependency>
```

### 自定义注解 @DistributedLock

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface DistributedLock {
  /** 获取锁失败时的默认错误描述 */
  String errorDesc() default "任务正在处理中，请耐心等待";

  /** SpEL表达式，动态获取锁key。示例："#name" 取参数值，"#user.id" 取对象属性 */
  String[] keys() default {};

  /** key前缀，为空时取类名+方法名 */
  String prefix() default "";
}
```

### AOP 切面类

```java
@Slf4j
@Aspect
@Component
public class DistributedLockAspect {

    @Resource
    private RedissonClient redissonClient;
    private static final ParameterNameDiscoverer PARAMETER_NAME_DISCOVERER =
            new DefaultParameterNameDiscoverer();

    @Around("@annotation(distributedLock)")
    public Object around(ProceedingJoinPoint joinPoint,
                         DistributedLock distributedLock) throws Throwable {
        String redisKey = getRedisKey(joinPoint, distributedLock);
        log.info("拼接后的redisKey为：{}", redisKey);

        RLock lock = redissonClient.getLock(redisKey);
        if (!lock.tryLock()) {
            throw new RuntimeException(distributedLock.errorDesc());
        }

        try {
            return joinPoint.proceed();
        } finally {
            lock.unlock();
        }
    }

    private String getRedisKey(ProceedingJoinPoint joinPoint,
                               DistributedLock distributedLock) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        EvaluationContext context = new MethodBasedEvaluationContext(
                TypedValue.NULL, method, joinPoint.getArgs(),
                PARAMETER_NAME_DISCOVERER);

        StringBuilder redisKey = new StringBuilder();

        // 前缀：指定 prefix 或默认「类名:方法名:」
        if (StringUtil.isNotBlank(distributedLock.prefix())) {
            redisKey.append(distributedLock.prefix()).append(":");
        } else {
            String className = joinPoint.getTarget().getClass().getSimpleName();
            String methodName = joinPoint.getSignature().getName();
            redisKey.append(className).append(":").append(methodName).append(":");
        }

        // SpEL 动态解析 keys
        ExpressionParser parser = new SpelExpressionParser();
        for (String key : distributedLock.keys()) {
            Expression expression = parser.parseExpression(key);
            Object value = expression.getValue(context);
            redisKey.append(ObjectUtils.nullSafeToString(value));
        }

        return redisKey.toString();
    }
}
```

### 统一异常处理

```java
@RestControllerAdvice
public class ExceptionHandle {
    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public String sendErrorResponseSystem(Exception e) {
        return e.getMessage();
    }
}
```

> 还需配置 RedissonClient 连接 Redis，此处省略。

## 使用场景

### 1. 无参方法级锁

```java
@DistributedLock
@GetMapping("/helloWorld")
public void helloWorld() throws InterruptedException {
    System.out.println("helloWorld");
    Thread.sleep(100000);
}
```

key 为 `HelloController:helloWorld:`（类名:方法名:）。适合集群中同一时间只启动一个的自动任务场景。

### 2. 按参数值加锁

```java
@DistributedLock(keys = "#name")
@GetMapping("/hello1")
public String hello1(String name) throws InterruptedException {
    // ...
}
```

key 为 `HelloController:hello1:hurry`（传 name=hurry 时）。不同参数值对应不同锁，互不干扰。

### 3. 按对象属性加锁

```java
@DistributedLock(keys = "#user.name")
@GetMapping("/hello2")
public String hello2(User user) throws InterruptedException {
    // ...
}
```

从 User 对象中提取 `name` 属性作为锁 key。

### 4. 自定义前缀

```java
@DistributedLock(keys = "#name", prefix = "testPrefix")
@GetMapping("/hello3")
public String hello3(String name) throws InterruptedException {
    // ...
}
```

key 为 `testPrefix:hurry`，使用自定义前缀替代默认的类名:方法名:。

## 核心原理

| 步骤 | 说明 |
|------|------|
| ① 切面拦截 | `@Around` 拦截带 `@DistributedLock` 的方法 |
| ② 拼装 key | SpEL 解析 `keys` 表达式 + `prefix` 拼接 Redis key |
| ③ 尝试加锁 | `redissonClient.getLock(key).tryLock()` 非阻塞尝试 |
| ④ 执行业务 | 加锁成功则 `joinPoint.proceed()` 执行原方法 |
| ⑤ 释放锁 | `finally` 块中 `lock.unlock()` 确保解锁 |

> 来源：鱼皮·编程导航 / codefather
