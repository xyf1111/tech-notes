---
title: "DevOps 02 - 企业微信群机器人定时提醒"
date: 2026-08-06
tags: [DevOps, 企业微信, 机器人, 定时任务, Spring Boot]
source: "鱼皮·编程导航 / codefather"
---

# DevOps 02 - 企业微信群机器人定时提醒

> 一句话摘要：开发一个企微群机器人 SDK，配合 Spring Boot 定时任务，每天自动在群里提醒轮值员工去接水，把「接水提醒员」从人变成程序。

## 背景

公司每天需轮流安排一名员工去饮水机接水，但大家忙于工作经常忘记。人工轮流提醒不可行（自己都不记得哪天轮到自己），企业微信日历排日程又因人数与天数不完全对应而很麻烦，调研的排班打卡系统还都要收费——最终方案：在企业微信群接入官方群机器人，每天定时提醒当天值班员工。该功能与员工排班打卡系统本质类似但更轻量；「群聊定时提醒」是通用能力，因此沉淀为企微机器人 SDK，供公司其他业务复用（如定时喝水提醒）。

## 企微群机器人基础

官方文档：<https://developer.work.weixin.qq.com/document/path/99110>

- 在企业微信**群聊中添加机器人**后，即可获取机器人的 **webhook**（一个 URL 地址），用于接收开发者服务器的 HTTP 请求、驱动群机器人发消息，后续所有开发都依赖它；webhook 形如 `https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx`，其中 **key 参数即机器人标识**，需保存好，切勿泄露
- 机器人支持多种消息类型：文本、Markdown、图片、图文、文件、语音、模板卡片等；每种消息最终都转换成 **JSON 格式**，通过 **HTTP POST 请求**发送到 webhook，官方文档对每种类型的请求参数和字段含义都有详尽说明

## SDK 设计（核心）

设计要点：把「企微机器人发消息」做成可复用的 SDK，而非一次性代码。

- **基础消息类 `Message`**：存放公共参数（如 `msgtype` 消息类型字段）；**具体消息类继承基类**，如 `TextMessage`、`MarkdownMessage`，各自持有对应类型的业务字段
- **统一发送器 `MessageSender`**：提供 `sendText` 等发送方法，接收 `Message` 对象，统一走底层 `send()` 方法 POST JSON 到 webhook；客户端只面向发送器调用，无需关心序列化与 HTTP 细节
- **更通用的扩展**：可将 `MessageSender` 定义为接口，编写不同子类实现多平台发送，如飞书 `MessageSender`、短信 `MessageSender` 等

SDK 结构图（文字描述）：

```
Message（基类：msgtype）
 ├── TextMessage / MarkdownMessage（子类，持各自业务字段）
MessageSender（如 RtxRobotMessageSender）
 └── send(Message)：JSON 序列化 → HTTP POST → webhook 发消息
```

## 开发步骤

1. 获取 webhook → 2. 创建 SDK 项目 → 3. 编写代码（配置类 → 消息类 → 消息发送类）→ 4. SDK 打包 → 5. 调用 SDK

### 1、获取 webhook

在企业微信群聊中创建群机器人，复制其 webhook 地址（含 key 参数，即机器人标识），保存好并注意保密。后续所有请求都通过该 webhook 控制机器人。

### 2、创建 SDK 项目

使用 Maven 构建干净的空项目。SDK 会被更多开发者使用，`groupId`/`artifactId`/`version` 需遵循规范：groupId 对应 main 目录下的 Java 目录结构；artifactId 为项目名，纯小写、多词用中划线分隔；`SNAPSHOT` 表示开发中的不稳定版本。本项目配置为 `com.yupi:rtx-robot:1.0-SNAPSHOT`。

为了让开发者通过配置文件传参（如 webhook）而非硬编码，把 SDK 做成 **Spring Boot starter**，引入依赖：

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-autoconfigure</artifactId>
</dependency>
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-configuration-processor</artifactId>
  <optional>true</optional>
</dependency>
```

并在 `build` 中配置 spring-boot-maven-plugin 的 `<skip>true</skip>`，跳过默认打包行为（SDK 不作为可执行 jar）。

### 3、编写配置类

配置类接收配置文件中写入的 webhook，并把 `MessageSender` 注册为 Bean 自动注入 IOC 容器，开发者无需自己 new 对象：

```java
@Configuration
@ConfigurationProperties(prefix = "wechatwork-bot")
@ComponentScan
@Data
public class WebhookConfig {
    private String webhook;
    @Bean
    public RtxRobotMessageSender rtxRobotMessageSender() {
        return new RtxRobotMessageSender(webhook);
    }
}
```

写入 `resources/META-INF/spring.factories`，让 Spring Boot 启动时自动识别该配置类：

```sh
org.springframework.boot.autoconfigure.EnableAutoConfiguration=com.yupi.rtxrobot.config.WebhookConfig
```

### 4、编写消息类

按官方文档的请求参数编写消息对象。每个消息类都有固定字段 `msgtype`，故定义基类 `Message`，便于将不同类型消息传入统一方法：

```java
public class Message {
    String msgtype; // 消息类型
}
```

文本消息 `TextMessage`：

```java
@Data
public class TextMessage extends Message {
    private String content;                   // 消息内容
    private List<String> mentionedList;       // 被提及者 userId 列表
    private List<String> mentionedMobileList; // 被提及者手机号列表
    private Boolean mentionAll = false;       // 提及全体（自动转为 "@all"）
    public TextMessage(String content, List<String> mentionedList, List<String> mentionedMobileList, Boolean mentionAll) {
        this.content = content;
        this.mentionedList = mentionedList;
        this.mentionedMobileList = mentionedMobileList;
        this.mentionAll = mentionAll;
        if (mentionAll) { // 自动向 mentionedList 追加 "@all"
            if (CollUtil.isNotEmpty(mentionedList)) {
                this.mentionedList.add("@all");
            } else {
                this.mentionedList = CollUtil.newArrayList("@all");
            }
        }
    }
    public TextMessage(String content) {
        this(content, null, null, false);
    }
}
```

> 优化细节：官方文档用 `"@all"` 字符串表示 @全体成员，属于魔法值；这里封装为布尔字段 `mentionAll`，构造时自动转换为实际请求需要的字段，简化调用。

### 5、编写消息发送类

发送类定义各种类型消息的发送方法，全部依赖底层 `send()` 方法——向 webhook 发送 HTTP POST 请求来驱动机器人：

```java
@Slf4j
public class RtxRobotMessageSender {
    private final String webhook;
    public WebhookConfig webhookConfig;

