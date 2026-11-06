---
title: "Java 工具 08 - 后端代码生成器"
date: 2026-07-28
tags: [java, mybatis, mybatisx, 代码生成器, crud, lombok, freemarker]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 08 - 后端代码生成器

> 使用 MyBatisX 插件（或 MyBatis-Plus 内置生成器、FreeMarker）从数据库表一键生成 Entity、Mapper、Service、Controller 等 CRUD 代码，大幅提升后端开发效率。

## 核心内容

后端开发中大量工作是重复编写 CRUD 代码。主流技术栈（Spring Boot + Spring MVC + MyBatis）下，代码生成器可以从数据库表结构自动生成以下层级代码：

- **数据访问层** — Mapper 接口 + XML 映射文件
- **实体类** — 与数据库表字段对应的 POJO
- **Service 层** — 业务逻辑骨架
- **Controller 层** — RESTful 接口

## MyBatisX 插件生成代码

### 1. 安装插件

在 IntelliJ IDEA 的 Settings → Plugins 中搜索 `MyBatisX` 并安装。该插件免费且由 MyBatis-Plus 官方维护。

### 2. 配置数据库连接

在 IDEA 右侧 Database 面板中创建 MySQL 数据源，填写连接信息（URL、用户名、密码），测试连接成功后即可在 IDEA 内部管理数据库，无需 Navicat 等第三方工具。

### 3. 使用 MyBatisX 生成代码

右键目标数据库表 → MyBatisX Generator，进入生成配置页面：

- **base package**（生成代码的包名和位置）建议**与已有项目包名隔离**，先生成到独立目录，确认无误后再移动到业务包中，避免冲突
- 生成模板选择 **MyBatis-Plus**
- 实体类建议启用 **Lombok**（自动生成 getter/setter/toString 等）
- 勾选需要生成的模块：实体类、Mapper 接口、Mapper XML、Service 接口、ServiceImpl、Controller

配置完成后点击生成，IDEA 会在指定包路径下创建所有代码文件。

### 4. 定制修改

生成的代码需根据业务需求微调，常见定制：

- **主键策略**：默认自动递增 → 改为雪花算法（Snowflake ID），防止自增 ID 被爬取连续数据
  - 在实体类主键字段上添加 `@TableId(type = IdType.ASSIGN_ID)` 注解
  - 或全局配置 MyBatis-Plus 的主键生成策略

## 其他代码生成方案

### MyBatis-Plus 内置代码生成器

MyBatis-Plus 框架自身提供灵活的代码生成器（AutoGenerator），可在 Java 代码中编程式配置数据源、包名、策略等，适合集成到构建流程中。

> 官方文档：https://baomidou.com/pages/981406/

### FreeMarker 自定义生成器

使用 FreeMarker 模板引擎手写模板，可完全控制代码结构和样式，适合有定制化需求或团队特定规范的场景。

> FreeMarker 官网：https://freemarker.apache.org/

### 在线代码生成器（SQL 之母）

浏览器即可使用的代码生成器，根据文本描述自动生成 SQL：[sqlfather.yupi.icu](http://sqlfather.yupi.icu)，开源仓库 [sql-father-backend-public](https://github.com/liyupi/sql-father-backend-public)，适合不想搭建本地环境的快速建表/查询场景。

## 关键约定

| 环节 | 建议 |
|------|------|
| 包名 | 先隔离生成，确认后再移动到业务包 |
| 实体类 | 启用 Lombok 减少样板代码 |
| 模板 | 优先使用 MyBatis-Plus 模板，支持更多开箱即用的方法 |
| 主键 | 推荐雪花算法（`IdType.ASSIGN_ID`）避免自增 ID 风险 |
| 代码审查 | 生成后仍需根据业务逻辑微调，尤其是关联查询和事务 |

> 来源：鱼皮·编程导航 / codefather
