---
title: "Linux 虚拟机搭建与远程开发"
date: 2026-08-23
tags: [Linux, 虚拟机, VMware, SSH, 远程开发]
source: "鱼皮·编程导航 / codefather"
---

# Linux 虚拟机搭建与远程开发

> 手把手在 Windows 上免费搭建一台 Linux 虚拟机，从下载 VMware、安装 Ubuntu 到配置系统一气呵成，再实践两种基于 SSH 的远程开发方式，像用本机一样在 Linux 上编码、构建、部署和调试。

## 为什么需要一台 Linux 虚拟机

在 Windows 上直接安装 Docker 需要依赖 WSL（Windows Subsystem for Linux），经常出现内核版本太低、缺少 WSL 之类的报错，折腾起来很麻烦。想要一台 Linux 环境，常见有两条路：

- 购买第三方云服务商的云服务器（要花钱）
- 使用虚拟机软件，在自己电脑上额外运行一个 Linux 系统（免费、几分钟搞定）

本篇实践第二种方案：在 Windows 上安装 VMware Workstation Player + Ubuntu 虚拟机，并配置远程开发环境。

## 一、安装 VMware Workstation Player

### 1. 下载与安装

- 推荐使用 VMware Workstation Player，个人非商业使用免费；官网下载：<https://www.vmware.com/cn/products/workstation-player.html>（条件允许也可以选功能更全的 Workstation Pro，但要付费）
- 安装时注意勾选两个选项：**自动安装 Windows Hypervisor Platform**、**将 VMware Workstation 控制台工具添加到系统 PATH**
- 版本选择免费、非商用版本（Free for Personal Use）

## 二、安装 Linux 系统（Ubuntu）

### 1. 选择发行版

- 曾经的经典 CentOS 已经停止维护，新手推荐选择带图形界面的 **Ubuntu 18.04 LTS**
- 镜像下载：<https://releases.ubuntu.com/18.04/>，拉到底部找到 `.iso` 后缀的文件下载（熟悉 Linux 的同学可以自由选择其他发行版）

### 2. 新建虚拟机

1. 打开 VMware，点击"创建新虚拟机"，指定刚才下载的 Ubuntu 镜像
2. 根据电脑实际配置自定义虚拟机硬件，内存和 CPU 可以多分配一些
3. 点击完成，稍等片刻系统即自动安装完成并启动

## 三、虚拟机基础配置

### 1. 修改语言为中文

1. 按 `Windows` 键搜索 "language"，打开"语言支持"
2. 点击"添加语言"→ 选择中文简体，把"汉语"拖到语言列表最上面 → 点击"应用到整个系统"
3. 等待语言包和输入法安装完成，重启虚拟机
4. 重启后按 `Windows` 键搜索 "language"，打开"区域和语言"，新增输入源，添加已安装的中文输入法

### 2. 修改分辨率

打开"显示设置"，调整分辨率和字体大小。

### 3. 修改时间

默认时区可能不对，打开"日期和时间"设置，将时区改为"中国上海"。

## 四、安装软件（以 Docker 为例）

Ubuntu 自带应用商店，可以可视化一键安装软件（如防火墙），适合新手；但 Linux 上更常用的是命令行安装。按 `Ctrl + Alt + T` 打开终端，安装 Docker：

```bash
sudo apt install docker.io        # apt 是软件包管理工具
docker -v                          # 查看 Docker 版本
sudo docker run hello-world        # 测试 Docker 能否正常运行
```

看到 hello-world 的正常输出，说明 Docker 安装成功——比在 Windows 上折腾 WSL 方便多了。

## 五、远程开发前置准备

远程开发的核心思路：不在虚拟机里装一堆开发工具来回切换，而是直接在 Windows 上操作 Linux 服务器，开发方式和平时完全一致。

### 1. 网络连通

1. 在虚拟机设置中搜索"网络"，查看网络设置，记下虚拟机的 **IPv4 地址**
2. 在 Windows 上 `ping 虚拟机IP` 测试连通性，能 ping 通说明网络正常

> NAT 模式、VMnet8 虚拟网络编辑器、端口转发、静态 IP 等网络配置详见 [[DevOps 01 - 虚拟机局域网访问配置]]。

### 2. 开启 SSH

很多远程开发工具都是通过 SSH 协议连接远程服务器的，需要在虚拟机里安装并开启 SSH：

```bash
sudo apt-get install openssh-server   # 安装 SSH 服务器
ps -e | grep ssh                       # 检查 SSH 是否已开启
sudo service ssh start                 # 如果未启动，手动启动
```

SSH 开启后，也可以在 Windows 命令行直接验证连接：`ssh 用户名@虚拟机IP`。

