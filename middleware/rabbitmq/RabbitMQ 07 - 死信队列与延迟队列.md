---
title: "RabbitMQ 07 - 死信队列与延迟队列"
date: 2024-01-01
tags: [RabbitMQ]
---

# RabbitMQ 07 - 死信队列与延迟队列

## 死信队列（Dead Letter Queue）

### 什么是死信

消息在队列中满足以下任一条件时，会变成"死信"（Dead Letter）：

1. **消息被拒绝** — 消费者使用 `basic.reject` 或 `basic.nack`，且 `requeue=false`
2. **消息过期** — 消息的 TTL 到期
3. **队列达到最大长度** — 队列中消息数量超过 `x-max-length` 或总大小超过 `x-max-length-bytes`

### 死信机制

通过为队列设置死信交换器（DLX），死信会被自动转发到指定 Exchange：

```go
args := amqp.Table{
    "x-dead-letter-exchange":    "dlx.exchange",
    "x-dead-letter-routing-key": "dlx.routing.key",
}
q, err := ch.QueueDeclare("main.queue", true, false, false, false, args)
```

死信发出后会携带原始消息的 headers，包括：
- `x-first-death-reason` — 死信原因（rejected/expired/maxlen）
- `x-first-death-exchange` — 原始交换器
- `x-first-death-queue` — 原始队列

### 完整示例

```go
package main

import (
    "log"
    "time"
    amqp "github.com/rabbitmq/amqp091-go"
)

func main() {
    conn, _ := amqp.Dial("amqp://guest:guest@localhost:5672/")
    defer conn.Close()
    ch, _ := conn.Channel()
    defer ch.Close()

    // 声明死信交换器
    ch.ExchangeDeclare("dlx.exchange", "direct", true, false, false, false, nil)
    dlq, _ := ch.QueueDeclare("dlx.queue", true, false, false, false, nil)
    ch.QueueBind(dlq.Name, "dlx.key", "dlx.exchange", false, nil)

    // 声明主队列，绑定死信
    args := amqp.Table{
        "x-dead-letter-exchange":    "dlx.exchange",
        "x-dead-letter-routing-key": "dlx.key",
        "x-message-ttl":             10000, // 10秒未消费变成死信
    }
    q, _ := ch.QueueDeclare("main.queue", true, false, false, false, args)

    // 消费死信队列
    msgs, _ := ch.Consume(dlq.Name, "", true, false, false, false, nil)
    go func() {
        for d := range msgs {
            log.Printf("死信收到: %s (原路由: %s)", d.Body, d.RoutingKey)
        }
    }()

    // 发一条消息
    ch.Publish("", q.Name, false, false, amqp.Publishing{
        ContentType: "text/plain",
        Body:        []byte("这条消息将在10秒后变成死信"),
    })
    log.Println("消息已发送")

    time.Sleep(15 * time.Second)
}
```

## 延迟队列（Delayed Queue）

### 通过 TTL + DLX 实现

利用消息 TTL 到期后进入死信队列的机制，模拟延迟队列：

```
生产者 → 无消费者队列（TTL=30s）→ DLX → 实际消费队列 → 消费者
```

```go
// 延迟交换机
ch.ExchangeDeclare("delay.exchange", "direct", true, false, false, false, nil)
delayArgs := amqp.Table{
    "x-dead-letter-exchange":    "process.exchange",
    "x-dead-letter-routing-key": "process.key",
}
delayQ, _ := ch.QueueDeclare("delay.queue", true, false, false, false, delayArgs)
ch.QueueBind(delayQ.Name, "delay.key", "delay.exchange", false, nil)

// 实际处理队列
ch.ExchangeDeclare("process.exchange", "direct", true, false, false, false, nil)
processQ, _ := ch.QueueDeclare("process.queue", true, false, false, false, nil)
ch.QueueBind(processQ.Name, "process.key", "process.exchange", false, nil)
```

### 通过延迟消息插件

RabbitMQ 官方插件 `rabbitmq_delayed_message_exchange` 提供原生支持：

```bash
# 启用插件
rabbitmq-plugins enable rabbitmq_delayed_message_exchange
```

```go
import amqp "github.com/rabbitmq/amqp091-go"

// 声明延迟交换机（类型为 x-delayed-message）
args := amqp.Table{"x-delayed-type": "direct"}
ch.ExchangeDeclare("delayed.exchange", "x-delayed-message", true, false, false, false, args)

// 发送延迟消息
ch.Publish("delayed.exchange", "order.created", false, false, amqp.Publishing{
    ContentType: "text/plain",
    Headers:     amqp.Table{"x-delay": "30000"}, // 30秒延迟
    Body:        []byte("订单已创建，30秒后处理"),
})
```

