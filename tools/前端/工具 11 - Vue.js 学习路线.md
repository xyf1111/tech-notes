---
title: "工具 11 - Vue.js 学习路线"
date: 2026-08-07
tags:
  - Vue
  - 前端
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# Vue.js 学习路线

> Vue.js 是一款渐进式 JavaScript 前端框架，由尤雨溪于 2014 年创建。核心特点是响应式数据绑定和组件化开发，语法简洁直观，学习成本低、开发效率高，是国内最流行的前端框架之一，招聘需求甚至超过 React，被大量中小型公司和创业公司采用。核心概念包括 MVVM 模式、响应式数据绑定和虚拟 DOM。
>
> Vue 3 是当前主流版本，采用 Composition API、更好的 TypeScript 支持等新特性。2025 年以来几乎所有新项目都使用 Vue 3，建议直接学习 Vue 3，不要在 Vue 2 上花时间。生态配套成熟：Vite 构建工具、Pinia 状态管理、Vue Router 路由，配合 Element Plus（桌面端）、Vant（移动端）等 UI 组件库可快速搭建应用，还能通过 uni-app 开发小程序和跨端应用。

## 整体学习建议

1. **直接学 Vue 3** — Vue 3 是 Vue 的未来，几乎所有新项目都在使用，不要花时间学 Vue 2
2. **重点掌握 Composition API** — 这是 Vue 3 的核心特性，代码组织更灵活、逻辑复用更简单；虽然 Vue 3 仍支持 Options API，但 Composition API 是推荐写法
3. **结合项目实践，边学边做** — 每学完一个知识点就动手实现一个小功能，如待办事项、计数器等
4. **官方文档是最好的老师** — Vue 官方文档写得非常好，中文文档质量也很高，遇到问题优先查阅官方文档，也可以借助 AI 辅助解决
5. **独立解决问题** — 学习阶段尽量自己动手排查问题，印象更深刻

### 学习前提

1. HTML 和 CSS：网页的基础
2. JavaScript 基础：变量、函数、对象、数组等
3. ES6+ 语法：箭头函数、Promise、async/await、解构等【重点】

### 就业方向

学完 Vue 后，主要从事前端相关岗位：

1. **前端开发工程师** — 使用 Vue 开发 Web 应用
2. **全栈工程师** — Vue 前端 + Node.js/Java 后端
3. **小程序开发工程师** — 使用 uni-app（基于 Vue）开发小程序
4. **跨平台开发工程师** — 使用 uni-app 开发 iOS、Android、小程序

## 阶段 1：Vue 3 基础（7-20 天）

### 学习目标

掌握 Vue 3 的基础知识，能够使用 Vue 开发简单的应用。

### 知识点

**Vue 基础概念【必学】：**
- Vue 的特点和优势
- MVVM 模式
- 响应式数据绑定
- 虚拟 DOM

**项目创建【必学】：**
- Vite 脚手架（推荐）
- Vue CLI（传统方式）
- 项目结构

**模板语法【必学】：**
- 插值语法（`{{ }}`）
- 指令（v-bind、v-on、v-if、v-for、v-show、v-model）
- 缩写（`:` 和 `@`）
- 条件渲染和列表渲染

**计算属性和侦听器【必学】：**
- computed：计算属性
- watch：侦听器
- watchEffect

**生命周期【必学】：**
- Vue 3 的生命周期钩子
- onMounted、onUpdated、onUnmounted 等

### 学习建议

1. Vite 是 Vue 官方推荐的新一代构建工具，启动速度快、热更新快，建议使用 Vite 创建 Vue 项目，官方文档中有快速上手指南
2. v-model 是 Vue 的双向绑定指令，可以方便地实现表单输入的数据绑定，本质是 `:value` 和 `@input` 的语法糖
3. computed 基于响应式依赖进行缓存，只有依赖变化时才重新计算；watch 用于监听数据变化并执行副作用
4. 多练习：尝试用 Vue 实现待办事项、计数器、表单验证等简单功能

### 学习资源

