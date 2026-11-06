---
title: "AI 大模型 04 - AI 文档助手实战（向量数据库 + 百川大模型）"
date: 2026-09-05
tags: [AI, 大模型, 向量数据库, RAG, Java]
source: "鱼皮·编程导航 / codefather"
---

# AI 大模型 04 - AI 文档助手实战（向量数据库 + 百川大模型）

> 把文档拆成小段、转成向量存入数据库；提问时先检索出最相似的段落，再连同问题拼进 prompt 交给大模型——分分钟就能做出一个能「读文档回答」的 AI 文档助手。

本文是 [[AI 大模型 01 - 应用开发学习路线]] 的一个落地实战：给大模型外挂「文档记忆」，让它能回答我们自己文档里的内容。本质就是 [[RAG 01 - 学习路线]] 里的检索增强生成（RAG）套路，只是把最麻烦的文档拆分、向量化环节全部交给了云服务。

效果演示：上传一篇写着「1 + 1 等于 3」的文档，向助手提问，AI 会原样回答出文档内容——这也提醒我们：AI 并不完全可信，回答质量取决于喂给它的原始数据。

## 实现原理：为什么 AI 能回答指定文档？

大模型无法直接「记住」我们的私人文档，需要先把文档数据喂给它；但 AI 的输入长度有限，装不下整篇长文。于是思路是：

1. **拆分文档**：把万字长文拆成若干小段落（如 20 个 500 字的小段落）；
2. **段落入库**：把小段落存入数据库；
3. **相似检索**：用户提问时，先从数据库查出与问题最相似的小段落；
4. **总结回答**：把检索到的段落交给大模型总结，再输出回答。

> 开卷考试比喻：脑子记不住所有考点，就带本书进考场——根据考题从书中查出答案，整理一下写到考卷上即可。

完整实现流程共 6 步：

1. 将知识库文档段落拆分；
2. 用算法（Embedding）把文档内容转为向量；
3. 将向量存储到向量数据库；
4. 把用户问题用 Embedding 转为向量；
5. 根据问题向量在向量数据库做相似性查询；
6. 将检索到的最相似结果作为背景知识（上下文）拼进 prompt，发给 AI 大模型，获得响应。

随之而来的两个关键问题：段落以什么格式存储？怎么按问题查出最相似的段落？——答案是向量数据库。

## 向量数据库：AI 的「小抄」

**向量数据库**是专门存储和处理**向量数据**的数据库，内置相似内容检索功能，能找出与某个向量最相似的数据。相比 MySQL 这类关系型数据库的 `like` 模糊查询，向量检索更灵活，因此成为 AI 时代越来越流行的「小抄」。

**什么是向量数据？** 就是用算法把文本、图片、音视频等内容统一转换成的数值向量（Embedding）：

- 「中午吃饺子」→ `[0.8, 0.6, 0.9, 0.4, ...]`
- 「晚上写代码」→ `[0.1, 0.2, 0.3, 0.4, ...]`

搜索时同样把关键字转成向量，然后**计算两个向量之间的距离来判断相似度**。例如用户问「中午吃什么？」→ `[0.8, 0.6, 0.7, 0.3, ...]`，显然更接近「中午吃饺子」的向量，所以会优先搜出「中午吃饺子」。

注意：采用不同的向量转换算法或相似度计算方法，得到的向量值和计算结果可能不同。

## 腾讯云向量数据库：流程简化为 3 步

自己实现上面的 6 步，要写文档拆分器、embedding 服务，相当麻烦。腾讯云新版向量数据库提供**自动向量化（Embedding）**、**文本自动拆分**和**一键上传**能力，直接把文章传上去，就能得到拆分好并转成向量的数据，流程简化为 3 步：

1. **上传文档**到腾讯云向量数据库（自动拆分 + 转向量存储）；
2. 把**用户问题**传入向量数据库做相似性查询；
3. 把检索到的最相似结果作为背景知识（上下文）拼进 prompt，发给 AI 大模型，获得回答。

选型上使用**腾讯云向量数据库 + 百川大模型（Baichuan2-53B）**搭配开发。准备工作：在控制台开通向量数据库实例（开启外网访问，白名单按需配置：测试期可放开、生产务必收紧），并在百川平台创建 API Key；写代码前先读腾讯云官方最新 API 文档与 Java SDK Demo。

## Java 实现步骤

以 Java Maven 项目为例，核心代码分五块：依赖、连接客户端、建库建集合并上传文档、相似检索、调用大模型，最后用 main 串联成问答循环。

### 1. 引入 Maven 依赖

核心是腾讯云向量数据库 Java SDK（作者所用版本需本地 jar + system scope 引入，**版本迭代快，坐标以官方最新 Demo 为准**），其余是 HTTP 客户端、JSON 解析等通用库：

