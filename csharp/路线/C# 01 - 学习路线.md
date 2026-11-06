---
title: "C# 学习路线"
date: 2026-07-18
tags:
  - learning
  - csharp
  - dotnet
  - roadmap
source: "鱼皮·编程导航 / codefather"
---

# C# 学习路线

> C# 是微软开发的现代面向对象编程语言，语法简洁优雅，适用于游戏开发（Unity）、Web 开发（ASP.NET Core）、桌面应用（WPF/MAUI）等多种场景。

## 就业方向

| 方向 | 说明 |
|------|------|
| Unity 游戏开发 | 使用 C# 开发 Unity 游戏 |
| .NET 后端开发 | 使用 ASP.NET Core 开发 Web 应用和 API |
| 桌面应用开发 | 使用 WPF 或 WinForms 开发 Windows 桌面应用 |
| 跨平台移动开发 | 使用 .NET MAUI |
| 全栈开发 | ASP.NET Core 后端 + 前端框架 |

## 学习路径

| 阶段 | 内容 | 建议时长 |
|------|------|---------|
| 阶段 1 | C# 基础语法 | 10-20 天 |
| 阶段 2 | 面向对象编程 | 10-20 天 |
| 阶段 3 | C# 高级特性 | 15-20 天 |
| 阶段 4 | .NET 框架和应用开发 | 15-30 天 |
| 阶段 5 | 项目实战 | 20-30 天 |
| 阶段 6 | 求职备战 | 面试前 1 个月 |

### 阶段 1：C# 基础语法

**必学知识点：**
- 变量、数据类型、运算符、控制流（if/switch/for/foreach）
- 方法定义、重载、ref/out 参数
- 字符串操作、字符串插值 `$""`、StringBuilder
- 异常处理（try-catch-finally、自定义异常）
- 数组和集合

**开发工具推荐：** Visual Studio（Windows）或 VS Code + .NET SDK

### 阶段 2：面向对象编程

**必学知识点：**
- 类与对象、字段/属性/方法、构造/析构函数
- 封装、继承、多态（virtual/override、abstract、interface）
- 自动属性、只读属性、索引器
- 委托（Delegate）、事件（Event）、Lambda 表达式

**C# 特色：** 属性（Property）比 Java 的 getter/setter 更简洁；接口支持多实现；委托和事件实现回调和观察者模式

### 阶段 3：C# 高级特性

**必学知识点：**
- **泛型**：泛型类/方法、约束、泛型集合（List\<T\>、Dictionary\<TKey, TValue\>）
- **LINQ**：查询语法、方法语法、常用操作（Where/Select/OrderBy/GroupBy）
- **异步编程**：async/await、Task\<T\>、异步方法编写
- **空值处理**：Nullable\<T\>、?? 运算符、?. 运算符
- C# 9-12 新特性：record 类型、模式匹配、主构造函数

### 阶段 4：.NET 框架

**根据方向选择学习：**

**ASP.NET Core（Web 开发）：**
- MVC 模式、路由和控制器、Razor 页面
- Web API 开发、Entity Framework Core（ORM）

**WPF（桌面应用）：**
- XAML 语法、数据绑定、MVVM 模式

**Unity 游戏开发：**
- C# 脚本、MonoBehaviour 生命周期

### 阶段 5：项目实战

**入门项目：** 计算器、学生管理系统、文件管理工具

**Web 项目：** 博客系统、任务管理系统、电商网站

**桌面项目：** 笔记应用、图片浏览器、音乐播放器

**开源资源：** awesome-dotnet（GitHub 20k+ stars）

### 阶段 6：求职备战

**经典面试题：**
1. C# 和 Java 有什么区别？
2. ref 和 out 有什么区别？
3. 抽象类和接口有什么区别？
4. 什么是委托？什么是事件？
5. 什么是 LINQ？
6. async/await 的工作原理？
7. 值类型和引用类型的区别？
8. string 和 StringBuilder 的区别？
9. C# 垃圾回收机制？

> 来源：鱼皮·编程导航 / codefather
