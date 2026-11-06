---
title: "RabbitMQ 10 - Spring Boot 集成配置"
date: 2026-07-24
tags: [RabbitMQ, SpringBoot, 消息队列, 中间件]
source: "鱼皮·编程导航 / codefather"
---

# RabbitMQ 10 - Spring Boot 集成配置

> 快速为 Spring Boot 项目引入 RabbitMQ，包含生产者/消费者配置、消息可靠性保障、JSON 消息转换器及错误处理。

## 配置概览

```yaml
spring:
  rabbitmq:
    # 连接信息
    host: xxx
    port: 5672
    virtual-host: /myapp
    username: xxx
    password: xxx
    connection-timeout: 200ms

    # 生产者确认机制（默认关闭，开启会有性能损耗）
    publisher-confirm-type: none     # none / correlated / simple
    publisher-returns: false
    template:
      retry:
        enabled: true                # 生产者重连
        initial-interval: 1000ms
        multiplier: 1
        max-attempts: 3

    # 消费者配置
    listener:
      simple:
        prefetch: 1                  # 能者多劳：每次只取一条
        acknowledge-mode: auto       # 自动确认（auto / manual / none）
        retry:
          enabled: true              # 消费失败重试策略
```

## JSON 消息转换器

替换默认的 JDK 序列化方式，使用 Jackson 进行 JSON 序列化/反序列化：

```java
@Bean
public MessageConverter messageConverter() {
    return new Jackson2JsonMessageConverter();
}
```

## 声明队列与交换机

### 方式一：@Configuration 手动声明

```java
@Configuration
public class MQConfiguration {

    @Bean
    public Queue bizQueue() {
        return QueueBuilder.durable("biz.queue")
            .lazy()                    // Lazy Queue：消息尽快落盘
            .build();
    }

    @Bean
    public DirectExchange bizExchange() {
        return ExchangeBuilder.directExchange("biz.exchange").build();
    }

    @Bean
    public Binding bizBinding() {
        return BindingBuilder.bind(bizQueue())
            .to(bizExchange())
            .with("biz.routing.key");
    }
}
```

### 方式二：@RabbitListener 声明式绑定（推荐）

```java
@RabbitListener(bindings = @QueueBinding(
    value = @Queue(
        name = "biz.queue",
        durable = "true",
        arguments = @Argument(name = "x-queue-mode", value = "lazy")
    ),
    exchange = @Exchange(name = "biz.exchange", type = ExchangeTypes.DIRECT),
    key = "biz.routing.key"
))
public void receiveMessage(String msg) {
    // 处理消息
}
```

## 错误消息处理策略

消费重试耗尽后，将失败消息投递到专门的错误交换机：

```java
@Bean
public MessageRecoverer messageRecoverer(RabbitTemplate rabbitTemplate) {
    return new RepublishMessageRecoverer(
        rabbitTemplate,
        "biz.error.exchange",    // 错误交换机
        "biz.error.routing.key"  // 错误路由键
    );
}
```

配套声明错误队列：

```java
@Configuration
public class ErrorConfiguration {

    @Bean
    public Queue errorQueue() {
        return QueueBuilder.durable("biz.error.queue").build();
    }

    @Bean
    public DirectExchange errorExchange() {
        return ExchangeBuilder.directExchange("biz.error.exchange").build();
    }

    @Bean
    public Binding errorBinding() {
        return BindingBuilder.bind(errorQueue())
            .to(errorExchange())
            .with("biz.error.routing.key");
    }
}
```

## 业务幂等性

在消费者中基于乐观锁做幂等判断，避免重复消费：

```java
@RabbitListener(bindings = @QueueBinding(
    value = @Queue(name = "bi.queue", durable = "true",
        arguments = @Argument(name = "x-queue-mode", value = "lazy")),
    exchange = @Exchange(name = "bi.exchange", type = ExchangeTypes.DIRECT),
    key = "bi.routing.key"
))
public void receiveMessage(Long chatId) {
    // 乐观锁：仅当状态为 WAIT 时更新为 RUNNING
    boolean updated = chartService.lambdaUpdate()
            .set(Chart::getStatus, RUNNING_STATUS)
            .eq(Chart::getId, chatId)
            .eq(Chart::getStatus, WAIT_STATUS)
            .update();
    if (!updated) {
        // 已处理或正在处理，跳过
        return;
    }
    // 执行耗时业务...
}
```

## 关键约定

| 配置项 | 说明 | 推荐值 |
|--------|------|--------|
| `publisher-confirm-type` | 生产者确认，correlated 模式可回调确认结果 | correlated（重要消息）|
| `prefetch` | 消费者预取数量，1 表示能者多劳 | 1 |
| `acknowledge-mode` | auto：异常时自动重试 / manual：手动 ack | auto |
| `x-queue-mode` | lazy 模式将消息尽快写入磁盘，降低内存压力 | lazy |

> 来源：鱼皮·编程导航 / codefather
