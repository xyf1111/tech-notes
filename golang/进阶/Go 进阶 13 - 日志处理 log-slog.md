---
title: "Go 进阶 13 - 日志处理 log/slog"
date: 2026-06-13
tags:
  - golang
  - 进阶
aliases:
  - "Go 进阶 13"
---

# Go 进阶 13 — 日志处理 log/slog

## slog 简介

Go 1.21+ 标准库引入了 `log/slog` — **结构化日志**库：

```go
import "log/slog"

slog.Info("server started", "port", 8080, "env", "production")
// 2024/01/15 10:30:00 INFO server started port=8080 env=production
```

| 日志级别 | 说明 |
|---------|------|
| `slog.Debug` | 调试信息 |
| `slog.Info` | 一般信息 |
| `slog.Warn` | 警告 |
| `slog.Error` | 错误 |

## 结构化日志

### 键值对方式

```go
slog.Info("request processed",
    "method", r.Method,
    "path", r.URL.Path,
    "status", resp.StatusCode,
    "duration", time.Since(start),
)
```

### 分组

```go
slog.Info("user action",
    "user", slog.Group("user", "id", 123, "role", "admin"),
    "action", "login",
)
// 输出：user.id=123 user.role=admin action=login
```

### Attr 方式

```go
slog.LogAttrs(context.Background(), slog.LevelInfo,
    "request completed",
    slog.String("method", "GET"),
    slog.Int("status", 200),
    slog.Duration("duration", 150*time.Millisecond),
    slog.Any("error", err),
)
```

## Logger 配置

### 创建 Logger

```go
// Text 格式（默认）
logger := slog.New(slog.NewTextHandler(os.Stdout, nil))

// JSON 格式（推荐生产环境）
logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
// {"time":"2024-01-15T10:30:00Z","level":"INFO","msg":"server started","port":8080}

// 配置文件
handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
    Level:     slog.LevelWarn,       // 只输出 Warn 及以上
    AddSource: true,                  // 添加源代码位置
})
logger := slog.New(handler)
```

### 设置为全局 logger

```go
slog.SetDefault(logger)
// 现在 slog.Info() 会使用自定义 logger
slog.Info("this uses json format")
```

## 自定义 Handler

```go
type RedactedHandler struct {
    handler slog.Handler
}

func (h *RedactedHandler) Handle(ctx context.Context, r slog.Record) error {
    // 修改记录：隐藏密码字段
    r.Attrs(func(a slog.Attr) {
        if a.Key == "password" {
            r.AddAttrs(slog.String("password", "***"))
        }
    })
    return h.handler.Handle(ctx, r)
}

func (h *RedactedHandler) Enabled(ctx context.Context, level slog.Level) bool {
    return h.handler.Enabled(ctx, level)
}

func (h *RedactedHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
    return &RedactedHandler{h.handler.WithAttrs(attrs)}
}

func (h *RedactedHandler) WithGroup(name string) slog.Handler {
    return &RedactedHandler{h.handler.WithGroup(name)}
}
```

## 旧版 log 包

```go
import "log"

// 基本用法
log.Println("server started on :8080")  // 2024/01/15 10:30:00 server started on :8080
log.Printf("user %s logged in", "alice")

// 配置
log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
log.SetPrefix("[myapp] ")
log.SetOutput(os.Stderr)
```

## 日志最佳实践

### 1. 统一日志格式

```go
// 项目启动时配置
func init() {
    handler := slog.NewJSONHandler(os.Stderr, &slog.HandlerOptions{
        Level: slog.LevelInfo,
    })
    slog.SetDefault(slog.New(handler))
}
```

### 2. 日志信息要有上下文

```go
// ❌ 不好：没有上下文
slog.Error("error")

// ✅ 好：包含操作、资源、错误信息
slog.Error("failed to fetch user",
    "user_id", id,
    "error", err,
)
```

### 3. 不要 log 敏感信息

```go
// ❌ 不要记录密码、token
slog.Info("user login", "password", pwd)

// ✅ 记录脱敏信息
slog.Info("user login", "user_id", id, "ip", ip)
```

### 4. 使用 RequestID 串联请求

```go
// 在中间件中设置
ctx = context.WithValue(ctx, "request_id", requestID)
logger := slog.With("request_id", requestID)
slog.SetDefault(logger)
```

## 参考资料

- [log/slog 官方文档](https://pkg.go.dev/log/slog)
- [Go Blog: Structured Logging with slog](https://go.dev/blog/slog)
- [slog 使用指南](https://go.dev/doc/structured-logging-with-slog)
