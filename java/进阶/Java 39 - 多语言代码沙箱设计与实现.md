---
title: Java 进阶 - 多语言代码沙箱设计与实现
date: 2026-07-29
tags:
  - java
  - 在线判题
  - 代码沙箱
  - docker
  - 安全
  - 系统设计
  - 进阶
source: "鱼皮·编程导航 / codefather"
---

# 多语言代码沙箱设计与实现

> OJ 系统中核心模块，负责执行用户提交的代码并返回执行结果。本文设计方案**将代码保存、编译、运行全流程放入 Docker 容器**，实现安全与简洁兼顾。

## 核心难点

代码沙箱需要解决 **4 个关键问题**：

1. **代码运行 + 结果保存** — 如何运行用户代码并捕获输出
2. **环境隔离** — 防止恶意代码影响宿主机
3. **内存统计** — 精确/近似地度量程序内存消耗
4. **耗时统计** — 精确度量程序运行时间

## 代码运行与结果保存

### Java 流程

1. 将代码字符串写入 `.java` 文件
2. 执行 `javac` 编译得到 `.class` 文件
3. 执行 `java` 运行编译后的字节码
4. 捕获 stdout/stderr 作为运行结果
5. 保存并返回结果
6. 删除临时文件（即用即删）

### Python3 流程

Python 无需编译步骤，保存 `.py` 文件后直接通过 `python3` 命令运行，其余步骤同上。

## 环境隔离方案

### 两种候选方案对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| Java 原生实现 | 简单、同步响应快 | 不够安全，恶意代码可直接操作宿主机 |
| Java + Docker（仅运行阶段） | 安全隔离性好 | 响应有额外延迟，方案不够统一 |

### 最终方案：全流程 Docker 化

**思路**：不只是在 Docker 中运行代码，而是将代码保存、编译、运行 **整个流程全部放在 Docker 容器内** 完成。

**实现方式**：
1. 将 Java 原生代码沙箱项目打包成 JAR
2. 编写 Dockerfile，基于 `openjdk:8-jdk` 镜像，额外安装 Python3
3. 构建 Docker 镜像，将 JAR 包内置到镜像中
4. 运行容器，对外暴露 API

**优点**：
- 综合了原生实现的简洁性和 Docker 的安全性
- 环境完全隔离，危险代码无法影响宿主机
- 执行过程稳定

**缺点**：
- 需要额外 Docker 配置和维护
- 容器被危险代码破坏后，除告警外仍需人工介入

## 安全防护体系（4 层防御）

| 层级 | 措施 | 说明 |
|------|------|------|
| **第 1 层** | 黑名单代码检测 | 针对各语言预置危险关键词黑名单，提交代码先过正则/字符串匹配，命中即拦截。跨平台通用。 |
| **第 2 层** | Java SecurityManager | 限制代码行为权限（文件读写、危险脚本、网络连接等）。**仅支持 Windows**。 |
| **第 3 层** | JVM 内存限制 | `java -Xmx128m` 限制 JVM 最大堆内存，跨平台通用。 |
| **第 4 层** | Docker 容器隔离 | 最终防线：即使前面三层被绕过，Docker 容器也限制了攻击半径。 |

### 各语言安全策略差异

- **Java**：黑名单 + SecurityManager + JVM 限制 + Docker，最完善
- **Python3**：仅黑名单 + Docker；Python 暂无成熟的 SecurityManager 替代品

### Python 内存限制

Windows 下使用 `resource` 库不可用，因此建议最终部署在 Linux 上：

```python
import resource
max_memory = 128
resource.setrlimit(resource.RLIMIT_AS, (max_memory * (1024 ** 2), -1))
```

## 超时限制

通过 **多线程监控 + 进程控制** 实现：
- 主线程启动子进程执行用户代码
- 监控线程计时，超过设定阈值后强制终止子进程
- 避免用户提交死循环或长时间运行代码阻塞系统

## 内存统计

使用 JVM `Runtime` API 做近似统计（不够精确，仅作参考）：

```java
public static long getUsedMemory() {
    Runtime runtime = Runtime.getRuntime();
    return runtime.totalMemory() - runtime.freeMemory();
}

long initialMemory = getUsedMemory();
// ... 执行用户代码 ...
long finalMemory = getUsedMemory();
long memoryUsage = finalMemory - initialMemory; // 单位：bytes
```

