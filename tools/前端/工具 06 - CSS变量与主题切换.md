---
title: 使用 CSS 变量 + 类名切换实现主题换肤
date: 2026-07-30
tags: [前端, CSS, 主题切换]
source: "鱼皮·编程导航 / codefather"
---

## 核心思路

**CSS 变量 + 类名切换** 是前端实现主题切换的主流方案。核心流程：

1. 在顶层元素（如 `<html>` 或 `<body>`）上通过类名或属性标记当前主题（如 `.theme-light` / `.theme-dark`、`arco-theme="dark"`）
2. 每个主题下定义一套 CSS 变量（颜色、背景、边框等）
3. 组件样式引用这些 CSS 变量，切换类名即自动切换视觉
4. 将当前主题持久化到 `localStorage`，配合状态管理（如 Vuex/Pinia）保持跨页面一致

## Arco Design 暗黑模式

Arco Design 组件库内置了两套 CSS 变量（亮色 / 暗黑），可直接使用。

### 操作步骤

1. **使用组件库定义好的 CSS 变量** — Arco 已提供完整的 Light/Dark Token：[Token 文档](https://arco.design/vue/docs/token)
2. **切换方式**：通过 `document.body.setAttribute("arco-theme", "dark")` / `removeAttribute("arco-theme")` 切换，并将当前值存入 `localStorage`
3. **初始化恢复**：`onMounted` 时从 `localStorage` 读取主题值，重新应用

```javascript
const isLight = ref();
const theme = ref();

const toggleLight = () => {
  isLight.value = true;
  document.body.removeAttribute("arco-theme");
  localStorage.setItem("theme", "light");
};

const toggleDark = () => {
  isLight.value = false;
  document.body.setAttribute("arco-theme", "dark");
  localStorage.setItem("theme", "dark");
};

onMounted(() => {
  theme.value = localStorage.getItem("theme");
  theme.value === "light" ? toggleLight() : toggleDark();
});
```

如需自定义更多变量，可通过 Arco Design Lab 在线生成：[Design Lab](https://arco.design/docs/designlab/guideline)

## Tailwind 主题切换

在 Tailwind CSS 中，通过 `@layer base` 定义亮/暗两套 CSS 变量，并在 `tailwind.config.js` 中将其映射为工具类。

### 定义 CSS 变量（style.css）

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  .theme-light {
    --color-base: theme('colors.white');
    --color-text-base: theme('colors.black');
    --color-off-base: theme('colors.gray.50');
    --color-text-muted: theme('colors.gray.600');
    --color-text-muted-hover: theme('colors.gray.500');
    --color-primary: theme('colors.blue.600');
    --color-secondary: theme('colors.blue.300');
  }

  .theme-dark {
    --color-base: theme('colors.gray.900');
    --color-text-base: theme('colors.gray.100');
    --color-off-base: theme('colors.gray.800');
    --color-text-muted: theme('colors.gray.300');
    --color-text-muted-hover: theme('colors.gray.200');
    --color-primary: theme('colors.blue.500');
    --color-secondary: theme('colors.blue.200');
  }
}
```

### 映射为工具类（tailwind.config.js）

```javascript
module.exports = {
  mode: 'jit',
  theme: {
    extend: {},
    backgroundColor: {
      base: 'var(--color-base)',
      'off-base': 'var(--color-off-base)',
      primary: 'var(--color-primary)',
      secondary: 'var(--color-secondary)',
      muted: 'var(--color-text-muted)',
    },
    textColor: {
      base: 'var(--color-text-base)',
      muted: 'var(--color-text-muted)',
      'muted-hover': 'var(--color-text-muted-hover)',
      primary: 'var(--color-primary)',
      secondary: 'var(--color-secondary)',
    },
  },
  variants: {},
  plugins: [],
};
```

### 使用方式

在 HTML 父元素上添加 `.theme-light` 或 `.theme-dark`，子元素使用 `bg-base`、`text-base` 等工具类即可自动跟随主题。

> 在线示例：[Tailwind Play](https://play.tailwindcss.com/pGH5RsrfJ0)

## UnoCSS 主题切换

UnoCSS 通过 `shortcuts` 配置，直接在类名上使用 `dark:` 变体实现亮/暗两套值。

### 配置（unocss.config.ts）

```javascript
export default defineConfig({
  // ...
  shortcuts: {
    'bg-base': 'bg-[#ffffff] dark:bg-[#20202a]',
    'card-base': 'bg-[#ffffff] dark:bg-[#10101a]',
    'text-base': 'text-[#20202a] dark:text-[#f0f0f0]',
  },
  // ...
});
```

### 使用方式

在 HTML 元素上直接使用 `bg-base`、`text-base` 等 shortcut 类名，UnoCSS 会自动根据 `dark` 类是否存在切换对应颜色值。

> 在线示例：[UnoCSS Playground](https://unocss.dev/play/)

## 总结

三种方案的共同本质都是 **CSS 变量 + 类名切换**：

| 方案 | 变量定义位置 | 切换方式 |
|------|------------|---------|
| Arco Design | 组件库内置 Token | body 的 `arco-theme` 属性 |
| Tailwind | `@layer base` 下的 `.theme-light / .theme-dark` | 父元素类名 |
| UnoCSS | `shortcuts` 配合 `dark:` 变体 | `dark` 类 |

选择哪种取决于项目使用的 UI 框架和工具链。核心始终是：**定义两套 CSS 变量 → 类名切换 → 持久化状态**。

> 来源：鱼皮·编程导航 / codefather
