---
title: "工具 26 - Svelte 框架入门与读书笔记实战"
date: 2026-08-23
tags: [Svelte, 前端框架, 响应式, 读书笔记, 实战]
source: "鱼皮·编程导航 / codefather"
---

# 工具 26 - Svelte 框架入门与读书笔记实战

> Svelte 是一款通过静态编译实现「无 runtime、无 Virtual DOM」的响应式前端框架，本文讲解它的核心特性，并手把手用它开发一个可增删、可导出 Markdown 的读书笔记小网站。

## Svelte 是什么

Svelte 是近年崛起的构建用户界面的前端框架，与 Vue、React、Angular 三大主流框架并列的新选择，目前 GitHub 已有近 4w star，且增速很快。

- 框架自身具有**反应性**，帮助开发者书写更精简的代码，开发出体积更小、更迅速的 App
- 使用 Svelte 开发需要遵循其特定语法，编写 `.svelte` 后缀的文件

一个 `.svelte` 文件的 Hello World 结构如下：

```
<script>
 // 编写网页交互行为
</script>

<div>
 <!-- 编写页面内容结构 -->
</div>

<style>
 /* 编写 CSS 样式 */
</style>
```

## Svelte 新在哪儿

### 不依赖 runtime，无 Virtual DOM

在 20 多种前端框架 Demo 项目的对比评测中，Svelte 在项目**尺寸**和 **Lighthouse 性能评分**两方面都表现卓越，一个 Svelte Demo 项目仅有 **15 KB**。

传统框架（如 Vue、React）在项目运行时依赖框架本身的代码，即把框架作为 runtime 引入，框架代码会被打进项目包。例如 Vue 的 `package.json`：

```
"dependencies": {
  "vue": "^2.6.11"
}
```

而 Svelte 的核心思想是**通过静态编译减少框架运行时的代码量**（尤雨溪语）：它不会把自己打包进项目，而是在编译打包阶段将 Svelte 组件转换为**原生 DOM 操作**。因此项目不依赖 runtime，也没有 Vue/React 中的 Virtual DOM，体积非常小。Svelte 在 `package.json` 中只是作为开发时依赖：

```
"devDependencies": {
  "svelte": "^3.0.0"
}
```

与其说是「新」，不如说是回归原始、返璞归真。

### 自带反应性，无需状态管理库

Svelte 自身具有**反应性**，可以轻松实现状态管理，无需像 Vue/React 那样额外引入 Vuex、Redux 之类的状态管理库，给开发者提供了极大的便利。

## 十分钟开发读书笔记小项目

### 需求分析

开发一个读书笔记网站，记录每日学习内容，基本功能：

1. 添加读书笔记
2. 展示已添加的读书笔记
3. 删除某一条读书笔记
4. 导出读书笔记为 Markdown 格式文件并下载到本地

成品体验地址：https://read-note.now.sh/

### 1. 启动模板项目

两种方式获取 Svelte 官方模板项目：

**方式一**：直接下载压缩包并解压
https://github.com/sveltejs/template/archive/master.zip

**方式二**：用 degit 命令创建：

```
npx degit sveltejs/template svelte-app
```

进入项目目录安装依赖并启动：

```
npm install
npm run dev
```

- Svelte 使用 Rollup 作为 JS 模块打包工具
- 启动成功后浏览器访问 `localhost:5000` 即可看到模板页面

### 2. 开发界面

读书笔记只有一个主页面，布局分上下两部分：上方是相同样式卡片组成的列表，下方是固定在底部的操作面板。因此只需开发两个组件：**卡片 Card** 和**操作面板 AddCard**。

在 `src` 目录下新建 `.svelte` 文件（`App.svelte` 为模板自带的主页面）。`.svelte` 文件的语法结构与 Vue 类似，由 JavaScript、HTML、CSS 三部分组成。

#### 2.1 卡片组件 Card.svelte

每张卡片包含标题、内容、创建日期，带编号和不同颜色，鼠标移到卡片上时显示删除按钮。先用 `script` 定义属性变量（`export let` 声明对外属性）和删除函数：

```
<script>
  // 定义变量
  export let title; // 标题
  export let content; // 内容
  export let creationTime; // 创建日期
  export let index = 0; // 卡片序号
  
  // 删除卡片
  function doDelete() { }
</script>
```

用尖括号输出变量值，用 `on:click` 绑定鼠标点击事件：

```
<div class={`card bg-color-${index % 5}`}>
  <div class="title">
    {title} <span class="del-btn" on:click={doDelete}>x</span>
  </div>
  <div class="content">{content}</div>
  <div class="creationTime">{creationTime}</div>
</div>
```

样式直接写在组件 `style` 标签中（Svelte 会自动做样式隔离）：

```
<style>
  .card {
    padding: 1rem;
    margin: 1rem;
    color: #fff;
    border-radius: 0.5rem;
  }
  
  /* 省略... */
  
  /* 当鼠标移到卡片上，展示删除按钮 */
  .card:hover .del-btn {
    opacity: 1;
  }
</style>
```

#### 2.2 操作面板组件 AddCard.svelte

操作面板包含标题/内容两个输入框和「添加」「导出」两个按钮。Svelte 通过 `bind:value` 指令实现表单数据的**双向绑定**：

```
<script>
  // 在 src 目录下新建 utils 工具类，编写获取当前日期的函数
  import {getNowDateFormat} from "./utils";

  // 定义变量
  let title = ''; // 标题
  let content = ''; // 内容

  // 添加卡片
  function doAdd() { }

  // 导出笔记
  function doExport() { }
</script>

<div class="add-card">
  <div class="input-wrapper">
    <input class="input-title" type="text" placeholder="输入标题" bind:value={title} />
    <textarea class="input-content" placeholder="输入内容" bind:value={content}></textarea>
  </div>
  <button class="add-btn" on:click={doAdd}>添加</button>
  <button class="export-btn" on:click={doExport}>导出</button>
</div>
```