## 耗时统计

使用 Spring 的 `StopWatch`：

```java
StopWatch stopWatch = new StopWatch();
stopWatch.start();
// ... 执行用户代码 ...
stopWatch.stop();
executeMessage.setTime(stopWatch.getLastTaskTimeMillis());
```

## Docker 部署

### Dockerfile 配置

```dockerfile
FROM openjdk:8-jdk

# 安装 Python3
RUN apt-get update && apt-get install -y python3

ARG VERSION=""
ENV JAVA_OPTS=""
ENV PARAMS=""

# 时区设置
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone

ADD ./sspuoj-code-sandbox-0.0.1-SNAPSHOT.jar /app.jar

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS $PARAMS -jar /app.jar $PARAMS"]
```

### 构建与运行

```bash
# 构建镜像
docker build -t sspuoj:codesandbox .

# 运行容器（映射 8090 端口，后台守护）
docker run -p 8090:8090 -d --name sspuoj-codesandbox-01 sspuoj:codesandbox

# 查看日志
docker logs -f sspuoj-codesandbox-01

# 清理
docker rm -f sspuoj-codesandbox-01
docker rmi -f sspuoj:codesandbox
```

### 跨平台支持

- **Java** 方案（Xmx 参数 + 黑名单检测）在 Windows 和 Linux 均可运行
- **Docker** 部署目标为 Linux 服务器
- **SecurityManager** 目前仅支持 Windows，建议 Linux 场景依赖 Docker 隔离

## 功能特性总结

| 功能 | 支持情况 |
|------|----------|
| 语言支持 | Java、Python3 |
| 系统兼容 | Windows + Linux |
| 环境隔离 | Docker 容器全流程 |
| 超时限制 | 多线程监控 + 进程控制 |
| 安全检测 | 黑名单 + SecurityManager + Docker + JVM 限制 |
| 内存统计 | Runtime API 近似统计 |
| 耗时统计 | StopWatch |

---

## 附：OJ 判题系统的实现方案（为什么自研沙箱）

> 动手做 OJ 前先选实现路线，核心原则是 **能用别人现成的，就不要自己写**——判题要支持多语言且安全隔离，自研成本高。主流有 5 种方案：

| 方案 | 做法 | 适用 |
|------|------|------|
| 1. 用现成开源 OJ | 直接下载部署开源项目（青岛 OJ、HustOJ），或成熟商业项目 **judge0**（支持 60+ 种语言，免费自部署 / 公有云 / 私有云，https://github.com/judge0/judge0） | 想要完整 OJ 系统 |
| 2. 用现成判题服务 | 只复用最难的判题逻辑：调用 judge0 CE 判题 API（RapidAPI），HTTP 请求 `submissions` 接口，传用户代码 + 输入值 + 预期结果，服务端自动编译执行并返回运行时间、状态 | 不想部署整套代码 |
| 3. 自主开发 | 判题服务与代码沙箱全部自研，本文的 Docker 沙箱即该路线的核心模块 | 适合学习，不适合商业项目 |
| 4. 用 AI 当代码沙箱 | 把代码 + 输入参数直接丢给 AI，问它能否得到预期结果，即实现在线判题逻辑 | 原型验证 |
| 5. 移花接木 | Puppeteer + 无头浏览器模拟用户：把代码像人一样输入到别人 OJ 网页、点提交，等对方返回判题结果再取回给自己用户 | 有创意但最不靠谱 |

- 方案 5 的缺点：核心流程依赖别人，对方服务挂了你的判题也挂；别人不支持的题型你也支持不了
- 本项目选择 **方案 3 自主开发**，主打学习；商业场景优先方案 1 / 2

> 延伸阅读：沙箱对象与判题流程上的设计模式见 [[概念 12 - 设计模式实战案例（OJ判题与聚合搜索）]]；提交后的排行榜设计见 [[Java 24 - OJ竞赛排行榜设计]]。

---

> **来源**：鱼皮·编程导航 (codefather) — 多语言代码沙箱的设计与实现(OJ 在线判题系统)，作者南侠。
