---
title: "GraphQL 学习路线"
date: 2026-07-19
tags:
  - learning
  - graphql
  - API
  - frontend
  - backend
  - roadmap
source: "鱼皮·编程导航 / codefather"
---

# GraphQL 学习路线

> GraphQL 是 Facebook 2015 年开源的 API 查询语言和运行时，让客户端精确请求所需数据，避免 REST API 的过度获取/获取不足问题。被 Facebook、GitHub、Shopify、Netflix 等公司使用。

## 核心思想

**"按需获取数据"** — 客户端在单个请求中精确描述需要的字段，服务器只返回请求的字段。核心概念：Schema（数据结构和查询接口定义）、Query（查询）、Mutation（修改）、Subscription（实时订阅）、Resolver（数据获取逻辑）。

## 学习前提

- JavaScript/TypeScript（ES6+ 语法，**必学**）
- REST API 基础（**建议**）
- 前端或后端 Web 开发基础（**建议**）

## 阶段 1：GraphQL 基础（3-15 天）

### 核心概念（必学）
- GraphQL 定义和特点 vs REST API
- Schema（模式）、Type（类型）
- Query（查询）、Mutation（修改）、Subscription（订阅，建议学）

### 查询语法（必学）
- 字段（Field）、参数（Arguments）
- 别名（Aliases）、片段（Fragments）
- 变量（Variables）

### 学习建议
- 查询语法类似 JSON 但更强大，支持指定字段、传参、变量
- 类型系统强类型，提供类型安全和自动补全
- 在 [GraphQL Playground](https://github.com/graphql/graphql-playground) 或 [Apollo Sandbox](https://studio.apollographql.com/sandbox/explorer) 中练习

### 学习资源
- [GraphQL 官方文档](https://graphql.org/)
- [GraphQL 中文文档](https://graphql.cn/)

## 阶段 2：Schema 定义（3-10 天）

### 类型定义（必学）
- 标量类型（Int、Float、String、Boolean、ID）
- 对象类型（Object Type）、枚举类型（Enum）
- 接口（Interface，建议学）、联合类型（Union，建议学）

### 字段参数（必学）
- 参数定义、必填/可选参数、默认值

### 输入类型（必学）
- Input Type 及其与 Object Type 的区别

## 阶段 3：客户端使用（3-15 天）

### Apollo Client（必学，推荐）
- 安装配置、useQuery Hook、useMutation Hook
- 缓存管理

### 前端集成（必学）
- React + Apollo Client
- Vue + Apollo Client（建议学）

### 其他客户端
- urql、Relay（可选）

### 学习资源
- [Apollo Client 官方文档](https://www.apollographql.com/docs/react/)

## 阶段 4：服务器开发（5-20 天）

### Apollo Server（必学，推荐）
- 安装配置、Schema 定义、Resolver 实现
- 数据源集成

### Resolver（必学）
- 参数解析、上下文（Context）
- DataLoader（解决 N+1 查询问题，建议学）

### 其他服务器
- GraphQL Yoga、express-graphql

### 学习资源
- [Apollo Server 官方文档](https://www.apollographql.com/docs/apollo-server/)

## 阶段 5：实战应用（5-20 天）

### 入门项目
- 博客系统（GraphQL API）
- 待办事项应用

### 优质开源项目
- [howtographql](https://github.com/howtographql/howtographql) — 全栈教程，含前后端实战（8.7k+ stars）

### 学习建议
- 先用简单项目熟悉完整流程
- 前后端结合（Apollo Client + Apollo Server）
- 对比 REST，将一个 REST API 改造为 GraphQL 体验差异

## 求职备战

### 经典面试题
1. GraphQL 是什么？有什么特点？
2. GraphQL 和 REST API 有什么区别？
3. 什么是 Schema？如何定义 Schema？
4. Query 和 Mutation 有什么区别？
5. 什么是 Resolver？

> 来源：鱼皮·编程导航 / codefather