- [Vue 3 官方文档](https://cn.vuejs.org/)：最权威的学习资料
- [2024 Vue 3 极简教程](https://www.bilibili.com/video/BV1sm411m7Px/)（B站）：1 小时快速学会
- [Vue 3 快速入门教程](https://www.bilibili.com/video/BV1cQzuYqEkN/)（B站）：完整教程

## 阶段 2：组件开发（7-15 天）

组件开发是 Vue.js 的核心思想，通过组件化可以构建可复用、可维护的前端应用。

### 学习目标

掌握 Vue 的组件化开发，能够开发可复用的组件。

### 知识点

**组件基础【必学】：**
- 组件的定义和注册
- 全局组件和局部组件
- 单文件组件（.vue 文件）
- 组件的生命周期

**组件通信【必学，面试重点】：**
- Props：父传子
- Emits：子传父
- Provide/Inject：跨层级传递
- v-model：双向绑定
- Ref：父组件调用子组件方法

**插槽【必学】：**
- 默认插槽
- 具名插槽
- 作用域插槽

**动态组件【建议学】：**
- component `:is`
- keep-alive：缓存组件

### 学习建议

1. 组件化是 Vue 的核心思想，要理解组件的复用性和独立性；一个好的组件应该高内聚、低耦合
2. 组件通信是 Vue 开发的重点，也是面试高频考点，要熟练掌握各种通信方式并理解各自适用场景
3. 插槽（slot）让组件更灵活，可以在使用组件时自定义部分内容；作用域插槽可以让父组件访问子组件的数据
4. 多写组件，尝试封装按钮、输入框、对话框等常用组件

### 学习资源

- [Vue 组件官方文档](https://cn.vuejs.org/guide/essentials/component-basics.html)

## 阶段 3：Composition API（7-15 天）

Composition API 是 Vue 3 的核心特性，是推荐的编程方式。

### 学习目标

掌握 Composition API，能够使用 `<script setup>` 语法编写组件。

### 知识点

**响应式 API【必学】：**
- ref：基本类型的响应式
- reactive：对象的响应式
- toRef 和 toRefs
- computed：计算属性
- watch 和 watchEffect：侦听器

**生命周期钩子【必学】：**
- onMounted、onUpdated、onUnmounted 等

**依赖注入【必学】：**
- provide 和 inject

**组合式函数（Composables）【建议学】：**
- 自定义组合式函数
- 逻辑复用

**`<script setup>` 语法【必学】：**
- setup 的使用
- defineProps 和 defineEmits
- defineExpose

### 学习建议

1. ref 和 reactive 是 Vue 3 响应式系统的核心：ref 适合基本类型，reactive 适合对象；模板中使用 ref 时会自动解包，不需要写 `.value`
2. Composition API 相比 Options API 的优势是逻辑组织更灵活、逻辑复用更简单、TypeScript 支持更好，建议优先学习
3. `<script setup>` 是 Vue 3.2+ 引入的语法糖，可以让代码更简洁，建议用它编写组件
4. 组合式函数（Composables）是逻辑复用的最佳实践，可将可复用逻辑抽取成独立函数，类似于 React 的自定义 Hooks

### 学习资源

- [Vue 3 Composition API 官方文档](https://cn.vuejs.org/guide/extras/composition-api-faq.html)

## 阶段 4：Vue Router（3-7 天）

Vue Router 是 Vue 的官方路由管理器，用于构建单页面应用（SPA）。

### 学习目标

掌握 Vue Router，能够实现页面路由和导航。

### 知识点

**路由基础【必学】：**
- 路由的概念和作用
- 安装和配置 Vue Router
- 路由的定义和注册
- router-link 和 router-view
- 编程式导航（push、replace、go）

**动态路由【必学】：**
- 路由参数（params）
- 查询参数（query）
- 路由传参

**嵌套路由【必学】：**
- 子路由的配置
- 多层嵌套

**路由守卫【必学】：**
- 全局守卫（beforeEach、afterEach）
- 路由独享守卫（beforeEnter）
- 组件内守卫（beforeRouteEnter、beforeRouteUpdate、beforeRouteLeave）

**懒加载【建议学】：**
- 路由懒加载
- 代码分割

### 学习建议

1. Vue Router 是构建 SPA 的必备工具，要理解单页面应用的概念和路由的作用
2. 路由守卫可以实现权限控制、登录验证等功能，是 Vue Router 的重要特性
3. 路由懒加载可以按需加载组件，减少首屏加载时间，提升性能

### 学习资源

- [Vue Router 官方文档](https://router.vuejs.org/zh/)

## 阶段 5：Pinia 状态管理（3-7 天）

状态管理用于管理多个组件或页面共享的状态，比如用户信息、购物车、主题设置等。对于小型应用可以不使用状态管理，对于大型应用则是必须的。

Pinia 是 Vue 3 推荐的状态管理库，比 Vuex 更简洁、更符合 Composition API 的风格，API 简洁、学习成本很低，建议直接学习 Pinia 而不是 Vuex。

### 学习目标

掌握 Pinia，能够管理应用的全局状态。

### 知识点

**状态管理基础【必学】：**
- 状态管理的概念和作用
- Pinia 的安装和配置
- Store 的定义

**Store 的使用【必学】：**
- State：状态
- Getters：计算属性
- Actions：方法
- 在组件中使用 Store

**Store 的组合【建议学】：**
- 多个 Store 的使用
- Store 之间的通信

### 学习资源

- [Pinia 官方文档](https://pinia.vuejs.org/zh/)

## 阶段 6：项目实战（30-45 天）

### 学习目标

通过实际项目巩固所学知识，积累项目经验。

### 学习建议

1. 从简单项目开始：先开发待办事项、天气查询、音乐播放器等简单项目
2. 使用 UI 组件库：推荐 Element Plus（桌面端）、Vant（移动端）等，快速搭建界面
3. 完整技术栈：Vue 3 + Vite + Vue Router + Pinia + Element Plus + Axios
4. 前后端分离：结合后端 API（Mock 数据或真实 API）开发完整的前后端分离应用，可通过[这个视频](https://www.bilibili.com/video/BV1AasqzWEj5)（B站）快速了解什么是前后端分离
5. 部署上线：完成项目后部署到服务器（如 Vercel、Netlify、阿里云），体验完整上线流程

### 项目推荐

**入门级项目：**
- 待办事项（TodoList）
- 笔记应用
- 天气查询
- 音乐播放器

**进阶级项目：**
- 后台管理系统
- 电商网站
- 博客系统
- 社交平台

## 阶段 7：求职备战（面试前 1 个月突击）

### 学习目标

熟练掌握 Vue 常见面试题，准备好简历和项目经历，顺利通过面试。

### 学习建议

1. 准备项目：简历上要有 1-2 个完整的 Vue 前端项目，包括项目介绍、技术栈、实现的功能、技术难点等，最好提供在线演示链接或 GitHub 地址
2. 多刷面试题：Vue 的面试题主要包括基础概念、组件通信、响应式原理、Composition API、Vue Router、Pinia 等
3. 理解原理：不仅要会用 Vue，还要对原理有一定了解，如响应式系统的实现原理、虚拟 DOM 的 Diff 算法、Composition API 的优势等
4. 面试时可能会被问到 Vue 和 React 的区别，要能说出各自的优势和适用场景

### 经典面试题

**基础概念：**
1. Vue 有什么特点？
2. MVVM 模式是什么？
3. Vue 的响应式原理是什么？
4. 虚拟 DOM 是什么？有什么作用？

**组件：**
1. Vue 的组件通信方式有哪些？
2. Props 和 Emits 如何使用？
3. 插槽（Slot）是什么？有哪些类型？
4. keep-alive 有什么作用？

**Composition API：**
1. Composition API 和 Options API 有什么区别？
2. ref 和 reactive 有什么区别？
3. computed 和 watch 有什么区别？
4. setup 函数有什么作用？

**Vue Router：**
1. Vue Router 的路由模式有哪些？
2. 路由守卫有哪些？如何使用？
3. 如何实现路由懒加载？

**Pinia：**
1. Pinia 和 Vuex 有什么区别？
2. Pinia 如何使用？

## 拓展资源

### Vue 专题资源

- [Vue.js 官方博客](https://blog.vuejs.org/)：Vue 官方博客
- [Vue.js GitHub](https://github.com/vuejs/core)：Vue 3 源码
- [awesome-vue](https://github.com/vuejs/awesome-vue)：Vue 资源大全

### 技术博客

- [Vue.js 官方博客](https://blog.vuejs.org/)：Vue.js 官方技术博客
- [腾讯 AlloyTeam](http://www.alloyteam.com/)：腾讯全端团队博客
- [淘宝前端团队 FED](https://fed.taobao.org/)：阿里淘宝前端团队
- [京东凹凸实验室](https://aotu.io/)：京东前端技术分享

## 写在最后

学习 Vue 建议直接从 Vue 3 开始，重点掌握 Composition API 和 `<script setup>` 语法。虽然 Vue 2 仍有很多项目在使用，但 Vue 3 已经是主流，掌握 Vue 3 能让你在求职时更有竞争力。

在 AI 时代，Vue 依然是开发 AI 应用前端界面的主流选择，结合 AI 网关、大模型 API 可以快速构建智能 Web 应用。

> 来源：鱼皮·编程导航 / codefather
