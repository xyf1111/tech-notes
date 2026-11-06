---
title: "DevOps 10 - 微服务项目部署实战（Docker Compose）"
date: 2026-09-02
tags: [DevOps, Docker Compose, 微服务, 部署]
source: "鱼皮·编程导航 / codefather"
---

# DevOps 10 - 微服务项目部署实战（Docker Compose）

> 以「Spring Cloud + Docker 代码沙箱在线判题系统」为例的保姆级微服务部署实战：先在本地用 Docker Compose 调通（梳理服务 → Maven 打包 → Dockerfile → 环境依赖配置 → 业务服务配置 → 改程序配置 → 测试访问），再原样搬到云服务器上线。核心思想：拆两套 compose 文件、先起环境依赖再起业务服务；容器之间用「服务名」互联，不能用 localhost。

## 背景：为什么用 Docker Compose

项目含 MySQL、Redis、RabbitMQ、Nacos 四个环境依赖 + 用户/题目/判题/Gateway 四个业务服务。传统单机部署的痛点：

1. 一个个手动安装依赖（MySQL/Redis/MQ/Nacos），非常麻烦
2. 一个个打 jar 包、手动 `java -jar` 运行，非常麻烦
3. 不方便集中观察所有服务的运行状态与资源占用

Docker Compose 是容器编排助手：**一个配置文件集中定义所有容器及其关系，一行命令启动全部容器**。

> 局限：Compose 适合把所有微服务部署在**同一台服务器**；企业级多服务器场景要用 K8S 等专业编排工具（见 [[Kubernetes 01 - 基础架构与核心概念]]）。Compose 基础语法见 [[Docker 04 - Docker Compose]]，不重复。

## 一、本地部署

### 1.1 梳理服务部署表格

先规划要部署的服务及关键信息（名称/端口/版本）。**类别划分决定启动顺序**：必须先启动「环境依赖」再启动「业务服务」，否则报"无法连接数据库"类错误。

| 服务名称 | 英文名 | 端口号 | 版本号 | 服务类别 |
| :--- | :--- | :--- | :--- | :--- |
| 数据库 | mysql | 3306 | v8 | 环境依赖 |
| 缓存 | redis | 6379 | v6 | 环境依赖 |
| 消息队列 | rabbitmq | 5672, 15672 | v3.12.6 | 环境依赖 |
| 注册中心 | nacos | 8848 | v2.2.0 | 环境依赖 |
| 网关服务 | gateway | 8101 | java 8 | 业务服务 |
| 用户服务 | yuoj-backend-user-service | 8102 | java 8 | 业务服务 |
| 题目服务 | yuoj-backend-question-service | 8103 | java 8 | 业务服务 |
| 判题服务 | yuoj-backend-judge-service | 8104 | java 8 | 业务服务 |

### 1.2 Maven 子父模块打包

微服务项目用 Maven 子父模块管理，配好后**根目录一键打包全部子服务**，不用逐个 `mvn package`。两个关键配置：

- **父模块 pom.xml**：引入 `spring-boot-maven-plugin`，但**一定不要配置 configuration 和 repackage**（父模块不产出可执行包）
- **每个可启动子模块**（4 个业务服务）pom.xml：给同一插件加 executions，用 repackage 目标构建，把公共模块依赖自动打进可执行 jar：

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <executions>
        <execution>
            <id>repackage</id>
            <goals><goal>repackage</goal></goals>
        </execution>
    </executions>
