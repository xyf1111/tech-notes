---
title: "Go 基础 15 — 泛型 Generics"
date: 2026-06-11
tags:
  - golang
  - 现代Go
  - 泛型
  - Go1.18
source: ""
aliases:
  - "Go 基础 15"
  - "Go Generics"
  - "Go 泛型"
---

# Go 基础 15 - 泛型 Generics

> Go 1.18 引入（2022年3月），是 Go 语言诞生以来最大的语法变更。Go 1.21 起内置类型约束包。

## 为什么需要泛型

在没有泛型之前，实现一个通用的加法函数需要：

```go
// 必须为每种类型分别实现
func AddInt(a, b int) int { return a + b }
func AddFloat(a, b float64) float64 { return a + b }
// 或者用 interface{} + 类型断言（运行时开销，丢失类型安全）
func AddAny(a, b interface{}) interface{} { ... }
```

泛型让代码**一次编写，多种类型使用**，同时保持**编译时类型安全**。

---

## 基本语法

### 泛型函数

```go
// T 是类型参数，comparable 是类型约束
func Min[T comparable](a, b T) T {
    return a
}

// 多个类型参数
func Map[T, U any](s []T, f func(T) U) []U {
    result := make([]U, len(s))
    for i, v := range s {
        result[i] = f(v)
    }
    return result
}
```

### 泛型类型

```go
// 泛型栈
type Stack[T any] struct {
    items []T
}

func (s *Stack[T]) Push(item T) {
    s.items = append(s.items, item)
}

func (s *Stack[T]) Pop() (T, bool) {
    if len(s.items) == 0 {
        var zero T  // 零值
        return zero, false
    }
    item := s.items[len(s.items)-1]
    s.items = s.items[:len(s.items)-1]
    return item, true
}
```

### 调用方式

```go
minInt := Min[int](3, 5)     // 显式指定类型
minInt := Min(3, 5)          // 类型推断（推荐）
```

---

## 类型约束

### 内置约束

| 约束 | 含义 | 可用操作 |
|------|------|----------|
| `any` | 任何类型（等价于 `interface{}`） | 无特殊操作 |
| `comparable` | 可用 `==` 和 `!=` 比较的类型 | `==`, `!=` |
| `~int` | 底层类型为 int 的类型 | `+`, `-`, `*`, `/` 等 |

### 自定义约束（Go 1.18+）

```go
// 使用 interface 语法定义约束
type Number interface {
    ~int | ~int8 | ~int16 | ~int32 | ~int64 |
    ~uint | ~uint8 | ~uint16 | ~uint32 | ~uint64 |
    ~float32 | ~float64
}

func Sum[T Number](s []T) T {
    var total T
    for _, v := range s {
        total += v
    }
    return total
}

// 带方法的约束
type Stringer interface {
    ~string
    String() string
}
```

### 近似元素 `~`

```go
type MyInt int

// ~int 允许 MyInt（底层类型是 int）
// int 不允许 MyInt
func Double[T ~int](x T) T { return x * 2 }

Double(5)       // ✅ int
Double(MyInt(5)) // ✅ MyInt（用了 ~int）
```

---

## 标准约束包（Go 1.21+）

Go 1.21 在 `cmp` 包中提供了常用约束：

```go
import "cmp"

// cmp.Ordered 包含所有可排序类型
func Sort[T cmp.Ordered](s []T) { ... }

// 比较和交换
func Max[T cmp.Ordered](a, b T) T {
    if cmp.Less(a, b) { return b }
    return a
}
```

---

## 实际应用场景

### 1. 集合类型

```go
// 类型安全的 Set
type Set[T comparable] map[T]struct{}

func NewSet[T comparable]() Set[T] {
    return make(Set[T])
}

func (s Set[T]) Add(v T)     { s[v] = struct{}{} }
func (s Set[T]) Contains(v T) bool { _, ok := s[v]; return ok }
```

### 2. 可选值 / Result 类型（类似 Rust）

```go
type Option[T any] struct {
    value T
    ok    bool
}

func Some[T any](v T) Option[T] { return Option[T]{value: v, ok: true} }
func None[T any]() Option[T]    { return Option[T]{ok: false} }
```

### 3. 通用的 CRUD 处理器

```go
type Repository[T any, ID comparable] struct {
    store map[ID]T
    idFn  func(T) ID
}

func NewRepo[T any, ID comparable](idFn func(T) ID) *Repository[T, ID] {
    return &Repository[T, ID]{store: make(map[ID]T), idFn: idFn}
}

func (r *Repository[T, ID]) Save(item T) {
    r.store[r.idFn(item)] = item
}

func (r *Repository[T, ID]) FindByID(id ID) (T, bool) {
    item, ok := r.store[id]
    return item, ok
}
```

---

## 性能注意事项

- **无运行时开销**：泛型在编译时通过 **单态化 (monomorphization)** 实现，为每个具体类型生成专门的代码（类似 C++ 模板）
- **代码膨胀**：大量不同泛型类型参数会导致二进制体积增大
- **inline 友好**：编译器可以像普通函数一样内联泛型函数
- **对比 interface{}**：泛型没有装箱/拆箱开销，性能更好

```go
// 泛型：编译时确定类型，无装箱开销
func IdentityGeneric[T any](v T) T { return v }

// interface{}：运行时装箱
func IdentityInterface(v interface{}) interface{} { return v }
```

---

## 限制与注意事项

1. **不能用于方法（除了接收者）** — 方法不能有额外的类型参数
   ```go
   // ❌ 错误：方法不能有额外类型参数
   func (s Stack) Push[T any](v T) {}
   
   // ✅ 正确：在类型上声明泛型
   func (s *Stack[T]) Push(v T) {}
   ```

2. **不能用于类型断言** — `x.(T)` 中的 T 不能是泛型类型参数
3. **不能用于 switch 类型判断**
4. **不能用于匿名函数** — 闭包不支持类型参数
5. **预声明类型** — `nil` 不能赋值给泛型类型变量

---

## 与旧模式的对比

| 场景 | 旧方式（Go 1.17-） | 新方式（Go 1.18+） |
|------|-------------------|-------------------|
| 通用容器 | `interface{}` + 类型断言 | `Stack[T any]` |
| 排序 | `sort.Interface` + 反射 | `slices.Sort[S ~[]E, E cmp.Ordered]` |
| Map/Filter | 手写每种类型 | `slices.Collect` / 泛型函数 |
| 类型安全 | 运行时才能发现错误 | 编译时检查 |

---

## 推荐阅读

- [Go 官方泛型教程](https://go.dev/doc/tutorial/generics)
- [Go 1.18 发行说明](https://go.dev/doc/go1.18)
- [slices 包文档](https://pkg.go.dev/slices)
- [maps 包文档](https://pkg.go.dev/maps)
