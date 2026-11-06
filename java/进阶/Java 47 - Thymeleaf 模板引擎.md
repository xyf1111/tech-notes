---
title: "Java 47 - Thymeleaf 模板引擎"
date: 2026-08-06
tags: [Java, Thymeleaf, 模板引擎, Spring Boot]
source: "鱼皮·编程导航 / codefather"
---

# Thymeleaf 模板引擎

Thymeleaf 是一种**自然的模板**：模板本身就是合法的 HTML，浏览器直接打开也能正常显示，实现**动静分离**；同时它也是一个处理**纯文本**的模板引擎。

## 模板引擎

模板引擎的作用：**将数据和页面显示分离**。

```
模板文件 + 数据 --> 模板引擎 --> html
```

模板引擎通过正则表达式识别模板中固定不变的部分与变化的数据，再借助已有 API（如各种表达式类型）把数据按指定格式渲染进去，根据既定规则完成解析。

### JSP 的局限性

Spring Boot 时代 JSP 逐渐被模板引擎取代，主要原因：

1. **内嵌容器不支持 JSP**：Spring Boot 打成 jar 包时内嵌容器不支持 JSP，要运行 JSP 必须打成 war 包并使用外部容器。
2. **undertow 容器不支持 JSP**。
3. **扩展性有限**：很多默认处理难以自定义。
4. **容器化使用繁杂**：在 Docker 等容器化技术中使用 JSP 很繁琐。

### 常见模板引擎

- 较早的模板引擎：**Velocity**、**FreeMarker**
- 国人开发的模板引擎：**Beetl**
- 本文主角：**Thymeleaf**

## 引入 Thymeleaf 命名空间

在 `<html>` 标签上引入 `xmlns:th`，使用 th 属性时才有代码提示：

```html
<html lang="en" xmlns:th="http://www.thymeleaf.org">
```

## 五种表达式

| 表达式 | 名称 | 作用 |
| --- | --- | --- |
| `${}` | 变量表达式 | 引用一个变量 |
| `*{}` | 选择变量表达式 | 通过 `${}` 拿到一个对象后，获取该对象的属性值 |
| `#{}` | 消息表达式 | 从配置文件中取值，可用来实现国际化效果 |
| `@{}` | 链接表达式 | 生成 URL 链接 |
| `~{}` | 片段表达式 | 引用相同的代码片段 |

## 字符串拼接

```html
<p th:text="${person.name} + ' is ' + ${person.age}"></p>
<!-- 使用 | 将 ${} 的内容替换成对象，其余部分不变 -->
<p th:text="|${person.name} is ${person.age}|"></p>
```

## 条件判断

### th:if / th:unless

```html
<p th:if="${msg=='yes'}">这是第一个msg的取值：</p>
<p th:text="${msg}" th:if="${msg=='yes'}"></p>
<p th:unless="${msg=='no'}">这是第二个msg的取值：</p>
<p th:text="${msg}" th:unless="${msg=='no'}"></p>
```

`th:if` 条件成立时展示；`th:unless` 与 `th:if` 相反，条件**不成立**时展示。

### th:switch / th:case

```html
<div th:switch="${num}">
    <p th:case="1">1</p>
    <p th:case="2">2</p>
    <p th:case="*">*</p>
</div>
```

`th:case="*"` 表示默认分支（类似 switch 的 default）。

## 循环：th:each

```html
<table>
    <thead>
        <tr>
            <th>名字</th>
            <th>年龄</th>
        </tr>
    </thead>
    <tbody>
        <tr th:each="data:${list}">
            <td th:text="${data.name}">name</td>
            <td th:text="${data.age}">age</td>
        </tr>
    </tbody>
</table>
```

### 状态变量

默认命名为 **参数名 + Stat**（如上面的 `dataStat`），用来**保存迭代状态**；也可自定义命名：

```html
<tr th:each="data,status:${list}">
```

此时状态变量名为 `status`。状态变量的属性：

| 属性 | 说明 |
| --- | --- |
| `index` | 索引，从 0 开始 |
| `count` | 计数，从 1 开始 |
| `size` | 集合的大小 |
| `current` | 当前对象 |
| `first` / `last` | 布尔类型，是否是第一个 / 最后一个 |
| `even` / `odd` | 布尔类型，是否是偶数 / 奇数个 |

使用示例：

```html
<tr th:each="data:${list}">
    <td th:text="${data.name}">name</td>
    <td th:text="${dataStat.index}">index</td>
    <td th:text="${dataStat.count}">count</td>
    <td th:text="${dataStat.first}">first</td>
    <td th:text="${dataStat.last}">last</td>
    <td th:text="${dataStat.even}">even</td>
</tr>
```

## URL 表达式：@{}

### 基础用法（上下文相对路径）

```html
<form th:action="@{/login}" method="post">
    username:
    <input type="text" name="username">
    password:
    <input type="password" name="password">
    <input type="submit" value="提交">
</form>
```

### 绝对路径

```html
<a th:href="@{http://cn.bing.com}">外链到：bing</a>
<!-- 渲染效果为 <a href="http://cn.bing.com">外链到：bing</a> -->
```

### 协议自动识别补全

