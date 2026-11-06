---
title: "Go 底层原理 10 - make 与 new 底层实现"
date: 2026-06-13
tags:
  - golang
  - 底层原理
aliases:
  - "Go 底层原理 10"
---

# Go 底层原理 10 — make 与 new 底层实现

## 编译器如何处理

`make` 和 `new` 都是 Go 的**内建函数**，但编译器对它们的处理完全不同：

```go
// make 由编译器根据类型转换为不同的运行时函数
make([]int, 5)         → runtime.makeslice
make(map[string]int)   → runtime.makemap
make(chan int, 10)     → runtime.makechan

// new 由编译器转换为 runtime.newobject
new(int)               → runtime.newobject
new(MyStruct)          → runtime.newobject
```

## makeslice 底层

```go
// runtime/slice.go
func makeslice(et *_type, len, cap int) unsafe.Pointer {
    // 1. 检查是否溢出
    mem, overflow := math.MulUintptr(et.size, uintptr(cap))
    if overflow || mem > maxAlloc || len < 0 || len > cap {
        panicmakeslicelen()  // panic: makeslice: len out of range
    }

    // 2. 分配内存（调用 mallocgc）
    return mallocgc(mem, et, true)
}
```

### slice 内存分配

```go
// 预分配 vs 动态追加
s1 := make([]int, 1000, 1000)   // 一次分配 8000 字节
var s2 []int                     // nil slice
for i := 0; i < 1000; i++ {
    s2 = append(s2, i)          // 多次扩容，多次分配
}
```

### 容量计算

```go
// 扩容策略（growslice）
// 1. 期望容量 < 256：翻倍
// 2. 期望容量 ≥ 256：增加 (cap+3*256)/4
// 3. 最后根据元素大小对齐（roundupsize）

// 实际分配的内存可能比请求的大（对齐到 2 的幂次页大小）
```

## makemap 底层

```go
// runtime/map.go
func makemap(t *maptype, hint int, h *hmap) *hmap {
    // 1. 计算需要的桶数
    // B = ceil(log2(hint / 8))  // 每个桶 8 个槽位
    // 如果 hint == 0，B = 0

    // 2. 分配 bucket 数组
    // buckets = make([]bmap, 1 << B)

    // 3. 返回 hmap 指针
    return &hmap{...}
}
```

### hmap 结构

```go
type hmap struct {
    count     int              // 元素数量
    flags     uint8            // 状态标志
    B         uint8            // 桶数量的对数（len(buckets) = 2^B）
    noverflow uint16           // 溢出桶数量
    hash0     uint32           // 哈希种子

    buckets    unsafe.Pointer   // 桶数组（2^B 个）
    oldbuckets unsafe.Pointer   // 扩容时的旧桶
    nevacuate  uintptr          // 扩容迁移进度

    extra *mapextra             // 溢出桶
}
```

### 负载因子与触发扩容

```go
// 负载因子 = count / 2^B
// 当负载因子 > 6.5 时触发增量扩容
const loadFactorNum = 13
const loadFactorDen = 2

// 扩容后 B++
// 不是一次性迁移，每次写操作迁移 2 个桶
```

## makechan 底层

```go
// runtime/chan.go
func makechan(t *chantype, size int) *hchan {
    var c *hchan
    switch {
    case size == 0:
        // 无缓冲 channel——只分配 hchan 本身
        c = (*hchan)(mallocgc(hchanSize, nil, true))
    case elem.kind&kindNoPointers != 0:
        // 元素不含指针——hchan + 环形缓冲区一次性分配
        c = (*hchan)(mallocgc(hchanSize+uintptr(size)*elem.size, nil, true))
    default:
        // 元素含指针——hchan 和缓冲区分开分配
        c = new(hchan)
        c.buf = mallocgc(uintptr(size)*elem.size, elem, true)
    }
    c.elemsize = uint16(elem.size)
    c.elemtype = elem
    c.dataqsiz = uint(size)
    return c
}
```

### hchan 结构

```go
type hchan struct {
    qcount   uint           // 队列中元素个数
    dataqsiz uint           // 环形队列大小（缓冲区容量）
    buf      unsafe.Pointer // 环形缓冲区指针
    elemsize uint16         // 元素大小
    closed   uint32         // 是否关闭
    elemtype *_type         // 元素类型
    sendx    uint           // 发送索引
    recvx    uint           // 接收索引
    recvq    waitq          // 接收等待队列
    sendq    waitq          // 发送等待队列
    lock     mutex          // 锁
}
```

## newobject 底层

```go
// runtime/malloc.go
func newobject(typ *_type) unsafe.Pointer {
    return mallocgc(typ.size, typ, true)
}

// 等价于
p := new(T)
// 编译器将其转换为
p := (T*)(runtime.newobject(typeOf(T)))
// 然后赋零值
*p = zero(T)
```

## make vs new 总结

| 对比 | make | new |
|------|------|-----|
| 编译器处理 | 转为 `makeslice/makemap/makechan` | 转为 `newobject` |
| 运行时函数 | `runtime.makeslice/makemap/makechan` | `runtime.mallocgc` |
| 返回值 | 已初始化的引用类型 | 零值指针 |
| 内存 | 初始化内部数据结构 + 分配缓冲区 | 只分配零值内存 |
| 适用类型 | slice, map, channel | 任意类型 |

## 参考资料

- [Go 源码：runtime/slice.go](https://github.com/golang/go/blob/master/src/runtime/slice.go)
- [Go 源码：runtime/map.go](https://github.com/golang/go/blob/master/src/runtime/map.go)
- [Go 源码：runtime/chan.go](https://github.com/golang/go/blob/master/src/runtime/chan.go)
- [Go 源码：runtime/malloc.go](https://github.com/golang/go/blob/master/src/runtime/malloc.go)
