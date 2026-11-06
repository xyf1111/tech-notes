---
title: "前端工具 - Ant Design Pro 入门与初始化"
date: 2026-07-28
tags: [Ant Design Pro, React, 前端框架, 企业级开发]
source: "鱼皮·编程导航 / codefather"
---

# 前端工具 - Ant Design Pro 入门与初始化

## 1. 什么是 Ant Design Pro？

Ant Design Pro 是由蚂蚁金服开发、基于 Ant Design 组件库的企业级前端开发框架，专门用于构建中后台管理和企业级 Web 应用。

它提供了一整套前端中后台解决方案，涵盖：
- **路由** — 约定式路由配置
- **权限管理** — 角色 / 权限控制
- **国际化** — 多语言支持
- **数据 mock** — 前后端分离开发
- **工程化** — 构建、打包、部署
- **数据流管理** — Umi 内置数据流方案

Ant Design Pro 开箱即用，一条命令就能得到一个完整的管理系统站点，大幅减少前期配置和重复劳动。

---

## 2. Ant Design 生态体系

Ant Design Pro 不是孤立的工具，它属于蚂蚁金服前端技术"全家桶"的一部分，相关生态包括：

### 2.1 Ant Design（核心组件库）

一套企业级 UI 设计语言和 React 组件库，提供丰富的界面组件、图标、布局和样式。遵循统一的设计规范，保证一致的用户体验。

- 官网：https://ant.design/
- 同时提供 Vue 版本（Ant Design Vue），跨框架保持编码和效果一致性
- 各框架文档入口：React 版 https://ant.design/docs/react/introduce-cn ｜ Angular 版 https://ng.ant.design/docs/introduce/zh

### 2.2 Ant Design ProComponents（高级业务组件）

在 Ant Design 基础上封装的高级业务组件库，包含高级表格、高级表单、高级描述列表等，专为中后台场景定制，进一步提高开发效率。

- 官网：https://procomponents.ant.design/

### 2.3 AntV（数据可视化）

一套完整的数据可视化组件和工具库，包含 G2（统计图表）、G6（图可视化）、F2（移动端图表）等子库，满足不同类型的数据可视化需求。

- 官网：https://antv.antgroup.com/

### 2.4 Ant Design Mobile（移动端组件库）

Ant Design 组件库的移动端版本，支持 React 和 Angular 两个主流框架，提供丰富的移动端组件；直接打开文档、复制代码略加修改即可使用。

- React 版文档：https://mobile.ant.design/docs/react/introduce-cn
- Angular 版文档：https://ng.mobile.ant.design/#/docs/introduce/zh

### 2.5 Ant Design Pro（中后台系统模板）

开箱即用的中后台前端系统，封装了监控页、表单页等企业后台常用页面与组件（甚至内置图形编辑器），适合有 React 经验的同学直接使用，不建议小白直接用（可能不会改）。**本文即围绕它展开**，初始化与使用见第 3 节起。

- 地址：https://pro.ant.design/index-cn

### 2.6 Ant Design Landing（首页搭建）

前端开发者「偷懒」的神器：**不用写代码就能做出精美的网站首页**。平台提供丰富的各类首页模板，下载模板代码包即可快速使用，也可在现有模板基础上做定制化编辑。

- 地址：https://landing.ant.design/index-cn

### 2.7 Scaffolds（脚手架市场）

Ant Design 脚手架市场，允许开发者把自研的模板页面、项目启动框架、组件、工具发布到这里分享；也可以在其中找到大量能节省开发工作量的现成优秀代码。

- 地址：https://scaffold.ant.design

### 2.8 Ant Motion（动效库）

Ant Design 风格的动效库，提供各种常用动画与灵活的高级动效组件。

- 地址：https://motion.ant.design/index-cn

### 2.9 Ant Design Charts（图表库）

对 AntV 数据可视化能力的封装，可以**以 Ant Design React 组件的方式直接使用图表**，与组件库的开发体验保持一致。

- 地址：https://charts.ant.design/

> 生态小结：Ant Design 不只是组件库 —— 它是「设计体系 + 组件库（React/Vue/Angular）+ 移动端 + 中后台模板 + 首页模板 + 脚手架市场 + 动效 + 图表」的一整套方案，所有产品遵循同一套设计规范，因此视觉体验一致。蚂蚁金服的各个项目中都有使用 Ant Design。

> 这套生态组合被称为"Ant Design 全家桶"，学一套即可覆盖大部分前端开发场景。

---

## 3. 快速初始化

### 3.1 环境准备

- Node.js ≥ 14.x（推荐 16.x，v18+ 可能遇到兼容问题）
- 包管理器：npm / yarn（推荐 yarn，速度更快）

