---
title: "TextCNN 01 - 文本分类与评论审核"
date: 2026-07-25
tags: [深度学习, NLP, 文本分类, TextCNN, 评论审核]
source: "鱼皮·编程导航 / codefather"
---

# 概念 05 - TextCNN 文本分类与评论审核

> 基于 TextCNN（卷积神经网络）实现文章评论自动审核，结合违规词检测 + 深度学习模型，在 CPU 上即可训练。训练 100 轮后验证损失 0.01，测试准确率 97%+。

## 核心要点

### 1. 系统架构

整体审核流程分四层：

1. **预处理**：文本清洗（去除无关字符、统一大小写）、分词
2. **违规词检测**：维护违规词库 + 敏感词库，采用精确匹配、模糊匹配、同义词匹配多层次策略，支持动态过滤
3. **TextCNN 模型**：捕捉语义和上下文信息
4. **综合判断**：融合规则匹配 + 模型输出，形成最终审核决策

### 2. TextCNN 模型结构

```
Input: 文本序列 (batch, sentence_length)
  |
Embedding层: (batch, sentence_length, embed_dim)
  |   \
  V    V
Conv2D + ReLU + MaxPool: (batch, kernel_num)   (kernel_size=3)
  |
Conv2D + ReLU + MaxPool: (batch, kernel_num)   (kernel_size=4)
  |
Conv2D + ReLU + MaxPool: (batch, kernel_num)   (kernel_size=5)
  |      |      |
  V      V      V
Concatenate: (batch, 3 × kernel_num)
  |
Dropout: (batch, 3 × kernel_num)   (dropout_rate=0.5)
  |
全连接层: (batch, class_num)
```

**超参数**：
- `kernel_num=16`，三种卷积核大小 3/4/5
- `embed_dim`: 嵌入维度（超参数）
- `class_num=2`（正常/违规）
- `batch_size=128`

### 3. 嵌入层原理

将单词索引映射为稠密词向量。示例：

```text
词汇表: ['I', 'love', 'natural', 'language', 'processing']
embed_dim=4

输入 [0, 1, 3] → 词向量:
[[0.1, 0.2, 0.3, 0.4],   # "I"
 [0.5, 0.6, 0.7, 0.8],   # "love"
 [1.3, 1.4, 1.5, 1.6]]   # "language"
```

嵌入层权重在训练过程中学习，以更好地适应具体任务。

### 4. 训练配置

| 配置项 | 值 |
|---|---|
| 优化器 | Adam，lr=0.01 |
| 损失函数 | NLLLoss（负对数似然损失） |
| Epochs | 100 |
| Batch size | 128 |
| 数据 shuffle | 是 |

**依赖**：PyTorch（CPU 版即可）、jieba（中文分词）、nltk、pandas、tqdm、numpy、Flask、gunicorn

### 5. 部署

**本地部署**：Flask 提供 REST API + HTML 测试页面

**生产部署**（Gunicorn）：
```bash
gunicorn -w 3 -b 0.0.0.0:9102 --preload predict_online:app
```

**Gunicorn 关键概念**：
- **Master 进程**：监听端口、接收请求、分配给 worker
- **Worker 进程**：实际处理请求，支持 sync/eventlet/gevent 等类型
- **预加载（`--preload`）**：在 worker 启动时加载应用代码，避免每个请求都初始化，提高性能

> 源码：https://gitee.com/crzzx/comment_moderation

> 来源：鱼皮·编程导航 / codefather
