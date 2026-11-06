---
title: "CI CD 01 - 持续集成与持续部署概念"
date: 2026-06-11
tags: [devops, cicd]
---

# CI CD 01 - 持续集成与持续部署概念

## 核心概念

| 阶段 | 英文 | 说明 |
|------|------|------|
| **持续集成** | CI | 频繁合并代码到主干，每次合并自动构建 + 测试 |
| **持续交付** | CD | CI 基础上，自动部署到类生产环境（人工确认上线）|
| **持续部署** | CD | CD 基础上，自动部署到生产环境（无人干预）|

## CI/CD 流水线

```
代码提交 → 触发构建 → 代码检查(Lint) → 单元测试 → 
镜像构建 → 推送镜像仓库 → 部署到测试环境 → 
集成测试 → 部署到预发布(Staging) → 部署到生产
```

## 常见工具

| 分类 | 工具 |
|------|------|
| **CI/CD 平台** | GitHub Actions、GitLab CI/CD、Jenkins、Drone CI、ArgoCD |
| **代码检查** | SonarQube、ESLint、golint、Checkstyle |
| **测试** | JUnit、pytest、go test、Selenium |
| **镜像构建** | Docker BuildKit、Kaniko（无特权模式）、Buildpacks |
| **部署** | kubectl、Helm、Kustomize、ArgoCD（GitOps）|

## GitHub Actions 示例

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - name: Build Docker image
      run: docker build -t my-app:${{ github.sha }} .

    - name: Push to registry
      run: |
        docker tag my-app:${{ github.sha }} registry.com/my-app:latest
        docker push registry.com/my-app:latest

    - name: Deploy to K8s
      run: |
        kubectl set image deployment/my-app \
          my-app=registry.com/my-app:${{ github.sha }}
```

## CI/CD 最佳实践

1. **提交小而频繁** — 每次提交都可触发 CI，快速发现错误
2. **流水线快速** — 10 分钟内反馈，长任务单独 Job
3. **不可变制品** — 构建产物带版本号，环境间传递同一制品
4. **环境一致性** — 测试/预发布/生产使用同一镜像
5. **GitOps** — Git 仓库作为唯一事实来源，ArgoCD 自动同步
