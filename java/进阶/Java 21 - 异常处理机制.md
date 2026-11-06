---
title: "Java 21 - 异常处理机制"
date: 2026-06-11
tags: [java, 进阶]
---

# Java 21 - 异常处理机制

## Java 异常体系

```
Throwable
├── Error（不可恢复，程序不应捕获）
│   ├── OutOfMemoryError
│   ├── StackOverflowError
│   └── NoClassDefFoundError
└── Exception（可恢复，程序应处理）
    ├── RuntimeException（非检查异常）
    │   ├── NullPointerException
    │   ├── ArrayIndexOutOfBoundsException
    │   ├── ClassCastException
    │   ├── IllegalArgumentException
    │   └── ArithmeticException
    └── 检查异常 (Checked Exception)
        ├── IOException
        ├── SQLException
        ├── ClassNotFoundException
        └── FileNotFoundException
```

## 检查异常 vs 非检查异常

| 类型 | 检查异常 | 非检查异常 (RuntimeException) |
|------|----------|------------------------------|
| 编译检查 | ✔ 必须处理或声明 | ❌ 不强制 |
| 继承 | Exception（非 RuntimeException 子类） | RuntimeException 子类 |
| 常见 | IOException、SQLException | NullPointerException、IndexOutOfBounds |
| 处理 | try-catch 或 throws | 建议避免，不强制处理 |

## 异常处理方式

### try-catch-finally

```java
try {
    // 可能抛出异常的代码
    FileReader fr = new FileReader("file.txt");
} catch (FileNotFoundException e) {
    // 处理特定异常
    System.err.println("文件不存在: " + e.getMessage());
} catch (IOException e) {
    // 处理 IO 异常
    e.printStackTrace();
} finally {
    // 无论是否异常都执行（关闭资源等）
    System.out.println("清理资源");
}
```

### try-with-resources（Java 7+）

自动关闭实现了 `AutoCloseable` 的资源：
```java
try (FileReader fr = new FileReader("file.txt");
     BufferedReader br = new BufferedReader(fr)) {
    String line = br.readLine();
} catch (IOException e) {
    e.printStackTrace();
}  // 自动关闭 fr 和 br
```

### throws / throw

```java
// throws — 声明方法可能抛出的异常
public void readFile(String path) throws IOException {
    // 不在此处理，交由调用者处理
}

// throw — 主动抛出异常
public void validateAge(int age) {
    if (age < 0) {
        throw new IllegalArgumentException("年龄不能为负数");
    }
}
```

## 最佳实践

1. **不捕获** `Error`（OOM、StackOverflow 等不可恢复）
2. **不吞异常** — catch 后要有实际处理或记录日志
3. **精准catch** — 不要只写 `catch (Exception e)`
4. **先具体后通用** — 子类异常 catch 在前，父类在后
5. **使用自定义异常** — 继承 Exception 或 RuntimeException
6. **finally 中不要 return** — 会覆盖 try/catch 中的返回值
