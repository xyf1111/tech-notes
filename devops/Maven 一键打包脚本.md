---
title: "DevOps - Maven 一键打包脚本"
date: 2026-08-19
tags: [DevOps, Maven, 效率工具]
source: "鱼皮·编程导航 / codefather"
---

# DevOps - Maven 一键打包脚本

> 用脚本代替 IDE 手动点击，实现 Maven 项目一键打包。

## 核心要点

- 把打包命令写进脚本文件，双击（或一行命令）即可完成构建，避免反复打开 IDE 操作
- 脚本放在程序 `src` 目录的同级路径下
- 核心命令：`mvn clean install -Dmaven.test.skip=true`

## 脚本写法

### Windows（.bat）

创建 txt 文件，粘贴以下代码后改后缀为 `.bat`，双击运行：

```bat
@echo off
echo [INFO] build and install modules.
call mvn clean install -Dmaven.test.skip=true
pause
```

### Linux / macOS（.sh）

```bash
#!/bin/bash
mvn clean install -Dmaven.test.skip=true
```

赋予执行权限 `chmod +x build.sh` 后 `./build.sh` 即可。

## 命令参数解释

| 参数 | 作用 |
|------|------|
| `clean` | 清理之前的构建结果 |
| `install` | 安装构建好的模块到本地仓库 |
| `-Dmaven.test.skip=true` | 跳过测试阶段，直接构建安装 |
| `@echo off` | 关闭命令回显，执行时不显示命令本身 |
| `pause` | 暂停程序执行，等待按任意键继续（Windows 专属） |

## 注意事项

- 跳过测试能显著加快打包速度，但**上线前仍应完整跑一遍测试**
- 多模块项目在根目录执行即可递归构建所有子模块

> 来源：鱼皮·编程导航 / codefather
