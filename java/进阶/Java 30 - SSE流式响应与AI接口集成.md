---
title: "Java 30 - SSE流式响应与AI接口集成"
date: 2026-07-26
tags: [java, 进阶, spring, sse, ai]
source: "鱼皮·编程导航 / codefather"
---

# Java 30 - SSE 流式响应与 AI 接口集成

> 使用 Spring SseEmitter + WebSocket 实现流式 AI 大模型接口，逐字推送响应。

## SseEmitter 是什么

Spring 提供的 SSE（Server-Sent Events）实现，允许服务端向客户端单向实时推送数据。相比 WebSocket：

| 对比 | WebSocket | SseEmitter (SSE) |
|------|-----------|------------------|
| **方向** | 全双工 | 服务端→客户端单向 |
| **协议** | 独立 TCP 连接（ws://） | 基于 HTTP |
| **客户端支持** | 所有浏览器 | 除 IE 外均支持 EventSource API |
| **简洁性** | 需要握手升级 | 直接 HTTP 响应 |
| **推荐场景** | 双工通信（聊天、游戏） | 服务端推送（通知、AI 流式输出） |

## 基本用法

### 服务端

```java
@GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public SseEmitter stream() {
    // 创建 emitter，设置超时（毫秒）
    SseEmitter emitter = new SseEmitter(600_000L);

    // 超时回调
    emitter.onTimeout(() -> log.info("连接超时"));
    // 完成回调
    emitter.onCompletion(() -> log.info("连接关闭"));
    // 异常回调
    emitter.onError(e -> log.error("连接异常", e));

    // 异步推送数据
    CompletableFuture.runAsync(() -> {
        try {
            for (int i = 0; i < 10; i++) {
                emitter.send("data " + i);
                Thread.sleep(200);
            }
            emitter.complete(); // 推送完成
        } catch (Exception e) {
            emitter.completeWithError(e);
        }
    });

    return emitter;
}
```

### 客户端（浏览器）

```js
const eventSource = new EventSource('/stream');
eventSource.onmessage = (event) => {
    console.log('收到:', event.data);
};
eventSource.onerror = () => console.log('连接异常');
// 关闭: eventSource.close();
```

### 配置超时时间

```yaml
# application.yml
spring:
  mvc:
    async:
      request-timeout: 600000  # 10分钟
```

## AI 大模型流式输出实战

以大模型 API（如 iFlytek Spark、通义千问、DeepSeek）为例，常见的架构模式是：**WebSocket 连接 AI 服务 → SseEmitter 推送给客户端**。

### 架构设计

```
浏览器/App ──HTTP SSE──→ Spring Boot ──WebSocket──→ AI 大模型
                         └─ SseEmitter       └─ OkHttp WebSocket
```

核心流程：
1. 客户端发起 HTTP 请求
2. 服务端立即返回 SseEmitter（不阻塞）
3. 服务端通过 WebSocket 连接 AI 大模型
4. AI 逐字返回 → WebSocket onMessage → emitter.send() → 客户端实时收到
5. AI 返回完毕 → emitter.complete()

### 关键实现

#### 1. SseEmitter 连接管理器

```java
@Component
public class SseManager {
    private static final Map<Object, SseEmitter> SSE_CACHE = new ConcurrentHashMap<>();

    public SseEmitter getConn(Object key) {
        SseEmitter emitter = SSE_CACHE.get(key);
        if (emitter != null) return emitter;

        emitter = new SseEmitter(600_000L);
        emitter.onTimeout(() -> SSE_CACHE.remove(key));
        emitter.onCompletion(() -> SSE_CACHE.remove(key));
        emitter.onError(e -> SSE_CACHE.remove(key));
        SSE_CACHE.put(key, emitter);
        return emitter;
    }
}
```

#### 2. 控制器返回流式响应

```java
@GetMapping(value = "/chat", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
public SseEmitter chat(@RequestParam String question) {
    long userId = 132L;
    SseEmitter emitter = sseManager.getConn(userId);

    // 异步执行 AI 请求，不阻塞 HTTP 返回
    CompletableFuture.runAsync(() -> {
        StringBuilder answerCache = new StringBuilder();
        SparkChatListener listener = sparkManager.doChat(userId, question, answerCache);

        int lastIdx = 0;
        try {
            while (!listener.getWsCloseFlag()) {
                int len = answerCache.length();
                if (lastIdx < len) {
                    emitter.send(answerCache.substring(lastIdx, len));
                    lastIdx = len;
                }
                Thread.sleep(100); // 轮询间隔
            }
            emitter.complete();
        } catch (Exception e) {
            emitter.completeWithError(e);
        }
    });

    return emitter;
}
```

#### 3. WebSocket 监听器（AI 客户端侧）

```java
@Slf4j
public class SparkChatListener extends WebSocketListener {
    private final StringBuilder totalAnswer = new StringBuilder();
    private volatile boolean wsCloseFlag = false;

    public SparkChatListener(StringBuilder answerCache) {
        // answerCache 与控制器共享引用，用于实时读取
    }

    @Override
    public void onMessage(WebSocket webSocket, String text) {
        ChatResponse resp = JSONUtil.toBean(text, ChatResponse.class);
        if (resp.getHeader().getCode() != 0) {
            webSocket.close(1000, resp.getHeader().getMessage());
            return;
        }
        // 追加 AI 返回内容
        resp.getPayload().getChoices().getText()
            .forEach(t -> totalAnswer.append(t.getContent()));
        // 写入共享缓存
        answerCache.append(...);

        if (resp.getHeader().getStatus() == 2) {
            wsCloseFlag = true; // 最后一条响应
        }
    }

    @Override
    public void onFailure(WebSocket webSocket, Throwable t, Response response) {
        wsCloseFlag = true;
    }
}
```

### Auth 鉴权示例（WebSocket 连接的 AI API）

多数 AI 大模型 WebSocket 接口需要 HMAC-SHA256 签名鉴权：

```
date = RFC1123格式当前时间
signature = HMAC-SHA256(date, apiSecret)
authorization = base64(signature)
url = ws(s)://host/path?authorization=...&date=...&host=...
```

```java
public static String genAuthUrl(String apiKey, String apiSecret,
                                 String host, String path) throws Exception {
    String date = ZonedDateTime.now(ZoneOffset.UTC)
        .format(DateTimeFormatter.RFC_1123_DATE_TIME);
    String preSign = "host: " + host + "\ndate: " + date + "\nGET " + path + " HTTP/1.1";
    Mac mac = Mac.getInstance("HmacSHA256");
    mac.init(new SecretKeySpec(apiSecret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
    String sign = Base64.getEncoder().encodeToString(mac.doFinal(preSign.getBytes()));
    String auth = Base64.getEncoder().encodeToString(
        ("api_key=\"" + apiKey + "\", algorithm=\"hmac-sha256\", " +
         "headers=\"host date request-line\", signature=\"" + sign + "\"").getBytes());
    return "wss://" + host + path + "?authorization=" + auth +
           "&date=" + URLEncoder.encode(date, "UTF-8") + "&host=" + host;
}
```

## 总结

| 模式 | 适用场景 |
|------|---------|
| SseEmitter + CompletableFuture | AI 对话、实时通知、日志流 |
| SseEmitter + WebSocket 客户端 | 代理第三方 AI API（星火、通义等） |
| SseEmitter + 本地计算 | 大数据量分页导出、报表生成进度 |

> 来源：鱼皮·编程导航 / codefather
