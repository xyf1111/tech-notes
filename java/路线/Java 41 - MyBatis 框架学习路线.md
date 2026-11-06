---
tags:
  - MyBatis
  - MyBatis-Plus
  - 学习路线
  - Java
source: 鱼皮·编程导航 / codefather
date: 2026-07-31
---

# Java 41 - MyBatis 框架学习路线

> MyBatis 是一款优秀的持久层框架，支持自定义 SQL、存储过程以及高级映射。MyBatis 免除了几乎所有的 JDBC 代码以及设置参数和获取结果集的工作。本文梳理从零基础到精通的系统学习路线，涵盖 MyBatis 基础、映射配置、动态 SQL、高级特性、MyBatis-Plus、项目实战及面试备战 7 个阶段。

## 学习前提

- **Java 基础**：熟练掌握 Java 编程
- **SQL 基础**：熟练使用 SQL 进行增删改查（必学）
- **JDBC**：理解 JDBC 的基本使用（建议）
- **Maven**：理解依赖管理（建议）

## 整体学习建议

1. 先学 SQL —— MyBatis 核心是 SQL，需熟练掌握增删改查、多表查询、子查询等
2. 理解 JDBC —— MyBatis 是对 JDBC 的封装，理解 JDBC 有助于掌握 MyBatis
3. 重点学 MyBatis-Plus —— 实际项目中大多使用 MyBatis-Plus，大幅提高开发效率
4. 多做实战项目 —— 至少搭建一个增删改查项目，体验 MyBatis 完整使用流程
5. 善用 AI 工具辅助理解概念、生成 SQL

---

## 阶段 1：MyBatis 基础（10-15 天）

### 学习目标
理解 MyBatis 基本概念，掌握基本使用。

### 知识点

**MyBatis 简介（必学）**
- MyBatis 的特点和优势
- MyBatis 与 Hibernate 的区别
- MyBatis 与 JDBC 的关系

**核心组件（必学）**
- SqlSessionFactory —— 核心对象，用于创建 SqlSession
- SqlSession —— 执行 SQL 的会话对象，类似 JDBC 的 Connection
- Mapper 接口

**配置（必学）**
- mybatis-config.xml 配置文件
- 数据源配置
- 映射器配置

**基本使用（必学）**
- 单表 CRUD 操作
- 参数传递：`#{}`（预编译，防 SQL 注入）与 `${}`（字符串拼接，有注入风险）的区别
- 结果映射

