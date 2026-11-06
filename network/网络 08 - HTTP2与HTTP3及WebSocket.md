---
title: "网络 08 - HTTP2与HTTP3及WebSocket"
date: 2026-06-11
tags: [网络]
---

# 网络 08 - HTTP/2、HTTP/3 与 WebSocket

## HTTP 协议演进

| 版本 | 年份 | 核心改进 |
|------|------|----------|
| HTTP/1.1 | 1997 | 持久连接、管道化、分块传输 |
| HTTP/2 | 2015 | 二进制分帧、多路复用、头部压缩、服务端推送 |
| HTTP/3 | 2022 | QUIC（基于 UDP）、0-RTT、无队头阻塞 |

## HTTP/1.0 → 1.1 → 2.0 的差异

三个版本的核心分歧都在"一个 TCP 连接怎么用"上，先看一张总表：

| 维度 | HTTP/1.0 | HTTP/1.1 | HTTP/2 |
|------|----------|----------|--------|
| 连接复用 | 默认短连接，每个请求新建 TCP | 默认持久连接，`Connection: keep-alive` 协商 | 单条 TCP 连接承载全部请求 |
| 队头阻塞 | 严格串行，前一响应未完成则等待 | 管道化名义上可连续发，实际仍有 HOL | 应用层消除，TCP 层仍存在 |
| 请求并发 | 只能靠浏览器多开连接 | 同域约 6 条连接 + 管道化（默认关闭） | 单连接内多路复用，流之间互不等待 |
| 头部压缩 | 无，每次全量明文 | 无压缩（只压响应体） | HPACK（静态表 + 动态表 + Huffman） |
| 传输格式 | 纯文本 | 文本 + 分块（chunked） | 二进制分帧（帧 / 消息 / 流） |
| 服务端推送 | 无 | 无 | Server Push（已被浏览器移除） |
| Host 头 | 无，一 IP 一站点 | 必填，支撑虚拟主机 | 保留，映射为 `:authority` 伪头 |
| 默认连接语义 | `close` | `keep-alive` | 长连接 + 流优先级树 |

### HTTP/1.0 的关键特征

- **短连接**：每个请求都要新建并关闭一次 TCP 连接。`Connection: keep-alive` 虽由 1.0 引入，但必须客户端和服务端**双方显式声明**才生效，且部分代理会直接剥掉该头，实际不可靠。
- **无 Host 头**：请求行里只有路径，一台服务器只能对应一个 IP 上的一个站点，虚拟主机（同 IP 多域名）几乎无法实现。
- **不支持断点续传 / 范围请求**：`Range` 与 `206 Partial Content` 是 1.1 才有的，大文件断了只能从头再来。
- **缓存控制粗糙**：只有 `Expires`（绝对时间，依赖客户端时钟）和 `If-Modified-Since`（秒级），没有强/协商缓存的明确区分。
- **无管道化**：客户端必须等上一个响应到达才能发下一个请求。

### HTTP/1.1 修补了什么、还剩下什么问题

修补的部分：

- **持久连接 + 管道化**：连接默认不关，请求可以连续发出而无需等待响应；但响应仍须**按请求顺序**返回，一个慢响应就把后面全堵住，这就是 1.1 的队头阻塞，因此主流浏览器最终都**默认关闭**管道化。
- **Host 头**：请求头携带域名，一台物理机可托管多个站点。
- **分块传输**：`Transfer-Encoding: chunked` 让服务端不必预先知道 `Content-Length` 就能边算边发，适合动态页面和大文件流式响应。
- **范围请求**：`Range` / `206`，支撑断点续传与多线程下载。
- **更细的缓存语义**：`Cache-Control`、`ETag` / `If-None-Match`，区分强缓存与协商缓存。
- **`Expect: 100-continue`**：客户端先问服务端要不要收大请求体，避免白传。

残留的问题：并发仍然靠"多开连接"顶着——浏览器对同一域名通常只允许 **6 条**连接，超出的请求要在队列里排队，`6 条连接 × 顺序返回`依然是队列式的队头阻塞；同时每条连接都重复发送几乎相同的头部，浪费带宽。这才是 HTTP/2 要解决的出发点。

### HTTP/2 怎么解决

- **二进制分帧**：把报文切成带长度前缀的二进制 **帧**，同一条连接上的所有帧可以交错发送，接收端按**流 ID** 重组。层级关系是 连接 → 流（Stream，一次请求/响应）→ 消息（Message，一次完整请求或响应）→ 帧（Frame，最小传输单位）。
- **多路复用**：一条 TCP 连接上并行跑成百上千个流，彻底消除了**应用层**队头阻塞，也避免了为每个请求重新握手和重复经历 TCP 慢启动。
- **HPACK 头部压缩**：静态表 + 动态表 + Huffman 编码，双方各自维护头部字典，只传索引和增量，同一批请求的重复头（`User-Agent`、`Cookie`）几乎不占带宽。
- **Server Push**：服务端在客户端请求 HTML 时主动把 CSS/JS 推过去，省一轮 RTT。**现状**：因缓存与优先级难以和浏览器对齐、实际收益不佳，Chrome 106 起已移除该特性，现在提它只作为"曾经的设计"，别当成 HTTP/2 的现役优势。
- **流优先级**：客户端可标注哪个流更要紧，服务端据此分配带宽（实际实现效果有限，HTTP/3 已改用可扩展优先级方案）。

