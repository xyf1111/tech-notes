---
title: "工具 08 - Node.js 学习路线"
date: 2026-07-31
tags: [Node.js, JavaScript, 学习路线, 全栈]
source: "鱼皮·编程导航 / codefather"
---

# 工具 08 - Node.js 学习路线

> Node.js 是基于 Chrome V8 引擎的 JavaScript 运行时，事件驱动、非阻塞 I/O，让 JavaScript 从浏览器走向服务器端，可用于后端开发、命令行工具、桌面应用等场景。本篇学习路线涵盖 Node.js 基础、核心模块、Web 框架、数据库操作、项目实战、求职备战 6 个阶段，零基础到精通一条龙。

## 整体学习建议

1. **JavaScript 是前提** — 先系统掌握 JavaScript 基础与 ES6+（箭头函数、Promise、async/await），基础不牢学 Node 会很吃力
2. **理解异步编程** — Node 核心是异步非阻塞 I/O，按「回调 → Promise → async/await」循序渐进理解
3. **多做项目实践** — 从简单 HTTP 服务器开始，逐步开发 RESTful API、Web 应用、实时聊天等项目
4. **善用 npm 生态** — 数百万开源包可提升效率，但核心逻辑避免过度依赖第三方包
5. **版本与模块管理** — 用 nvm 管理 Node 版本，理解 CommonJS 与 ES Module 两套模块系统

## 阶段 1：Node.js 基础（8-15 天）

### 学习目标

理解 Node.js 基本概念，掌握安装与基本使用。

### 知识点

- **基础概念** — 定义与特点、应用场景、事件驱动与非阻塞 I/O、单线程模型、事件循环（Event Loop）
- **安装与配置** — 官网下载 / nvm 管理版本、npm 使用（安装、卸载、更新包）、package.json、node_modules 目录
- **模块系统** — CommonJS（require、module.exports）、ES Module（import、export）、内置模块与第三方模块、自定义模块
- **npm 包管理** — npm init（初始化项目）、npm install（安装依赖）、npm scripts（脚本命令）、package-lock.json、yarn 和 pnpm（建议学）

### 学习建议

1. 用 nvm 管理 Node 版本，方便在不同项目间切换
2. 两套模块系统并存，建议优先学习 ES Module
3. yarn / pnpm 在速度与磁盘占用上更优，建议了解
4. 多动手创建简单 Node.js 脚本，熟悉基本操作

### 学习资源