```xml
<!-- 腾讯云向量数据库 SDK：坐标仅供参考，以官方最新 Demo 为准 -->
<dependency>
    <groupId>com.tencent.tcvectordb</groupId>
    <artifactId>vectordatabase-sdk-java</artifactId>
    <version>1.0.4-SNAPSHOT</version>
</dependency>
<!-- 调用大模型用的 HTTP 客户端 -->
<dependency>
    <groupId>com.squareup.okhttp3</groupId>
    <artifactId>okhttp</artifactId>
    <version>4.9.1</version>
</dependency>
<!-- JSON 序列化 / 解析 -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-core</artifactId>
    <version>2.12.3</version>
</dependency>
```

另外按需引入 commons-lang3（字符串/对象工具）、cos_api 等。

### 2. 连接向量数据库

url 直接在实例列表中复制，username 和 key 在实例的「密钥管理」里获取：

```java
ConnectParam param = ConnectParam.newBuilder()
        .withUrl("url")              // 实例列表复制
        .withUsername("username")    // 密钥管理获取
        .withKey("key")
        .withTimeout(30)
        .build();
VectorDBClient client = new VectorDBClient(param, ReadConsistencyEnum.EVENTUAL_CONSISTENCY);
```

### 3. 建库建集合 + 上传文档（自动拆分 + Embedding）

```java
private static void initKnowledge(VectorDBClient client) throws Exception {
    // 建库：可先删旧库，不存在则忽略异常（演示用，实际项目可拆成独立初始化脚本）
    try { client.dropAIDatabase(DB_NAME); } catch (VectorDBException e) { /* ignore */ }
    client.createAIDatabase(DB_NAME);              // 创建 AI 数据库

    // 建集合（类似数据表）
    Database database = client.database(DB_NAME);
    database.createAICollection(CreateAICollectionParam.newBuilder()
            .withName(COLLECTION_NAME).build());   // 创建 AI 集合

    // 上传本地 doc 目录下的全部文档：拆分、转向量全部自动完成
    AICollection collection = client.database(DB_NAME).describeAICollection(COLLECTION_NAME);
    for (String f : Objects.requireNonNull(new File("doc").list())) {
        System.out.println("upload file doc/" + f);
        collection.upload("doc/" + f, Collections.emptyMap());
    }
    // 上传后服务端要解析 + Embedding，需等待 10~20 秒才能开始检索
}
```

### 4. 相似检索 + 相似度阈值过滤（关键经验）

**关键经验**：搜索与文档完全无关的问题时，向量数据库**依然会返回结果**，容易让大模型「睁着眼睛乱说」。好在每条结果都带相似度 score，可设阈值过滤——低于 0.8 的视为无关直接丢弃；检索不到相关内容时，宁可提示「未找到」，也不要把垃圾上下文喂给大模型。

```java
private static final Double THRESHOLD = 0.8; // 文档相关性阈值

private static String searchKnowledge(String question, VectorDBClient client) {
    AICollection collection = client.database(DB_NAME).describeAICollection(COLLECTION_NAME);
    // 直接传问题文本，向量化由服务端自动完成
    SearchByContentsParam param = SearchByContentsParam.newBuilder()
            .withContent(question).build();

    StringBuilder knowledge = new StringBuilder();
    for (Document document : collection.search(param)) {
        Double score = document.getScore();           // 结果自带的相似度
        if (ObjectUtils.isEmpty(score) || score < THRESHOLD) {
            continue;                                 // 过滤无关结果
        }
        ChunkInfo chunk = (ChunkInfo) document.getObject("chunk");
        knowledge.append(chunk.getText()).append(" "); // 拼接命中段落文本
    }
    return knowledge.toString();
}
```

### 5. 调用百川大模型（OKHttp）

按百川要求的格式设置请求头、封装 prompt 即可，要点：

- 接口：`https://api.baichuan-ai.com/v1/chat`
- 请求头：
  - `Authorization: Bearer <ak>`（ak 即 API Key）
  - `X-BC-Timestamp`：秒级时间戳
  - `X-BC-Signature`：`MD5(sk + 请求体 + timestamp)`
  - `X-BC-Sign-Algo: MD5`
- 请求体：`model` 填 `Baichuan2-53B`，`messages` 中放用户 prompt
- 响应：取 `data.messages[0].content` 即为回答

