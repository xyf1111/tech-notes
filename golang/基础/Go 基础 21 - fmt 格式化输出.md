---
title: "Go 基础 21 - fmt 格式化输出"
date: 2026-06-13
tags:
  - golang
  - go基础
aliases:
  - "Go 基础 21"
---

# Go 基础 21 - fmt 格式化输出

## 三大输出函数

| 函数 | 作用 | 换行 |
|------|------|------|
| `fmt.Print` | 输出到标准输出 | ❌ 不换行 |
| `fmt.Println` | 输出到标准输出 | ✅ 自动换行，参数间加空格 |
| `fmt.Printf` | 格式化输出 | ❌ 需手动加 `\n` |

```go
name := "Alice"
age := 30

fmt.Print("Hello")                          // "Hello"
fmt.Println("Hello", "World")               // "Hello World\n"
fmt.Printf("Name: %s, Age: %d\n", name, age) // "Name: Alice, Age: 30"
```

### 写入字符串

```go
s := fmt.Sprintf("Name: %s, Age: %d", name, age)
// s = "Name: Alice, Age: 30"
```

### 写入 io.Writer

```go
var buf bytes.Buffer
fmt.Fprintf(&buf, "Name: %s", name)
fmt.Fprintln(&buf, "extra")     // 追加 + 换行
```

## 常用格式化动词

### 通用

| 动词 | 作用 | 示例 |
|------|------|------|
| `%v` | 默认格式 | `fmt.Sprintf("%v", 42)` → `"42"` |
| `%+v` | 带字段名的结构体 | `{Name:Alice Age:30}` |
| `%#v` | Go 语法表示 | `main.Person{Name:"Alice", Age:30}` |
| `%T` | 类型 | `string`、`int` |
| `%%` | 百分号字面量 | `"%"` |

### 整数

| 动词 | 作用 | 示例（n=255） |
|------|------|------|
| `%d` | 十进制 | `"255"` |
| `%b` | 二进制 | `"11111111"` |
| `%o` | 八进制 | `"377"` |
| `%x` | 十六进制小写 | `"ff"` |
| `%X` | 十六进制大写 | `"FF"` |
| `%c` | 对应 Unicode 字符 | `'ÿ'` |
| `%q` | 带引号的字符 | `'ÿ'` |
| `%U` | Unicode 格式 | `U+00FF` |

### 浮点数

| 动词 | 作用 | 示例（n=3.14159） |
|------|------|------|
| `%f` | 固定小数位 | `"3.141590"` |
| `%.2f` | 指定小数位 | `"3.14"` |
| `%e` | 科学计数法 | `"3.141590e+00"` |
| `%g` | 按需选择 %e 或 %f | `"3.14159"`（去掉尾随零） |

### 字符串

| 动词 | 作用 | 示例 |
|------|------|------|
| `%s` | 字符串 | `"hello"` |
| `%q` | 带引号字符串 | `"\"hello\""` |
| `%x` | 十六进制编码 | `"68656c6c6f"` |
| `%10s` | 宽度 10（右对齐） | `"     hello"` |
| `%-10s` | 宽度 10（左对齐） | `"hello     "` |
| `%.5s` | 截断 5 个字符 | `"hello"` |

## 宽度与精度

```go
// 宽度与对齐
fmt.Printf("|%10s|", "hello")    // "|     hello|"（宽度 10，右对齐）
fmt.Printf("|%-10s|", "hello")   // "|hello     |"（宽度 10，左对齐）

// 精度
fmt.Printf("%.2f", 3.14159)      // "3.14"
fmt.Printf("%8.2f", 3.14159)     // "    3.14"（宽度 8，精度 2）

// 数字补零
fmt.Printf("%05d", 42)           // "00042"（宽度 5，补零）
```

## 结构体格式化

```go
type Person struct {
    Name string
    Age  int
}

p := Person{"Alice", 30}

fmt.Printf("%%v:  %v\n", p)    // {Alice 30}
fmt.Printf("%%+v: %+v\n", p)   // {Name:Alice Age:30}
fmt.Printf("%%#v: %#v\n", p)   // main.Person{Name:"Alice", Age:30}
fmt.Printf("%%T:  %T\n", p)    // main.Person
```

## 错误格式化

```go
// fmt.Errorf 创建格式化错误
err := fmt.Errorf("user %s not found", "Alice")
// err.Error() = "user Alice not found"

// 错误链（Go 1.20+）
err = fmt.Errorf("login failed: %w", err)
// errors.Is(err, originalErr) // true
```

## 实现 Stringer 接口

自定义类型的默认格式化通过实现 `String()` 方法控制：

```go
type Point struct{ X, Y int }

func (p Point) String() string {
    return fmt.Sprintf("(%d, %d)", p.X, p.Y)
}

p := Point{3, 4}
fmt.Println(p)          // "(3, 4)"（自动调用 String()）
fmt.Printf("%v", p)     // "(3, 4)"
fmt.Printf("%#v", p)    // "main.Point{X:3, Y:4}"（Stringer 不影响 %#v）
```

## 格式化注意事项

### 性能对比

```go
// 慢：fmt.Sprintf（涉及反射）
result := fmt.Sprintf("%s-%d", name, age)

// 快：strings.Builder
var sb strings.Builder
sb.WriteString(name)
sb.WriteByte('-')
sb.WriteString(strconv.Itoa(age))

// 更快（已知容量时）
sb.Grow(len(name) + 1 + 10)  // 预分配
```

### 循环中避免反复格式化

```go
// ❌ 慢：每次迭代都格式化
for _, v := range items {
    fmt.Printf("Item: %s\n", v)
}

// ✅ 快：用 strings.Builder 拼接后一次性输出
var sb strings.Builder
for _, v := range items {
    fmt.Fprintf(&sb, "Item: %s\n", v)
}
fmt.Print(sb.String())
```

## 参考资料

- [Go fmt 包文档](https://pkg.go.dev/fmt)
- [Go by Example: String Formatting](https://gobyexample.com/string-formatting)
- [Effective Go: Formatting](https://go.dev/doc/effective_go#formatting)
