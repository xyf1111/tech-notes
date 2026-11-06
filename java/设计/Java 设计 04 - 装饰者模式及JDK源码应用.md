---
title: "Java 设计 04 - 装饰者模式及JDK源码应用"
date: 2026-07-27
tags: [设计模式, 结构型模式, 装饰者模式, Java, InputStream]
source: "鱼皮·编程导航 / codefather"
---

# Java 设计 04 - 装饰者模式及JDK源码应用

> 装饰者模式允许在不改变对象结构的情况下，动态地向对象添加额外功能。通过将对象包装在装饰器对象中实现功能扩展。

## 核心思想

如毛坯房可用不同颜色装饰厨房、客厅，但房子本质不变。装饰者模式可以在不修改原类的前提下动态装饰对象，并可随意组合多个装饰类。

## 四种角色

| 角色 | 职责 | 示例（房子上色） |
|------|------|------------------|
| **Component** | 抽象组件类 | 房子抽象类 |
| **ConcreteComponent** | Component 的具体实现 | 商品房、公寓房 |
| **Decorator** | 通用装饰抽象类，内部保存被装饰的 Component | 抽象装饰器 |
| **ConcreteDecorator** | 具体装饰类 | 红色装饰、黄色装饰、绿色装饰 |

## Java 实现示例

### Component — 抽象房子
```java
public abstract class House {
    public abstract void show();
}
```

### ConcreteComponent — 商品房
```java
public class CommercialHouse extends House {
    @Override
    public void show() {
        System.out.println("这是一个商品房");
    }
}
```

### Decorator — 抽象装饰器
```java
public class HouseDecorator extends House {
    private House house;

    public HouseDecorator(House house) {
        this.house = house;
    }

    @Override
    public void show() {
        house.show();
    }
}
```

### ConcreteDecorator — 具体装饰类
```java
public class RedHouseDecorator extends HouseDecorator {
    public RedHouseDecorator(House house) { super(house); }
    @Override
    public void show() {
        super.show();
        System.out.println("装饰了红色");
    }
}

public class YellowHouseDecorator extends HouseDecorator {
    public YellowHouseDecorator(House house) { super(house); }
    @Override
    public void show() {
        super.show();
        System.out.println("装饰了黄色");
    }
}

public class GreenHouseDecorator extends HouseDecorator {
    public GreenHouseDecorator(House house) { super(house); }
    @Override
    public void show() {
        super.show();
        System.out.println("装饰了绿色");
    }
}
```

### 组合使用
```java
public class Main {
    public static void main(String[] args) {
        House house = new CommercialHouse();
        // 单独装饰
        House redHouse = new RedHouseDecorator(house);
        redHouse.show();
        // 组合装饰（绿色+黄色）
        House greenAndYellowHouse =
            new GreenHouseDecorator(new YellowHouseDecorator(house));
        greenAndYellowHouse.show();
        // 三种颜色全部装饰
        House allHouse = new RedHouseDecorator(
            new GreenHouseDecorator(new YellowHouseDecorator(house)));
        allHouse.show();
    }
}
```

如果用继承实现每种组合都需新建类，装饰者模式的优势明显。

## 在 JDK 源码中的应用：InputStream

Java I/O 流是装饰者模式的经典应用。以 `InputStream` 为例：

```java
// 组合使用：带缓存的文件流
new BufferedInputStream(new FileInputStream(""));
// 组合使用：可读取基本类型的数据流
new DataInputStream(new FileInputStream(""));
```

**结构分析：**
- **Component**：`InputStream`（抽象类，定义 `read()`）
- **ConcreteComponent**：`FileInputStream`、`ByteArrayInputStream` 等
- **Decorator**：`FilterInputStream`（持有 `InputStream` 引用，委托调用 `read()`）
- **ConcreteDecorator**：`BufferedInputStream`（加缓存）、`DataInputStream`（加基本类型读取）、`ObjectInputStream`（加对象读取）

```java
public abstract class InputStream implements Closeable {
    public abstract int read() throws IOException;
}

public class FilterInputStream extends InputStream {
    protected volatile InputStream in;

    protected FilterInputStream(InputStream in) {
        this.in = in;
    }

    public int read() throws IOException {
        return in.read();
    }
}
```

## 总结

装饰者模式很好地体现了**开闭原则**——类应对扩展开放，对修改关闭。通过组合而非继承的方式，在运行时动态扩展功能，避免了类爆炸。

> 来源：鱼皮·编程导航 / codefather
