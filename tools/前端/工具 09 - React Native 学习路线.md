---
title: "工具 09 - React Native 学习路线"
date: 2026-08-04
tags:
  - React Native
  - 移动端
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# 工具 09 - React Native 学习路线

> React Native 是 Facebook 于 2015 年开源的跨平台移动应用开发框架，可以使用 JavaScript 和 React 开发原生 iOS 和 Android 应用。它不是在 WebView 中运行网页，而是将 React 组件渲染为真正的原生组件，性能和用户体验接近原生应用。被 Facebook、Instagram、Discord、Shopify、Microsoft 等知名公司使用。

React Native 的核心特性：使用 React 语法开发、组件渲染为原生组件、热重载（Fast Refresh）、跨平台（一套代码两个平台）、JavaScript 与原生代码互操作、丰富的第三方库。Expo 是 React Native 的开发工具和服务平台，提供大量开箱即用的功能。React Native 与 Flutter 是跨平台开发的两大主流框架：RN 优势是技术栈与 Web 一致、生态丰富；Flutter 优势是性能更好、UI 一致性更高，可依据项目需求选择。

## 整体学习建议

1. **先学 React** — React Native 基于 React，先熟练掌握组件、Hooks、状态管理等基础，再学 React Native
2. **用 Expo 入门** — Expo 提供开箱即用的功能（相机、位置、推送通知等），简化开发环境配置，建议初学者使用
3. **真机调试** — 在真机上调试，真机的性能和行为可能与模拟器不同
4. **理解与 React Web 的差异** — RN 使用 View、Text 组件而非 div、span；使用 StyleSheet 而非 CSS 文件
5. **多动手写项目** — 学习过程中多做实战练习，积累移动端开发经验

### 学习前提

1. React 基础：熟练使用 React、Hooks、组件等【必学】
2. JavaScript/TypeScript：熟练使用 ES6+ 语法【必学】
3. 移动端开发基础：了解移动端开发的基本概念【建议】

### 就业方向

1. React Native 工程师：专注于跨平台移动开发
2. 移动端开发工程师：开发 iOS 和 Android 应用
3. 全栈工程师：React Native 移动端 + Web 前端/后端
4. 前端工程师：同时负责 Web 和移动端开发

## 阶段 1：React Native 基础（10-20 天）

### 学习目标

理解 React Native 的核心概念，掌握基本的组件和 API。

### 知识点

**React Native 简介【必学】**

- React Native 的特点和优势
- React Native 和 React Web 的区别
- React Native 和 Flutter 的对比【简单了解】

**开发环境【必学】**

- Expo 开发环境（推荐新手）
- React Native CLI 开发环境
- 模拟器和真机调试

**核心组件【必学】**

- View、Text、Image
- ScrollView、FlatList
- Button、TouchableOpacity
- TextInput

**样式【必学】**

- StyleSheet
- Flexbox 布局
- 平台特定样式

### 学习重点

- Expo 开箱即用，新手无需配置复杂的原生环境
- StyleSheet 语法类似 CSS 但有差异，使用 Flexbox 布局，默认 `flexDirection: 'column'`
- FlatList 是高性能列表组件，支持虚拟列表、下拉刷新、上拉加载，需熟练掌握
- RN 组件是平台特定的原生组件：View 对应 iOS 的 UIView、Android 的 `android.view`

### 学习资源

