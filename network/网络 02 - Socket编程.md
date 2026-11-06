---
title: "网络 02 - Socket编程"
date: 2021-02-14
tags: [网络]
---

# 网络 02 - Socket 编程

## Socket 概念

在 TCP/IP 协议中，**"IP 地址 + 端口号"**唯一标识网络中一个进程，这个组合即为一个 **Socket**。

- Socket 是网络通信的端点（Endpoint）
- 通信双方各有一个 Socket，形成 **Socket Pair** 唯一标识一个连接
- 对应用程序来说，Socket 是一个**文件描述符**，可通过 read/write 操作数据

> 在网络通信中，套接字一定是成对出现的。一端的发送缓冲区对应另一端的接收缓冲区。

## 网络字节序

- **大端序（Big-Endian）** — 高位字节存低地址（网络字节序）
- **小端序（Little-Endian）** — 低位字节存低地址（x86 架构）

```c
// 主机字节序 ↔ 网络字节序
htonl() / htons()   // 主机→网络 (long/short)
ntohl() / ntohs()   // 网络→主机 (long/short)
```

## IP 地址转换

```c
inet_pton(AF_INET, "192.168.1.1", &addr);   // 文本→二进制
inet_ntop(AF_INET, &addr, buf, sizeof(buf)); // 二进制→文本
```

## TCP Socket 通信流程

### 服务端

```
socket()  →  bind()  →  listen()  →  accept()  →  read()/write()  →  close()
```

### 客户端

```
socket()  →  connect()  →  write()/read()  →  close()
```

### 各函数说明

| 函数 | 作用 |
|------|------|
| `socket()` | 创建套接字，返回文件描述符 |
| `bind()` | 绑定 IP 和端口 |
| `listen()` | 设置监听状态，指定最大连接数 |
| `accept()` | 阻塞等待客户端连接，返回新 socket |
| `connect()` | 客户端发起连接请求 |
| `send()/recv()` | 收发数据 |
| `close()` | 关闭连接（触发四次挥手） |

## TCP 状态转换

```
CLOSED → SYN_SENT → ESTABLISHED → FIN_WAIT_1 → FIN_WAIT_2 → TIME_WAIT → CLOSED
CLOSED → LISTEN → SYN_RCVD → ESTABLISHED → CLOSE_WAIT → LAST_ACK → CLOSED
```
