---
title: "Java 02 - JDK JRE JVM"
date: 2021-02-09
tags: [java, 基础]
aliases:
  - "JDK JRE JVM"
---

# Java 02 - JDK JRE JVM

## 三者关系

```
JDK  >  JRE  >  JVM
(开发工具包) (运行环境) (虚拟机)
```

| 组件 | 全称 | 包含内容 | 用途 |
|------|------|----------|------|
| **JDK** | Java Development Kit | JRE + 开发工具（javac/jar/javadoc等） | 开发 Java 程序 |
| **JRE** | Java Runtime Environment | JVM + 核心类库 | 运行 Java 程序 |
| **JVM** | Java Virtual Machine | 字节码解释器 | 执行字节码 |

## JDK 包含的关键工具

- `javac` — Java 编译器（`.java` → `.class`）
- `java` — Java 程序启动器
- `jar` — 打包工具
- `javadoc` — 文档生成器
- `jdb` — 调试器
- `jstack` — 线程堆栈分析
- `jmap` — 内存映像分析
- `jstat` — JVM 统计监控

## JVM 架构组成

1. **类加载子系统** — 加载、链接、初始化类
2. **运行时数据区** — 堆、栈、方法区、程序计数器、本地方法栈
3. **执行引擎** — 解释器、JIT 编译器、垃圾回收器
4. **本地方法接口** — JNI 调用 C/C++ 代码

> JVM 是 Java 跨平台的核心保障，不同操作系统有各自的 JVM 实现，但字节码标准是统一的。
