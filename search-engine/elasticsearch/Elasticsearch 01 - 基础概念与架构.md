---
title: "Elasticsearch 01 - 基础概念与架构"
date: 2024-01-01
tags: [Elasticsearch]
---

# Elasticsearch 01 - 基础概念与架构

## 什么是 Elasticsearch

Elasticsearch 是一个基于 **Apache Lucene** 的分布式、RESTful 搜索引擎。由 Shay Banon 于 2010 年开源，是 ELK（Elasticsearch + Logstash + Kibana）生态的核心。

### 核心能力

- **全文搜索** — 倒排索引、分词、相关性评分（BM25）
- **分析聚合** — 指标聚合、桶聚合、管道聚合
- **分布式** — 分片机制、自动故障转移
- **近实时（NRT）** — 写入后约 1s 可查询
- **REST API** — 全 HTTP 接口，客户端库丰富

## 核心概念

### 与关系型数据库的类比

| Elasticsearch | 关系型数据库 |
|--------------|-------------|
| Index（索引） | Database（数据库） |
| Type（类型，已废弃） | Table（表） |
| Document（文档） | Row（行） |
| Field（字段） | Column（列） |
| Mapping（映射） | Schema（表结构） |
| Shard（分片） | 分区 |

### Index（索引）

索引是文档的集合，类似数据库。命名规则：
- 全小写
- 不能包含 `\`, `/`, `*`, `?`, `"`, `<`, `>`, `|`, `,`, `#`
- 不能以 `-`, `_`, `+` 开头

### Document（文档）

JSON 格式的数据单元，是搜索的基本单位：

```json
{
  "_index": "products",
  "_id": "1",
  "_version": 1,
  "_source": {
    "title": "iPhone 15 Pro",
    "price": 7999,
    "stock": 100,
    "tags": ["手机", "苹果"],
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

### Mapping（映射）

定义字段类型和分析器：

```json
PUT /products
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "ik_max_word",
        "fields": {
          "keyword": { "type": "keyword" }
        }
      },
      "price":  { "type": "double" },
      "stock":  { "type": "integer" },
      "tags":   { "type": "keyword" },
      "created_at": { "type": "date" }
    }
  }
}
```

## 集群架构

```
┌──────────────────────────────────────────────┐
│              Elasticsearch Cluster           │
│                                              │
│  Node 1 (Master)     Node 2 (Data)           │
│  ┌──────────────┐    ┌──────────────┐        │
│  │ P0 (Primary) │    │ P0 (Replica) │        │
│  │ P1 (Replica) │    │ P1 (Primary) │        │
│  └──────────────┘    └──────────────┘        │
│                                              │
│  Node 3 (Ingest)     Node 4 (Coordinating)   │
│  ┌──────────────┐    ┌──────────────┐        │
│  │ 数据预处理   │    │ 请求路由     │        │
│  └──────────────┘    └──────────────┘        │
└──────────────────────────────────────────────┘
```

### 节点类型

| 类型 | 配置 | 职责 |
|------|------|------|
| Master | `node.roles: [master]` | 集群管理、元数据 |
| Data | `node.roles: [data]` | 数据存储、CRUD、搜索 |
| Ingest | `node.roles: [ingest]` | 数据预处理 Pipeline |
| Coordinating | `node.roles: []` | 负载均衡、请求路由 |
| Machine Learning | `node.roles: [ml]` | 异常检测（白金版） |

## REST API 快速上手

```bash
# 检查集群健康
GET /_cluster/health

# 创建索引
PUT /products
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1
  }
}

# 写入文档
POST /products/_doc
{
  "title": "MacBook Pro",
  "price": 14999
}

# 指定 ID 写入
PUT /products/_doc/1
{
  "title": "iPhone 15",
  "price": 7999
}

