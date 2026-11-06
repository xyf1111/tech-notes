---
title: "Java 设计 03 - 命令模式入门实战"
date: 2026-07-27
tags: [设计模式, 行为型模式, 命令模式, Java]
source: "鱼皮·编程导航 / codefather"
---

# Java 设计 03 - 命令模式入门实战

> 命令模式将每个请求封装为独立对象，实现请求发送者与接收者的解耦，支持请求排队、记录和撤销。

## 核心思想

将每种请求或操作封装为一个独立对象，从而可以集中管理——将请求队列化依次执行，或对操作进行记录和撤销。通过解耦请求发送者（客户端）和接收者（执行请求的对象），提供更大的灵活性和可维护性。

**类比：** 电视机遥控器。用户（客户端）通过遥控器（调用者）的按钮（具体命令）来控制电视（接收者），遥控器丢失可更换，手机也能当万能遥控器控制多个品牌设备。

## 优点与应用场景

- **解耦**发送者和接收者
- **开闭原则友好**：新增命令无需改现有代码
- 系统需统一处理多种复杂操作（排队、历史记录、撤销重做）
- 需持续增加新命令或处理复杂组合命令

## 五大要素

### 1）命令（Command）
抽象类或接口，定义 `execute()` 方法，封装具体操作。

```java
public interface Command {
    void execute();
}
```

### 2）具体命令（ConcreteCommand）
命令接口的实现类，将请求传递给接收者并执行操作。

```java
public class TurnOffCommand implements Command {
    private Device device;

    public TurnOffCommand(Device device) {
        this.device = device;
    }

    public void execute() {
        device.turnOff();
    }
}

public class TurnOnCommand implements Command {
    private Device device;

    public TurnOnCommand(Device device) {
        this.device = device;
    }

    public void execute() {
        device.turnOn();
    }
}
```

### 3）接收者（Receiver）
执行命令的对象，知道如何执行具体操作。

```java
public class Device {
    private String name;

    public Device(String name) {
        this.name = name;
    }

    public void turnOn() {
        System.out.println(name + " 设备打开");
    }

    public void turnOff() {
        System.out.println(name + " 设备关闭");
    }
}
```

### 4）调用者（Invoker）
接受客户端命令并执行。可扩展存储历史记录、撤销重做等能力。

```java
public class RemoteControl {
    private Command command;

    public void setCommand(Command command) {
        this.command = command;
    }

    public void pressButton() {
        command.execute();
    }
}
```

### 5）客户端（Client）
创建命令对象并与接收者关联，将命令对象传递给调用者触发执行。

```java
public class Client {
    public static void main(String[] args) {
        Device tv = new Device("TV");
        Device stereo = new Device("Stereo");

        TurnOnCommand turnOn = new TurnOnCommand(tv);
        TurnOffCommand turnOff = new TurnOffCommand(stereo);

        RemoteControl remote = new RemoteControl();

        remote.setCommand(turnOn);
        remote.pressButton();

        remote.setCommand(turnOff);
        remote.pressButton();
    }
}
```

## 关系结构

```
Client → Invoker → Command (接口)
                      ↑
              ConcreteCommand → Receiver
```

## 实战应用

- **yuindex 网页终端项目**（[GitHub: liyupi/yuindex](https://github.com/liyupi/yuindex)）：以命令模式为核心实现，将用户输入的命令封装为独立命令对象执行，前后端同学都可参考学习。

> 来源：鱼皮·编程导航 / codefather
