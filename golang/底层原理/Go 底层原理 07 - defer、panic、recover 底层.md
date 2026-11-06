---
title: "Go 底层原理 07 - defer/panic/recover 底层"
date: 2026-06-13
tags:
  - golang
  - 底层原理
aliases:
  - "Go 底层原理 07"
---

# Go 底层原理 07 — defer/panic/recover 底层

## defer 底层结构

defer 语句在运行时由 `_defer` 结构体表示：

```go
type _defer struct {
    siz       int32       // 参数和结果的大小
    started   bool
    heap      bool        // true = 堆上分配，false = 栈上分配
    openDefer bool        // 是否经过开放编码优化
    sp        uintptr     // 栈指针
    pc        uintptr     // 程序计数器
    fn        *funcval    // 延迟调用的函数
    _panic    *_panic     // 关联的 panic
    link      *_defer     // defer 链表（LIFO）
}
```

### defer 链表

defer 以**链表**形式挂在 goroutine（`g._defer`）上：

```
goroutine g
┌──────────────────────┐
│ _defer → d3 → d2 → d1 │   ← 后进先出（LIFO）
└──────────────────────┘
```

```go
func example() {
    defer fmt.Println(1)  // d1（最后执行）
    defer fmt.Println(2)  // d2
    defer fmt.Println(3)  // d3（最先执行）
}
// 输出：3 2 1
```

## defer 的三种分配策略

Go 编译器根据复杂度选择 defer 的实现方式：

### 1. 开放编码（Open-coded defer）

Go 1.14+ 优化：defer 调用被直接内联，没有运行时开销。

**条件**：
- 函数中 defer 数量 ≤ 8
- 没有在循环中 defer
- 没有 recover
- 不是显式的 `defer func(){...}()` 的间接调用

```go
// 这种会被优化为开放编码
func example() {
    defer mu.Unlock()
    defer wg.Done()
    // 没有额外运行时开销
}
```

### 2. 栈上分配（Stack-allocated defer）

当 defer 数量 ≤ 8 但不符合开放编码条件时，`_defer` 在栈上分配。

### 3. 堆上分配（Heap-allocated defer）

循环中的 defer 或 defer 数量 > 8 时，`_defer` 在堆上分配。

```go
// 堆上分配
for i := 0; i < 10; i++ {
    defer func() { fmt.Println(i) }()
}
```

## 经典 defer 陷阱

### 1. 闭包引用

```go
// ❌ 输出：3 3 3
for i := 0; i < 3; i++ {
    defer func() {
        fmt.Println(i)  // 闭包引用 i 的地址
    }()
}

// ✅ 输出：2 1 0
for i := 0; i < 3; i++ {
    defer func(val int) {
        fmt.Println(val) // 值传递
    }(i)
}
```

### 2. defer 与 return 顺序

```go
func example() (result int) {
    defer func() {
        result++    // 3. 修改返回值
    }()
    return 1        // 2. result = 1
                    // 4. result = 2
}
// 返回 2
```

执行顺序：**return 赋值 → defer 执行 → 函数返回**

### 3. defer 与命名返回值

```go
func a() int {
    var i int
    defer func() {
        i++        // 修改的是局部变量 i
    }()
    return i       // 返回的是 i 的副本
}
// 返回 0

func b() (i int) {
    defer func() {
        i++        // 修改的是命名返回值 i
    }()
    return i       // 直接使用 i
}
// 返回 1
```

## panic 与 recover 机制

### panic 的执行流程

```go
func main() {
    defer func() {
        fmt.Println("defer 1")
    }()
    defer func() {
        fmt.Println("defer 2")
    }()
    panic("something went wrong")

    fmt.Println("unreachable") // 永远不会执行
}
// 输出：
// defer 2
// defer 1
// panic: something went wrong
```

### recover

```go
func safeCall() {
    defer func() {
        if r := recover(); r != nil {
            fmt.Println("recovered from:", r)
        }
    }()
    panic("oops")
}
// 输出：recovered from: oops
// 程序正常退出
```

### recover 必须在 defer 中直接调用

```go
// ❌ 无效：间接调用
defer func() {
    myRecover() // recover 不会生效
}()

func myRecover() {
    recover() // 不在 defer 中直接调用
}

// ✅ 有效：直接在 defer 函数体中调用
defer func() {
    recover()
}()
```

### panic 链

```go
func main() {
    defer func() {
        fmt.Println(recover()) // "b" — 最后一个 panic 被 recover
    }()
    defer func() {
        panic("a")  // 覆盖前一个 panic
    }()
    panic("b")
}
// 输出：b（最外层的 panic 被 recover）
// 因为 panic("a") 在 defer 中执行，覆盖了 panic("b")
```

### panic 链的完整流程

```
panic("b")
    ↓
执行 goroutine 的 defer 链表（LIFO）
    ↓
执行到 defer { panic("a") }
    ↓
栈展开中断，开始处理 panic("a")
    ↓
继续执行 defer 链表（当前函数剩余的 defer）
    ↓
执行到 defer { recover() }
    ↓
recover 捕获的是最新 panic("a")... 不对
实际上 recover 捕获的是最外层未 recover 的 panic
```

> 给简洁起见记住：**recover 捕获最近的未恢复 panic，如果有嵌套 panic 则最内层的生效**。

## 参考资料

- [Go Blog: Defer, Panic, and Recover](https://go.dev/blog/defer-panic-and-recover)
- [Go 源码：runtime/panic.go](https://github.com/golang/go/blob/master/src/runtime/panic.go)
- [Go defer 实现原理](https://tiancaiamao.gitbooks.io/go-internals/content/zh/03.4.html)
