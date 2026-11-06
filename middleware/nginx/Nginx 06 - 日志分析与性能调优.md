---
title: "Nginx 06 - 日志分析与性能调优"
date: 2024-01-01
tags: [Nginx]
---

# Nginx 06 - 日志分析与性能调优

## 日志格式定制

### 高级日志格式

```nginx
# 包含响应时间的日志格式
log_format detailed '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent" '
                    '$request_time $upstream_response_time '
                    '$upstream_addr $upstream_status';
```

| 变量 | 含义 |
|------|------|
| `$request_time` | 请求处理总时间（秒，含客户端网络） |
| `$upstream_response_time` | 上游服务器响应时间（秒） |
| `$upstream_addr` | 上游服务器地址 |
| `$upstream_status` | 上游服务器返回码 |
| `$body_bytes_sent` | 响应体大小 |
| `$bytes_sent` | 总发送字节数（含头部） |

### 条件日志

```nginx
# 只记录 4xx/5xx 错误
map $status $loggable {
    ~^[23]  0;    # 2xx/3xx 不记录
    default 1;    # 其他记录
}
server {
    access_log /var/log/nginx/error_only.log detailed if=$loggable;
}
```

## 日志分析命令

```bash
# 最常见的请求路径
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head -10

# 响应时间最慢的 10 个请求
awk '{if (NF > 0) print $NF, $0}' access.log | sort -rn | head -10

# 每秒请求数（RPS）
cut -d' ' -f4 access.log | cut -d: -f2 | sort | uniq -c

# HTTP 状态码分布
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# 某 IP 的访问统计
grep "1.2.3.4" access.log | cut -d'"' -f2 | sort | uniq -c | sort -rn

# 最活跃的 IP（防爬虫）
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -10
```

### GoAccess 实时分析

```bash
# 安装
brew install goaccess

# 实时分析（终端）
goaccess access.log --log-format=COMBINED

# 生成 HTML 报告
goaccess access.log -o report.html --log-format=COMBINED
```

## 性能调优

### worker 进程

```nginx
# 自动检测 CPU 核心数
worker_processes auto;

# 设置 worker 优先级
worker_priority -5;  # 提高优先级

# worker 进程可以打开的最大文件数
worker_rlimit_nofile 65535;
```

### 连接数调优

```nginx
events {
    # 每个 worker 的最大连接数
    worker_connections 65535;

    # 使用 epoll（Linux 高效模型）
    use epoll;

    # 批量接受新连接
    multi_accept on;
}
```

### 内核参数调优

```bash
# /etc/sysctl.conf
net.core.somaxconn = 65535              # listen 队列最大长度
net.ipv4.tcp_max_tw_buckets = 2000000   # 最大 TIME_WAIT 数
net.ipv4.tcp_tw_reuse = 1               # 重用 TIME_WAIT 连接
net.ipv4.tcp_fin_timeout = 30           # FIN-WAIT-2 超时
net.core.netdev_max_backlog = 5000       # 网卡接收队列
net.ipv4.tcp_syncookies = 1             # 防止 SYN Flood
net.ipv4.tcp_syn_retries = 2            # SYN 重试次数
net.ipv4.tcp_synack_retries = 2         # SYN-ACK 重试次数
```

### 缓冲区调优

```nginx
http {
    # 头部缓冲区
    client_body_buffer_size 128k;
    client_header_buffer_size 1k;
    large_client_header_buffers 4 8k;

    # 输出缓冲区
    output_buffers 8 32k;
    postpone_output 1460;

    # 代理缓冲区
    proxy_buffer_size 4k;
    proxy_buffers 8 32k;
    proxy_busy_buffers_size 64k;
    proxy_temp_file_write_size 64k;
}
```

## 常见性能瓶颈及排查

| 症状 | 可能原因 | 解决方案 |
|------|---------|---------|
| 高 CPU | TTFB 慢，大量 SSL 握手 | 开启 keepalive，SSL session cache |
| 高内存 | worker 数量过多或缓冲区过大 | 减少 worker_processes，调小 buffer |
| 大量 TIME_WAIT | 短连接频繁 | 开启 keepalive，复用连接 |
| 大量 CLOSE_WAIT | 应用未及时关闭连接 | 修复应用代码 |
| 连接拒绝 | worker_connections 不足 | 增大连接数，增加 worker |
| 磁盘 I/O 高 | 访问日志频繁写入 | 关闭 access_log，使用 buffer |

## 零宕机重载

Nginx 支持平滑重载，不丢失连接：

```bash
# 工作流程：
# 1. 新进程 fork，加载新配置
# 2. 新连接由新进程处理
# 3. 旧进程处理完现有连接后优雅退出
nginx -s reload
```

### 配置语法检查

```bash
# 重载前务必检查
nginx -t && nginx -s reload
```

## 性能基准

```bash
# 使用 ab 做压测
ab -n 10000 -c 100 -k https://example.com/

# 使用 wrk
wrk -t12 -c400 -d30s https://example.com/

# 使用 siege
siege -c100 -t60s https://example.com/

# 常见性能数据（4C8G VPS）
# 静态文件: 50,000+ RPS
# 反向代理: 10,000-20,000 RPS
# HTTPS (TLS 1.3): 5,000-10,000 RPS
# 限流场景: 取决于配置
```

> **注意**：实际性能取决于硬件、网络、应用逻辑和配置。以上为参考值。
