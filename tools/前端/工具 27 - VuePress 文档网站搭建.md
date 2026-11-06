---
title: "工具 - VuePress 文档网站搭建"
date: 2026-08-24
tags: [VuePress, 文档网站, 前端]
source: "鱼皮·编程导航 / codefather"
---

# 工具 - VuePress 文档网站搭建

> 本文基于开源模板 codefather 的 template 分支，讲解如何用 VuePress 静态网站生成器在几分钟内搭出精简的文档网站，覆盖项目启动、目录结构、基本配置、主题配置、插件配置与项目部署全流程。

## 为什么选 VuePress

- **VuePress** 是静态网站生成器（SSG），把 Markdown 渲染成静态 HTML 网站；相比 VitePress，VuePress 的生态和成熟度更高、插件丰富，更适合长期维护的文档站。
- 与 docsify 运行时动态渲染不同（见 [[工具 22 - Docsify 文档网站搭建]]），VuePress 构建时生成纯静态资源，SEO 更友好，产物可部署到任意服务器或静态托管。
- 无需从零配置：作者开源了一套增强版模板（GitHub: liyupi/codefather 的 `template` 分支），已选好常用插件，开箱即用，改配置即可定制。
- 配合 [[AI 大模型 02 - 批量生成内容建站实战（VuePress + OpenAI）]]，可用 AI 批量生成文档内容后一键发布成站。

## 一、项目启动

1. 下载开源项目 codefather 的 `template` 分支代码压缩包，解压后用 WebStorm / VS Code 打开。
2. 环境要求：Node + npm（版本尽量与模板保持一致，避免莫名报错）。
3. 首次运行安装依赖并启动：

```bash
npm install        # 安装依赖
npm run docs:dev   # 启动开发服务器，默认端口 8080
```

4. 浏览器访问本地 8080 端口即可预览网站。

## 二、模板目录结构

所有文档（Markdown 文件/目录）直接放到项目根目录下，即对应网站页面；构建、主题、插件等配置集中在 `.vuepress` 目录。

## 三、基本配置（config.ts）

核心配置文件 `config.ts`，网站内容、主题样式、插件能力都在此全局配置。

### 1. 网站基本信息

标题、描述，以及自定义的作者、域名、全局标签：

```javascript
const author = "作者名";
const domain = "https://example.com";   // 替换为自己的域名
const tags = ["前端", "编程", "计算机"];

export default defineConfig({
  title: "网站标题",
  description: "网站描述",
  ...
});
```

### 2. head 标签配置

head 标签包含网页重要元信息，可配置站点图标、SEO 元信息、第三方统计分析代码等：

```javascript
head: [
  // 站点图标
  ["link", { rel: "icon", href: "/favicon.ico" }],
  // SEO 关键词
  ["meta", { name: "keywords", content: "关键词1, 关键词2" }],
  // 第三方统计（百度统计示例）
  ["script", {}, `
    var _hmt = _hmt || [];
    (function() {
      var hm = document.createElement("script");
      hm.src = 'https://hm.baidu.com/hm.js?你的统计ID';
      var s = document.getElementsByTagName("script")[0];
      s.parentNode.insertBefore(hm, s);
    })();
  `],
],
```

### 3. 永久链接

默认按文档目录层级生成访问链接，目录变动会导致旧链接失效、影响 SEO 和用户访问；开启后按文章标题自动生成简短链接，不受目录结构影响：

```javascript
permalink: "/:slug",
```

