---
title: 中间件 - Nacos 配置中心
date: 2026-07-23
tags:
  - nacos
  - 配置中心
  - 中间件
  - spring-cloud
source: "鱼皮·编程导航 / codefather"
---

# Nacos 配置中心

> Nacos 是阿里开源的动态服务发现、配置管理和服务管理平台。

## 安装与启动

### 版本选择
选择稳定版（非 beta），从 [GitHub Releases](https://github.com/alibaba/nacos/releases) 下载。

### 单机启动
```bash
sh startup.sh -m standalone
```

查看启动日志确认状态：
```bash
tail -n 5 /path/to/nacos/logs/start.out
```

访问控制台：`http://127.0.0.1:8848/nacos`（默认账号密码：nacos/nacos）

## Spring Boot 集成

### 依赖
```xml
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-bootstrap</artifactId>
  <version>3.1.3</version>
</dependency>
<dependency>
  <groupId>com.alibaba.boot</groupId>
  <artifactId>nacos-config-spring-boot-starter</artifactId>
  <version>0.2.12</version>
</dependency>
```

### 配置
```yaml
nacos:
  config:
    server-addr: 127.0.0.1:8848
    auto-refresh: true
    group: DEFAULT_GROUP
    username: nacos
    password: nacos
    namespace: projectName
```

> **注意**：`nacos.config.bootstrap.enable` 为 true 时才能从 Nacos 读取启动配置（如端口号）。

### 使用方式

**方式一：@NacosConfigListener 监听配置变更**
```java
@NacosConfigListener(dataId = "nacos-test-config")
public void onChange(String config) {
    try {
        vipConfigList = JSONUtil.toList(config, VipConfig.class);
    } catch (Exception e) {
        throw new RuntimeException(e);
    }
}
```

**方式二：@NacosInjected 注入 ConfigService**
```java
@NacosInjected
private ConfigService configService;

@PostConstruct
public void initVipConfig() {
    try {
        String content = configService.getConfig(dataId, groupId, 5000);
        vipConfigList = JSONUtil.toList(content, VipConfig.class);
    } catch (NacosException e) {
        e.printStackTrace();
    }
}
```

## Spring Cloud 集成

### 依赖
```xml
<dependency>
  <groupId>com.alibaba.cloud</groupId>
  <artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>
  <version>${cloud.alibaba}</version>
</dependency>
<dependency>
  <groupId>org.springframework.cloud</groupId>
  <artifactId>spring-cloud-starter-bootstrap</artifactId>
  <version>3.0.3</version>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

### 配置（bootstrap.yml）
```yaml
spring:
  cloud:
    nacos:
      config:
        server-addr: 127.0.0.1:8848
        namespace: cloud
  application:
    name: cloud-nacos
```

## 接入 MySQL 数据源

Nacos 默认使用内嵌 Derby 数据库。集群环境下需要统一的外置数据库，建议生产环境替换为 MySQL。

参考官方文档：[Nacos 部署文档](https://nacos.io/zh-cn/docs/deployment.html)

## 认证配置

Nacos 提供基础鉴权能力，需在可信内部网络运行，**不可暴露公网**。认证配置参考：[Nacos 认证文档](https://nacos.io/zh-cn/docs/auth.html)

## 服务注册与发现

Nacos 不仅可作为配置中心，也提供服务注册与发现能力，是 Spring Cloud Alibaba 体系的核心组件。

### 版本兼容性

Spring Boot / Spring Cloud / Spring Cloud Alibaba 版本需严格对应，否则启动失败。以 Spring Boot 2.6.11 为例：

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>2.6.11</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>2021.0.4</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
        <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-alibaba-dependencies</artifactId>
            <version>2021.0.4.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

> 版本映射可参考 [官方文档](https://github.com/alibaba/spring-cloud-alibaba/wiki/%E7%89%88%E6%9C%AC%E8%AF%B4%E6%98%8E)。

### 依赖配置

```xml
<!-- Nacos 服务发现 -->
<dependency>
    <groupId>com.alibaba.cloud</groupId>
    <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
</dependency>
<!-- Spring Boot 2.4+ 必须引入 bootstrap 支持 -->
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-bootstrap</artifactId>
</dependency>
```

> **注意**：Spring Cloud 2020.* 以后默认禁用了 bootstrap 配置文件，需显式引入 `spring-cloud-starter-bootstrap`。

### 配置（application.yml）

```yaml
spring:
  application:
    name: my-service
  cloud:
    nacos:
      discovery:
        server-addr: localhost:8848
```

### 启用服务发现

在启动类添加 `@EnableDiscoveryClient` 注解：

```java
@SpringBootApplication
@EnableDiscoveryClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

### 跨服务调用（负载均衡）

Spring Cloud Nacos 2021 以后默认不再使用 Ribbon 作为负载均衡器，推荐使用 Spring Cloud LoadBalancer：

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-loadbalancer</artifactId>
</dependency>
```

使用 `LoadBalancerClient` 按服务名调用：

```java
@RestController
@RequestMapping("/order")
public class TestController {
    @Resource
    private LoadBalancerClient loadBalancerClient;
    @Resource
    private RestTemplate restTemplate;

    @GetMapping("/test/{id}")
    public String getTest(@PathVariable("id") String id) {
        ServiceInstance instance = loadBalancerClient.choose("userservice");
        String url = instance.getUri() + "/user/getOne/" + id;
        return restTemplate.getForObject(url, String.class);
    }
}
```

### 常见错误

| 错误信息 | 原因与解决 |
|----------|-----------|
| `No spring.config.import set` | Spring Boot 2.4+ 未引入 `spring-cloud-starter-bootstrap` |
| 服务注册后无法发现 | 检查 `spring.application.name` 配置是否正确 |
| 负载均衡调用失败 | 需引入 `spring-cloud-starter-loadbalancer`（Ribbon 已移除） |

> 来源：鱼皮·编程导航 / codefather
