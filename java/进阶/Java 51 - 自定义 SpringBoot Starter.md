---
title: "Java 进阶 - 自定义 SpringBoot Starter"
date: 2026-08-19
tags: [SpringBoot, 自动装配, Java]
source: "鱼皮·编程导航 / codefather"
---

# Java 进阶 - 自定义 SpringBoot Starter

> Starter 是 SpringBoot 的"一键集成"依赖描述符：一个坐标聚合某项技术所需的全部 jar 并自动适配版本。自定义 Starter 就是把独立于业务的通用模块（如短信发送、IP 访问统计）封装成独立 jar，借助自动装配在引入方项目中"无感"生效——pom 引用即可引入、删除依赖即可摘除。本文先讲 Starter 概念与自动装配原理，再以"IP 访问监控"模块为例，完整演示从统计服务、配置属性类、自动配置类到 META-INF 注册、yml 配置、拦截器与配置提示的全过程。

## 核心要点

- **Starter 是什么**：一组便捷的依赖描述符，一个坐标替代手动导入的 n 个坐标，自动适配版本、避免版本冲突
- **为什么自定义**：通用模块硬拷贝、重复集成的痛点 → 封装成 starter，pom 引用即复用
- **自动装配原理**：自动配置类通过 `META-INF/spring.factories`（SpringBoot 2.7 之前）或 `META-INF/spring/...AutoConfiguration.imports`（2.7+）注册，启动时被加载
- **自动配置类**：`@Configuration` + `@Bean` 提供功能 bean，可配合 `@ConditionalOnClass`、`@ConditionalOnMissingBean` 等条件注解按需生效
- **配置绑定**：`@ConfigurationProperties` 读取 yml 前缀参数，用 `@EnableConfigurationProperties` 或 `@Import` 注册
- **yml 提示**：引入 `spring-boot-configuration-processor` 自动生成配置元数据，配合字段 javadoc 实现 IDE 提示
- **命名规范**：第三方 starter 用 `xxx-spring-boot-starter`，配置前缀使用唯一命名空间（如 `tools.ip`）

## Starter 概念与价值

### 什么是 Starter

官方文档定义：

> Starters are a set of convenient dependency descriptors that you can include in your application. You get a one-stop shop for all the Spring and related technologies that you need without having to hunt through sample code and copy-paste loads of dependency descriptors.

概述：当想使用某项技术与 Spring 结合使用时，直接导入该技术的 starter 即可，不必再去找该技术所依赖的 n 个坐标逐个复制进项目。

例如开发 Spring Web 项目，不使用 starter 可能需要手动导入这些坐标：

| 坐标 | 用途 |
|---|---|
| `spring-boot-starter` | 核心 starter（自动配置、日志等） |
| `spring-boot-starter-json` | JSON 序列化 |
| `spring-boot-starter-tomcat` | 内嵌 Tomcat |
| `spring-web` / `spring-webmvc` | Web MVC 框架 |
| `jakarta.validation-api` 等 | 校验等辅助能力 |

而使用 SpringBoot 提供的 starter 只需一个坐标，即可包含上面所有 jar 并自动适配版本：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

如果手动导入不同 jar 包，存在版本不兼容时还会产生一系列版本冲突问题。

### 为什么要自定义 Starter

**问题产生**：日常开发中常有一些独立于业务之外的通用模块，在许多场景下都能用到。以往的做法是把代码备份在某处，某个工程需要时再将代码硬拷贝进去重新集成一遍，麻烦至极。

**问题解决**：把这些可独立于业务代码的通用模块封装成一个个 starter，复用时只需在 pom 中引用依赖，SpringBoot 自动完成装配。自定义 Starter 相当于一个大的工具模块，导入其他项目即可快速实现功能的引入与剔除。

### 常见场景

- 短信发送模块
- 自定义 SDK，让调用者使用更方便
- 任何跨项目复用的通用能力（如本文案例的 IP 访问统计）

## 自动装配原理

### 注册方式一：spring.factories（SpringBoot 2.7 之前）

早期版本通过 `META-INF/spring.factories` 文件注册自动配置类，key 固定为 `org.springframework.boot.autoconfigure.EnableAutoConfiguration`，值为自动配置类的全限定名：

```properties
# Auto Configure
org.springframework.boot.autoconfigure.EnableAutoConfiguration=cn.guanzhi.autoconfig.IpAutoConfiguration
```

SpringBoot 启动时通过 `SpringFactoriesLoader` 扫描 classpath 下所有 jar 中的该文件并加载。

项目加载流程：**加载模块 → 加载 `spring.factories` 文件 → 加载自动配置类 → 加载其声明的功能 bean**。

