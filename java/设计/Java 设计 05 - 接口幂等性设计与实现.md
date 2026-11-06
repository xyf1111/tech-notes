---
title: "Java 设计 05 - 接口幂等性设计与实现"
date: 2026-07-27
tags: [API设计, 幂等性, 分布式系统, Spring Boot, Redis]
source: "鱼皮·编程导航 / codefather"
---

# Java 设计 05 - 接口幂等性设计与实现

> 接口幂等性是指一个操作在执行一次和多次执行时结果相同，任意多次执行产生的影响与一次执行相同。

## 什么是幂等性

- **数学定义**：某一元运算作用在任一元素两次后结果与一次相同
- **计算机定义**：相同参数重复执行，结果相同，不影响系统状态

HTTP 中 `GET`、`PUT`、`DELETE` 通常被设计为幂等操作，`POST` 则非幂等。

## 常见非幂等场景

| 场景 | 说明 |
|------|------|
| 前端重复提交表单 | 网络波动致用户重复点击提交按钮 |
| 恶意刷单 | 投票等场景重复提交 |
| 接口超时重试 | HTTP 客户端默认重试机制 |
| MQ 重复消费 | 消息中间件未提交消费信息导致重复消费 |

影响面：
- **INSERT** 操作：可能产生重复数据
- **UPDATE** 操作：单纯更新状态无问题（如 `status=1`），但含计算（如 `status=status+1`）会导致数据错误

## 解决方案

### 1. Select Before Insert
INSERT 前先 SELECT 判断数据是否已存在，存在则 UPDATE，不存在则 INSERT。

### 2. 数据库唯一索引
```sql
ALTER TABLE `order` ADD UNIQUE KEY `t_code` (`code`);
```
首次插入成功，重复插入唯一索引冲突，捕获异常返回成功（防重）。

### 3. Token 机制（跨多次请求）
需要两次请求：① 获取 Token → ② 携带 Token 执行业务。

**流程：**
1. 客户端请求获取全局唯一 Token（存入 Redis，设过期时间）
2. 客户端执行业务时在请求头携带 Token
3. 服务端拦截器检查 Redis 中 Token 是否存在
4. 存在则删除 Token 并执行业务；不存在或删除失败则返回重复操作

**Token 服务实现：**
```java
@Component
public class TokenService {
    @Autowired
    RedisService redisService;

    public String createToken() {
        String uuid = UUID.randomUUID().toString();
        redisService.setEx(uuid, uuid, 10000L);
        return uuid;
    }

    public boolean checkToken(HttpServletRequest request) {
        String token = request.getHeader("token");
        if (StringUtils.isEmpty(token)) {
            token = request.getParameter("token");
        }
        if (!redisService.exists(token)) {
            throw new IdempotentException("重复的操作");
        }
        boolean remove = redisService.remove(token);
        if (!remove) {
            throw new IdempotentException("重复的操作");
        }
        return true;
    }
}
```

**自定义幂等注解 + 拦截器：**
```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface AutoIdempotent {}

@Component
public class IdempotentInterceptor implements HandlerInterceptor {
    @Autowired
    TokenService tokenService;

    @Override
    public boolean preHandle(HttpServletRequest request,
            HttpServletResponse response, Object handler) throws Exception {
        if (!(handler instanceof HandlerMethod)) return true;
        AutoIdempotent idempotent = ((HandlerMethod) handler)
            .getMethod().getAnnotation(AutoIdempotent.class);
        if (idempotent != null) {
            return tokenService.checkToken(request);
        }
        return true;
    }
}
```

### 4. 悲观锁
```sql
SELECT * FROM user WHERE id = 888 FOR UPDATE;
```
同一事务中锁住行数据，只有第一个请求能获取锁并执行 update，其余等待或返回。事务耗时较长时影响性能。

### 5. 乐观锁（版本号）
```sql
ALTER TABLE user ADD version INT DEFAULT 0;

UPDATE user SET amount = amount - 100, version = version + 1
WHERE id = 888 AND version = 1;
```
更新时对版本号加 1，判断影响行数：>0 为一次请求，=0 为重复请求。

### 6. 防重表
业务表不宜加唯一索引时，单独建防重表（id + 唯一索引）。业务操作前先插入防重表，成功则继续业务，失败（唯一索引冲突）则直接返回成功。

## 方案对比

| 方案 | 复杂度 | 适用场景 | 性能影响 |
|------|--------|----------|----------|
| Select Before Insert | 低 | INSERT 前检查 | 低 |
| 唯一索引 | 低 | 业务允许异常捕获 | 低 |
| Token 机制 | 中 | 表单/订单提交，跨多次请求 | 中（需 2 次请求） |
| 悲观锁 | 低 | 高一致性要求，低频写入 | 高（锁等待） |
| 乐观锁 | 中 | 高并发更新 | 低 |
| 防重表 | 中 | 业务表不宜加索引 | 中 |

> 来源：鱼皮·编程导航 / codefather
