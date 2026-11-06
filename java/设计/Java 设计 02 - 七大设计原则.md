---
title: "Java 设计 02 - 七大设计原则"
date: 2026-07-26
tags: [设计模式, 面向对象, SOLID]
source: "鱼皮·编程导航 / codefather"
---

# Java 设计 02 - 七大设计原则

> 面向对象设计的七条核心原则，用于提高软件的可维护性、可复用性、可扩展性和灵活性。

## 一、开闭原则（Open/Closed Principle）

**对扩展开放，对修改关闭。** 当程序需要扩展时，不修改原有代码，通过扩展（继承、实现）来实现新功能。

- 使用接口或抽象类定义稳定抽象
- 通过派生实现类来扩展新行为
- 降低修改风险，提高维护性

**示例：搜狗输入法皮肤设计**

定义皮肤抽象类，用户可自由扩展新皮肤而不修改输入法源码：

```java
// 抽象皮肤
public abstract class AbstractSkin {
    public abstract void display();
}

// 具体皮肤实现
public class DefaultSkin extends AbstractSkin {
    public void display() { System.out.println("默认皮肤"); }
}
public class HeiMaSkin extends AbstractSkin {
    public void display() { System.out.println("自定义皮肤"); }
}

// 输入法依赖抽象而非具体
public class SougouInput {
    private AbstractSkin skin;
    public void setSkin(AbstractSkin skin) { this.skin = skin; }
    public void display() { skin.display(); }
}
```

![开闭原则 - 输入法皮肤类图](../image/img_design_ocp_001.png)

## 二、里氏代换原则（Liskov Substitution Principle）

**任何基类出现的地方，子类一定可以出现。** 子类可以扩展父类功能，但不能改变父类原有功能——尽量不重写父类方法。

**经典反面案例：「正方形不是长方形」**

```java
// 错误继承：正方形重写 setter 导致死循环
public class Square extends Rectangle {
    public void setWidth(double w) {
        super.setLength(w);
        super.setWidth(w);
    }
}
// resize(rectangle) 传入 Square 后宽度永远 ≤ 长度，死循环
```

**改进方案：** 抽象四边形接口，Rectangle 和 Square 各自独立实现：

![里氏代换 - 四边形接口重构](../image/img_design_lsp_001.png)

```java
public interface Quadrilateral {
    double getLength();
    double getWidth();
}

public class Rectangle implements Quadrilateral { /* 长宽独立 */ }
public class Square implements Quadrilateral { /* 只有 side */ }
```

## 三、依赖倒转原则（Dependency Inversion Principle）

**高层模块不应依赖低层模块，两者都应依赖抽象；抽象不应依赖细节，细节应依赖抽象。**

- 面向接口编程，而非面向实现编程
- 抽象比实现更稳定

**示例：组装电脑**

```java
// 错误做法：Computer 直接依赖具体配件
public class Computer {
    private XiJieHardDisk hardDisk;  // 具体类
    private IntelCpu cpu;            // 具体类
    private KingstonMemory memory;   // 具体类
}
```

![依赖倒转 - 组装电脑原始设计](../image/img_design_dip_001.png)

**改进：** Computer 依赖配件接口而非具体实现

```java
public class Computer {
    private HardDisk hardDisk;  // 接口
    private Cpu cpu;            // 接口
    private Memory memory;      // 接口
}
```

![依赖倒转 - 改进设计](../image/img_design_dip_002.png)

## 四、接口隔离原则（Interface Segregation Principle）

**客户端不应依赖它不使用的方法；一个类对另一个类的依赖应建立在最小接口上。**

- 胖接口拆分为多个专用接口
- 避免实现类被迫实现不需要的方法

**示例：安全门功能拆分**

```java
// 错误：一个接口包含所有功能
public interface SafetyDoor {
    void antiTheft();
    void fireproof();
    void waterproof();
}

// 正确：拆分为三个独立接口
public interface AntiTheft { void antiTheft(); }
public interface Fireproof { void fireproof(); }
public interface Waterproof { void waterproof(); }

// HeiMa 门需要全部功能
public class HeiMaSafetyDoor implements AntiTheft, Fireproof, Waterproof {}
// Itcast 门只需要防盗和防火
public class ItcastSafetyDoor implements AntiTheft, Fireproof {}
```

![接口隔离 - 安全门接口拆分](../image/img_design_isp_001.png)

## 五、迪米特法则（Law of Demeter / Least Knowledge Principle）

**只和你的直接朋友交谈，不跟「陌生人」说话。** 两个软件实体无需直接通信时，不直接调用，通过第三方转发。

- "朋友"：当前对象本身、成员对象、创建的对象、方法参数
- 降低类间耦合，提高模块独立性

**示例：明星与经纪人**

```java
// 明星不直接与粉丝、媒体交互，全部通过经纪人
public class Agent {
    private Star star;
    private Fans fans;
    private Company company;

    public void meeting() {
        System.out.println(fans.getName() + "与明星" + star.getName() + "见面");
    }
    public void business() {
        System.out.println(company.getName() + "与明星" + star.getName() + "洽淡业务");
    }
}
```

![迪米特法则 - 明星经纪人模式](../image/img_design_lod_001.png)

## 六、合成复用原则（Composite/Aggregate Reuse Principle）

**优先使用组合或聚合关系实现复用，其次才考虑继承。**

| 继承复用（白箱） | 合成复用（黑箱） |
|---|---|
| 暴露父类实现细节 | 隐藏内部细节 |
| 父类变更影响子类（高耦合） | 低耦合 |
| 编译时确定（静态） | 运行时动态（灵活） |

**示例：汽车分类管理**

按「动力源」+「颜色」两种维度分类，继承方式会产生大量子类（汽油白车、电动白车、汽油黑车…）。改用聚合后，动力和颜色作为独立属性组合到 Car 中，大大减少类数量。

## 七、单一职责原则（Single Responsibility Principle）

**一个类应只负责一项职责。** 职责变更时不影响其他职责。

- 降低类的复杂度
- 提高可读性、可维护性
- 降低变更风险

```java
// 符合单一职责：按交通工具类型拆分
class RoadVehicle {
    public void run(String v) { System.out.println(v + " 在公路上跑"); }
}
class SkyVehicle {
    public void run(String v) { System.out.println(v + " 在空中飞"); }
}
class WaterVehicle {
    public void run(String v) { System.out.println(v + " 在水中游"); }
}
```

当类中方法足够少时，可在方法级别保持单一职责：

```java
// 方法级单一职责：同一个类不同方法处理不同行为
class Vehicle {
    public void run(String v)       { System.out.println(v + " 在公路上跑"); }
    public void runAir(String v)    { System.out.println(v + " 在天空飞行"); }
    public void runWater(String v)  { System.out.println(v + " 在水中游"); }
}
```

> 来源：鱼皮·编程导航 / codefather
