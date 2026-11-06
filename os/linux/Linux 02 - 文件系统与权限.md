---
title: "Linux 02 - 文件系统与权限"
date: 2024-01-01
tags: [Linux]
---

# Linux 02 - 文件系统与权限

## 文件系统结构

```bash
/           # 根目录
├── bin     # 用户二进制命令（ls, cp, mv）
├── sbin    # 系统管理命令（fdisk, mkfs）
├── etc     # 配置文件（nginx.conf, sshd_config）
├── usr     # 用户程序（/usr/local 用户安装）
├── var     # 可变数据（日志/缓存）
│   ├── log # 日志
│   └── lib # 状态信息
├── tmp     # 临时文件（重启清空）
├── home    # 用户家目录
├── root    # root 用户家目录
├── dev     # 设备文件（/dev/sda）
├── proc    # 进程信息（虚拟文件系统）
└── mnt     # 挂载点
```

## 文件权限

```bash
# 权限表示
-rwxr-xr-x  1 user group 1024 Jan 1 10:00 script.sh
 ^^^ ^^^ ^^^
  │   │   └─ 其他用户权限 (r-x = 5)
  │   └───── 同组权限   (r-x = 5)
  └───────── 所有者权限  (rwx = 7)

# 数字表示
r=4, w=2, x=1
rwx = 7, r-x = 5, r-- = 4

# 修改权限
chmod 755 script.sh        # rwxr-xr-x
chmod u+x script.sh         # 所有者加执行
chmod g-w script.sh         # 同组去写
chmod o+r file.txt          # 其他加读

# 修改所有者
chown user:group file.txt

# 递归修改
chown -R user:group /path/to/dir
chmod -R 755 /path/to/dir
```

### 特殊权限

```bash
# SUID (4) — 临时获得文件所有者的权限
chmod u+s /usr/bin/passwd   # -rwsr-xr-x

# SGID (2) — 继承目录的组
chmod g+s /shared          # drwxrwsr-x

# Sticky (1) — 仅文件所有者可删除（/tmp）
chmod +t /tmp              # drwxrwxrwt
```

## 磁盘与挂载

```bash
# 查看磁盘
lsblk
df -h                      # 查看分区使用
du -sh /path               # 查看目录大小

# 挂载
mount /dev/sda1 /mnt/data
umount /mnt/data

# 查看挂载
mount | grep sda

# fstab 自动挂载（/etc/fstab）
# UUID=xxx /data ext4 defaults 0 2
```

## 软链接与硬链接

```bash
# 软链接（符号链接）— 类似快捷方式
ln -s /original/file link_name

# 硬链接 — 同一 inode 的不同文件名
ln /original/file hard_link

# 区别
# 软链接：可跨文件系统，可链接目录，源删除则失效
# 硬链接：不可跨文件系统，不可链接目录，源删除仍可用
```

## 常用文件操作

```bash
# 查找
find / -name "*.log" -type f -mtime -7   # 7天内修改的 .log
find . -size +100M                        # 大于 100MB 的文件

# 压缩/解压
tar -czf archive.tar.gz /path
tar -xzf archive.tar.gz
zip -r archive.zip /path
unzip archive.zip

# 查看文件大小排名
du -sh /* | sort -rh | head -10
```
