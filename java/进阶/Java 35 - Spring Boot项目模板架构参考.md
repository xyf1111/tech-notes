---
title: "Java 35 - Spring Boot 项目模板架构参考"
date: 2026-07-29
tags: [java, spring-boot, project-template]
source: "鱼皮·编程导航 / codefather"
---

# Java 35 - Spring Boot 项目模板架构参考

本文基于鱼皮（yupi）的用户中心 Spring Boot 项目模板，梳理各模块职责与配置要点。

> **已覆盖内容快速提示**：AOP 自定义注解 + 权限校验（参见 [[Java 31 - AOP与自定义注解实践]]）、统一响应格式 BaseResponse / ResultUtils / ErrorCode（参见 [[Java 25 - RESTful 接口规范]]）、全局异常处理 BusinessException / GlobalExceptionHandler（参见 [[Java 21 - 异常处理机制]]）——本文不再赘述，仅做简要提及。

---

## 1. application.yml 核心配置

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/my_db
    username: root
    password: your_password
  redis:
    host: localhost
    port: 6379
    password: your_redis_password
```

- 数据库：修改 `url`、`username`、`password` 指向实际库
- Redis：按需修改密码；若启用 Redis，需在 Spring Boot 启动类中做对应配置

---

## 2. 拦截器（AOP 模式）

### AuthInterceptor（权限校验）

> 详情见 [[Java 31 - AOP与自定义注解实践]]

- 自定义 `@AuthCheck` 注解，标注方法所需角色（admin / user / ban）
- `@Around` 环绕通知拦截所有带 `@AuthCheck` 的方法，校验当前用户角色是否匹配

### LogInterceptor（请求日志）

- `@Around` + 切入点表达式拦截 `com.yupi.springbootinit.controller` 下所有方法
- 打印请求方法、参数、耗时等信息，辅助调试与异常追踪

---

## 3. 统一响应封装

> 详情见 [[Java 25 - RESTful 接口规范]] 与 [[Java 21 - 异常处理机制]]

- **BaseResponse**：通用返回类，含 `code`（状态码）、`data`（数据）、`message`（提示信息）
- **ResultUtils**：静态工厂方法，简化成功/失败响应的构造（`success(data)` → code=0, message="ok"）
- **ErrorCode**：枚举类，统一管理业务错误码（如无权限 40300、服务器内部异常 50000）

---

## 4. 配置类（重点：现有文档未覆盖的内容）

### 4.1 JsonConfig — Long 精度丢失处理

**问题场景**：数据库主键使用雪花算法（Snowflake ID），生成的 ID 超过 17 位，JavaScript 无法精确表示长整型，前端精度丢失。

**解决方案**：自定义 Jackson 序列化器，将 `Long` / `long` 类型转为字符串输出。

```java
@JsonComponent
public class JsonConfig {

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jsonCustomizer() {
        return builder -> {
            builder.serializerByType(Long.class, ToStringSerializer.instance);
            builder.serializerByType(Long.TYPE, ToStringSerializer.instance);
        };
    }
}
```

- `@JsonComponent` 声明自定义 JSON 序列化/反序列化组件
- `ToStringSerializer.instance` 将 Long 序列化为字符串，避免前端精度丢失

**为什么 JS 存不下（原理）**：JS 的 Number 类型总长 64 位，但用 53 位表示尾数、10 位指数、1 位符号，能精确表示的整数范围只有 -2^53 ~ 2^53（约 16 位十进制）；而 Java Long 最大 2^63-1（约 19 位）。因此 Long 经 JSON 传给前端后，超过 16 位的数字末尾会丢精度（案例：后端返回 123456789123456789，前端展示 123456789123456780）。该问题只在数字超过 16 位时出现，可据此特征快速判断。

**排查定位要点**：后端用 curl 测接口返回正确、前端 F12 查看网络请求的**原生返回**（而非浏览器二次处理的格式化数据）也正确 → 数据链路本身没问题，锅在前端 JS 的解析/数字表示层，不用怀疑接口。修复优先在后端（统一序列化为字符串）；前端虽可用正则解析替换或修改 json parser 绕过，但实现麻烦且易遗漏。

### 4.2 Knife4jConfig — 接口文档

- Knife4j 是 Swagger 的增强版，提供更友好的在线调试界面
- `@Profile("dev")` 配合 `spring.profiles.active`，仅在开发/测试环境生效

```java
@Configuration
@Profile("dev")
public class Knife4jConfig {

