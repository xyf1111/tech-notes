---
title: "AI 绘画 01 - Stable Diffusion 平台搭建"
date: 2026-08-22
tags: [AI 绘画, Stable Diffusion, 腾讯云, HAI, GPU, 部署]
source: "鱼皮·编程导航 / codefather"
---

# AI 绘画 01 - Stable Diffusion 平台搭建

> 用开源 Stable Diffusion + 腾讯云 HAI（高性能应用服务），不写代码、几分钟搭建自己的 AI 绘画平台：选择环境 → 一键部署 → 写 prompt 生成 → 换模型优化效果。

## AI 绘画工具选型

- 主流工具：Stable Diffusion、DreamStudio、Midjourney、DALL·E 2
- 推荐 **开源 Stable Diffusion**：比封装平台更灵活、可定制化生成图像

## 环境选择

**本地部署硬件要求**：不少于 16GB 内存、60GB 以上硬盘、CUDA 架构（推荐 N 卡；A 卡虽有支持但速度明显慢）。

配置不够时用 **GPU 云服务器**。腾讯云 **HAI（高性能应用服务）** 是面向 AI 和科学计算的 GPU 应用服务，即插即用：`HAI = GPU 服务器 + 开箱即用的应用`，免去自己安装依赖的麻烦（官方：https://cloud.tencent.com/product/hai ）。

HAI 可预装：

- **AI 模型**：Stable Diffusion、ChatGLM2 6B、Llama2 7B、Llama 13B 等
- **AI 框架**：PyTorch 2.0.0、TensorFlow 2.9.0 等
- **开发环境**：JupyterLab 等可视化界面

## 部署步骤

1. 从 HAI 官网进入算力管理页（https://console.cloud.tencent.com/hai/instance ）点击「新建」创建实例，只需设置实例名称，其余保持默认
2. 创建过程中可做**加速设置**（选创建地域即免费加速），几分钟后实例运行
3. 点击算力连接，打开 HAI 预装好的 **Gradio WebUI**（Stable Diffusion 使用界面），即可开始 AI 绘画

## 使用 AI 绘画：Prompt 编写

- 画得好坏取决于 **prompt**（输入给 AI 的文字）；不会写可直接从 **Civitai**（https://civitai.com/ ）选图并复制现成 prompt
- **提示词用英文写效果更好**：同一画面用英文描述通常明显优于中文（有时差距很大）；可先写中文、再翻译成尽量详细的英文描述（不少平台提供「优化中文描述」一键转英文）
- **Negative prompt**：指定模型应避免的内容（畸形手脚、低画质等）
- 可调参数：**Sampling method、Sampling steps、CFG Scale、Seed** 等，可复制他人配置或自行调试
- 点击 Generate 等待十几秒出图；内置基础模型能力一般（尤其画人效果差），需下载专业模型优化

## 使用模型优化图像

1. 从 Civitai 下载模型（如动物类模型 FenrisXL：https://civitai.com/models/122793/fenrisxl ）；可用 https://spell.novelai.dev/ 查看模型信息与用法
2. 通过 HAI 自带的 **JupyterLab**（基于 Web 的开源交互式开发环境，可在网页上运行 Python/终端命令/管理文件）上传模型文件到 `/root/stable-diffusion-webui/models/Stable-diffusion` 目录
3. 回 Gradio WebUI 点击**刷新**，左上角切换新模型，再 Generate 生成，效果显著提升（细节、背景均改善）

## 成本与省钱技巧

- 价格约 **1.2 元/小时**，**用完就关**最实惠
- 默认 80GB 硬盘：创建 **15 天内关机免计费**；15 天后关机也仅 0.02 元/小时

> 来源：鱼皮·编程导航 / codefather