    public RtxRobotMessageSender(String webhook) {
        this.webhook = webhook;
    }
    public void sendMessage(Message message) throws Exception {
        if (message instanceof TextMessage) send((TextMessage) message);
        else if (message instanceof MarkdownMessage) send((MarkdownMessage) message);
        else throw new RuntimeException("Unsupported message type");
    }
    public void sendText(String content) throws Exception {
        sendText(content, null, null, false);
    }
    public void sendText(String content, List<String> mentionedList, List<String> mentionedMobileList) throws Exception {
        send(new TextMessage(content, mentionedList, mentionedMobileList, false));
    }
    private void send(Message message) throws Exception {
        String webhook = this.webhook;
        if (StrUtil.isBlank(webhook)) { // 未传入时降级从配置类获取（失败则检查 application.yml 与 spring 环境）
            webhook = webhookConfig.getWebhook();
        }
        String json = JSONUtil.toJsonStr(message);
        OkHttpClient client = new OkHttpClient();
        RequestBody body = RequestBody.create(MediaType.get("application/json; charset=utf-8"), json);
        Request request = new Request.Builder().url(webhook).post(body).build();
        try (Response response = client.newCall(request).execute()) {
            if (response.isSuccessful()) {
                log.info("消息发送成功");
            } else {
                log.error("消息发送失败，响应码：{}", response.code());
                throw new Exception("消息发送失败，响应码：" + response.code());
            }
        } catch (IOException e) {
            log.error("发送消息时发生错误:" + e);
            throw new Exception("发送消息时发生错误", e);
        }
    }
}
```

### 6、SDK 打包

通过 Maven `install` 命令打包，jar 包会导入本地仓库（打包前建议先执行 `clean` 清理垃圾文件），之后可本地使用或上传远程仓库。

### 7、调用 SDK

将 SDK 作为依赖引入业务项目（如接水提醒应用），并把 webhook 写入配置文件：

```xml
<dependency>
  <groupId>com.yupi</groupId>
  <artifactId>rtx-robot</artifactId>
  <version>1.0-SNAPSHOT</version>
</dependency>
```

```yaml
wechatwork-bot:
  webhook: 你的webhook地址
```

Spring 环境中通过依赖注入获取发送器；非 Spring 环境也可手动创建：

```java
@Resource
public RtxRobotMessageSender rtxRobotMessageSender;
RtxRobotMessageSender sender = new RtxRobotMessageSender("你的webhook地址");
```

## 定时提醒实现

用最简单的方式实现轮值排班：定义员工数组，按「星期几」对应到具体员工，再用定时任务每日触发发送：

```java
@Component
public class WaterReminderTask {
    @Resource
    public RtxRobotMessageSender rtxRobotMessageSender;
    private String[] names = {"员工a", "员工b", "员工c", "员工d", "员工e"};

    @Scheduled(cron = "0 55 9 * * MON-FRI")
    public void remindToGetWater() {
        DayOfWeek dayOfWeek = LocalDate.now().getDayOfWeek();
        String nameToRemind;
        switch (dayOfWeek) {
            case MONDAY:    nameToRemind = names[0]; break;
            case TUESDAY:   nameToRemind = names[1]; break;
            case WEDNESDAY: nameToRemind = names[2]; break;
            case THURSDAY:  nameToRemind = names[3]; break;
            case FRIDAY:    nameToRemind = names[4]; break;
            default: return;
        }
        String message = "提醒：" + nameToRemind + "，是你接水的时间了！";
        rtxRobotMessageSender.sendText(message);
    }
}
```

要点：

- **轮值排班**：用 `LocalDate.now().getDayOfWeek()` 计算当天星期，switch 映射到值班员工；人数多于工作日的场景可扩展为按日期/人数取模计算
- **定时调度**：使用 Spring Boot `@Scheduled(cron = "0 55 9 * * MON-FRI")`，每个工作日 9:55 自动触发；复杂调度可换用 Quartz
- **异常处理**：`send()` 在响应码非成功或网络异常时记录日志并抛出异常，可在调用处捕获后实现发送失败重试（如重试 N 次或转人工告警），避免漏提醒

## 实际运行效果

每天工作日 9:55，机器人自动在企业微信群里发送文本消息，内容形如：

> 提醒：员工a，是你接水的时间了！

> 来源：鱼皮·编程导航 / codefather
