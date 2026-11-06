---
title: "Java 13 - File与IO流"
date: 2026-06-11
tags: [java, IO]
---

# Java 13 - File与IO流

## File 类

`java.io.File` 表示文件或目录路径的抽象表示。

```java
File file = new File("/path/to/file.txt");
file.exists();       // 是否存在
file.isFile();       // 是否文件
file.isDirectory();  // 是否目录
file.getName();      // 文件名
file.length();       // 文件大小
file.mkdirs();       // 创建目录
file.createNewFile(); // 创建文件
file.delete();       // 删除
```

## IO 流分类

按流向：
- **输入流** — 读取数据（读入内存）
- **输出流** — 写入数据（写出到目的地）

按数据类型：
- **字节流** — 处理二进制文件（图片、视频等）
- **字符流** — 处理文本文件（.txt、.java 等）

## 字节流

| 抽象类 | 输入 | 输出 | 说明 |
|--------|------|------|------|
| `InputStream` | `FileInputStream` | `FileOutputStream` | 文件字节流 |
| `BufferedInputStream` | `BufferedInputStream` | `BufferedOutputStream` | 缓冲字节流 |

```java
// 文件复制：字节流
try (FileInputStream fis = new FileInputStream("src.jpg");
     FileOutputStream fos = new FileOutputStream("dest.jpg")) {
    byte[] buffer = new byte[1024];
    int len;
    while ((len = fis.read(buffer)) != -1) {
        fos.write(buffer, 0, len);
    }
}
```

## 字符流

| 抽象类 | 输入 | 输出 | 说明 |
|--------|------|------|------|
| `Reader` | `FileReader` | `FileWriter` | 文件字符流 |
| `BufferedReader` | `BufferedReader` | `BufferedWriter` | 缓冲字符流 |
| `InputStreamReader` | 字节→字符转换 | — | 解码 |
| `OutputStreamWriter` | — | 字符→字节转换 | 编码 |

```java
// 文本读取：字符流（推荐）
try (BufferedReader br = new BufferedReader(new FileReader("input.txt"))) {
    String line;
    while ((line = br.readLine()) != null) {
        System.out.println(line);
    }
}
```

## try-with-resources (Java 7+)

自动关闭实现了 `AutoCloseable` 的资源：
```java
try (FileInputStream fis = new FileInputStream("file.txt")) {
    // 使用 fis
}  // 自动调用 fis.close()
```

## 序列化与 transient

- `Serializable` 接口 — 标记对象可序列化
- `transient` — 修饰的字段不参与序列化

```java
public class User implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
    private transient String password;  // 不序列化
}
```
