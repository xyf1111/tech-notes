---
title: "Java 55 - 配置文件中的密码安全"
date: 2026-08-27
tags: [Java, Spring Boot, 安全, 配置中心, 实践]
source: "鱼皮·编程导航 / codefather"
---

# Java 55 - 配置文件中的密码安全

> 自己做的项目把数据库密码直接写进 `application.yml` 图省事没问题；但团队开发中，配置提交到代码仓库后协作者都能看到明文密码，属于高危漏洞。本文给出 3 种改造方案：密码管理平台/配置中心动态获取、Spring Cloud bootstrap.yml 远程加载、「移花接木」配置文件不入库。

## 为什么密码不能写进配置文件

- 个人项目：为了方便直接把密码写在 `application.yml` 等配置文件中，没有问题
- 团队开发（尤其是大公司）：配置提交到代码仓库后，**有代码库权限的同学都能看到明文密码**，非常不安全

## 方案一：密码管理平台 / 配置中心 + 动态获取

密码是极度敏感的信息，常见做法是保存到独立的**密码管理平台**或**有严格权限控制的配置中心**，由运维、开发 owner 等角色管理。项目通过 API 调用从这些地方**动态获取**密码，再初始化数据库、Redis 等客户端连接。

Spring Boot 只有在启动时才会读取 `application.yml` 初始化客户端连接 Bean，控制「先拉取密码、再创建 Bean」的办法是**自定义 Bean**：

```java
// 伪代码：先通过 API 从配置中心拉取密码，再创建数据库连接 Bean
@Bean
public DataSource dataSource() {
    String password = configCenterApi.fetch("db.password");
    return DataSourceBuilder.create()
            .password(password)
            .build();
}
```

**缺点**：需要修改 Bean 的加载方式，即改动代码。对不熟悉项目或 Spring Boot 运行机制的新人风险较高——一旦数据库连不上，整个项目几乎瘫痪。

## 方案二：Spring Cloud bootstrap.yml 远程加载

如果使用 Spring Cloud，启动时会**优先读取 `bootstrap.yml`**（如连接配置中心的配置），从远程加载其他配置（如密码），可能不需要自己创建 Bean。

## 方案三：「移花接木」配置文件不入库（不改代码）

项目从开发到运行经历 开发 → 编译构建 → 运行 三个阶段。既然 Spring Boot 会自动读取 `application.yml`，那就**不把这个文件提交到代码仓库**（`.gitignore` 忽略），在后续阶段把配置文件「扔进去」：

1. **构建阶段**：流水线构建项目时，把配置文件从远程配置中心拉取下来，放到项目目录下，一起打进 jar 包
2. **运行阶段**：启动项目时通过 shell 脚本把配置文件从远程拉取下来放到项目目录，运行 jar 包时指定读取该配置文件

Spring Boot 不仅能读取 resources 目录下的 `application.yml`，还能在打完 jar 包后找到**和 jar 包同目录的配置文件**基于它运行。加载优先级（先读取上面的）：

1. jar 包目录配置文件：`config/application.yml` 和 `application.yml`
2. 项目类路径目录的配置文件：如 `config/application.yml` 和 `application.yml`
3. 项目代码目录中的配置文件：如 `resources/application.yml`

> 来源：鱼皮·编程导航 / codefather
