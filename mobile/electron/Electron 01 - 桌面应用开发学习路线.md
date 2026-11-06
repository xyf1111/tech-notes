---
title: "Electron 桌面应用开发学习路线"
date: 2026-07-19
tags: [learning, frontend, electron]
source: "鱼皮·编程导航 / codefather"
---

# Electron 桌面应用开发学习路线

> 使用 Web 技术（HTML/CSS/JavaScript）构建跨平台桌面应用的学习路径。

## 学习前提

1. **JavaScript/TypeScript** — 熟练使用 ES6+ 语法
2. **HTML/CSS** — 掌握前端基础技术
3. **Node.js** — 理解基础概念（建议）
4. **React/Vue 等前端框架** — 提升开发效率（建议）

> 初学者务必先打好前端基础，不要直接从 Electron 开始。

## 为什么选择 Electron（选型考量与取舍）

**桌面端项目本身的取舍**（相对于网站 / 小程序等形态）：
- 不利于分享：用户要下载安装包、还要为它做官网宣传，分发成本高
- 不利于移植：Windows / macOS / Linux 多平台差异大，兼顾多系统的成本高
- 技术栈相对老旧：以 Java 桌面端为例，可选的组件与开发框架都很少
- 适用场景：只有当项目必须调用操作系统能力、且要求用户在本机安装使用时，才值得选桌面端

**选 Electron 的理由：**
- 跨平台，可用团队最熟悉的前端语言（HTML/CSS/JS）开发，几乎零学习成本
- 生态成熟稳定；不追最新框架（太新的反而不敢用）

**原理与注意点：**
- 本质是内置浏览器内核，相当于在桌面端里跑网页 → 打包产物体积偏大（如今带宽充足，影响不大）
- 兼容性坑：部分功能 Windows 能用、macOS 不能用，需在不同系统上分别打包测试，耗时较多
- 性能比不过原生应用，但实测体验可接受，且绝大多数系统能力都能通过 Electron 调用

## 核心架构：多进程模型

- **主进程（Main Process）** — 管理窗口和应用生命周期，类似后端
- **渲染进程（Renderer Process）** — 渲染页面，类似前端，每个窗口独立进程
- **预加载脚本（Preload Script）** — 主进程与渲染进程的桥梁，暴露安全 API

> 一个应用一个主进程，可有多个渲染进程。

## 阶段 1：Electron 基础（10-20 天）

### 知识点

**核心概念（必学）：**
- Electron 特点与优势
- Chromium + Node.js 的作用
- 进程模型：主进程、渲染进程、预加载脚本

**创建项目：**
- 项目初始化、package.json 配置
- 主进程入口（main.js）
- BrowserWindow 创建窗口

**开发环境：**
- VS Code、热重载（electron-reload）
- DevTools 调试

### 学习资源
- [Electron 官方文档（中文）](https://www.electronjs.org/zh/docs/latest/)
- [尚硅谷 Electron 教程](https://www.bilibili.com/video/BV1sE421N7M5)

## 阶段 2：进程间通信 IPC（10-20 天）

| 通信方向 | 方式 | 说明 |
|---------|------|------|
| 渲染→主进程 | ipcRenderer.invoke() / ipcMain.handle() | 推荐的双向通信（返回 Promise） |
| 渲染→主进程 | ipcRenderer.send() / ipcMain.on() | 单向通信 |
| 主→渲染进程 | webContents.send() | 主进程主动推送 |

**安全：** 渲染进程不能直接访问 Node.js API，需通过 **contextBridge** 在预加载脚本中暴露安全 API。

## 阶段 3：原生能力（7-20 天）

### 核心 API

| 功能 | API | 说明 |
|------|-----|------|
| 系统对话框 | dialog | 打开/保存文件、消息框 |
| 原生菜单 | Menu | 自定义菜单栏 |
| 托盘图标 | Tray | 最小化到系统托盘 |
| 文件系统 | Node.js fs | 文件读写、监听 |
| 系统通知 | Notification | 桌面通知 |
| 剪贴板 | clipboard | 读写剪贴板 |
| 全局快捷键 | globalShortcut | 注册系统快捷键 |

## 阶段 4：打包与发布（7-15 天）

**打包工具：**
- **electron-builder** — 打包为 exe/dmg/deb/rpm 等格式（最流行）
- **electron-forge** — 官方打包工具

**自动更新：**
- autoUpdater + electron-updater
- 搭建更新服务器

**代码签名（可选）：** Windows/macOS 代码签名可避免安全警告，个人开发者可跳过。

**分发渠道：** 官网下载、Microsoft Store、Mac App Store、Snap/Flatpak

## 阶段 5：项目实战（20-30 天）

### 入门项目
- Markdown 笔记本、待办事项应用
- 音乐播放器、图片浏览器

### 进阶项目
- 代码编辑器、聊天应用（IM）
- 视频播放器、文件管理器、系统监控工具

### 技术栈推荐
Vite + React/Vue + Electron

### 开源参考
- [Electron 官方](https://github.com/electron/electron)（119k+ stars）
- [VS Code](https://github.com/microsoft/vscode)（165k+ stars）
- [Electron React Boilerplate](https://github.com/electron-react-boilerplate/electron-react-boilerplate)

## 经典面试题

**基础概念：**
1. Electron 进程模型是怎样的？
2. 主进程和渲染进程的区别？
3. 预加载脚本的作用？

**IPC 通信：**
1. ipcRenderer.send 和 invoke 的区别？
2. 如何从主进程向渲染进程发送消息？
3. 什么是 contextBridge？为什么需要它？

**打包发布：**
1. Electron 如何打包？
2. 如何实现自动更新？

## 面试题库

- [面试鸭 - Electron 面试题](https://www.mianshiya.com/bank/1991432457391439874)

> 来源：鱼皮·编程导航 / codefather
