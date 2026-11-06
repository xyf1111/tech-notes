---
title: 'Java 工具 09 - 对象存储文件上传下载'
date: 2026-07-28
tags: [java, springboot, cos, 对象存储, 腾讯云, 文件上传]
source: '鱼皮·编程导航 / codefather'
---

# Java 工具 09 - 对象存储文件上传下载

## 为什么不用服务器本地存储？

将文件直接上传到后端所在服务器虽然简单（Java 自带文件读写 API），但存在以下问题：

- **不利于扩展**：单机存储容量有限，存满后需新增空间或清理文件
- **不利于迁移**：更换服务器时需迁移全部文件
- **不够安全**：权限控制需自行实现，易出现安全漏洞
- **不利于管理**：缺乏数据处理、流量控制等高级能力

因此，持久化用户文件（如头像、图片、生成产物等）应使用专业的第三方存储服务，最常用的是**对象存储**。

## 什么是对象存储？

对象存储是存储**海量文件**的**分布式**存储服务，具有高扩展性、低成本、可靠安全等优点。

常见产品：
- **开源**：MinIO
- **商业云服务**：亚马逊 S3、阿里云 OSS、腾讯云 COS

本文使用**腾讯云 COS**（Cloud Object Storage），通过 Java Spring Boot 后端实现文件上传下载。

## 腾讯云 COS 存储桶创建

