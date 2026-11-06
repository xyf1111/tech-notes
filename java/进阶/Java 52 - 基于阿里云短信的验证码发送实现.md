---
title: "Java 进阶 - 基于阿里云短信的验证码发送实现"
date: 2026-08-19
tags: [Java, SpringBoot, 短信, 验证码, Redis, 阿里云]
source: "鱼皮·编程导航 / codefather"
---

# Java 进阶 - 基于阿里云短信的验证码发送实现

> 短信验证码是注册、登录等敏感操作最常用的安全校验方式。本文基于阿里云短信服务（新用户赠送免费额度）实现手机验证码发送，配合 Redis 做一分钟限流；与 QQ 邮箱验证码方案（Java 48）互为付费 / 免费两种选择。

## 需求分析

- **场景**：用户输入手机号 → 点击「获取验证码」→ 后端调用短信服务发送验证码到该手机号。
- **防刷设计**：限制一分钟内只能获取一次。
  - 前端：倒计时期间禁用「获取验证码」按钮。
  - 后端：验证码存入 Redis 并设置过期时间；请求先查 Redis，已有验证码则直接拒绝。

## 短信服务介绍

第三方短信服务商会与各大运营商（移动、联通、电信）对接，我们只需购买服务后按其开发文档调用 API 即可发送短信。常用短信服务：

- 阿里云
- 腾讯云
- 华为云

本文采用阿里云（新用户赠送免费额度，成本为零）。

## 服务配置（签名/模板/AccessKey）

1. 进入阿里云官网并登录，顶部搜索「短信服务」，进入短信服务控制台。
2. 选择「国内消息」菜单，先添加**短信签名**：用于标识短信发送者身份（一般填应用/公司名称），需审核。
3. 再申请**短信模板**：定义短信内容格式，验证码位置留占位符（如 `${code}`），需审核。
4. 右上角用户头像 → **AccessKey 管理**：AccessKey 相当于程序访问阿里云 API 的用户名密码。
5. 建议使用**子用户**而非主账号：权限更小，泄露后危害较小，但操作相对繁琐。
   - 创建用户时，可控制其只允许 OpenAPI 调用访问。
   - 创建成功后生成一对 AccessKey（AccessKeyId / AccessKeySecret），需妥善保管、防止泄露。
   - 点击用户为其授予短信服务（SMS）相关权限。

## SpringBoot 集成

### 依赖与配置

pom.xml 导入阿里云短信 SDK 与 Redis 依赖：

```xml
<!-- 短信验证码所需 jar 包 -->
<dependency>
    <groupId>com.aliyun</groupId>
    <artifactId>aliyun-java-sdk-core</artifactId>
    <version>4.5.16</version>
</dependency>
<dependency>
    <groupId>com.aliyun</groupId>
    <artifactId>aliyun-java-sdk-dysmsapi</artifactId>
    <version>2.1.0</version>
</dependency>
<!-- 使用 redis 缓存验证码时效 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

application.yml 配置 Redis（若设置了 redis 密码记得补上 password）：

```yaml
spring:
  redis:
    # redis 数据库索引（默认为 0），使用索引 3 避免和其他数据库冲突
    database: 3
    # redis 服务器地址（默认为 localhost）
    host: localhost
    # redis 端口（默认为 6379）
    port: 6379
```

### 发送验证码工具类

将官方 API 封装为工具类，填入服务配置阶段获取的参数：

```java
public class SMSUtils {
    // 签名
    private final static String SIGN_NAME = "XXXX";
    // 模板
    private final static String TEMPLATE_CODE = "XXXX";

    /**
     * 发送短信
     * @param phoneNumbers 收信人手机号
     * @param param        发送的验证码
     */
    public static void sendMessage(String phoneNumbers, String param) {
        // 配置的 accessKeyId 和 secret
        DefaultProfile profile = DefaultProfile.getProfile("cn-hangzhou", "xxxx", "xxxxxx");
        IAcsClient client = new DefaultAcsClient(profile);

        SendSmsRequest request = new SendSmsRequest();
        request.setSysRegionId("cn-hangzhou");
        request.setPhoneNumbers(phoneNumbers);   // 收信人手机号
        request.setSignName(SIGN_NAME);          // 申请的签名
        request.setTemplateCode(TEMPLATE_CODE);  // 申请的模板
        // 替换模板中的参数，必须为 Json 格式
        request.setTemplateParam("{\"code\":\"" + param + "\"}");
        try {
            SendSmsResponse response = client.getAcsResponse(request);
            System.out.println(response);
        } catch (ServerException e) {
            e.printStackTrace();
        } catch (ClientException e) {
            // 打印处理结果
            System.out.println("ErrCode:" + e.getErrCode());
            System.out.println("ErrMsg:" + e.getErrMsg());
            System.out.println("RequestId:" + e.getRequestId());
        }
    }
}
```

要点：

- `setTemplateParam` 必须传 JSON 字符串，key 需与模板占位符对应。
- `ClientException` 中的 ErrCode / ErrMsg / RequestId 用于排查发送失败原因。

### 发送接口与登录校验

```java
@RestController
@CrossOrigin("http://localhost:63342")
public class SendCode {

    @GetMapping("/getCode")
    @ResponseBody
    public String phone(@RequestParam("targetPhone") String targetPhone) {
        // 生成六位数验证码
        int authNum = new Random().nextInt(899999) + 100000;
        SMSUtils.sendMessage(targetPhone, String.valueOf(authNum));
        return "发送成功";
    }
}
```

启动服务后测试：

```http
GET http://localhost:8080/getCode?targetPhone=158xx889
```

### Redis 限流改进

无缓存时，恶意用户可无限次请求接口，每次都会产生短信费用，因此引入 Redis 缓存做一分钟限流：

```java
@RestController
@CrossOrigin("http://localhost:63342")
public class SendCode {
    @Resource
    private RedisTemplate<String, String> redisTemplate;

    @GetMapping("/getCode")
    @ResponseBody
    public String phone(@RequestParam("targetPhone") String targetPhone) {
        // 发送前先看是否已缓存验证码
        String yzm = redisTemplate.opsForValue().get("yzm");
        if (yzm == null) {
            // 生成六位数验证码并发送
            int authNum = new Random().nextInt(899999) + 100000;
            String authCode = String.valueOf(authNum);
            SMSUtils.sendMessage(targetPhone, authCode);
            // 存入 redis，有效期 1 分钟
            redisTemplate.opsForValue().set("yzm", authCode, 1, TimeUnit.MINUTES);
            return "发送成功";
        }
        // 已存在，直接拒绝，不再发送
        return "请勿重复发送验证码";
    }
}
```

改进思路：先查 Redis → 不存在才发送并写入（有效期 1 分钟）→ 已存在则拒绝，短时间内只能获取一次。实际项目中建议以手机号为 key（如 `sms:code:{phone}`），并在校验登录时比对验证码是否正确。

## 前端倒计时按钮

原生 JS 实现：点击按钮发起请求，请求完成后禁用按钮并显示 60 秒倒计时：

```html
<div>
    <input id="phoneNum" type="text">
    <button id="getCode">获取验证码</button>
</div>
<script>
    /* 按钮禁用 60 秒，并显示倒计时 */
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
        const phoneNum = document.querySelector("#phoneNum");
        let xhr = new XMLHttpRequest();
        xhr.open("GET", "http://localhost:8080/getCode?targetPhone=" + phoneNum.value, true);
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

> 来源：鱼皮·编程导航 / codefather — 《阿里云短信服务实现手机验证码》
