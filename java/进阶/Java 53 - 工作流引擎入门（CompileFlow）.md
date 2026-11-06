---
title: "Java 53 - 工作流引擎入门（CompileFlow）"
date: 2026-08-23
tags: [Java, 工作流, CompileFlow, Activiti, 中间件]
source: "鱼皮·编程导航 / codefather"
---

# Java 53 - 工作流引擎入门（CompileFlow）

> 用工作流引擎把业务流程可视化建模为流程图，让引擎生成执行代码，替代大量手写 if else，降低复杂业务流程的开发与维护成本。

## 什么是工作流

- 工作流 = 一系列工作组成的流程，像工厂流水线：确认生产步骤后，每个工人只需做好自己的事
- 企业业务流程往往很复杂，加上多人协作开发，大家都在一个文件里写 if else 不现实
- **工作流引擎**：通过可视化拖拽绘制流程图，自动生成业务流程执行代码，不用手写 if else，大幅降低开发成本，非程序员也能参与

## 主流工作流引擎

| 引擎 | 特点 |
|------|------|
| Activiti | 成熟，企业开发中使用广泛 |
| flowable-engine | 成熟（Activiti 分支） |
| CompileFlow | 轻量纯净、易上手，适合入门理解（本文演示） |

> 企业级开发推荐 Activiti 等成熟引擎；CompileFlow 文档精简、更新较慢，仅作入门演示。

## CompileFlow 实战：养鸡考核系统

需求：每只鸡依次通过 唱/跳/RAP/篮球 四项考核，且练习时长两年半才能出售，否则打回重新练习。用 if else 实现会是一大段嵌套分支，改用工作流引擎。

### 1. 准备

- 引入 CompileFlow 依赖，或直接克隆官方示例项目 compileflow-demo（Maven + Spring Boot）
- 目录中的 `.bpm` 文件是 XML 编写的业务流程管理文件，手写复杂 → 安装 **Compileflow Designer** 插件即可可视化编辑

### 2. 新建流程

- 在 resources 目录下新建 `.bpm` 文件（如 `ji.bpm`），编辑器底部切换到可视化编辑视图
- 左侧内容是**节点**：每个流程图必须包含一个开始和一个结束节点，不同节点有不同的流程控制规则
- 节点可以指向其他节点表示执行顺序，双击节点可编辑名称
- 画好的流程图是静态的，需要绑定数据与代码才能跑起来

### 3. 绑定数据（上下文）

- **上下文** = 整个流程的输入/输出（可理解为全局变量），每个节点都能读取
- 双击编辑器空白处配置上下文；注意 `inOutType` 取值：全局入参用 `param`、全局返回值用 `result`、部分节点间传递变量用 `inner`

### 4. 绑定方法

- 从 if else 程序中提取每个分支为独立方法（如 checkChang、考核成功、考核失败），每个节点一个方法
- 双击节点 → 行为配置 → 选择方法 → 配置输入参数（从上下文获取）与返回值（同步给上下文）

### 5. 绑定条件

- 单击箭头输入表达式，表达式成立则往下执行
- 可配置优先级决定判断顺序（类似代码中 if else 的顺序）

### 6. 执行流程

```java
// 输入一只鸡，放到上下文，调用引擎 start 即可拿到结果
Map<String, Object> context = new HashMap<>();
context.put("ji", ji);

ProcessEngine processEngine = ProcessEngineFactory.getProcessEngine();
Map<String, Object> result = processEngine.start("bpm.ji", context);
System.out.println(result.get("result"));
```

## 原理

- CompileFlow 的原理：将用户编辑好的 XML 视图文件**编译为 Java 代码**（全局变量、流程等都在里面）
- 底层其实还是用到了 if else，但开发者不再需要关心这些流程控制代码——定义好流程、写好每个节点要做的工作即可

## 适用场景

- 工作流引擎在 **ERP、OA 系统**中使用较多（复杂审批/业务流程）
- 简单程序用 if else 没问题——任何技术都要结合实际场景选择是否运用
- 进阶练习：跑通 demo 项目中的 `orderFulfillmentFlow.bpm` 复杂示例，感受工作流引擎开发的高效

> 来源：鱼皮·编程导航 / codefather