### 注册方式二：AutoConfiguration.imports（SpringBoot 2.7+）

SpringBoot 2.7 起官方推荐改用 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 文件，每行一个自动配置类全限定名，更简洁、加载机制更高效；`spring.factories` 方式仍兼容但已不推荐：

```
cn.guanzhi.autoconfig.IpAutoConfiguration
```

### 自动配置类与条件注解

自动配置类本质是一个 `@Configuration` 配置类，内部用 `@Bean` 方法把功能类注册为 bean：

```java
@EnableScheduling
@Import({IpProperties.class, SpringMvcConfig.class})
public class IpAutoConfiguration {

    @Bean
    public IpCountService ipCountService() {
        return new IpCountService();
    }
}
```

为了让自动配置"按需生效、可被覆盖"，通常还会配合条件注解：

- `@ConditionalOnClass`：classpath 存在某类时才生效（如引入对应依赖才启用）
- `@ConditionalOnMissingBean`：容器中不存在该 bean 时才注册（允许使用者自定义覆盖）
- `@ConditionalOnProperty`：配置文件满足某属性时才生效

### 配置绑定：@EnableConfigurationProperties

`@ConfigurationProperties(prefix = "xxx")` 标注的属性类可读取 yml 中对应前缀下的配置。将其注册成 bean 有两种方式：

- `@EnableConfigurationProperties(IpProperties.class)`：在自动配置类上声明（默认 bean 名由 Spring 生成）
- `@Import(IpProperties.class)` 或属性类上加 `@Component("ipProperties")`：可自定义 bean 名称，便于在 `@Scheduled` 等注解中用 `#{}` 引用

## 最小可用的 Starter：工程配置与打包

把已有类库（如公司项目的加密模块）封装成 starter 的最小流程：pom 引入自动配置依赖 → 编写配置类 → META-INF 注册 → `mvn install` 本地安装。

### pom.xml 核心依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-autoconfigure</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
```

- `spring-boot-autoconfigure`：自动加载配置的核心依赖
- `spring-boot-configuration-processor`：自动生成配置文件提示（`optional` 防止传递给使用方）
- 依赖尽量精简，便于其他项目引用时的兼容性；注意 Spring Boot 3.x 已移除 `spring.factories` 注册机制（改用 AutoConfiguration.imports，见上文）

### 删除 spring-boot-maven-plugin

若 pom 中显式声明了 `spring-boot-maven-plugin` 需删掉：该插件用于把项目打成可执行 jar，而类库应按普通 jar 打包被其他项目引用，保留会导致打包产物不适合作为依赖。

### 配置类 + META-INF 注册

```java
@Configuration
@ConfigurationProperties(prefix = "yuapi.client")
@Data
@ComponentScan
public class YuApiClientConfig {
    private String appId;
    private String appSecret;

    @Bean
    public YuApiClient yuApiClient() {
        return new YuApiClient(appId, appSecret);
    }
}
```

- `@Configuration`：声明配置类，可创建 Bean
- `@ConfigurationProperties`：绑定 yml 中 `yuapi.client.appId` 等配置到属性，避免硬编码
- `@ComponentScan`：扫描组件

在 `resources/META-INF/spring.factories` 中注册（相当于给项目一个启动入口）：

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=com.yupi.mystarter.YuApiClientConfig
```

### 打包与引用

执行 `mvn install` 打包为本地依赖，其他项目 pom 中引用：

```xml
<dependency>
    <groupId>com.yupi</groupId>
    <artifactId>my-starter</artifactId>
    <version>0.0.1</version>
</dependency>
```

## 实战案例：IP 访问监控 Starter

### 需求与功能设计

**功能**：统计网站独立 IP 访问次数，每 10 秒在后台输出一次监控信息（IP + 访问次数），用户访问时自动统计。例如张三（192.168.0.135）访问 15 次、李四（61.129.65.248）访问 20 次，后台每 10 秒刷新输出：

```tex
         IP访问监控
+-----ip-address-----+--num--+
|     192.168.0.135  |   15  |
|     61.129.65.248  |   20  |
+--------------------+-------+
```

**实现分析**：

1. **数据存储**：IP（字符串）→ 次数（数字）的键值对，用 `Map<String, Integer>` 即可（也可换成 Redis 等键值存储技术）
2. **统计位置**：每次 web 请求都需要统计，不可能在每个接口手动调用，使用**拦截器**统一处理
3. **可配置项**：输出频度（默认 10 秒）、累计数据 / 阶段数据（周期内是否清空）、输出格式（详细 / 极简）

