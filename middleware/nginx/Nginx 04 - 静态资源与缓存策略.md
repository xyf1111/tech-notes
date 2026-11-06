---
title: "Nginx 04 - 静态资源与缓存策略"
date: 2024-01-01
tags: [Nginx]
---

# Nginx 04 - 静态资源与缓存策略

## 静态文件服务

### 基础配置

```nginx
server {
    listen 80;
    server_name static.example.com;

    # 根目录
    root /var/www/static;

    # 默认索引文件
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### 多目录与别名

```nginx
server {
    root /var/www/html;

    # /images → /var/www/images
    location /images/ {
        alias /var/www/images/;    # alias 会替换匹配的路径
    }

    # /uploads → /var/www/storage/uploads
    location /uploads/ {
        alias /var/www/storage/uploads/;
    }
}
```

`root` vs `alias`：

```
root:     /images/a.jpg → /var/www/html/images/a.jpg
alias:    /images/a.jpg → /var/www/images/a.jpg
```

## 缓存策略

### 强缓存

```nginx
location /static/ {
    root /var/www;

    # 缓存 1 年（适用于 hash 文件名）
    expires 1y;
    add_header Cache-Control "public, immutable";

    # 或者更精确的控制
    expires max;
    add_header Cache-Control "max-age=31536000, immutable";
}
```

### 协商缓存

```nginx
location /assets/ {
    root /var/www;

    # 开启 ETag
    etag on;  # 默认开启

    # 修改 Last-Modified
    if_modified_since before;  # 精确比较

    # 更精细的缓存时间
    expires 7d;
    add_header Cache-Control "public, must-revalidate";
}
```

### 按文件类型设置

```nginx
# 针对不同类型设置不同的缓存时间
location ~* \.(jpg|jpeg|png|gif|ico|webp)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
}

location ~* \.(css|js)$ {
    expires 7d;
    add_header Cache-Control "public";
}

location ~* \.(html|htm)$ {
    expires 0;
    add_header Cache-Control "no-cache, must-revalidate";
}
```

## 压缩

### gzip

```nginx
http {
    # 开启 gzip
    gzip on;
    gzip_vary on;               # Vary: Accept-Encoding
    gzip_min_length 256;        # 小于 256 字节不压缩
    gzip_proxied any;
    gzip_comp_level 5;          # 压缩级别 1-9（推荐 5-6）
    gzip_types
        text/plain
        text/css
        text/javascript
        application/javascript
        application/json
        application/xml+rss
        image/svg+xml;
    gzip_disable "msie6";       # IE6 不压缩
}
```

### Brotli（可选）

```nginx
# 需要 ngx_brotli 模块
brotli on;
brotli_static on;       # 优先使用预压缩 .br 文件
brotli_types text/plain text/css application/javascript;
brotli_comp_level 6;
```

## 防盗链

```nginx
location ~* \.(jpg|jpeg|png|gif|ico)$ {
    # 允许的域名
    valid_referers none blocked server_names
        ~\.?example\.com
        ~\.?google\.com;

    if ($invalid_referer) {
        return 403;
        # 或者返回防盗链图片
        # rewrite ^ /images/forbidden.png break;
    }
}
```

## 文件操作限制

```nginx
# 禁止访问隐藏文件
location ~ /\. {
    deny all;
}

# 限制上传大小
client_max_body_size 10m;

# 限制请求方法
if ($request_method !~ ^(GET|HEAD|POST)$) {
    return 405;
}

# 防止热链接（直接 IP 访问）
server {
    listen 80 default_server;
    return 444;  # 直接关闭连接
}
```

## 性能优化

```nginx
# sendfile — 零拷贝
sendfile on;
tcp_nopush on;      # 配合 sendfile，一次性发送所有头部数据
tcp_nodelay on;     # 禁用 Nagle 算法，减少延迟

# 打开文件缓存
open_file_cache max=1000 inactive=20s;
open_file_cache_valid 60s;
open_file_cache_min_uses 2;
open_file_cache_errors on;

# 读取头部超时
client_header_timeout 10;
client_body_timeout 10;
```