- [尚硅谷 Node.js 教程](https://www.bilibili.com/video/BV1bs411E7pD/)：经典教程
- [尚硅谷 Node.js 视频教程](https://www.bilibili.com/video/BV1gM411W7ex/)：零基础入门，新手到高手
- [20 分钟入门 Node.js](https://www.bilibili.com/video/BV1vVyeYMEAs)
- [Node.js 官方文档](https://nodejs.org/docs/latest/api/)
- [Node.js 中文文档](https://nodejs.cn/)

## 阶段 2：Node.js 核心模块（8-15 天）

### 学习目标

掌握 Node.js 核心模块，能够进行文件操作、网络请求等基本开发。

### 知识点

- **文件系统 fs** — 读取（readFile、readFileSync）、写入（writeFile、writeFileSync）、文件信息（stat）、目录操作（mkdir、readdir）、文件流（Stream）
- **路径处理 path** — join（拼接）、resolve（绝对路径）、dirname / basename / extname
- **HTTP 模块** — 创建 HTTP 服务器、处理请求与响应、路由处理、静态文件服务
- **事件 events** — EventEmitter、on（监听）、emit（触发）、once、off
- **流 Stream** — 可读流（Readable）、可写流（Writable）、管道（pipe）
- **Buffer** — 创建与使用、与字符串的转换
- **其他核心模块** — url（URL 解析）、querystring（查询字符串解析）、crypto（加密）、util（工具函数）

### 学习重点

1. fs 是最常用核心模块，同步方法（如 readFileSync）会阻塞执行，建议用异步方法
2. 实际开发多用 Express/Koa 框架，但 HTTP 模块的工作原理必须理解
3. 事件驱动是核心特性，Node 的很多模块继承自 EventEmitter
4. Stream 处理大文件可边读边处理，避免一次性加载整个文件到内存

### 学习资源

- [Node.js 官方文档（核心模块）](https://nodejs.org/docs/latest/api/)

## 阶段 3：Web 框架（10-20 天）

### 学习目标

掌握 Express 或 Koa 框架，能够快速开发 RESTful API。

### 知识点

- **Express（必学）** — 安装与使用、路由（Router）、中间件（Middleware）、请求与响应对象、模板引擎（EJS、Pug，可不学）、错误处理、静态文件服务
- **Koa（建议学）** — 洋葱模型、中间件、koa-router、错误处理
- **RESTful API 设计（必学）** — 概念与规范、HTTP 方法（GET、POST、PUT、DELETE）、状态码、参数传递（Query、Body、Params）、API 文档（Swagger、Postman）
- **身份认证（必学）** — Session 与 Cookie、JWT（JSON Web Token）、OAuth 2.0（建议学）
- **文件上传（建议学）** — Multer 中间件、文件存储（本地存储、云存储）

### 学习建议

1. Express 最流行、社区活跃，简单易学，优先学习；Koa 采用 async/await 语法更简洁，时间充足再学
2. 中间件是 Express/Koa 的核心概念，理解执行顺序与洋葱模型
3. RESTful 是现代 Web 开发标准，用 HTTP 方法表示操作、HTTP 状态码表示结果
4. JWT 是现代 Web 应用最常用的认证方式，理解工作原理与使用方法

### 学习资源

- [Express 官方文档](https://expressjs.com/)
- [Koa 官方文档](https://koajs.com/)
- [尚硅谷 Node.js 视频教程](https://www.bilibili.com/video/BV1gM411W7ex/)
- [20 分钟入门 Node.js](https://www.bilibili.com/video/BV1vVyeYMEAs)

## 阶段 4：数据库操作（10-15 天）

### 学习目标

掌握在 Node.js 中连接和操作 MySQL、MongoDB 等数据库，能够进行数据的增删改查。

### 知识点

- **MySQL（必学）** — mysql2 库、连接数据库、执行 SQL 语句、参数化查询（防止 SQL 注入）、连接池
- **MongoDB（建议学）** — mongoose 库、定义 Schema 和 Model、CRUD 操作、查询与聚合
- **ORM 框架（建议学）** — Sequelize（MySQL ORM）、Prisma（现代 ORM，语法简洁、类型安全，推荐）、TypeORM
- **Redis（建议学）** — ioredis 库、基本操作（set、get、del）、缓存应用

### 学习建议

1. Node.js 操作数据库一般使用第三方库：MySQL 推荐 mysql2，MongoDB 推荐 mongoose
2. ORM 框架可简化数据库操作、避免手写 SQL；Prisma 语法简洁、类型安全，推荐学习

### 学习资源

- [Sequelize 官方文档](https://sequelize.org/)：Sequelize ORM
- [Prisma 官方文档](https://www.prisma.io/)：Prisma ORM
- [Mongoose 官方文档](https://mongoosejs.com/)：Mongoose ODM

## 阶段 5：项目实战（20-30 天）

### 学习目标

通过实际项目巩固所学知识，积累项目经验。

### 学习建议

1. 从简单项目开始：Todo API、博客系统 API、用户管理系统等
2. 逐步增加复杂度：电商系统、社交平台、实时聊天系统（WebSocket）等
3. 全栈开发：结合前端框架（Vue、React）和 Node.js 后端，开发完整全栈应用
4. 应用所学技术：在项目中应用 Express/Koa、数据库、身份认证、文件上传等
5. 部署上线：部署到服务器（如阿里云、腾讯云），体验完整项目上线流程

### 项目推荐

- **入门级** — RESTful API 服务、博客系统后端、用户管理系统、文件上传服务
- **进阶级** — 电商系统后端、社交平台 API、实时聊天系统（WebSocket）、内容管理系统（CMS）
- **优质开源项目** — [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)（100k+ stars，最佳实践大全）、[Awesome Node.js](https://github.com/sindresorhus/awesome-nodejs)（59k+ stars，资源大全）、[Node Express TypeScript Starter](https://github.com/takuyadev/node-express-typescript)（Express + TypeScript 起步项目）

### 学习资源

- [Node.js 项目实战教程](https://github.com/tuture-dev/nodejs-roadmap)：Node.js 实战学习路线

## 阶段 6：求职备战（面试前 1 个月突击）

### 学习目标

熟练掌握 Node.js 常见面试题，准备好简历和项目经历，顺利通过面试。

### 学习建议

1. 打磨简历和项目：简历上要有 1-2 个完整的 Node.js 项目，包括项目介绍、技术栈、实现的功能、技术难点等
2. 多刷面试题：主要包括 JavaScript 基础、Node.js 核心概念、异步编程、Express/Koa 框架、数据库操作等
3. 能讲清 Node.js 的优势（高并发、JavaScript 全栈、npm 生态）与适用场景（I/O 密集型应用）
4. 准备手写代码题：如实现简单的 HTTP 服务器、Promise、async/await 等

### 经典面试题

- **基础概念** — Node.js 是什么？有什么特点？事件循环是怎样的？为什么单线程却能处理高并发？非阻塞 I/O 是什么？
- **模块与包管理** — CommonJS 和 ES Module 有什么区别？require 和 import 有什么区别？npm、yarn、pnpm 有什么区别？package.json 和 package-lock.json 有什么区别？
- **异步编程** — 回调函数、Promise、async/await 有什么区别？如何避免回调地狱？Promise 的状态有哪些？async/await 的原理是什么？
- **Web 开发** — Express 和 Koa 有什么区别？中间件是什么、如何实现？如何用 JWT 实现身份认证？如何处理跨域（CORS）？
- **性能优化** — Node.js 如何做性能优化？如何避免内存泄漏？如何进行错误处理？

## 持续学习资源

- [Node.js 官方文档](https://nodejs.org/docs/latest/api/)：最权威的学习资料
- [Node.js 中文文档](https://nodejs.cn/)
- [Node.js GitHub](https://github.com/nodejs/node)：Node.js 开源项目
- [Awesome Node.js](https://github.com/sindresorhus/awesome-nodejs)：Node.js 资源大全
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)：Node.js 最佳实践
- [Node.js 官方博客](https://nodejs.org/en/blog)
- [Netflix TechBlog](https://netflixtechblog.com/)：Netflix 技术实践
- [PayPal Engineering](https://medium.com/paypal-tech)：PayPal 技术博客
- [淘宝前端团队 FED](https://fed.taobao.org/)：阿里淘宝前端团队

## 写在最后

Node.js 轻量、高性能，适合快速开发和微服务架构；前端开发者学习 Node.js 可以成为全栈工程师。学习关键在理解异步编程与事件驱动模型，多做实践、多写代码即可逐渐掌握。在 AI 时代，Node.js 也可用于 AI 应用的 API 开发与数据处理。

> 来源：鱼皮·编程导航 / codefather
