---
title: "Java 工具 18 - Hutool 工具类库入门"
date: 2026-09-19
tags: [Java, Hutool, 工具类库, Util, 效率提升]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 18 - Hutool 工具类库入门

> Hutool 是一个小而全的开源 Java 工具类库，用静态方法封装了文件、流、加密解密、转码、正则、线程、XML 等 JDK 能力，是项目里 util 包友好的替代品，可以最大限度避免「复制粘贴网上代码」带来的效率损耗与隐藏 Bug。

## 一、要解决的问题

开发中经常需要重复编写与业务无关的代码：获取指定日期对象、获取本机 IP、校验身份证号、数据加密等。通常的做法是把这些代码独立到 util 包下作为工具类供其他代码调用。

但遇到没写过的工具类时（比如老板要做一个 MD5 加密工具，而你根本没学过加密算法），典型流程是：

1. 打开搜索引擎搜「Java MD5 加密算法实现」
2. 打开某篇博客（可能还要登录）
3. 复制粘贴，去掉无用注释、略加修改
4. 放进自己的 util 目录

一套操作下来十几分钟就过去了，而这段代码和业务完全无关，直接耽误项目开发时间。写过的项目多了，日积月累才可能攒出自己的一套工具类库——代价很高。

## 二、Hutool 是什么

**Hutool 是一个开源的 Java 工具包类库**，对文件、流、加密解密、转码、正则、线程、XML 等 JDK 方法进行封装，组成各种 Util 工具类。

- 官网：https://hutool.cn/
- 文档：https://hutool.cn/docs/
- GitHub：https://github.com/looly/hutool

## 三、为什么用它

- **JDK 自带的工具类不够丰富**：Java 语言虽然自带了不少工具类，但相对 Scala 等语言来说封装程度远远不够
- **知名的 guava、apache-commons 种类还不够多**：这些库实现优秀，但作为工具类库工具种类仍偏少，通常还要搭配其他第三方库（比如操作 Excel 的 POI）一起用
- **小而全**：Hutool 基本可以覆盖日常业务诉求，静态方法封装能降低 API 学习成本，让 Java 拥有函数式语言般的优雅
- **自己封装成本高且容易出错**：自研虽然可行，但耗时长、性能未必好，还可能踩坑（比如资源忘记 `close` 导致泄露）
- **经过真实检验**：工具方法由社区开发者共同打磨，并经过大量企业真实项目验证，既是大型项目解决小问题的利器，也是小型项目的效率担当

> 名字来源：Hutool 谐音「糊涂」，寓意追求「万事都作糊涂观，无所谓失，无所谓得」的境界。

## 四、如何引入

用法简单且对业务无任何侵入，可以通过包管理工具引入，也可以直接把源码复制到项目中。

**Maven（pom.xml 的 dependencies）：**

```xml
<dependency>
  <groupId>cn.hutool</groupId>
  <artifactId>hutool-all</artifactId>
  <version>5.4.4</version>
</dependency>
```

> 上面的版本号是示例，实际使用请以官网最新稳定版为准。

**Gradle（build.gradle）：**

```groovy
compile 'cn.hutool:hutool-all:5.4.4'
```

## 五、常用工具与模块

### 提升效率的典型示例

Hutool 的目标是「用一个工具方法代替一段复杂代码」，以发送邮件为例：

- 以前：打开搜索引擎 → 搜「Java 如何发送邮件」→ 打开几篇博客 → 挑一个看似优秀的实现 → 复制粘贴 → 改改就用
- 现在：引入 Hutool → 直接调用 `MailUtil.sendText`

### 常用工具类

| 工具 | 说明 |
|------|------|
| `DateUtil` | 高度便捷的日期访问、处理和转换 |
| `HttpUtil` | 对 HTTP 客户端的封装，便捷发送请求并简化文件上传 |
| `Convert` | 一整套类型转换方案，可通过 `ConverterRegistry` 工厂类自定义转换 |
| `Setting` | 兼容 Properties 文件但更强大的配置工具，解决中文、分组等 JDK 配置文件的问题 |

### 模块清单

| 模块 | 介绍 |
|------|------|
| hutool-aop | JDK 动态代理封装，提供非 IOC 下的切面支持 |
| hutool-bloomFilter | 布隆过滤，提供一些 Hash 算法的布隆过滤 |
| hutool-cache | 简单缓存实现 |
| hutool-core | 核心，包括 Bean 操作、日期、各种 Util 等 |
| hutool-cron | 定时任务模块，提供类 Crontab 表达式的定时任务 |
| hutool-crypto | 加密解密模块，提供对称、非对称和摘要算法封装 |
| hutool-db | JDBC 封装后的数据操作，基于 ActiveRecord 思想 |
| hutool-dfa | 基于 DFA 模型的多关键字查找 |
| hutool-extra | 扩展模块，对第三方封装（模板引擎、邮件、Servlet、二维码、Emoji、FTP、分词等） |
| hutool-http | 基于 HttpUrlConnection 的 Http 客户端封装 |
| hutool-log | 自动识别日志实现的日志门面 |
| hutool-script | 脚本执行封装，例如 Javascript |
| hutool-setting | 功能更强大的 Setting 配置文件和 Properties 封装 |
| hutool-system | 系统参数调用封装（JVM 信息等） |
| hutool-json | JSON 实现 |
| hutool-captcha | 图片验证码实现 |
| hutool-poi | 针对 POI 中 Excel 和 Word 的封装 |
| hutool-socket | 基于 Java 的 NIO 和 AIO 的 Socket 封装 |

可以按需单独引入某个模块，也可以通过 `hutool-all` 一次性引入全部模块。

## 六、使用建议

**不要仅仅把 Hutool 当作一个工具去使用，用久了会把人用傻。** 有时间应该阅读 Hutool 的源码，学习各种工具类的优秀实现，培养自己的代码能力。

Hutool 的源码并不难，就是通过大量静态方法来方便调用，比如手机号工具类：

```java
/**
 * 手机号工具类
 */
public class PhoneUtil {
    /**
     * 座机号码
     */
    private static final Pattern TEL =
        Pattern.compile("0\\d{2,3}-[1-9]\\d{6,7}");

    /**
     * 验证是否为手机号码（中国）
     *
     * @param value 值
     * @return 是否为手机号码（中国）
     */
    public static boolean isMobile(CharSequence value) {
        return Validator.isMatchRegex(PatternPool.MOBILE, value);
    }
    // ...
}
```

## 相关文档

- Hutool 在项目中的实际用法见 [[Java 37 - 基于 Redis 的短信登录实现]]（`BeanUtil.copyProperties` 属性拷贝、`BeanUtil.beanToMap` 对象转 Map）
- 对象属性拷贝的其他方案见 [[Java 工具 02 - Bean 拷贝之 MapStruct]]
- Java 工具集清单见 [[Java 01 - 学习路线]]

> 来源：鱼皮·编程导航 / codefather
