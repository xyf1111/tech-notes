---
title: Java 36 - 单元测试编写指南
date: 2026-07-29
tags: [java, testing, junit, unit-test]
source: '鱼皮·编程导航 / codefather'
---

# Java 36 - 单元测试编写指南

保证程序的正常运行、提高程序的稳定性和质量是程序员的核心工作。单元测试是其中关键的一环，本文以 Java 为例，介绍如何编写单元测试。

## 什么是单元测试？

单元测试（Unit Testing，简称 UT）是软件测试的一种，通常由开发者编写测试代码并运行。它关注软件的 **最小** 可测试单元。

例如实现用户注册功能可能包含多个子步骤：
1. 校验用户输入是否合法
2. 校验用户是否已注册
3. 向数据库中添加新用户

每个子步骤都是一个小方法。单元测试就是要针对每个小方法分别测试，验证其在成功和失败时的表现是否符合预期。

**单元测试的核心要点：**

1. **最小化测试范围**：只测试代码的一个非常小的部分，确保简单和准确
2. **自动化**：开发人员可以随时运行它们来验证代码的正确性
3. **快速执行**：执行时间不能过长，轻量、有利于频繁执行
4. **独立性**：每个测试独立于其他测试，不依赖外部系统或状态

## 为什么需要单元测试？

- **改进代码**：编写测试过程中能再次审视业务流程，发现代码问题，推动模块进一步拆解
- **利于重构**：修改或重构代码后自动执行单元测试，快速验证修改是否正确，大幅提高效率和稳定性
- **文档沉淀**：详细的单元测试本身就是一种文档，说明代码的预期行为

> **真实案例**：作者曾开发 SQL 语法解析模块，需将 10000 多条链式调用语法转换为标准 SQL。由于细节多，每次改进算法后总会人工发现几个转换错误，于是编写单元测试自动验证解析是否正确，改完代码执行一遍即可确认是否完全成功，大幅提高效率。

## 如何编写单元测试？

以 Java 开发为例，最流行的单元测试框架是 JUnit。

### 1. 引入 JUnit

#### Maven 项目

在 `pom.xml` 中引入 JUnit 4 依赖：

```xml
<dependency>
    <groupId>junit</groupId>
    <artifactId>junit</artifactId>
    <version>4.13.2</version>
    <scope>test</scope>
</dependency>
```

#### Spring Boot 项目

直接引入 `spring-boot-starter-test`：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

该 starter 会自动引入 JUnit Jupiter（JUnit 5 的一部分），提供了更灵活易用的编写和执行测试方式。

### 2. 编写单元测试

编写单元测试通常包括三个步骤：**准备测试数据 → 执行要测试的代码 → 验证结果**。一般每个类对应一个测试类，每个方法对应一个测试方法。

#### JUnit 单元测试示例

测试一个计算器的求和功能：

```java
import org.junit.Test;
import org.junit.Assert;

public class CalculatorTest {

    @Test
    public void testAdd() {
        // 准备测试数据
        long a = 2;
        long b = 3;
        // 执行要测试的代码
        Calculator calculator = new Calculator();
        int result = calculator.add(2, 3);
        // 验证结果
        Assert.assertEquals(5, result);
    }
}
```

`Assert` 类提供了多种断言方法：`assertEquals`（是否相等）、`assertNull`（是否为空）等，用于对比实际输出和预期值。

#### Spring Boot 项目单测

测试 Mapper 和 Service Bean 时，使用 `@SpringBootTest` 注解开启依赖注入支持。

以用户注册功能为例：

```java
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import javax.annotation.Resource;

@SpringBootTest
public class UserServiceTest {

    @Resource
    private UserService userService;

    @Test
    void userRegister() {
        // 准备数据
        String userAccount = "yupi";
        String userPassword = "";
        String checkPassword = "123456";
        // 执行测试
        long result = userService.userRegister(userAccount, userPassword, checkPassword);
        // 验证结果
        Assertions.assertEquals(-1, result);
        // 再准备一组数据，重复测试流程
        userAccount = "yu";
        result = userService.userRegister(userAccount, userPassword, checkPassword);
        Assertions.assertEquals(-1, result);
    }
}
```

### 3. 生成测试报告

当单元测试数量很多时（如 1000 个），需要全面的测试报告来查看覆盖度、评估效果和定位问题。

**测试覆盖度**：衡量测试过程中被测试到的代码量的指标，一般情况下越高越好。100% 覆盖度表示所有方法和关键语句都被测试到。

#### 方式一：IDEA Run with Coverage

在 IDEA 中右键选择 `Run xxx with Coverage` 执行测试类，即可在内嵌窗口中看到覆盖度报告。也可以导出为 HTML 文档，打开 `index.html` 在浏览器中查看详细报告。这种方式简单灵活，适合日常学习使用。

#### 方式二：JaCoCo Maven 插件

JaCoCo 是一个常用的 Java 代码覆盖度工具，能自动生成详细的单测报告。

在 `pom.xml` 中引入插件并配置执行：

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <configuration>
        <includes>
            <include>com/**/*</include>
        </includes>
    </configuration>
    <executions>
        <execution>
            <id>pre-test</id>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>post-test</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

执行 Maven 的 `test` 命令后，在 `target` 目录中生成 JaCoCo 测试报告网站，打开 `index.html` 即可查看详细结果。这种方式适用于企业配置流水线自动化生成测试报告的场景。

## 单元测试 vs 集成测试

单元测试侧重小的代码单元（通常是单个方法或代码行，比如一次增删改查），仅检查方法的本地执行，不建议用于外部和远程资源，常用工具有 JUnit。

集成测试则是在模块之间的交互上下文中更完整地检查软件是否正常工作。这种测试方法长期未得到足够重视，但随着 Testcontainers 等技术的出现（用真实的数据库、容器、消息队列作为测试依赖），集成测试会越来越流行。

| 对比项 | 单元测试 | 集成测试 |
| --- | --- | --- |
| 测试对象 | 小的代码单元（单个方法 / 代码行） | 模块之间的交互上下文 |
| 外部与远程资源 | 不建议使用 | 可使用（数据库、容器、队列等） |
| 常用工具 | JUnit | Testcontainers 等 |

两者互补：单元测试保证代码单元的正确性，集成测试保证模块组装后整体可用，企业项目通常两者都要写。
