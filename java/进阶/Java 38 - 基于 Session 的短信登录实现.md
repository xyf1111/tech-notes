---
title: "Java - 基于 Session 的短信登录实现"
date: 2026-07-29
tags: [Session, 短信登录, Spring Boot, Java]
source: "鱼皮·编程导航 / codefather"
---

# Java - 基于 Session 的短信登录实现

> 使用 HttpSession 存储短信验证码与用户登录态，实现短信验证码登录与自动注册功能。

---

## 核心流程

### 1. 发送验证码

1. 用户提交手机号
2. 校验手机号格式（正则）
3. 合法 → 生成 6 位随机验证码，存入 Session
4. 不合法 → 提示重新输入

### 2. 短信验证码登录 / 注册

1. 用户输入手机号 + 验证码
2. 从 Session 取出验证码与用户输入比对
3. 不一致 → 校验失败
4. 一致 → 根据手机号查询用户
5. 用户不存在 → 自动创建新用户（随机昵称、无密码）
6. 将用户信息（脱敏后）存入 Session

---

## 正则校验工具

### RegexPatterns — 正则常量

```java
public class RegexPatterns {
    public static final String PHONE_REGEX = "1\\d{10}";
    public static final String EMAIL_REGEX = "/^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$/";
    public static final String VERIFY_CODE_REGEX = "^[a-zA-Z\\d]{6}$";
}
```

### RegexUtils — 校验工具类

```java
public class RegexUtils {
    public static boolean isPhoneInvalid(String phone) {
        return phone.matches(RegexPatterns.PHONE_REGEX);
    }

    public boolean isCodeInvalid(String code) {
        return code.matches(RegexPatterns.VERIFY_CODE_REGEX);
    }
}
```

---

## 发送验证码实现

### Controller

```java
@GetMapping("/code")
public boolean SendCode(String phone, HttpSession session) {
    return userService.sendCode(phone, session);
}
```

### Service

```java
public boolean sendCode(String phone, HttpSession session) {
    // 1. 校验手机号
    if (!RegexUtils.isPhoneInvalid(phone)) {
        return false;
    }
    // 2. 生成 6 位随机验证码
    String code = RandomUtil.randomNumbers(6);
    // 3. 存入 Session
    session.setAttribute("code", code);
    // 4. 日志输出（需开启 debug 级别）
    log.debug("发送短信验证码成功，验证码:{}", code);
    return true;
}
```

> 需在 `application.yml` 中开启 debug 日志：
> ```yaml
> logging:
>   level:
>     com.example: debug
> ```

---

## 登录注册实现

### 请求参数封装

```java
@Data
public class LoginFormDTO {
    private String code;
    private String phone;
}
```

### Controller

```java
@PostMapping("/login")
public boolean login(LoginFormDTO loginFormDTO, HttpSession session) {
    return userService.Login(loginFormDTO, session);
}
```

### Service

```java
@Override
public boolean Login(LoginFormDTO loginFormDTO, HttpSession session) {
    // 1. 校验手机号
    String phone = loginFormDTO.getPhone();
    if (!RegexUtils.isPhoneInvalid(phone)) {
        return false;
    }
    // 2. 校验验证码
    Object cachecode = session.getAttribute("code");
    String dtoCode = loginFormDTO.getCode();
    if (dtoCode == null || !dtoCode.equals(cachecode)) {
        return false;
    }
    // 3. 根据手机号查询用户
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("phone", phone);
    User user = userMapper.selectOne(queryWrapper);
    // 4. 用户不存在则创建
    if (user == null) {
        user = CreateUser(phone);
    }
    // 5. 用户信息脱敏后存入 Session
    UserDTO userDTO = BeanUtil.copyProperties(user, UserDTO.class);
    session.setAttribute("user", userDTO);
    return true;
}
```

### 创建新用户

```java
private User CreateUser(String phone) {
    User user = new User();
    user.setPhone(phone);
    user.setNickName(RandomUtil.randomString(10));
    save(user);
    return user;
}
```

---

## 用户信息脱敏（UserDTO）

避免将完整 User 实体（含密码等敏感字段）暴露到前端，专门封装脱敏 DTO：

```java
@Data
public class UserDTO {
    private Long id;
    private String nickName;
    private String icon;
}
```

使用 Hutool 的 `BeanUtil.copyProperties(user, UserDTO.class)` 一键拷贝属性。

---

## API 测试

### 发送验证码

```
GET http://localhost:8080/api/user/code?phone=13177576913
```

### 校验验证码并登录

```
POST http://localhost:8080/api/user/login?phone=13177576913&code=686422
```

---

## 与 Redis 版（Java 37）对比

| 维度 | Session 版（本文） | Redis 版（Java 37） |
|------|-------------------|---------------------|
| 存储介质 | HttpSession（服务端内存） | Redis（独立缓存服务） |
| 验证码 Key | `session.getAttribute("code")` | `login:code:{phone}` |
| 用户信息 Key | `session.getAttribute("user")` | `login:token:{phone}` (Hash) |
| 数据结构 | 直接存 Java 对象 | 验证码 → String，用户 → Hash |
| TTL 控制 | 依赖 Session 超时配置 | 精确的 TTL（2 分/30 分） |
| 脱敏方式 | `BeanUtil.copyProperties` | `BeanUtil.copyProperties` + `BeanUtil.beanToMap` |
| 集群支持 | 需配置 Session 共享（如 Spring Session + Redis）| 天然支持 |
| 业务逻辑 | 完全相同 | 完全相同 |

> 核心差异仅在存储介质与 API 调用方式，发送验证码 → 校验登录 → 自动注册的整体业务逻辑完全一致。

---

> 来源：鱼皮·编程导航 / codefather
