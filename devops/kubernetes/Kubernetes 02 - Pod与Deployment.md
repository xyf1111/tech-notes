---
title: "Kubernetes 02 - Pod与Deployment"
date: 2026-06-11
tags: [devops, kubernetes]
---

# Kubernetes 02 - Pod与Deployment

## Pod

### 创建 Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
```

```bash
kubectl apply -f pod.yaml
kubectl get pods -o wide
kubectl describe pod nginx-pod
kubectl logs nginx-pod
kubectl exec -it nginx-pod -- sh
```

### 多容器 Pod

同一个 Pod 中的容器共享网络栈和存储卷（sidecar 模式）：

```yaml
spec:
  containers:
  - name: app
    image: my-app
  - name: sidecar
    image: envoy:latest  # 日志采集、代理等辅助容器
```

## Deployment

### 声明式更新

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

### 滚动更新与回滚

```bash
# 更新镜像
kubectl set image deployment/nginx-deployment nginx=nginx:1.26

# 查看更新状态
kubectl rollout status deployment/nginx-deployment

# 回滚到上一个版本
kubectl rollout undo deployment/nginx-deployment

# 回滚到指定版本
kubectl rollout undo deployment/nginx-deployment --to-revision=2

# 查看版本历史
kubectl rollout history deployment/nginx-deployment
```

### 扩缩容

```bash
# 手动扩缩
kubectl scale deployment/nginx-deployment --replicas=5

# HPA（自动扩缩）
kubectl autoscale deployment/nginx-deployment --min=2 --max=10 --cpu-percent=80
```