    @Bean
    public Docket docket() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.yupi.springbootinit.controller"))
                .build();
    }
}
```

> **注意**：`basePackage` 需修改为实际 Controller 层包名，否则 Knife4j 无法扫到接口。

### 4.3 CorsConfig — 跨域配置

前后端分离架构下，跨域是常见问题。以下配置允许指定来源访问后端资源。

```java
@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.addAllowedOriginPattern("*");      // 允许的域名
        config.setAllowCredentials(true);          // 是否允许携带 Cookie
        config.addAllowedMethod("*");              // 允许的 HTTP 方法
        config.addAllowedHeader("*");              // 允许的请求头
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return new CorsFilter(source);
    }
}
```

- `addAllowedOriginPattern`：可精确指定域名或使用通配符
- `setAllowCredentials(true)`：允许前端请求携带 Cookie

### 4.4 MyBatisPlusConfig — 分页插件

```java
@Configuration
@MapperScan("com.yupi.springbootinit.mapper")
public class MyBatisPlusConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
```

- `@MapperScan` 指定 Mapper 扫描路径，按实际包名修改
- `PaginationInnerInterceptor` 添加分页插件
- MyBatis-Plus 还提供乐观锁、多租户、动态表名等插件，参见 [官方文档](https://www.baomidou.com/pages/24112f/)

### 4.5 CosClientConfig — 腾讯云对象存储

```yaml
cos:
  client:
    accessKey: your_accessKey
    secretKey: your_secretKey
    region: ap-guangzhou
    bucket: your-bucket-123456
```

- 在 `application.yml` 中配置后，配合工具类实现文件上传/下载
- 适用于图片、文件等静态资源的对象存储

### 4.6 WxOpenConfig — 微信开放平台配置

```yaml
wx:
  open:
    appId: your_appId
    appSecret: your_appSecret
```

- 用于微信扫码登录、公众号/小程序对接
- 在微信开放平台申请后替换对应配置即可

---

## 5. 全局异常处理

> 基础机制见 [[Java 21 - 异常处理机制]]

- **BusinessException**：自定义业务异常，继承 `RuntimeException`，含 `code` + `message`，与 `ErrorCode` 枚举配合使用
- **GlobalExceptionHandler**：`@RestControllerAdvice` + `@ExceptionHandler` 统一捕获并格式化异常响应
- **ThrowUtils**：静态工具方法，简化参数校验——条件不满足时直接抛出 `BusinessException`

---

## 6. 定时同步：数据库 → Elasticsearch

### IncSyncPostToEs（增量同步）

- `@Component` + `@Scheduled(fixedDelay = 60000)`：每分钟执行一次
- 将最近变更的帖子数据写入 ES，保持搜索数据新鲜度

### FullSyncPostToEs（全量同步）

- `@Scheduled(cron = "0 0 0 * * ?")`：每天凌晨执行
- 全量重建 ES 索引，保证数据最终一致

**适用场景**：

1. **热点数据缓存**：如 Top10 接口调用统计，定时同步到 Redis，避免每次查询数据库
2. **稳定接口结果缓存**：不需要用户传参且结果几乎不变的接口，定时同步到 Redis 以提升 QPS

---

## 7. 工具类

### NetUtils — 获取客户端 IP

```java
public class NetUtils {
    public static String getIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        // 多个代理时取第一个 IP
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        return ip;
    }
}
```

- 通过逐级检查请求头获取真实客户端 IP，避免代理层干扰

### SpringContextUtils — 获取 Spring 容器

```java
@Component
public class SpringContextUtils implements ApplicationContextAware {
    private static ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) {
        SpringContextUtils.applicationContext = applicationContext;
    }

    public static <T> T getBean(String name) {
        return (T) applicationContext.getBean(name);
    }

    public static <T> T getBean(Class<T> clazz) {
        return applicationContext.getBean(clazz);
    }
}
```

- 在非 Spring 管理的类（如工具类、线程池）中获取 Bean 的桥梁
- 通过 `ApplicationContextAware` 接口注入上下文后静态持有

### SqlUtils — SQL 注入检查

```java
public class SqlUtils {
    public static boolean validSortField(String sortField) {
        // 仅允许字母、数字、下划线，防止 SQL 注入
        return sortField.matches("^[a-zA-Z0-9_]+$");
    }
}
```

- 用于动态排序字段的入参校验
- 拒绝包含特殊字符或 SQL 关键字的输入，拦截注入攻击

---

## 总结

| 类别 | 模块 | 核心作用 |
|------|------|----------|
| 配置 | application.yml | 数据库、Redis 环境配置 |
| AOP | AuthInterceptor / LogInterceptor | 权限校验 + 请求日志 |
| 响应封装 | BaseResponse / ResultUtils / ErrorCode | 统一接口返回格式 |
| 序列化 | JsonConfig | 解决 Long 精度丢失 |
| 文档 | Knife4jConfig | 在线接口调试 |
| 跨域 | CorsConfig | 前后端分离跨域放行 |
| ORM | MyBatisPlusConfig | 分页插件 + Mapper 扫描 |
| 存储 | CosClientConfig | 腾讯云对象存储 |
| 三方登录 | WxOpenConfig | 微信开放平台对接 |
| 异常处理 | BusinessException / GlobalExceptionHandler / ThrowUtils | 全局异常统一处理 |
| 定时任务 | IncSyncPostToEs / FullSyncPostToEs | 数据库与 ES 数据同步 |
| 工具类 | NetUtils / SpringContextUtils / SqlUtils | IP 获取、容器访问、SQL 防注入 |