### 3. 安装 Java JDK

```bash
sudo apt update               # 更新软件源信息
sudo apt install openjdk-8-jdk   # 安装 Java 8
java -version                 # 检查版本
```

### 4. 安装 Maven

```bash
sudo apt install maven
mvn -v                        # 查看版本号
```

## 六、远程开发方式一：远程部署（IDEA + 自动同步）

思路：在本地 IDE 编写代码，把代码文件定期同步到 Linux 服务器，再用本地电脑操作远程服务器完成运行、构建、部署、调试。这种方式主要提高"本地编码 + 服务器部署"的效率，不算真正意义上的远程开发，但效果接近。

以 Spring Boot 项目为例，远程开发主要分 6 个阶段：**编码、文件同步、运行、编译构建、部署、调试**。

### 1. 编码 + 文件同步

1. 在 IDEA 中点击 Tools => Development => Configuration，配置 SSH 连接：输入服务器实际的 IP、用户名、密码，点击 Test Connection 测试（报错多半是 IP / 用户名 / 密码不对）
2. 在 Mappings 中配置路径映射：把本地代码目录同步到远程服务器的指定路径
3. 保存后，IDEA 右侧即可看到虚拟机的文件列表；点击 Tools => Development => Automatic Upload 开启自动同步
4. 进入 Options 配置，勾选文件删除的同步（否则本地删文件时，服务器上的文件不会跟着删）

之后在本地写的代码都会自动同步到服务器。

### 2. 运行项目

在 IDEA 终端中打开远程服务器的终端，`cd` 进入代码目录后执行：

```bash
mvn clean
mvn spring-boot:run
```

项目启动成功后，访问 `http://虚拟机IP:8080/health`，能看到输出说明已能正常访问服务器上运行的项目。也可以在 Deployment 界面配置 web server url 作为快捷访问方式。

### 3. 构建项目

```bash
mvn package
```

打包成功后，在服务器上可以看到生成的可执行 jar 包。

### 4. 部署项目

以生产环境配置运行 jar 包：

```bash
java -jar /home/用户名/code/target/项目名-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
```

### 5. 远程调试

- 注意：远程调试开发时可以用，但千万别给线上环境打断点，会影响正常用户访问
- 在 IDEA 右上角 Edit Configurations → 新建 Remote JVM Debug 配置，填写虚拟机 IP、远程调试端口、JDK 版本，IDEA 会自动生成一段调试参数
- 启动项目时，把生成的 command line 参数追加到启动命令中，**注意要加在 jar 包路径之前**：

```bash
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar /home/用户名/code/target/项目名-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
```

- 启动项目后在右上角开启 Debug，给代码打断点，再访问对应端口即可看到 Debug 生效

## 七、远程开发方式二：纯远程开发（IDEA SSH / JetBrains Gateway）

思路：本地的编译、构建、调试、运行全部放在远程服务器执行，本地只运行一个轻量的客户端界面，不存放代码、不负责程序运行。很像云游戏，适合本地电脑性能差（服务器性能强）、需要统一开发环境、多人协作开发的场景。

1. 进入 IDEA 主页，找到 SSH 选项，点击新建项目，配置 SSH 连接
2. 指定远程开发的代码路径
3. 首次使用需要下载 JetBrains Client 客户端，服务器端会自动安装对应的远程开发后端
4. 进入客户端后，软件自动加载 Maven 项目，手动指定服务器上已安装的 JDK
5. 直接以 Debug 模式启动项目，配置请求转发（端口转发）后，访问 `http://127.0.0.1:8080/health` 就能访问到项目，直接支持 Debug，无须多余配置

## 八、其他远程开发方式：VS Code Remote-SSH

VS Code 也可以实现类似体验：安装 Remote-SSH 插件 → `Ctrl+Shift+P` → Remote-SSH: Add New SSH Host → 输入 `ssh 用户名@主机地址 -A` 连接 → 打开远程文件夹开始开发。详细步骤见 [[DevOps 05 - VS Code 远程开发实战]]。

## 小结

虚拟机 + 远程开发的方式，可以让你在不影响现有 Windows 系统的情况下，愉快地学习 Linux、Docker 等技术。两种远程开发方式中，纯远程开发更简单、更丝滑，本地客户端非常轻量。

## 参考

- 视频教程（讲解更细节，建议配合本文）：<https://www.bilibili.com/video/BV1h94y1k7Jf/>
- VMware Workstation Player 下载：<https://www.vmware.com/cn/products/workstation-player.html>
- Ubuntu 18.04 镜像：<https://releases.ubuntu.com/18.04/>

> 来源：鱼皮·编程导航 / codefather
