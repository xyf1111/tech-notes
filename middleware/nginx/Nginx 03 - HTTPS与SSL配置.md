---
title: "Nginx 03 - HTTPS与SSL配置"
date: 2024-01-01
tags: [Nginx]
---

# Nginx 03 - HTTPS 与 SSL 配置

## SSL 证书基础

### 获取证书

**Let's Encrypt（免费）**：

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d example.com -d www.example.com
```

**自签名（开发环境）**：

```bash
# 生成私钥和自签名证书
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/private.key \
  -out /etc/nginx/ssl/certificate.crt \
  -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Dev/CN=localhost"
```

### Nginx HTTPS 基础配置

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    ssl_certificate     /etc/nginx/ssl/certificate.crt;
    ssl_certificate_key /etc/nginx/ssl/private.key;

    location / {
        root /var/www/html;
        index index.html;
    }
}

# HTTP → HTTPS 重定向
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

## 安全最佳实践（A+ 评级）

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    # 证书
    ssl_certificate     /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;

    # 协议 — 只允许 TLS 1.2 和 1.3
    ssl_protocols TLSv1.2 TLSv1.3;

    # 密码套件 — 安全优先
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:\
                ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:\
                ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;

    # ECDH 密钥交换曲线 — 使用更强的曲线
    ssl_ecdh_curve X25519:prime256v1:secp384r1;

    # 优先使用服务端密码套件
    ssl_prefer_server_ciphers on;

    # 会话缓存 — 减少 SSL 握手
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;  # 禁用会话票据（更安全）

    # OCSP Stapling — 减少客户端验证证书的延迟
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 1.1.1.1 valid=300s;
    resolver_timeout 5s;

    # HSTS — 强制浏览器使用 HTTPS
    add_header Strict-Transport-Security "max-age=63072000" always;

    # 安全头
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

## 配置测试

```bash
# 检查 SSL 配置
openssl s_client -connect example.com:443 -tls1_2

# 使用 testssl.sh 全面检测
./testssl.sh https://example.com

# 在线检测
# https://www.ssllabs.com/ssltest/
```

## 证书续期

### Let's Encrypt 自动续期

```bash
# 测试续期
sudo certbot renew --dry-run

# 自动续期（系统默认每天自动执行）
sudo crontab -l | grep certbot || echo "0 3 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

## 多域名与泛域名

```nginx
# 单证书多域名（SAN）
server {
    listen 443 ssl http2;
    server_name example.com www.example.com api.example.com;

    ssl_certificate     /etc/nginx/ssl/multi-domain.pem;
    ssl_certificate_key /etc/nginx/ssl/multi-domain.key;
}
```

## 性能优化

```nginx
# SSL 会话复用
ssl_session_cache shared:SSL:50m;  # 50MB 可缓存约 50K 个会话
ssl_session_timeout 1d;            # 会话有效期 1 天

# 开启 SSL 硬件加速（如果支持）
ssl_engine pkcs11;  # 硬件安全模块

# 调整缓冲区
ssl_buffer_size 4k;  # 默认 16k，调小减少 TLS 记录延迟
```
