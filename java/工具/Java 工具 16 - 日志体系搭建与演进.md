---
title: "Java 工具 16 - 日志体系搭建与演进"
date: 2026-09-01
tags: [日志, Logback, ELK, Filebeat, Kafka]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 16 - 日志体系搭建与演进

> 本文以七个阶段讲述日志处理体系从无到有的演进：从 System.out 调试、Logback 落地，到日志分级、按类隔离，再到 ELK 集中管理、Filebeat 日志代理，最终用 Kafka 缓冲搭建出可承载千万级日志的完善架构。

## 日志的作用

1. 记录系统和接口的使用情况（如请求日志）
2. 记录和分析用户行为（如网站访问日志）
3. 调试程序：控制台内容不落盘，日志可长期保存
4. 排查定位错误：异常信息记录后可事后复盘
5. 分析日志优化代码逻辑、提升系统性能与稳定性

## 第一阶段 无日志

项目初期未接入任何日志框架，调试用 `System.out.println`，异常直接打印堆栈：

```java
// 输出调试
System.out.println("value = " + value);

// 出现异常
catch (Exception e) {
    e.printStackTrace();
}
```

上线后系统出问题却查不到任何记录，只能乖乖补上日志功能。

## 第二阶段 引入日志类库 Logback

Spring Boot 默认日志库即 Logback，无需额外引入。通过 `logback.xml` 配置文件指定日志文件的存储路径和格式，Logback 会自动按天压缩日志，并在指定天数后自动删除以节约磁盘空间。

Logback 配置要点：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="60 seconds">
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>logs/application.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
      <!-- 按天滚动并压缩 -->
      <fileNamePattern>log/application-log-%d{yyyy-MM-dd}.gz</fileNamePattern>
      <maxHistory>30</maxHistory>
    </rollingPolicy>
    <encoder>
      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level ${PID:- } ...</pattern>
      <charset>UTF-8</charset>
    </encoder>
  </appender>
</configuration>
```

- `TimeBasedRollingPolicy`：基于时间的滚动策略
- `fileNamePattern`：按天生成文件并压缩为 `.gz`
- `maxHistory`：最大保留天数，自动清理旧日志

代码中使用：

```java
Logger logger = LoggerFactory.getLogger(MyApp.class);

catch (Exception e) {
    logger.error("app error", e);
}
```

日志量大了之后，排查错误靠 `cat application.log | grep 'ERROR'` 过滤，命令越来越慢，于是想到把错误日志和正常日志分开存储。

## 第三阶段 日志分级

修改 logback.xml，将 ERROR 级别日志单独输出到 error.log：

```xml
<appender name="ERROR" class="ch.qos.logback.core.rolling.RollingFileAppender">
  <file>logs/error.log</file>
  <filter class="ch.qos.logback.classic.filter.LevelFilter">
    <level>ERROR</level>
    <onMatch>ACCEPT</onMatch>
    <onMismatch>DENY</onMismatch>
  </filter>
  <encoder>
    <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level ${PID:- } [%15.15thread] %-50.50logger{50} - %msg%n</pattern>
    <charset>UTF-8</charset>
  </encoder>
</appender>
```

要点：`LevelFilter` 配合 `<level>ERROR</level>`，命中则 `ACCEPT`，不命中则 `DENY`。之后出异常只需打开 error.log，错误信息一览无遗。

## 第四阶段 按类隔离

Logback 支持将不同类产生的日志记录到不同文件。例如把所有 RequestAOP 类产生的请求日志单独记录到 request.log：

```xml
<appender name="REQUEST_HANDLER" class="ch.qos.logback.core.rolling.RollingFileAppender">
  <file>logs/request.log</file>
  <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
    ...
  </rollingPolicy>
  <encoder>
    <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} %-5level ${PID:- } [%15.15thread] %-50.50logger{50} - %msg%n</pattern>
    <charset>UTF-8</charset>
  </encoder>
</appender>

<!-- logger 中配置类名 -->
<logger name="com.yupi.RequestAOP" level="INFO" additivity="false">
  <appender-ref ref="REQUEST_HANDLER"/>