遗留问题：多路复用把鸡蛋全放在一条 TCP 连接里，一旦发生丢包，TCP 的有序重传会把**整条连接**上所有流一起卡住——这就是 TCP 层队头阻塞，也是 HTTP/3 换用 QUIC 的直接动因。

### 历史背景

HTTP 诞生于 1989—1990 年，蒂姆·伯纳斯-李在 CERN 同时做出了 URI、HTML、HTTP 和第一个浏览器/服务器。最早的 HTTP/0.9 极简到只有 `GET` 一个方法、没有请求头和状态码、响应就是纯文本 HTML，取完即断开，所谓 "0.9" 是后人补的版本号。1996 年 HTTP/1.0 正式发布（新增方法、状态码、头部、版本号、`Content-Type`），1997—1999 年 HTTP/1.1 以 RFC 2068 / RFC 2616 定稿，2015 年 HTTP/2 以 Google 的 SPDY 为蓝本发布。这条线的共同规律是：**每一版都在还上一版留下的性能债**。

> 相关：[[#HTTP/1.1 的问题]]、[[#HTTP/2 改进]]、[[#HTTP/3（QUIC）]]、[[网络 05 - HTTP协议详解]]、[[网络 03 - TCP三次握手与四次挥手]]

## HTTP/1.1 的问题

1. **队头阻塞（HOL Blocking）** — 同一连接上请求必须按顺序返回
2. **头部冗余** — 每次请求发送相同的头部，浪费带宽
3. **连接数过多** — 浏览器为每个域名开 6 个连接

## HTTP/2 改进

### 二进制分帧

HTTP/1.1 是文本协议，HTTP/2 改为二进制帧，更高效解析。

### 多路复用

```
HTTP/1.1:  ┌──请求1──┐──请求2──┐──请求3──┐ （串行）
HTTP/2:   ┌─请求1─┐┌─请求2─┐┌─请求3─┐   （并发帧）
```

### 头部压缩（HPACK）

- 使用静态表 + 动态表 + Huffman 编码
- 减小头部体积 80%+

### 服务端推送（Server Push）

服务端可主动推送客户端可能需要的资源（如 HTML 中的 CSS/JS）。

## HTTP/3（QUIC）

### QUIC 协议

基于 UDP 实现的可靠传输协议。

| HTTP/2 | HTTP/3 |
|--------|--------|
| 基于 TCP | 基于 UDP（QUIC） |
| TCP 队头阻塞 | 无队头阻塞（丢包只影响单个流） |
| 1-3 RTT 连接 | 0-1 RTT 连接 |
| 内核态 TLS | 用户态加密 |

## WebSocket

### 什么是 WebSocket

基于 TCP 的**全双工通信**协议，浏览器与服务器可以实时双向推送数据。

### 建立过程

```
客户端 → HTTP 升级请求 → 服务端 → 101 切换协议 → 全双工通信
```

```http
GET /chat HTTP/1.1
Host: example.com
Connection: Upgrade
Upgrade: websocket
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
```

### 应用场景

| 场景 | 说明 |
|------|------|
| **实时聊天** | 即时消息推送 |
| **股票行情** | 价格实时更新 |
| **协作编辑** | 多人同时编辑文档 |
| **游戏** | 实时对战 |
| **通知推送** | 替代轮询 |

### HTTP 短轮询 vs WebSocket

| 对比 | 短轮询 | WebSocket |
|------|--------|-----------|
| 延迟 | 受轮询间隔影响 | 实时 |
| 带宽 | 每次建立 HTTP 连接 | 一次连接，持续通信 |
| 服务端压力 | 高（大量无效请求） | 低（事件触发） |

### JavaScript 客户端 API

```js
// 建立连接
const ws = new WebSocket('ws://localhost:8080/channel/echo');

// 接收消息
ws.addEventListener('message', (event) => {
    console.log('收到:', event.data);
});
// 或 ws.onmessage = (event) => { ... };

// 发送消息
ws.send('Hello, server!');

// 关闭连接
ws.close();

// 连接状态
if (ws.readyState === WebSocket.OPEN) { /* 连接打开 */ }

// 事件监听
ws.addEventListener('open', (e) => console.log('已连接'));
ws.addEventListener('close', (e) => console.log('已关闭'));
ws.addEventListener('error', (e) => console.error('异常:', e.error));
```

> WebSocket 没有跨域限制，可在任意页面控制台直接连接测试。

## Spring Boot WebSocket 实战

Spring Boot 整合 WebSocket 有两种方式：Jakarta EE 规范（`@ServerEndpoint`）和 Spring WebSocket 模块。

### 方式一：Jakarta EE @ServerEndpoint（推荐）

**添加依赖：**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-websocket</artifactId>
</dependency>
```

**开发端点：**
```java
@ServerEndpoint(value = "/channel/echo")
public class EchoChannel {

    private Session session;

    @OnOpen
    public void onOpen(Session session, EndpointConfig config) {
        this.session = session;
    }

    @OnMessage
    public void onMessage(String message) throws IOException {
        if ("bye".equalsIgnoreCase(message)) {
            this.session.close(
                new CloseReason(CloseReason.CloseCodes.NORMAL_CLOSURE, "Bye"));
            return;
        }
        this.session.getAsyncRemote()
            .sendText("[" + Instant.now().toEpochMilli() + "] Hello " + message);
    }

    @OnClose
    public void onClose(CloseReason reason) { /* 断开处理 */ }

    @OnError
    public void onError(Throwable t) throws IOException {
        this.session.close(new CloseReason(
            CloseReason.CloseCodes.UNEXPECTED_CONDITION, t.getMessage()));
    }
}
```

**配置注册：**
```java
@Configuration
public class WebSocketConfig {
    @Bean
    public ServerEndpointExporter serverEndpointExporter() {
        return new ServerEndpointExporter();
    }
}
```

也可在端点上加 `@Component` 让 Spring 自动扫描注册。

### 注入 Bean 的注意事项

`@ServerEndpoint` 实例由 WebSocket 容器（Tomcat）创建，**不受 Spring 管理**，所以 `@Autowired` 注入会空指针。正确做法：

```java
@ServerEndpoint("/channel/echo")
@Component
public class EchoChannel implements ApplicationContextAware {

    private static ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(ApplicationContext ctx) {
        applicationContext = ctx;
    }

    private UserService userService;

    @OnOpen
    public void onOpen(Session session, EndpointConfig config) {
        this.session = session;
        // 连接创建时从 ApplicationContext 获取 Bean
        this.userService = applicationContext.getBean(UserService.class);
    }
}
```

`onOpen` 在整个连接生命周期只执行一次，不会带来通信性能损耗。

### 方式二：Spring WebSocket 模块

通过 `WebSocketHandler` 接口实现，可无缝整合 Spring Security 等模块，代码略（参考 Spring 官方文档）。

### WebSocket 连接状态码

| 状态码 | 含义 |
|--------|------|
| 1000 | 正常关闭（NORMAL_CLOSURE） |
| 1009 | 消息体超过 `@OnMessage` 的 `maxMessageSize` 限制 |
| 1011 | 服务端意外错误（UNEXPECTED_CONDITION） |

### 发送文件（服务端推送）

```java
// 服务端主动发送（基于 Session）
session.getAsyncRemote().sendText("消息内容");
session.getBasicRemote().sendText("同步消息");

// 群发管理（使用 CopyOnWriteArraySet 维护连接池）
private static CopyOnWriteArraySet<WebSocketServer> connections = new CopyOnWriteArraySet<>();
```

### 聊天室模型：点对点 vs 服务器中转

- **点对点直连**：每人与其他所有人各建一条连接，2000 人聊天室每人要建 1999 条连接，资源浪费严重，且无法统一控制用户、保证连接安全
- **服务器中转（聊天室基本模型）**：所有客户端连接同一服务器，消息统一发给服务器，由服务器决定转发/广播给哪些用户——每人只需一条连接

实现协议可选 HTTP 或 WebSocket；HTTP 单向、不够实时，实时聊天通常用 WebSocket。

> **WebSocket ≠ Socket**：Socket 不是协议，只是对 TCP/UDP 等协议的抽象封装接口，方便编程；WebSocket 是应用层协议，收发消息时只是**模拟**了 Socket 的实现。

### Socket.IO 聊天室实战（Node.js）

Socket.IO 是 Node.js 优秀的 WebSocket 封装库，一个 JS 语言同时实现前后端，官方提供聊天室 Demo（入门体验优于 Vertx/Netty 等 Java 方案）。

**服务端**（Express + Socket.IO）：监听事件（事件名可自定义），收到消息后广播给其他客户端：

```js
// 监听 chat message 事件
socket.on('chat message', (msg) => {
  // 收到消息后广播到其他客户端
  socket.broadcast.emit('chat message', msg);
});
```

**客户端**：点击发送按钮时触发事件，服务端广播后其余客户端监听插入 DOM：

```js
// 发送消息
socket.emit('chat message', '用户输入的消息');

// 接收并展示消息
socket.on('chat message', function(msg) {
  var item = document.createElement('li');
  item.textContent = msg;
  messages.appendChild(item);
  window.scrollTo(0, document.body.scrollHeight);
});
```

完整流程：Express 建 Node.js 服务 → 前端页面发送消息界面 → 前后端整合 Socket.IO → 发送/广播 → 接收方插入 DOM。可扩展到实时视频评论监控等场景；企业级聊天室仍需考虑鉴权、消息持久化、水平扩展等。