> 官方对 starter 的定位：包含某技术基础设施的自动配置与定制代码；通过专用命名空间暴露配置键；提供一个 starter 依赖让使用者轻松上手。本案例即按此设计。

### 项目结构

```
ip-spring-boot-starter
├── pom.xml
└── src
    ├── main/java/cn/guanzhi/autoconfig
    │   ├── IpCountService.java      # 统计 + 定时打印业务类
    │   ├── IpProperties.java        # 配置属性类（含 LogModel 枚举）
    │   ├── IpCountInterceptor.java  # 拦截器：请求时自动统计
    │   ├── SpringMvcConfig.java     # 注册 MVC 拦截器
    │   └── IpAutoConfiguration.java # 自动配置类（装配以上 bean）
    └── main/resources/META-INF
        ├── spring.factories                                          # 注册自动配置类（2.7 前）
        └── spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports  # 2.7+
```

### 核心代码

#### 统计服务 IpCountService

用 Map 记录 IP 访问次数，从容器自动装配请求对象获取 IP：

```java
public class IpCountService {
    // 单例 bean，无需 static
    private Map<String, Integer> ipCountMap = new HashMap<>();

    @Resource
    private HttpServletRequest httpServletRequest;  // 从容器直接获取请求对象

    @Resource
    private IpProperties ipProperties;              // 配置属性 bean

    // 统计：每次访问对应 IP 次数 +1
    public void count() {
        String ip = httpServletRequest.getRemoteAddr();
        ipCountMap.put(ip, ipCountMap.getOrDefault(ip, 0) + 1);
    }

    // 定时打印（cron 周期从配置 bean 读取）
    @Scheduled(cron = "0/#{ipProperties.cycle} * * * * ?")
    public void print() {
        // 详细模式：IP + 次数
        if (ipProperties.getModel().equals(IpProperties.LogModel.DETAIL.getValue())) {
            System.out.println("         IP访问监控");
            System.out.println("+-----ip-address-----+--num--+");
            for (Map.Entry<String, Integer> entry : ipCountMap.entrySet()) {
                System.out.println(String.format("|%18s  |%5d  |", entry.getKey(), entry.getValue()));
            }
            System.out.println("+--------------------+-------+");
        }
        // 极简模式：只输出 IP
        else if (ipProperties.getModel().equals(IpProperties.LogModel.SIMPLE.getValue())) {
            System.out.println("     IP访问监控");
            System.out.println("+-----ip-address-----+");
            for (String key : ipCountMap.keySet()) {
                System.out.println(String.format("|%18s  |", key));
            }
            System.out.println("+--------------------+");
        }
        // 周期内数据清空：必须在输出之后执行，否则每次看到的都是空白数据
        if (ipProperties.getCycleReset()) {
            ipCountMap.clear();
        }
    }
}
```

#### 配置属性类 IpProperties

```java
@ConfigurationProperties(prefix = "tools.ip")
public class IpProperties {
    /** 日志显示周期（秒） */
    private Long cycle = 5L;
    /** 是否周期内重置数据 */
    private Boolean cycleReset = false;
    /** 日志输出模式：detail 详细模式 / simple 极简模式 */
    private String model = LogModel.DETAIL.value;

    public enum LogModel {
        DETAIL("detail"), SIMPLE("simple");
        private String value;
        LogModel(String value) { this.value = value; }
        public String getValue() { return value; }
    }
}
```

要点：

- 属性前缀至少使用**两级**命名（`tools.ip`），避免项目组参数过多产生冲突
- 分类性数据（输出模式）建议用**枚举**定义，方便使用时取字符串亦可
- **字段 javadoc 一定要写**：会自动生成到配置元数据中，作为 yml 提示的描述文字

#### 自动配置类 IpAutoConfiguration

```java
@EnableScheduling
@Import({IpProperties.class, SpringMvcConfig.class})
public class IpAutoConfiguration {

    @Bean
    public IpCountService ipCountService() {
        return new IpCountService();
    }
}
```

#### 拦截器：请求自动统计

```java
public class IpCountInterceptor implements HandlerInterceptor {
    @Autowired
    private IpCountService ipCountService;

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response, Object handler) throws Exception {
        ipCountService.count();
        return true;
    }
}

@Configuration
public class SpringMvcConfig implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(ipCountInterceptor()).addPathPatterns("/**");
    }

    @Bean
    public IpCountInterceptor ipCountInterceptor() {
        return new IpCountInterceptor();
    }
}
```

有了拦截器后，使用方**无需在业务代码中手动调用** `count()`，导入坐标即自动统计；拦截路径可按需调整，也可从配置属性读取。删除依赖即可摘除功能，不会在业务代码中留下散落的调用点。

