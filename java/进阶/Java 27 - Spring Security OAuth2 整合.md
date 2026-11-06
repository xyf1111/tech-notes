---
title: "Java - Spring Security OAuth2 整合"
date: 2026-07-24
tags:
  - java
  - spring-security
  - oauth2
  - 安全
  - 认证授权
source: "鱼皮·编程导航 / codefather"
---

# Spring Security OAuth2 整合

> OAuth 2.0 是一个开放的授权标准/协议，允许用户让第三方应用访问该用户在某一网站上存储的私密资源（如头像、照片、视频等），无需将用户名和密码提供给第三方应用。通过令牌（token）实现授权，每个令牌授权特定网站在特定时段内访问特定资源。

## OAuth 2.0 基础概念

### 角色

| 角色 | 说明 |
|------|------|
| **Client**（第三方应用） | 需要访问用户资源的应用程序 |
| **Resource Owner**（资源所有者） | 用户，拥有资源的所有权 |
| **Authorization Server**（授权服务器） | 负责认证和发放令牌的服务器 |
| **Resource Server**（资源服务器） | 存放用户资源的服务器 |

### 总体流程

```
A) 用户打开客户端 → 客户端要求用户给予授权
B) 用户同意给予客户端授权
C) 客户端使用获得的授权，向认证服务器申请令牌
D) 认证服务器确认无误，发放令牌
E) 客户端使用令牌，向资源服务器申请获取资源
F) 资源服务器确认令牌无误，开放资源
```

## 四种授权模式

### 1. 授权码模式（Authorization Code）

功能最完整、流程最严密、使用最广泛的模式。通过客户端后台服务器与服务提供商的认证服务器交互。

**流程：**
- （A）用户访问第三方应用，第三方应用通过浏览器导向认证服务器
- （B）用户选择是否给予客户端授权
- （C）用户给予授权后，认证服务器将用户导向客户端指定的重定向URI，附上授权码
- （D）客户端收到授权码，在后台向认证服务器申请令牌（对用户不可见）
- （E）认证服务器核对授权码和重定向URI无误后，发送访问令牌和更新令牌

**核心参数：**
```
https://wx.com/oauth/authorize?response_type=code&client_id=CLIENT_ID&redirect_uri=http://www.baidu.com&scope=read
```

| 参数 | 说明 |
|------|------|
| `client_id` | 授权服务器注册后的唯一标识 |
| `response_type` | 固定值，授权码模式为 `code` |
| `redirect_uri` | 客户端的重定向URL |
| `scope` | 令牌可访问的资源权限（read / all） |
| `state` | 可选，原样返回客户端，防止 CSRF 攻击 |

### 2. 简化模式（Implicit）

不通过第三方后台服务器，直接在浏览器中向认证服务器申请令牌，跳过授权码步骤。令牌对访问者可见。

**流程：**
- （A）第三方应用将用户导向认证服务器
- （B）用户决定是否给予授权
- （C）用户给予授权后，认证服务器将用户导向重定向URI，在URI的Hash部分包含访问令牌（`#token`）
- （D）浏览器向资源服务器发出请求，不包括Hash值
- （E）资源服务器返回含脚本的网页，提取Hash中的令牌
- （F）浏览器执行脚本提取令牌
- （G）浏览器将令牌发给客户端

### 3. 密码模式（Resource Owner Password Credentials）

用户向客户端提供用户名和密码，客户端用这些信息向服务提供商索要授权。适用于用户高度信任客户端的情况（如操作系统的一部分）。

**流程：**
- （A）用户向客户端提供用户名和密码
- （B）客户端将用户名和密码发给认证服务器，请求令牌
- （C）认证服务器确认无误后提供访问令牌

### 4. 客户端模式（Client Credentials）

客户端以自己的名义而非用户的名义向服务提供商进行认证。不涉及授权问题。

**流程：**
- （A）客户端向认证服务器进行身份认证，要求访问令牌
- （B）认证服务器确认无误后提供访问令牌

