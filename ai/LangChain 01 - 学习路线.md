---
title: "AI - LangChain 学习路线（Python）"
date: 2026-07-25
tags:
  - AI
  - LangChain
  - LLM
  - Python
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# AI - LangChain 学习路线（Python）

> LangChain 是当前最流行的大语言模型（LLM）应用开发框架，提供模型封装、Prompt 模板、输出解析、记忆管理、文档加载、向量存储、链（Chains）、Agent 等组件。核心理念是「组合」——通过组合不同组件快速构建 AI 应用。

## 阶段 1：AI 大模型基础（3-15 天）

**大模型基础：**
- LLM 概念、Token 和上下文窗口
- 主流模型（GPT、Claude、文心、通义等）
- Prompt Engineering 基础

**API 调用：**
- OpenAI API、国产模型 API
- 参数配置（temperature、top_p）、错误处理、流式输出

**Python 基础：** 语法、异步编程、常用库（requests、json）

## 阶段 2：LangChain 核心概念（10-25 天）

| 模块 | 必学内容 |
|------|---------|
| 基础 | LangChain 架构、安装配置、Hello World |
| 模型封装 | LLM 接口、Chat Models、流式输出 |
| Prompt 模板 | PromptTemplate、ChatPromptTemplate、Few-shot、Prompt 组合 |
| 输出解析 | OutputParser、StructuredOutputParser、Pydantic 解析器、JSON 解析 |
| 链（Chains） | LLMChain、SequentialChain、RouterChain、自定义 Chain |

**学习重点：** LangChain 的核心是「组合」。从简单的 LLMChain 开始，逐步理解链式结构。Prompt 模板让管理更规范灵活，输出解析使模型输出结构化可控。

## 阶段 3：文档处理和 RAG（15-30 天）

**文档加载：** Document Loaders（文本、PDF、网页、数据库）
**文档分割：** Text Splitters、RecursiveCharacterTextSplitter、按语义分割
**向量化：** Embeddings（OpenAI、本地模型）
**向量存储：** Chroma、FAISS、Pinecone、相似度搜索
**检索器：** VectorStoreRetriever、多路检索、检索优化
**RAG 应用：** RetrievalQA、ConversationalRetrievalChain、评估调优

**关键参数：** chunk_size=500-1000，chunk_overlap=100-200（RecursiveCharacterTextSplitter）

## 阶段 4：Agent 开发（15-35 天）

**Agent 基础：** 概念和架构、ReAct Agent、Tool Calling、执行流程

**工具（Tools）：** 内置工具（搜索、计算器、数据库查询）、自定义工具（函数+描述）、工具组合

**Agent 类型：** Zero-shot ReAct、Structured Tool Chat、OpenAI Functions Agent、自定义 Agent

**AgentExecutor：** 最大迭代次数、错误处理、日志记录

## 阶段 5：LangGraph 高级编排（15-30 天）

LangGraph 使用图（Graph）方式定义执行流程，比传统 Chain 更灵活可控：

- **图结构**：节点（Node）和边（Edge）、状态（State）管理
- **工作流**：顺序执行、条件分支、循环、并行执行
- **Human-in-the-Loop**：人工介入、暂停恢复、人工审核
- **多 Agent 协作**：Agent 通信、任务分配、结果聚合

## 阶段 6：LangChain 生态系统（7-20 天）

| 工具 | 说明 | 优先级 |
|------|------|--------|
| LangChain4j | Java 版本，Spring Boot 集成良好 | 按需 |
| LangChain.js | JavaScript/TypeScript 版本 | 按需 |
| LangSmith | 官方监控和调试工具，可视化 LLM 调用 | 必学 |
| LangServe | 基于 FastAPI 的部署方案 | 建议学 |

## 阶段 7：项目实战（30-45 天）

**推荐项目方向：**
- 文档问答系统（RAG + 上传文档）
- 代码助手（生成、解释、审查代码）
- 智能客服（处理咨询 + 工具调用）
- 内容创作助手（搜索资料 + 生成/优化文章）
- 数据分析助手（数据库查询 + 图表生成 + 报告撰写）

> 来源：鱼皮·编程导航 / codefather
