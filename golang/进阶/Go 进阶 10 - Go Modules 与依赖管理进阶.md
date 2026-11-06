---
title: "Go 进阶 10 - Go Modules 与依赖管理进阶"
date: 2026-06-13
tags:
  - golang
  - 进阶
aliases:
  - "Go 进阶 10"
---

# Go 进阶 10 — Go Modules 与依赖管理进阶

> 基础入门见 [[golang/基础/Go 基础 09 - GOPATH与依赖管理]]。

## Module 设计策略

### 单一模块 vs 多模块

```
❌ 大仓单模块：
github.com/company/monorepo
├── pkg/
│   ├── auth/
│   ├── config/
│   └── db/
└── cmd/
    └── server/

✅ 多模块合理拆分：
github.com/company/auth    → go.mod（独立版本）
github.com/company/config  → go.mod
github.com/company/db      → go.mod
```

> 原则：**一个模块只做一件事**，有独立版本需求的包拆分为独立模块。

### 模块命名

```go
// ✅ 好：包含路径+包名明确
module github.com/gin-gonic/gin

// ❌ 不好：路径不明确
module mylib
```

## 版本管理策略

### 语义化版本

```
v1.2.3
│ │ │
│ │ └── 补丁版本（bug fix，向后兼容）
│ └──── 次版本（新功能，向后兼容）
└────── 主版本（不兼容变更）
```

### 主版本升级

当有 Breaking Change 时必须升级主版本：

```
v1.0.0 → v2.0.0 (Breaking Change)
```

Go Modules 支持多主版本共存：

```go
import (
    "github.com/company/lib/v2"  // v2.x
    "github.com/company/lib/v3"  // v3.x
)
```

模块路径需要包含 `/v2`、`/v3`。

## 依赖锁文件 go.sum

```go
// go.sum 内容
github.com/gin-gonic/gin v1.9.1 h1:...  // SHA-256 hash
github.com/gin-gonic/gin v1.9.1/go.mod h1:...  // go.mod hash
```

- **防篡改**：每次 `go mod tidy` 验证 hash
- **可重复**：确保所有人下载相同的依赖
- **自动管理**：不要手动编辑 go.sum

## vendor 目录

```go
// 生成 vendor
go mod vendor

// 构建时使用 vendor
go build -mod=vendor

// 适用于：
// - CI/CD 环境网络受限
// - 需要审计所有依赖代码
// - 无法访问外部 registry
```

## 私有仓库

```go
// 环境变量配置
go env -w GOPRIVATE=github.com/mycompany/*
go env -w GONOSUMCHECK=github.com/mycompany/*
go env -w GONOSUMDB=github.com/mycompany/*

// ~/.netrc 配置 Git 认证
machine github.com
login your-username
password your-github-token
```

### 替代方案（推荐 SSH）

```go
// ~/.gitconfig
[url "git@github.com:"]
    insteadOf = https://github.com/
```

## 依赖安全检查

```go
// govulncheck 检测已知漏洞
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...

// 依赖更新检查
go list -u -m all
```

## 参考资料

- [Go Modules 官方参考](https://go.dev/ref/mod)
- [Go Modules 最佳实践](https://go.dev/blog/modules-best-practices)
- [Go 依赖管理指南](https://go.dev/doc/modules/managing-dependencies)
- [govulncheck 文档](https://go.dev/security/vuln/)