### OAuth2 标准接口

| 端点 | 说明 |
|------|------|
| `/oauth/authorize` | 授权端点 |
| `/oauth/token` | 获取令牌端点 |
| `/oauth/confirm_access` | 用户确认授权提交端点 |
| `/oauth/error` | 授权服务错误信息端点 |
| `/oauth/check_token` | 资源服务访问的令牌解析端点 |
| `/oauth/token_key` | 公有密钥端点（JWT令牌时使用） |

## Spring Security OAuth2 发展历程

Spring Security OAuth 经历了多次演变：

1. **早期阶段**：Spring Security OAuth 社区驱动项目，同时支持 OAuth1.0 和 OAuth2.0
2. **碎片化问题**：Spring Security OAuth、Spring Cloud Security、Spring Boot 1.5.x、Spring Security 5.x 各自提供了 OAuth2 实现，选择混乱
3. **2018年**：官方宣布停止现有 OAuth2 支持，在 Spring Security 5 中构建下一代 OAuth2.0 支持。Spring Security OAuth 进入维护模式
4. **2019年**：宣布不再支持授权服务器（理由：已有大量商业/开源授权服务器；框架不适合构建授权服务器产品）
5. **2020年4月**：因社区强烈反馈，官方启动 **Spring Authorization Server** 项目
6. **2020年8月**：Spring Authorization Server 0.0.1 发布

> 日常开发中，大部分场景是开发**客户端**（接入 QQ/微信/GitHub 登录）。授权服务器和资源服务器通常由外部提供。

## 实战：GitHub 授权登录

### 创建 OAuth 应用
1. 访问 GitHub → Settings → Developer Settings → OAuth Apps
2. 创建 OAuth App，获取 Client ID 和 Client Secret

### 引入依赖
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-oauth2-client</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

### 配置类
```java
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.authorizeRequests()
                .anyRequest().authenticated()
                .and()
                .oauth2Login();
    }
}
```

### 配置文件
```properties
server.port=8080
spring.security.oauth2.client.registration.github.client-id=your-client-id
spring.security.oauth2.client.registration.github.client-secret=your-client-secret
spring.security.oauth2.client.registration.github.redirect-uri=http://localhost:8080/login/oauth2/code/github
```

### 测试 Controller
```java
@RestController
public class HelloController {
    @GetMapping("/hello")
    public DefaultOAuth2User hello(){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return (DefaultOAuth2User) authentication.getPrincipal();
    }
}
```

## 实战：搭建授权服务器与资源服务器

### 授权服务器（基于内存存储）

引入依赖（注意需降低 Spring Boot 版本至 2.2.5.RELEASE）：
```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-oauth2</artifactId>
    <version>2.2.5.RELEASE</version>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

Security 配置类：
```java
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
    @Override
    @Bean
    protected AuthenticationManager authenticationManager() throws Exception {
        return super.authenticationManager();
    }
    @Bean
    public UserDetailsService userDetailsService() {
        InMemoryUserDetailsManager manager = new InMemoryUserDetailsManager();
        manager.createUser(User.withUsername("root")
            .password(passwordEncoder().encode("123"))
            .roles("ADMIN").build());
        return manager;
    }
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userDetailsService());
    }
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable().formLogin();
    }
}
```

Authorization Server 配置类：
```java
@Configuration
@EnableAuthorizationServer
public class AuthorizationServer extends AuthorizationServerConfigurerAdapter {
    // ... 注入 passwordEncoder, userDetailsService
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.inMemory().withClient("client")
            .secret(passwordEncoder.encode("secret"))
            .redirectUris("http://www.baidu.com")
            .scopes("client:read,user:read")
            .authorizedGrantTypes("authorization_code", "refresh_token",
                "implicit", "password", "client_credentials");
    }
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
        endpoints.userDetailsService(userDetailsService);
    }
}
```

获取令牌：
```bash
# 获取授权码
http://localhost:8080/oauth/authorize?client_id=client&response_type=code&redirect_uri=http://www.baidu.com