</plugin>
```

之后在根目录执行 `mvn clean package -DskipTests` 即可产出全部子服务 jar 包。

### 1.3 Dockerfile 编写

Spring Boot 项目两种常用 Dockerfile：

1. **复制 jar 包版**：本地打好 jar 后 COPY/ADD 进容器运行——本项目选用（上面已能一键产出全部 jar，无需在容器里逐个构建）
2. **Maven 打包版**：源码 COPY 进容器、容器内 `RUN mvn package -DskipTests` 再运行（适合无本地打包环境）

每个业务服务根目录放一个 Dockerfile。以用户服务为例（复制 jar 版）：

```dockerfile
FROM openjdk:8-jdk-alpine   # 基础镜像
WORKDIR /app                # 工作目录
ADD target/yuoj-backend-user-service-0.0.1-SNAPSHOT.jar .   # 本地 jar 拷入
EXPOSE 8102                 # 暴露端口
ENTRYPOINT ["java","-jar","/app/yuoj-backend-user-service-0.0.1-SNAPSHOT.jar","--spring.profiles.active=prod"]
```

`--spring.profiles.active=prod` 指定加载生产配置（配合 1.6）。先在本地用 IDEA 调通每个镜像构建，日志出现 Spring 图标即成功。

### 1.4 编写环境依赖配置 docker-compose.env.yml

**为什么拆两套 compose 文件**：业务服务依赖 MySQL 等环境依赖，必须保证依赖先成功启动。`depends_on` 只保证启动顺序、**不等待服务完全就绪**，不稳定，所以拆 `docker-compose.env.yml`（环境）与 `docker-compose.service.yml`（业务）先后启动。

MySQL 需准备 `mysql-init/` 目录（放建库建表 SQL，官方镜像自动执行 `/docker-entrypoint-initdb.d` 下脚本）+ `.mysql-data/` 目录（数据持久化，防容器重启丢失）。**Nacos 镜像要选支持 linux/arm64 的 `v2.2.0-slim`**，否则可能跑不起来。四个依赖合并后的完整文件：

```yaml
version: '3'
services:
  mysql:
    image: mysql:8
    container_name: yuoj-mysql
    environment:
      MYSQL_ROOT_PASSWORD: 123456
    ports:
      - "3306:3306"
    volumes:
      - ./.mysql-data:/var/lib/mysql              # 数据持久化
      - ./mysql-init:/docker-entrypoint-initdb.d  # 自动建库建表
    restart: always            # 崩溃自动重启
    networks:
      - mynetwork
  redis:
    image: redis:6
    container_name: yuoj-redis
    ports:
      - "6379:6379"
    volumes:
      - ./.redis-data:/data
    networks:
      - mynetwork
  rabbitmq:
    image: rabbitmq:3.12.6-management             # management 版带管理面板
    container_name: yuoj-rabbitmq
    environment:
      RABBITMQ_DEFAULT_USER: guest
      RABBITMQ_DEFAULT_PASS: guest
    ports:
      - "5672:5672"        # 服务端口
      - "15672:15672"      # 管理面板端口
    volumes:
      - ./.rabbitmq-data:/var/lib/rabbitmq
    networks:
      - mynetwork
  nacos:
    image: nacos/nacos-server:v2.2.0-slim
    container_name: yuoj-nacos
    ports:
      - "8848:8848"
    volumes:
      - ./.nacos-data:/home/nacos/data
    environment:
      - MODE=standalone            # 单节点模式
      - PREFER_HOST_MODE=hostname
      - TZ=Asia/Shanghai
    networks:
      - mynetwork
networks:
  mynetwork:                       # 自定义网络：容器互通与隔离
```

验证：MySQL 可本地连接；Redis 可进 Terminal 调试；RabbitMQ 访问 `localhost:15672`（guest/guest）见管理面板；Nacos 访问 `localhost:8848/nacos`（nacos/nacos）见管理页。

### 1.5 编写业务服务配置 docker-compose.service.yml

核心关注 `build`（构建上下文指向子服务目录）与 `depends_on`（业务服务间启动顺序）。以网关为例：

```yaml
version: '3'
services:
  yuoj-backend-gateway:
    container_name: yuoj-backend-gateway
    build:
      context: ./yuoj-backend-gateway
      dockerfile: Dockerfile
    ports:
      - "8101:8101"
    networks:
      - mynetwork
```

其余三个服务结构完全相同，仅取值不同（同用 `mynetwork` 网络）：

| 服务 | container_name / build context | 端口 | depends_on（服务间顺序） |
| :--- | :--- | :--- | :--- |
| yuoj-backend-user-service | ./yuoj-backend-user-service | 8102 | gateway |
| yuoj-backend-question-service | ./yuoj-backend-question-service | 8103 | user-service, gateway |
| yuoj-backend-judge-service | ./yuoj-backend-judge-service | 8104 | user-service, question-service, gateway |

### 1.6 调整程序配置（关键坑）

直接启动业务服务会报"依赖服务地址访问不通"——因为程序连依赖写的是 `localhost`，而**容器内的 localhost/127.0.0.1 指向容器自身，不是宿主机**。解决办法：容器间访问一律改用 **compose 服务名**（同一自定义网络内，服务名即 DNS 域名，可直接解析）。

给每个 Spring Boot 服务新增一套 `application-prod.yml`（配合 Dockerfile 的 `--spring.profiles.active=prod`），把地址全部改为服务名。用户/题目/判题服务改动一致，示意：

```yaml
spring:
  # 数据库：原 localhost → 服务名 mysql
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://mysql:3306/yuoj?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: 123456
  # 缓存：原 localhost → redis
  redis:
    host: redis
    port: 6379
  # 消息队列：原 localhost → rabbitmq（guest/guest）
  rabbitmq:
    host: rabbitmq
    port: 5672
    username: guest
    password: guest
  # 注册中心：原 localhost:8848 → nacos:8848
  cloud:
    nacos:
      server-addr: nacos:8848
