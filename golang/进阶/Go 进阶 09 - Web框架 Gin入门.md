---
title: "Go 进阶 09 - Web 框架 Gin 入门"
date: 2026-06-13
tags:
  - golang
  - 进阶
aliases:
  - "Go 进阶 09"
---

# Go 进阶 09 — Web 框架 Gin 入门

## Gin 概述

Gin 是 Go 最流行的 Web 框架，以**高性能**和**轻量**著称：

```go
import "github.com/gin-gonic/gin"

r := gin.Default()
r.GET("/ping", func(c *gin.Context) {
    c.JSON(200, gin.H{
        "message": "pong",
    })
})
r.Run() // 默认 :8080
```

| 特性 | 说明 |
|------|------|
| 路由 | 支持 RESTful、路由组、参数路由 |
| 中间件 | 全局/路由级中间件、链式处理 |
| 参数绑定 | JSON/Form/URI 自动绑定和校验 |
| 渲染 | JSON/XML/HTML/Protobuf/YAML |

## 路由

### 基础路由

```go
r.GET("/user", handler)
r.POST("/user", handler)
r.PUT("/user/:id", handler)
r.DELETE("/user/:id", handler)
r.PATCH("/user/:id", handler)
r.Any("/health", handler)  // 所有方法
```

### 路径参数

```go
r.GET("/user/:id", func(c *gin.Context) {
    id := c.Param("id")   // 路径参数
    name := c.Query("name") // URL 查询参数
    c.JSON(200, gin.H{"id": id, "name": name})
})
// GET /user/123?name=alice → {"id":"123","name":"alice"}
```

### 通配符路由

```go
r.GET("/files/*path", func(c *gin.Context) {
    path := c.Param("path") // 包含前导 /
    c.String(200, "file: %s", path)
})
// GET /files/a/b/c.txt → "file: /a/b/c.txt"
```

### 路由组

```go
v1 := r.Group("/api/v1")
{
    v1.GET("/users", listUsers)
    v1.POST("/users", createUser)
    v1.GET("/users/:id", getUser)
}

v2 := r.Group("/api/v2")
{
    v2.GET("/users", listUsersV2)
}
```

## 请求参数绑定

```go
type CreateUserRequest struct {
    Name  string `json:"name" form:"name" binding:"required"`
    Email string `json:"email" form:"email" binding:"required,email"`
    Age   int    `json:"age" form:"age" binding:"gte=0,lte=150"`
}

r.POST("/user", func(c *gin.Context) {
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }
    c.JSON(200, req)
})
```

### 不同绑定方式

```go
c.ShouldBindJSON(&req)     // JSON body
c.ShouldBindQuery(&req)    // URL 查询参数
c.ShouldBindForm(&req)     // 表单
c.ShouldBindUri(&req)      // URI 路径参数
c.ShouldBind(&req)         // 自动判断 Content-Type
```

## 中间件

```go
// 全局中间件
r.Use(gin.Logger())
r.Use(gin.Recovery())

// 自定义中间件
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            c.AbortWithStatusJSON(401, gin.H{"error": "unauthorized"})
            return
        }
        // 验证 token...
        c.Set("user_id", "123")
        c.Next()  // 继续执行
    }
}

r.GET("/profile", AuthMiddleware(), func(c *gin.Context) {
    userID := c.GetString("user_id")
    c.JSON(200, gin.H{"user_id": userID})
})
```

### 路由组中间件

```go
api := r.Group("/api")
api.Use(AuthMiddleware())
{
    api.GET("/profile", profile)
    api.PUT("/settings", updateSettings)
}
```

## 响应格式

```go
// JSON
c.JSON(200, gin.H{"key": "value"})
c.JSON(200, &user)  // 结构体自动序列化

// XML
c.XML(200, gin.H{"key": "value"})

// YAML
c.YAML(200, gin.H{"key": "value"})

// 字符串
c.String(200, "Hello %s", name)

// 文件
c.File("./static/logo.png")

// 重定向
c.Redirect(301, "/new-path")
```

## 静态文件服务

```go
r.Static("/static", "./public")
r.StaticFile("/favicon.ico", "./public/favicon.ico")
r.StaticFS("/assets", http.Dir("./assets"))
```

## 参考资料

- [Gin 官方文档](https://gin-gonic.com/docs/)
- [Gin GitHub](https://github.com/gin-gonic/gin)
- [Go Web 开发最佳实践](https://go.dev/doc/articles/wiki/)
