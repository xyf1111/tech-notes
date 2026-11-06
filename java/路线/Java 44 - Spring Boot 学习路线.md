---
title: Java 44 - Spring Boot 学习路线
tags:
  - Spring Boot
  - Java
  - 学习路线
source: 鱼皮·编程导航 / codefather
date: 2026-08-05
---

# Java 44 - Spring Boot 学习路线

> Spring Boot 是基于 Spring 框架的快速开发脚手架，以"约定优于配置"为核心设计理念，通过自动配置和起步依赖让开发者几分钟内搭建可运行的 Web 应用。本文梳理从 Spring 核心概念、Spring Boot 入门、Web 开发、数据访问、企业级特性、微服务衔接到项目实战、求职备战的完整学习路线，共 8 个阶段。

## 开篇介绍

Spring Boot 已经成为 Java 后端开发的标准，几乎所有 Java Web 项目都在使用 Spring Boot，是 Java 后端开发工程师的必备技能。

- **核心设计理念**："约定优于配置"，通过大量自动配置和起步依赖简化 Spring 的配置和使用
- **快速上手**：几分钟内即可搭建一个可运行的 Web 应用
- **AI 时代**：Spring Boot 结合 Spring AI 框架，可快速开发 AI 应用的后端服务
- **版本选择**：Spring Boot 3 是当前主流版本，基于 Spring Framework 6 和 Java 17，引入 GraalVM 原生镜像、观测性改进、HTTP 接口等新特性，2026 年建议优先学习
- 💡 虽然已发布 Spring Boot 4，但距离生产应用还有很长距离，不建议急着使用

### 学习前提

1. **Java 基础**：面向对象编程、集合、异常处理、IO 流等【必须】
2. **Java Web 基础**：Servlet、JSP、HTTP 协议等【建议】
3. **MySQL 数据库**：SQL 语句、数据库设计等【必须】
4. **Maven 或 Gradle**：项目构建工具【建议】

### Spring、Spring MVC、Spring Boot 的关系

- **Spring**：Java 企业级应用开发的基础框架，提供 IoC（控制反转）和 AOP（面向切面编程）等核心功能
- **Spring MVC**：基于 Spring 的 Web 开发框架，用于开发 Web 应用和 RESTful API
- **Spring Boot**：基于 Spring 的快速开发脚手架，简化 Spring 的配置和使用

简单来说，Spring 是基础，Spring MVC 是 Web 层，Spring Boot 是把这些整合起来并简化配置的工具。建议直接学习 Spring Boot，它已内置 Spring 和 Spring MVC，只需了解 Spring 核心概念（IoC、AOP）即可，不需要深入学习 XML 配置。

### 就业方向

1. Java 后端开发工程师：使用 Spring Boot 开发后端服务
2. Java 全栈工程师：Spring Boot 后端 + Vue/React 前端
3. 微服务开发工程师：使用 Spring Cloud 开发微服务
4. 架构师：设计基于 Spring Boot 的系统架构

## 整体学习建议

1. **理解 Spring 核心概念**：虽然建议直接学 Spring Boot，但 IoC、AOP 等核心概念仍要理解，这是用好 Spring Boot 的基础
2. **边学边做**：每学完一个知识点就动手实现一个功能或写 Demo，如用户注册、登录、增删改查等
3. **优先查阅官方文档**：官方文档比搜索引擎上的博客更准确、更全面，遇到问题先查官方文档（或问 AI）
4. **版本不必焦虑**：Spring Boot 3 已是主流，即使看的是 Spring Boot 2 的教程也完全没影响，概念和用法上没有明显区别

## 阶段总览

| 阶段 | 内容 | 建议时长 |
| --- | --- | --- |
| 阶段 1 | Spring 基础概念 | 2-5 天 |
| 阶段 2 | Spring Boot 入门 | 5-15 天 |
| 阶段 3 | Web 开发 | 10-20 天 |
| 阶段 4 | 数据访问 | 5-15 天 |
| 阶段 5 | 企业级特性 | 5-15 天 |
| 阶段 6 | 微服务开发（可选） | 10-20 天 |
| 阶段 7 | 项目实战 | 30-45 天 |
| 阶段 8 | 求职备战 | 面试前突击 |

---

## 阶段 1：Spring 基础概念（2-5 天）

### 学习目标

理解 Spring 的核心概念，为学习 Spring Boot 打基础。

### 知识点

**Spring 核心概念【必学】**

