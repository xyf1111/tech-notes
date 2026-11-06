---
title: "网络 05 - HTTP协议详解"
date: 2024-01-01
tags: [网络, HTTP]
---

# 网络 05 - HTTP 协议详解

## HTTP 请求结构

```
请求行:  GET /api/users HTTP/1.1
请求头:  Host: example.com
         User-Agent: curl/8.0
         Accept: application/json
         Authorization: Bearer xxx
         
请求体:  {"name": "张三"}
```

### HTTP 响应结构

```
状态行:  HTTP/1.1 200 OK
响应头:  Content-Type: application/json
         Content-Length: 42
         Cache-Control: max-age=3600
         
响应体:  {"id": 1, "name": "张三"}
```

## 请求方法

| 方法 | 含义 | 幂等 | 安全 | 请求体 |
|------|------|------|------|--------|
| GET | 获取资源 | ✅ | ✅ | 无 |
| HEAD | 获取响应头 | ✅ | ✅ | 无 |
| POST | 创建资源 | ❌ | ❌ | 有 |
| PUT | 替换资源 | ✅ | ❌ | 有 |
| PATCH | 部分修改 | ❌ | ❌ | 有 |
| DELETE | 删除资源 | ✅ | ❌ | 可选 |
| OPTIONS | 查看支持方法 | ✅ | ✅ | 无 |

## 状态码

### 1xx 信息性
- **101** — Switching Protocols（WebSocket 升级）

### 2xx 成功
- **200** OK
- **201** Created（POST 创建成功）
- **204** No Content（DELETE 成功，无响应体）

### 3xx 重定向
- **301** Moved Permanently（永久重定向，浏览器缓存）
- **302** Found（临时重定向）
- **304** Not Modified（协商缓存命中）

### 4xx 客户端错误
- **400** Bad Request（参数错误）
- **401** Unauthorized（未认证）
- **403** Forbidden（无权限）
- **404** Not Found
- **405** Method Not Allowed
- **409** Conflict（资源冲突）
- **429** Too Many Requests（限流）

### 5xx 服务端错误
- **500** Internal Server Error
- **502** Bad Gateway（上游不可达）
- **503** Service Unavailable（过载/停机）
- **504** Gateway Timeout（上游超时）

## HTTP 版本对比

| 特性 | HTTP/1.1 | HTTP/2 | HTTP/3 |
|------|----------|--------|--------|
| 传输层 | TCP | TCP | QUIC (UDP) |
| 多路复用 | ❌（队头阻塞） | ✅ | ✅ |
| 头部压缩 | ❌ | ✅ HPACK | ✅ QPACK |
| 服务器推送 | ❌ | ✅ | ✅ |
| 连接迁移 | ❌ | ❌ | ✅（连接 ID） |
| 加密 | 可选 | 实际强制 | 强制 |

### HTTP/2 核心改进

```
HTTP/1.1 队头阻塞：
请求1 ████████████
请求2                ████████
请求3                        ████

HTTP/2 多路复用：
请求1 ████
请求2    ██████
请求3 ██
```

## HTTPS

HTTPS = HTTP + SSL/TLS

```
客户端                             服务端
  │                                 │
  ├── ClientHello ────────────────►│  1. 支持的加密套件、TLS 版本
  │                                 │
  │◄── ServerHello + 证书 ───────────┤  2. 选择加密套件，发送证书
  │                                 │
  ├── 验证证书有效性               │  3. 验证 CA 签名
  │                                 │
  ├── 生成 Pre-Master Secret ─────►│  4. 用公钥加密发送
  │                                 │
  │◄══ 对称密钥（会话密钥）建立 ═══►│  5. 双方计算会话密钥
  │                                 │
  │◄══════ 加密通信 ═══════════════►│
```

### HTTPS vs HTTP

| 对比 | HTTP | HTTPS |
|------|------|-------|
| 端口 | 80 | 443 |
| 安全性 | 明文 | 加密 |
| 性能 | 快 | 慢（1 次 RTT 握手） |
| SEO | 普通 | 加分 |
| 证书 | 不需要 | 需要 CA 证书 |
