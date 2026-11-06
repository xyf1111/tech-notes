---
title: "Java 工具 06 - MyBatis 多数据源整合"
date: 2026-07-22
tags: [java, mybatis, datasource, springboot, baomidou]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 06 - MyBatis 多数据源整合

> 使用 `dynamic-datasource-spring-boot-starter` 快速为 Spring Boot + MyBatis 项目整合多数据源，实现运行时动态切换。

## 背景

业务中常需要查询多个库表的数据，但不想起多个服务。MyBatis 支持整合多数据源并随时切换，通过社区主流的 `dynamic-datasource` 组件即可实现。

## 解决方案

### 引入依赖

```xml
<dependency>
  <groupId>com.baomidou</groupId>
  <artifactId>dynamic-datasource-spring-boot-starter</artifactId>
  <version>${version}</version>
</dependency>
```

### 配置文件

```yaml
spring:
  datasource:
    dynamic:
      primary: master           # 默认数据源
      strict: false
      datasource:
        master:
          url: jdbc:mysql://localhost:3306/db1?useSSL=false&serverTimezone=Asia/Shanghai
          username: root
          password: xxxx
          driver-class-name: com.mysql.cj.jdbc.Driver
        slave_1:
          url: jdbc:mysql://localhost:3306/db2?useSSL=false&serverTimezone=Asia/Shanghai
          username: root
          password: xxxx
          driver-class-name: com.mysql.cj.jdbc.Driver
```

### 使用 @DS 注解切换数据源

在 Service 类或方法上添加 `@DS` 注解，指定数据源名称：

```java
@Service
@DS("master")
public class InterfaceInfoServiceImpl extends ServiceImpl<InterfaceInfoMapper, InterfaceInfo>
        implements InterfaceInfoService {
}

@Service
@DS("slave_1")
public class TEmailServiceImpl extends ServiceImpl<TEmailMapper, TEmail>
        implements TEmailService {
}
```

注解值为配置中的 `datasource` 名称。方法上注解优先级高于类上注解。

## 关键约定

1. **只做数据源切换**，不做其他限制，切换后可执行任何 CRUD
2. 配置文件中以下划线 `_` 分割的数据源首部为组名，同组数据源放在一个组下，切换时采用负载均衡算法
3. 可切换组名或具体数据源名称；默认数据源名称为 `master`，可通过 `spring.datasource.dynamic.primary` 修改
4. **方法注解优先于类注解**；`@DS` 支持继承抽象类上的注解，不支持接口上的注解
5. 底层基于 AOP 实现，同一个方法内不可切换数据源

## 手动实现：AbstractRoutingDataSource + 自定义注解

除使用 `dynamic-datasource-spring-boot-starter` 外，也可通过继承 `AbstractRoutingDataSource` + 自定义注解 + AOP 实现多数据源切换，**灵活性更高**，适合定制化路由场景。

### 实现步骤

1. **配置数据源** — 为读/写操作分别配置数据源
2. **继承 `AbstractRoutingDataSource`** — 根据路由键决定使用哪个数据源
3. **自定义注解 `@DataSource`** — 标记方法或类使用的数据源
4. **AOP 切面解析注解** — 将注解值存入 ThreadLocal
5. **事务管理器** — 确保跨数据源操作的事务一致性

### 核心代码

#### 1. 配置多数据源

```yaml
spring:
  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driverClassName: com.mysql.cj.jdbc.Driver
    ds:
      master:
        url: jdbc:mysql://localhost:3306/db1
        username: root
        password: xxx
      slave:
        url: jdbc:mysql://localhost:3306/db2
        username: root
        password: xxx
    initialSize: 5
    minIdle: 5
    maxActive: 20
```

#### 2. ThreadLocal 工具类

```java
public class DynamicDataSourceUtil {
    private static final ThreadLocal<String> CONTEXT_HOLDER = new ThreadLocal<>();

    public static void setDataSourceType(String dsType) {
        CONTEXT_HOLDER.set(dsType);
    }
    public static String getDataSourceType() {
        return CONTEXT_HOLDER.get();
    }
    public static void clear() {
        CONTEXT_HOLDER.remove();
    }
}
```

#### 3. 自定义 @DataSource 注解

```java
@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.METHOD})
public @interface DataSource {
    String value() default "master";  // 默认主库
}
```

#### 4. AOP 切面

```java
@Component
@Aspect
public class DataSourceAspect {

    @Pointcut("@annotation(com.example.annotation.DataSource) || " +
              "@within(com.example.annotation.DataSource)")
    public void pc() {}

    @Around("pc()")
    public Object around(ProceedingJoinPoint point) throws Throwable {
        DataSource ds = getDataSource(point);
        if (ds != null) {
            DynamicDataSourceUtil.setDataSourceType(ds.value());
        }
        try {
            return point.proceed();
        } finally {
            DynamicDataSourceUtil.clear();
        }
    }

    private DataSource getDataSource(ProceedingJoinPoint point) {
        MethodSignature sig = (MethodSignature) point.getSignature();
        DataSource annotation = AnnotationUtils.findAnnotation(
                sig.getMethod(), DataSource.class);
        if (annotation != null) return annotation;
        return AnnotationUtils.findAnnotation(
                sig.getDeclaringType(), DataSource.class);
    }
}
```

#### 5. 动态数据源

```java
@Component
public class DynamicDataSource extends AbstractRoutingDataSource {

    public DynamicDataSource(LoadDataSource loadDataSource) {
        Map<String, DataSource> map = loadDataSource.loadAllDataSource();
        super.setTargetDataSources(new HashMap<>(map));
        super.setDefaultTargetDataSource(map.get("master"));
        super.afterPropertiesSet();
    }

    @Override
    protected Object determineCurrentLookupKey() {
        return DynamicDataSourceUtil.getDataSourceType();
    }
}
```

#### 6. 使用示例

```java
@Service
public class UserService {
    @Autowired
    private UserMapper userMapper;

    @DataSource("slave")   // 指定从库
    public List<User> getAll() {
        return userMapper.getAll();
    }
}
```

### 方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| **dynamic-datasource-starter** | 开箱即用、配置简单、支持负载均衡 | 依赖外部组件、定制能力受限 |
| **AbstractRoutingDataSource + AOP** | 灵活可控、无额外依赖、完全自定义路由逻辑 | 需要手写模板代码、事务管理需额外处理 |

> 来源：鱼皮·编程导航 / codefather