- IoC（控制反转）和 DI（依赖注入）
- Bean 和容器
- 注解（@Component、@Autowired、@Configuration）
- AOP（面向切面编程）【建议学】

**SSM 框架【了解即可】**

- Spring：IoC 和 AOP
- Spring MVC：Web 开发框架
- MyBatis：持久层框架

### 学习建议

1. IoC 和 DI 是 Spring 的核心思想：把对象的创建和管理交给 Spring 容器，而不是在代码中手动 new 对象
2. 注解是 Spring Boot 的核心，现代 Spring 开发几乎不使用 XML 配置，要熟悉常用注解
3. SSM 是传统 Spring 技术栈，了解概念即可，有助于理解 Spring Boot 的工作原理，不需要深入学习其配置
4. 本阶段不需要花太多时间，快速过一遍即可，重点放在 Spring Boot 上

### 学习资源

- [Spring 官方文档](https://docs.spring.io/spring-framework/reference/)：官方文档

---

## 阶段 2：Spring Boot 入门（5-15 天）

### 学习目标

掌握 Spring Boot 的基础知识，能够快速搭建 Spring Boot 应用。

### 知识点

**Spring Boot 基础【必学】**

- Spring Boot 的特点和优势
- 核心概念：自动配置、起步依赖
- Spring Initializr：快速创建项目
- 项目结构和配置文件（application.yml）

**依赖管理【必学】**

- Maven 和 Gradle
- pom.xml 和依赖管理
- Spring Boot Starter

**核心注解【必学】**

- @SpringBootApplication
- @RestController、@Controller
- @RequestMapping、@GetMapping、@PostMapping
- @Autowired、@Resource
- @Service、@Repository、@Component

**配置【必学】**

- application.properties 和 application.yml
- 多环境配置（dev、test、prod）
- 自定义配置（@Value、@ConfigurationProperties）

**日志【建议学】**

- Logback 日志框架
- 日志级别和配置
- 日志输出

### 学习建议

1. 使用 [Spring Initializr](https://start.spring.io/) 快速创建项目，也可以直接用 IDEA 初始化项目工程
2. Starter 是 Spring Boot 的核心特性，每个 Starter 包含一组相关依赖，如 spring-boot-starter-web 包含 Spring MVC、Tomcat 等 Web 开发所需依赖
3. YAML 比 Properties 更简洁，建议使用 application.yml 而不是 application.properties
4. 多环境配置可让开发、测试、生产环境使用不同配置，非常实用
5. 多动手：创建项目、运行 Hello World、写点 Demo，熟悉 Spring Boot 的基本使用

### 学习资源

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)：官方文档
- [2024 Spring Boot 3 + SSM 教程](https://www.bilibili.com/video/BV1hy411q72d/)：368 集完整教程
- [Spring Boot 核心知识点教程](https://www.bilibili.com/video/BV1Wb421e7P8/)：800 分钟彻底掌握

---

## 阶段 3：Web 开发（10-20 天）

Web 开发是 Spring Boot 最常见的应用场景，通过 Spring MVC 可以快速构建 RESTful API 和 Web 应用。

### 学习目标

掌握 Spring Boot 的 Web 开发，能够开发 RESTful API。

### 知识点

**RESTful API【必学】**

- RESTful 的概念和规范
- HTTP 方法（GET、POST、PUT、DELETE）
- 请求参数（@RequestParam、@PathVariable、@RequestBody）
- 响应（@ResponseBody、ResponseEntity）
- 统一返回格式

**参数校验【必学】**

- Hibernate Validator
- @Valid、@Validated
- 常用校验注解（@NotNull、@NotBlank、@Min、@Max）
- 自定义校验

**全局异常处理【必学】**

- @ControllerAdvice
- @ExceptionHandler
- 统一异常处理

**拦截器和过滤器【建议学】**

- HandlerInterceptor
- Filter
- 拦截器和过滤器的区别

**跨域处理【必学】**

- CORS 跨域
- @CrossOrigin
- 全局跨域配置

**文件上传【建议学】**

- MultipartFile
- 文件存储（本地存储、云存储）

### 学习重点

1. RESTful API 是现代 Web 开发的标准：用 HTTP 方法表示操作（GET 查询、POST 创建、PUT 更新、DELETE 删除），用 HTTP 状态码表示结果
2. 参数校验保证数据有效性，学会用 Hibernate Validator 即可，注解不用死记
3. 全局异常处理避免每个方法都写 try-catch，学会 @ControllerAdvice + @ExceptionHandler
4. 拦截器常用于权限验证、日志记录等场景，是 Spring MVC 的重要特性

### 学习资源

- [Spring Boot Web 开发官方文档](https://spring.io/guides/gs/rest-service)：官方指南

---

## 阶段 4：数据访问（5-15 天）

数据访问是后端开发的核心，Spring Boot 能够轻松整合 JPA、MyBatis 等多种持久层框架，简化数据库操作。

### 学习目标

掌握 Spring Boot 的数据访问，能够操作数据库。

### 知识点

**MyBatis【必学】**

- MyBatis 的配置和使用
- Mapper 接口和 XML 映射文件
- 动态 SQL（if、foreach、choose）
- 分页（PageHelper）

**MyBatis-Plus【必学，推荐】**

- MyBatis-Plus 的优势
- BaseMapper：基础 CRUD
- 条件构造器（QueryWrapper、LambdaQueryWrapper）
- 代码生成器
- 分页插件

**JPA【可不学】**

- Spring Data JPA
- Entity 和 Repository
- JPQL 查询
- JPA 和 MyBatis 的区别

**事务管理【必学】**

- @Transactional
- 事务的传播行为
- 事务的隔离级别

### 学习重点

1. MyBatis 和 MyBatis-Plus 是 Java 后端最流行的持久层框架，MyBatis-Plus 是 MyBatis 的增强工具，建议重点学习 MyBatis-Plus
2. MyBatis-Plus 代码生成器可根据数据库表自动生成 Entity、Mapper、Service 等代码，大幅提高开发效率
3. JPA 是 Java 官方持久层规范，比 MyBatis 更面向对象但灵活性较差；国内更流行 MyBatis，国外更流行 JPA
4. 事务是数据库操作的重要概念，要理解事务的 ACID 特性和使用场景

### 学习资源

- [MyBatis-Plus 官方文档](https://baomidou.com/)：官方文档
- [Spring Data JPA 官方文档](https://spring.io/projects/spring-data-jpa)：官方文档

---

## 阶段 5：企业级特性（5-15 天）

企业级特性包括缓存、消息队列、安全认证等，是构建生产级应用的必备技能。

### 学习目标

掌握 Spring Boot 的企业级特性，能够开发安全、可靠的应用。

### 知识点

**安全认证【必学】**

- Spring Security：权限框架
- JWT（JSON Web Token）：无状态认证
- Sa-Token：轻量级权限框架（推荐）
- OAuth 2.0【建议学】

**缓存【必学】**

- Spring Cache
- Redis 集成
- 缓存注解（@Cacheable、@CacheEvict、@CachePut）

**定时任务【必学】**

- @Scheduled
- Cron 表达式
- 异步任务（@Async）

**消息队列【建议学】**

- RabbitMQ 集成
- Kafka 集成
- RocketMQ 集成

**Actuator【建议学】**

- 应用监控
- 健康检查
- 指标收集

### 学习重点

1. Spring Security 功能强大但学习成本较高：中小型项目推荐更轻量的 Sa-Token，大型企业级应用建议用 Spring Security
2. JWT 是现代 Web 应用最常用的认证方式，要理解其工作原理和使用方法
3. Redis 是缓存的首选，要学习如何在 Spring Boot 中集成 Redis
4. 定时任务常用于数据同步、定时清理、报表生成等场景，要学会使用定时任务注解
5. 消息队列用于系统解耦、异步处理、流量削峰，是分布式系统的重要组件

### 学习资源

- [Spring Security 官方文档](https://spring.io/projects/spring-security)：官方文档
- [Sa-Token 官方文档](https://sa-token.cc/)：轻量级权限框架

---

## 阶段 6：微服务开发（可选，10-20 天）

如果目标是大厂或微服务架构，需要学习 Spring Cloud。

### 学习目标

掌握 Spring Cloud，能够开发微服务应用。

### 知识点

**Spring Cloud【建议学】**

- 服务注册和发现（Nacos、Eureka）
- 服务调用（OpenFeign）
- 负载均衡（Ribbon、LoadBalancer）
- 服务网关（Gateway）
- 配置中心（Nacos Config、Spring Cloud Config）
- 服务熔断（Sentinel、Hystrix）

**Dubbo【建议学】**

- Dubbo 的概念和特点
- Dubbo 和 Spring Cloud 的区别

### 学习建议

1. Spring Cloud 是微服务架构的主流解决方案，适合大型分布式系统；目标中小型公司可以先不学（学了能加分）
2. Nacos 是阿里开源的服务注册和配置中心，功能强大且易用，建议优先学习
3. 微服务涉及组件多、概念多，建议结合项目实践学习

### 学习资源

- [Spring Cloud 官方文档](https://spring.io/projects/spring-cloud)：官方文档
- [2024 Spring Cloud 微服务教程](https://www.bilibili.com/video/BV1re411m7hQ/)：完整教程

---

## 阶段 7：项目实战（30-45 天）

### 学习目标

通过实际项目巩固所学知识，积累项目经验。

### 学习建议

1. **从简单项目开始**：用户管理系统、博客系统 API、图书管理系统等
2. **完整技术栈**：Spring Boot + MyBatis-Plus + MySQL + Redis + JWT
3. **前后端分离**：开发 RESTful API，配合前端（Vue/React）开发完整应用
4. **微服务改造**：学了 Spring Cloud 后，可尝试将单体项目改造成微服务架构
5. **部署上线**：部署到服务器（如阿里云、腾讯云），体验完整的项目上线流程

### 项目方向参考

以下项目方向覆盖不同技术点，可作为实战选题：

- **用户中心项目**：适合新手入门
- **伙伴匹配系统**：学习 Redis、并发编程
- **API 开放平台**：学习 Dubbo、Gateway 微服务
- **智能 BI 项目**：学习 RabbitMQ、AI 应用开发

---

## 阶段 8：求职备战

### 学习目标

熟练掌握 Spring Boot 常见面试题，准备好简历和项目经历，顺利通过面试。

### 学习建议

1. **准备项目**：简历上至少要有 2 个完整的 Spring Boot 项目，面试时要能流畅介绍技术架构、核心功能、技术难点
2. **准备简历**：突出项目经历与技术栈，量化项目成果与亮点
3. **多刷面试题**：重点涵盖 Spring 核心概念、Spring Boot 特性、Web 开发、数据访问、微服务等
4. **理解原理**：IoC 的实现原理、AOP 的实现原理、Spring Boot 自动配置的原理等是面试高频考点

### 经典面试题

**Spring 核心**

1. 什么是 IoC？什么是 DI？
2. Spring Bean 的生命周期是怎样的？
3. Spring Bean 的作用域有哪些？
4. 什么是 AOP？AOP 的应用场景有哪些？
5. @Autowired 和 @Resource 有什么区别？

**Spring Boot**

1. Spring Boot 有什么优势？
2. Spring Boot 的自动配置原理是什么？
3. Spring Boot Starter 是什么？
4. 如何自定义 Spring Boot Starter？

**Web 开发**

1. @RestController 和 @Controller 有什么区别？
2. @RequestParam 和 @PathVariable 有什么区别？
3. 如何实现全局异常处理？
4. 拦截器和过滤器有什么区别？

**数据访问**

1. MyBatis 和 JPA 有什么区别？
2. MyBatis 的 # 和 $ 有什么区别？
3. @Transactional 如何使用？事务失效的场景有哪些？

---

## 更多资源

### 官方文档与源码

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)：最权威的学习资料
- [Spring 官方博客](https://spring.io/blog)：Spring 官方技术博客
- [spring-projects/spring-boot](https://github.com/spring-projects/spring-boot)：Spring Boot 源码
- [awesome-spring-boot](https://github.com/ityouknow/awesome-spring-boot)：Spring Boot 资源大全

### 技术博客

- [Netflix TechBlog](https://netflixtechblog.com/)：Netflix 微服务实践
- [Uber Engineering Blog](https://www.uber.com/blog/engineering/)：Uber 后端架构
- [美团技术团队](https://tech.meituan.com/)：大厂技术博客

---

## 写在最后

Spring Boot 是 Java 后端开发的必备框架，掌握 Spring Boot 是 Java 后端工程师的基本要求。它通过"约定优于配置"的设计理念，大大简化了 Spring 的使用，让开发者可以专注于业务逻辑的实现。

学习建议：先理解 Spring 的核心概念（IoC、AOP），然后直接上手 Spring Boot，不要在传统的 Spring 配置上花太多时间。重点掌握 Web 开发、数据访问、安全认证等核心功能，结合项目实践不断巩固。

加油，未来的 Spring Boot 高手们！

> 来源：鱼皮·编程导航 / codefather — Spring Boot 学习路线
