---
title: "AI - LangChain4j 学习路线"
date: 2026-07-25
tags: [LangChain4j, AI, Java, Java框架, 学习路线]
source: "鱼皮·编程导航 / codefather"
---

# AI - LangChain4j 学习路线

> LangChain4j 是专为 Java 开发者设计的 AI 应用开发框架，Python LangChain 的 Java 实现，深度针对 Java 生态优化。提供与 LLM 和向量数据库交互的统一 API，支持声明式开发模式（注解+接口），可与 Spring Boot、Quarkus 集成。

**核心特点：**
- 声明式开发：`@SystemMessage`、`@UserMessage` 注解定义 AI 行为
- 支持多种模型：OpenAI、Anthropic、Azure、阿里云等
- 支持多种向量数据库：Milvus、Pinecone、Chroma 等
- 支持 Prompt 模板、结构化输出、对话记忆、RAG、Agent、工具调用

## 学习路线图

![](../image/img_langchain4j_roadmap.png)

## 就业方向

| 岗位 | 说明 |
|------|------|
| Java AI 应用开发工程师 | 使用 LangChain4j 开发 AI 应用（主要方向） |
| 全栈 AI 工程师 | 前后端 + AI 全栈 |
| AI 架构师 | AI 系统架构设计和技术选型 |
| 独立开发者 | 快速开发 AI 产品 |

## 阶段 1：Java 基础（回顾，10-15 天）

**Java 17+ 特性 [必学]：** Lambda、Stream API、函数式编程、注解
**Spring Boot 基础 [建议学]：** 项目创建、依赖注入、自动配置、RESTful API

## 阶段 2：LangChain4j 基础（5-10 天）

**核心概念：**
- **AI Service**：声明式开发，定义接口 + 注解，框架自动实现
- `@SystemMessage`：定义系统提示词
- `@UserMessage`：定义用户消息模板
- **Prompt Template**：变量替换，从文件读取
- **结构化输出**：返回值设为 POJO、Record 或 List，框架自动解析 AI 输出

```java
interface Friend {
    @SystemMessage("You are a good friend of mine. Answer using slang.")
    String chat(String userMessage);
}
Friend friend = AiServices.create(Friend.class, model);
String answer = friend.chat("Hello"); // Hey! What's up?
```

## 阶段 3：RAG 开发（5-15 天）

**文档处理：** DocumentLoader、DocumentSplitter、DocumentTransformer、元数据管理
**Embedding：** EmbeddingModel、文本向量化、存储
**向量存储：** EmbeddingStore（内存/向量数据库）、相似度搜索
**RAG 实现：** ContentRetriever、EmbeddingStoreContentRetriever、引用来源获取

三种实现方式：
1. **极简版**：内置组件，开箱即用
2. **标准版**：自定义配置，效果更好
3. **进阶版**：RAG Pipeline，最灵活

## 阶段 4：Agent 和工具调用（5-15 天）

**工具定义：** `@Tool` 注解 + 方法和参数描述
**工具调用：** 注册 → 执行 → 返回值处理 → 多工具调用
**MCP 集成 [建议学]：** Model Context Protocol 开放标准，支持网络搜索、数据库查询等
**Agent：** 自主决定调用哪些工具，理解执行流程和调试

## 阶段 5：高级特性（5-15 天）

**Chat Memory [必学]：** MessageWindowChatMemory、多用户会话隔离
**Guardrails [必学]：** 输入护轨/输出护轨，敏感词过滤和内容审核
**流式输出 [必学]：** StreamingChatModel、TokenStream、SSE 集成
**观测性 [必学]：** 日志、Listener、调试工具、性能监控

## 阶段 6：项目实战（15-30 天）

**入门级项目：**
- AI 程序员技术练兵场（鱼皮原创，游戏化学习）
- AI 编程小助手（鱼皮开源）
- 智能客服机器人 / 文档问答系统

**企业级项目：**
- AI 零代码应用生成平台（鱼皮原创，对标大厂）
- 企业知识库管理 / AI 代码生成平台
- 智能数据分析助手

## 阶段 7：求职备战

**经典面试题：**
- LangChain4j 与 Spring AI 区别、AI Service 工作原理
- RAG 实现方式、文档处理、向量数据库集成
- 工具调用、Guardrails、流式输出、对话记忆
- LangChain4j 与 Python LangChain 的区别

> 来源：鱼皮·编程导航 / codefather
