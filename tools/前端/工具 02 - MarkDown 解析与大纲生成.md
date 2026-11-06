---
title: "工具 - MarkDown 解析与大纲生成"
date: 2026-07-22
tags: [前端, Vue, Markdown]
source: "鱼皮·编程导航 / codefather"
---

# 工具 - MarkDown 解析与大纲生成

> 在 Vue 项目中将 MarkDown 文本解析为 HTML，并自动生成可交互的大纲目录（Table of Contents），支持点击导航和滚动高亮。

## 核心要点

### 1. MarkDown → HTML 渲染

使用 [marked](https://github.com/markedjs/marked) 库将 MarkDown 文本解析为 HTML：

```javascript
import { marked } from 'marked';
const htmlContent = marked(resp.share.content);
```

使用 [github-markdown-css](https://github.com/sindresorhus/github-markdown-css) 添加样式，保证渲染效果与 GitHub 风格一致：

```javascript
const link = document.createElement('link');
link.type = 'text/css';
link.rel = 'stylesheet';
link.href = 'https://cdn.bootcss.com/github-markdown-css/2.10.0/github-markdown.min.css';
document.head.appendChild(link);
```

> **注意：** DOM 渲染需要时间，通过 `setTimeout(1ms)` 等待 DOM 挂载完成后再操作渲染后的元素。

### 2. 提取标题生成大纲树

遍历渲染后的 `.markdown-body` 子元素，通过正则 `/h(10|[1-9])/g` 匹配 h1-h6 标签，构建层级树：

```javascript
// 解析 HTML，生成标题树
const setTreeDataByHtml = (htmlContent) => {
  const regex = /h(10|[1-9])/g;
  for (let i = 0; i < htmlContent.length; i++) {
    if (htmlContent[i].localName.match(regex)) {
      const level = parseInt(htmlContent[i].localName.replace("h", ""));
      const label = htmlContent[i].innerText;
      if (treeData.value.length === 0 || treeData.value[treeData.value.length - 1].level >= level) {
        treeData.value.push({ label, level, children: [] });
      } else {
        // 递归寻找父标题
        setSubDirectory(treeData.value[treeData.value.length - 1], level, label);
      }
    }
  }
};

// 递归将子标题挂到父标题下
const setSubDirectory = (directory, level, label) => {
  const children = directory.children;
  if (children.length > 0) {
    setSubDirectory(children[children.length - 1], level, label);
  }
  if (directory.level < level) {
    directory.children.push({ level, label, children: [] });
  }
};
```

**层级逻辑：**
- 当前标题层级 ≤ 上一个父标题层级 → 直接作为顶层节点
- 当前标题层级 > 上一个父标题层级 → 递归查找最深层父级，作为子节点挂入

### 3. 使用 Element Plus Tree 展示

```html
<el-tree :data="treeData" :expand-on-click-node="false" class="tree"></el-tree>
```

CSS 固定定位在页面右侧：
```css
.tree {
  width: 20%;
  position: fixed;
  top: 80px;
  right: 50px;
}
```

### 4. 点击目录导航到标题

使用 `scrollIntoView` API 实现平滑滚动到对应标题位置：

```javascript
element.scrollIntoView({
  behavior: "instant",
  block: "center",
});
```

### 5. 滚动时高亮当前标题

使用 `IntersectionObserver` API 监听标题元素是否进入可视区域：

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      treeRef.value.setCurrentKey(entry.target.id);
    }
  });
}, { threshold: 0 });

// 将需要监听的标题元素加入 Observer
observer.observe(htmlContent[i]);
```

> 来源：鱼皮·编程导航 / codefather
