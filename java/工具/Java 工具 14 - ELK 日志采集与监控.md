---
title: "Java 工具 14 - ELK 日志采集与监控"
date: 2026-07-24
tags:
  - java
  - spring-boot
  - elk
  - elasticsearch
  - logstash
  - kibana
  - 日志
  - 监控
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 14 - ELK 日志采集与监控

> SpringBoot 项目通过 Logback + Logstash 将日志采集到 Elasticsearch，并用 Kibana 可视化。

## 应用场景

- **Web 应用日志监控**：收集应用日志，通过 Kibana 展示和搜索
- **系统性能监控**：采集 CPU、内存、网络流量等指标
- **错误信息监控**：收集 Exception、HTTP 请求等错误信息，快速定位问题

## 环境搭建

### Docker 部署（推荐）

```bash
# 拉取镜像（版本号必须统一）
docker pull elasticsearch:7.6.0
docker pull logstash:7.6.0
docker pull kibana:7.6.0

# 启动 Elasticsearch
docker run -id \
  -p 9200:9200 \
  --name=elasticsearch \
  -v /etc/localtime:/etc/localtime \
  -e "discovery.type=single-node" \
  elasticsearch:7.6.0

# 启动 Kibana
docker run -id \
  -p 5601:5601 \
  --name=kibana \
  -v /etc/localtime:/etc/localtime \
  kibana:7.6.0

# 启动 Logstash
docker run -id \
  -p 9600:9600 \
  -p 9061:9061 \
  --name=logstash \
  -v /etc/localtime:/etc/localtime \
  logstash:7.6.0
```

### 配置 ELK

**Elasticsearch** — `config/elasticsearch.yml`:

```yaml
ingest.geoip.downloader.enabled: false
xpack.security.transport.ssl.enabled: true
xpack.security.enabled: true
xpack.license.self_generated.type: basic
```

启动后设置密码：`elasticsearch-setup-passwords interactive`

**Kibana** — `config/kibana.yml`:

```yaml
elasticsearch.username: "elastic"
elasticsearch.password: "your-password"
```

**Logstash** — `config/logstash-meter.conf`:

```
input {
  tcp {
    mode => "server"
    host => "0.0.0.0"
    port => 9061
    codec => json_lines
  }
}
filter {
  ruby {
    code => "event.set('timestamp', event.get('@timestamp').time.localtime + 8*60*60)"
  }
  ruby {
    code => "event.set('@timestamp',event.get('timestamp'))"
  }
  mutate {
    remove_field => ["timestamp","@version","host","port"]
  }
}
output {
  elasticsearch {
    hosts => ["ipaddress:9200"]
    index => "logstash-meter-%{+YYYY.MM.dd}"
    user => "elastic"
    password => "your-password"
    template_name => "logstash-meter-template"
  }
  stdout { codec => rubydebug }
}
```

## SpringBoot 配置

### Maven 依赖

```xml
<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>${logstash-logback-encoder.version}</version>
</dependency>
```

### Logback 配置

在 `src/main/resources/logback.xml` 中添加 Logstash Appender：

```xml
<appender name="logstash" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
    <destination>127.0.0.1:9061</destination>
    <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
        <providers>
            <timestamp><timeZone>UTC</timeZone></timestamp>
            <pattern>
                <pattern>
                    {
                    "ip":"%ip",
                    "serverName":"${serverName}",
                    "thread": "%thread",
                    "level": "%-5level",
                    "logger": "%logger{36}",
                    "message": "%msg"
                    }
                </pattern>
            </pattern>
        </providers>
    </encoder>
</appender>

<root level="INFO">
    <appender-ref ref="logstash" />
</root>
```

## Kibana 可视化

### 创建索引模板

```json
PUT /_template/logstash-meter-template
{
  "index_patterns": ["logstash-meter-*"],
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  },
  "mappings": {
    "properties": {
      "message": {
        "type": "text",
        "analyzer": "ik_max_word",
        "search_analyzer": "ik_smart",
        "fields": { "keyword": { "type": "keyword" } }
      },
      "ip": { "type": "keyword" },
      "serverName": { "type": "keyword" },
      "thread": { "type": "keyword" },
      "level": { "type": "keyword" },
      "logger": { "type": "keyword" }
    }
  }
}
```

### 搜索测试

```json
GET /logstash-meter-*/_doc/_search
{
  "query": {
    "match": { "message": { "query": "xxx" } }
  }
}
```

### 使用步骤

1. 在 Kibana 中创建 Index Pattern，名称设为 `logstash-meter-*`
2. 启动 SpringBoot 项目 + Logstash
3. 在 Kibana → Discover 中查看日志，可按字段过滤和搜索

> 来源：鱼皮·编程导航 / codefather
