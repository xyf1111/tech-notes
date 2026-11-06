---
title: "工具 03 - Vue3 文件上传 OSS"
date: 2026-07-25
tags: [Vue3, Element Plus, OSS, 阿里云, Node.js, 文件上传]
source: "鱼皮·编程导航 / codefather"
---

# 工具 03 - Vue3 文件上传 OSS

> 使用 Vue3 + Element Plus Upload 组件实现前端文件上传，Node.js 后端接收后存入阿里云 OSS。

## 核心要点

### 1. 前端（Vue3 + Element Plus）

使用 Upload 组件的 `http-request` 自定义上传方法（而非 `action` 属性，便于后期维护）：

```typescript
const doUpload = async (options: any) => {
  const { file } = options;
  const formData = new FormData();
  formData.append('file', file);
  await upload(fileData);
}
```

请求头需设置 `Content-Type: application/form-data`：

```typescript
const headers = { 'Content-type': 'application/form-data' };
export function upload(params: any) {
  return instance.post('/uploadImg', params, { headers });
}
```

> 📌 使用 FormData 时，请求头必须设置为 `application/form-data`，后端才能正确识别上传文件。

### 2. 后端（Node.js + Express）

```typescript
import express from 'express';
import bodyParser from 'body-parser';
import cors from 'cors';
import multer from 'multer';

const app = express();
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ limit: '10mb', extended: true }));
app.use(cors());

const upload = multer({ dest: 'uploads/' });

app.post('/uploadImg', upload.single('file'), async (req: any, res: Response) => {
  const file = req.file;
  const result = await put(file.originalname, file.path);
  res.send({ code: 200, data: { fileName: result?.name, url: result?.url } });
});

app.listen(1300, () => {});
```

**依赖**：`body-parser`（解析请求体）、`cors`（解决跨域）、`multer`（处理文件上传）

### 3. 阿里云 OSS 集成

安装 `ali-oss` 后创建客户端：

```typescript
import * as OSS from 'ali-oss';

const client = new OSS.default({
  region: 'oss-cn-hangzhou',  // Bucket 所在地域
  accessKeyId: '你的阿里云Key',
  accessKeySecret: '你的阿里云KeySecret',
  bucket: '你的Bucket名称'
});

export async function put(filename: string, fileData: File) {
  try {
    const result = await client.put(filename, fileData);
    return result;
  } catch (e) {
    console.log(e);
  }
}
```

在接口中调用：
```typescript
router.post('/uploadImg', upload.single('file'), async (req: any, res: Response) => {
  const file = req.file;
  const result = await put(file.originalname, file.path);
  res.send({ code: 200, data: { fileName: result?.name, url: result?.url } });
});
```

> 来源：鱼皮·编程导航 / codefather
