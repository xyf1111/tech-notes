---
title: "工具 10 - React 学习路线"
date: 2026-08-04
tags:
  - React
  - 前端
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# React 学习路线

> React 由 Facebook（现 Meta）开发并开源，2013 年首次发布，是全球最流行的前端框架之一，国外使用率超过 Vue，大厂应用广泛。核心思想是组件化和声明式编程，通过将界面拆分为独立、可复用的组件，让前端开发更高效、可维护。核心特点是虚拟 DOM（通过 Diff 算法最小化 DOM 操作）和单向数据流。使用 JSX 语法，将 HTML 写在 JavaScript 中。除 Web 开发外，还可通过 React Native 开发移动应用，实现「一次学习，到处编写」。
>
> React 版本迭代很快，最新版本为 React 19，引入了服务器组件（Server Components）、Actions、use Hook 等新特性。React 生态丰富，可结合 TensorFlow.js、AI SDK 等 AI 库，配合 AI Vibe Coding 快速开发 Web 应用。

## 整体学习建议

1. **掌握 JavaScript 是前提** — React 大量使用 ES6+ 语法（箭头函数、解构、展开运算符），基础不牢学 React 会很吃力
2. **重点掌握 Hooks** — Hooks 是现代 React 开发的标准，重点学习 useState、useEffect、useContext、useMemo、useCallback
3. **结合项目实践，边学边做** — 每学完一个知识点就动手实现一个小功能
4. **多看官方文档** — React 官方文档有大量示例和交互式教程，质量很高
5. **善用 AI 工具** — 可用 ChatGPT、Cursor、TRAE 等辅助学习和开发

### 学习前提

1. HTML 和 CSS：网页的基础
2. JavaScript 基础：变量、函数、对象、数组等
3. ES6+ 语法：箭头函数、Promise、async/await、解构等【重点】

## 阶段 1：React 基础（7-20 天）

### 学习目标

掌握 React 的基础知识，能够使用 React 开发简单的应用。

### 知识点

**React 基础概念【必学】：**
- React 的特点和优势
- 虚拟 DOM 和 Diff 算法
- JSX 语法
- 组件和 Props
- 单向数据流

**项目创建【必学】：**
- Create React App（传统方式）
- Vite（现代方式，推荐）
- 项目结构

**JSX【必学】：**
- JSX 的语法规则
- JSX 中的表达式
- 条件渲染（&&、三元运算符）
- 列表渲染（map）
- 事件处理

**组件【必学】：**
- 函数组件（推荐）
- 类组件（了解即可）
- Props 的传递和使用
- 组件的组合和嵌套

### 学习重点

1. Vite 是现代前端项目的推荐构建工具，启动速度快、热更新快，建议使用 Vite 创建 React 项目
2. JSX 是 JavaScript 的扩展语法，看起来像 HTML 但实际是 JavaScript，会被编译成 React.createElement 函数调用
3. React 推荐使用函数组件 + Hooks，类组件已不推荐；看到老教程讲类组件可以跳过
4. Props 是组件间通信的主要方式，要理解其单向数据流（父组件 → 子组件）

此阶段要多写代码，熟悉 JSX 语法和组件的使用。

### 学习资源

