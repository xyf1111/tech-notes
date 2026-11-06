---
title: "Java 18 - 类加载机制"
date: 2026-06-11
tags: [java, JVM]
---

# Java 18 - 类加载机制

## 类加载生命周期

```
加载 → 验证 → 准备 → 解析 → 初始化 → 使用 → 卸载
          ↕ (可重排序)
        连接
```

| 阶段 | 说明 |
|------|------|
| **加载** | 通过全限定名获取二进制字节流，生成 Class 对象 |
| **验证** | 校验字节码合法性（格式、语义、符号引用） |
| **准备** | 为静态变量分配内存并赋零值 |
| **解析** | 符号引用 → 直接引用 |
| **初始化** | 执行 `<clinit>()` 方法，为静态变量赋值 |

## 类加载器

```
┌─────────────────────────────────────┐
│          Bootstrap ClassLoader      │
│  (C++实现，加载 rt.jar / java.*)     │
├─────────────────────────────────────┤
│         Extension ClassLoader        │
│  (加载 jre/lib/ext/*.jar)           │
├─────────────────────────────────────┤
│         Application ClassLoader      │
│  (加载 classpath 下的类)             │
├─────────────────────────────────────┤
│         自定义 ClassLoader           │
│  (热部署、加密解密等场景)             │
└─────────────────────────────────────┘
```

## 双亲委派模型

### 工作流程

1. 类加载器收到类加载请求
2. 委派给**父加载器**尝试加载
3. 父加载器无法加载（找不到此类）时，子加载器才尝试加载

```java
protected Class<?> loadClass(String name) {
    // 1. 检查是否已加载
    Class<?> c = findLoadedClass(name);
    if (c == null) {
        if (parent != null) {
            c = parent.loadClass(name);  // 委派给父加载器
        } else {
            c = findBootstrapClassOrNull(name);
        }
    }
    // 2. 父加载器未找到，自己加载
    if (c == null) {
        c = findClass(name);
    }
    return c;
}
```

### 为什么用双亲委派？

- **安全性** — 防止核心 API 被篡改（`java.lang.String` 始终由 Bootstrap 加载器加载）
- **避免重复加载** — 父加载器已加载的子加载器无需再次加载

### 打破双亲委派

- **SPI** (Service Provider Interface) — JDBC、JNDI 等使用线程上下文类加载器
- **热部署** — Tomcat 的 WebAppClassLoader 优先加载 web 应用中的类
- **OSGi** — 每个模块有自己的类加载器

## 自定义 ClassLoader

```java
public class MyClassLoader extends ClassLoader {
    @Override
    protected Class<?> findClass(String name) {
        byte[] bytes = loadClassData(name);
        return defineClass(name, bytes, 0, bytes.length);
    }
}
```