> **注意**：`x-delay` 单位为毫秒。插件方式的延迟比 TTL+DLX 更精确，且不需要额外队列。

## 延迟队列的应用场景

| 场景 | 延迟时间 | 说明 |
|------|---------|------|
| 订单超时取消 | 30min | 下单后30分钟未支付自动取消 |
| 重试机制 | 递增 | 失败任务按指数退避重试（5s→25s→125s） |
| 定时通知 | 定时 | 预约提醒、活动开始前通知 |
| 数据同步 | 延迟 | 延迟写入，允许数据聚合/去重 |

## Spring Boot 配置示例（Java）

除了 Go，RabbitMQ 死信队列在 Java/Spring Boot 项目中同样常用。以下是在 Spring Boot 项目中声明死信队列的配置类。

### 交换机、队列和 RoutingKey 配置

```java
@Configuration
public class TtlQueueConfig {
    private final String COMMON_EXCHANGE = "bi_common_exchange";
    private final String COMMON_QUEUE = "bi_common_queue";
    private final String DEAD_LETTER_EXCHANGE = "bi_dead_letter_exchange";
    private final String DEAD_LETTER_QUEUE = "bi_dead_letter_queue";
    private final String COMMON_ROUTINGKEY = "bi_common_routingKey";
    private final String DEAD_LETTER_ROUTINGKEY = "bi_dead_letter_routingKey";

    @Bean("commonExchange")
    public DirectExchange commonExchange() {
        return new DirectExchange(COMMON_EXCHANGE);
    }

    @Bean("deadLetterExchange")
    public DirectExchange deadLetterExchange() {
        return new DirectExchange(DEAD_LETTER_EXCHANGE);
    }

    @Bean("commonQueue")
    public Queue commonQueue() {
        Map<String, Object> map = new HashMap<>(3);
        map.put("x-message-ttl", 20000);
        map.put("x-dead-letter-exchange", DEAD_LETTER_EXCHANGE);
        map.put("x-dead-letter-routing-key", DEAD_LETTER_ROUTINGKEY);
        return QueueBuilder.durable(COMMON_QUEUE).withArguments(map).build();
    }

    @Bean("deadLetterQueue")
    public Queue deadLetterQueue() {
        return QueueBuilder.durable(DEAD_LETTER_QUEUE).build();
    }

    @Bean
    public Binding commonQueueBindingCommonExchange(
            @Qualifier("commonQueue") Queue commonQueue,
            @Qualifier("commonExchange") DirectExchange commonExchange) {
        return BindingBuilder.bind(commonQueue).to(commonExchange).with(COMMON_ROUTINGKEY);
    }

    @Bean
    public Binding deadQueueBindingDeadExchange(
            @Qualifier("deadLetterQueue") Queue deadLetterQueue,
            @Qualifier("deadLetterExchange") DirectExchange deadLetterExchange) {
        return BindingBuilder.bind(deadLetterQueue).to(deadLetterExchange).with(DEAD_LETTER_ROUTINGKEY);
    }
}
```

### 普通消费者（异步处理 + 拒绝后投递到死信队列）

```java
@Component
@Slf4j
public class BIMessageConsumer {
    @Resource
    private ChartService chartService;

    @SneakyThrows
    @RabbitListener(queues = {"bi_common_queue"}, ackMode = "MANUAL")
    public void receiveMessage(String message, Channel channel,
                               @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) {
        if (StringUtils.isBlank(message)) {
            channel.basicNack(deliveryTag, false, false);
            log.info("消息为空拒绝接收，转发到死信队列");
            return;
        }
        // ... 业务处理失败时 channel.basicNack(deliveryTag, false, false);

        // 处理成功后手动确认
        channel.basicAck(deliveryTag, false);
    }
}
```

### 死信队列消费者

```java
@Component
@Slf4j
public class DeadLetterConsumer {
    @Resource
    private BIMessageProducer biMessageProducer;

    @SneakyThrows
    @RabbitListener(queues = "bi_dead_letter_queue", ackMode = "MANUAL")
    public void consumeDeadLetter(String message, Channel channel,
                                  @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag) {
        log.info("收到死信消息：{}", message);
        biMessageProducer.sendMessage(message); // 重试或转存
        channel.basicAck(deliveryTag, false);
    }
}
```

## 注意事项

1. **死信循环**：避免死信队列未消费，消息又被转发回原队列 — 检查 `x-dead-letter-exchange` 配置是否正确
2. **TTL 精度**：队列级 x-message-ttl 对所有消息生效；消息级 `expiration` 属性更灵活
3. **延迟插件**：生产环境推荐用插件方式，单节点支持数万延迟消息；集群需要所有节点安装插件
4. **消息顺序**：TTL+DLX 不保证延迟队列的消息顺序 — 不同队列的 TTL 到期时间不同