1. 进入 [COS 控制台](https://console.cloud.tencent.com/cos/bucket)，创建存储桶
2. 地域选择国内靠近用户的位置
3. 访问权限：若文件允许公开访问选「公有读私有写」；若不允许公开访问选「私有读写」
4. **务必勾选默认告警**——对象存储的存储和访问流量都计费，超限需第一时间处理

创建成功后可通过 Web 控制台上传和浏览文件，并使用默认域名在线访问。

## 后端操作对象存储

### 1. 依赖与配置

参考腾讯云 COS [Java SDK 文档](https://cloud.tencent.com/document/product/436/10199) 接入。

#### CosClientConfig：配置类 + COS 客户端 Bean

```java
@Configuration
@ConfigurationProperties(prefix = "cos.client")
@Data
public class CosClientConfig {

    private String accessKey;
    private String secretKey;
    private String region;
    private String bucket;

    @Bean
    public COSClient cosClient() {
        COSCredentials cred = new BasicCOSCredentials(accessKey, secretKey);
        ClientConfig clientConfig = new ClientConfig(new Region(region));
        return new COSClient(cred, clientConfig);
    }
}
```

#### 配置文件（application-local.yml）

```yaml
cos:
  client:
    accessKey: xxx
    secretKey: xxx
    region: xxx
    bucket: xxx
```

> **注意**：将该文件加入 `.gitignore`，防止密钥泄露到代码仓库。

配置获取方式：
- **accessKey / secretKey**：腾讯云访问管理 → [密钥管理](https://console.cloud.tencent.com/cam/capi)
- **region**：参考[地域文档](https://cloud.tencent.com/document/product/436/6224)
- **bucket**：存储桶名称，可在控制台查看

#### 文件常量

```java
public interface FileConstant {
    String COS_HOST = "https://yuzi-1256524210.cos.ap-shanghai.myqcloud.com";
}
```

该域名在 COS 控制台「域名信息」处获取。

### 2. CosManager：对象存储操作封装

`CosManager` 组件封装 COS 的核心操作，供 Service 层调用：

```java
@Component
public class CosManager {

    @Resource
    private CosClientConfig cosClientConfig;

    @Resource
    private COSClient cosClient;

    /**
     * 上传对象（本地文件路径）
     */
    public PutObjectResult putObject(String key, String localFilePath) {
        PutObjectRequest putObjectRequest = new PutObjectRequest(
            cosClientConfig.getBucket(), key, new File(localFilePath));
        return cosClient.putObject(putObjectRequest);
    }

    /**
     * 上传对象（File 对象）
     */
    public PutObjectResult putObject(String key, File file) {
        PutObjectRequest putObjectRequest = new PutObjectRequest(
            cosClientConfig.getBucket(), key, file);
        return cosClient.putObject(putObjectRequest);
    }

    /**
     * 下载对象
     */
    public COSObject getObject(String key) {
        GetObjectRequest getObjectRequest = new GetObjectRequest(cosClientConfig.getBucket(), key);
        return cosClient.getObject(getObjectRequest);
    }
}
```

### 3. 文件上传测试接口

在 Controller 中编写测试接口，核心流程：接收 `MultipartFile` → 指定路径 → 调用 `cosManager.putObject` → 返回文件 key。

```java
@AuthCheck(mustRole = UserConstant.ADMIN_ROLE)
@PostMapping("/test/upload")
public BaseResponse<String> testUploadFile(@RequestPart("file") MultipartFile multipartFile) {
    String filename = multipartFile.getOriginalFilename();
    String filepath = String.format("/test/%s", filename);
    File file = null;
    try {
        file = File.createTempFile(filepath, null);
        multipartFile.transferTo(file);
        cosManager.putObject(filepath, file);
        return ResultUtils.success(filepath);
    } catch (Exception e) {
        log.error("file upload error, filepath = " + filepath, e);
        throw new BusinessException(ErrorCode.SYSTEM_ERROR, "上传失败");
    } finally {
        if (file != null) {
            file.delete();  // 删除临时文件
        }
    }
}
```

> 测试接口务必加管理员权限（`@AuthCheck`），防止随意上传。

### 4. 文件下载测试接口

COS 提供两种下载方式：
1. **下载到服务器**：适合后端处理文件
2. **获取输入流**：适合返回给前端用户
3. **直接 URL 访问**：适合可公开访问的资源（如头像、图片），无需后端中转

对于需要权限控制的文件，采用方式 2——后端从 COS 获取文件流后写入 Servlet Response：

```java
@AuthCheck(mustRole = UserConstant.ADMIN_ROLE)
@GetMapping("/test/download/")
public void testDownloadFile(String filepath, HttpServletResponse response) throws IOException {
    COSObjectInputStream cosObjectInput = null;
    try {
        COSObject cosObject = cosManager.getObject(filepath);
        cosObjectInput = cosObject.getObjectContent();
        byte[] bytes = IOUtils.toByteArray(cosObjectInput);
        // 设置文件下载响应头
        response.setContentType("application/octet-stream;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=" + filepath);
        response.getOutputStream().write(bytes);
        response.getOutputStream().flush();
    } catch (Exception e) {
        log.error("file download error, filepath = " + filepath, e);
        throw new BusinessException(ErrorCode.SYSTEM_ERROR, "下载失败");
    } finally {
        if (cosObjectInput != null) {
            cosObjectInput.close();
        }
    }
}
```

## 前端 Vue3 页面对接

### 路由配置

```javascript
{
  path: '/test/file',
  icon: 'home',
  component: './Test/File',
  name: '文件上传下载测试',
  hideInMenu: true,
}
```

### 常量

```typescript
export const COS_HOST = "https://yuzi-1256524210.cos.ap-shanghai.myqcloud.com";
```

### 文件上传组件

使用 Ant Design 的 `Dragger`（拖拽上传），通过 `customRequest` 自定义上传逻辑，调用后端上传接口：

```tsx
const props: UploadProps = {
  name: 'file',
  multiple: false,
  maxCount: 1,
  customRequest: async (fileObj: any) => {
    try {
      const res = await testUploadFileUsingPost({}, fileObj.file);
      fileObj.onSuccess(res.data);
      setValue(res.data);
    } catch (e: any) {
      message.error('上传失败，' + e.message);
      fileObj.onError(e);
    }
  },
  onRemove() {
    setValue(undefined);
  },
};
```

### 文件展示与下载

上传成功后直接拼接 COS 域名展示图片，使用 `file-saver` 库调用后端下载接口保存文件：

```tsx
import { saveAs } from 'file-saver';

<Button onClick={async () => {
  const blob = await testDownloadFileUsingGet(
    { filepath: value },
    { responseType: "blob" },
  );
  const fullPath = COS_HOST + value;
  saveAs(blob, fullPath.substring(fullPath.lastIndexOf("/") + 1));
}}>
  点击下载文件
</Button>
```

### 响应拦截器修改

后端下载接口直接返回二进制流而非 JSON 格式，需要在请求拦截层对下载路径做特殊处理，直接返回 blob：

```javascript
responseInterceptors: [
  (response) => {
    const requestPath: string = response.config.url ?? '';
    const { data } = response as unknown as ResponseStructure;
    if (!data) throw new Error('服务异常');
    // 文件下载时直接返回，不做 JSON 解析
    if (requestPath.includes("download")) {
      return response;
    }
    // ...
  },
]
```

## 阿里云 OSS 接入（补充）

> 腾讯云 COS 之外的另一主流选择：阿里云 OSS。流程一致——开通服务 → 创建 Bucket → 获取 AccessKey → 后端集成 SDK。以下为差异点与最小可运行配置。

### 1. 开通与创建 Bucket

- 阿里云控制台搜索「对象存储 OSS」，首次使用先开通服务（用量小免费）
- 创建存储空间 Bucket：名称全局唯一，地域就近选择（如华北 2 北京），存储类型选「本地冗余存储」（省流量费）
- 获取密钥：控制台右上角头像 → AccessKey 管理 → 创建 AccessKey，得到 AccessKeyId / AccessKeySecret

### 2. 依赖与配置

```xml
<dependency>
    <groupId>com.aliyun.oss</groupId>
    <artifactId>aliyun-sdk-oss</artifactId>
    <version>3.10.2</version>
</dependency>
```

```yaml
oss:
  aliyun:
    endpoint: oss-cn-beijing.aliyuncs.com   # Bucket 所在地域对应 Endpoint
    accessKeyId: your-key-id
    accessKeySecret: your-key-secret
    bucket: your-bucket-name
    domain: https://your-bucket.oss-cn-beijing.aliyuncs.com/  # 返回前端拼接文件 URL
```

### 3. 初始化 OssClient

```java
@Configuration
public class OssConfig {
    @Value("${oss.aliyun.endpoint}") private String endpoint;
    @Value("${oss.aliyun.accessKeyId}") private String accessKeyId;
    @Value("${oss.aliyun.accessKeySecret}") private String accessKeySecret;

    @Bean
    public OSS ossClient() {
        return new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);
    }
}
```

### 4. 上传接口

```java
@PostMapping("/upload")
public String upload(@RequestParam("file") MultipartFile file) throws IOException {
    // 时间戳 + 原扩展名，避免重名
    String original = file.getOriginalFilename();
    String fileName = System.currentTimeMillis()
            + original.substring(original.lastIndexOf("."));
    // 对象存储无「文件夹」概念，用文件名中的 / 模拟目录，如 2024/08/19/xxx.png
    PutObjectRequest request = new PutObjectRequest(BUCKET, fileName, file.getInputStream());
    oss.putObject(request);
    return DOMAIN + fileName;
}
```

### 5. 常见坑

- 上传后访问报 Access Denied：Bucket 读写权限设为「公共读」（私有读写需额外签名 URL）
- endpoint 不带 `https://` 前缀（如 `oss-cn-beijing.aliyuncs.com`）

## 架构总结

```
前端 (Vue3 + Ant Design)          后端 (Spring Boot)             腾讯云 COS
      │                                │                            │
      ├─ 上传文件 ─────────────────► Controller ──► CosManager ──► putObject()
      │                                │                            │
      │◄── 返回文件 key ───────────────┤                            │
      │                                │                            │
      ├─ 拼接 COS_HOST + key ────► 直接访问 ───────────────────► 图片展示
      │                                │                            │
      └─ 下载 blob ◄─── Controller ◄── CosManager ◄─── getObject()
```

---

**来源**：鱼皮·编程导航 / codefather — 《使用对象存储实现文件上传下载》
