---
title: "Linux 04 - 软件包管理"
date: 2026-06-11
tags: [os, linux]
---

# Linux 04 - 软件包管理

## APT（Debian/Ubuntu）

```bash
# 更新源
sudo apt update

# 安装
sudo apt install nginx

# 卸载
sudo apt remove nginx          # 保留配置文件
sudo apt purge nginx            # 清除配置文件
sudo apt autoremove             # 清理依赖

# 搜索
apt search keyword
apt show nginx                  # 查看包信息

# 升级
sudo apt upgrade                # 升级所有包
sudo apt full-upgrade           # 升级系统

# 管理
apt list --installed            # 列出已安装
apt list --upgradable           # 可升级的
```

## YUM/DNF（CentOS/RHEL/Fedora）

```bash
# 安装
sudo yum install nginx          # CentOS 7
sudo dnf install nginx          # Fedora / CentOS 8+

# 卸载
sudo yum remove nginx
sudo dnf remove nginx

# 搜索
yum search keyword
yum info nginx

# 升级
sudo yum update
sudo dnf upgrade

# 包组
yum groupinstall "Development Tools"
```

## 编译安装

```bash
# 三步曲
./configure --prefix=/usr/local/nginx
make
sudo make install

# 常用参数
./configure --prefix=/usr/local/nginx \
            --with-http_ssl_module \
            --with-stream
```

## 源码 vs 包管理器

| 方式 | 优点 | 缺点 |
|------|------|------|
| **APT/YUM** | 自动解决依赖，方便更新 | 版本可能旧 |
| **编译安装** | 版本新，可定制编译参数 | 依赖手动解决，无自动更新 |
| **Snap/Flatpak** | 沙箱隔离，自动更新 | 体积大 |
| **Docker** | 环境隔离，可重复 | 需 Docker 环境 |
