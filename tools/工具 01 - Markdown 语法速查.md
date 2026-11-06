---
title: "工具 01 - Markdown 语法速查"
date: 2026-06-11
tags: [工具, markdown]
---

# 工具 01 - Markdown 语法速查

> Markdown 是一种轻量级标记语言，广泛用于文档、博客、README 和笔记（Obsidian 等）。

## 标题

```markdown
# H1
## H2
### H3
#### H4
##### H5
###### H6
```

## 文本样式

```markdown
**粗体**
*斜体*
~~删除线~~
==高亮== (Obsidian/某些编辑器)
`行内代码`
<u>下划线</u> (HTML)
```

## 列表

```markdown
无序列表：
- 项一
- 项二
  - 子项（缩进两个空格）

有序列表：
1. 第一
2. 第二
   1. 子项（缩进）
```

## 链接与图片

```markdown
[链接文字](https://example.com)
![图片描述](https://example.com/image.png)

Obsidian Wiki 链接：
[[笔记名]]
[[笔记名|显示文字]]
```

## 代码块

`​``语言
// 代码块指定语言可高亮
function hello() {
    console.log("Hello World");
}
`​``

## 引用

```markdown
> 这是一段引用
>> 嵌套引用
```

## 表格

```markdown
| 左对齐 | 居中对齐 | 右对齐 |
|:-------|:--------:|-------:|
| A      | B        | C      |
| D      | E        | F      |
```

## 分割线

```markdown
---
```

## 任务列表

```markdown
- [x] 已完成
- [ ] 未完成
- [ ] 待办
```

## Obsidian 特有语法

```markdown
%% 注释（仅在编辑时可见） %%

[[]]    Wiki 链接
![]     [[图片嵌入]]
#标签   #tag

> [!note] Callout
> 这行内容会显示在 Callout 框内

> [!warning] 警告
> 支持 note/warning/tip/important/caution/question 等
```

## 转义字符

在特殊字符前加 `\`：`\*` `\#` `\-` `\` `` \` ``
