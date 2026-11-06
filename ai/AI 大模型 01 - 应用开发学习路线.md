---
title: "AI 大模型应用开发学习路线"
date: 2026-07-18
tags:
  - learning
  - AI
  - LLM
  - roadmap
source: "鱼皮·编程导航 / codefather"
---

# AI 大模型应用开发学习路线

> AI 大模型应用开发的核心不是从头训练模型，而是通过工程化手段释放现成模型的潜力——组合 Prompt 工程、向量数据库、业务逻辑等模块，将通用大模型定制为特定场景的解决方案。

## 后端开发者转型 AI 的优势

后端开发者的系统架构、数据处理、性能优化能力在 AI 应用落地中天然适用。AI 应用仍然需要 WebSocket/SSE 实时通信、MySQL 存储、TTS 语音等传统后端能力，只是核心逻辑变成了调用大模型。

**需要新学的：**
- 理解大模型的能力边界（上下文限制、幻觉问题、稳定性）
- 掌握 Prompt 设计
- 熟悉 LangChain、RAG、向量数据库

## 学习路线总览

| 阶段 | 内容 | 建议时长 |
|------|------|---------|
| 阶段 1 | 大模型基础 | ~83 天 |
| 阶段 2 | RAG 应用开发工程 | ~37 天 |
| 阶段 3 | 大模型 Agent 应用架构 | ~50 天 |
| 阶段 4 | 大模型微调和私有化部署 | ~105 天 |

## 阶段 1：大模型基础

### 1.1 大模型基本信息（5天）

**知识：**
- AI 演进（AI 1.0 → AI 2.0）、大模型与 AGI
- 国外大模型：GPT 系列、Claude、Gemini、Llama、Mistral
- 国产大模型：DeepSeek、通义千问、豆包、Kimi、文心一言、讯飞星火、ChatGLM、百川、腾讯元宝

### 1.2 大模型的原理（60天）

**知识：**
- 生成式模型 vs 大语言模型
- 主流模型系列：GPT（1-4）、LLaMA、BLOOM、ChatGLM
- Transformer 架构（Self-Attention、Encoder-Decoder、Multi-head Attention）
- NLP 基础：数学基础（线性代数、概率统计）、机器学习（TF-IDF、朴素贝叶斯、SVM）、神经网络（RNN/LSTM、CNN、PyTorch）
- 关键技术：预训练（分词器 BPE/WordPiece/SentencePiece）、分布式训练、推理规划（CoT、Least-to-Most）、LLM 加速（FlashAttention、PagedAttention）
- 强化学习：PPO、RLHF

**学习建议：** 不必死磕数学证明，重点理解模型结构和工作原理。理论结合实践，尝试本地部署小型模型。

### 1.3 Prompt Engineering（10天）

**知识：**
- Python 环境、IDE 搭建
- 提示词基础：零样本、少样本提示、上下文学习
- 进阶技巧：思维链（CoT）、自洽性（Self-Consistency）、思维树（ToT）
- 提示词攻击和防范：注入攻击、防范策略
- Prompt 与 RAG、Agent、微调的关系

### 1.4 大模型 API（3天）

**知识：**
- 专业术语：Endpoints、Token、Prompt、API Key
- 流式输出（WebSocket、SSE）
- Token 计算和费用控制

## 阶段 2：RAG 应用开发工程

### 2.1 RAG 基础（15天）

**核心概念：**
- RAG（检索增强生成）：让大模型先查资料再回答问题
- 三大范式：Naive RAG、Advanced RAG、Modular RAG
- 三大部件：Retriever（检索器）、Generator（生成器）、Augmentation Method（增强方法）

**Naive RAG Pipeline：**
1. 知识库构建（文档加载和分块、分块方案）
2. Embeddings 向量化（OpenAI/GLM/bge 等模型）
3. 向量相似度算法（余弦距离、点积、欧氏距离）
4. 向量数据库（作用、类型、主流产品对比）

### 2.2 RAG 三大范式和优化（10天）

**知识：**
- Naive RAG：索引→检索→生成
- Advanced RAG：预检索、检索增强、后检索
- Modular RAG：混合检索、智能编排、技术融合
- 优化方向：索引优化、检索前优化（Embedding 微调、混合检索、问题转换）、检索后优化（召回重排、信息压缩、知识融合）