样式使用 Flex 布局，操作面板固定在页面底部：

```
<style>
  /* 操作面板固定在页面底部 */
  .add-card {
    position: fixed;
    bottom: 0;
    left: 0;
    width: 100%;
    box-sizing: border-box;
    padding: 1rem;
    background-image: linear-gradient(135deg, #FEC163 10%, #DE4313 100%);
    display: flex;
  }

  .input-wrapper {
    flex: 4; /* 使用 Flex 布局 */
  }

  /* 省略... */
  
  .add-btn, .export-btn {
    flex: 1;
    margin-left: 1rem;
    color: #666;
  }
</style>
```

#### 2.3 将组件放入主页面

在 `App.svelte` 中用 `import` 引入组件，通过 `{#each ...}{/each}` 循环语句渲染卡片列表，直接以组件名使用组件：

```
<script>
  import {cards} from './store'; // 引入 cards（状态）
  import Card from "./Card.svelte";
  import AddCard from "./AddCard.svelte";
</script>

<div id="app">
  {#each $cards as card, i}
    <Card {...card} index={i}/>
  {/each}
  <AddCard/>
</div>
```

### 3. 实现功能

读书笔记本质上是一个简单的增删改查项目。这里没有后端和数据库，直接使用 **Svelte 自带的状态管理 API** 实现本地数据管理，无需引入任何新依赖。

#### 3.1 管理卡片数据

在 `src` 目录新建 `store.js` 作为数据管理文件，通过 `writable` 函数定义可写的 `cards` 状态变量：

```
import {writable} from "svelte/store";

export const cards = writable([]);
```

`cards` 即可当作全局变量使用。在组件中想要使用状态变量，需要在变量名前加 `$` 符号（如 `$cards`）。

#### 3.2 添加卡片

实现 `AddCard.svelte` 的添加函数：校验输入后，调用状态变量的 `update` 函数在原数组后追加一个新卡片。

```
<script>
  // 引入状态
  import {cards} from './store';
  import {getNowDateFormat} from "./utils";

  let title = '';
  let content = '';

  function doAdd() {
    // 校验
    if (!title || !content) {
      alert('标题和内容必须都填！');
      return;
    }
    
    // 更新卡片状态，追加一个新卡片
    cards.update(item => {
      item = [...item, {
        title,
        content,
        creationTime: getNowDateFormat()
      }];
      return item;
    })
  }
</script>
```

#### 3.3 删除卡片

实现 `Card.svelte` 的删除函数：同样调用 `cards.update`，从数组中移除当前下标的元素。

```
<script>
  import {cards} from "./store";
 
  // 删除卡片
  function doDelete() {
    cards.update(item => {
      item.splice(index, 1);
      return item;
    })
  }
</script>
```

#### 3.4 导出 Markdown 笔记

先安装 `file-saver` 库用于实现文件下载：

```
npm i file-saver
```

实现导出函数：遍历 `$cards` 状态数组拼装 Markdown 文本，用 `Blob` 包装后调用 `saveAs` 触发下载。

```
<script>
  import {cards} from './store';
  // 引入 file-saver
  import {saveAs} from 'file-saver';
  
 // 导出为 read_note.md 文件
  function doExport() {
    const texts = [];
    // 读取 cards 状态数组
    for (const card of $cards) {
      let text = `### ${card.title}\n${card.content}\n${card.creationTime}\n`;
      texts.push(text);
    }
    // 写入文件
    const blob = new Blob(texts, {type: "text/plain;charset=utf-8"});
    saveAs(blob, "read_note.md");
  }
</script>
```

#### 3.5 改进方向

目前只实现了最基本功能，还可以继续完善：

1. 给卡片添加不同颜色（可在 `public/global.css` 中补充颜色样式）
2. 刷新后卡片数据会丢失，可借助浏览器 Cookie 实现持久化：卡片更新时保存到 Cookie，再次打开网站时从 Cookie 恢复数据并写回状态

### 4. 发布上线

本地开发完成后打包项目：

```
npm run build
```

会在 `public` 目录下生成 `bundle.js` 文件（部署到子路径时注意配置好对外 base path）。

无需自己买服务器，可用 **Vercel**（免费网站托管平台）部署并生成可访问网址：

```
npm install -g vercel
cd public
vercel deploy --name read-note
```

发布成功后即可获得访问网址。用开发者工具（F12）查看网页加载信息，整个读书笔记网站仅 **16 KB**。

## 对 Svelte 的评价与展望

社区对 Svelte 的看法褒贬不一：

- 反对者认为：为了减少几十 KB 的体积而放弃 runtime 设计和成熟生态，得不偿失——如今一张图片都要几百 KB，一个页面可能好几 MB，没必要纠结这点大小
- 支持者认为：Svelte 的强大之处正在于没有 runtime，可以像原生 JS 一样融入任何框架和组件，非常适合**微前端**架构

抛开生态之争，作者打破思维定式、返璞归真的探索精神值得肯定。**脱离业务场景的技术选型都是耍流氓**——在配置较低、网络较差的小设备上，减小几十 KB 包大小确实很有必要。Svelte 在保证高效极简开发体验的同时保留了原生项目的轻小体积和高性能，这是它吸引开发者的核心爽点；但无 Virtual DOM 的设计在大型生产项目中的表现还有待更多实践检验。多一种技术选型，何乐而不为？

进一步学习推荐 Svelte 官方教程：https://svelte.dev/tutorial （简洁清晰、容易上手，还提供在线编辑器可实时练习调试）。

> 来源：鱼皮·编程导航 / codefather
