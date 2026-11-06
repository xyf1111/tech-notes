---
title: "Nginx 01 - 基础概念与安装配置"
date: 2024-01-01
tags: [Nginx]
---

# Nginx 01 - 基础概念与安装配置

## 什么是 Nginx

Nginx（Engine X）是一个高性能 HTTP 和反向代理服务器，由 Igor Sysoev 于 2004 年创建。

### 核心特性

- **事件驱动** — 非阻塞 I/O，单线程处理数万并发连接
- **静态资源处理** — 远超 Apache
- **反向代理** — HTTP、TCP、UDP
- **负载均衡** — 内置多种均衡策略
- **SSL/TLS** — 原生支持 HTTPS
- **模块化** — 插件体系，功能可扩展

### Nginx vs Apache

| 特性 | Nginx | Apache |
|------|-------|--------|
| 架构 | 事件驱动（异步） | 进程/线程（同步） |
| 并发连接 | 万级 | 千级 |
| 静态文件 | 极快 | 快 |
| 动态处理 | 需通过 FastCGI | 模块直接支持（mod_php） |
| 配置 | 简洁 | 复杂 |
| 模块 | 动态/静态加载（1.9.11+） | 动态加载 |

## 安装

### macOS

```bash
brew install nginx
# 配置文件: /opt/homebrew/etc/nginx/nginx.conf
# 默认根目录: /opt/homebrew/var/www
```

### Ubuntu/Debian

```bash
sudo apt update
sudo apt install nginx
# 配置文件: /etc/nginx/nginx.conf
# 站点配置: /etc/nginx/sites-available/ → sites-enabled/
```

### CentOS/RHEL

```bash
sudo dnf install epel-release
sudo dnf install nginx
```

### 从源码编译

```bash
# 如需自定义模块
./configure --prefix=/usr/local/nginx \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-stream \
  --with-http_gzip_static_module
make && sudo make install
```

## 配置文件结构

```
nginx.conf
├── main (全局)
│   ├── user / worker_processes / error_log / pid
│   └── events → worker_connections
├── http (HTTP 协议)
│   ├── include mime.types
│   ├── sendfile / tcp_nopush / keepalive_timeout / gzip
│   ├── upstream (负载均衡组)
│   └── server (虚拟主机)
│       ├── listen / server_name
│       ├── location (URL 路由)
│       │   ├── root / alias / index / try_files
│       │   ├── proxy_pass / fastcgi_pass
│       │   └── rewrite / return / deny
│       └── ssl (HTTPS 配置)
└── stream (TCP/UDP 代理)
```

### 最小配置

```nginx
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  example.com;

        location / {
            root   /var/www/html;
            index  index.html index.htm;
        }
    }
}
```

## 常用命令

```bash
# 启动
nginx                     # 默认使用 /usr/local/nginx/conf/nginx.conf
nginx -c /path/to/config  # 指定配置文件

# 停止
nginx -s stop             # 快速停止
nginx -s quit             # 优雅停止（处理完当前请求）

# 重载（配置生效）
nginx -s reload

# 检查配置语法
nginx -t

# 查看版本和模块
nginx -V
```

## 日志管理

```nginx
# 日志格式
http {
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log  /var/log/nginx/error.log warn;
}
```

> **日志轮转**：`logrotate` 配置通常位于 `/etc/logrotate.d/nginx`，默认按周轮转。