```java
public class BaiChuanLLM {
    private static final String URL = "https://api.baichuan-ai.com/v1/chat";
    private static final String API_KEY = "ak";    // 百川控制台创建
    private static final String SECRET_KEY = "sk"; // 用于生成签名

    /** 问题 + 检索到的背景知识拼成 prompt，发给大模型 */
    public static String ask(String question, String knowledge) {
        return llmRequest(getPrompt(question, knowledge));
    }

    private static String llmRequest(String prompt) throws IOException {
        String requestData = getBaiChuanRequest(prompt);
        String timestamp = String.valueOf(System.currentTimeMillis() / 1000);
        String signature = calculateMd5(SECRET_KEY + requestData + timestamp); // MD5(sk + body + 时间戳)

        RequestBody body = RequestBody.create(requestData,
                MediaType.parse("application/json; charset=utf-8"));
        Request request = new Request.Builder().url(URL)
                .headers(buildHeaders(timestamp, signature)).post(body).build();

        try (Response response = getHttpClient().newCall(request).execute()) {
            JsonNode node = MAPPER.readTree(response.body().string());
            return node.get("data").get("messages").get(0).get("content").asText(); // 取回答
        }
    }

    private static Headers buildHeaders(String timestamp, String signature) {
        return new Headers.Builder()
                .add("Content-Type", "application/json")
                .add("Authorization", "Bearer " + API_KEY)  // ak
                .add("X-BC-Timestamp", timestamp)           // 秒级时间戳
                .add("X-BC-Signature", signature)           // MD5 签名
                .add("X-BC-Sign-Algo", "MD5")
                .build();
    }

    /** 请求体：model 固定为 Baichuan2-53B */
    private static String getBaiChuanRequest(String prompt) {
        ObjectNode data = JsonNodeFactory.instance.objectNode();
        data.put("model", "Baichuan2-53B");
        ObjectNode msg = JsonNodeFactory.instance.objectNode();
        msg.put("role", "user");
        msg.put("content", prompt);
        data.put("messages", JsonNodeFactory.instance.arrayNode().add(msg));
        return new ObjectMapper().writeValueAsString(data);
    }

    /** prompt = {请回答问题: 问题, 背景知识如下: 检索到的段落} */
    private static String getPrompt(String question, String knowledge) {
        ObjectNode obj = JsonNodeFactory.instance.objectNode();
        obj.put("请回答问题", question);
        obj.put("背景知识如下", knowledge);
        return new ObjectMapper().writeValueAsString(obj);
    }

    private static String calculateMd5(String input) { /* 标准 MD5 工具方法，输出十六进制小写 */ }
    private static OkHttpClient getHttpClient() { /* OkHttpClient 单例：读超时 60s、配置连接池 */ }
}
```

calculateMd5 与 getHttpClient 属常规样板：前者用 `MessageDigest.getInstance("MD5")` 后转小写十六进制；后者建议读超时设 60 秒（大模型生成慢）并配连接池。

### 6. main 循环串联（提问 → 检索 → 调大模型 → 输出）

```java
public static void main(String[] args) throws Exception {
    VectorDBClient client = createClient();
    initKnowledge(client);            // 建库建集合 + 上传文档（演示每次启动重建，实际只初始化一次）

    Scanner scanner = new Scanner(System.in);
    System.out.print("请输入您的问题（exit退出）：");
    String question = scanner.nextLine();
    while (!"exit".equalsIgnoreCase(question)) {
        if (!question.trim().isEmpty()) {
            String result = searchKnowledge(question, client);      // 1. 向量库检索背景知识
            if (StringUtils.isBlank(result)) {
                System.out.println("未找到相关内容");                // 2a. 无相关结果，如实提示
            } else {
                String llmResult = BaiChuanLLM.ask(question, result); // 2b. 拼 prompt 调大模型
                System.out.println("---->LLM回答结果：");
                System.out.println(llmResult);                       // 3. 输出回答
            }
        }
        System.out.print("\n\n请输入您的问题（exit退出）：");
        question = scanner.nextLine();
    }
}
```

## 注意事项

- **版本迭代快**：SDK、接口与官方 Demo 持续更新，动手前务必以腾讯云官方最新文档为准（官方 API 文档地址：cloud.tencent.com/document/product/1709/97768）；
- **Python 更简单**：同样的功能用 Python 不到 100 行即可搞定，不想折腾 Java 依赖可优先用 Python。

## 总结

整套方案开发成本低，在于向量数据库一站式完成了**文件分片、Embedding 向量化、相似搜索**三件事，把 RAG 最重的活全包了；大模型只负责最后一步「根据背景知识作答」。两条实践经验：

1. 向量检索在没有相关内容时也会硬返回最接近的片段，必须用相似度阈值（如 0.8）过滤，避免大模型基于无关内容瞎编；
2. 文档上传后需等待服务端解析 + Embedding 完成（约 10~20 秒）再检索。

> 来源：鱼皮·编程导航 / codefather
