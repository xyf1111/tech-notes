---
title: "Java 工具 - Maven 中央仓库发包流程"
date: 2026-07-22
tags: [Java, Maven, 构建工具]
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 - Maven 中央仓库发包流程

> 将 Java 开源项目发布到 Maven Central Repository（Maven 中央仓库）的完整流程，包含 Jira 申请、GPG 签名、Maven 配置、上传发布。

## 核心要点

### 整体流程

1. 注册 Jira 账号并创建 Issue 申请 Group Id
2. 完成域名所有权验证（DNS 记录或 GitHub 仓库）
3. 配置 GPG 密钥签名
4. 配置 Maven `settings.xml` 和项目的 `pom.xml`
5. 执行上传并验证发布结果

### 1. Jira 申请 Group Id

在 [Sonatype Jira](https://issues.sonatype.org) 新建 Issue（类型选择 `New Project`）：

- **Group Id**：填写域名（如 `io.github.用户名`）— 后续需验证所有权
- **Project URL / SCM URL**：填写 GitHub 仓库地址
- **Username(s)**：授权可发包的 Jira 用户

审核通常 5-10 分钟完成，机器人会自动回复验证要求。

### 2. 域名所有权验证

- **域名方式**：为域名添加一条 DNS TXT 记录
- **GitHub 方式**：创建一个指定名称的公开仓库

验证通过后，Issue 状态变为已解决，标识该 Group Id 已授权。

### 3. GPG 密钥配置

```bash
# 生成密钥对
gpg --gen-key

# 查看已生成的密钥
gpg --list-keys

# 将公钥上传到服务器
gpg --keyserver keyserver.ubuntu.com --send-keys <公钥>
```

> 生成时会要求输入私钥密码，务必保存。

### 4. Maven 配置

**`settings.xml`** — 在 `<servers>` 中添加：

```xml
<server>
  <id>ossrh</id>
  <username>jira 账号</username>
  <password>jira 密码</password>
</server>
```

**`pom.xml`** — 关键配置项：

```xml
<!-- GAV 坐标：groupId 必须与 Jira 申请的 Group Id 一致 -->
<groupId>...</groupId>
<artifactId>...</artifactId>
<version>...</version>

<!-- 分发管理 -->
<distributionManagement>
    <snapshotRepository>
        <id>ossrh</id>
        <url>https://s01.oss.sonatype.org/content/repositories/snapshots</url>
    </snapshotRepository>
    <repository>
        <id>ossrh</id>
        <url>https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/</url>
    </repository>
</distributionManagement>
```

**关键插件：**

| 插件 | 作用 |
|---|---|
| `nexus-staging-maven-plugin` | 自动 Stage 发布到 Sonatype |
| `maven-source-plugin` | 打包源码 |
| `maven-gpg-plugin` | 对制品进行 GPG 签名 |
| `maven-javadoc-plugin` | 生成 Javadoc 包 |

推荐配置（`autoReleaseAfterClose=true` 自动发布）：

```xml
<plugin>
    <groupId>org.sonatype.plugins</groupId>
    <artifactId>nexus-staging-maven-plugin</artifactId>
    <version>1.6.7</version>
    <extensions>true</extensions>
    <configuration>
        <serverId>ossrh</serverId>
        <nexusUrl>https://s01.oss.sonatype.org/</nexusUrl>
        <autoReleaseAfterClose>true</autoReleaseAfterClose>
    </configuration>
</plugin>
```

### 5. 执行上传

```bash
mvn clean deploy
```

构建成功后登录 [Sonatype Staging](https://s01.oss.sonatype.org) 查看 Stage 状态。

### 6. 验证发布

- Maven 中央仓库搜索 [search.maven.org](https://search.maven.org)：半小时内可查到
- [mvnrepository.com](https://mvnrepository.com)：同步需约 4-7 小时

> **同步时间**：官方称 4 小时，实际测试约 7 小时。在其他第三方仓库（如 mvnrepository.com）的同步会有额外延迟。

> 来源：鱼皮·编程导航 / codefather
