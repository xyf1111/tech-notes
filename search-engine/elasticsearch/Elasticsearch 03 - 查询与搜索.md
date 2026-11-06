---
title: "Elasticsearch 03 - 查询与搜索"
date: 2024-01-01
tags: [Elasticsearch]
---

# Elasticsearch 03 - 查询与搜索

## 查询 DSL

DSL（Domain Specific Language）基于 JSON，分两种上下文：

- **Query Context** — 相关性评分（`_score`）
- **Filter Context** — 精确过滤（缓存、不评分）

### 全文搜索

```json
// match — 标准全文搜索
GET /products/_search
{
  "query": {
    "match": {
      "title": "苹果手机"
    }
  }
}

// match_phrase — 短语精确匹配
GET /products/_search
{
  "query": {
    "match_phrase": {
      "title": "iPhone 15"
    }
  }
}

// multi_match — 多字段搜索
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "苹果",
      "fields": ["title^2", "description", "tags"]
    }
  }
}
```

### 精确查询

```json
// term — 精确词匹配（keyword/numeric/date）
GET /products/_search
{
  "query": {
    "term": { "brand": "Apple" }
  }
}

// terms — 多值匹配
GET /products/_search
{
  "query": {
    "terms": { "tags": ["手机", "数码"] }
  }
}

// range — 范围查询
GET /products/_search
{
  "query": {
    "range": {
      "price": {
        "gte": 1000,
        "lte": 5000,
        "boost": 2.0
      }
    }
  }
}

// exists — 存在查询
GET /products/_search
{
  "query": {
    "exists": { "field": "discount" }
  }
}
```

### 复合查询

```json
// bool — 组合多个条件
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "手机" } }
      ],
      "filter": [
        { "term":  { "status": "active" } },
        { "range": { "price": { "gte": 1000, "lte": 5000 } } }
      ],
      "should": [
        { "match": { "tags": "热销" } },
        { "match": { "tags": "新品" } }
      ],
      "minimum_should_match": 1,
      "must_not": [
        { "term": { "stock": 0 } }
      ]
    }
  }
}
```

### 聚合分析

```json
// 指标聚合
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "total_revenue": {
      "sum": { "field": "amount" }
    },
    "avg_price": {
      "avg": { "field": "amount" }
    }
  }
}

// 桶聚合（分组）
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "by_status": {
      "terms": { "field": "status" },
      "aggs": {
        "revenue": {
          "sum": { "field": "amount" }
        }
      }
    }
  }
}

// 日期直方图
GET /logs/_search
{
  "size": 0,
  "aggs": {
    "requests_over_time": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "hour"
      }
    }
  }
}
```

## 排序与分页

```json
GET /products/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "price": { "order": "asc" } },
    "_score"
  ],
  "from": 0,
  "size": 20
}
```

## 高亮

```json
GET /products/_search
{
  "query": { "match": { "title": "手机" } },
  "highlight": {
    "fields": {
      "title": {
        "pre_tags": ["<em>"],
        "post_tags": ["</em>"]
      }
    }
  }
}
```

## 搜索建议（Search Suggest）

Elasticsearch 提供了搜索建议（Search Suggest）功能，能够根据用户输入的搜索查询词实时地提供搜索建议或自动完成功能，帮助用户更快速地找到感兴趣的内容。该功能通常用于搜索框下拉列表中。

### Term Suggester（完全匹配建议）

基于用户输入的查询词进行拼写纠正和完全匹配。Elasticsearch 使用编辑距离（Edit Distance）算法来识别和纠正输入中的拼写错误。

```json
POST /my_index/_search
{
  "suggest": {
    "my_suggestion": {
      "text": "搜索建议示例",
      "term": {
        "field": "suggest_field"
      }
    }
  }
}
```

### Context Suggester（上下文建议）

根据用户输入的上下文信息（如搜索历史、地理位置、用户偏好等）提供与上下文相关的搜索建议。

```json
POST /my_index/_search
{
  "suggest": {
    "my_suggestion": {
      "text": "搜索建议示例",
      "context": {
        "location": {
          "lat": 40.73,
          "lon": -74.1
        }
      },
      "completion": {
        "field": "suggest_field"
      }
    }
  }
}
```

### 综合使用

可以同时使用完全匹配建议和上下文建议，提供更加准确和有针对性的搜索建议。

```json
POST /my_index/_search
{
  "suggest": {
    "my_suggestion": {
      "text": "搜索建议示例",
      "term": {
        "field": "suggest_field"
      },
      "context": {
        "location": {
          "lat": 40.73,
          "lon": -74.1
        }
      }
    }
  }
}
```

## 搜索模板

```json
PUT _scripts/search_by_status
{
  "script": {
    "lang": "mustache",
    "source": {
      "query": {
        "bool": {
          "filter": [
            { "term": { "status": "{{status}}" } }
          ]
        }
      }
    }
  }
}

GET /orders/_search/template
{
  "id": "search_by_status",
  "params": { "status": "paid" }
}
```

## 性能建议

1. **避免大分页**：`from + size > 10000` 会报错，使用 `search_after` 或 Scroll API
2. **用 filter 代替 must**：filter 不评分、缓存
3. **keyword 字段用 term**：不要对 keyword 用 match
4. **控制返回字段**：用 `_source: ["field1", "field2"]`
5. **聚合用 `size: 0`**：不需要返回文档时设置 `size: 0`

> 来源：鱼皮·编程导航 / codefather
