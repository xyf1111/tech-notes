---
title: "Nginx 02 - 反向代理与负载均衡"
date: 2024-01-01
tags: [Nginx]
---

# Nginx 02 - 反向代理与负载均衡

## 反向代理

正向代理代理客户端，反向代理代理服务端：

```
正向代理: 客户端 → 代理 → 互联网（代理访问外部资源）
反向代理: 客户端 → 代理 → 内网服务器（隐藏后端服务）
```

### 简单反向代理

```nginx
server {
    listen 80;
    server_name api.example.com;

    location / {
        proxy_pass http://localhost:3000;  # 转发到 Node.js 应用

        # 传递客户端真实信息
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 通用代理参数（可抽取为文件）

```nginx
# /etc/nginx/proxy_params.conf
proxy_redirect off;
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;

proxy_connect_timeout 60s;
proxy_read_timeout 60s;
proxy_send_timeout 60s;

proxy_buffering on;
proxy_buffer_size 4k;
proxy_buffers 8 4k;
proxy_busy_buffers_size 8k;
```

```nginx
server {
    location /api/ {
        include proxy_params.conf;
        proxy_pass http://backend;
    }
}
```

### 路径重写

```nginx
# 保留 URI 路径（默认）
location /api/ {
    proxy_pass http://backend/;   # 注意结尾 /
}
# 请求 /api/users → http://backend/users

# 不保留路径前缀
location /api/ {
    proxy_pass http://backend/api/;   # 不带结尾 /
}
# 请求 /api/users → http://backend/api/users
```

## 负载均衡

### upstream 模块

```nginx
# 定义后端服务器组
upstream backend {
    server 10.0.0.1:3000 weight=3;    # 权重 3
    server 10.0.0.2:3000 weight=1;    # 权重 1
    server 10.0.0.3:3000 backup;       # 备份服务器
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://backend;
    }
}
```

### 负载均衡算法

| 算法 | 指令 | 说明 |
|------|------|------|
| 轮询（默认） | — | 依次分发请求 |
| 加权轮询 | `weight=N` | 按权重比例分发 |
| 最少连接 | `least_conn` | 转发到连接数最少的服务器 |
| IP Hash | `ip_hash` | 同一 IP 固定到同一服务器（会话保持） |
| 通用 Hash | `hash $request_uri` | 根据指定的 key 哈希分配 |

```nginx
# IP Hash（会话保持）
upstream backend {
    ip_hash;
    server 10.0.0.1:3000;
    server 10.0.0.2:3000;
}

# 最少连接
upstream backend {
    least_conn;
    server 10.0.0.1:3000;
    server 10.0.0.2:3000;
}

# 一致性哈希（适合缓存场景）
upstream backend {
    hash $request_uri consistent;
    server 10.0.0.1:3000;
    server 10.0.0.2:3000;
}
```

### 健康检查

Nginx 默认只在请求时检测服务器是否可用（被动检查）：

```nginx
upstream backend {
    server 10.0.0.1:3000 max_fails=3 fail_timeout=30s;
    server 10.0.0.2:3000 max_fails=3 fail_timeout=30s;
}
```

主动健康检查需要 Nginx Plus 或第三方模块（nginx_upstream_check_module）。

## 缓存反向代理

```nginx
# 定义缓存路径和大小
proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=mycache:10m
                 max_size=1g inactive=60m;

server {
    location / {
        proxy_cache mycache;
        proxy_cache_key "$scheme$request_method$host$request_uri";
        proxy_cache_valid 200 302 1h;      # 200/302 缓存 1 小时
        proxy_cache_valid 404 1m;           # 404 缓存 1 分钟
        proxy_cache_use_stale error timeout updating;  # 源站故障用缓存
        proxy_cache_background_update on;   # 后台异步更新

        proxy_pass http://backend;
    }
}
```

## 多代理场景

```
客户端 → Nginx (负载均衡) → 上游 Nginx (静态资源)
                          → 后端服务集群
```

```nginx
upstream frontends {
    server nginx1.example.com weight=5;
    server nginx2.example.com weight=5;
}

server {
    listen 80;
    server_name *.example.com;

    location /static/ {
        proxy_pass http://static-servers;
    }

    location /api/ {
        proxy_pass http://api-backend;
    }
}
```
