---
title: "工具 07 - Next.js 学习路线"
date: 2026-07-31
tags: [Next.js, React, 全栈, 学习路线, frontend]
source: "鱼皮·编程导航 / codefather"
---

# 工具 07 - Next.js 学习路线

> Next.js 是由 Vercel 开发的基于 React 的全栈 Web 框架，提供服务器端渲染（SSR）、静态站点生成（SSG）、增量静态再生（ISR）、API 路由、文件系统路由等开箱即用功能。本路线从 React/JS 基础出发，覆盖 Next.js 核心概念、App Router 与 React Server Components、数据获取与缓存、API 路由与后端开发、优化与部署、项目实战、求职备战 7 个阶段。

## 整体学习建议

1. **先打牢 React 基础** — Next.js 基于 React，先熟练掌握组件、Hooks、状态管理等核心概念，再学 Next.js
2. **学最新版本** — 优先学习 Next.js 15+ 的 App Router 和 React Server Components，这是框架的未来方向
3. **理解渲染原理** — SSR、SSG、ISR 是核心特性，要理解它们的原理和使用场景
4. **优先 App Router** — 两套路由系统中 App Router 是新一代（13+），Pages Router 已不推荐新项目使用
5. **以官方文档为准** — 框架迭代很快，勤查官方文档；可用 AI 工具辅助开发

## 阶段 1：Next.js 基础（10-20 天）

### 学习目标

理解 Next.js 的核心概念，掌握项目的创建和基本使用。

### 知识点

- **Next.js 简介** — 特点与优势、Next.js 与 React 的关系、SSR / SSG / ISR 概念
- **项目创建** — create-next-app 脚手架、项目结构、配置文件（next.config.js）
- **路由系统** — 文件系统路由、动态路由、路由导航（Link 组件）、嵌套路由
- **页面和布局** — 页面组件、布局组件（Layout）、模板（Template）、加载和错误处理

### 学习重点

1. 路由基于文件系统：在 app 目录下创建文件夹和文件即可自动生成路由，比传统路由配置更简单直观
2. Next.js 15 默认使用 App Router（app 目录），Pages Router（pages 目录）仍支持但不推荐新项目使用
3. Layout 可为多个页面共享布局（导航栏、侧边栏），页面切换时保持状态、不重新渲染

### 学习资源

