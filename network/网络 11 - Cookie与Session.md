---
title: "网络 11 - Cookie与Session"
date: 2026-08-17
tags: [网络, HTTP, Cookie, Session, 会话管理]
source: "鱼皮·编程导航 / codefather"
---

# 网络 11 - Cookie 与 Session

> HTTP 是无状态协议，服务器无法判断请求来自哪个用户，因此诞生了 Cookie 与 Session 实现状态保持：Cookie 存客户端、Session 存服务端，二者「黄金搭档」共同完成会话管理。

## 背景：HTTP 的无状态问题

- HTTP 是无状态的请求-响应协议，每个请求之间**相互独立、互不相关**，服务器处理完请求后不会保存任何客户端状态。
- 弊端：服务端无法判断请求是哪个用户发起的 → 需要对**状态保持**做额外处理 → 诞生 Cookie 和 Session。

## Cookie

### 概念

- Cookie（HTTP Cookie）由**服务器发送到浏览器（客户端）**，保存在用户本地计算机上的**小型文本文件**（可持久化）。
- 用于存储特定网站的用户信息，实现状态保持，用户再次访问时可直接检索使用。

### 应用场景

1. **免登录**：首次登录成功后浏览器提示保存账号信息（本质是 Cookie 存储），下次直接从 Cookie 取出信息免登录。注意：免登录≠跳过数据库查询，只是登录信息从 Cookie 中取出。
2. **会话管理**：检测用户登录后是否连续操作，超过过期时间则需重新校验身份（如 B 站 30 天未操作需重新登录）。
3. **个性化体验**：存储个人偏好配置（暗黑模式、页面布局、语言选择等）。

### 作用

- 服务器识别用户，保持跳转页面时会话状态的一致性
- 实现免登录、自动身份验证
- 保留个性化体验

### 存储位置

不同浏览器、不同操作系统下 Cookie 的本机存储位置不同（由各浏览器实现决定）。

## Session

### 概念

- 会话（Session）指用户与服务器之间建立的**交互周期**，允许服务器在多次请求-响应之间跟踪用户状态。
- 常说的 Session 存在于**服务端**，用于跟踪用户的请求和响应。

### 浏览器 Session vs 服务端 Session

| 类型 | 存储位置 | 生命周期 | 持久化 |
|------|----------|----------|--------|
| 会话 Cookie（浏览器 Session） | 浏览器进程内 | 关闭浏览器即销毁 | 不具持久化 |
| 服务端 Session | 服务器（内存、磁盘等） | 由服务器配置控制，不受关闭浏览器影响 | 可持久化 |

## Cookie 和 Session 的关系

- 二者互补配合：Cookie 负责客户端侧的标识与存储，Session 负责服务端侧的状态保存，一般通过 Cookie 携带 sessionId 关联服务端 Session。
- 会话 Cookie 与「黄金搭档」说法：有了 Cookie 就一定有 Session（指会话场景下二者配合使用）。

## SessionId 的判定规律（实验验证）

测试代码（Spring Boot）：

```java
@GetMapping("/test")
public void test(HttpServletRequest request, HttpServletResponse response) throws IOException {
    String id = request.getSession().getId();
    response.getWriter().write(id);
}
```

实测结论：

| 场景 | sessionId 是否相同 |
|------|-------------------|
| 不同用户、同一浏览器、同一标签页、同一请求 | 相同（但后一次请求的 value 会覆盖前一次的，前提是 key 相同） |
| 同一浏览器、不同标签页、同一请求 | 相同 |
| 不同浏览器、同一请求 | 不同 |

**总结：只要符合「同一个浏览器 + 同一个请求」，sessionId 一定相同。**

> 来源：鱼皮·编程导航 / codefather
