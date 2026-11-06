---
title: "DevOps - 自建服务部署实战（Leanote 云笔记）"
date: 2026-09-18
tags: [DevOps, Leanote, MongoDB, 云笔记, 部署]
source: "鱼皮·编程导航 / codefather"
---

# DevOps 12 - 自建服务部署实战（Leanote 云笔记）

> 本文以 Leanote 私有云笔记为例，完整走一遍「Linux 服务器上部署一个带数据库的开源服务」的标准流程：下载项目 → 手动安装并启动 MongoDB → 导入初始数据 → 改配置 → 启动应用 → 端口与防火墙排查。

## 一、背景与选型

在开源笔记软件评测中得分最高的是 **Leanote 云笔记**，该项目在 GitHub 上有上万个 star。私有部署后可以随时随地记录和分享内容。

- 项目地址：https://github.com/leanote/leanote
- 支持多种操作系统：有 Linux 服务器可装到服务器上（保证 24 小时持续运行），没有也可装在自己电脑上
- 支持**安装包安装**和**源码安装**两种方式，建议选择前者（免编译）
- 本文演示 Linux 服务器上的安装方式

## 二、部署流程总览

| 步骤 | 内容 |
|------|------|
| 1 | 下载并解压 Leanote 安装包 |
| 2 | 安装 MongoDB、配置环境变量、启动数据库服务 |
| 3 | 将 Leanote 初始数据导入数据库 |
| 4 | 修改应用配置（端口、域名、密钥，可跳过） |
| 5 | 启动应用并访问 |
| 6 | 访问失败时排查端口占用与防火墙 |

## 三、下载项目

在安装文档中找到对应版本的安装包下载地址，可直接在服务器上用 `wget` 下载（比手动下载再上传更简单）：

```bash
wget https://udomain.dl.sourceforge.net/project/leanote-bin/2.6.1/leanote-linux-amd64-v2.6.1.bin.tar.gz \
--no-check-certificate
```

> 记得加上 `--no-check-certificate` 选项，否则可能无法下载。

下载成功后用 `tar` 解压即出项目目录：

```bash
tar -zxvf leanote-linux-amd64-v2.6.1.bin.tar.gz
```

## 四、安装并启动 MongoDB

Leanote 使用 MongoDB 存储笔记资源，所以需要先安装它。

### 1. 下载解压

```bash
# 下载安装包
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.1.tgz
# 解压
tar -xzvf mongodb-linux-x86_64-3.0.1.tgz
```

### 2. 配置环境变量

数据库的命令文件位置在 mongodb 目录中，每次都要先进入该目录才能执行，非常麻烦，因此把它加入环境变量：

```bash
# 修改环境配置文件
sudo vim /etc/profile
```

在文件底部新增一行（vim 中按 `shift + g` 到文件底部，按 `o` 新增一行）：

```bash
export PATH=$PATH:$HOME/mongodb-linux-x86_64-3.0.1/bin
```

按 `esc` 后输入 `:wq` 回车保存退出，再激活配置：

```bash
source /etc/profile
```

### 3. 启动与验证

```bash
# 新建数据目录，用于存放数据文件
mkdir data
# 启动数据库，指定 data 为数据文件目录，& 表示后台启动
mongod --dbpath data &
# 连接已启动的数据库
mongo
# 查看数据库列表与占用空间
show dbs
```

MongoDB 的更多用法（CRUD、索引聚合、副本集）见 [[MongoDB 01 - 基础概念与CRUD]] 与 [[MongoDB 04 - 学习路线]]。

## 五、导入初始数据

Leanote 应用的初始数据（比如初始账号名称、密码）需要导入数据库中，使用 `mongorestore`：`-h` 指定数据库地址、`-d` 指定数据库名、`--dir` 指定要导入的数据文件目录。

```bash
mongorestore -h localhost \
-d leanote \
--dir leanote/mongodb_backup/leanote_install_data/
```

导入成功后，再用 `mongo` 命令连接数据库，即可看到已导入的集合与数据。

## 六、修改配置并启动应用

应用配置（启动端口号、域名、安全密钥等）在 `conf/app.conf` 中：

```bash
vim ${leanote路径}/conf/app.conf
```

没有特殊需求时这一步可以直接跳过。启动应用：

```bash
# 切换目录
cd leanote/bin
# 后台执行启动脚本
bash run.sh &
```

启动过程会输出一大堆日志，不用理会。之后浏览器访问 `http://${服务器地址或 localhost}:9000` 即可使用云笔记。

## 七、无法访问应用时如何排查

1. 用 `netstat -ntlp` 检查 `9000` 端口是否已被其他应用占用；若被占用，回到上一步修改 `app.conf` 中的端口号后重新启动
2. 进入服务器提供商控制台，在**防火墙**中开放 `9000` 端口

更系统的服务器访问排查步骤（端口监听 / 安全组 / 防火墙 / 应用层限制 / 网络连通等）见 [[Linux 03 - 进程管理与网络排查]] 的「服务器无法访问排查（7 步清单）」。

## 关键命令速查

| 阶段 | 命令 |
|------|------|
| 下载 Leanote | `wget <安装包地址> --no-check-certificate` |
| 解压 | `tar -zxvf *.tar.gz` |
| 装 MongoDB | `wget http://fastdl.mongodb.org/.../*.tgz` + `tar -xzvf` |
| 配置环境变量 | `export PATH=$PATH:$HOME/mongodb-linux-x86_64-3.0.1/bin` → `source /etc/profile` |
| 启动数据库 | `mongod --dbpath data &` |
| 连接数据库 | `mongo` / `show dbs` |
| 导入数据 | `mongorestore -h localhost -d leanote --dir <备份目录>/` |
| 启动应用 | `cd leanote/bin && bash run.sh &` |
| 排查端口 | `netstat -ntlp` |
| 访问 | `http://<服务器地址>:9000` |

> 来源：鱼皮·编程导航 / codefather