# 搜索
GET /products/_search
{
  "query": {
    "match": { "title": "手机" }
  }
}
```

## vs Solr

| 特性 | Elasticsearch | Solr |
|------|-------------|------|
| 分布式 | 原生（分片自动） | ZooKeeper 管理 |
| 实时性 | 近实时（默认 1s） | 近实时 |
| 生态 | ELK（Kibana/Logstash/Beats） | SolrCloud + Banana |
| 学习曲线 | 中等 | 较高 |
| 社区活跃度 | 极高 | 中等 |
|| 场景偏好 | 日志分析、通用搜索 | 企业搜索、传统项目 |

## Elastic Stack 生态

Elastic Stack 是一个开源的数据分析平台，主要用于实时搜索、分析和可视化大规模的结构化和非结构化数据。它包含以下主要组件：

### Elasticsearch
Elastic Stack 的核心组件，一个分布式的实时搜索和分析引擎。负责存储、搜索和分析数据，并提供 RESTful API 以进行数据索引和查询。

### Logstash
Logstash 是一个用于数据收集、转换和发送的数据处理管道工具。它可以从多种来源（如日志文件、消息队列、数据库等）收集数据，然后进行过滤、转换和标准化，最后将数据发送到 Elasticsearch 等目标存储或分析系统。

### Kibana
Elastic Stack 的可视化平台，用于分析和可视化 Elasticsearch 中的数据。它提供了丰富的图表、图形和仪表板，用户可以通过 Kibana 轻松地创建定制化的数据可视化和仪表板，并进行数据分析和探索。

### Beats
Beats 是一组轻量级的数据收集器，用于收集各种类型的操作数据，并将其发送到 Elasticsearch 或 Logstash 进行处理和存储。Beats 包括多个模块，如 Filebeat 用于收集日志文件、Metricbeat 用于收集系统和服务指标、Packetbeat 用于网络数据分析等。

这些组件共同构成了 Elastic Stack，使用户能够以高效、灵活和可扩展的方式收集、存储、搜索、分析和可视化数据。

## ES vs MongoDB

Elasticsearch（ES）和 MongoDB 都是流行的数据存储和检索解决方案，但它们在设计目标、特点和适用场景上有所不同。

### 主要优势对比

| 维度 | Elasticsearch | MongoDB |
|------|-------------|---------|
| 全文搜索 | 专门为全文搜索设计，支持复杂搜索、聚合分析和搜索建议 | 支持文本搜索，但功能相对较弱 |
| 分布式性能 | 原生分布式，水平扩展性出色，高可用 | 支持分片和副本集，但扩展性不如 ES |
| 实时索引和搜索 | 近实时（NRT），写入后约 1s 可查询 | 实时性能相对较弱 |
| 聚合分析 | 丰富的聚合功能（分组、统计、日期直方图等） | 支持聚合框架，但不如 ES 强大灵活 |
| 结构化数据融合 | 同时处理全文检索和结构化数据 | 更偏向结构化数据存储和查询 |

### 全文搜索功能对比

**分词支持**：MongoDB 内置简单分词器，不支持自定义；ES 支持多种内置分词器和定制化插件（如 IK Analyzer、Smart Chinese Analysis 等）。

**定制化插件**：ES 允许通过插件扩展分词器，适应不同语言的分词需求；MongoDB 不支持。

**复杂查询**：ES 提供丰富的查询操作和查询语法，支持复杂的全文搜索和过滤条件；MongoDB 的全文搜索操作相对简单。

### 应用场景

**MongoDB 适用场景**：大部分操作以 CRUD 为主、需要灵活的数据模型、实时数据分析和报表生成。

**Elasticsearch 适用场景**：需要高效全文搜索和分析、复杂的搜索查询和聚合分析、需要实时索引和搜索功能。

## 搜索引擎工作流程

搜索引擎的工作流程可以分为四个核心步骤：

### 1. 抓取（Crawling）
网络爬虫在互联网上扫描网页，跟踪 URL 链接，发现新的内容（包括网页、图片、视频和文件），并将 URL 存储在 URL 存储器中。

### 2. 索引（Indexing）
网页被抓取后，搜索引擎对网页进行解析，并将内容编入索引数据库。对内容进行分析和分类，评估关键字、网站质量、内容新鲜度等因素。

### 3. 排名（Ranking）
搜索引擎使用复杂的算法来决定搜索结果的顺序，考虑关键词、页面相关性、内容质量、用户参与度、页面加载速度等因素。还可以根据用户过去的搜索历史、位置、设备等进行个性化处理。

### 4. 查询（Query）
当用户执行搜索时，搜索引擎筛选其索引，提供最相关的结果。

### ES 在其中的角色

- **索引阶段**：ES 可以作为索引数据库，存储和索引网页内容。
- **排名阶段**：ES 的查询结果中的相关度得分（`_score`）可作为最终排名的参考之一。得分越高表示文档与查询的匹配程度越高，排名越靠前。

```json
POST /articles/_search
{
  "query": {
    "match": {
      "title": "Elasticsearch"
    }
  }
}
```

查询结果中每个文档都有一个 `_score` 字段，表示其相关度得分，得分最高的文档排名最靠前。

## 相关性评分算法

Elasticsearch 使用复杂的算法和模型来计算文档的相关度得分，确保搜索结果的准确性和相关性。

### TF-IDF

- **TF（词频）**：计算查询词在文档中出现的频率，词频越高，得分越高。
- **IDF（逆文档频率）**：计算查询词在整个索引中出现的频率，出现在越多的文档中，表示越常见，相关度得分越低。

### BM25（默认算法）

Elasticsearch 默认使用 BM25 算法（Best Matching 25），它是 TF-IDF 的改进版本，考虑了词频和逆文档频率之间的平衡，并且对较长的字段有较好的适应性。

### 字段长度归一化

对于较长的字段，文档的相关度得分会被字段长度归一化，避免较长的字段对相关度得分的影响过大。

### 字段权重调整

Elasticsearch 支持对不同字段设置不同的权重（boost），通过字段权重来调整字段在计算得分时的重要性。

> 来源：鱼皮·编程导航 / codefather
