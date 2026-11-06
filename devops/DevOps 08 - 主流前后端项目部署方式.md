---
title: "DevOps 08 - 主流前后端项目部署方式"
date: 2026-08-25
tags: [部署, Nginx, Docker, 宝塔, 静态托管, DevOps]
source: "鱼皮·编程导航 / codefather"
---

# DevOps 08 - 主流前后端项目部署方式

> 前端 / 后端项目的主流部署方式全景：web 服务器、宝塔面板、静态网站托管、容器、容器托管平台。免费托管平台的实操细节见 [[DevOps 06 - 免费上线网站的几种方法]]。

## 前端部署

前端项目打包后是一个目录（index.html 入口 + css/js），核心问题是两个：**文件放哪里** + **怎么提供访问能力**。

### 1. web 服务器

把文件放到服务器上，用 Nginx / Apache / Tomcat 等 web 服务器提供访问，改配置文件指定「哪个端口 → 哪个目录」：

```
server {
  listen 80; # 监听端口，http 80 https 443
  server_name dogyupi.com; # 域名
  index index.html; # 主页文件
  root /web/xxx; # 网页文件所在目录
}
```

### 2. 宝塔 Linux

仍是 web 服务器方案，但用宝塔**可视化地安装和管理**服务器软件（一键装 Nginx、方便改配置），适合访问量不大的新网站。

### 3. 静态网站托管

没有完整服务器时，把网页文件放到托管平台：GitHub Pages、Gitee Pages、腾讯云静态网站托管等，代码上传到指定分支/目录即可；也可以把网页文件像图片一样扔到**对象存储平台**（可搭配 CDN 加速）。

⚠️ 仅限静态页面——必须每个页面路由都有对应 html 文件，否则刷新页面可能 404（SPA 需另行处理）。

### 4. 容器

用 Docker 把 web 服务器 + 网页文件打成镜像：copy 一个 Dockerfile → `docker build` 构建镜像 → `docker run` 执行。

### 5. 容器托管平台

容器方案的升级：手动构建镜像、关老容器、起新容器太麻烦且无法统一管理。用云服务商提供的容器托管平台（如微信云托管）可实现**自动化构建、版本化发布**等一系列能力。

## 后端部署

以 Java 为例，打包产物分两种：war 包（依赖外部 web 服务器）和 jar 包（内嵌 web 服务器可直接运行），对应不同部署方式。

### 1. web 服务器（war 包）

部署 war 包用 tomcat / jetty：手动安装 tomcat，改几行配置让它找到 war 包。⚠️ 尽量不要暴露 tomcat 的应用管理页面。

### 2. 直接启动（jar 包）

SpringBoot 打的 jar 内置 tomcat，一行命令启动：

```
java -jar app.jar --spring.profiles.active=prod
```

后台运行：开头加 `nohup`，结尾加 `&`。

### 3. 宝塔面板

懒得在服务器上手动装 java / maven / tomcat 环境，直接用宝塔面板可视化安装。

### 4. 容器

容器可以封装任意环境和应用：把 Java 环境、Maven、jar 包打成一个镜像。Dockerfile 可直接用 `maven:3.5-jdk-8-alpine` 这类基础镜像（自带 jdk + maven，省安装脚本）。需要时可在 Java 容器前加 Nginx 负载均衡。

### 5. 容器托管平台

只要是容器就能放到容器托管平台统一管理，与前端同理。

> 来源：鱼皮·编程导航 / codefather
