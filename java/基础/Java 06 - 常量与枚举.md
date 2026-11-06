---
title: "Java 基础 - 常量与枚举"
date: 2026-07-26
tags: [Java, 基础, 常量, 枚举, 魔法值]
source: "鱼皮·编程导航 / codefather"
---

# Java 基础 - 常量与枚举

> 用常量和枚举替代魔法值（魔法数字/字符串），提升代码可读性和可维护性。

## 核心要点

### 什么是魔法值

代码中直接出现的数字或字符串字面量，无法直接判断其代表的含义。

```java
// ❌ 不推荐 — 1 是什么？需要联系上下文才明白
gender.setGender(1);
```

阿里巴巴 Java 开发规范明确要求：**不允许任何魔法值直接出现在代码中**。

### 常量（`static final`）

**定义语法**：

```java
public class UserStatus {
    public static final Integer USER_NORMAL   = 0;  // 正常
    public static final Integer USER_ABNORMAL = 1;  // 异常
    public static final Integer USER_PROHIBIT = 2;  // 禁止
}
```

- 使用 `public static final` 修饰，一旦初始化不可修改
- 命名：全大写 + 下划线
- 编译阶段自动"宏替换"为字面量

**使用示例**：

```java
// ❌ 魔法值
user.setStatus(1);

// ✅ 常量
user.setStatus(UserStatus.USER_ABNORMAL);
```

### 枚举（`enum`）

**基本语法**：

```java
public enum SeasonEnum {
    UP, DOWN, LEFT, RIGHT;
}
```

**带值的枚举**：

```java
public enum UserStatusEnum {
    NORMAL(0),
    ABNORMAL(1),
    PROHIBIT(2);

    private final Integer value;

    UserStatusEnum(Integer value) {
        this.value = value;
    }

    public Integer getValue() {
        return value;
    }
}
```

**特点**：
- 继承 `java.lang.Enum`
- 最终类，不可被继承
- 构造器私有，不能通过 `new` 创建
- 第一行必须罗列枚举实例
- 相当于**多例模式**

### 常量 vs 枚举

| 对比项 | 常量 | 枚举 |
|--------|------|------|
| 类型约束 | 无（可传任意值） | 强（只能传定义好的实例） |
| 方法参数 | `setStatus(int)` 接受任何 int | `setStatus(UserStatusEnum)` 限定范围 |
| 可读性 | 好 | 更好 |
| 扩展性 | 好 | 一般 |

**枚举作为参数的优势**：

```java
// 调用方只能传递枚举定义的实例
public static void setStatus(UserStatusEnum userStatus) {
    User user = new User();
    user.setStatus(userStatus.getValue());
}
```

### 选择建议

- **简单常量分组**（无类型约束要求）→ 使用常量类如 `UserStatus`
- **需要强类型约束**（参数只能取特定值）→ 使用枚举
- **既要传值又要约束** → 枚举 + 构造器传值模式

> 来源：鱼皮·编程导航 / codefather