生成规则可自定义，也可为单个页面定制永久链接，详见官方文档：[https://vuepress.vuejs.org/zh/guide/permalinks.html](https://vuepress.vuejs.org/zh/guide/permalinks.html)

### 4. 文件热更新

默认仅文档/配置改动自动热更新，自定义的 js、ts 文件修改不会触发；用 `extraWatchFiles` 扩展监听范围：

```javascript
// 监听文件变化，热更新
extraWatchFiles: [".vuepress/*.ts", ".vuepress/sidebars/*.ts"],
```

### 5. Markdown 配置

自定义 Markdown 渲染规则：

```javascript
markdown: {
  // 开启代码块行号
  lineNumbers: true,
  // 支持 4 级以上标题渲染
  extractHeaders: ["h2", "h3", "h4", "h5", "h6"],
},
```

## 四、主题配置

模板使用 VuePress 默认主题（更精简、稳定；Hope 主题功能更丰富但界面较复杂）。所有主题配置写在 `config.ts` 的 `themeConfig` 中：

```javascript
export default defineConfig({
  themeConfig: {
    logo: "/logo.png",
    nav: navbar,
    sidebar,
    lastUpdated: "最近更新",

    // GitHub 仓库位置
    repo: "用户名/仓库名",
    docsBranch: "master",

    // 编辑链接
    editLinks: true,
    editLinkText: "完善页面",

    // 底部版权信息（模板自定义扩展）
    footer,
    // 右侧附加边栏（模板自定义扩展）
    extraSideBar,
  },
});
```

官方默认主题配置文档：[https://vuepress.vuejs.org/zh/theme/default-theme-config.html](https://vuepress.vuejs.org/zh/theme/default-theme-config.html)

### 1. 导航栏配置

导航配置集中写在 `navbar.ts`，在 `config.ts` 中引用；支持子导航栏：

```javascript
import navbar from "./navbar";

export default defineConfig({
  themeConfig: {
    nav: navbar,
  },
});
```

示例（含子导航）：

```javascript
nav: [
  {
    text: 'Languages',
    ariaLabel: 'Language Menu',
    items: [
      { text: 'Chinese', link: '/language/chinese/' },
      { text: 'Japanese', link: '/language/japanese/' }
    ]
  }
]
```

### 2. 侧边栏配置（最佳实践）

侧边栏配置写在 `sidebar.ts` 并引用；文章多时需要分组、自动识别文章小标题，最佳实践：

1. 同类文章放到同一个目录（如 `/学习路线/`）；
2. 每个分类的侧边栏配置单独写在 `sidebars/` 目录下的独立文件中（如 `roadmapSideBar.ts`）；
3. 在 `sidebar.ts` 中按目录路径映射各分类配置，未匹配的目录用 `"auto"` 降级为按文章标题自动渲染：

```typescript
import {SidebarConfig4Multiple} from "vuepress/config";

import roadmapSideBar from "./sidebars/roadmapSideBar";

export default {
    "/学习路线/": roadmapSideBar,
    // 降级：默认根据文章标题渲染侧边栏
    "/": "auto",
} as SidebarConfig4Multiple;
```

### 3. 底部配置（footer.ts）

模板用 VuePress 自定义主题能力二次开发的功能：填写 `footer.ts` 配置，自动在网页底部生成友情链接、备案信息等：

```javascript
/**
 * 底部版权信息
 */
export default {
  friendLinks: [
    {
      label: "友情链接名称",
      href: "https://example.com",
    },
  ],
  copyright: {
    href: "https://beian.miit.gov.cn/",
    name: "备案号",
  },
};
```

### 4. 右侧附加边栏（extraSideBar.ts）

模板二次开发功能：填写 `extraSideBar.ts` 配置，在网页右侧生成固定侧边栏，提供附加能力（如二维码入口等），支持自定义 HTML：

```javascript
/**
 * 额外右侧边栏
 */
export default [
  {
    title: "标题",
    icon: "/icon/xxx.png",
    popoverTitle: "弹窗标题",
    popoverUrl: "/qrcode.png",
    popoverDesc: "描述文字",
  },
]
```

## 五、插件配置

VuePress 的核心优势是插件生态，插件清单可参考 awesome-vuepress：[https://github.com/vuepressjs/awesome-vuepress#plugins](https://github.com/vuepressjs/awesome-vuepress#plugins)。模板已内置精选的核心插件：

### 1. 返回顶部

```bash
yarn add -D @vuepress/plugin-back-to-top
# OR npm install -D @vuepress/plugin-back-to-top
```

```javascript
module.exports = {
  plugins: ['@vuepress/back-to-top']
}
```

### 2. 图片点击放大

所有图片支持点击放大：

```javascript
module.exports = {
  plugins: ["@vuepress/medium-zoom"]
}
```

### 3. SEO 相关插件

1) **谷歌分析**（利于谷歌收录）：`@vuepress/google-analytics`，`ga` 填自己的分析 ID（如 UA-00000000-0）：

```javascript
module.exports = {
  plugins: [
    ['@vuepress/google-analytics', { 'ga': 'UA-00000000-0' }]
  ]
}
```

2) **vuepress-plugin-seo**：自定义生成的 meta 标签内容（文章描述、标签等），提高收录率。官方：[https://github.com/lorisleiva/vuepress-plugin-seo](https://github.com/lorisleiva/vuepress-plugin-seo)

```javascript
[
  "seo",
  {
    siteTitle: (_, $site) => $site.title,
    title: ($page) => $page.title,
    description: ($page) => $page.frontmatter.description || $page.description,
    author: (_, $site) => $site.themeConfig.author || author,
    tags: ($page) => $page.frontmatter.tags || tags,
    type: ($page) => "article",
    url: (_, $site, path) => ($site.themeConfig.domain || domain || "") + path,
    image: ($page, $site) =>
      $page.frontmatter.image &&
      (($site.themeConfig.domain && !$page.frontmatter.image.startsWith("http")) || "") + $page.frontmatter.image,
    publishedAt: ($page) => $page.frontmatter.date && new Date($page.frontmatter.date),
    modifiedAt: ($page) => $page.lastUpdated && new Date($page.lastUpdated),
  },
]
```

3) **sitemap 插件**：自动生成 `sitemap.xml` 站点地图。官方：[https://github.com/ekoeryanto/vuepress-plugin-sitemap](https://github.com/ekoeryanto/vuepress-plugin-sitemap)

```javascript
[
  "sitemap",
  {
    hostname: domain,
  },
]
```

4) **百度自动推送**：定期自动把文章推送给百度，提高收录率。官方：[https://github.com/IOriens/vuepress-plugin-baidu-autopush](https://github.com/IOriens/vuepress-plugin-baidu-autopush)

```javascript
['vuepress-plugin-baidu-autopush']
```

### 4. 代码复制

一键复制网站上的代码块。官方：[https://github.com/znicholasbrown/vuepress-plugin-code-copy](https://github.com/znicholasbrown/vuepress-plugin-code-copy)

```javascript
[
  "vuepress-plugin-code-copy",
  {
    successText: "代码已复制",
  },
]
```

### 5. RSS 订阅

让用户通过 RSS 订阅网站内容更新。官方：[https://github.com/webmasterish/vuepress-plugin-feed](https://github.com/webmasterish/vuepress-plugin-feed)

```javascript
[
  "feed",
  {
    canonical_base: domain,
    count: 10000,
    // 需要自动推送的文档目录
    posts_directories: [],
  },
]
```

### 6. 文章标签

用 Markdown FrontMatter 语法定义标签并在网站展示。官方：[https://github.com/zq99299/vuepress-plugin/tree/master/vuepress-plugin-tags](https://github.com/zq99299/vuepress-plugin/tree/master/vuepress-plugin-tags)

```javascript
["vuepress-plugin-tags"],
```

### 7. 图片懒加载

页面滚动到图片位置时才请求加载，大幅提升图片较多网站的加载速度、节约带宽。官方：[https://github.com/tolking/vuepress-plugin--lazy](https://github.com/tolking/vuepress-plugin--lazy)

```javascript
['-lazy']
```

## 六、项目部署

1. 执行打包命令（package.json 中的 `docs:build` 脚本）：

```bash
npm run docs:build
```

2. 打包成功后，`.vuepress` 目录下生成 `dist` 目录，所有网页资源都在其中。
3. 把 `dist` 目录下所有文件上传到服务器（或静态托管平台）即可对外访问。

> 部署思路与 [[工具 22 - Docsify 文档网站搭建]] 中介绍的静态托管一致：构建产物都是纯静态文件，任意 Web 服务器或静态托管都能承载。

## 小结

通过本教程可以掌握文档网站从搭建到上线的完整流程，同时接触 SEO、懒加载、代码复制、RSS 等实用前端知识；配合 [[AI 大模型 02 - 批量生成内容建站实战（VuePress + OpenAI）]] 可进一步实现内容批量生产。

> 来源：鱼皮·编程导航 / codefather