### 3.2 安装脚手架并创建项目

```bash
# 全局安装 Pro CLI 脚手架
npm i @ant-design/pro-cli -g

# 使用 CLI 创建项目
npx pro create myapp
```

### 3.3 项目类型选择

创建过程中 CLI 会提示选择 umi 版本：

- **umi@3** — 适合需要 UMI UI 插件的场景，生态成熟
- **umi@4** — 更新的版本，但部分插件可能不兼容

> 实操建议：选择 `umi@3`，社区资源和插件支持更丰富。

### 3.4 安装依赖

```bash
cd myapp
yarn                     # 安装项目依赖

# 如需使用 UMI UI 插件（"小米饭"插件），额外安装：
yarn add @umijs/preset-ui -D
```

### 3.5 启动项目

```bash
yarn start               # 或通过 package.json 中的 start 脚本运行
```

启动后在浏览器访问 `http://localhost:8000` 即可看到初始的管理系统界面。

---

## 4. 项目优化：前端瘦身

Ant Design Pro 初始化项目包含较多示例和工具文件，对于学习或小型项目可选择性清理，减少项目体积和编译时间。

### 4.1 去除国际化（i18n）

如果项目不需要多语言支持，可移除国际化代码：

```bash
yarn i18n-remove         # 执行国际化移除脚本
```

它会自动扫描并移除项目中的国际化包装代码。

### 4.2 删除测试与示例文件

| 路径 / 文件 | 说明 | 操作建议 |
|---|---|---|
| `src/e2e/` | 端到端测试（业务流程测试） | 可删除 |
| `tests/` | 单元测试文件 | 小项目可删除 |
| `src/services/swagger/` | Swagger 接口文档工具生成的代码 | 可删除 |
| `config/openapi.json` | OpenAPI 配置（定义接口路径） | 如无接口文档需求可删除 |

### 4.3 删除原则

> ⚠️ **删一个文件，启动一遍项目**，确认运行无误后再继续删下一个，避免项目跑不起来后难以定位问题。

---

## 5. 常见问题

### 5.1 Node 版本兼容

- Ant Design Pro v4/v5 对 Node 版本有一定要求，**推荐使用 Node 16.x**
- Node 18.x 及以上版本已知可能遇到编译报错（如 node-sass、gyp 相关错误）
- 务必通过 **nvm**（Node Version Manager）管理多个 Node 版本，按项目需求灵活切换

> nvm 的详细安装和配置请参考同目录下《Node 版本管理 - NVM 使用.md》。

### 5.2 UMI UI 插件无法访问

如果安装了 `@umijs/preset-ui` 但无法访问插件界面（白屏或网络错误），可能是网络代理或环境问题。该插件非必须，不影响项目正常运行。

### 5.3 旧版 Node 卸载

在通过 nvm 切换版本前，建议卸载系统预装的旧版 Node.js，避免路径冲突引起 nvm 切换失效。（注意：GPT 等 AI 工具可能给出错误建议，实操以验证为准。）

---

## 6. 学习建议

### 6.1 以官方文档为准

Ant Design Pro 版本迭代较快，**务必阅读官方文档** 来学习，不要完全照搬教程视频：

- 官方文档：https://pro.ant.design/zh-CN/docs/getting-started/
- 文档涵盖入门、开发到部署的全流程，按顺序阅读即可

### 6.2 版本选择

- **v4 版本** — 社区广泛使用，资料和视频教程以 v4 为主，更稳定
- **v5 版本** — 更新，但 API 变化较大，与 v4 不兼容
- 根据项目需求选择合适的文档版本

### 6.3 新手建议

- 创建项目时选择 **`simple` 模板**（而非 full / complete），避免一次性引入过多代码和依赖
- **边读文档边实践**，多修改代码、查看效果，理解框架的运行机制

### 6.4 报错排查

学习 Ant Design Pro 遇到报错时：

1. **检查最新官方文档** — 确认命令和用法是否已更新
2. **切换文档版本** — 如跟随 v4 视频教程，将文档切回 v4
3. **搜索错误信息** — 复制错误全文到百度 / Google 搜索
4. **Github Issues** — 在 [Ant Design Pro Issues](https://github.com/ant-design/ant-design-pro/issues) 搜索，99% 的问题已有人遇到并解决

> 任何教程都有保质期，学会阅读官方文档和自主排查，才是长久之计。

---

## 参考来源

- [鱼皮·编程导航] 前端必学的开发框架，Ant Design Pro
- [D·编程导航] 前端初始化 Ant Design Pro 笔记
- Ant Design Pro 官方文档：https://pro.ant.design/
