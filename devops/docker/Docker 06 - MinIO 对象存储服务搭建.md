---
title: "Docker - MinIO 对象存储服务搭建"
date: 2026-07-22
tags: [Docker, MinIO, 对象存储, DevOps, SpringBoot]
source: "鱼皮·编程导航 / codefather"
---

# Docker - MinIO 对象存储服务搭建

> 使用 Docker 在服务器上搭建 MinIO 高性能对象存储服务，并通过 SpringBoot 集成实现文件上传功能。

## 为什么选择 MinIO

[MinIO](https://min.io) 是一个高性能、轻量级的对象存储服务器，兼容 Amazon S3 API。GitHub 上拥有 43k+ Star，阿里巴巴、腾讯、百度等企业均有使用。

**优势：**
- 低延迟、高吞吐量
- 易于部署和管理（单容器即可运行）
- 分布式、高可用、水平扩展
- 控制成本，避免第三方对象存储被攻击刷流量的风险

## 使用 Docker 搭建 MinIO

### 1. 创建数据目录

```bash
mkdir -p /home/minio/config   # MinIO 配置文件
mkdir -p /home/minio/data     # 上传文件存储
```

### 2. 启动 MinIO 容器

```bash
docker run -p 9000:9000 -p 9001:9001 \
  -d --restart=always \
  -e "MINIO_ACCESS_KEY=admin" \
  -e "MINIO_SECRET_KEY=password" \
  -v /home/minio/data:/data \
  -v /home/minio/config:/root/.minio \
  minio/minio server /data \
  --console-address ":9001"
```

**参数说明：**

| 参数 | 说明 |
|---|---|
| `-p 9000:9000` | API 端口（文件读写） |
| `-p 9001:9001` | Web 控制台端口 |
| `-d --restart=always` | 后台运行，异常自动重启 |
| `MINIO_ACCESS_KEY / MINIO_SECRET_KEY` | 控制台登录账号密码 |
| `-v /home/minio/data:/data` | 持久化文件存储目录 |

### 3. 控制台配置

访问 `http://服务器IP:9001`，使用配置的账号密码登录：

1. **创建 Bucket（存储桶）** — 用于存放上传文件
2. **生成 Access Key / Secret Key** — 用于程序远程访问
3. **添加只读访问规则**（可选）— 若需允许直接通过 URL 访问文件，在 Bucket 的权限配置中添加 `readonly` 规则

### 4. 测试文件访问

上传文件后，访问路径格式：
```
http://服务器IP:9000/{bucket名称}/{文件名}
```

## SpringBoot 集成 MinIO

### 1. 引入依赖

```xml
<!-- MinIO 客户端 -->
<dependency>
    <groupId>io.minio</groupId>
    <artifactId>minio</artifactId>
    <version>8.5.9</version>
</dependency>
```

### 2. 配置类

```java
@Configuration
@ConfigurationProperties(prefix = "file.minio")
@Data
public class MinioConfiguration {

    private String accessKey;
    private String secretKey;
    private String endpoint;
    private String bucket;

    @Bean
    public MinioClient minioClient() {
        return MinioClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .build();
    }
}
```

### 3. application.yml 配置

```yaml
file:
  minio:
    endpoint: http://服务器ip:9000
    accessKey: <生成的 AccessKey>
    secretKey: <生成的 SecretKey>
    bucket: guanzhi
```

### 4. 文件上传接口

```java
@RestController
@RequestMapping("/file")
public class FileController {

    @Resource
    private MinioClient minioClient;

    @Resource
    private MinioConfiguration minioConfiguration;

    @PostMapping("/upload")
    public String upload(@RequestParam("file") MultipartFile file) throws Exception {
        String path = UUID.randomUUID() + file.getOriginalFilename();
        minioClient.putObject(PutObjectArgs.builder()
                .bucket(minioConfiguration.getBucket())
                .object(path)
                .stream(file.getInputStream(), file.getSize(), -1)
                .contentType(file.getContentType())
                .build());
        return String.format("%s/%s/%s",
                minioConfiguration.getEndpoint(),
                minioConfiguration.getBucket(),
                path);
    }
}
```

### 5. MinioUtils 工具类

完整的文件操作工具类，包含上传、下载、删除、列表、获取访问地址：

```java
@Service
@Slf4j
public class MinioUtils {

    @Autowired
    private MinioClient minioClient;
    @Autowired
    private MinioConfiguration minioConfig;

    /** 获取文件列表 */
    public List<String> listObjects() {
        List<String> list = new ArrayList<>();
        try {
            ListObjectsArgs args = ListObjectsArgs.builder()
                    .bucket(minioConfig.getBucket()).build();
            for (Result<Item> result : minioClient.listObjects(args)) {
                Item item = result.get();
                list.add(item.objectName());
            }
        } catch (Exception e) {
            log.error("MinIO list error", e);
        }
        return list;
    }

    /** 上传文件 */
    public void uploadObject(InputStream is, String fileName, String contentType) {
        try {
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(minioConfig.getBucket())
                    .object(fileName)
                    .contentType(contentType)
                    .stream(is, is.available(), -1)
                    .build());
            is.close();
        } catch (Exception e) {
            log.error("MinIO upload error", e);
        }
    }

    /** 删除文件 */
    public void deleteObject(String objectName) {
        try {
            minioClient.removeObject(RemoveObjectArgs.builder()
                    .bucket(minioConfig.getBucket())
                    .object(objectName).build());
        } catch (Exception e) {
            log.error("MinIO delete error", e);
        }
    }

    /** 生成预签名下载地址（7 天有效） */
    public String getObjectUrl(String objectName) {
        try {
            return minioClient.getPresignedObjectUrl(
                    GetPresignedObjectUrlArgs.builder()
                    .method(Method.GET)
                    .bucket(minioConfig.getBucket())
                    .object(objectName)
                    .expiry(7, TimeUnit.DAYS).build());
        } catch (Exception e) {
            log.error("MinIO getUrl error", e);
        }
        return "";
    }

    /** 下载文件流 */
    public InputStream getObject(String objectName) {
        try {
            return minioClient.getObject(GetObjectArgs.builder()
                    .bucket(minioConfig.getBucket())
                    .object(objectName).build());
        } catch (Exception e) {
            log.error("MinIO download error", e);
        }
        return null;
    }
}
```

### 6. 完整 Controller

```java
@RestController
@RequestMapping("/minio")
public class MinioController {

    @Autowired
    private MinioUtils minioService;

    @GetMapping("/list")
    public BaseResponse<List<String>> list() {
        return ResultUtils.success(minioService.listObjects());
    }

    @DeleteMapping("/delete")
    public BaseResponse<Boolean> delete(@RequestParam String filename) {
        minioService.deleteObject(filename);
        return ResultUtils.success(true);
    }

    @PostMapping("/upload")
    public BaseResponse<String> upload(@RequestParam("file") MultipartFile file) {
        try {
            String fileName = System.currentTimeMillis() + "."
                    + StringUtils.substringAfterLast(
                            file.getOriginalFilename(), ".");
            minioService.uploadObject(
                    file.getInputStream(), fileName, file.getContentType());
            return ResultUtils.success(fileName);
        } catch (Exception e) {
            throw new BusinessException(ErrorCode.OPERATION_ERROR, "上传失败");
        }
    }

    @GetMapping("/download")
    public void download(@RequestParam String filename,
                         HttpServletResponse response) {
        try (InputStream in = minioService.getObject(filename)) {
            response.setHeader("Content-Disposition",
                    "attachment;filename=" + filename);
            IOUtils.copy(in, response.getOutputStream());
        } catch (Exception e) {
            throw new BusinessException(ErrorCode.OPERATION_ERROR, "下载失败");
        }
    }

    @GetMapping("/getUrl")
    public BaseResponse<String> getUrl(@RequestParam String filename) {
        return ResultUtils.success(minioService.getObjectUrl(filename));
    }
}
```

### 7. 文件上传配置

```yaml
spring:
  servlet:
    multipart:
      enabled: true
      max-file-size: 50MB
      max-request-size: 100MB
```

## 使用建议

- **访问策略**：Bucket 需设置为 Public，否则文件 URL 访问返回 403
- **域名绑定**：可通过域名解析将 IP 映射到域名，避免暴露服务器 IP
- **安全组**：云服务器需在安全组中开放 9000（API）和 9001（控制台）端口
- **数据持久化**：Docker 部署时务必挂载数据卷，防止容器重启后数据丢失

> 来源：鱼皮·编程导航 / codefather
