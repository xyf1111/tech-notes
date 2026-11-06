---
title: "网络 06 - UDP与DNS"
date: 2026-06-11
tags: [网络]
---

# 网络 06 - UDP 与 DNS

## UDP 协议

### UDP 特点

| 特性 | 说明 |
|------|------|
| **无连接** | 不需要握手，直接发送数据 |
| **不可靠** | 不保证到达，不保证顺序 |
| **面向报文** | 保留报文边界，不拆分合并 |
| **低延迟** | 没有确认重传机制，延迟低 |
| **支持广播/组播** | TCP 不支持 |

### UDP 报文头（固定 8 字节）

```
┌─────────┬─────────────┐
│ 源端口 (16) │ 目的端口 (16) │
├─────────┴─────────────┤
│ 长度 (16) │ 校验和 (16) │
└───────────────────────┘
```

### TCP vs UDP

| 对比 | TCP | UDP |
|------|-----|-----|
| 连接 | 面向连接 | 无连接 |
| 可靠 | 可靠（确认重传） | 不可靠 |
| 顺序 | 保证顺序 | 不保证 |
| 速度 | 较慢 | 快 |
| 首部 | 20-60 字节 | 8 字节 |
| 应用 | Web、邮件、文件传输 | 视频直播、DNS、游戏 |

## DNS 协议

### 域名解析过程

```
浏览器 → 本地 DNS 缓存 → /etc/hosts → 递归 DNS → 根 DNS → .com DNS → 权威 DNS
```

### DNS 记录类型

| 类型 | 说明 | 示例 |
|------|------|------|
| **A** | IPv4 地址 | `example.com → 93.184.216.34` |
| **AAAA** | IPv6 地址 | `example.com → 2606:2800:220:1:248:1893:25c8:1946` |
| **CNAME** | 别名 | `www.example.com → example.com` |
| **MX** | 邮件交换记录 | `mail.example.com → mail.example.com` |
| **NS** | 名称服务器 | `example.com → ns1.example.com` |
| **TXT** | 文本记录 | 用于验证（SPF、DKIM 等） |

### 常用命令

```bash
# DNS 查询
dig example.com
dig example.com A +short    # 简洁输出
nslookup example.com

# 反向查询
dig -x 93.184.216.34

# 流量 DNS
dig example.com @8.8.8.8   # 指定 DNS 服务器（Google）
dig example.com @1.1.1.1   # Cloudflare

# 本地 DNS 配置
cat /etc/resolv.conf
# nameserver 8.8.8.8
# nameserver 1.1.1.1
```

### CDN DNS 智能解析

- 同一域名根据用户 IP 所在地，返回不同的 IP（就近接入）
- 全局负载均衡（GSLB）基于 DNS
