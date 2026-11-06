---
title: "Go 基础 09 — Go Modules 依赖管理"
date: 2021-02-17
tags:
  - golang
  - go基础
aliases:
  - "Go 基础 09"
  - "Go Study 09"
---

# Go 基础 09 — Go Modules 依赖管理

>
> ⚠️ **更新说明**：原笔记基于 GOPATH（已过时），现改为 Go Modules（Go 1.11+ 默认，Go 1.16+ 强制）。

## Go Modules 概述

Go Modules 从 **Go 1.11** 引入，**Go 1.16+** 默认启用，是官方推荐的依赖管理方案。

### 核心概念

- **Module** — 一个包含 `go.mod` 文件的目录树
- **`go.mod`** — 模块定义文件（module path + 依赖版本）
- **`go.sum`** — 依赖校验文件（防篡改）

## 初始化模块

```bash
# 创建新模块
go mod init github.com/user/myproject

# go.mod 内容：
# module github.com/user/myproject
# go 1.21
```

### Module Path 约定

| 场景 | Module Path | 示例 |
|------|-------------|------|
| GitHub 仓库 | `github.com/user/repo` | `github.com/gin-gonic/gin` |
| 私有仓库 | `gitlab.com/group/project` | `gitlab.com/myteam/service` |
| 本地实验 | `myproject` | `myproject` |

## 管理依赖

```bash
# 添加依赖
go get github.com/gin-gonic/gin@v1.9.1

# 更新所有依赖
go get -u ./...

# 移除未使用的依赖
go mod tidy

# 下载依赖到本地缓存
go mod download

# 查看模块依赖图
go mod graph

# 验证依赖完整性
go mod verify
```

### go.mod 示例

```
module github.com/user/myproject

go 1.21

require (
    github.com/gin-gonic/gin v1.9.1
    github.com/go-sql-driver/mysql v1.7.1
)

// 间接依赖（自动管理）
require (
    github.com/bytedance/sonic v1.9.1 // indirect
    golang.org/x/arch v0.3.0 // indirect
)
```

## 版本管理

### 版本格式

| 格式 | 示例 | 说明 |
|------|------|------|
| 语义化版本 | `v1.2.3` | 推荐方式 |
| 预发布版本 | `v1.2.3-beta.1` | 用于测试 |
| Commit Hash | `v0.0.0-20230101123456-abcdef` | 无标签时使用 |
| 分支最新 | `@latest` | 最新稳定版 |
| 特定版本 | `@v1.2.3` | 锁定版本 |

### 版本升级与降级

```bash
go get github.com/gin-gonic/gin@v1.8.0   # 降级
go get github.com/gin-gonic/gin@latest    # 最新
go get github.com/gin-gonic/gin@master    # 分支最新
```

## 依赖缓存位置

| 系统 | 路径 |
|------|------|
| Linux / macOS | `$(go env GOMODCACHE)` — 通常为 `~/go/pkg/mod` |
| Windows | `%USERPROFILE%\go\pkg\mod` |

```bash
# 查看模块缓存路径
go env GOMODCACHE

# 清除模块缓存（慎用）
go clean -modcache
```

## GOPROXY 代理设置

```bash
# 查看当前代理
go env GOPROXY

# 设置代理（常用方案）
go env -w GOPROXY=https://goproxy.cn,direct          # 国内推荐
go env -w GOPROXY=https://proxy.golang.org,direct    # 官方代理
go env -w GOPROXY=direct                             # 直连（不推荐）

# 私有仓库绕过代理
go env -w GOPRIVATE=github.com/mycompany/*
go env -w GONOSUMCHECK=github.com/mycompany/*         # 跳过 checksum
```

## 多模块工作区（Go 1.18+）

```bash
# go.work 文件（适合本地多模块开发）
go work init ./module1 ./module2

# go.work 内容：
# go 1.21
# use (
#     ./module1
#     ./module2
# )
```

## 常见问题

### 包下载失败

```bash
# 设置国内代理
go env -w GOPROXY=https://goproxy.cn,direct

# 如果单个包超时
GOPROXY=direct go get github.com/xxx/xxx
```

### 私有仓库认证

```bash
# ~/.netrc 或 ~/_netrc
machine github.com
login your-username
password your-github-token

# 或者使用 SSH（推荐）
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### 依赖被删除/修改

```bash
# Go Module 的 checksum 系统会检测篡改
# 如果确认要强制使用
go env -w GONOSUMCHECK=github.com/user/repo
GONOSUMDB=* go get github.com/user/repo@version
```

## GOPATH（旧版，了解即可）

> Go Modules 普及前，所有项目必须放在 `$GOPATH/src` 下。

```bash
# 默认路径
# Unix: ~/go
# Windows: %USERPROFILE%\go

# GOPATH 目录结构
$GOPATH/
├── bin/    # 编译后的可执行文件
├── pkg/    # 编译后的包对象
└── src/    # 源码（所有项目放这里）
```

**Go 1.16+ 不再需要设置 GOPATH**，除非使用旧版工具链。

## 参考资料

- [Go Modules 官方文档](https://go.dev/doc/modules/managing-dependencies)
- [Go Modules Reference](https://go.dev/ref/mod)
- [GOPROXY 设置](https://go.dev/doc/gopath.md)
