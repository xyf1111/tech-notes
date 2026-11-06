---
title: "工具 05 - 鱼聪明 AI：无门槛 AI 对话与绘画助手"
date: 2026-07-17
tags: [AI, 对话, 绘画, 工具]
source: "鱼皮·编程导航 / codefather"
---

# 工具 05 - 鱼聪明 AI：无门槛 AI 对话与绘画助手

> 鱼聪明 AI（https://yucongming.com）是一款集 AI 对话、AI 写书、AI 绘画于一体的无门槛 AI 助手平台，支持个人创建 AI 助手、开放平台 API 集成。

## 核心功能

### AI 对话助手

- **数百个现成助手**：涵盖文案写作、编程辅助、学习辅导等多场景，支持搜索
- **自定义创建助手**：用户可自主创建 AI 助手，配置名称、头像、对话示例、想象力参数等，支持公开发布和分享海报

### AI 写书

- 输入书名和内容介绍，AI 自动生成完整书籍
- 支持指定风格，实时预览生成进度
- 生成后支持下载为文档

### AI 绘画

- 输入文字描述，一键生成图片（支持 4 张并行）
- 接入主流 AI 绘画平台，提供「一键优化描述」功能（用 AI 优化中文描述适应海外模型）
- 实时预览绘画生成进度

### AI 导航

- 内置上百个 AI 工具站索引，支持快速搜索发现

### 开放平台（Open API）

- 提供 Java SDK，几行代码即可调用 AI 助手能力
- 示例代码：

```java
// 构造请求
DevChatRequest devChatRequest = new DevChatRequest();
devChatRequest.setModelId(1651468516836098050L);
devChatRequest.setMessage("鱼皮");
// 获取 AI 助手的回复
BaseResponse<DevChatResponse> response = client.doChat(devChatRequest);
System.out.println(response.getData());
```

### 实用插件

- **对话分享海报**：将对话记录生成为海报分享
- **语音朗读**：AI 朗读消息内容，可用于语言学习
- **对话下载**：一键下载对话记录为文档

## 优势特点

- 无需自建 AI 账号，零门槛使用
- 每日免费领取额度
- 会员服务按需开通
- 支持 Web 端和微信小程序

> 来源：鱼皮·编程导航 / codefather
