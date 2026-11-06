---
title: "Java 工具 07 - Picocli 命令行开发"
date: 2026-07-28
tags: [java, picocli, 命令行, cli, springboot]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 07 - Picocli 命令行开发

> Picocli 是 Java 中最完善、最简单易用的命令行开发框架，通过注解驱动的方式快速构建 CLI 应用，支持子命令、交互式输入、自动生成帮助手册等功能。

## 核心内容

### 入门 Demo

#### 1. 引入依赖

```xml
<dependency>
    <groupId>info.picocli</groupId>
    <artifactId>picocli</artifactId>
    <version>4.7.5</version>
</dependency>
```

#### 2. 编写命令类

```java
package com.example.cli;

import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;
import picocli.CommandLine.Parameters;

@Command(name = "ASCIIArt", version = "ASCIIArt 1.0", mixinStandardHelpOptions = true)
public class ASCIIArt implements Runnable {

    @Option(names = { "-s", "--font-size" }, description = "Font size")
    int fontSize = 19;

    @Parameters(paramLabel = "<word>", defaultValue = "Hello, picocli",
               description = "Words to be translated into ASCII art.")
    private String[] words = { "Hello,", "picocli" };

    @Override
    public void run() {
        System.out.println("fontSize = " + fontSize);
        System.out.println("words = " + String.join(",", words));
    }

    public static void main(String[] args) {
        int exitCode = new CommandLine(new ASCIIArt()).execute(args);
        System.exit(exitCode);
    }
}
```

#### 3. 核心概念说明

| 元素 | 说明 |
|------|------|
| `@Command` | 标记类为命令，`name` 指定命令名，`mixinStandardHelpOptions = true` 自动添加 `--help` 和 `--version` |
| `@Option` | 将字段声明为命令行选项（如 `-s`、`--font-size`） |
| `@Parameters` | 将字段声明为命令行参数（非选项式的位置参数） |
| `Runnable` / `Callable` | 命令类需实现二者之一，`run()` 或 `call()` 在命令解析成功后执行 |
| `CommandLine.execute()` | 解析用户输入并执行业务逻辑，返回退出码 |

#### 4. 命令开发流程

1. 创建命令类
2. 设置选项（`@Option`）和参数（`@Parameters`）
3. 编写业务逻辑（`run` / `call` 方法）
4. 通过 `CommandLine` 对象接受输入并执行命令

---

### 帮助手册

通过 `@Command(mixinStandardHelpOptions = true)` 开启，运行 `--help` 即可自动生成规范清晰的帮助手册，包括命令名、选项、参数说明等信息。

---

### 命令解析

Picocli 最核心的能力：从完整命令行中解析选项和参数，注入到注解字段中，类型自动转换。

#### @Option 注解

```java
@Option(names = { "-s", "--font-size" }, description = "Font size")
int fontSize = 19;
```

#### @Parameters 注解

```java
@Parameters(paramLabel = "<word>", defaultValue = "Hello, picocli",
           description = "Words to be translated into ASCII art.")
private String[] words = { "Hello,", "picocli" };
```

#### 常用参数

| 参数 | 说明 | 适用注解 |
|------|------|----------|
| `names` | 选项名称（如 `{"-s", "--font-size"}`） | `@Option` |
| `description` | 描述信息，显示在帮助手册中 | 两者 |
| `paramLabel` | 参数标签，类似描述信息 | `@Parameters` |
| `defaultValue` | 默认值 | `@Parameters` |
| `required` | 是否必填 | 两者 |
| `arity` | 可接受参数个数（如 `"0..1"`） | `@Option` |

#### 必填选项

```java
class RequiredOption {
    @Option(names = "-a", required = true)
    String author;
}
```

#### 多值选项

将字段类型设为数组即可接收多个值：

```java
@Option(names = "-option")
int[] values;
```