# 申请令牌
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
  -d 'grant_type=authorization_code&code={code}&redirect_uri=http://www.baidu.com' \
  "http://client:secret@localhost:8080/oauth/token"

# 刷新令牌
curl -X POST -H "Content-Type: application/x-www-form-urlencoded" \
  -d 'grant_type=refresh_token&refresh_token={refresh_token}&client_id=client' \
  "http://client:secret@localhost:8080/oauth/token"
```

### 授权服务器（基于数据库存储）

建表使用 Spring Security OAuth 提供的 [schema.sql](https://github.com/spring-projects/spring-security-oauth/blob/master/spring-security-oauth2/src/test/resources/schema.sql)（MySQL 需将 `LONGVARBINARY` 替换为 `BLOB`）。

关键表：`oauth_client_details`（客户端信息）、`oauth_access_token`（令牌）、`oauth_refresh_token`（刷新令牌）、`oauth_code`（授权码）、`oauth_approvals`（用户授权）。

配置类切换为 JDBC 存储：
```java
@Configuration
@EnableAuthorizationServer
public class JdbcAuthorizationServer extends AuthorizationServerConfigurerAdapter {
    @Bean
    public TokenStore tokenStore() { return new JdbcTokenStore(dataSource); }
    @Bean
    public ClientDetailsService clientDetails() {
        JdbcClientDetailsService service = new JdbcClientDetailsService(dataSource);
        service.setPasswordEncoder(passwordEncoder);
        return service;
    }
    @Override
    public void configure(AuthorizationServerEndpointsConfigurer endpoints) throws Exception {
        endpoints.authenticationManager(authenticationManager);
        endpoints.tokenStore(tokenStore());
        DefaultTokenServices tokenServices = new DefaultTokenServices();
        tokenServices.setTokenStore(endpoints.getTokenStore());
        tokenServices.setSupportRefreshToken(true);
        tokenServices.setAccessTokenValiditySeconds((int) TimeUnit.DAYS.toSeconds(30));
        tokenServices.setRefreshTokenValiditySeconds((int) TimeUnit.DAYS.toSeconds(3));
        endpoints.tokenServices(tokenServices);
    }
    @Override
    public void configure(ClientDetailsServiceConfigurer clients) throws Exception {
        clients.withClientDetails(clientDetails());
    }
}
```

### 资源服务器

```java
@Configuration
@EnableResourceServer
public class ResourceServerConfig extends ResourceServerConfigurerAdapter {
    @Override
    public void configure(ResourceServerSecurityConfigurer resources) throws Exception {
        resources.tokenStore(tokenStore());
    }
    @Bean
    public TokenStore tokenStore() { return new JdbcTokenStore(dataSource); }
}
```

### 使用 JWT 令牌

授权服务器配置 JWT：
```java
@Bean
public TokenStore tokenStore() { return new JwtTokenStore(jwtAccessTokenConverter()); }
@Bean
public JwtAccessTokenConverter jwtAccessTokenConverter() {
    JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
    converter.setSigningKey("your-secret-key"); // 生产环境建议加密存储
    return converter;
}
```

资源服务器使用相同密钥解析 JWT：
```java
@Configuration
@EnableResourceServer
public class JwtResourceServerConfig extends ResourceServerConfigurerAdapter {
    @Override
    public void configure(ResourceServerSecurityConfigurer resources) throws Exception {
        resources.tokenStore(tokenStore());
    }
    @Bean
    public TokenStore tokenStore() { return new JwtTokenStore(jwtAccessTokenConverter()); }
    @Bean
    public JwtAccessTokenConverter jwtAccessTokenConverter() {
        JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
        converter.setSigningKey("your-secret-key");
        return converter;
    }
}
```

访问资源：
```bash
curl -H "Authorization:Bearer eyJhbG..." http://localhost:8081/hello
```

> 来源：鱼皮·编程导航 / codefather
