---
title: "Go 进阶 14 - HTTP 服务开发"
date: 2026-06-13
tags:
  - golang
  - 进阶
aliases:
  - "Go 进阶 14"
---

# Go 进阶 14 — HTTP 服务开发

## 标准库 net/http

```go
import "net/http"

// 基本 HTTP 服务器
func main() {
    http.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello, %s!", r.URL.Query().Get("name"))
    })

    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

### Handler 接口

```go
type Handler interface {
    ServeHTTP(w http.ResponseWriter, r *http.Request)
}

// 自定义 Handler
type HelloHandler struct{}

func (h *HelloHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("Hello, World!"))
}

http.Handle("/hello", &HelloHandler{})
```

## 请求处理

### 获取请求信息

```go
func handler(w http.ResponseWriter, r *http.Request) {
    // 方法
    fmt.Println(r.Method)           // GET, POST, PUT...
    fmt.Println(r.URL.Path)         // /api/users/123

    // 查询参数
    name := r.URL.Query().Get("name")
    page, _ := strconv.Atoi(r.URL.Query().Get("page"))

    // Header
    contentType := r.Header.Get("Content-Type")
    token := r.Header.Get("Authorization")

    // Body
    body, err := io.ReadAll(r.Body)
    defer r.Body.Close()

    // Cookie
    cookie, err := r.Cookie("session_id")

    // 表单
    r.ParseForm()
    username := r.Form.Get("username")
}
```

### 响应

```go
func response(w http.ResponseWriter, r *http.Request) {
    // 状态码
    w.WriteHeader(http.StatusOK)    // 200
    w.WriteHeader(http.StatusNotFound)  // 404
    w.WriteHeader(http.StatusInternalServerError)  // 500

    // 响应体
    w.Write([]byte("OK"))

    // Header
    w.Header().Set("Content-Type", "application/json")
    w.Header().Set("X-Request-ID", requestID)

    // JSON 响应
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(map[string]interface{}{
        "status": "ok",
        "data":   result,
    })
}
```

## 路由

Go 1.22+ 标准库支持路径参数和方法路由：

```go
// Go 1.22+ 路由增强
mux := http.NewServeMux()
mux.HandleFunc("GET /api/users/{id}", getUser)
mux.HandleFunc("POST /api/users", createUser)
mux.HandleFunc("DELETE /api/users/{id}", deleteUser)

func getUser(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")   // 路径参数
    // ...
}
```

### 第三方路由

```go
import "github.com/go-chi/chi/v5"

r := chi.NewRouter()
r.Get("/api/users/{id}", getUser)
r.Post("/api/users", createUser)
r.Put("/api/users/{id}", updateUser)
r.Delete("/api/users/{id}", deleteUser)

// 路由组
r.Route("/api", func(r chi.Router) {
    r.Use(AuthMiddleware)
    r.Get("/users", listUsers)
    r.Get("/users/{id}", getUser)
})
```

## 中间件模式

```go
// 标准库中间件
func loggingMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        slog.Info("request",
            "method", r.Method,
            "path", r.URL.Path,
            "duration", time.Since(start),
        )
    })
}

// 链式中间件
handler := loggingMiddleware(authMiddleware(http.HandlerFunc(handler)))
```

### 常用中间件

```go
// CORS
func corsMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
        if r.Method == "OPTIONS" {
            w.WriteHeader(204)
            return
        }
        next.ServeHTTP(w, r)
    })
}

// Recovery
func recoveryMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        defer func() {
            if err := recover(); err != nil {
                log.Printf("panic recovered: %v", err)
                http.Error(w, "Internal Server Error", 500)
            }
        }()
        next.ServeHTTP(w, r)
    })
}
```

## 优雅关闭

```go
func main() {
    srv := &http.Server{
        Addr:    ":8080",
        Handler: mux,
    }

    // 启动服务器
    go func() {
        slog.Info("server starting on :8080")
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatal(err)
        }
    }()

    // 等待信号
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit
    slog.Info("shutting down server...")

    // 优雅关闭（最多等待 30 秒）
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Fatal("server forced to shutdown:", err)
    }
    slog.Info("server exited")
}
```

## 超时设置

```go
srv := &http.Server{
    Addr:         ":8080",
    Handler:      mux,
    ReadTimeout:  10 * time.Second,   // 读取请求超时
    WriteTimeout: 10 * time.Second,   // 写入响应超时
    IdleTimeout:  60 * time.Second,   // 长连接空闲超时
}
```

## 参考资料

- [Go net/http 文档](https://pkg.go.dev/net/http)
- [Go Blog: HTTP Server 最佳实践](https://go.dev/blog/http-server)
- [chi router](https://github.com/go-chi/chi)
- [Go 1.22 路由增强](https://go.dev/blog/routing-enhancements)
