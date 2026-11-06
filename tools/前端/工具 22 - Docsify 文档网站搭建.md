---
title: "工具 22 - Docsify 文档网站搭建"
date: 2026-08-21
tags: [Docsify, 云开发, CloudBase, 静态网站, 文档网站, 前端]
source: "鱼皮·编程导航 / codefather"
---

# 工具 22 - Docsify 文档网站搭建

> 使用 docsify 动态生成文档网站 + 腾讯云开发静态托管，5 分钟把 Markdown 文档发布成可访问的网站，免去 GitHub Pages 的国外访问慢问题。

## 为什么选 docsify + 云开发

- **docsify**：动态生成文档网站的工具，用 Markdown 写文档、自动生成简洁优雅的网站（多种主题），无需关心格式，专注内容本身。
- **对比**：GitBook 是国外网站访问慢；简书写文档限制多不够灵活；GitHub Pages 托管同样受中美网络波动影响、访问速度慢。
- **云开发（CloudBase）**：云端一体化产品方案，serverless 架构、免环境搭建等运维事务、支持一云多端；静态网站托管支持通过云开发 SDK 调用云函数、云存储、云数据库等服务端资源，可将静态网站扩展为全栈网站。
- **计费**：开通**按量付费**模式才支持静态网站托管，有免费资源（超出用量才计费）。

## 本地初始化文档网站

前置依赖：安装 Node.js（nodejs.org 下载）。

```bash
# 安装 docsify-cli 工具（创建 + 本地预览）
npm i docsify-cli -g

# 初始化项目，创建 mydocs 目录
docsify init mydocs
```

生成的目录结构：

```
mydocs/
├── README.md    # 入口文件，index.html 会作为主页内容渲染
└── index.html
└── .nojekyll    # 阻止 GitHub Pages 忽略下划线开头的文件，不用关心
```

- 直接编辑 `README.md` 即可更新网站内容，也可以写多个页面。
- 本地启动服务器（支持热加载，改文档自动更新、实时预览）：

```bash
docsify serve mydocs
```

浏览器打开 `http://localhost:3000` 查看效果。

## 部署到云开发静态托管

### 开通云环境

1. 进入腾讯云云开发（cloudbase）控制台，点击「立即创建」开通一个云环境。
2. **注意选择「按量计费」模式**（只有按量计费才能开通静态网站托管），使用免费资源，超过用量才计费。
3. 创建完成后点击「开始使用」，初始化静态网站服务。

### 方式一：界面上传

1. 在文件管理页点击「上传文件」，将本机 mydocs 目录下的 `index.html` 与 `README.md` 上传。
2. 进入设置页，使用默认域名即可访问文档网站（默认读取 index.html 展示，也可自己修改索引文档）。

### 方式二：命令行上传（cloudbase cli）

```bash
# 安装 CLI
npm install -g @cloudbase/cli

# 登录授权（弹出页面确认）
cloudbase login

# 进入 mydocs 目录部署（EnvID 替换为云环境 ID）
cd mydocs
cloudbase hosting:deploy . -e EnvID
```

部署完成后，与界面上传一样，在设置页用默认域名访问即可。

## 进阶

- 把 cloudbase cli 配置到 CI 环境中，可实现文档网站自动部署。

> 来源：鱼皮·编程导航 / codefather
