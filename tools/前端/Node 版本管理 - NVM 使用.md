---
title: "前端工具 - NVM 版本管理"
date: 2026-07-27
tags: [NVM, Node.js, 版本管理, 前端工具]
source: "鱼皮·编程导航 / codefather"
---

# 前端工具 - NVM 版本管理

> NVM（Node Version Manager）是 Node.js 版本管理工具，支持在同一系统中安装、切换多个 Node 版本。本文涵盖跨平台通用命令及 Windows 平台配置说明。

## 核心命令（跨平台通用）

### 安装指定版本

```bash
nvm install 18.16.0     # 安装指定版本
nvm install latest      # 安装最新版本
nvm install lts         # 安装最新 LTS 版本
```

### 版本切换

```bash
nvm use 18.16.0         # 使用指定版本
```

### 版本查看

```bash
nvm ls                  # 查看已安装版本列表
nvm list available      # 查看可安装版本列表
```

### 版本卸载

```bash
nvm uninstall 16.20.1   # 删除指定版本
```

## Windows 配置说明

### 下载与安装

推荐下载**免安装版**（`nvm-noinstall.zip`），版本 `1.1.12`。

免安装版需手动创建 `settings.txt` 配置文件：

```ini
root: D:\envs\nvm
path: D:\envs\nvm\nodejs
node_mirror: https://npmmirror.com/mirrors/node/
npm_mirror: https://npmmirror.com/mirrors/npm/
```

| 字段 | 说明 |
|------|------|
| `root` | NVM 解压目录路径 |
| `path` | Node.js 安装路径 |
| `node_mirror` | Node 镜像源（可替换为淘宝镜像） |
| `npm_mirror` | npm 镜像源（可替换为淘宝镜像） |

### 系统环境变量配置

**新建系统变量：**

| 变量名 | 变量值 |
|--------|--------|
| `NVM_HOME` | `D:\envs\nvm` |
| `NVM_SYMLINK` | `D:\envs\nvm\nodejs` |

**添加至 PATH 环境变量：**

```
%NVM_HOME%
%NVM_SYMLINK%
```

如配置了 npm/yarn 全局路径，需额外添加：

```
D:\envs\nvm\node_global
D:\envs\nvm\yarn_global\bin
```

## npm 全局路径修改

可通过修改 npm 配置，将全局包安装到 NVM 目录下，避免占用 C 盘：

```bash
npm config set prefix "D:\envs\nvm\node_global"
npm config set cache "D:\envs\nvm\node_cache"
```

查看配置：

```bash
npm prefix -g
npm config ls
```

## yarn 全局安装与路径配置

### 全局安装 yarn

```bash
npm install yarn -g
```

### 配置 yarn 路径

```bash
yarn config set prefix "D:\envs\nvm\yarn_global"
yarn config set global-folder "D:\envs\nvm\yarn_global"
yarn config set cache-folder "D:\envs\nvm\yarn_cache"
```

### 关闭 SSL 校验（可选）

yarn 安装包报证书失效时可执行：

```bash
yarn config set "strict-ssl" false -g
```

### 查看目录

```bash
yarn global bin
yarn global dir
yarn cache dir
yarn config list
```

> 来源：鱼皮·编程导航 / codefather