### 学习资源
- [MyBatis 官方文档（中文）](https://mybatis.org/mybatis-3/zh_CN/index.html)

---

## 阶段 2：映射配置（10-15 天）

### 学习目标
掌握映射配置，能够处理复杂查询结果。

### 知识点

**Mapper XML（必学）**
- Mapper XML 结构
- SQL 语句配置（select、insert、update、delete）
- 参数映射（parameterType）
- 结果映射（resultType、resultMap）

**resultMap（必学）**
- 字段与属性映射
- 一对一关联（association）
- 一对多关联（collection）

**注解方式（建议学）**
- @Select、@Insert、@Update、@Delete
- 简单 SQL 用注解，复杂 SQL（如动态 SQL）建议用 XML

### 学习资源
- [MyBatis XML 映射官方文档](https://mybatis.org/mybatis-3/zh_CN/sqlmap-xml.html)

---

## 阶段 3：动态 SQL（10-12 天）

### 学习目标
动态 SQL 是 MyBatis 的强大功能，可根据条件动态生成 SQL 语句，避免字符串拼接。

### 知识点

**动态 SQL 标签（必学）**
- `if` —— 条件判断
- `choose`、`when`、`otherwise` —— 多分支选择
- `where` —— 自动去除多余 and/or
- `set` —— 自动去除多余逗号
- `foreach` —— 遍历集合（in 查询、批量插入）
- `trim` —— 自定义前缀/后缀处理

**SQL 片段（建议学）**
- `sql` 标签：定义可复用的 SQL 片段
- `include` 标签：引用 SQL 片段

### 学习资源
- [MyBatis 动态 SQL 官方文档](https://mybatis.org/mybatis-3/zh_CN/dynamic-sql.html)

---

## 阶段 4：高级特性（8-10 天）

### 学习目标
掌握缓存、分页、插件等高级特性。

### 知识点

**缓存（建议学）**
- 一级缓存（SqlSession 级别，默认开启）
- 二级缓存（Mapper 级别，需手动开启）
- 缓存的配置与使用

**分页（必学）**
- 手动分页
- PageHelper 分页插件

**插件机制（建议学）**
- MyBatis 插件原理
- 自定义插件

**逆向工程（建议学）**
- MyBatis Generator
- 自动生成 Mapper、XML、实体类

### 学习资源
- [PageHelper 官方文档](https://pagehelper.github.io/)
- [MyBatis Generator 官方文档](https://mybatis.org/generator/)

---

## 阶段 5：MyBatis-Plus（15-20 天）

### 学习目标
掌握 MyBatis-Plus，能够使用其快速开发。

### 知识点

**MyBatis-Plus 基础（必学）**
- MyBatis-Plus 的特点（只做增强不做改变）
- BaseMapper 接口 —— 继承即可拥有单表 CRUD
- 无需编写 SQL 的 CRUD 操作

**条件构造器（必学）**
- QueryWrapper —— 基础查询条件封装
- LambdaQueryWrapper —— Lambda 风格，避免硬编码字段名
- UpdateWrapper —— 更新条件封装
- 复杂查询的构造

**代码生成器（必学）**
- AutoGenerator —— 自动生成 Entity、Mapper、Service、Controller

**分页插件（必学）**
- MyBatis-Plus 分页插件
- Page 对象

**其他功能（建议学）**
- 逻辑删除
- 自动填充
- 乐观锁
- 多租户
- MyBatis Flex（简单了解，更轻量）

### 学习资源
- [MyBatis-Plus 官方文档](https://baomidou.com/)

---

## 阶段 6：项目实战（15-20 天）

### 学习目标
通过实际项目巩固所学知识，积累 MyBatis 项目经验。

### 学习建议
1. **从简单项目开始**：搭建增删改查项目（如学生管理系统、图书管理系统），熟悉 MyBatis 完整流程
2. **使用 MyBatis-Plus**：实际项目中建议使用，代码生成器生成基础代码后再开发业务逻辑
3. **处理复杂查询**：学会用 XML 编写复杂 SQL（多表联查、分组统计）或用条件构造器
4. **结合 Spring Boot**：学习在 Spring Boot 中集成 MyBatis / MyBatis-Plus

### 项目推荐

**入门级项目**
- 学生管理系统
- 图书管理系统
- 博客系统
- 待办事项应用

**进阶级项目**
- 电商系统
- 在线教育平台
- 企业管理系统

### 学习资源
- [Spring Boot 整合 MyBatis-Plus 官方教程](https://baomidou.com/getting-started/)

---

## 阶段 7：经典面试题

### 学习目标
熟练掌握 MyBatis 常见面试题，准备简历和项目经历。

### 学习建议
1. 简历上要有使用 MyBatis 的项目经历
2. 多刷面试题，重点涵盖基本使用、动态 SQL、缓存、MyBatis-Plus
3. 准备项目经历，能回答 MyBatis 在项目中的实际使用场景

### 经典面试题

**基础概念**
1. MyBatis 是什么？有什么特点？
2. MyBatis 和 Hibernate 有什么区别？
3. `#{}` 和 `${}` 有什么区别？
4. MyBatis 的核心组件有哪些？

**映射配置**
1. resultType 和 resultMap 有什么区别？
2. 如何处理一对一、一对多关联查询？
3. MyBatis 如何实现分页？

**动态 SQL**
1. MyBatis 的动态 SQL 有哪些标签？
2. where 标签和 if 标签有什么区别？
3. foreach 标签如何使用？

**高级特性**
1. MyBatis 的缓存机制是怎样的？
2. 一级缓存和二级缓存有什么区别？
3. MyBatis 的插件机制是什么？

**MyBatis-Plus**
1. MyBatis-Plus 有什么特点？
2. 条件构造器如何使用？
3. MyBatis-Plus 如何实现逻辑删除？

---

> 来源：鱼皮·编程导航 / codefather — MyBatis 学习路线
