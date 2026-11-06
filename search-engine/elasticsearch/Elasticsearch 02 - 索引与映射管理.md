---
title: "Elasticsearch 02 - 索引与映射管理"
date: 2024-01-01
tags: [Elasticsearch]
---

# Elasticsearch 02 - 索引与映射管理

## 索引管理

### 创建索引

```json
PUT /my_index
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1,
    "refresh_interval": "30s",
    "max_result_window": 10000
  }
}
```

### 索引别名

别名是实现**零宕机重建索引**的关键机制：

```json
# 创建别名
POST /_aliases
{
  "actions": [
    { "add": { "index": "logs-2024-01", "alias": "logs_write" } },
    { "add": { "index": "logs-2024-01", "alias": "logs_read" } }
  ]
}

# 重建索引并切换
POST /_aliases
{
  "actions": [
    { "remove": { "index": "logs-2024-01", "alias": "logs_write" } },
    { "add":    { "index": "logs-2024-02", "alias": "logs_write" } }
  ]
}
```

### 滚动索引（Rollover）

```json
PUT /logs-000001
{
  "aliases": { "logs_write": {} }
}

POST /logs_write/_rollover
{
  "conditions": {
    "max_age": "7d",
    "max_docs": 1000000,
    "max_size": "50gb"
  }
}
```

## 映射（Mapping）

### 数据类型

```json
PUT /products
{
  "mappings": {
    "properties": {
      "title":   { "type": "text" },
      "content": { "type": "text", "analyzer": "english" },
      "price":   { "type": "double" },
      "stock":   { "type": "integer" },
      "is_active": { "type": "boolean" },
      "created_at": { "type": "date", "format": "yyyy-MM-dd HH:mm:ss||epoch_millis" },
      "tags":    { "type": "keyword" },
      "location": { "type": "geo_point" },
      "metadata": { "type": "object" },
      "attachments": {
        "type": "nested",
        "properties": {
          "name": { "type": "keyword" },
          "size": { "type": "long" }
        }
      }
    }
  }
}
```

### 动态映射

ES 默认自动推断字段类型：

```
"15"        → long
"15.0"      → float
"true"      → boolean
"2024-01-15" → date
"hello"     → text + keyword
```

关闭或限制动态映射：

```json
PUT /my_index
{
  "mappings": {
    "dynamic": "strict",    // 未知字段拒绝写入
    "properties": { ... }
  }
}

// 或 "dynamic": false  // 未知字段不索引但存储
```

### reindex（重建映射）

Mapping 不能直接修改（除新增字段），需要 reindex：

```json
POST /_reindex
{
  "source": { "index": "old_index" },
  "dest":   { "index": "new_index" }
}
```

## 分词器（Analyzer）

### 内置分词器

| 名称 | 行为 | 例子: "I'm eating apples" |
|------|------|--------------------------|
| standard（默认） | 按标点分词、小写 | [i'm, eating, apples] |
| simple | 按非字母分词 | [i, m, eating, apples] |
| whitespace | 按空格分词 | [I'm, eating, apples] |
| keyword | 不分词 | [I'm eating apples] |
| stop | 去除停用词 | [eating, apples] |
| english | 词干提取 | [eat, appl] |

### 中文分词

需要安装 IK 分词插件：

**方式一（命令行安装）：**

```bash
elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/...
```

**方式二（手动安装，Windows 适用）：**

下载 `elasticsearch-analysis-ik-{version}.zip`，解压后放入 ES 安装目录的 `plugins/` 下，重启 ES 即可。

**版本兼容：** 如报错提示分词器版本不兼容，编辑分词器目录下的 `plugin-descriptor.properties`，将 `elasticsearch.version` 改为当前 ES 版本。

```json
// ik_smart — 粗粒度（推荐搜索用）
// ik_max_word — 最细粒度（推荐索引用）

PUT /articles
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "ik_max_word",
        "search_analyzer": "ik_smart"
      }
    }
  }
}

// 测试分词
POST /articles/_analyze
{
  "text": "中华人民共和国",
  "analyzer": "ik_max_word"
}
// 结果: 中华人民共和国, 中华人民, 中华, 华人, 人民共和国, 人民, 共和国
```

## 文档 CRUD

### 新增文档

```json
# 指定 ID
POST /products/_doc/1
{
  "title": "iPhone 15",
  "price": 7999,
  "stock": 100
}

# 不指定 ID（自动生成随机 ID）
POST /products/_doc
{
  "title": "MacBook Pro",
  "price": 14999
}
```

> 字段类型声明为 `float` 但仍可插入数组——ES 没有数组类型，允许一个字段接受多个值。

### 查询文档

```json
GET /products/_doc/1
```

### 删除文档

```json
DELETE /products/_doc/1
```

### 修改文档

**全量修改：** 覆盖原文档（本质是删除 + 新增）

```json
PUT /products/_doc/1
{
  "title": "iPhone 15 Pro",
  "price": 8999,
  "stock": 50
}
```

> 如果指定 ID 不存在，则从修改变为新增操作。

**增量修改：** 只更新部分字段

```json
POST /products/_update/1
{
  "doc": {
    "price": 7999
  }
}
```

## Java 客户端使用

### 引入依赖

```xml
<dependency>
    <groupId>org.elasticsearch.client</groupId>
    <artifactId>elasticsearch-rest-high-level-client</artifactId>
</dependency>
```

注意覆盖 Spring Boot 管理的 ES 版本：

```xml
<properties>
    <elasticsearch.version>7.12.1</elasticsearch.version>
</properties>
```

### 初始化客户端

```java
RestHighLevelClient client = new RestHighLevelClient(
    RestClient.builder(HttpHost.create("http://localhost:9200"))
);
```

> 来源：鱼皮·编程导航 / codefather
