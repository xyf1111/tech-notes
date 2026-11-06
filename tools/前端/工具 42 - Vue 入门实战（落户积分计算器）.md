---
title: "工具 42 - Vue 入门实战（落户积分计算器）"
date: 2026-10-06
tags: [Vue, Vant, Vue CLI, 前端实战, Vercel]
source: "鱼皮·编程导航 / codefather"
---

# 工具 42 - Vue 入门实战（落户积分计算器）

> 用 Vue 脚手架 + Vant 组件库做一个「上海应届生落户积分计算器」单页网站：整个网站就是一个表单累加器，每个选项对应不同分数，底部实时显示总分；本地跑通后打包部署到 Vercel 免费上线，全程约 10 分钟，是练手 Vue 前端框架的入门级小项目。

## 项目背景

做一个「计算器」，本质上就是把自己的情况做成一个表单。以「上海应届生落户积分」为例：当时落户达标线是 72 分，各积分项与常见得分如下——

| 积分项 | 情况 | 得分 |
| :-- | :-- | :-- |
| 最高学历 | 本科 | 21 |
| 毕业学校 | 第一类高校 | 15 |
| 最高学历毕业在沪 | 是 | 2 |
| 学习成绩 | 一级 | 8 |
| 外语水平 | 英语六级 | 8 |
| 计算机水平 | 计算机专业 | 7 |
| 用人单位分 | 满足条件 | 5 |

用户按自身情况逐项选择，网站底部实时累加出总分（`total >= 72` 时按钮变色提示达标）。Vue 框架的系统学习路线见 [[工具 11 - Vue.js 学习路线]]。

## 1. 创建项目（Vue CLI）

用 Vue 官方脚手架 Vue CLI 一行命令搭建项目，自动安装依赖：

```
vue create can-i-settle-shanghai
```

有脚手架就不用自己写项目基础模板了。

## 2. 引入 Vant 组件库

移动端页面推荐引入有赞的 `Vant` 组件库（精致美观、文档成熟）。参照官方文档「快速上手」，先安装依赖：

```
npm i vant -S
```

再全局引入：

```js
import Vue from 'vue';
import Vant from 'vant';
import 'vant/lib/index.css';

Vue.use(Vant);
```

之后即可参照文档，把想要的组件代码复制到页面文件中使用。

## 3. 开发界面

界面开发像拼图：把大页面拆成小组件，再自上而下堆积起来。本页由标题、输入框、单选按钮组、底部展示按钮组成。

Vue 中一个页面对应一个 `.vue` 文件，分为三部分——内容（`template`）、行为（`script`）、样式（`style`）：

```vue
<template>
  ... 写网页内容和结构
</template>

<script>
  ... 给页面添加交互行为
</script>

<style scoped>
  ... 写样式，美化网页
</style>
```

开发流程：**先写内容 → 再美化样式 → 最后加交互**。内容直接使用 Vant 组件（`Radio` 单选框、`Divider` 分割线、`Field` 输入框）：

```vue
<template>
  <van-divider :style="{ color: '#1989fa', borderColor: '#1989fa'}">最高学历</van-divider>
  <van-radio-group>
    <van-radio name="27">博士27分</van-radio>
    <van-radio name="24">硕士24分</van-radio>
    <van-radio name="21">本科21分</van-radio>
  </van-radio-group>
</template>
```

底部用一个按钮显示当前分数 `total`，并在 `total >= 72` 时改变按钮类型（颜色）：

```vue
<van-button :type="total >= 72 ? 'primary' : 'info'">当前分数：{{total}}</van-button>
```

## 4. 实现积分计算功能

用 `score` 数组记录每组选项的得分（如 `score[0]` 记「最高学历」组、`score[1]` 记「毕业学校」组），当然也可以用对象等其他数据结构：

```js
export default {
  name: "Index",
  data() {
    return {
      scores: [],
      show: false,
    };
  }
}
```

用 `v-model` 把数组元素绑定到选项组，用 `@change` 给选项绑定点击事件，选项的 `name` 属性即选中时的得分：

```vue
<van-radio-group v-model="scores[2]" @change="doChange">
  <van-radio name="2">上海 2分</van-radio>
  <van-radio name="0">非上海 0分</van-radio>
</van-radio-group>
```

总分用 Vue 的 `computed` 计算属性对数组求和，`score` 数组值变化时自动重算 `total`：

```js
export default {
  computed: {
    total() {
      let total = 0;
      for (const score of this.scores) {
        if (score) total += parseInt(score);
      }
      return total;
    }
  }
}
```

## 5. 打包发布（Vercel）

先在项目目录打包，生成 `dist` 目录：

```
npm run build
```

不必买服务器，用 `Vercel` 免费网站托管平台即可上线。全局安装 CLI 后进入产物目录发布：

```
npm install -g vercel
cd dist
vercel deploy --name can-i-settle-shanghai
```

发布成功会得到一个可访问网址，打开就能看到积分计算器网站。更多免费托管方案见 [[DevOps 06 - 免费上线网站的几种方法]]；同类练手小项目可参考 [[工具 25 - 原生 JS 计算器实现]]。

> 来源：鱼皮·编程导航 / codefather
