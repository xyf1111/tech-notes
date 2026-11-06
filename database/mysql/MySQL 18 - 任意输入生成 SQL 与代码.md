---
title: "MySQL 18 - 任意输入生成 SQL 与代码"
date: 2026-08-10
tags: [数据库, SQL, 生成器, 设计模式]
source: "鱼皮·编程导航 / codefather"
---

# MySQL 18 - 任意输入生成 SQL 与代码

> 本文整理自 codefather（鱼皮·编程导航）《这次我开源，别再打我啦！》：作者开源了「SQL 之父 sql-father」——一个输入任意描述即可生成 **SQL 语句 + 模拟数据 + 代码** 的工具网站。核心架构理念是「**任意输入 => 统一 Schema => 任意输出**」：Schema 构造器将各种输入收敛为统一 Schema，再由生成器产出 SQL / Java / 前端代码与模拟数据。后端大量运用设计模式（策略、单例、工厂、门面），前端包含复杂嵌套 & 动态 & 可折叠表单与代码编辑器。开源代码：前端 https://github.com/liyupi/sql-father-frontend-public ，后端 https://github.com/liyupi/sql-father-backend-public

## 项目概览

### 项目特点

- 功能完整：分为**用户前台**和**管理后台**
- 达到上线标准、架构设计清晰、目录结构规范
- 前端：复杂的嵌套 & 动态 & 可折叠表单、代码编辑器
- 后端：多种主流设计模式、AOP 切面鉴权

### 技术栈

**前端主要技术：**

- React 18
- Umi 4.x
- Ant Design 4.x 组件库
- Ant Design Pro Components 高级组件
- TypeScript 类型控制
- ESLint 代码规范控制
- Prettier 美化代码

**前端依赖库：**

- monaco-editor：代码编辑器
- copy-to-clipboard：剪切板复制

**后端主要技术：**

- Spring Boot 2.7.x
- MyBatis Plus 3.5.x
- MySQL 8.x
- Spring AOP

**后端依赖库：**

- FreeMarker：模板引擎
- Druid：SQL 解析
- datafaker：模拟数据
- Apache Commons Lang3：工具库
- Hutool：工具库
- Gson：JSON 解析
- Easy Excel：Excel 导入导出
- Knife4j：接口文档生成

## 整体架构设计

核心设计理念：**将各输入方式统一为明确的 Schema，并根据 Schema 生成各类内容**，即：

> 任意输入 => 统一 Schema => 任意输出

系统分为以下核心模块，各模块职责分明：

1. **Schema 构造器**：将各种不同的输入源转为统一的 TableSchema 定义
2. **统一 Schema 定义**：本质是一个 Java 类（JSON 配置），用于保存表和字段的信息
3. **生成器**：负责根据 Schema 生成数据和代码
4. **共享服务**：包括词库、表信息、字段信息共享

## Schema 构造器

- **核心类**：`TableSchemaBuilder`，作用是将不同的参数统一收敛为 `TableSchema` 对象
- 包含多种构造方法，对应不同输入源（如 SQL 文本、JSON、表单参数、Excel 等）
- **buildFromSql（根据 SQL 生成 Schema）**：使用 **Druid 数据库连接池自带的语法解析器**，非常强大
- 关键经验：**解析器这种东西一般不要自己写**——自己写耗时费力，写出来还没成熟库好用

## 统一 Schema 定义

用于保存表和字段的信息，本质是 Java 类（JSON 配置）。示例结构如下：

```json
{
  "dbName": "库名",
  "tableName": "test_table",
  "tableComment": "表注释",
  "mockNum": 20,
  "fieldList": [{
    "fieldName": "username",
    "comment": "用户名",
    "fieldType": "varchar(256)",
    "mockType": "随机",
    "mockParams": "人名",
    "notNull": true,
    "primaryKey": false,
    "autoIncrement": false
  }]
}
```

字段说明：

| 字段 | 含义 |
| --- | --- |
| dbName / tableName / tableComment | 库名 / 表名 / 表注释 |
| mockNum | 模拟数据条数 |
| fieldList[].fieldName | 字段名 |
| fieldList[].comment | 字段注释 |
| fieldList[].fieldType | 字段类型（如 varchar(256)） |
| fieldList[].mockType | 模拟数据类型（如「随机」） |
| fieldList[].mockParams | 模拟数据参数（如「人名」） |
| fieldList[].notNull / primaryKey / autoIncrement | 非空 / 主键 / 自增标记 |

## 生成器

### 多种生成类型（Builder）

将**每种生成类型定义为一个 Builder**：

- **SqlBuilder**：生成 SQL 代码
- **JavaCodeBuilder**：生成 Java 代码
- **FrontendCodeBuilder**：生成前端代码

**SQL 代码生成器（SqlBuilder）**：

- 使用**方言（Dialect）**支持不同的数据库类型 → 策略模式
- 使用**单例模式 + 工厂模式**创建方言实例

**Java、前端代码生成器（JavaCodeBuilder、FrontendCodeBuilder）**：

- 使用 **FreeMarker 模板引擎**生成代码（模板 + 数据模型渲染）

### 多种模拟数据生成规则（Generator）

- 每种生成规则定义为一个 **Generator**
- **DataGeneratorFactory（工厂模式）**：对多个 Generator 实例进行统一的创建和管理
- **dataFaker** 库实现随机数据生成（RandomDataGenerator）
- **Generex** 库实现正则表达式数据生成（RuleDataGenerator）

### 统一的生成入口

- 使用**门面模式（Facade）**聚合各种生成类型
- 提供统一的生成调用和校验方法

## 设计模式应用一览

| 设计模式 | 应用场景 |
| --- | --- |
| 策略模式 | SqlBuilder 通过方言（Dialect）支持不同数据库类型 |
| 单例模式 | 创建方言实例 |
| 工厂模式 | 创建方言实例；DataGeneratorFactory 统一创建管理各 Generator |
| 门面模式 | 统一生成入口，聚合各种生成类型并提供统一调用与校验 |
| AOP 切面 | 后端鉴权 |

## 小结

- 一句话本质：**任意输入 => 统一 Schema => 任意输出**，用统一 Schema 中间层解耦「输入」与「输出」
- 最值得借鉴的设计：统一 Schema 建模 + 各种生成器（Builder / Generator）分类 + 共享服务（词库 / 表信息 / 字段信息）
- 最值得学习的实现：复用 Druid 语法解析器、FreeMarker 模板生成、dataFaker / Generex 模拟数据、多种设计模式组合（策略 / 单例 / 工厂 / 门面）
- 适用边界：需要从多种输入源生成 SQL / 模拟数据 / 代码的场景；与「JSON 结构化生成 SQL」的 sql-generator（SQL 02）是不同工具——sql-generator 侧重文本解析替换生成复杂 SQL，本项目侧重统一 Schema 建模 + 设计模式组合
- 延伸建议：该项目后续更新较少，可自行扩展（新增输入源、生成类型、模拟数据规则），提交代码前需遵循项目规范

> 来源：鱼皮·编程导航 / codefather