- [Next.js 官方文档](https://nextjs.org/docs) — 最权威的学习资料
- [Next.js 官方教程](https://nextjs.org/learn) — 官方 Learn 课程
- [Next.js 15 + Antd 5 开发教程](https://zhuanlan.zhihu.com/p/1897759368063222429)

## 阶段 2：App Router 和 React Server Components（5-15 天）

### 学习目标

深入理解 App Router 与 React Server Components，掌握更高效的服务端渲染方式。

### 知识点

- **App Router（核心重点）** — 与 Pages Router 的区别、app 目录结构、路由组（Route Groups）、并行路由（Parallel Routes）、拦截路由（Intercepting Routes）
- **React Server Components（核心重点）** — Server / Client Components 区别、"use client" 指令、RSC 优势、何时选用
- **Server Actions** — 定义与使用、"use server" 指令、表单处理、数据变更
- **流式渲染** — Streaming、Suspense、loading.js

### 学习建议

1. Server Components 在服务器上渲染，可直接访问数据库，不增加客户端 JS 体积
2. 大部分组件应为 Server Components，需要交互时用 "use client" 标记为 Client Components
3. Server Actions 可在服务器执行函数（如表单提交、数据变更），无需编写 API 路由，大幅简化全栈开发
4. 框架版本迭代较快，仔细阅读官方文档

### 学习资源

- [Next.js App Router 官方文档](https://nextjs.org/docs/app)

## 阶段 3：数据获取和缓存（5-15 天）

### 学习目标

掌握 Next.js 的数据获取方法，理解缓存机制。

### 知识点

- **数据获取** — Server Components 中 async/await 获取数据、fetch() API、数据库查询（Prisma、Drizzle）
- **渲染策略** — 静态渲染（Static Rendering）、动态渲染（Dynamic Rendering）、增量静态再生（ISR）
- **缓存机制** — Request Memoization、Data Cache、Full Route Cache、Router Cache、revalidate 与 revalidatePath

### 学习建议

1. Server Components 可直接 async/await 获取数据，无需 useEffect / useState
2. Next.js 有强大的多层缓存机制，要理解不同缓存层级及如何控制缓存
3. 静态渲染在构建时生成页面、动态渲染在请求时生成，按页面特性选择合适的策略

### 学习资源

- [Next.js 数据获取文档](https://nextjs.org/docs/app/building-your-application/data-fetching)

## 阶段 4：API 路由和后端开发（7-20 天）

### 学习目标

掌握 Next.js 的 API 路由，能够在同一项目中开发前后端，实现真正的全栈开发。

### 知识点

- **Route Handlers** — API 路由定义（app/api 目录下 route.ts）、GET / POST / PUT / DELETE 方法、请求和响应处理、路由段配置
- **数据库集成** — Prisma ORM、MongoDB、PostgreSQL
- **认证和鉴权** — NextAuth.js、JWT、Session 管理
- **文件上传** — 文件上传处理、图片优化

### 学习建议

1. Prisma 是目前最流行的 TypeScript ORM，与 Next.js 配合良好，推荐用于数据库操作
2. NextAuth.js 是 Next.js 生态的认证库，支持 OAuth、邮箱密码、Magic Link 等多种认证方式

### 学习资源

- [Next.js Route Handlers 文档](https://nextjs.org/docs/app/building-your-application/routing/route-handlers)
- [Prisma 官方文档](https://www.prisma.io/docs)
- [NextAuth.js 文档](https://next-auth.js.org/)

## 阶段 5：优化和部署（5-15 天）

### 学习目标

掌握 Next.js 的性能优化与部署方法，让应用更快更稳定。

### 知识点

- **性能优化** — 图片优化（next/image）、字体优化（next/font）、代码分割、懒加载
- **SEO 优化** — Metadata API、生成 sitemap、robots.txt
- **部署** — Vercel 一键部署、自托管部署（Node.js、Docker）、静态导出

### 学习建议

1. Vercel 是 Next.js 官方部署平台，部署简单且免费，适合个人和小型项目；可参考 [Vercel 部署视频教程](https://www.bilibili.com/video/BV1TV4y1j76t/)
2. next/image 可自动优化图片（懒加载、响应式、格式转换），用其替代原生 img 标签
3. Metadata API 可方便设置页面 meta 标签提升 SEO，每个页面都应配置合适的 metadata

### 学习资源

- [Next.js 部署文档](https://nextjs.org/docs/app/building-your-application/deploying)
- [Vercel 官网](https://vercel.com/)

## 阶段 6：项目实战（30-60 天）

### 学习目标

通过实际项目巩固所学知识，积累 Next.js 项目经验。

### 学习建议

1. 从简单项目开始（个人博客、企业官网等），熟悉 Next.js 完整开发流程
2. 开发全栈项目：API 路由做后端、Server Components 做前端，体验真正的全栈开发
3. 在项目中应用 SSR、SSG、ISR 等特性，理解不同渲染策略的适用场景
4. 完成项目后部署到 Vercel 或其他平台，让项目真正可访问

### 项目推荐

- **入门级** — 个人博客（支持 Markdown）、企业官网、作品集网站、待办事项应用
- **进阶级** — 全栈电商网站、SaaS 平台、社交媒体应用、在线教育平台
- **官方示例** — [Next.js 官方示例项目](https://github.com/vercel/next.js/tree/canary/examples)

### 学习资源

- [使用 Next.js + MongoDB 构建博客](https://www.bilibili.com/video/BV13Nafe4ES3/)（完整教程）

## 阶段 7：求职备战

### 学习目标

熟练掌握 Next.js 常见面试题，准备好简历和项目经历。

### 学习建议

1. 简历上要有 Next.js 全栈项目，对前端求职很加分
2. 多刷面试题，重点是 SSR、SSG、App Router、Server Components 等核心概念
3. 准备项目经历：能清楚说明为什么用 Next.js、用了哪些特性、如何优化性能

### 经典面试题

- **基础概念** — Next.js 是什么、Next.js 与 React 的区别、SSR / SSG 是什么、App Router 与 Pages Router 的区别
- **Server Components** — 什么是 React Server Components、Server / Client Components 区别、何时使用、use client / use server 的作用
- **数据获取** — Next.js 如何获取数据、什么是 ISR、缓存机制是怎样的、如何在 Server Components 中获取数据
- **其他** — 如何优化性能、如何部署、图片优化如何实现

## 持续学习资源

### Next.js 资源

- [Next.js 官网](https://nextjs.org/)
- [Next.js GitHub](https://github.com/vercel/next.js)
- [Vercel](https://vercel.com/)
- [Next.js 中文文档](https://www.nextjs.cn/)

### 技术博客

- [Vercel 博客](https://vercel.com/blog)
- [Next.js 官方博客](https://nextjs.org/blog)
- [Airbnb Tech Blog](https://medium.com/airbnb-engineering)
- [Stripe Engineering](https://stripe.com/blog/engineering)

## 写在最后

Next.js 是当前最热门的 React 全栈框架，学习路径：先打牢 React 基础（组件、Hooks、状态管理），再重点掌握 App Router 与 Server Components，最后多动手做项目。AI 时代可结合 Vercel AI SDK 快速开发 AI 应用，掌握 Next.js + AI 将提升求职竞争力。

> 来源：鱼皮·编程导航 / codefather
