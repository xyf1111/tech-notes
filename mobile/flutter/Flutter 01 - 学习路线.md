---
title: "Flutter 学习路线"
date: 2026-07-19
tags: [flutter, dart, mobile, learning]
source: "鱼皮·编程导航 / codefather"
---

# Flutter 学习路线

> Google 跨平台移动应用开发框架学习路径：一套代码同时开发 iOS、Android、Web、桌面应用。

![](../image/img_flutter_roadmap.png)

## 概述

Flutter 是 Google 推出的开源跨平台移动应用开发框架，使用 Dart 语言编写，通过一套代码可同时运行在 iOS、Android、Web、Windows、macOS、Linux 上。核心特点是高性能（使用 Skia 渲染引擎）、美观的 UI 和热重载（Hot Reload）。

### Flutter vs 原生开发

| 维度 | Flutter | 原生开发 |
|------|---------|---------|
| 多端支持 | 一套代码多端运行 | 需维护两套代码 |
| 性能 | 接近原生 | 最好 |
| 开发体验 | 热重载，效率高 | 编译慢 |
| UI 一致性 | 跨平台一致 | 平台原生风格 |
| 生态 | 相对较新 | 成熟丰富 |
| 岗位 | 相对较少（增长中） | 多 |

### 学习前提
- 至少一门编程语言基础（Java/JS/Python）
- 面向对象编程概念
- 移动端基础知识（建议）

### 就业方向
| 岗位 | 说明 |
|------|------|
| Flutter 开发工程师 | 跨平台移动应用开发 |
| 移动端开发工程师 | 同时负责 iOS 和 Android |
| 跨平台开发工程师 | 多平台应用开发 |

## 整体学习建议

1. **先学 Dart 再学 Flutter** — Dart 语法与 Java/JavaScript 相似
2. **官方文档质量高**，优先查阅
3. **结合项目实践**，每学完一个知识点动手实现小功能
4. **充分利用热重载**提高开发效率

## 阶段 1：Dart 语言（10-20 天）

Dart 是 Google 开发的现代编程语言，支持面向对象和函数式编程，提供空安全特性。

### 知识点
**基础语法【必学】：** 变量（var/final/const）、数据类型（int/double/String/bool/List/Map）、运算符、控制流、函数、**空安全（Null Safety）**

**面向对象【必学】：** 类和对象、构造函数、继承和 Mixin、抽象类和接口、泛型

**异步编程【必学】：** Future 和 async/await、Stream

**集合【必学】：** List/Set/Map、集合操作（map/where/reduce）

### 学习资源
- [Dart 官方文档](https://dart.cn/)
- [2025 Dart Flutter 入门教程](https://www.bilibili.com/video/BV15P411P7DN/)
- [DartPad](https://dartpad.dev/) — 在线编辑器

## 阶段 2：Flutter 基础（10-20 天）

### 知识点
**基础概念【必学】：** Widget 树、StatelessWidget 与 StatefulWidget

**环境搭建【必学】：** Flutter SDK 安装、Android Studio/VS Code 配置、模拟器和真机调试

**基础组件【必学】：** Text/Image/Icon、Container/Padding/Center、Row/Column/Stack、ListView/GridView、各类 Button

**布局【必学】：** Flex 布局、Expanded/Flexible、Align/Positioned

**路由导航【必学】：** Navigator、push/pop、路由传参

### 学习资源
- [Flutter 官方文档](https://docs.flutter.cn/)
- [黑马程序员 Flutter 教程](https://www.bilibili.com/video/BV1wR4Xz6EqG)

## 阶段 3：状态管理（7-15 天）

### 知识点
**setState【必学】：** StatefulWidget 状态管理

**Provider【推荐】：** ChangeNotifier、Consumer

**其他方案【建议学】：** Riverpod（Provider 升级版）、GetX（功能全面）、Bloc（基于 Stream）

### 学习资源
- [Provider 官方文档](https://pub.dev/packages/provider)
- [Riverpod 官方文档](https://riverpod.dev/)
- [GetX 官方文档](https://pub.dev/packages/get)

## 阶段 4：网络和数据（5-15 天）

### 知识点
**网络请求【必学】：** http 库、dio 库（推荐）、JSON 解析、请求封装

**数据存储【必学】：** shared_preferences（轻量）、sqflite（SQLite）、hive（NoSQL，推荐）

**第三方库【建议】：** cached_network_image、pull_to_refresh、webview_flutter

## 阶段 5：项目实战（30-50 天）

### 项目推荐
**入门级：** 计算器、待办事项、笔记应用、天气查询

**进阶级：** 新闻资讯 App、音乐播放器、电商 App、社交 App

**优质开源项目：**
- [Flutter Samples](https://github.com/flutter/samples) — 官方示例集合（19k+ stars）
- [GSY Flutter 开源项目](https://github.com/CarGuo/gsy_flutter_book)
- [awesome-flutter](https://github.com/Solido/awesome-flutter) — 资源大全
- [Flutter 完整开发实战](https://guoshuyu.cn/home/wx/Flutter-1.html)

## 阶段 6：求职备战（面试前 1 个月）

### 经典面试题
**Dart 语言：** 空安全、Future vs Stream

**Flutter 基础：** Widget/Element/RenderObject 关系、StatelessWidget vs StatefulWidget、渲染原理

**状态管理：** Provider 使用、setState vs Provider

**性能优化：** 避免不必要的 rebuild、const 构造函数作用

### 面试题库
- [Flutter 面试题](https://www.mianshiya.com/bank/1991431522212642817)
- [Dart 面试题](https://www.mianshiya.com/bank/1991431803600109569)

> 来源：鱼皮·编程导航 / codefather
