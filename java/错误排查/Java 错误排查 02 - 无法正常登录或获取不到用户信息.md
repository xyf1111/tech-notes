---
title: "错误排查 02 - 无法正常登录或获取不到用户信息"
date: 2026-07-15
tags: [Java, 后端, 登录鉴权, 跨域, 错误排查]
source: "鱼皮·编程导航 / codefather"
---

# 错误排查 02 - 无法正常登录或获取不到用户信息

> 登录功能常见问题：账号密码正确但登录后接口报未登录、登录成功跳转后拿不到用户信息。以下从跨域、后端、前端三个层面排查。

## 跨域问题

跨域是最常见的登录失败原因。跨域指前端域名（如 `aaa.com`）与后端服务域名（如 `bbb.com`）不同，浏览器同源策略会阻止 cookie 互通，导致用户凭证无法传递。

### 解决方案

**方案一：保持域名一致**
前端和后端接口使用相同域名，通过 Nginx 进行端口转发。

**方案二：后端配置跨域**

全局配置（Spring Boot）：

```java
@Configuration
public class CorsConfig {

    @Bean
    public FilterRegistrationBean<CorsFilter> corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        config.addAllowedOrigin("http://aaa.com");   // 填写前端域名
        config.addAllowedHeader("*");
        config.addAllowedMethod("*");
        source.registerCorsConfiguration("/**", config);
        FilterRegistrationBean<CorsFilter> bean = new FilterRegistrationBean<>(new CorsFilter(source));
        bean.setOrder(Ordered.HIGHEST_PRECEDENCE);
        return bean;
    }
}
```

Controller 级别或方法级别：

```java
@RestController
@CrossOrigin(origins = "http://aaa.com", allowCredentials = "true")
public class MyController {
    // ...
}
```

**常见踩坑**：用了 `@CrossOrigin` 仍无效 → 加上 `allowCredentials = "true"`

**`@CrossOrigin` 属性说明：**

| 属性 | 说明 |
|------|------|
| `origins` | 允许的来源域 |
| `methods` | 允许的 HTTP 方法 |
| `allowedHeaders` | 允许的请求头 |
| `exposedHeaders` | 暴露给浏览器的响应头 |
| `allowCredentials` | 是否允许发送身份验证信息（如 Cookie） |
| `maxAge` | 预检请求有效期 |

## 后端代码问题

确认无跨域问题后，排查后端逻辑：

1. 通过 F12 确认登录接口是否正常返回数据
2. 查看控制台或服务器日志，检查登录接口调用时是否有报错（可能会被 `try-catch` 吞掉）
3. 确认 session/token 凭证正确写入响应

## 前端代码问题

后端接口正常返回用户信息后，检查前端：

**问题 1：用户数据取值与后端返回结构不匹配**
检查前端取数据字段名是否与后端返回值一致。

**问题 2：请求未携带 cookie**
在请求配置中添加 `withCredentials: true`：

```typescript
// requestConfig.ts
export const request = extend({
  withCredentials: true,
  // ...
});
```

**问题 3：域名不一致导致 cookie 种不上**
如 `app.ts` 中配置的是 `localhost`，但用 `127.0.0.1` 访问，cookie 无法写入。保持访问域名一致。

> 来源：鱼皮·编程导航 / codefather
