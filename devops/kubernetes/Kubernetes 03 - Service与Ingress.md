---
title: "Kubernetes 03 - Service与Ingress"
date: 2026-06-11
tags: [devops, kubernetes]
---

# Kubernetes 03 - Service与Ingress

## Service 类型

| 类型 | 说明 | 适用场景 |
|------|------|----------|
| **ClusterIP**（默认） | 集群内虚拟 IP，仅内部可访问 | 内部服务通信 |
| **NodePort** | 在每个 Node 上开端口访问 | 开发测试 |
| **LoadBalancer** | 云厂商 LB 分发流量（如 ALB、NLB） | 生产对外服务 |
| **ExternalName** | CNAME 到外部域名 | 访问外部服务 |

## Service 示例

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx          # 关联到 label 为 app=nginx 的 Pod
  ports:
  - protocol: TCP
    port: 80             # Service 端口
    targetPort: 80       # Pod 容器端口
  type: ClusterIP
```

## Ingress（HTTP 路由）

Ingress 提供 HTTP/HTTPS 路由，将外部请求转发到内部 Service。

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

## 常用命令

```bash
# Service
kubectl get svc
kubectl describe svc nginx-service
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Ingress
kubectl get ingress
kubectl describe ingress my-ingress

# 端口转发（临时调试）
kubectl port-forward svc/nginx-service 8080:80
kubectl port-forward pod/nginx-pod 8080:80
```
