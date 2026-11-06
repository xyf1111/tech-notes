---
title: "MySQL ZIP绿色版安装（Windows）"
date: 2026-07-23
tags: [mysql, install, windows, devops]
source: "鱼皮·编程导航 / codefather"
---

# MySQL ZIP绿色版安装（Windows）

> Windows 下 MySQL 绿色版（ZIP）的安装步骤备忘录。

## 安装步骤

1. **下载**：从 [MySQL Downloads](https://dev.mysql.com/downloads/mysql/) 获取 ZIP 压缩包
2. **解压**：解压到目标目录，如 `D:\mysql-8.2.0-winx64`
3. **配置 my.ini**：在解压目录创建 `my.ini` 配置文件

```ini
[mysqld]
port=3307
basedir=D:\\software\\mysql-8.2.0-winx64
datadir=D:\\software\\MySQLData\\mysql81\\Data
max_connections=200
max_connect_errors=10
character-set-server=utf8
default-storage-engine=INNODB
default_authentication_plugin=mysql_native_password
[mysql]
default-character-set=utf8mb4
[client]
port=3306
default-character-set=utf8
```

4. **初始化**（以管理员身份运行 cmd，切换到 bin 目录）：

```bash
mysqld --initialize --console
```

初始化完成后会生成 root 用户和临时密码，保存好。

5. **安装服务**：

```bash
mysqld --install 服务名    # 如 mysql81
```

6. **启动服务**：

```bash
net start 服务名
# 停止：net stop 服务名
# 卸载：sc delete 服务名
```

7. **登录并改密码**：

```bash
mysql -u root -p
# 输入临时密码
ALTER USER root@localhost IDENTIFIED BY '新密码';
```

> 来源：鱼皮·编程导航 / codefather