- [React 官方文档](https://zh-hans.react.dev/)：最权威的学习资料（2023 年全面重写）
- [2025 年 React 教程](https://www.bilibili.com/video/BV1fpANeVEnS)（B站）
- [30 分钟学会 React 18 核心语法](https://www.bilibili.com/video/BV1pF411m7wV)（B站）

## 阶段 2：React Hooks（7-20 天）

Hooks 是特殊函数，允许在函数组件中使用状态和其他 React 功能而无需写类，是 React 的核心特性，也是现代 React 开发的标准。

### 学习目标

掌握 React Hooks，能够使用 Hooks 管理组件的状态和副作用。

### 知识点

**基础 Hooks【必学】：**
- useState：状态管理
- useEffect：副作用处理
- useContext：上下文

**性能优化 Hooks【必学】：**
- useMemo：缓存计算结果
- useCallback：缓存函数
- memo：缓存组件

**其他 Hooks【建议学】：**
- useRef：引用 DOM 或保存变量
- useReducer：复杂状态管理
- useLayoutEffect：同步副作用
- useImperativeHandle：自定义暴露给父组件的实例值

**自定义 Hooks【必学】：**
- 自定义 Hooks 的创建
- 逻辑复用

**React 19 新 Hooks【建议学】：**
- use：通用的资源读取 Hook
- useOptimistic：乐观更新
- useFormStatus：表单状态

### 学习重点

1. useState 和 useEffect 最常用：useState 管理组件状态，useEffect 处理副作用（网络请求、订阅事件）
2. useEffect 依赖数组很重要：空数组表示只在挂载时执行一次，不传数组表示每次渲染都执行
3. useMemo 和 useCallback 用于性能优化，避免不必要的重新渲染和重新计算，但不要过度优化
4. 自定义 Hooks 是逻辑复用的最佳实践，可将可复用逻辑抽取成独立 Hook
5. React 19 的 use Hook 可读取 Promise、Context 等资源，简化异步数据处理

### 学习资源

- [React Hooks 官方文档](https://zh-hans.react.dev/reference/react)
- [React 19 新特性官方博客](https://zh-hans.react.dev/blog/2024/12/05/react-19)

## 阶段 3：React Router（2-7 天）

React Router 是 React 的路由管理库，用于构建单页面应用。

### 学习目标

掌握 React Router，能够实现页面路由和导航。

### 知识点

**路由基础【必学】：**
- 路由的概念和作用
- 安装和配置 React Router
- BrowserRouter 和 HashRouter
- Route、Routes、Link
- 编程式导航（useNavigate）

**动态路由【必学】：**
- 路由参数（useParams）
- 查询参数（useSearchParams）

**嵌套路由【必学】：**
- 嵌套路由的配置
- Outlet 组件

**路由守卫【建议学】：**
- 路由拦截和权限控制

### 学习建议

1. React Router 版本更新迭代快且不同版本差异较大，建议直接看官方文档学习最新版本，不要学旧版本
2. BrowserRouter 使用 HTML5 History API，URL 更美观；HashRouter 兼容性更好。一般推荐使用 BrowserRouter

### 学习资源

- [React Router 官方文档](https://reactrouter.com/)

## 阶段 4：状态管理（3-7 天）

前端状态管理是组织、跟踪和更新应用中动态数据的方法，包括用户交互、服务器响应等各类状态，保证数据在组件间的一致性。说人话就是：把各页面或组件都需要的数据集中管理，便于公共读写。

### 学习目标

掌握至少一种状态管理方案，能够管理应用的全局状态。

### 知识点

**Context API【必学】：**
- Context 的创建和使用
- useContext Hook
- Context 的优缺点

**状态管理库【建议学】：**
- **Zustand**（推荐）：轻量级、简单易用
- **Redux Toolkit**：传统方案，功能强大但复杂
- **Jotai**：原子化状态管理
- **Recoil**：Facebook 出品

### 学习建议

1. Context API 是 React 内置方案，适合中小型应用；简单的全局状态（主题、用户信息）用 Context 就足够
2. 大型应用建议使用专门的状态管理库，Zustand 简单易用、体积小、性能好，是当前最推荐的方案
3. Redux 代码量较大、学习成本高，非特殊需求建议用 Zustand 而不是 Redux

### 学习资源

- [Zustand 官方文档](https://zustand-demo.pmnd.rs/)
- [Redux Toolkit 官方文档](https://redux-toolkit.js.org/)

## 阶段 5：React 19 新特性（可选）

React 19 引入了很多新特性，建议了解。

### 知识点

**服务器组件【建议学】：**
- Server Components 的概念
- 'use client' 和 'use server'
- RSC Payload

**新特性【建议学】：**
- Actions：表单处理的新方式
- use Hook：通用资源读取
- useOptimistic：乐观更新
- useFormStatus：表单状态

### 学习重点

1. 服务器组件是 React 19 的重要特性，需配合框架（如 Next.js）使用；不用 Next.js 可先不学
2. Actions 简化了表单处理，无需手动管理 loading 状态和错误处理

### 学习资源

- [React 19 发布文章](https://zh-hans.react.dev/blog/2024/12/05/react-19)：官方博客
- [React 服务器组件文档](https://zh-hans.react.dev/reference/rsc/server-components)：官方文档

## 阶段 6：项目实战（30-60 天）

### 学习目标

通过实际项目巩固所学知识，积累项目经验。

### 学习建议

1. 从简单项目开始：待办事项、天气查询、音乐播放器等
2. 使用 UI 组件库：Ant Design（国内最流行）、Material-UI、Chakra UI 等
3. 完整技术栈：React + Vite + React Router + Zustand + Ant Design + Axios
4. 前后端分离：结合后端 API 开发完整的前后端分离应用
5. 学习 Next.js：React 的服务端渲染框架，是 React 生态的重要组成部分

### 项目推荐

**纯 React 练手项目：**
- 待办事项（TodoList）
- 天气查询
- Hacker News 克隆
- 计算器
- 后台管理系统
- 博客系统
- 电商网站
- 社交平台

**进阶方向：**
- React + Next.js 服务端渲染：学习 SSR、多级缓存、Elasticsearch 搜索、权限控制、流控
- React 跨端小程序：学习分库分表、分布式锁、SSE 实时推送
- React + Spring Boot 全栈：学习模板引擎、对象存储、性能优化

## 阶段 7：求职备战（面试前 1 个月突击）

### 学习目标

熟练掌握 React 常见面试题，准备好简历和项目经历，顺利通过面试。

### 学习建议

1. 简历上要有 1-2 个完整的 React 项目（想增强前端竞争力，最好同时有 Vue 项目）
2. 多刷面试题：基础概念、Hooks、虚拟 DOM、性能优化、状态管理等
3. 理解原理：虚拟 DOM 的 Diff 算法、Hooks 的实现原理、Fiber 架构等，面试不仅要会用还要懂原理
4. 对比 React 和 Vue：能说出各自的优势和适用场景

### 经典面试题

**基础概念：**
1. React 有什么特点？
2. 什么是虚拟 DOM？有什么作用？
3. 什么是 JSX？
4. React 的单向数据流是什么？

**组件：**
1. 函数组件和类组件有什么区别？
2. Props 是什么？如何使用？
3. 受控组件和非受控组件有什么区别？

**Hooks：**
1. 什么是 Hooks？为什么要使用 Hooks？
2. useState 和 useEffect 如何使用？
3. useEffect 的依赖数组有什么作用？
4. useMemo 和 useCallback 有什么区别？
5. 如何自定义 Hooks？

**性能优化：**
1. React 如何进行性能优化？
2. 什么是 React.memo？
3. 虚拟 DOM 的 Diff 算法是怎样的？

**状态管理：**
1. Context API 如何使用？
2. Redux 的工作原理是什么？

## 拓展资源

### React 专题资源

- [React GitHub](https://github.com/facebook/react)：React 源码
- [awesome-react](https://github.com/enaqx/awesome-react)：React 资源大全
- [React Status](https://react.statuscode.com/)：React 周刊（英文）

### 技术博客

- [React 官方博客](https://react.dev/blog)
- [Meta Engineering](https://engineering.fb.com/)：Meta 工程技术博客
- [腾讯 AlloyTeam](http://www.alloyteam.com/)：腾讯全端团队博客
- [淘宝前端团队 FED](https://fed.taobao.org/)：阿里淘宝前端团队

## 学习方向

学完 React 后，可从事以下岗位：

1. **前端开发工程师** — 使用 React 开发 Web 应用
2. **全栈工程师** — React 前端 + Node.js/Java 后端
3. **移动端开发工程师** — 使用 React Native 开发移动应用
4. **桌面应用开发工程师** — 使用 Electron + React 开发桌面应用

> 来源：鱼皮·编程导航 / codefather