- [React Native 官方文档](https://reactnative.dev/)：最权威的学习资料
- [Expo 官方文档](https://docs.expo.dev/)：Expo 文档
- [React Native 入门到实战](https://www.bilibili.com/video/BV1Pt4y1n7bD)（B站）
- [React Native + Expo 实战教程](https://www.bilibili.com/video/BV1U66bYzEyL/)（B站）：快速上手

## 阶段 2：导航和路由（3-15 天）

### 学习目标

导航和路由是移动应用的核心功能，要熟练掌握各种导航模式，能够实现多页面应用。

### 知识点

**React Navigation【必学】**

- Stack Navigator（堆栈导航）
- Tab Navigator（标签导航）
- Drawer Navigator（抽屉导航）
- 导航参数传递
- 导航生命周期

**Expo Router【建议学，Expo 推荐】**

- 文件系统路由
- 动态路由
- 布局（Layout）

### 学习建议

- React Navigation 是 React Native 最流行的导航库：Stack Navigator 用于页面堆栈，Tab Navigator 用于底部标签栏
- Expo Router 基于文件系统路由，类似 Next.js，使用 Expo 建议学习

### 学习资源

- [React Navigation 官方文档](https://reactnavigation.org/)
- [Expo Router 官方文档](https://docs.expo.dev/router/introduction/)

## 阶段 3：原生模块和 API（7-20 天）

> 原生模块可以调用原生代码，实现 React Native 不支持的功能。编写原生模块需要 Objective-C/Swift（iOS）或 Java/Kotlin（Android）知识。

### 学习目标

掌握 React Native 的原生能力，能够调用设备功能。

### 知识点

**常用 API【必学】**

- AsyncStorage（本地存储）
- Camera（相机）
- Location（定位）
- Notifications（推送通知）

**第三方库【建议学】**

- React Native Vector Icons（图标）
- React Native Maps（地图）
- React Native WebView

**原生模块【建议学】**

- 调用原生代码
- 编写原生模块【可不学】

### 学习建议

- Expo 提供大量开箱即用的 API（相机、位置、推送通知等），无需额外安装库
- 使用 React Native CLI 需自行安装第三方库，注意库的维护状态和兼容性

### 学习资源

- [Expo SDK 文档](https://docs.expo.dev/versions/latest/)：Expo API 文档

## 阶段 4：项目实战（30-45 天）

### 学习目标

通过实际项目巩固所学知识，积累 React Native 项目经验。

### 学习建议

1. 从简单项目开始：待办事项、天气查询等，熟悉 React Native 的完整开发流程
2. 使用 Expo：提供大量模板项目，用 `npx create-expo-app` 创建项目
3. 发布应用：发布到 App Store 和 Google Play，体验完整发布流程；Expo 提供 EAS Build 和 EAS Submit 简化发布
4. 性能优化：关注列表渲染、图片加载等性能问题

### 项目推荐

**入门级项目：** 待办事项、天气查询、新闻资讯、笔记应用

**进阶级项目：** 电商 App、社交 App、音乐播放器、健身 App

**优质开源项目：**

- [Best of React Native](https://github.com/fkromer/best-of-react-native)（GitHub）：精选优质 React Native 项目
- [React Native Community](https://github.com/react-native-community)（GitHub）：社区维护的优质组件和项目
- [Expo Examples](https://github.com/expo/examples)（GitHub）：Expo 官方示例项目集合

### 学习资源

- [2025 React Native + Expo 实战教程](https://www.bilibili.com/video/BV1U66bYzEyL/)（B站）：完整项目
- [React Native 项目实战](https://www.bilibili.com/video/BV1gSGFzAEUN/)（B站）
- [React Native 指南](https://github.com/reactnativecn/react-native-guide)（GitHub）：学习资源汇总

## 阶段 5：求职备战

### 学习目标

熟练掌握 React Native 常见面试题，准备好简历和项目经历，顺利通过面试。

### 学习建议

1. **准备项目** — 简历上一定要有 React Native 项目，最好能发布到应用商店，对移动端求职非常加分。现在 AI 生成代码的能力很强，开发 APP 的成本越来越低（参考：[用 AI 开发 APP 视频教程](https://www.bilibili.com/video/BV17HMcziEye/)）
2. **刷面试题** — 面试题主要包括 React 基础、RN 组件、性能优化、与原生开发的差异等
3. **对比其他方案** — 面试可能被问 React Native 与 Flutter、原生开发的对比，要能说出 React Native 的优势和劣势

### 经典面试题

**基础概念**

1. React Native 是什么？有什么特点？
2. React Native 和 React Web 有什么区别？
3. React Native 和 Flutter 有什么区别？
4. React Native 的工作原理是什么？

**组件和样式**

1. React Native 的核心组件有哪些？
2. React Native 的样式和 CSS 有什么区别？
3. 如何实现响应式布局？
4. FlatList 和 ScrollView 有什么区别？

**性能优化**

1. 如何优化 React Native 应用的性能？
2. 如何优化列表渲染？
3. 如何减少应用体积？

**其他**

1. 什么是 Expo？有什么优势？
2. 如何调试 React Native 应用？
3. 如何发布 React Native 应用？

## 拓展资源

### React Native 资源

- [React Native 官网](https://reactnative.dev/)：官方网站
- [Expo 官网](https://expo.dev/)：Expo 平台
- [React Native 中文网](https://reactnative.cn/)：中文社区
- [awesome-react-native](https://github.com/jondot/awesome-react-native)（GitHub）：资源大全

### 技术博客

- [React Native 官方博客](https://reactnative.dev/blog)：官方博客
- [Meta Engineering](https://engineering.fb.com/)：Meta 移动开发实践
- [Airbnb Tech Blog](https://medium.com/airbnb-engineering)：Airbnb RN 经验分享

## 最后

React Native 是跨平台移动开发的主流选择，结合了跨平台开发的高效率和原生应用的好性能。学习时先打好 React 基础，理解组件、Hooks、状态管理等核心概念，再学习 React Native 特性及与 React Web 的差异；多做实战项目并在真机上测试，积累移动端开发经验。

React Native 与 Flutter 各有优劣：团队已使用 React 则 React Native 是自然选择；追求更好的性能和 UI 一致性，Flutter 也是不错的选择。

> 来源：鱼皮·编程导航 / codefather