```

网关服务的 prod 配置同理，重点是注册中心地址改为 `nacos:8848`，保证能从 Nacos 发现下游服务并聚合路由。

**代码层同类问题**：若代码里用原生 RabbitMQ 客户端初始化交换机/队列（如判题服务的 `InitRabbitMqBean`），连接地址写死 localhost 同样连不通，应改为从配置读取并兜底默认值：

```java
@Slf4j
@Component
public class InitRabbitMqBean {
    @Value("${spring.rabbitmq.host:localhost}")
    private String host;

    @PostConstruct
    public void init() {
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost(host);
        // 声明 direct 交换机 code_exchange、队列 code_queue，绑定 routingKey my_routingKey
        log.info("消息队列启动成功");
    }
}
```

### 1.7 本地测试访问

全部服务经 compose 启动后，访问网关 `localhost:8101/doc.html` 能看到 Swagger 聚合接口文档；依次调用「用户注册 → 登录 → 获取登录用户信息 → 创建题目」全部成功，第一阶段完成。

## 二、服务器部署

### 2.1 准备服务器

先评估内存占用再买服务器：本地 Docker Desktop 显示虚拟机约 8G、容器实际约 4G。作者用**2 核 4G（CentOS 7.9）**实测部署 4 业务服务 + 4 依赖完全够用（见 2.6，实测约 3G）。云服务器需在控制台防火墙放通要用的端口。

### 2.2 安装 Docker + Docker Compose（V2）

Compose V2 已统一为 `docker compose` 子命令（V1 用 `docker-compose`），按官方文档安装：

```bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl start docker
sudo docker run hello-world   # 验证
```

### 2.3 同步文件

把本地调通的整个项目源码上传服务器（FTP/SSH，或 JetBrains 系 IDE 远程部署功能：配置本地→服务器路径映射、开启自动上传，首次手动右键上传并先删除无用文件）。上传后代码位于服务器 `/code/yuoj-backend-microservice`（含 Dockerfile、两套 compose 文件、mysql-init 等）。

### 2.4 获取 jar 包

构建镜像需要 jar 包：① 本地 `mvn package` 后上传；② 服务器装 Maven 直接打包。**jar 包大、频繁改动同步慢，推荐第二种**：

```bash
sudo yum install maven
sudo mvn package          # 项目根目录执行，一键打全部子服务
```

### 2.5 服务启动

**1）启动环境依赖**（先依赖后业务；无权限加 sudo；老版本用 `docker-compose`）：

```bash
docker compose -f docker-compose.env.yml up          # 前台便于看日志
# 云控制台放通端口后，用公网 IP 分别访问 MySQL/Redis/RabbitMQ/Nacos 验证
sudo docker compose -f docker-compose.env.yml up -d  # Ctrl+C 退出后加 -d 后台运行
sudo docker stats                                    # 查看所有容器资源占用
```

**2）启动业务服务**（确认环境依赖就绪后）：

```bash
docker compose -f docker-compose.service.yml up
```

若个别服务启动失败（作者网关就失败过），可只单独重启该服务：

```bash
sudo docker compose -f docker-compose.service.yml up yuoj-backend-gateway
```

### 2.6 线上测试访问

访问 `http://服务器IP:8101/doc.html` 网关接口文档，依次调用注册 → 登录 → 获取用户信息 → 创建题目，全部成功即部署完成。`docker stats` 实测总内存占用约 **3G** → **小型微服务项目 4G 内存服务器足够**。

## 思考题与总结

- 源文留问：只有 **2G 内存**的服务器能否部署这套项目、怎么部署？（提示方向：内存大头在环境依赖，可考虑精简依赖、限制容器内存、改用云厂商托管中间件）
- 方法论沉淀：① 先本地完整跑通再上服务器；② 部署清单先行（服务/端口/版本/依赖关系）；③ 环境与业务拆两套 compose、保证就绪顺序；④ 容器互联用服务名而非 localhost；⑤ Dockerfile/compose 优先复用现成模板。

> 相关：[[DevOps 08 - 主流前后端项目部署方式]] · [[Docker 04 - Docker Compose]] · [[Docker 02 - Dockerfile与镜像构建]] · [[Kubernetes 01 - 基础架构与核心概念]]
> 视频参考：https://www.bilibili.com/video/BV1Cp4y1F7eA/
> 来源：鱼皮·编程导航 / codefather
