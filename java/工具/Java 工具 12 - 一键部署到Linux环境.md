---
title: "Java 工具 12 - 一键部署到Linux环境"
date: 2026-07-20
tags: [java, springboot, devops, deployment, linux]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 12 - 一键部署到Linux环境

> 在 IDEA 中一键将 SpringBoot 项目 jar 包部署到 Linux 环境，实现秒级部署。

## 基础部署流程

### 1. 本地构建可运行的 jar

使用 Maven 的 `package` 命令打出一个包含依赖的 jar 包：

```bash
mvn clean package
```

Window 下测试启动：

```bash
java -jar SpringBootTest-0.0.1-SNAPSHOT.jar
```

确认 jar 包可正常启动后再上传到 Linux 服务器。

### 2. Linux 环境启动

上传 jar 包到 Linux 服务器后，通过 Java 命令启动（需安装 JDK）：

```bash
java -jar SpringBootTest-0.0.1-SNAPSHOT.jar
```

直接运行会占用终端，关闭窗口后进程退出。

### 3. 后台启动脚本

使用 `nohup` 将项目转为后台运行，日志输出到文件：

```bash
nohup java -jar SpringBootTest-0.0.1-SNAPSHOT.jar > springboot.log 2>&1 &
```

参数说明：

| 参数 | 作用 |
|------|------|
| `nohup` | 后台运行，脱离终端会话 |
| `> springboot.log` | 标准输出重定向到日志文件 |
| `2>&1` | 标准错误也重定向到标准输出 |
| `&` | 放入后台执行 |

### 4. 完善的启停脚本

创建 `start.sh`，启动时自动关闭旧进程：

```bash
#!/bin/bash
# 关闭旧进程
fileName=SpringBootTest-0.0.1-SNAPSHOT.jar
pid=$(ps -ef | grep $fileName | grep -v "grep" | awk '{print $2}')
kill -9 $pid

# 启动项目
nohup java -jar $fileName > springboot.log 2>&1 &
```

使用方式：

```bash
sh start.sh
```

## 分离依赖部署

### 问题：jar 包体积过大

仅引入 Web 依赖时 jar 约 17MB；实际项目可达 100+ MB。其中 lib 目录（第三方依赖）占绝大部分。

### 方案：依赖放在服务器，只更新代码包

**步骤 1：上传依赖到服务器**

创建 `lib` 目录，将 jar 包中 `BOOT-INF/lib` 下的所有依赖上传到服务器的 `lib` 文件夹：

```bash
mkdir lib
```

**步骤 2：修改 pom.xml，打包时不包含依赖**

```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
                <mainClass>com.example.springboottest.SpringBootTestApplication</mainClass>
                <layout>ZIP</layout>
                <includes>
                    <include>
                        <groupId>nothing</groupId>
                        <artifactId>nothing</artifactId>
                    </include>
                </includes>
            </configuration>
            <executions>
                <execution>
                    <goals>
                        <goal>repackage</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

重新打包后，jar 包从 17MB 缩小到 ~156KB。

**步骤 3：指定外部依赖启动**

```bash
nohup java -jar -Dloader.path=./lib $fileName > springboot.log 2>&1 &
```

**步骤 4：智能启动脚本**

合并两种启动方式，根据 jar 包大小自动判断：

```bash
#!/bin/bash
fileName=SpringBootTest-0.0.1-SNAPSHOT.jar
pid=$(ps -ef | grep $fileName | grep -v "grep" | awk '{print $2}')
kill -9 $pid

filesize=$(ls -l $fileName | awk '{ print $5 }')
maxsize=$((1024 * 1024 * 10))  # 10MB 阈值

if [ $filesize -gt $maxsize ]; then
    echo "使用内部依赖启动"
    nohup java -jar $fileName > springboot.log 2>&1 &
else
    echo "使用外部依赖启动"
    nohup java -jar -Dloader.path=./lib $fileName > springboot.log 2>&1 &
fi
```

## 一键部署（Alibaba Cloud Toolkit）

### 安装插件

在 IDEA 插件市场搜索并安装 **Alibaba Cloud Toolkit**，重启 IDEA。

### 配置服务器地址

1. 点击右侧工具栏或 `Tools` → `Alibaba Cloud Toolkit` → `Deploy to Host`
2. 添加 Host：填写服务器 IP、用户名、密码/密钥

### 配置上传和部署

1. **上传文件**：选择本地 jar 包路径和目标服务器路径
2. **执行命令**：在文件上传后执行 `sh start.sh`（需先将 start.sh 脚本上传到服务器）

### 一键启动

点击 **Upload** 按钮，插件自动完成文件上传和脚本执行。

> 提示：该插件安装后会在 IDEA 侧边栏增加多个功能按钮，可移除无关项，只保留上传功能。

> 来源：鱼皮·编程导航 / codefather