**开头用 `//`**，以引用静态资源举例：

```html
<script type="text/javascript" th:src="@{//code.jquery.com/jquery-3.4.1.min.js}"></script>
```

渲染结果会自动补全协议（跟随当前页面的 http/https）。

### 上下文相关的 URL（context-path）

`@{/login}` 是上下文相对路径。比如项目部署地址为 `localhost:8080/demo`（配置文件中增加 `server.servlet.context-path=/demo`），渲染结果会自动带上 `/demo` 前缀。

引用静态资源（webjars）的方式：先引入 springboot 依赖配置

```xml
<dependency>
    <groupId>org.webjars</groupId>
    <artifactId>jquery</artifactId>
    <version>3.4.1</version>
</dependency>
```

再在 html 中引用：

```html
<script type="text/javascript" th:src="@{/webjars/jquery/3.4.1/jquery.js}"></script>
```

### 带参数的 URL

请求中携带参数：

```html
<!-- a）单个参数：/addPerson?id=1，用括号括起来 -->
@{/addPerson(id=1)}

<!-- b）多个参数：/addPerson?id=1&name='lsq'，参数之间用逗号隔开 -->
@{/addPerson(id=1,name='lsq')}

<!-- c）路径变量：/addPerson/1?name='lsq'，路径中支持变量并用参数替换 -->
@{/addPerson/{id}(id=1,name='lsq')}
```

### 服务器相关 URL（~）

```html
<a th:href="@{~/a.html}"></a>
```

通过 `~` 指定的是**服务器上的某个地址**，与项目无关，**不会增加上下文路径（context-path）**；这样不同的项目可以访问同一服务器下的某个固定文件。渲染结果为 `<a href="/a.html">`。

## 内置工具对象（# 前缀）

工具类的使用方式：**加前缀 `#`**。可用的工具类：`dates`、`calendars`、`numbers`、`strings`、`objects`、`bools`、`arrays`、`lists`、`sets`、`maps`。

日期 `#dates`：

```html
<p th:text="${date}"></p>
<p th:text="${#dates.format(date,'yyyy-MM-dd HH:mm:ss')}"></p>

<!-- 拿到当前的时间 -->
<p th:text="${#dates.createNow()}"></p>
<p th:text="${#dates.createToday()}"></p>
```

字符串 `#strings`：

```html
<p th:text="${#strings.isEmpty(str)}"></p>
<p th:text="${#strings.length(str)}"></p>
<p th:text="${#strings.equals(str,'duing')}"></p>
```

## 表达式语言：OGNL 与 SpEL

- **OGNL**（Object-Graph Navigation Language）：对象视图导航语言，可以通过表达式获取 Java 对象，JavaWeb 中使用较多。
- **SpEL**：基于 Spring 的表达式语言，提供运行时与对象交互的能力。

本质都是**在视图层和控制层之间建立数据联系**的方式。支持简单算术、集合下标访问、`T(...)` 静态方法调用等：

```html
<p th:text="${ 1 * 2 + 3 - 4}"></p>

<p th:text="${list[0].name}"></p>

<p th:text="${T(java.lang.Math).random()}"></p>
```

## 内联表达式

用两个中括号 `[[...]]` 将一个引用对象括起来，对象本身还是用 `${}` 获取，这样就能把展示的信息与其它字符串拼接起来（简化展示文本的逻辑）。凡是可以用 `th:text` 或 `th:utext` 显示的内容都可以用内联表达式来转换：

- `th:text` => `[[...]]`：**转义**，内容若含标签，标签效果不起作用
- `th:utext` => `[(...)]`：**不转义**，按标签效果输出

```html
<p> 加油，[[${info}]] </p>
<p> 加油，<span th:text="${info}"></span> </p>

<!-- 如果文本需要展示含 [[]] 的数据，可以禁用内联表达式 -->
<p th:inline="none"> 加油，[[<span th:text="${info}"></span>]] </p>
```

### 内联 JavaScript

当需要给 JavaScript 中传数据时使用，同样支持**动静分离**：用 `/*[[${info}]]*/` 将动态数据引起来，在其后跟上静态数据作为兜底（使用后原来的注释功能就不能用了）。局限性：在外部 js 文件中不能使用，只在 html 文件中的 js 代码生效：

```html
<script type="text/javascript" th:inline="javascript">
    var info = /*[[${info}]]*/ 123;
    console.log(info);
</script>
```

类似 js，也支持 css：

```html
<style th:inline="css">
</style>
```

## 碎片代码：th:fragment / th:include / th:replace / th:insert

有些网页内容需要在许多网页中使用，可以用 `th:fragment` 在某个独立的（网页）标签中设置碎片代码并为其命名，在需要引入的网页中使用 `th:include`、`th:replace`、`th:insert` 等引入。

三者的区别：

| 指令 | 行为 |
| --- | --- |
| `th:include` | 只引入碎片代码的**内容**，不引入碎片标签，保留原有标签属性 |
| `th:replace` | 与 include 相反：引入碎片标签，**不保留**原有标签 |
| `th:insert` | 既引入碎片标签，也保留原有标签（样式冲突时碎片标签属性起作用） |

> 来源：鱼皮·编程导航 / codefather
