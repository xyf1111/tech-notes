---
title: "Meilisearch 01 - 快速入门与对比"
date: 2024-01-01
tags: [Meilisearch]
---

# Meilisearch 01 - 快速入门与对比

## 什么是 Meilisearch

Meilisearch 是一个 Rust 编写的开源搜索引擎，以**开发者体验**和**开箱即用**著称。

### 核心特点

- **毫秒级搜索** — 即使百万级数据也 < 50ms
- **模糊搜索** — 自带 Typo Tolerance（拼写容错）
- **中文支持** — 内置中文分词，无需额外插件
- **即搜即得** — 默认前缀搜索、高亮、关键词高亮
- **零配置** — 启动即可用，自动推断字段类型
- **REST API** — 全部通过 HTTP 管理

## 快速开始

### 安装

```bash
# macOS
brew install meilisearch
meilisearch --master-key=myMasterKey

# Docker
docker run -it --rm \
  -p 7700:7700 \
  -v $(pwd)/data:/meili_data \
  getmeili/meilisearch \
  meilisearch --master-key=myMasterKey
```

### 创建索引与写入数据

```bash
# 创建索引
curl -X POST 'http://localhost:7700/indexes' \
  -H 'Authorization: Bearer myMasterKey' \
  -H 'Content-Type: application/json' \
  -d '{"uid": "products", "primaryKey": "id"}'

# 写入文档
curl -X POST 'http://localhost:7700/indexes/products/documents' \
  -H 'Authorization: Bearer myMasterKey' \
  -H 'Content-Type: application/json' \
  -d '[
    { "id": 1, "title": "iPhone 15 Pro", "price": 7999, "brand": "Apple" },
    { "id": 2, "title": "MacBook Air M3", "price": 8999, "brand": "Apple" },
    { "id": 3, "title": "小米14 Ultra", "price": 5999, "brand": "Xiaomi" }
  ]'
```

### 搜索

```bash
# 基础搜索（支持拼写容错）
curl 'http://localhost:7700/indexes/products/search?q=iphon&limit=10'

# 返回
{
  "hits": [
    { "id": 1, "title": "iPhone 15 Pro", "price": 7999 },
    { "id": 2, "title": "MacBook Air M3", "price": 8999 }
  ],
  "query": "iphon",
  "processingTimeMs": 1,
  "limit": 10,
  "estimatedTotalHits": 2
}
```

## 前端集成（InstantSearch）

Meilisearch 的最大优势是与前端的无缝集成：

```html
<script src="https://cdn.jsdelivr.net/npm/meilisearch@latest"></script>
<script src="https://cdn.jsdelivr.net/npm/instantsearch.js@4"></script>

<div id="searchbox"></div>
<div id="hits"></div>

<script>
const searchClient = instantMeiliSearch(
  'http://localhost:7700',
  'myMasterKey'
);

const search = instantsearch({
  indexName: 'products',
  searchClient,
});

search.addWidgets([
  instantsearch.widgets.searchBox({ container: '#searchbox' }),
  instantsearch.widgets.hits({ container: '#hits' }),
]);

search.start();
</script>
```

## 核心配置

### 可搜索字段

```bash
curl -X PATCH 'http://localhost:7700/indexes/products/settings' \
  -H 'Content-Type: application/json' \
  -d '{
    "searchableAttributes": ["title", "brand", "description"],
    "filterableAttributes": ["price", "brand"],
    "sortableAttributes": ["price"],
    "rankingRules": [
      "words",
      "typo",
      "proximity",
      "attribute",
      "sort",
      "exactness"
    ]
  }'
```

### 过滤与排序

```bash
# 搜索 + 过滤 + 排序
curl 'http://localhost:7700/indexes/products/search?q=手机&filter=price >= 1000 AND price <= 5000&sort=price:asc'
```

## Meilisearch vs Elasticsearch

| 特性 | Meilisearch | Elasticsearch |
|------|------------|---------------|
| 语言 | Rust | Java |
| 安装 | 单文件下载 | JDK + 配置复杂 |
| 学习曲线 | 极低（15 分钟上手） | 较高 |
| 中文搜索 | 内置支持 | 需要 IK 插件 |
| Typo Tolerance | 内置（自动） | 需配置 |
| 聚合能力 | 有限 | 强大 |
| 分布式 | 有限（企业版支持） | 原生 |
| 数据量 | 百万级最佳 | 亿级 |
| REST API | 简洁 | 丰富 |
| 前端 SDK | InstantSearch 原生 | 需额外封装 |
| 部署运维 | 简单 | 复杂 |

## 适用场景

**Meilisearch 最佳场景**：
- 文档站搜索（如文档、博客、手册）
- 电商商品搜索（中小规模）
- 知识库 / 笔记搜索
- 前端直连搜索（需要快速上线的项目）

**Elasticsearch 更合适**：
- 日志分析（ELK 生态）
- 大规模数据（亿级以上）
- 复杂聚合分析
- 需要高可用集群
