---
title: "Java 14 - NIO与序列化"
date: 2026-06-11
tags: [java, IO]
---

# Java 14 - NIO与序列化

## NIO (New IO, Java 1.4+)

Java NIO 是面向**缓冲区 (Buffer)** 和**通道 (Channel)** 的 IO 模型。

### 核心组件

| 组件 | 说明 |
|------|------|
| **Channel** | 双向通道，可读可写：FileChannel、SocketChannel、ServerSocketChannel |
| **Buffer** | 数据容器：ByteBuffer、CharBuffer、IntBuffer |
| **Selector** | 多路复用器，单线程管理多个 Channel |

### 核心优势

- **非阻塞 IO** — 线程不会在 read/write 上阻塞
- **零拷贝** — FileChannel.transferTo() 避免数据在用户态/内核态之间拷贝
- **内存映射文件** — MappedByteBuffer 可直接操作文件映射到内存的数据

### Buffer 常用操作

```java
ByteBuffer buffer = ByteBuffer.allocate(1024);
buffer.put(data);     // 写入数据
buffer.flip();        // 切换为读模式
buffer.get();         // 读取数据
buffer.clear();       // 清空缓冲区
buffer.rewind();      // 重读
```

### FileChannel 示例

```java
try (FileChannel in = FileChannel.open(Paths.get("src.txt"), StandardOpenOption.READ);
     FileChannel out = FileChannel.open(Paths.get("dest.txt"), 
         StandardOpenOption.CREATE, StandardOpenOption.WRITE)) {
    in.transferTo(0, in.size(), out);  // 零拷贝传输
}
```

### Selector 多路复用

```java
Selector selector = Selector.open();
channel.configureBlocking(false);
channel.register(selector, SelectionKey.OP_READ);

while (true) {
    selector.select();  // 阻塞直到有事件
    Set<SelectionKey> keys = selector.selectedKeys();
    for (SelectionKey key : keys) {
        if (key.isReadable()) { /* 读取 */ }
        if (key.isWritable()) { /* 写入 */ }
    }
    keys.clear();
}
```

## 序列化

### Serializable 接口

```java
public class User implements Serializable {
    private static final long serialVersionUID = 1L;
    private String name;
    private int age;
}
```

### 序列化与反序列化

```java
// 序列化
try (ObjectOutputStream oos = new ObjectOutputStream(
        new FileOutputStream("user.ser"))) {
    oos.writeObject(new User("Alice", 25));
}

// 反序列化
try (ObjectInputStream ois = new ObjectInputStream(
        new FileInputStream("user.ser"))) {
    User user = (User) ois.readObject();
}
```

### serialVersionUID

- 用于版本控制，确保序列化和反序列化使用同一个类版本
- 不显式声明则 JVM 自动生成，但类修改后自动生成值会变化
- **建议显式声明** `private static final long serialVersionUID = 1L;`
