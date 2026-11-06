---
title: "工具 40 - Solid.js 框架介绍（无虚拟 DOM 的编译型框架）"
date: 2026-09-20
tags: [Solid.js, 前端框架, 编译型框架, 性能优化, 技术选型]
source: "鱼皮·编程导航 / codefather"
---

# 工具 40 - Solid.js 框架介绍（无虚拟 DOM 的编译型框架）

> Solid 是一款用静态编译实现「无 Virtual DOM + 细粒度更新」的声明式 JavaScript UI 库，压缩后仅约 6 KB，在前端框架性能测试中长期位居前列。

## 一、Solid 是什么

国外的一个前端框架 / 库，官网自我描述为：**一个用于构建用户界面的声明性 JavaScript 库**，特点是高效、灵活。

- 曾是 GitHub 趋势榜上的「前端超新星」，短期内日增上千 star，Star 增长曲线近乎垂直
- 压缩后的代码体积仅约 **6 KB**
- 天然支持 **TypeScript** 与 **JSX**（React 中常见的写法）
- 语法与 React 神似，React 使用者迁移成本较低

> 当时的 JS 框架格局是 React / Vue / Angular 三分天下，外加新兴的 Svelte（潜力大、增速快），Solid 属于在同一赛道里又挤进来的一位选手。

## 二、为什么它快：不用 Virtual DOM

在主流 JS 框架性能测试对比中，Solid 位列第一梯队（通常仅次于作为「不引入框架的原生 JS 基准」的 Vanilla），超过 Vue 和 React。

核心原因在于 **它没有采用其他主流框架的 Virtual DOM**：

- 直接被**静态编译为真实的原生 DOM 节点**
- 把更新控制在**细粒度的局部范围**内
- 因此 runtime（运行时）更轻小，也没有所谓的脏检查、摘要循环带来的额外消耗
- 一句话：**编译后的 Solid 本质上就是 JavaScript**，性能与原生 JS 几乎无异

## 三、与 Svelte 的差异：同一段代码编译后的区别

Solid 的原理与新兴框架 Svelte 非常类似，都是编译成原生 DOM，但 Solid 仍更快一点。差异看同一段代码 `<div>{aaa}</div>` 编译后的产物：

**Svelte 编译结果** — 逐个创建真实节点：

```js
let a1, a2
a1 = document.createElement('div')
a2 = document.createTextNode('')
a2.nodeValue = ctx[0] // aaa
a1.appendChild(a2)
```

**Solid 编译结果** — 借模板字符串一次性产出节点：

```js
let a1, a2
let fragment = document.createElement('template')
fragment.innerHTML = `<div>aaa</div>`
a1 = fragment.firstChild
a2 = a1.firstChild
a2.nodeValue = data.aaa
```

可以看到，创建 DOM 节点时 Solid「耍了一点小把戏」：**利用 `innerHTML` 代替 `createElement`** 来批量创建节点，从而进一步提升性能。

## 四、客观看待

- 抛去 Virtual DOM 并不意味着就是「银弹」：十年前还没有各种框架时大家也都写原生 JavaScript，轻 runtime 同样有它的缺点（生态、团队上手成本、调试体验等），需要按项目权衡
- 除「快」之外，Solid 还有其他特点：语法精简、**WebComponent 友好**（可自定义元素）等
- 结论：它不一定动摇三大框架的地位，但给技术选型增加了一个选项——**没有绝对最好的技术，只有最适合的技术**

> 前端初学者不必急着追新：老老实实学 HTML / CSS / JS 三件套 + Vue / React 即可，框架的体系化学习路径见 [[工具 12 - 前端学习路线]]；同为「编译为原生 DOM」的框架可对照 [[工具 26 - Svelte 框架入门与读书笔记实战]]。

> 来源：鱼皮·编程导航 / codefather
