---
title: "Java 进阶 - @Validated 参数校验实践"
date: 2026-08-18
tags: [Java, SpringBoot, 参数校验, 注解]
source: "鱼皮·编程导航 / codefather"
---

# Java 进阶 - @Validated 参数校验实践

> 使用 `@Validated` 注解将参数校验从手写 if 判断改为声明式配置：Controller 接收参数处加 `@Validated`，实体类字段加校验注解（如 `@NotBlank`），即可自动完成非空、长度、数值范围等校验，失败时统一抛异常返回错误信息。

## 为什么用注解校验

手写 if 校验的缺点（常见写法：`if (userName == null || userName.trim().isEmpty())` 之类）：

- 每个 Controller 都要写一遍，甚至每个 Service 层也要重复同样的校验
- 代码繁琐、容易遗漏，漏写一处就可能在运行时出问题
- 校验逻辑与业务逻辑混在一起，可读性差

`@Validated` 声明式校验的好处：

- 校验规则写在实体类字段上，一处定义、处处生效
- 校验失败自动抛异常，配合全局异常处理统一返回错误信息
- 代码简洁、易维护

## 基本用法

1. 在 Controller 层接收参数处添加 `@Validated` 注解
2. 在对应的实体类字段上加校验注解（如 `@NotBlank`），即可生效
3. 校验失败会直接抛异常，配合全局异常处理统一封装错误信息返回前端

## 常用校验注解

### 空检查

| 注解 | 说明 |
| --- | --- |
| `@Null` | 验证对象是否为 null |
| `@NotNull` | 验证对象是否不为 null，无法检查长度为 0 的字符串 |
| `@NotBlank` | 检查约束字符串是否为 null，且去空格（trim）后长度是否大于 0；只对字符串生效，会去掉前后空格 |
| `@NotEmpty` | 检查约束元素是否为 null 或 EMPTY（空） |

### Boolean 检查

| 注解 | 说明 |
| --- | --- |
| `@AssertTrue` | 验证 Boolean 对象是否为 true |
| `@AssertFalse` | 验证 Boolean 对象是否为 false |

### 长度检查

| 注解 | 说明 |
| --- | --- |
| `@Size(min=, max=)` | 验证对象（Array、Collection、Map、String）长度是否在给定的范围之内 |
| `@Length(min=, max=)` | 验证注解的元素值长度在 min 和 max 区间内（Hibernate 扩展） |

### 日期检查

| 注解 | 说明 |
| --- | --- |
| `@Past` | 验证 Date 和 Calendar 对象是否在当前时间之前 |
| `@Future` | 验证 Date 和 Calendar 对象是否在当前时间之后 |
| `@Pattern` | 验证 String 对象是否符合正则表达式的规则 |

### 数值检查

| 注解 | 说明 |
| --- | --- |
| `@Min` | 验证 Number 和 String 对象是否大于等于指定的值 |
| `@Max` | 验证 Number 和 String 对象是否小于等于指定的值 |
| `@DecimalMax` | 被标注的值必须不大于约束中指定的最大值；参数是通过 BigDecimal 定义的最大值的字符串表示，小数存在精度 |
| `@DecimalMin` | 被标注的值必须不小于约束中指定的最小值；参数是通过 BigDecimal 定义的最小值的字符串表示，小数存在精度 |
| `@Digits` | 验证 Number 和 String 的构成是否合法；`@Digits(integer=, fraction=)` 验证字符串是否是符合指定格式的数字，integer 指定整数精度，fraction 指定小数精度 |
| `@Range(min=, max=)` | 验证注解的元素值在最小值和最大值之间（Hibernate 扩展），如 `@Range(min=10000, max=50000, message="range.bean.wage") private BigDecimal wage;` |

> **建议**：数值校验用在 String、Integer 类型上，不建议用在 int 类型上。因为表单值为 ""（空字符串）时无法转换为 int，但可以转换为 String 的 ""、Integer 的 null。

### 其他

| 注解 | 说明 |
| --- | --- |
| `@Valid` | 递归地对关联对象进行校验；若关联对象是集合或数组，则对其中的元素递归校验；若是 Map，则对其值部分校验 |
| `@Email` | 验证是否是邮件地址；若为 null 则不校验，算通过验证 |
| `@CreditCardNumber` | 信用卡号验证 |
| `@URL(protocol=, host=, port=, regexp=, flags=)` | URL 格式验证 |
| `@ScriptAssert(lang=, script=, alias=)` | 脚本断言校验 |

## 与全局异常处理配合

- `@Validated` 校验失败时抛出 `MethodArgumentNotValidException`（@RequestBody 场景）、`BindException`（表单绑定场景）等异常
- 可在 `@RestControllerAdvice` 全局异常处理器中统一捕获，提取字段错误信息（FieldError）并返回统一响应格式
- 全局异常处理（GlobalExceptionHandler）的实现细节可参考 [[Java 21 - 异常处理机制]]
