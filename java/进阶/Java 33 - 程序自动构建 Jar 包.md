---
title: "Java 进阶 - 程序自动构建 Jar 包"
date: 2026-07-27
tags: [Java, Maven, 自动化构建, ProcessBuilder]
source: "鱼皮·编程导航 / codefather"
---

## 概述

手动执行 Maven 命令构建 jar 包适用于开发阶段，但在自动化构建和部署场景中，需要让程序代替人工完成打包操作。本文以 Java 语言为例，利用 `ProcessBuilder` + `Process` 类执行 Maven 命令，实现 jar 包的自动构建。

## 前置条件

1. 本地或服务器已安装 Maven 并配置好环境变量
2. 终端执行 `mvn -v` 确认安装成功（示例环境为 Maven 3.9.5）
3. 目标项目根目录下存在有效的 `pom.xml` 文件

## 实现思路

程序自动构建的本质是让代码代替人工执行 Maven 打包命令。使用 Java 内置的 `ProcessBuilder` 启动一个子进程来运行 Maven 命令，并通过 `Process` 对象读取命令的输出流，获取构建过程的实时信息。

## 代码实现

### JarGenerator 类

关键点：
- 使用 `ProcessBuilder` 执行 Maven 打包命令
- 通过 `BufferedReader` 读取命令输出流，实时打印日志
- 使用 `process.waitFor()` 等待命令执行完成，获取退出码判断成功/失败
- **不同操作系统命令不同**：Windows 用 `mvn.cmd`，Linux/macOS 用 `mvn`

完整代码：

```java
package com.yupi.maker.generator;

import java.io.*;

public class JarGenerator {

    public static void doGenerate(String projectDir) throws IOException, InterruptedException {
        // 清理之前的构建并打包
        // 注意不同操作系统，执行的命令不同
        String winMavenCommand = "mvn.cmd clean package -DskipTests=true";
        String otherMavenCommand = "mvn clean package -DskipTests=true";
        String mavenCommand = winMavenCommand;
        
        // 这里一定要拆分！
        ProcessBuilder processBuilder = new ProcessBuilder(mavenCommand.split(" "));
        processBuilder.directory(new File(projectDir));

        Process process = processBuilder.start();

        // 读取命令的输出
        InputStream inputStream = process.getInputStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        String line;
        while ((line = reader.readLine()) != null) {
            System.out.println(line);
        }

        // 等待命令执行完成
        int exitCode = process.waitFor();
        System.out.println("命令执行结束，退出码：" + exitCode);
    }

    public static void main(String[] args) throws IOException, InterruptedException {
        doGenerate("C:\\code\\yuzi-generator\\yuzi-generator-maker\\generated\\acm-template-pro-generator");
    }
}
```

> 注意：`main` 方法中的路径需替换为本地实际项目路径。

### 跨平台命令处理说明

代码中通过变量 `winMavenCommand`（`mvn.cmd`）和 `otherMavenCommand`（`mvn`）区分操作系统。生产环境中可通过 `System.getProperty("os.name")` 动态判断，或统一在环境变量中配置别名来简化。

### ProcessBuilder 使用要点

- `ProcessBuilder` 构造方法接收命令+参数的**拆分数组**（如 `["mvn", "clean", "package"]`），而非整个命令字符串
- 通过 `directory(File)` 设置命令执行的**工作目录**（即项目根目录）
- 输出流必须被读取，否则子进程可能在缓冲区满时阻塞

## Maven Assembly 插件配置

要在 `pom.xml` 中配置 `maven-assembly-plugin` 插件，才能将项目及其依赖一起打包为可执行的 fat jar。`mainClass` 需要替换为项目实际的主类路径。

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-assembly-plugin</artifactId>
            <version>3.3.0</version>
            <configuration>
                <descriptorRefs>
                    <descriptorRef>jar-with-dependencies</descriptorRef>
                </descriptorRefs>
                <archive>
                    <manifest>
                        <mainClass>${basePackage}.Main</mainClass> <!-- 替换为你的主类的完整类名 -->
                    </manifest>
                </archive>
            </configuration>
            <executions>
                <execution>
                    <phase>package</phase>
                    <goals>
                        <goal>single</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

## 完整调用示例

构建 jar 包的调用方式：

```java
public class MainGenerator {

    public static void main(String[] args) throws IOException, InterruptedException {
        String outputPath = "项目代码根路径";
        // 构建 jar 包
        JarGenerator.doGenerate(outputPath);
    }
}
```

## 注意事项

- **首次构建较慢**：首次执行时需要从 Maven 中央仓库拉取依赖，耗时较长
- **退出码检查**：`exitCode == 0` 表示构建成功，非零值表示出错
- **路径不存在**：确保传入的 `projectDir` 是有效的 Maven 项目根目录（包含 `pom.xml`）
- **跳过测试**：命令中使用了 `-DskipTests=true`，如需执行测试可移除该参数