官方文档：[Options and Parameters](https://picocli.info/quick-guide.html#_options_and_parameters)、[Multiple Values](https://picocli.info/#_multiple_values)、[Required Arguments](https://picocli.info/#_required_arguments)

---

### 交互式输入

Picocli 支持引导用户逐个输入参数，共有 4 种模式。

#### 1. 基本交互式

设置 `@Option(interactive = true)`，命令类需实现 `Callable` 接口：

```java
public class Login implements Callable<Integer> {
    @Option(names = {"-u", "--user"}, description = "User name")
    String user;

    @Option(names = {"-p", "--password"}, description = "Passphrase", interactive = true)
    String password;

    public Integer call() throws Exception {
        System.out.println("password = " + password);
        return 0;
    }

    public static void main(String[] args) {
        new CommandLine(new Login()).execute("-u", "user123", "-p");
    }
}
```

注意：用户必须在命令中指定交互式选项（如 `-p`），才会触发提示输入。从 Picocli 4.6 起可通过 `@Option(echo = true)` 显示输入内容，`prompt` 参数自定义提示语。

#### 2. 多个选项交互式

支持在一个命令中指定多个交互式选项，按顺序提示输入：

```java
@Option(names = {"-p", "--password"}, description = "Passphrase", interactive = true)
String password;

@Option(names = {"-cp", "--checkPassword"}, description = "Check Password", interactive = true)
String checkPassword;
```

执行时需在命令中指定所有交互式选项：

```java
new CommandLine(new Login()).execute("-u", "user123", "-p", "-cp");
```

#### 3. 可选交互式

默认交互式选项不能在命令中直接赋值（`-p xxx` 会报错）。通过设置 `arity = "0..1"` 支持两种方式——既可在完整命令中直接传值，也可省略值触发交互式输入：

```java
@Option(names = {"-p", "--password"}, arity = "0..1", description = "Passphrase", interactive = true)
String password;
```

直接传值（不触发交互式）：

```java
new CommandLine(new Login()).execute("-u", "user123", "-p", "123", "-cp", "456");
```

> **最佳实践**：建议给所有需要交互式输入的选项都设置 `arity = "0..1"`，让用户自由选择输入方式。

官方文档：[Optionally Interactive](https://picocli.info/#_optionally_interactive)、[Arity](https://picocli.info/#_arity)

#### 4. 强制交互式

如果用户未在命令中指定某个交互式选项（如省略 `-p`），不会自动提示输入，属性值为默认值（null）。需要强制用户输入时，可编写校验逻辑：

```java
@Command
public class Main implements Runnable {
    @Option(names = "--interactive", interactive = true)
    String value;

    public void run() {
        if (value == null && System.console() != null) {
            value = System.console().readLine("Enter value for --interactive: ");
        }
        System.out.println("You provided value '" + value + "'");
    }

    public static void main(String[] args) {
        new CommandLine(new Main()).execute(args);
    }
}
```

另一种思路：通过自动检测 args 数组中是否包含交互式选项，若缺失则自动补充该选项元素，从而强制触发 Picocli 的交互式输入机制。

官方文档：[Forcing Interactive Input](https://picocli.info/#_forcing_interactive_input)

---

### 子命令

适用于功能较多、较复杂的 CLI 程序（如 git、docker）。支持两种注册方式。

#### 1. 声明式

通过 `@Command(subcommands = { ... })` 注册：

```java
@Command(subcommands = {
    GitStatus.class,
    GitCommit.class,
    GitAdd.class,
    GitBranch.class,
    GitCheckout.class,
    GitClone.class,
    GitDiff.class,
    GitMerge.class,
    GitPush.class,
    GitRebase.class,
    GitTag.class
})
public class Git { /* ... */ }
```

#### 2. 编程式

通过 `addSubcommand` 方法动态绑定，更灵活：

```java
CommandLine commandLine = new CommandLine(new Git())
        .addSubcommand("status",   new GitStatus())
        .addSubcommand("commit",   new GitCommit())
        .addSubcommand("add",      new GitAdd())
        .addSubcommand("branch",   new GitBranch())
        .addSubcommand("checkout", new GitCheckout())
        .addSubcommand("clone",    new GitClone())
        .addSubcommand("diff",     new GitDiff())
        .addSubcommand("merge",    new GitMerge())
        .addSubcommand("push",     new GitPush())
        .addSubcommand("rebase",   new GitRebase())
        .addSubcommand("tag",      new GitTag());
```

#### 实践示例

支持 `add`、`delete`、`query` 三个子命令：

```java
@Command(name = "main", mixinStandardHelpOptions = true)
public class SubCommandExample implements Runnable {

    @Override
    public void run() {
        System.out.println("执行主命令");
    }

    @Command(name = "add", description = "增加", mixinStandardHelpOptions = true)
    static class AddCommand implements Runnable {
        public void run() {
            System.out.println("执行增加命令");
        }
    }

    @Command(name = "delete", description = "删除", mixinStandardHelpOptions = true)
    static class DeleteCommand implements Runnable {
        public void run() {
            System.out.println("执行删除命令");
        }
    }

    @Command(name = "query", description = "查询", mixinStandardHelpOptions = true)
    static class QueryCommand implements Runnable {
        public void run() {
            System.out.println("执行查询命令");
        }
    }

    public static void main(String[] args) {
        String[] myArgs = new String[] { };
        int exitCode = new CommandLine(new SubCommandExample())
                .addSubcommand(new AddCommand())
                .addSubcommand(new DeleteCommand())
                .addSubcommand(new QueryCommand())
                .execute(myArgs);
        System.exit(exitCode);
    }
}
```

使用 `--help` 可查看主命令及所有子命令信息；传入子命令名（如 `add`）执行对应子命令。

官方文档：[Subcommands](https://picocli.info/#_subcommands)

---

### 其他功能（参考）

| 功能 | 文档 |
|------|------|
| 参数分组 | https://picocli.info/#_argument_groups |
| 错误处理 | https://picocli.info/#_handling_errors |
| ANSI 颜色高亮 | https://picocli.info/#_ansi_colors_and_styles |

---

## 学习资源

- 官方文档：https://picocli.info/
- 快速入门：https://picocli.info/quick-guide.html
- Picocli 中文入门：https://blog.csdn.net/it_freshman/article/details/125458116

> 来源：鱼皮·编程导航 / codefather
