---
title: Java 43 - Spring AI 学习路线
tags:
  - Spring AI
  - Java
  - AI
  - 学习路线
source: 鱼皮·编程导航 / codefather
date: 2026-08-05
---

# Java 43 - Spring AI 学习路线

> Spring AI 是 Spring 生态推出的 AI 应用开发框架，把 Spring 的设计理念与最佳实践带入 AI 领域，为 Java 开发者提供统一的 AI 模型访问 API，支持对话、Embedding、多模态、RAG、工具调用与智能体开发。本文梳理从 Spring Boot 基础到求职备战的完整学习路线，共 7 个阶段。

## 开篇介绍

Spring AI 是 Spring 生态系统推出的 AI 应用开发框架，它把 Spring 的设计理念和最佳实践带入了 AI 领域。作为 Java 开发者最熟悉的框架体系，Spring AI 让 Java 程序员能够**用熟悉的方式开发 AI 应用**，无需学习全新的技术栈。

### 为什么学 Spring AI

1. **上手成本低**：设计理念和 API 风格与 Spring Boot 一脉相承，熟悉 Spring Boot 即可顺畅学习
2. **统一 API**：一套 API 访问各种 AI 模型（OpenAI、Anthropic、Azure、Google、DeepSeek、阿里云等），支持对话、Embedding、多模态图像生成等多种功能
3. **高级特性完善**：提供 RAG、工具调用（Function Calling）、结构化输出、观测性等开箱即用的能力
4. **应用场景广泛**：企业智能客服、文档问答系统、代码助手、内容创作工具等
5. **国产化支持**：国内大厂推出 Spring AI Alibaba，可轻松对接阿里云大模型，提供完整 AI 应用开发解决方案和清晰的中文文档
6. **就业竞争力**：同时掌握 Java 后端与 AI 开发，在求职上更有竞争力

### 学习前提

1. **Java 基础**：熟练掌握 Java 编程（Spring AI 要求 Java 17+，建议使用 Java 21）
2. **Spring Boot 基础**：项目创建、自动配置、依赖注入、RESTful API 开发（必学）
3. **Spring 设计理念**：熟悉 IoC、AOP 等思想，便于理解 Advisors 等机制
4. **AI 基础概念**：了解大模型、Prompt、Token 等基本概念（建议）

### 就业方向

1. Java AI 应用开发工程师：使用 Spring AI 开发各类 AI 应用，主要就业方向
2. 全栈 AI 工程师：能处理前端、后端、数据库等全栈工作
3. 企业 AI 架构师：负责企业 AI 系统的架构设计和技术选型
4. AI 产品经理：理解 Spring AI 的能力边界，更好地规划产品功能

## 整体学习建议

1. **先打基础**：先回顾 Spring Boot 基础，熟悉 Spring 的设计理念和开发方式
2. **理论结合实践**：跟着官方文档动手实践，边学路线理论、边做项目实战，效果最佳
3. **重点攻克 RAG**：RAG 是 Spring AI 最重要的应用场景，投入最多精力
4. **善用 AI 工具**：辅助理解概念、调试代码
5. **持续关注生态**：Spring AI 生态发展迅速，API 和概念都可能变化，多关注官方文档与社区动态

## 阶段总览

| 阶段 | 内容 | 建议时长 |
| --- | --- | --- |
| 阶段 1 | Spring Boot 基础（回顾） | 3-15 天 |
| 阶段 2 | Spring AI 基础 | 10-30 天 |
| 阶段 3 | RAG 开发 | 5-15 天 |
| 阶段 4 | 高级特性 | 5-15 天 |
| 阶段 5 | Spring AI Alibaba | 5-15 天 |
| 阶段 6 | 项目实战 | 30-45 天 |
| 阶段 7 | 求职备战 | 面试前突击 |

---

## 阶段 1：Spring Boot 基础（回顾，3-15 天）

### 学习目标

本阶段按需学习，主要回顾 Spring Boot 基础知识，为 Spring AI 学习打下基础。

### 知识点

**Spring Boot 基础（必学）**
- Spring Boot 项目创建
- 自动配置原理
- 依赖注入
- 配置文件
- RESTful API 开发

**Java 基础（必学）**
- Java 17+ 特性
- Lambda 表达式
- Stream API
- Record 类型

### 学习建议

