---
title: "Java - 基于 Redis 的短信登录实现"
date: 2026-07-29
tags: [Redis, 短信登录, Spring Boot, Java]
source: "鱼皮·编程导航 / codefather"
---

# Java - 基于 Redis 的短信登录实现

> 使用 Redis 替代 Session 实现短信验证码登录，支持验证码存储与用户登录态管理

## 核心要点

### 1. Redis Key 设计

| Key 模式 | 类型 | TTL | 用途 |
|---|---|---|---|
| `login:code:{phone}` | String | 2 分钟 | 存储短信验证码 |
| `login:token:{phone}` | Hash | 30 分钟 | 存储用户登录态（脱敏后的 UserDTO） |

常量定义：

```java
public class RedisContants {
    public static final String LOGIN_CODE_KEY = "login:code:";
    public static final Long LOGIN_CODE_TTL = 2L;         // 2分钟
    public static final String LOGIN_USER_KEY = "login:token:";
    public static final Long LOGIN_USER_TTL = 30L;        // 30分钟
    public static final String USER_NICK_NAME_PREFIX = "user_";
    public static final String LOGON_USER_ICON = "https://...";
}
```

### 2. 存储结构选择

- **验证码 → String**：数据简单，直接用 `opsForValue().set(key, value, TTL, TimeUnit.MINUTES)` 即可
- **用户信息 → Hash**：用户数据是多个字段（id、phone、nickName、icon），用 Hash 存储可以减少内存占用（相比 String 整体序列化），每个字段作为 Hash 的一个 field

### 3. 发送验证码流程

Controller 校验手机号格式 → Service 生成 6 位随机码 → 存入 Redis → 返回

```java
// Service 核心
public String sendCode(String phone, HttpSession session) {
    if (!RegexUtils.isPhoneInvalid(phone)) {
        return "手机号格式异常";
    }
    String code = RandomUtil.randomNumbers(6);
    stringRedisTemplate.opsForValue()
        .set(LOGIN_CODE_KEY + phone, code, LOGIN_CODE_TTL, TimeUnit.MINUTES);
    log.debug("发送短信验证码成功，验证码:{}", code);
    return "验证码发送成功:" + code;
}
```

### 4. 登录校验流程

校验手机号 + 验证码 → 查询用户（不存在则创建）→ 脱敏 → 转为 Hash 存储 → 返回 UserDTO

```java
// Service 核心
public UserDTO Login(LoginFormDTO loginFormDTO, HttpSession session) {
    String phone = loginFormDTO.getPhone();
    // 校验验证码
    String cachecode = stringRedisTemplate.opsForValue().get(LOGIN_CODE_KEY + phone);
    String dtoCode = loginFormDTO.getCode();
    if (dtoCode == null || !dtoCode.equals(cachecode)) {
        return null;
    }
    // 查询用户
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.eq("phone", phone);
    User user = userMapper.selectOne(queryWrapper);
    if (user == null) {
        user = CreateUser(phone);   // 新用户自动注册
    }
    // 脱敏 + 转 Hash 存储到 Redis
    UserDTO userDTO = BeanUtil.copyProperties(user, UserDTO.class);
    Map<String, Object> userMap = BeanUtil.beanToMap(userDTO, new HashMap<>(),
        CopyOptions.create()
            .setIgnoreNullValue(true)
            .setFieldValueEditor((fieldName, fieldValue) -> fieldValue.toString()));
    String tokenKey = LOGIN_USER_KEY + phone;
    stringRedisTemplate.opsForHash().putAll(tokenKey, userMap);
    stringRedisTemplate.expire(tokenKey, LOGIN_USER_TTL, TimeUnit.MINUTES);

    return userDTO;
}
```

### 5. 创建新用户

```java
private User CreateUser(String phone) {
    User user = new User();
    user.setPhone(phone);
    user.setNickName(USER_NICK_NAME_PREFIX + RandomUtil.randomString(10));
    user.setIcon(LOGON_USER_ICON);
    save(user);
    return user;
}
```

### 6. 关键工具与依赖

- **Hutool**：`BeanUtil.copyProperties()` 对象属性拷贝、`BeanUtil.beanToMap()` 对象转 Map、`BeanUtil.fillBeanWithMap()` Map 转对象
- **StringRedisTemplate**：`opsForValue()` 操作 String，`opsForHash()` 操作 Hash
- **RandomUtil**：生成随机验证码和昵称
- **RegexUtils**：校验手机号格式

### 7. 设计决策要点

| 决策 | 选择 | 原因 |
|---|---|---|
| 用户 Key 前缀 | `login:code:` / `login:token:` | 区分不同用途，避免 key 冲突 |
| 用户标识 | 使用手机号作为 key | 实现简单（作者原计划用 UUID token，但因 token 比对逻辑未攻克而放弃）；注意：手机号作为 key 存在信息泄露风险 |
| 数据结构 | Hash | 字段级存取，节省空间，无需整体序列化/反序列化 |
| 对象转换 | Hutool BeanUtil | 简化 DTO 与 Map 之间的转换，自动处理属性拷贝 |
| 新用户处理 | 自动创建 | 验证码正确即自动注册，提升用户体验 |

> 来源：鱼皮·编程导航 / codefather
