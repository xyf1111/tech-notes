---
title: "移动端 - Kotlin 学习路线"
date: 2026-07-25
tags: [Kotlin, Android, 移动开发, 学习路线]
source: "鱼皮·编程导航 / codefather"
---

# 移动端 - Kotlin 学习路线

> Kotlin 是 JetBrains 开发的一门现代编程语言，2017 年被 Google 宣布为 Android 开发的官方首选语言。可运行在 JVM 上，与 Java 100% 互操作，代码量减少 40% 以上，避免空指针异常等问题。

## 学习前提

- **Java 基础**：有 Java 基础学 Kotlin 更快（推荐）
- **面向对象编程**：理解类、对象、继承、多态
- **Android 开发基础**：可选，目标 Android 开发需补充

## 学习路线图

![](../../image/img_kotlin_roadmap.png)

## 就业方向

| 岗位 | 说明 |
|------|------|
| Android 开发工程师 | 使用 Kotlin 开发 Android 应用 |
| Kotlin 后端开发工程师 | 用 Kotlin + Spring Boot 开发后端（较少） |
| 移动端开发工程师 | Android + iOS 全栈 |
| 跨平台开发工程师 | 使用 Kotlin Multiplatform（较少） |

## 阶段 1：Kotlin 基础语法（7-20 天）

**基础语法 [必学]：**
- 变量和常量（var、val）、基本数据类型、运算符、控制流（if、when、for、while）
- **空安全（Nullable Types）**[重点] — 可空类型 `String?` 和非空类型 `String` 的区别
- 安全调用 `?.`、Elvis 操作符 `?:`、非空断言 `!!`
- 字符串模板

**函数 [必学]：**
- 函数定义、默认参数和命名参数
- **扩展函数**[重点] — 为已有类添加新方法而不修改原类
- 高阶函数和 Lambda 表达式

**集合 [必学]：**
- List、Set、Map、可变/不可变集合
- 集合操作函数（map、filter、reduce 等）

## 阶段 2：面向对象编程（10-15 天）

**类和对象 [必学]：**
- 类定义、构造函数（主/次构造函数）、属性、方法、访问修饰符

**继承和多态 [必学]：**
- `open` / `override`、抽象类、接口、多态

**数据类 [必学，特色]：**
- `data class` — 自动生成 equals、hashCode、toString、copy

**密封类 [建议学]：**
- `sealed class` — 表示有限的几种状态或结果

**对象和伴生对象 [必学]：**
- `object`（单例）、`companion object`（类似 Java 静态成员）

## 阶段 3：Kotlin 高级特性（10-20 天）

**泛型 [建议学]：**
- 泛型类/函数、约束、协变/逆变

**委托 [建议学]：**
- 类委托、属性委托（`by lazy`、`by observable`）

**协程 [必学，重点]：**
- 协程概念、启动协程（launch、async）、协程作用域（CoroutineScope）
- 挂起函数（suspend）、调度器（Dispatchers.Main/IO/Default）
- **Flow**：响应式流
- 比传统线程更轻量、更易用

**作用域函数 [建议学]：**
- `let`、`run`、`with`、`apply`、`also`

## 阶段 4：Android 开发（可选）

目标 Android 开发则继续学习 Android 开发体系（Jetpack Compose 等）。

## 阶段 5：求职备战

**准备项目**：简历上要有 Kotlin 项目经历，能讲解协程、扩展函数、数据类等特性使用。

**经典面试题：**
- Kotlin 与 Java 的区别、空安全实现
- 数据类、协程与线程区别
- 作用域函数区别、委托
- Android：为什么 Google 推荐 Kotlin、协程在 Android 中的使用

> 来源：鱼皮·编程导航 / codefather
