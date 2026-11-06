---
title: "工具 36 - 代码编辑器与 IDE 一览"
date: 2026-09-19
tags: [工具, 编辑器, IDE, VS Code, JetBrains, Web IDE]
source: "鱼皮·编程导航 / codefather"
---

# 工具 36 - 代码编辑器与 IDE 一览

> 从记事本到云端 IDE 的完整工具谱系：轻量文本编辑器（Notepad / Notepad++ / Sublime Text / Vim / VS Code / Atom）、功能完整的本地 IDE（JetBrains 全家桶 / Visual Studio / Eclipse / 各语言「独角兽」）、Web 编辑器与 Web IDE（Coder / StackBlitz / Codespaces / Gitpod / Coding）。作者的日常组合是 JetBrains 全家桶 + Sublime Text + Web 编辑器 + Web IDE。

## 核心要点

### 一、本地编辑器（轻量，写代码片段与简单页面）

- **Notepad（Windows 自带记事本）**：最原始、最纯洁的代码编辑器，把文件另存为 `.html` 后双击即可运行网页。**完全没有代码提示与校验**，缩进、代码正确性全靠自己保证，反而很适合新手培养写代码规范
- **Notepad++**：开源免费的文本编辑器，软件轻小却支持几十种编程语言，拿来写代码片段没问题，开发项目也不在话下
- **Sublime Text**：极其轻量、界面简洁、基本做到秒开，同样支持安装各种插件。作者把它当「副武器」：临时记录或编辑代码（当灵活的备忘录 / 剪切板）、阅读从服务器下载的日志与 dump 文件、做文本替换与代码格式化
- **Vim**：Linux 系统上的文本编辑器，没有华美界面、操作都在终端里进行，需要花时间学快捷键；一旦上手就很高效。后端开发经常要编辑服务器上的文件，至少要掌握它的基础用法
- **VS Code**：微软 2015 年发布的**免费开源**轻量级代码编辑器，装插件后可打造成支持一切编程语言的 IDE，知名插件「**远程开发**」大大提高了效率（详见 [[DevOps 05 - VS Code 远程开发实战]]）
- **Atom**：GitHub 开源的编辑器，官方称其为「21 世纪的极客编辑器」，界面简洁炫酷、可装插件增强为 IDE；但比 Sublime Text 重，且早期输入时频繁闪退（作者已弃用）

### 二、本地 IDE（功能完整，企业级项目开发）

- **JetBrains 全家桶**：几乎覆盖所有主流语言的集成开发环境——IDEA 写 Java、WebStorm 写前端、PhpStorm 写 PHP、GoLand 写 Go，可用 Toolbox 集中管理；作者最喜欢、最常用（详见 [[Java 工具 15 - IDEA 高效开发技巧]]）
- **Visual Studio**：微软多年之作，功能极其强大且丰富，支持 Android / iOS / Mac / Windows / Web 与云应用开发；代价是**极其庞大**（安装、卸载都很痛苦，C 盘直接爆炸），功能太多不适合新手
- **Eclipse**：老牌的跨平台 IDE，早期学 Java / PHP 的常用选择；界面风格、使用体验、功能丰富度、插件生态整体不如 JetBrains 系列
- **按语言 / 方向选用的「独角兽」**：HBuilder X（前端与小程序）、Android Studio（移动端 App）、Dev-C++ / Code::Blocks（C++ 小项目）、Qt Creator（C++ 图形界面软件）

### 三、Web 编辑器与 Web IDE（把开发环境搬上云端）

- **Web 编辑器**：直接在浏览器里写代码并运行小段代码，如 dooccn、菜鸟教程编译工具、JsRun 小闪电、BeJSON；工作中临时写个小脚本时比本地 IDE 更高效
- **Web IDE**：把整套本地厚重的开发环境搬上云端，可在网页中开发项目、甚至多人实时协作开发——基于 VS Code Web 版的有 Coder、StackBlitz、Codespaces、Gitpod；编写并分享前端片段用 CodePen、CodeSandbox；国内的 Coding 还支持把整个研发流程集成到云端；新兴语言与框架也常自带官方 Web IDE（如 HarmonyOS 在线开发体验环境、区块链技术 Solidity 的 IDE），快速体验一门新技术时可省去搭环境
- 各类在线编程平台的具体用法见 [[工具 33 - 在线编程网站与在线 IDE]]

### 四、工具组合与选型建议

作者工作中一般使用 **JetBrains 全家桶 + Sublime Text + Web 编辑器 + Web IDE**：

1. 主开发工具选 JetBrains 的 3 点理由：**功能强大、插件丰富**；**知名度高、维护用心**；**自成体系、生态广泛**——全栈开发常要跟着项目写不同语言，全家桶界面风格、工具用法、快捷键保持一致，能降低语言切换与工具学习成本
2. JetBrains 的缺点是太重（16 G 内存的笔记本开 2-3 个项目可能就卡），老电脑上可改用更轻量的 VS Code
3. 轻量编辑器（Sublime Text 这类）适合临时记录、阅读大文件（日志 / dump）、文本替换与格式化
4. 建议给工具装插件增强功能：快捷键提示、代码提示、代码美化、代码检测、代码生成、代码小地图等
5. **初学者不要被环境搭建劝退**：直接在线上手写代码更容易提起对编程的兴趣，才能坚持学下去（学习路线里的开发工具清单见 [[工具 12 - 前端学习路线]]）

> 来源：鱼皮·编程导航 / codefather
