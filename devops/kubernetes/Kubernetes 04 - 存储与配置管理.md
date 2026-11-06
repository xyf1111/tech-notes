---
title: "Kubernetes 04 - 存储与配置管理"
date: 2026-06-11
tags: [devops, kubernetes]
---

# Kubernetes 04 - 存储与配置管理

## ConfigMap（配置）

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    DB_HOST=mysql-service
    DB_PORT=3306
    LOG_LEVEL=info
  REDIS_URL: "redis://redis-service:6379"
```

```yaml
# Pod 中使用 ConfigMap
spec:
  containers:
  - name: app
    env:
    - name: REDIS_URL
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: REDIS_URL
    volumeMounts:
    - name: config
      mountPath: /etc/config
  volumes:
  - name: config
    configMap:
      name: app-config
```

## Secret（敏感信息）

Base64 编码存储，etcd 中建议开启加密：

```bash
kubectl create secret generic db-secret \
  --from-literal=password='MyP@ssw0rd' \
  --from-literal=username='admin'
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-secret
type: Opaque
data:
  username: YWRtaW4=          # base64("admin")
  password: TXlQQHNzdzByZA==  # base64("MyP@ssw0rd")
```

## PersistentVolume（存储）

```yaml
# PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/k8s

---
# PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi

---
# Pod 使用 PVC
spec:
  containers:
  - name: app
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: pvc-data
```

### 常用 kubectl 命令

```bash
kubectl get configmap
kubectl get secret
kubectl get pv,pvc
kubectl create configmap my-config --from-file=config/
kubectl create secret generic my-secret --from-file=key.json
```
