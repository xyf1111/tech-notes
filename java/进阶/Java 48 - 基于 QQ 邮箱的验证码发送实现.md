---
title: "Java 进阶 - 基于 QQ 邮箱的验证码发送实现"
date: 2026-08-18
tags: [Java, SpringBoot, 邮件, 验证码, Redis]
source: "鱼皮·编程导航 / codefather"
---

# Java 进阶 - 基于 QQ 邮箱的验证码发送实现

> 登录注册等敏感操作常需要验证码校验，短信验证码需付费，不适合个人项目学习。本方案改用 QQ 邮箱 SMTP 发送邮件验证码，配合 Redis 做一分钟限流，成本为零，且步骤与其他邮箱平台基本一致。

## 需求分析

- **场景**：用户输入邮箱 → 点击获取验证码 → 后台发送一封含验证码的邮件到该邮箱。
- **防刷方案**：限制一分钟内只能获取一次。
  - 前端：倒计时期间禁用「获取验证码」按钮。
  - 后端：验证码存入 Redis 并设置过期时间；请求先查 Redis，已有验证码则直接拒绝。

## 开启 QQ 邮箱 SMTP

1. 网页版 QQ 邮箱 → 设置 → 账户。
2. 下滑找到「POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV 服务」开关，开启 SMTP 服务。
3. 按提示完成安全验证后，会生成一串**授权码**。后端程序用它代替邮箱密码登录 SMTP 服务器，务必保存（只显示一次）。

## SpringBoot 集成

### pom 依赖

```xml
<!-- 邮件发送 -->
<dependency>
    <groupId>javax.mail</groupId>
    <artifactId>mail</artifactId>
    <version>1.4.7</version>
</dependency>
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-email</artifactId>
    <version>1.4</version>
</dependency>
<dependency>
    <groupId>javax.activation</groupId>
    <artifactId>activation</artifactId>
    <version>1.1.1</version>
</dependency>

<!-- Redis 缓存验证码 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

### application.yml

```yaml
spring:
  redis:
    # 使用索引为 3 的库，避免与其他业务数据冲突
    database: 3
    host: localhost
    port: 6379
    # 若 Redis 设置了密码，需加上 password: xxx
```

## 发送验证码工具类

基于 commons-email 的 SimpleEmail 封装：

```java
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;

public class SendMailUtil {

    /**
     * 发送验证码邮件
     * @param targetEmail 目标用户邮箱
     * @param authCode    验证码
     */
    public static void sendEmailCode(String targetEmail, String authCode) {
        try {
            SimpleEmail mail = new SimpleEmail();
            mail.setHostName("smtp.qq.com");                    // SMTP 服务器
            mail.setAuthentication("你的邮箱@qq.com", "授权码");  // 邮箱 + 授权码
            mail.setFrom("你的邮箱@qq.com", "发送昵称");
            mail.setSSLOnConnect(true);                         // 启用 SSL
            mail.addTo(targetEmail);                            // 收件人
            mail.setSubject("注册验证码");                        // 主题
            mail.setMsg("您的验证码为:" + authCode + "(一分钟内有效)"); // 内容
            mail.send();
        } catch (EmailException e) {
            e.printStackTrace();
        }
    }
}
```

## 接口与 Redis 限流

Controller 中先查 Redis：验证码不存在才发送邮件并写入缓存（有效期 1 分钟），存在则直接拒绝：

```java
@RestController
public class SendMailController {

    @Resource
    private RedisTemplate<String, String> redisTemplate;

    @GetMapping("/getCode")
    public String mail(@RequestParam("targetEmail") String targetEmail) {
        // 发送前先查缓存，防止刷爆邮箱
        String yzm = redisTemplate.opsForValue().get("yzm");
        if (yzm == null) {
            // 生成 6 位随机验证码
            String authCode = String.valueOf(new Random().nextInt(899999) + 100000);
            SendMailUtil.sendEmailCode(targetEmail, authCode);
            // 存入 Redis，1 分钟后过期
            redisTemplate.opsForValue().set("yzm", authCode, 1, TimeUnit.MINUTES);
            return "发送成功";
        }
        return "请勿重复发送验证码";
    }
}
```

## 线上部署排错

本地运行正常、部署到线上却报错时，典型报错如下：

```
Could not connect to SMTP host: smtp.qq.com, port: 465
No appropriate protocol (protocol is disabled or cipher suites are inappropriate)
```

**原因**：阿里云等服务器厂商默认禁用 25 端口，需改用 465 等可用端口 + SSL 发送，并在服务器防火墙放行对应端口。

**解决**：在工具类中补充以下配置：

```java
// 使用 465 端口 + SSL
mail.setSslSmtpPort("465");
mail.setSSLOnConnect(true);
System.setProperty("mail.smtp.ssl.enable", "true");
System.setProperty("mail.smtp.ssl.protocols", "TLSv1.2");
```

## 前端倒计时按钮（补充）

原生 JS 实现「获取验证码」按钮 60 秒禁用倒计时：

```html
<input id="mail" type="text">
<button id="getCode">获取验证码</button>

<script>
// 按钮禁用 60 秒并显示倒计时
function disabledButton() {
    const getCode = document.querySelector("#getCode");
    getCode.disabled = true;
    let second = 60;
    const intervalObj = setInterval(function () {
        getCode.innerText = "请" + second + "秒后再重试";
        if (second === 0) {
            getCode.innerText = "获取验证码";
            getCode.disabled = false;
            clearInterval(intervalObj);
        }
        second--;
    }, 1000);
}

document.querySelector("#getCode").addEventListener('click', function () {
    const mail = document.querySelector("#mail");
    let xhr = new XMLHttpRequest();
    xhr.open("GET", "http://localhost:8080/getCode?targetEmail=" + mail.value, true);
    xhr.send();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            alert(xhr.response);
            disabledButton();
        }
    };
});
</script>
```
