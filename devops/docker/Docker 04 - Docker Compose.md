---
title: "Docker 04 - Docker Compose"
date: 2026-06-11
tags: [devops, docker]
---

# Docker 04 - Docker Compose

## 什么是 Docker Compose

通过 `docker-compose.yml` 定义和运行多容器应用，一条命令启动整个服务栈。

## docker-compose.yml 示例

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - api

  api:
    build: ./api
    ports:
      - "3000:3000"
    environment:
      - DB_HOST=db
      - DB_PORT=3306
    depends_on:
      db:
        condition: service_healthy

  db:
    image: mysql:8.0
    volumes:
      - mysql-data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: myapp
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s

volumes:
  mysql-data:
```

## 常用命令

```bash
# 启动所有服务
docker compose up -d

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f

# 重建特定服务
docker compose up -d --build api

# 停止并删除
docker compose down

# 停止并删除数据卷
docker compose down -v

# 缩放服务实例数
docker compose up -d --scale api=3
```

## 适用场景

- 本地开发环境（MySQL + Redis + App）
- CI/CD 测试环境
- 单机部署小型应用

> 生产环境多机部署推荐使用 **Kubernetes** 或 **Docker Swarm**。