</logger>
```

要点：`logger name="类全限定名"` 指定要隔离的类，`additivity="false"` 阻止日志继续向上传递给根 logger，`appender-ref` 指向独立文件。请求日志可用于流控分析等。

但系统扩容到多台机器后，每台机器各自落盘，查日志要逐台登录服务器，量级达到几十万行，迫切需要集中查看。

## 第五阶段 日志上报与集中式管理（ELK）

ELK 是 Elasticsearch、Logstash、Kibana 的简称，不是单一软件，而是一整套解决方案：

| 组件 | 职责 |
| --- | --- |
| Elasticsearch（ES） | 全文搜索引擎，海量数据存储与高效搜索 |
| Logstash | 数据管道，从各种数据源收集数据、传输并解析转换 |
| Kibana | 数据可视化平台，展示 ES 中数据，支持自定义可视化图表 |

典型流程：Logstash 统一收集各机器数据 → 传输至 ES 存储 → Kibana 展示分析。

考虑到引入三个组件复杂度高、Logstash 较重（CPU/内存占用高），曾尝试舍弃 Logstash，在 Spring Boot 中直连 ES 写日志：

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-elasticsearch</artifactId>
  <version>2.3.4.RELEASE</version>
</dependency>
```

```java
@Repository
public interface UserRepository extends ElasticsearchRepository<HouseIndexTemplate, Long> {
}
```

结果失败：需要把项目里所有记日志代码替换为写 ES 的代码，侵入性太大；写入 ES 耗时远大于异步写文件；并发大时偶发写入失败。最终还原代码，放弃该方案。

## 第六阶段 日志代理（ElasticStack / Filebeat）

ELK 已升级为 ElasticStack，多了一个 Beats 组件。Beats 是轻量级数据采集器，针对不同数据类型提供不同组件；Filebeat 是轻量型日志采集器，用于转发和汇总日志与文件，可面对成千上万台服务器、虚拟机和容器产生的日志。

类比：日志文件 = 垃圾，Filebeat = 垃圾车，ES = 垃圾站。Filebeat 作为代理（agent）收集各机器日志，传输给 Logstash 处理或直接传输到 ES 存储，完全不用修改项目代码。

Filebeat 配置示例（采集 system 日志并传输给 Logstash）：

```yaml
filebeat.inputs:
- type: log
  paths:
    - /var/log/system.log

output.logstash:
  hosts: ["127.0.0.1:5044"]
```

只需将 Filebeat 安装到日志文件所在服务器，定义输入（采集的日志文件路径）和输出（数据发送目的地）即可。之后打开 Kibana 即可轻松查看和分析几十万、几百万条日志。

## 第七阶段 完善日志架构（引入 Kafka 缓冲）

Elasticsearch 支持水平扩容，可应对日志量级持续增大。但当每秒日志量过大时，瓶颈往往在 Logstash：它要同时接收多个 Filebeat 采集的日志，机器越多压力越大；仅靠增加 Logstash 节点不能从根本上解决问题，量级大到一定程度连 ES 集群都可能撑不住。

解决方案：接入可靠且高性能的消息队列 Kafka（依赖分布式协调工具 Zookeeper）作为缓冲。

```mermaid
flowchart LR
    A[业务系统日志文件] --> B[Filebeat 采集]
    B --> C[Logstash 处理]
    C --> D[Kafka 缓冲]
    D --> E[Elasticsearch 存储]
    E --> F[Kibana 可视化]
```

至此形成完善的分布式日志收集系统架构，千万级日志也可从容管理。

## 记录日志的 5 条经验

1. 不要过度依赖日志、什么都记，日志应当简洁明晰、具有实际价值
2. 在保证可理解的同时适当减少日志长度（如把 this is an apple 简化为 apple）
3. 日志要分级分类，仅在开发和测试环境输出 DEBUG 级别日志，不要用于生产环境
4. 统一日志格式，便于后续处理分析，通常在日志框架配置中完成
5. 不要把日志当成存储数据的工具：日志中不能出现敏感信息，也不要对外公开

> 来源：鱼皮·编程导航 / codefather
