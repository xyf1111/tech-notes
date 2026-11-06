---
title: "Go 基础 20 - time 时间处理"
date: 2026-06-13
tags:
  - golang
  - go基础
aliases:
  - "Go 基础 20"
---

# Go 基础 20 - time 时间处理

## time.Time — 时间点

```go
import "time"

now := time.Now()                    // 当前本地时间
utc := time.Now().UTC()              // 当前 UTC 时间
```

### 构造时间

```go
// 指定年月日时分秒
t := time.Date(2024, time.January, 15, 10, 30, 0, 0, time.UTC)

// 从 Unix 时间戳
t := time.Unix(1705300000, 0)        // 秒级
t := time.UnixMilli(1705300000000)   // 毫秒级
t := time.UnixMicro(1705300000000000) // 微秒级
```

### 获取时间分量

```go
t := time.Now()

t.Year()        // 2024
t.Month()       // January（time.Month 类型）
t.Day()         // 15
t.Weekday()     // Monday（time.Weekday 类型）
t.YearDay()     // 年内的第几天（1-366）
t.Hour()        // 10
t.Minute()      // 30
t.Second()      // 0
t.Nanosecond()  // 纳秒
```

## 时间格式化（2006-01-02）

Go 使用**参考时间** `Mon Jan 2 15:04:05 MST 2006` 格式化，不是 `YYYY-MM-DD`：

```go
t := time.Now()

// 常用格式
t.Format("2006-01-02")                     // "2024-01-15"
t.Format("2006-01-02 15:04:05")            // "2024-01-15 10:30:00"
t.Format("15:04:05")                       // "10:30:00"

// 中文友好
t.Format("2006年01月02日")                  // "2024年01月15日"
t.Format("2006-01-02 15:04:05 Monday")     // "2024-01-15 10:30:00 Monday"

// 紧凑
t.Format("20060102150405")                 // "20240115103000"（适合文件名）

// 解析字符串
t, _ := time.Parse("2006-01-02", "2024-01-15")
t, _ := time.Parse("2006-01-02 15:04:05", "2024-01-15 10:30:00")
```

### 时间比较

```go
t1 := time.Date(2024, 1, 15, 0, 0, 0, 0, time.UTC)
t2 := time.Date(2024, 2, 15, 0, 0, 0, 0, time.UTC)

t1.Before(t2)    // true
t2.After(t1)     // true
t1.Equal(t2)     // false
```

## Duration — 时间间隔

`time.Duration` 本质是 `int64`（纳秒）：

```go
// 常量
const (
    Nanosecond  Duration = 1
    Microsecond          = 1000 * Nanosecond
    Millisecond          = 1000 * Microsecond
    Second               = 1000 * Millisecond
    Minute               = 60 * Second
    Hour                 = 60 * Minute
)

// 构造
d := 5 * time.Second + 500 * time.Millisecond  // 5.5s
d2 := time.Duration(1000000000)                 // 1s

// 解析字符串
d, _ := time.ParseDuration("1h30m")    // 1h30m
d, _ := time.ParseDuration("500ms")    // 500ms
d, _ := time.ParseDuration("2.5s")     // 2.5s
d, _ := time.ParseDuration("1m30s")   // 1m30s
```

### Duration 运算

```go
t := time.Now()

future := t.Add(2 * time.Hour)          // 加 2 小时
past := t.Add(-30 * time.Minute)        // 减 30 分钟

diff := future.Sub(t)                   // 2h0m0s（time.Duration）
fmt.Println(diff.Hours())               // 2（小数）
fmt.Println(diff.Minutes())             // 120
fmt.Println(diff.Seconds())             // 7200
fmt.Println(diff.Milliseconds())        // 7200000

since := time.Since(t)                  // 从 t 到现在的间隔
until := time.Until(future)             // 从现在到 future 的间隔
```

## 定时器

### time.Sleep

```go
time.Sleep(2 * time.Second)      // 阻塞 2 秒
time.Sleep(100 * time.Millisecond) // 阻塞 100ms
```

### time.Ticker（周期性定时器）

```go
ticker := time.NewTicker(1 * time.Second)
defer ticker.Stop()

for i := 0; i < 5; i++ {
    <-ticker.C      // 每秒收到一个信号
    fmt.Println("tick", i)
}
```

### time.Timer（单次定时器）

```go
// 方式 1：NewTimer
timer := time.NewTimer(2 * time.Second)
<-timer.C          // 等待 2 秒
timer.Stop()       // 提前取消（返回 false 表示已经超时）

// 方式 2：After（更简洁，但不支持 Stop）
<-time.After(2 * time.Second)

// 方式 3：AfterFunc（回调模式）
timer := time.AfterFunc(2*time.Second, func() {
    fmt.Println("2 seconds passed")
})
// timer.Stop() 可以取消
```

## 超时控制

```go
// 带超时的 channel 操作
ch := make(chan int)

select {
case result := <-ch:
    fmt.Println("received:", result)
case <-time.After(5 * time.Second):
    fmt.Println("timeout after 5s")
}
```

## 时区处理

```go
// 加载时区
loc, _ := time.LoadLocation("America/New_York")
t := time.Now().In(loc)

// 不同时区的时间
now := time.Now()
utc := now.UTC()
ny, _ := time.LoadLocation("America/New_York")
nyTime := now.In(ny)

// 固定时区偏移（适合无 IANA 时区数据库的环境）
cst := time.FixedZone("CST", 8*3600)  // 东八区
t := time.Now().In(cst)
```

## 计时

```go
start := time.Now()

// ... 执行任务 ...

elapsed := time.Since(start)
fmt.Printf("took %v\n", elapsed)           // "took 1.234s"

// 高精度计时
fmt.Printf("took %d ns\n", elapsed.Nanoseconds())
fmt.Printf("took %.3f ms\n", float64(elapsed.Microseconds())/1000)
```

## 参考资料

- [Go time 包文档](https://pkg.go.dev/time)
- [Go by Example: Time](https://gobyexample.com/time)
- [Go 时间格式化](https://go.dev/src/time/format.go)
