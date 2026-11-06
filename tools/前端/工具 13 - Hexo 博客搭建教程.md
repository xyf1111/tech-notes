---
title: "工具 13 - Hexo 博客搭建教程"
date: 2026-07-21
tags: [Hexo, 博客, GitHub Pages, Netlify, 前端]
source: "鱼皮·编程导航 / codefather"
---

# 工具 13 - Hexo 博客搭建教程

> 使用 Hexo 静态网站框架 + GitHub Pages + Netlify 搭建个人博客的完整流程。

## 环境准备

### 安装 Node.js

从 [nodejs.cn](http://nodejs.cn/) 下载安装包，安装后验证：

```bash
node -v
npm -v
```

### 配置国内镜像源（可选）

```bash
npm config set registry https://registry.npm.taobao.org
```

### 安装 Hexo

```bash
npm install -g hexo-cli
hexo -v   # 验证安装
```

## 初始化博客

```bash
# 创建并进入博客目录
mkdir my-blog && cd my-blog

# 初始化
hexo init
npm install

# 生成静态页面并启动本地预览
hexo g
hexo server    # 简写: hexo s
```

访问 `http://localhost:4000` 查看效果，按 `Ctrl+C` 关闭本地服务器。

## 部署到 GitHub Pages

### 创建 GitHub 仓库

在 GitHub 新建仓库，命名格式：`<你的用户名>.github.io`

### 配置部署

编辑博客根目录的 `_config.yml`，修改最后一行：

```yaml
deploy:
  type: git
  repository: https://github.com/<用户名>/<用户名>.github.io.git
  branch: master
```

### 安装部署插件

```bash
npm install hexo-deployer-git --save
```

### 部署

```bash
hexo clean
hexo generate   # 简写: hexo g
hexo deploy     # 简写: hexo d
```

访问 `https://<用户名>.github.io` 即可看到博客。

## 个人域名

1. 购买域名（阿里云等平台）
2. 在 DNS 解析中添加记录，指向 GitHub Pages IP
3. 在 GitHub 仓库 **Settings → Custom domain** 填写域名
4. 在 `source/` 目录新建 `CNAME` 文件（无后缀），写入域名
5. 重新部署

## 写文章

```bash
hexo new post "文章标题"
```

编辑 `source/_posts/文章标题.md`（Markdown 格式），预览后部署：

```bash
hexo g && hexo d
```

## 更换主题

- 在 [Hexo 主题官网](https://hexo.io/themes/) 选择主题
- 下载主题文件放入 `themes/` 目录
- 修改 `_config.yml` 的 `theme` 字段
- 参考主题的文档进行个性化配置

## 常用功能

| 功能 | 说明 |
|------|------|
| 评论系统 | Twikoo、Valine、Disqus |
| 访问统计 | 不蒜子统计、Google Analytics |
| 文章字数统计 | 主题内置支持 |
| 搜索功能 | 配置 SEO 插件 |
| 分类与标签 | 在 Front-matter 中设置 |

## 使用 Netlify 自动部署

1. 用 GitHub 账号登录 [Netlify](https://www.netlify.com/)
2. 关联博客源码仓库
3. 配置构建命令：`hexo generate`
4. 设置发布目录：`public/`
5. Netlify 自动在每次 push 时部署，并提供 CDN 加速和免费 SSL

## Hexo 目录结构

```
my-blog/
├── node_modules/    # 依赖包
├── public/          # 生成的静态文件（部署用）
├── scaffolds/       # 文章模板
├── source/
│   └── _posts/      # 文章 Markdown 文件
├── themes/          # 主题文件夹
├── _config.yml      # 站点配置文件
└── package.json     # 依赖配置
```

> 来源：鱼皮·编程导航 / codefather
