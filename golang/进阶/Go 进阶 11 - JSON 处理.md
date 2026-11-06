---
title: "Go 进阶 11 - JSON 处理"
date: 2026-06-13
tags:
  - golang
  - 进阶
aliases:
  - "Go 进阶 11"
---

# Go 进阶 11 — JSON 处理

## encoding/json 基础

```go
import "encoding/json"

type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email,omitempty"`  // 空值时忽略
    Role  string `json:"-"`               // 忽略该字段
}
```

### Marshal（序列化）

```go
u := User{ID: 1, Name: "Alice", Email: "alice@example.com", Role: "admin"}

// 到 []byte
bytes, err := json.Marshal(u)
// bytes = {"id":1,"name":"Alice","email":"alice@example.com"}

// 格式化输出
bytes, err := json.MarshalIndent(u, "", "  ")
// {
//   "id": 1,
//   "name": "Alice",
//   "email": "alice@example.com"
// }
```

### Unmarshal（反序列化）

```go
data := []byte(`{"id":1,"name":"Alice"}`)

var u User
if err := json.Unmarshal(data, &u); err != nil {
    // 处理错误
}
fmt.Println(u.Name) // "Alice"
```

## Struct Tag 详解

```go
type Config struct {
    // 重命名字段
    ServerName string `json:"server_name"`

    // 空值时忽略
    Description string `json:"description,omitempty"`

    // 忽略该字段
    SecretKey string `json:"-"`

    // 字符串转数字
    Port int `json:"port,string"`  // `"port": "8080"` → Port = 8080

    // 强制数字/布尔作为字符串
    Enabled bool `json:"enabled,string"`  // `"enabled": "true"`

    // 嵌入字段展平
    Base
    // 嵌套对象
    Extra ExtraConfig `json:"extra"`
}

type Base struct {
    Version string `json:"version"`
}

// 输出展平版本字段
// {"server_name":"...", "version":"1.0", "extra":{...}}
```

## 动态 JSON

### interface{} 处理

```go
var data interface{}
json.Unmarshal([]byte(`{"name":"Alice","age":30}`), &data)

m := data.(map[string]interface{})
name := m["name"].(string)  // "Alice"
age := m["age"].(float64)   // JSON 数字默认解析为 float64
```

### json.RawMessage — 延迟解析

```go
type Response struct {
    Code    int              `json:"code"`
    Message string           `json:"message"`
    Data    json.RawMessage  `json:"data"`  // 暂不解析
}

// 先解析外层，再根据类型解析 Data
var resp Response
json.Unmarshal(bytes, &resp)

switch {
case resp.Code == 200:
    var users []User
    json.Unmarshal(resp.Data, &users)
}
```

### json.Decoder — 流式读取

```go
// 适合大文件/HTTP 流
file, _ := os.Open("large.json")
defer file.Close()

decoder := json.NewDecoder(file)
for {
    var user User
    if err := decoder.Decode(&user); err == io.EOF {
        break
    } else if err != nil {
        log.Fatal(err)
    }
    fmt.Println(user.Name)
}
```

## 自定义 Marshal/Unmarshal

```go
type Duration time.Duration

// 自定义序列化：纳秒 → 可读字符串
func (d Duration) MarshalJSON() ([]byte, error) {
    return json.Marshal(time.Duration(d).String())
}

// 自定义反序列化：字符串 → 纳秒
func (d *Duration) UnmarshalJSON(b []byte) error {
    var s string
    if err := json.Unmarshal(b, &s); err != nil {
        return err
    }
    dur, err := time.ParseDuration(s)
    if err != nil {
        return err
    }
    *d = Duration(dur)
    return nil
}
```

## 性能优化

### 预分配

```go
// ❌ 慢：反复扩容
var buf bytes.Buffer
encoder := json.NewEncoder(&buf)
for _, u := range users {
    encoder.Encode(u)
}

// ✅ 快：预分配
buf := bytes.NewBuffer(make([]byte, 0, len(users)*100))  // 估算大小
```

### 编码器复用

```go
// 复用 Encoder
var bufPool = sync.Pool{
    New: func() interface{} {
        return &bytes.Buffer{}
    },
}

buf := bufPool.Get().(*bytes.Buffer)
buf.Reset()
json.NewEncoder(buf).Encode(data)
```

### 第三方库对比

| 库 | 速度 | 特点 |
|----|------|------|
| `encoding/json` | 标准 | 反射、通用、兼容性好 |
| `jsoniter` | 快 3-5x | 兼容 encoding/json API |
| `sonic` | 快 5-10x | 基于 JIT（Go 1.17+） |
| `easyjson` | 快 10x+ | 代码生成，支持差 |

```go
// jsoniter 使用（API 兼容）
import jsoniter "github.com/json-iterator/go"

var json = jsoniter.ConfigCompatibleWithStandardLibrary
json.Marshal(&data)
```

## 参考资料

- [Go encoding/json 文档](https://pkg.go.dev/encoding/json)
- [Go Blog: JSON and Go](https://go.dev/blog/json)
- [sonic — 字节跳动 JSON 库](https://github.com/bytedance/sonic)
- [jsoniter](https://github.com/json-iterator/go)
