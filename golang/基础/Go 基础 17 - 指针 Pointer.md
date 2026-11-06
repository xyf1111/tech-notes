---
title: "Go 基础 17 - 指针 Pointer"
date: 2026-06-13
tags:
  - golang
  - go基础
aliases:
  - "Go 基础 17"
---

# Go 基础 17 - 指针 Pointer

## 指针概述

Go 有指针，但**没有指针运算**（不像 C/C++）。指针保存变量的内存地址。

| 操作符 | 作用 | 示例 |
|--------|------|------|
| `&` | 取地址 | `p := &x` |
| `*` | 解引用 | `v := *p` |

## 基本用法

```go
x := 42
p := &x          // p 是指向 x 的指针（*int 类型）

fmt.Println(p)   // 0xc0000b2008（内存地址）
fmt.Println(*p)  // 42（解引用获取值）

*p = 21           // 通过指针修改 x
fmt.Println(x)   // 21（x 被修改了）
```

## 指针的零值与 nil

```go
var p *int          // nil（指针的零值）
fmt.Println(p)      // <nil>

if p != nil {
    fmt.Println(*p) // 安全：只有非 nil 才解引用
}

// 解引用 nil 指针会 panic
// fmt.Println(*p)  // panic: runtime error: invalid memory address
```

## 值传递 vs 引用传递

Go **所有参数都是值传递**，但指针参数可以修改原值：

```go
// 值传递：不修改原值
func zeroVal(val int) {
    val = 0
}

// 指针传递：修改原值
func zeroPtr(ptr *int) {
    *ptr = 0
}

x := 5
zeroVal(x)
fmt.Println(x)   // 5（未被修改）

zeroPtr(&x)
fmt.Println(x)   // 0（被修改）
```

## 指针作为函数参数

```go
func swap(a, b *int) {
    *a, *b = *b, *a
}

x, y := 1, 2
swap(&x, &y)
fmt.Println(x, y) // 2 1
```

## 指针接收者（Methods）

```go
type Counter struct {
    value int
}

// 值接收者：不会修改原对象
func (c Counter) Increment() {
    c.value++
}

// 指针接收者：修改原对象
func (c *Counter) RealIncrement() {
    c.value++
}

c := Counter{value: 0}
c.Increment()
fmt.Println(c.value)      // 0（未修改）

c.RealIncrement()
fmt.Println(c.value)      // 1（已修改）
```

### 何时用指针接收者

1. **需要修改接收者时** — `func (s *Struct) SetX(val int)`
2. **接收者是大结构体时** — 避免拷贝开销
3. **保持一致性** — 如果某个方法用了指针接收者，其他方法也应该用

## 指针与切片/映射

```go
// 切片和映射本身就是引用类型，很少需要 *[]int
// 但修改切片长度时需要指针
func appendToSlice(s *[]int, vals ...int) {
    *s = append(*s, vals...)
}

nums := []int{1, 2}
appendToSlice(&nums, 3, 4)
fmt.Println(nums) // [1 2 3 4]
```

## new 函数

`new(T)` 分配零值并返回指针：

```go
p := new(int)       // *int，值为 0
fmt.Println(*p)     // 0
*p = 42
fmt.Println(*p)     // 42

// 等价于
var x int
p := &x
```

## 常见陷阱

### 1. 循环中取变量地址

```go
// ❌ 错误：所有指针指向同一个变量
var ptrs []*int
for _, v := range []int{1, 2, 3} {
    ptrs = append(ptrs, &v)  // 每次取的是同一个 v 的地址
}
// ptrs 全部指向 3

// ✅ 正确：每次创建新变量
for _, v := range []int{1, 2, 3} {
    v := v  // 创建副本
    ptrs = append(ptrs, &v)
}
```

### 2. 返回局部变量地址是安全的

```go
// Go 编译器会自动进行逃逸分析（escape analysis）
func newCounter() *Counter {
    c := Counter{value: 0}
    return &c      // 安全：Go 自动在堆上分配
}
```

## 总结

| 场景 | 用值 | 用指针 |
|------|------|--------|
| 不修改原值 | ✅ 值传递 | ❌ |
| 修改原值 | ❌ | ✅ 指针参数/接收者 |
| 大结构体 | ❌ 拷贝开销大 | ✅ 避免拷贝 |
| nil 安全性 | ✅ 不会是 nil | ❌ 需要判 nil |
| 永远不变的类型（int, bool） | ✅ | ❌ 没必要 |

## 参考资料

- [Go Blog: Pointers vs. Values](https://go.dev/doc/effective_go#pointers_vs_values)
- [Go by Example: Pointers](https://gobyexample.com/pointers)