### 2.3 RAG 项目评估（5天）

**评估指标：**
- 质量指标：上下文相关性、答案忠实度、答案相关性
- 能力指标：对噪声的鲁棒性、负面信息排除能力、信息整合能力
- 评估工具：RAGAS、ARES、Trulens

### 2.4 RAG 开源项目（7天）

| 项目 | 说明 |
|------|------|
| RAGFlow | 开源 RAG 引擎 |
| FastGPT | 知识库问答系统 |
| QAnything | 网易有道出品 |
| LangChain-Chatchat | LangChain 生态 |
| GraphRAG | 微软图增强 RAG |

## 阶段 3：大模型 Agent 应用架构

### 3.1 LangChain（15天）

**核心组件：**
- Chat Models vs LLMs（流式输出、结构性输出）
- 模型 I/O 封装：Prompts 模板、自定义模板、序列化
- 数据连接：文本向量化、向量数据库（Chroma/ES/FAISS/Milvus）、文档切割
- Memory 记忆封装：内置链、工具使用、多轮对话
- Chain（链）：LCEL 表达式、Runnable 协议、多链组合

**学习建议：** 先跑通 Demo（如本地知识库问答），再逐步深入。

### 3.2 LlamaIndex（5天）

数据框架，专注于将 LLM 与特定领域数据相结合。适合构建文档索引和问答系统。

### 3.3 Agent（20天）

**核心知识：** 规划（子任务拆解、反思改进）、记忆（Memory）、工具使用（Function Calling）、执行（Action）

**认知框架：** ReAct（思考-行动-观察）、Plan-and-Execute、Self-Ask、Thinking and Self-Reflection

**多 Agent 系统：** AutoGPT、CAMEL、AutoGen、MetaGPT

### 3.4 可视化开发框架 / Agent IDE（10天）

- **GPTs & Assistants API**：OpenAI 官方
- **Coze（扣子）**：字节跳动出品的 AI Bot 开发平台
- **Dify**：开源 LLM 应用编排工具

## 阶段 4：大模型微调和私有化部署

### 4.1 Transformer 深入（10天）

理解 Self-Attention、Encoder-Decoder 架构、Multi-head Attention、不同 Decoding 方法。

### 4.2 开源模型（20天）

- 国外：Llama、Falcon、vLLM、Ollama、Mistral
- 国内：ChatGLM、Qwen、DeepSeek、Baichuan、MOSS、InternLM

**学习建议：** 用 Ollama 跑 Llama3，用 vLLM 部署 ChatGLM。

### 4.3 Fine-Tuning（15天）

**流程：** 选择基座模型 → 数据收集和预处理（清洗、去重、增强）→ 微调训练

**训练框架：** Hugging Face Transformers、PyTorch、DeepSpeed

**学习建议：** 从简单分类任务开始，用 ChatGLM3 + LoRA 微调工单分类器，几百条高质量数据可见效果。

### 4.4 PEFT（参数高效微调，20天）

**技术：**
- Adapter Tuning、Prompt Tuning、Prefix Tuning
- LoRA（低秩适配微调）
- LoRA 变体：AdaLoRA、QLoRA、LongLoRA、SLoRA
- P-Tuning V2

### 4.5 Quantization（量化，10天）

**技术：** PTQ（训练后量化）、QAT（量化感知训练）、AWQ、GPTQ

量化可显著减少模型内存占用和计算需求，同时尽量保持模型性能。

### 4.6 语言模型训练数据（5天）

数据来源（通用/专业）、数据处理（过滤、去重、隐私消除）、数据影响分析。

### 4.7 大语言模型评估（5天）

评估指标（BLEU、ROUGE、METEOR、准确率、召回率、F1）、伦理和安全、垂直领域评估。

### 4.8 Multimodal（多模态，20天）

多模态模型处理文本、图像、音频、视频。AIGC、图像生成（DALL-E 3、Midjourney、Stable Diffusion + ControlNet）、语音生成（TTS）。

---

> 来源：鱼皮·编程导航 / codefather
