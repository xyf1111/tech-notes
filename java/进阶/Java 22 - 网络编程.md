---
title: "Java 22 - 网络编程"
date: 2026-06-11
tags: [java, 进阶]
---

# Java 22 - 网络编程

## 网络编程基础

### InetAddress

```java
InetAddress address = InetAddress.getByName("www.example.com");
address.getHostName();    // 主机名
address.getHostAddress(); // IP 地址
address.isReachable(5000); // 是否可达
```

## Socket 编程

### TCP 客户端-服务端

**服务端：**
```java
ServerSocket server = new ServerSocket(8080);
System.out.println("服务端启动，等待连接...");
Socket socket = server.accept();  // 阻塞等待客户端连接

BufferedReader in = new BufferedReader(
    new InputStreamReader(socket.getInputStream()));
PrintWriter out = new PrintWriter(socket.getOutputStream(), true);

String msg = in.readLine();
System.out.println("收到: " + msg);
out.println("已收到: " + msg);

socket.close();
server.close();
```

**客户端：**
```java
Socket socket = new Socket("localhost", 8080);

PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
BufferedReader in = new BufferedReader(
    new InputStreamReader(socket.getInputStream()));

out.println("Hello Server");
String response = in.readLine();
System.out.println("服务端响应: " + response);

socket.close();
```

### UDP 通信

**服务端：**
```java
DatagramSocket socket = new DatagramSocket(9090);
byte[] buf = new byte[1024];
DatagramPacket packet = new DatagramPacket(buf, buf.length);
socket.receive(packet);
String msg = new String(packet.getData(), 0, packet.getLength());
System.out.println("收到: " + msg);
```

**客户端：**
```java
DatagramSocket socket = new DatagramSocket();
String msg = "Hello UDP";
DatagramPacket packet = new DatagramPacket(
    msg.getBytes(), msg.length(), InetAddress.getByName("localhost"), 9090);
socket.send(packet);
```

## URL 与 URLConnection

```java
URL url = new URL("https://api.example.com/data");
HttpURLConnection conn = (HttpURLConnection) url.openConnection();
conn.setRequestMethod("GET");
conn.setConnectTimeout(5000);

int code = conn.getResponseCode();
BufferedReader in = new BufferedReader(
    new InputStreamReader(conn.getInputStream()));
String line;
while ((line = in.readLine()) != null) {
    System.out.println(line);
}
```

> 现代应用推荐使用 **OkHttp** 或 **WebClient (Spring WebFlux)** 替代原生 URLConnection。

## NIO 网络编程

详见 [[java/IO/Java 14 - NIO与序列化]] 的 Selector 多路复用部分。
