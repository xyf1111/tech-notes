---
title: "DevOps - Wechaty 微信机器人自动回复"
date: 2026-08-09
tags: [DevOps, 微信机器人, wechaty, 自动化]
source: "鱼皮·编程导航 / codefather"
---

# DevOps 04 - Wechaty 微信机器人自动回复

> 一句话摘要：用开源库 wechaty 接收微信消息、再配合「if/else 正则」或「微信对话开放平台」生成回复，自制一个自动回答常见编程问题的微信 AI 问答机器人。

## 核心要点

自制微信 AI 问答机器人 = 解决两个问题：

1. **接收消息**：如何让程序接收到微信发来的消息？（用开源库 `wechaty` 实现微信自动化：收发消息、通过好友、拉群等）
2. **智能回复**：如何根据消息回复对应的内容？（简单规则用 if/else 正则匹配；复杂多变表达用「微信对话开放平台」的免费智能对话能力）

---

## 一、接收消息：wechaty 入门

### 1. 6 行代码启动机器人

wechaty 支持几乎所有主流编程语言，其中 JavaScript 的入门示例只需 **6 行代码**，即可启动一个帮你接收消息的机器人：

```javascript
import { WechatyBuilder } from 'wechaty'
// 启动
WechatyBuilder.build()
  .on('scan', (qrcode, status) => console.log(`Scan QR Code to login: ${status}\nhttps://wechaty.js.org/qrcode/${encodeURIComponent(qrcode)}`))
  .on('login',            user => console.log(`User ${user} logged in`))
  .on('message',       message => console.log(`Message: ${message}`))
  .start()
```

> wechaty 官网：<https://wechaty.js.org/>

**事件机制**：wechaty 中定义了很多事件，如扫码（`scan`）、用户登录（`login`）、收到消息（`message`）、收到好友请求等。你不需要关心事件是如何被触发的，只需要针对不同事件编写处理方法即可。

### 2. 初始化机器人并处理消息

```javascript
// 初始化机器人
const bot = WechatyBuilder.build({
  name: 'yupi-wxrobot',
  // 用于兼容不同 IM 协议，不用关心
  puppet: 'wechaty-puppet-wechat',
})
// 处理消息
bot.on('message', async function (msg) {
  // 获取消息发送人
  const contact = msg.talker()
  // 获取消息内容
  const text = msg.text()
  // 获取群聊信息
  const room = msg.room()
  // 是私聊
  if (contact && text) {
    // 回复相同内容
    msg.say(text, contact);
  }
}
```

### 3. ⚠️ 陷阱：必须补充过滤逻辑

**千万不要**直接运行上述代码！一旦启动机器人、又没有限制回复者昵称，它会对**所有给你发消息的人**生效（作者就曾被坑过）。

如果只想自动回复某人或某群聊的消息，记得在代码中补充过滤逻辑：

```javascript
// 处理消息
bot.on('message', async function (msg) {
  // 获取消息发送人
  const contact = msg.talker()
  // 获取消息内容
  const text = msg.text()
  // 获取群聊信息
  const room = msg.room()

  // 不处理自己的消息
  if (msg.self()) {
    return
  }
  // 群聊还是私聊
  if (room) {
    if(room.topic() === '鱼皮群') {
      // 回复
    }
  } else {
    if(contact.name() === '小号') {
      // 回复
    }
  }
}
```

过滤要点：

- `msg.self()`：跳过自己发出去的消息，避免机器人自问自答
- `room.topic()`：判断群聊名称（仅对群聊消息生效）
- `contact.name()`：判断私聊联系人昵称（非群聊消息）

### 4. 原理：无头浏览器 + 网页版微信

wechaty 接收微信消息的原理很简单：

1. 执行 wechaty 程序时，它利用**无头浏览器技术**悄悄打开一个**网页版微信**
2. 在运行程序的控制台弹出微信网页版的**登录二维码**
3. 扫码登录后，程序只需**监听页面元素的变化**、或**自动触发点击事件**即可

本质就是把「人工操作网页」转化为「后台自动化执行」。

---

## 二、智能回复

### 1. 简单规则：if/else 正则匹配

如果只是简单的自动回复，问题规则可收敛、可枚举时，直接用 if/else 加正则即可解决：

```javascript
if(/你好/.test(text)) {
  msg.say('好的');
} else if (/谢谢/.test(text)) {
  msg.say('不客气');
} else if (/加群/.test(text)) {
  msg.say('公众号[程序员鱼皮],回复[加群]');
} else {
  msg.say('我不懂');
}
```

### 2. 复杂表达：微信对话开放平台

现实场景中，读者对同一个问题有不同表达方式（如「怎么学 Java？」「我想学 Java，怎么学？」），规则难以枚举，需要真正的人工智能。可直接利用 **微信对话开放平台** 提供的免费智能对话能力，一行代码都不用写：

> 地址：<https://openai.weixin.qq.com/>

**配置流程**：

1. **创建机器人**：登录平台后先创建一个机器人
2. **添加技能**：
   - **自定义技能**：向机器人灌输指定的问题和回答，可灵活自定义题目、不同的问法以及回答，全部用界面操作完成
   - **默认技能**：直接使用平台提供的默认技能，如听歌、聊天、百科等
   - （示例需求：自动回答编程相关问题 → 创建一个新技能，自定义编程问题与回答）
3. **发布和使用**（三种方式）：
   - 绑定**公众号 / 小程序**，自动回复读者消息
   - 直接在 **H5 网页**中接入智能客服
   - 在程序中调用**开放接口**使用智能对话能力

### 3. 开放接口调用代码

在 wechaty 程序中自动获得回复，采用开放接口方式，用请求库调用即可：

```javascript
// 获取 API 签名，2小时过期
// token 需从平台获取
const url = `https://openai.weixin.qq.com/openapi/sign/${token}`;
const {signature} = (await axios.post(url, {
    userid: 'test'
})).data;

// 调用 AI 接口，获取答案
async function getAnswer(userid, text) {
  const apiUrl = `https://openai.weixin.qq.com/openapi/aibot/${token}`;
  return (await axios.post(apiUrl, {
    "signature": signature,
    "userid": userid,
    "query": text,
  })).data?.answer;
}
```

调用流程：先 `POST /openapi/sign/{token}` 获取签名（**2 小时过期**），再 `POST /openapi/aibot/{token}` 携带 `signature` / `userid` / `query` 获取 `answer`。

---

## 总结

- 接收消息：wechaty 事件驱动（scan / login / message），**务必加过滤逻辑**，避免对所有人生效
- 回复内容：规则简单用 if/else 正则，表达多变用微信对话开放平台的智能对话接口
- 原理：无头浏览器自动化操作网页版微信，人工操作 → 后台自动化

> 来源：鱼皮·编程导航 / codefather