1. Spring AI 要求 Java 17 或更高版本，建议使用 Java 21；如果 Java 版本较低，需要先升级
2. 已熟悉 Spring Boot 可快速过一遍本阶段；Spring Boot 新手建议先系统学习 Spring Boot 基础

### 学习资源

- [Spring Boot 官方文档](https://docs.spring.io/spring-boot/)：权威参考
- 网上的 Spring Boot 入门教程与学习路线均可作为补充

---

## 阶段 2：Spring AI 基础（10-30 天）

### 学习目标

掌握 Spring AI 的核心概念和基本用法，能够开发简单的 AI 应用。

### 知识点

**Spring AI 核心概念（必学）**
- Spring AI 架构
- 模型抽象（Model API）
- ChatClient API
- Advisors 模式
- 自动配置

**Chat Model（必学）**
- ChatModel 接口
- 模型配置
- 同步调用 vs 流式调用
- 多模态支持

**Prompt 管理（必学）**
- Prompt Template
- 系统消息（System Message）
- 用户消息（User Message）
- 消息历史管理

**结构化输出（必学）**
- BeanOutputConverter
- MapOutputConverter
- JSON Schema

### 学习建议

1. Spring AI 的核心是 ChatClient API，它提供流畅的 API 与 AI 模型交互。ChatClient 的设计理念类似 WebClient 和 RestClient，熟悉这些 API 的话学习成本很低：

```java
@RestController
class MyController {

    private final ChatClient chatClient;

    public MyController(ChatClient.Builder chatClientBuilder) {
        this.chatClient = chatClientBuilder.build();
    }

    @GetMapping("/ai")
    String generation(String userInput) {
        return this.chatClient.prompt()
            .user(userInput)
            .call()
            .content();
    }
}
```

2. Spring AI 支持多种 AI 模型提供商（OpenAI、Anthropic、Azure、Google、DeepSeek 等），通过统一 API 可以轻松切换模型，无需修改业务代码
3. Advisors 是 Spring AI 的重要概念，类似 AOP 切面或拦截器，可在调用 AI 前后执行额外逻辑（添加上下文、过滤输出、记录日志等），一定要理解其工作原理和应用场景
4. 建议从官方文档开始学习，文档非常详细且提供了大量示例，跟着文档动手实践效果最好
5. Spring AI Alibaba 是国内团队维护的版本，学完 Spring AI 后也建议学习一下，了解国产模型的快速集成方法

### 学习资源

- ⭐ [Spring AI 官方文档](https://docs.spring.io/spring-ai/reference/)：最权威的学习资源
- ⭐ [Spring AI Alibaba 官方文档](https://java2ai.com/)：国内开发者友好
- [Spring AI GitHub](https://github.com/spring-projects/spring-ai)：源代码
- [Awesome Spring AI](https://github.com/spring-ai-community/awesome-spring-ai)：社区资源大全
- [鱼皮的 Spring AI 特性讲解（B 站）](https://www.bilibili.com/video/BV1xkJxzEEmD)：快速入门视频
- [鱼皮的保姆级 AI 指南（B 站）](https://www.bilibili.com/video/BV1i9Z8YhEja/)：程序员必知必会的 AI 概念与工具

---

## 阶段 3：RAG 开发（5-15 天）

RAG（Retrieval-Augmented Generation，检索增强生成）是一种结合信息检索技术和 AI 内容生成的混合架构，可以解决大模型的知识时效性限制和幻觉问题。简单来说，RAG 就像给 AI 配了一个"小抄本"，让 AI 回答问题前先查一查特定的知识库来获取知识，确保回答基于真实资料而不是凭空想象。

### 学习目标

掌握使用 Spring AI 开发 RAG 应用，能够实现文档问答等功能。

### 知识点

**文档处理（ETL）（必学）**
- DocumentReader（文档读取器）
- DocumentTransformer（文档转换器）
- DocumentWriter（文档写入器）
- 文档切割策略

**向量存储（必学）**
- VectorStore 接口
- 向量数据库集成（PGVector、Redis、Milvus 等）
- 相似度搜索
- 元数据过滤

**检索增强（必学）**
- QuestionAnswerAdvisor
- RetrievalAugmentationAdvisor
- DocumentRetriever
- 查询转换和扩展

**高级特性（建议学）**
- 查询重写
- 查询翻译
- 多查询扩展
- 重排序

### 学习建议

1. RAG 是 Spring AI 最重要的应用场景，要深入理解四大核心步骤：**文档处理、向量化、检索、生成**，Spring AI 为每个步骤都提供了完善的组件支持
2. 文档处理（ETL）是 RAG 的基础。Spring AI 提供多种 DocumentReader（如 PDFReader、MarkdownReader、JsonReader 等）处理各种格式的文档；要掌握文档切割策略，合理的切割能显著提升 RAG 效果
3. 向量存储的选择很重要：开发阶段可使用 SimpleVectorStore（内存存储），生产环境建议使用 PGVector（PostgreSQL 扩展）或专业向量数据库。PGVector 的优势是可以复用现有 PostgreSQL，成本低、维护简单
4. Advisors 是 Spring AI 实现 RAG 的核心机制：QuestionAnswerAdvisor 简单易用，RetrievalAugmentationAdvisor 更加灵活，要理解两者的区别和应用场景，掌握配置方法

### 学习资源

- [Spring AI RAG 官方文档](https://docs.spring.io/spring-ai/reference/api/retrieval-augmented-generation.html)：官方教程
- [Spring AI ETL 官方文档](https://docs.spring.io/spring-ai/reference/api/etl-pipeline.html)：文档处理

---

## 阶段 4：高级特性（5-15 天）

### 学习目标

掌握 Spring AI 的高级特性，能够开发更复杂的 AI 应用。

### 知识点

**工具调用（Function Calling）（必学）**
- 工具定义
- 工具注册
- 工具执行
- 工具链

**Chat Memory（必学）**
- 对话记忆管理
- MessageChatMemoryAdvisor
- 多用户会话隔离
- 持久化存储

**多模态（建议学）**
- 图像理解
- 音频处理
- 文档处理
- 多模态组合

**观测性（必学）**
- 日志记录
- 指标监控
- 链路追踪
- 调试工具

**安全性（必学）**
- 输入验证
- 输出过滤
- 提示词注入防护
- 内容审核

### 学习建议

1. 工具调用（Function Calling）是让 AI 能够执行实际任务的关键：通过工具调用，AI 可以查询数据库、调用 API、执行代码等。要掌握如何定义工具、如何让 AI 正确调用工具、如何处理工具返回结果（例如让 AI 调用联网搜索工具获取最新知识）
2. Chat Memory 让 AI 能够记住历史对话、实现多轮对话。Spring AI 提供了 MessageChatMemoryAdvisor 轻松实现对话记忆，要理解如何配置记忆大小、如何实现多用户隔离、如何持久化存储
3. 可观测性在生产环境非常重要。Spring AI 提供完善的观测性支持（日志、指标、链路追踪等），要学会使用这些工具调试和监控 AI 应用；可参考 [Prometheus + Grafana + ARMS 大厂监控视频教程（B 站）](https://www.bilibili.com/video/BV1QPYDztEtW/)
4. AI 应用可能面临提示词注入攻击、输出不当内容等安全问题，要学习如何防范这些问题，保证应用安全

### 学习资源

- [Spring AI Chat Memory 文档](https://docs.spring.io/spring-ai/reference/api/chatclient.html#_chat_memory)：对话记忆
- [Spring AI 观测性文档](https://docs.spring.io/spring-ai/reference/observability/index.html)：监控调试

---

## 阶段 5：Spring AI Alibaba（5-15 天）

Spring AI Alibaba 是阿里巴巴团队维护的 Spring AI 扩展，为国内开发者提供更好的支持，不仅集成了国产大模型，还提供了很多额外功能。

### 学习目标

掌握 Spring AI Alibaba 的使用，能够集成国产大模型和云服务。

### 知识点

**Spring AI Alibaba 基础（必学）**
- Spring AI Alibaba 概述
- 和 Spring AI 的关系
- 阿里云模型集成
- 配置和使用

**阿里云服务集成（必学）**
- 通义千问模型
- 文心一言模型
- 阿里云 Embedding 模型
- 阿里云向量存储

**扩展功能（建议学）**
- 文档读取器扩展
- 向量存储扩展
- 工具集成

### 学习建议

1. 阿里云百炼平台提供了丰富的 AI 服务，包括大模型、Embedding 模型、向量存储、知识库等，通过 Spring AI Alibaba 可以轻松使用这些服务
2. Spring AI Alibaba 提供了很多扩展的 DocumentReader，如加载飞书文档、B 站视频字幕、GitHub 文档等，非常实用

### 学习资源

- ⭐ [Spring AI Alibaba 官方文档](https://java2ai.com/)：官方文档
- [阿里云百炼平台](https://bailian.console.aliyun.com/)：云服务平台

---

## 阶段 6：项目实战（30-45 天）

### 学习目标

通过完整的项目实践，综合运用所学知识，积累 Spring AI 开发经验。

### 学习建议

1. 开发一个完整的 Spring AI 应用，推荐企业真实项目方向：企业知识库问答、智能客服系统、代码助手、文档分析工具、学习辅导系统
2. 项目要包含完整功能：用户界面、模型集成、RAG 实现、工具调用、对话记忆、日志监控。建议使用 Spring Boot + Spring AI + Vue/React 的技术栈
3. 关注项目的完成度和质量：一个简单但完整的项目比一个复杂但半成品的项目更有价值。要做好文档、写好 README、提供运行示例

### 项目推荐

**Spring AI 技术栈：**
- AI 超级智能体项目：Spring Boot 3 + Spring AI，实战 AI 应用 + 拥有自主规划能力的超级智能体，涵盖 RAG、Tool Calling、MCP（模型上下文协议）、AI 智能体等核心技术
- AI 恋爱大师类应用：基于 Spring Boot 3 + Spring AI 的完整业务应用，涵盖自定义拦截器、上下文持久化、结构化输出、大模型接入与本地部署、Prompt 工程与多模态、向量数据库、AI 服务化与 Serverless 部署

**其他 AI 技术栈（可作参考）：**
- LangChain4j + LangGraph4j：AI 智能体、工作流编排
- LangChain4j + SSE 实时推送 + RxJava 响应式编程：AI 应用开发
- LangChain4j + AI 图表生成 + 异步化 + 线程池 + RabbitMQ：智能 BI 类应用

**其他项目方向：**
- 企业知识库问答系统
- 智能客服机器人
- 技术文档助手
- 代码生成和审查工具

---

## 阶段 7：求职备战

### 学习目标

熟练掌握 Spring AI 常见面试题，准备好简历和项目经历，顺利通过面试。

### 学习建议

1. **准备 AI 项目**：建议在简历上添加至少 1 个 AI 项目经历，最好是完整的、已经上线的 AI 应用
2. **准备简历**：写清楚项目职责、技术亮点与业务成果，突出 Spring AI 相关技术栈
3. **多刷面试题**：Spring AI 的面试题主要包括框架使用、RAG 技术、工具调用等方向，围绕这些方向系统复习

### 经典面试题

**基础概念：**

1. 什么是 Spring AI？它解决了什么问题？
2. Spring AI 和 LangChain 有什么区别？
3. ChatClient API 的设计理念是什么？
4. 什么是 Advisors？有什么作用？
5. Spring AI 支持哪些 AI 模型？

**RAG 技术：**

1. Spring AI 如何实现 RAG？
2. QuestionAnswerAdvisor 和 RetrievalAugmentationAdvisor 有什么区别？
3. 如何使用 Spring AI 处理文档？
4. 如何集成向量数据库？
5. 如何优化 RAG 检索效果？

**高级特性：**

1. Spring AI 如何实现工具调用？
2. 如何实现对话记忆？
3. Spring AI 如何支持多模态？
4. 如何监控 Spring AI 应用？

**项目经验：**

1. 你开发过哪些 Spring AI 应用？
2. 项目中遇到过什么技术难点？
3. Spring AI 和 Spring AI Alibaba 有什么区别？
4. 如何部署 Spring AI 应用？

---

## 尾声

Spring AI 是 Java 开发者的首选 AI 框架，掌握 Spring AI 将让你在 AI 浪潮中占据有利位置。从基础概念到高级特性，从简单对话到 RAG 应用，从工具调用到多模态处理，Spring AI 提供了完整的解决方案。

学习 Spring AI 要先打好 Spring Boot 基础，熟悉 Spring 的设计理念和开发方式；深入学习 Spring AI 的核心概念和 API，掌握 ChatClient、Advisors 等核心组件；重点学习 RAG 开发，这是最重要的应用场景；掌握高级特性，如工具调用、对话记忆、多模态等；了解 Spring AI Alibaba，集成国产大模型和云服务；最后通过完整的项目实践，积累开发经验。

Spring AI 和 Spring AI Alibaba 的生态系统在不断发展，新功能和集成不断加入，要持续学习、多关注官方文档和社区动态。学习时建议多看示例项目，多动手实践。
