---
title: "Go 基础 19 - make 与 new"
date: 2026-06-13
tags:
  - golang
  - go基础
aliases:
  - "Go 基础 19"
---

# Go 基础 19 - make 与 new

## 核心区别

| 特性 | `make` | `new` |
|------|--------|-------|
| 作用 | **初始化**引用类型 | **分配**零值内存 |
| 返回值 | 类型本身（非指针） | 指向零值的指针 |
| 适用类型 | `slice`、`map`、`channel` | 任意类型 |
| 零值效果 | 内部数据结构初始化 | 返回零值的指针 |

## make — 创建引用类型

```go
// Slice
s := make([]int, 5)        // len=5, cap=5, 元素全为 0
s2 := make([]int, 0, 10)   // len=0, cap=10（预分配容量）

// Map
m := make(map[string]int)        // 空的 map
m2 := make(map[string]int, 100)  // 预分配容量（减少 rehash）

// Channel
ch := make(chan int)            // 无缓冲 channel
ch2 := make(chan int, 10)       // 有缓冲 channel，容量 10
```

### 为什么 nil map 不能直接赋值

```go
var m map[string]int      // nil map
// m["key"] = 1           // ❌ panic：nil map 不能写入

m = make(map[string]int)  // ✅ 必须先初始化
m["key"] = 1

// 但 nil slice 可以 append
var s []int                // nil slice
s = append(s, 1)           // ✅ 可以（append 会自动初始化）
// s[0] = 1                // ❌ panic：nil slice 不能索引赋值
```

## new — 分配零值指针

```go
p := new(int)          // *int，值为 0
fmt.Println(*p)        // 0

// 等价于
var x int
p := &x
```

```go
type Person struct {
    Name string
    Age  int
}

p := new(Person)       // *Person，字段全为零值
p.Name = "Alice"       // 可以直接赋值（Go 自动解引用）
```

### new 不常用的情况

```go
// Go 风格更推荐直接取地址
p := &Person{}         // 等价于 new(Person)
p := &Person{Name: "Alice", Age: 30}  // 可以同时初始化字段
```

## 三种引用类型的零值与初始化

```go
// Slice
var s []int            // nil, len=0, cap=0, 不能索引
s = make([]int, 5)     // [0 0 0 0 0], len=5, cap=5
s = []int{}            // 非空构造，但一般不推荐（不预分配）

// Map
var m map[string]int   // nil，不能写入
m = make(map[string]int)      // 空的 map，可以写入
m = map[string]int{}          // ✅ 同上，字面量初始化

// Channel
var ch chan int        // nil，不能收发数据
ch = make(chan int)    // 无缓冲 channel
ch = make(chan int, 5) // 有缓冲 channel
```

## 典型使用场景

### 1. 预分配 Slice

```go
// 提前知道长度时
ids := make([]int, 1000)         // 分配 1000 个元素
for i := 0; i < 1000; i++ {
    ids[i] = i + 1
}

// 提前知道容量但不清楚长度时
buf := make([]byte, 0, 1024)     // 预分配 1024 字节，但 len=0
for i := 0; i < 100; i++ {
    buf = append(buf, byte(i))   // append 无需额外内存分配
}
```

### 2. 预分配 Map

```go
// 大数据量时预分配性能更好
users := make(map[int]User, 10000)
for i := 0; i < 10000; i++ {
    users[i] = fetchUser(i)
}
```

### 3. Channel 缓冲

```go
// 无缓冲：同步通信（发送者等待接收者）
ch := make(chan int)

// 有缓冲：异步通信（直到缓冲满才阻塞）
ch := make(chan int, 100)
```

## 常见误区

```go
// ❌ 用 new 创建 slice/map/channel
p := new([]int)         // 返回 *[]int，但内部不初始化
// append(*p, 1)        // 可以 append，因为 append 自动初始化
// (*p)[0] = 1          // ❌ panic：索引不可用

p := new(map[string]int) // 返回 *map[string]int，但 map 是 nil
// (*p)["key"] = 1       // ❌ panic：nil map

// ✅ 正确：用 make
s := make([]int, 0)
m := make(map[string]int)
ch := make(chan int)
```

## 总结速查

| 场景 | 用哪个 | 返回值 |
|------|--------|--------|
| 创建 slice/map/channel | `make` | 初始化好的类型本身 |
| 创建零值结构体指针 | `new` / `&T{}` | `*T` |
| 创建结构体并初始化字段 | `&T{Field: val}` | `*T` |
| 创建基本类型指针 | `new` | `*int`, `*bool` 等 |
| 零值初始化任意类型 | `new` | `*T`（零值） |

## 参考资料

- [Go Blog: make vs new](https://go.dev/doc/effective_go#allocation_new)
- [Go 内建函数文档](https://pkg.go.dev/builtin)
