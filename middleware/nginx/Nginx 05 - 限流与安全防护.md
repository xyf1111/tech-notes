---
title: "Nginx 05 - 限流与安全防护"
date: 2024-01-01
tags: [Nginx]
---

# Nginx 05 - 限流与安全防护

## 连接限制

### limit_conn — 限制并发连接数

```nginx
# 定义连接限制区域
limit_conn_zone $binary_remote_addr zone=addr:10m;

server {
    # 每个 IP 最多 10 个并发连接
    limit_conn addr 10;

    # 超出时返回状态码（默认 503）
    limit_conn_status 429;
}
```

### limit_req — 限制请求速率

```nginx
# 定义请求限制区域（$binary_remote_addr = IP）
limit_req_zone $binary_remote_addr zone=api:10m rate=5r/s;

server {
    location /api/ {
        # 速率限制：每秒最多 5 个请求
        limit_req zone=api;

        # 突发允许 10 个请求的队列
        # nodelay — 突发请求不延迟，直接处理（但超出的还是拒绝）
        limit_req zone=api burst=10 nodelay;

        # 延迟模式（默认）：突发请求排队处理
        limit_req zone=api burst=10;

        proxy_pass http://backend;
    }
}
```

### 限流逻辑

```
rate=5r/s, burst=10, nodelay

时间线：
T+0s:  请求到达 → 令牌桶 10 个 → 直接处理 (5 个正常速率 + 5 个突发)
T+1s:  请求到达 → 桶有 5 个令牌 → 继续
T+2s:  请求到达 → 桶已空 → 立即拒绝（返回 503/429）
```

### 按 URI 限制

```nginx
# 按 URI 限制（针对暴力破解 API）
limit_req_zone $request_uri zone=uri:10m rate=10r/m;

# 按 User-Agent 限制（爬虫）
limit_req_zone $http_user_agent zone=bot:10m rate=1r/s;
```

## 访问控制

### IP 黑白名单

```nginx
# 白名单
location /admin/ {
    allow 192.168.1.0/24;
    allow 10.0.0.1;
    deny all;
}

# 黑名单
location /api/ {
    deny 1.2.3.4;
    deny 5.6.7.0/24;
    allow all;
}
```

### 基础认证

```nginx
# 生成密码文件
# printf "admin:$(openssl passwd -apr1 123456)\n" > /etc/nginx/.htpasswd

location /admin/ {
    auth_basic "Restricted Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
}
```

## 常见攻击防护

### 禁止恶意 User-Agent

```nginx
# 在 http 块中定义变量
map $http_user_agent $bad_bot {
    default 0;
    ~*(curl|wget|Java|python-requests|scrapy|http-client) 1;
}

server {
    if ($bad_bot) {
        return 403;
    }
}
```

### SQL 注入 / XSS 过滤

```nginx
# 检测请求中的危险字符
if ($query_string ~* "(<|>|'|%27|%22|union.*select|select.*from)") {
    return 403;
}

if ($uri ~* "(\.\.|//|\\|/etc/passwd)") {
    return 403;
}
```

### 限制请求方法

```nginx
# 只允许 GET/POST
if ($request_method !~ ^(GET|POST|HEAD)$) {
    return 405;
}
```

### 限制请求体大小

```nginx
# 限制上传大小（默认 1MB）
client_max_body_size 10m;

# 缓冲区大小
client_body_buffer_size 128k;
```

## DDoS 防护建议

```nginx
# 1. 限制连接数
limit_conn_zone $binary_remote_addr zone=conn:10m;
server {
    limit_conn conn 50;
}

# 2. 限制请求速率
limit_req_zone $binary_remote_addr zone=ddos:10m rate=30r/s;
server {
    limit_req zone=ddos burst=50 nodelay;
}

# 3. 限制上游连接超时
proxy_connect_timeout 5s;
proxy_read_timeout 10s;

# 4. 限制缓冲区大小
client_body_buffer_size 8k;
client_header_buffer_size 1k;
large_client_header_buffers 4 8k;

# 5. 限制请求头大小
client_header_timeout 10s;
```

## 日志安全

```nginx
# 不记录健康检查请求
location /health {
    access_log off;
    return 200;
}

# 不记录静态文件访问
location /static/ {
    access_log off;
}
```

## 速率限制的高级用法

### 双层限流

```nginx
# 第一层：限制全局 API 请求
limit_req_zone $binary_remote_addr zone=global:10m rate=100r/s;

# 第二层：限制特定 API
limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/m;

server {
    location /api/auth/ {
        limit_req zone=global burst=200 nodelay;
        limit_req zone=auth burst=3;
        proxy_pass http://auth-backend;
    }
}
```

### 自定义错误页面

```nginx
error_page 429 /429.html;
location = /429.html {
    internal;
    root /var/www/errors;
}
```
