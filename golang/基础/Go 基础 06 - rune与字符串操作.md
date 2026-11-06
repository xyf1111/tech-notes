---
title: "Go 基础 06 - rune与字符串操作"
date: 2021-02-16
tags:
  - golang
  - go基础
aliases:
  - "Go 基础 06"
  - "Go Study 06"
---

# Go 基础 06 - rune与字符串操作


## rune 是什么

`rune` 是 Go 中 **Unicode 码点（code point）** 的类型，本质是 `int32` 的别名：

```go
type rune = int32
```

- 一个 `rune` 可以表示任意 Unicode 字符
- 一个 UTF-8 编码的字符占用 **1~4 字节**
- ASCII 字符（如 `'A'`）占 1 字节，中文（如 `'世'`）占 3 字节

## 字符串的字节 vs 字符

```go
s := "Yes我是你爸爸!"

fmt.Println(len(s))                    // 19（字节数）
fmt.Println(utf8.RuneCountInString(s)) // 10（字符数，rune 数）

// 按字节遍历（不推荐）
for _, b := range []byte(s) {
    fmt.Printf("%X ", b)               // 59 65 73 E6 88 91 E6 98 AF E4 BD A0 E7 88 B8 E7 88 B8 21
}
fmt.Println()

// 按 rune 遍历（推荐）
for i, r := range s {
    fmt.Printf("(%d, %c) ", i, r)      // (0, Y) (1, e) (2, s) (3, 我) (6, 是) (9, 你) (12, 爸) (15, 爸) (18, !)
}
```

> **注意**：`range` 对字符串的遍历自动按 rune 解码，`i` 是字节偏移量，不是索引序号。

## 常用操作

### 字符串转 rune 切片

```go
s := "Hello, 世界"
runes := []rune(s)          // [72, 101, 108, 108, 111, 44, 32, 19990, 30028]
fmt.Println(len(runes))     // 9（字符数，不是字节数）
```

### 获取字符串中的某个字符

```go
s := "Hello, 世界"

// 错误的做法：按字节索引会乱码
fmt.Println(string(s[7]))   // 乱码（"世"占3字节，单字节取到的是中间字节）

// 正确的做法：转 rune 切片
runes := []rune(s)
fmt.Println(string(runes[7])) // "世"
```

### 反转包含中文的字符串

```go
func reverseRunes(s string) string {
    runes := []rune(s)
    for i, j := 0, len(runes)-1; i < j; i, j = i+1, j-1 {
        runes[i], runes[j] = runes[j], runes[i]
    }
    return string(runes)
}
```

### 统计字符数

```go
import "unicode/utf8"

s := "Hello, 世界"
fmt.Println(utf8.RuneCountInString(s)) // 9
```

## unicode/utf8 包

```go
import "unicode/utf8"

s := "世"

fmt.Println(utf8.RuneLen('世'))         // 3（编码需要 3 字节）
fmt.Println(utf8.ValidString(s))        // true（是否是合法 UTF-8）

// 手动解码
r, size := utf8.DecodeRuneInString(s)
fmt.Printf("%c (%d bytes)\n", r, size)  // 世 (3 bytes)

// 判断首字节
b := []byte(s)
fmt.Println(utf8.RuneStart(b[0]))       // true
fmt.Println(utf8.RuneStart(b[1]))       // false（后续字节）
```

## 字符类别判断

```go
import "unicode"

unicode.IsLetter('世')      // true
unicode.IsDigit('5')        // true
unicode.IsSpace(' ')        // true
unicode.IsUpper('A')        // true
unicode.ToLower('A')        // 97 ('a')
```

## 字符串性能

```go
// ❌ 低效：每次 + 创建新字符串
s := ""
for i := 0; i < 1000; i++ {
    s += "a"
}

// ✅ 高效：使用 Builder
var sb strings.Builder
sb.Grow(1000)
for i := 0; i < 1000; i++ {
    sb.WriteByte('a')
}
s := sb.String()

// ✅ 或者用 []byte
buf := make([]byte, 0, 1000)
for i := 0; i < 1000; i++ {
    buf = append(buf, 'a')
}
s := string(buf)
```

## 参考资料

- [Go Blog: Strings, bytes, runes and characters](https://go.dev/blog/strings)
- [unicode/utf8 包文档](https://pkg.go.dev/unicode/utf8)