#### META-INF 注册

`META-INF/spring.factories`（SpringBoot 2.7 之前）：

```properties
org.springframework.boot.autoconfigure.EnableAutoConfiguration=cn.guanzhi.autoconfig.IpAutoConfiguration
```

`META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports`（2.7+）：

```
cn.guanzhi.autoconfig.IpAutoConfiguration
```

### yml 配置示例

```yaml
tools:
  ip:
    cycle: 10          # 输出频度（秒）
    cycleReset: false  # 是否周期内清空累计数据
    model: "detail"    # detail 详细模式 / simple 极简模式
```

### 定时任务参数化

`@Scheduled` 注解上无法直接使用 `@ConfigurationProperties` 的配置数据，需要绕一步：

1. cron 中用 `#{}` 读取 bean 属性：`@Scheduled(cron = "0/#{ipProperties.cycle} * * * * ?")`
2. 属性类加 `@Component("ipProperties")` 自定义 bean 名 —— **必须设置**，否则 Spring 用命名生成器生成长名称，`#{}` 无法读取属性
3. 自动配置类弃用 `@EnableConfigurationProperties`，改用 `@Import(IpProperties.class)` 以使用自定义 bean 名

### 开启 yml 配置提示

自定义 starter 默认没有 IDE 配置提示，引入专用工具坐标即可生成（`optional` 防止传递给使用方）：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```

重新编译 install 后会在 `META-INF` 生成对应的提示文件（`spring-configuration-metadata.json`），可拷贝到自己的 META-INF 目录编辑：

- `groups`：配置的总体描述，指向属性封装类
- `properties`：每个属性的名称、类型、描述、默认值（**description 来自字段 javadoc 自动生成**）
- `hints`：默认空白，可参考 SpringBoot 源码为枚举类属性配置候选值提示：

```json
{
  "hints": [
    {
      "name": "tools.ip.model",
      "values": [
        { "value": "detail", "description": "详细模式." },
        { "value": "simple", "description": "极简模式." }
      ]
    }
  ]
}
```

配置后使用方在 yml 中即可获得与官方 starter 一致的联想提示效果。

## 在项目中使用

### 安装与发布

- 本地使用：在自定义 starter 项目中执行 `mvn install`，重新编译并安装到本地仓库
- 团队/对外使用：`deploy` 到私服（Nexus 等）

### 使用方引用

```xml
<dependency>
    <groupId>cn.guanzhi</groupId>
    <artifactId>ip-spring-boot-starter</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

### 调用方式演进

1. **初期（功能简陋）**：手动注入 `IpCountService` 并在接口中调用 `count()`：

```java
@RestController
public class DemoController {
    @Resource
    private IpCountService ipCountService;

    @GetMapping("/guanzhi")
    public void ipDemo() {
        ipCountService.count();
        System.out.println("方法触发成功");
    }
}
```

2. **完善后（拦截器方案）**：注释掉手动注入调用代码，拦截器自动统计，功能依旧正常执行——真正实现"导入即用、删除即摘"。

### 整体流程总结

1. 创建一个功能模块，按需求导入坐标并实现功能 —— **必须**
2. 创建自动配置类加载功能类（Service），并在 `spring.factories` / `AutoConfiguration.imports` 中注册自动配置类 —— **必须**
3. 完成以上两步即算完成最小可用 Starter，install 到本地仓库后即可通过导入坐标在其他项目使用
4. 通过 yml 配置对外暴露参数，灵活控制功能 —— **非必须**
5. 开启 yml 配置提示，避免使用者写错配置 —— **非必须**

## 开发规范

### Starter 命名规范

官方 starter 统一为 `spring-boot-starter-*`，该前缀为官方保留（`*` 为特定应用类型，便于 IDE 按名称检索）。第三方 starter **不应以 `spring-boot` 开头**，推荐使用**项目名-spring-boot-starter**格式，如 `ip-spring-boot-starter`。

### 参数前缀命名

配置参数必须使用**唯一命名空间**，不要使用 `server`、`management`、`spring` 等 SpringBoot 保留命名空间，否则后续版本可能修改这些命名空间导致模块出错。建议用两级以上前缀 + 项目名区分（如 `tools.ip`），并保持 yml 与 `@ConfigurationProperties(prefix = ...)` 一致。

### 配置注释与提示

每个配置字段都要写 javadoc（`/** */`），IDE 中输入 `/**` 回车即可快捷生成。这些注释会自动成为 yml 提示中的描述文字，官方也明确要求：Make sure that configuration keys are documented by adding field javadoc for each property。

> 来源：鱼皮·编程导航 / codefather
