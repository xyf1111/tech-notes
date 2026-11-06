---
title: "CI CD 02 - GitHub Actions 实践"
date: 2026-06-11
tags: [devops, cicd]
---

# CI CD 02 - GitHub Actions 实践

## 核心概念

| 概念 | 说明 |
|------|------|
| **Workflow** | 一个 `.yml` 文件定义的自动化流程 |
| **Job** | Workflow 中的任务单元，可并行或依赖 |
| **Step** | Job 中的单个步骤 |
| **Action** | 可复用的步骤（官方或社区发布）|
| **Runner** | 运行 Workflow 的服务器 |

## 常用 Workflow 示例

### 1. Go 项目 CI

```yaml
name: Go CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Setup Go
      uses: actions/setup-go@v5
      with:
        go-version: '1.22'

    - name: Lint
      run: golangci-lint run ./...

    - name: Test
      run: go test -v -race -coverprofile=coverage.txt ./...

    - name: Upload coverage
      uses: codecov/codecov-action@v4
```

### 2. 构建并推送 Docker 镜像

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push
      uses: docker/build-push-action@v5
      with:
        push: true
        tags: user/app:latest,user/app:${{ github.sha }}
```

### 3. 部署到 Kubernetes

```yaml
    - name: Set up kubectl
      uses: azure/setup-kubectl@v3

    - name: Deploy
      run: |
        kubectl set image deployment/app app=user/app:${{ github.sha }}
```

## 常用 Actions 推荐

| Action | 用途 |
|--------|------|
| `actions/checkout` | 检出代码 |
| `actions/setup-go/node/python` | 设置语言环境 |
| `docker/login-action` | 登录镜像仓库 |
| `docker/build-push-action` | 构建推送镜像 |
| `azure/setup-kubectl` | 安装 kubectl |
| `codecov/codecov-action` | 上传测试覆盖率 |
| `actions/cache` | 缓存依赖加速构建 |
