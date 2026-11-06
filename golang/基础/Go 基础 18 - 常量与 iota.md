---
title: "Go 基础 18 - 常量与 iota"
date: 2026-06-13
tags:
  - golang
  - go基础
aliases:
  - "Go 基础 18"
---

# Go 基础 18 - 常量与 iota

## 常量（Constants）

常量是**编译期确定**的值，用 `const` 关键字声明：

```go
const Pi = 3.14159
const Greeting = "Hello, World"

// 批量声明
const (
    StatusOK   = 200
    StatusNotFound = 404
    StatusError    = 500
)
```

### 有类型常量 vs 无类型常量

```go
// 无类型常量：可以隐式转换
const Pi = 3.14159
var radius float32 = 5.0
area := Pi * radius * radius  // 自动推断为 float32

// 有类型常量：类型严格
const PiFloat64 float64 = 3.14159
// var radius float32 = 5.0
// area := PiFloat64 * radius  // ❌ 编译错误：类型不匹配
```

> **推荐**：如果不需要特定类型，优先用无类型常量（更灵活）。

### 常量表达式的求值

```go
const (
    a = 2 + 3        // 5（编译期求值）
    b = a * 2        // 10（可以引用其他常量）
    // c = os.Getenv("PATH")  // ❌ 编译错误：不能是运行时调用
)

const (
    Size = 1024
    MaxSize = Size * 4  // 4096
)
```

## iota 枚举

`iota` 在 `const` 块中逐行递增，从 `0` 开始：

```go
const (
    Monday = iota     // 0
    Tuesday           // 1
    Wednesday         // 2
    Thursday          // 3
    Friday            // 4
    Saturday          // 5
    Sunday            // 6
)
```

### iota 跳过与重置

```go
const (
    A = iota    // 0
    _           // 1（跳过）
    B           // 2
)

// 每个 const 块重新从 0 开始
const (
    C = iota    // 0（重新开始）
    D           // 1
)
```

### iota 偏移与计算

```go
const (
    KB = 1 << (10 * iota)   // 1 << 0
    MB                       // 1 << 10
    GB                       // 1 << 20
    TB                       // 1 << 30
)

// 结果
fmt.Println(KB) // 1024
fmt.Println(MB) // 1048576
```

### 位掩码枚举

```go
const (
    Read    = 1 << iota  // 0001 = 1
    Write                 // 0010 = 2
    Execute              // 0100 = 4
)

permission := Read | Write  // 0011 = 3
fmt.Println(permission & Read)    // 1（有 Read 权限）
fmt.Println(permission & Execute) // 0（无 Execute 权限）
```

### 自定义类型枚举

```go
type Weekday int

const (
    Sunday Weekday = iota  // 0
    Monday                 // 1
    Tuesday                // 2
    Wednesday              // 3
    Thursday               // 4
    Friday                 // 5
    Saturday               // 6
)
```

## 字符串常量 vs 数字常量

```go
// 字符串是常量
const Name = "Go"
// Name[0] = 'G'       // ❌ 编译错误：字符串常量不可修改

// 数字常量可以有精度
const Big = 1 << 100           // 大整数常量
const Precision = Big / 1e10   // 编译期计算

// 但赋给变量可能会溢出
// var x int = Big  // ❌ 编译错误：溢出
```

## 常量 vs 变量

| 特性 | 常量 | 变量 |
|------|------|------|
| 声明 | `const` | `var` |
| 赋值时机 | 编译期 | 运行时 |
| 修改 | ❌ 不可修改 | ✅ 可修改 |
| 类型推断 | 支持（无类型常量） | 支持 |
| 用途 | 固定值、枚举 | 可变状态 |

## 最佳实践

1. **魔数用常量替代** — 避免硬编码数字
2. **枚举用 `iota`** — 简洁且便于扩展
3. **不需要特定类型时用无类型常量** — 更灵活
4. **常量名用 PascalCase 或 SCREAMING_SNAKE_CASE** — Go 社区无强制约定，推荐用 PascalCase（但 HTTP 状态码等习惯用全大写）
5. **先定义 `Unspecified=0`** — 枚举的零值应该是「未指定」，而不是有效值

```go
type Status int

const (
    StatusUnspecified Status = iota  // 0 = Unspecified
    StatusPending                     // 1
    StatusApproved                    // 2
    StatusRejected                    // 3
)
```

## 参考资料

- [Go by Example: Constants](https://gobyexample.com/constants)
- [Effective Go: Constants](https://go.dev/doc/effective_go#constants)
- [Go 常量与 iota 详解](https://go.dev/blog/constants)
