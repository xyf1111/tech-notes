---
title: "Java 工具 15 - IDEA 高效开发技巧"
date: 2026-08-26
tags:
  - java
  - idea
  - jetbrains
  - 开发效率
  - 插件
  - 快捷键
source: "鱼皮·编程导航 / codefather"
---

# Java 工具 15 - IDEA 高效开发技巧

> IDEA 是面向 Java 开发的专业 IDE，90% 以上的企业使用；善用实用插件、快捷键和内置工具，可显著提升日常开发与阅读源码的效率。

工欲善其事，必先利其器。IDEA 是 **面向 Java 开发的专业 IDE**（集成开发环境），**90% 以上**的企业使用 IDEA 进行 Java 开发，而不是 Eclipse 等其他工具。IDEA 功能丰富，但只有熟练使用才能发挥最大效率，本文总结**实用插件、开发技巧、阅读源码技巧**三大类使用心得。

如果还是**学生党**，可以**免费使用** IDEA 及 JetBrains 全系列产品：

地址：https://www.jetbrains.com/shop/eform/students

所有快捷键都可以在 preferences 的 keymap 设置中查询及自定义。

## 核心要点

- **IDEA 定位**：面向 Java 的专业 IDE，90% 以上企业使用；学生党可免费使用 JetBrains 全系列产品
- **快捷键入口**：preferences → keymap 中可查询和设置快捷键
- **实用插件 12 个**：快捷键提示、AI 补全、Arthas 诊断、代码生成、Git 增强、翻译等
- **开发技巧 6 条**：快捷键、Generate 生成代码、Live Templates、内置剪切板、内置 Git、内置 HTTP Client
- **阅读源码**：先看整体（包层级、类关系）再看局部（类属性、方法实现），配合 11 组快捷键
- 同为 IDEA 主题的文档：[[Java 工具 13 - IDEA Docker远程部署SpringBoot|Java 工具 13]]

## 实用插件

插件可在 Settings（Preferences）→ Plugins 中搜索安装，以下 12 个插件覆盖快捷键、代码生成、代码浏览、Git 增强、翻译等场景，地址均为 JetBrains 官方插件市场：

| 插件名 | 类型 | 作用 | 地址 |
| --- | --- | --- | --- |
| Key Promoter X | 快捷键提示 | 鼠标操作可被快捷键代替时给出提示，帮助自然养成快捷键习惯，告别死记硬背 | https://plugins.jetbrains.com/plugin/9792-key-promoter-x/ |
| AiXcoder Code Completer | 代码提示补全 | 使用 AI 自动提示和补全代码，比 IDEA 自带代码补全更智能 | https://plugins.jetbrains.com/plugin/13574-aixcoder-code-completer/ |
| Arthas Idea | 命令生成 | 自动生成 Arthas 在线 Java 代码诊断命令（Arthas 是阿里开源的 Java 在线诊断工具），不用再翻文档拼命令 | https://plugins.jetbrains.com/plugin/13581-arthas-idea/ |
| Auto filling Java call arguments | 代码生成 | 通过快捷键自动补全函数调用参数，针对包含大量参数的构造函数和方法非常有用 | https://plugins.jetbrains.com/plugin/8638-auto-filling-java-call-arguments/ |
| GenerateAllSetter | 代码生成 | 一键生成指定对象的所有 set 方法调用代码，单元测试造假数据时非常有用 | https://plugins.jetbrains.com/plugin/9360-generateallsetter/ |
| GenerateSerialVersionUID | 代码生成 | 一键为实现 Serializable 接口的类生成 SerialVersionUID | https://plugins.jetbrains.com/plugin/185-generateserialversionuid/ |
| GsonFormat | 代码生成 | 在类中使用，粘贴一段 JSON 文本即可自动生成对象的嵌套结构代码 | https://plugins.jetbrains.com/plugin/7654-gsonformat/ |
| Lombok | 代码生成 | 配合 Lombok 依赖及注解使用，大大减少 POJO 代码量；安装后需开启注解支持（配置参考 https://www.baeldung.com/lombok-ide ） | https://plugins.jetbrains.com/plugin/6317-lombok/ |
| Rainbow Brackets | 代码浏览 | 用颜色区分括号嵌套层级，便于阅读并更快定位调整错误代码（建议避免大量嵌套） | https://plugins.jetbrains.com/plugin/10080-rainbow-brackets/ |
| CodeGlance | 代码浏览 | 编辑器右侧生成代码小地图，可拖拽光标快速定位，阅读行数很多的代码文件时非常实用 | https://plugins.jetbrains.com/plugin/7275-codeglance/ |
| GitToolBox | Git 增强 | 在自带 Git 功能之上新增查看 Git 状态、自动拉取代码、提交通知等，最好用的是查看每一行代码的最近提交信息 | https://plugins.jetbrains.com/plugin/7499-gittoolbox/ |
| Translation | 翻译 | 鼠标选中文本点击右键即可自动翻译成多国语言，解决阅读代码遇英文单词的痛点 | https://plugins.jetbrains.com/plugin/8579-translation/ |

## 开发技巧

通过插件可以给 IDEA 增加新功能，但 IDEA 自带的功能也非常强大，以下 6 条开发技巧值得掌握：

### 1. 熟练使用快捷键

活用快捷键是使用任何 IDE 提升开发及阅读源码效率的前提。比较常用的是**换行、复制/删除当前行、代码格式化**等，可通过 Key Promoter X 插件渐进式熟悉快捷键。

快捷键参考文章（纯技术博客）：
- IDEA Mac 快捷键指南：https://www.jianshu.com/p/454c71172c46
- IDEA Win 常用快捷键：https://www.jianshu.com/p/5de7cca0fefc

### 2. 利用 Generate 快捷键快速生成代码

在类中使用 Generate 可快速生成构造器、Getter/Setter 等代码：
- Win：`Alt + Insert`
- Mac：`Command + N`

### 3. 运用代码模板（Live Templates）

代码模板是 IDEA 中非常好用的功能，可以**通过缩写（关键词）生成指定的代码段**，很多重复代码都可以快速生成，提高效率的同时降低出错概率。

- IDEA 内置了很多代码模板，如 `main`；
- 可以自定义缩写和要生成的代码段；
- 还支持预定义变量、自定义变量以及内置函数。

更多高级用法参考：IDEA 中 live template 的详细使用教程 https://www.jianshu.com/p/3974df6572af

### 4. 使用内置剪切板保存复制历史

写代码的必备技能是复制粘贴，不仅能提高效率，还能降低出错率（如用户、密钥、地址等信息）。

- IDEA 内置剪切板可保存复制历史，粘贴时按 `Shift + Ctrl + V` 即可选择要粘贴的内容；
- 不满足于内置剪切板，还可以使用更高级的软件：Ditto（Windows）或 Alfred（Mac）。

### 5. 使用内置的 Git

IDEA 内置 Git 辅助工具，能够**可视化分支管理/切换、代码提交/更新/冲突解决/回退、代码历史版本查看**等，在顶部菜单 `VCS > Git` 中查看所有功能；底部栏中可以查看 Git 日志。

### 6. 使用内置 HTTP Client 测试接口

不需要再使用 Postman 等外置接口测试工具，IDEA 内置了 HTTP Client，**通过编写请求脚本**进行接口调用，非常灵活，在顶部菜单 `Tools > HTTP Client` 中打开。

详细用法请阅读官方使用文档：https://www.jetbrains.com/help/idea/http-client-in-product-code-editor.html

## 常见坑：别被「包折叠」视图骗了

JetBrains 系列 IDE（IDEA / PyCharm 等）为了界面简洁，默认会在视图中**折叠空的中间包**，真实的目录层级可能被隐藏、甚至产生「障眼法」。

**踩坑案例**（MyBatis 配置文件找不到）：resources 目录下已有同事的配置结构 `aaa/config`（磁盘上两个真实嵌套目录，对应 Java 包 `aaa.config`）。照葫芦画瓢新建时，直接输入目录名 `bbb.config`——结果磁盘上创建的是**一个名字里带点号的单目录**，但在 IDE 折叠视图中它显示成 `bbb > config` 两层，和 `aaa/config` 看起来一模一样，肉眼无法分辨。

- 按 `bbb/config/sql-map-config.xml` 路径加载 → 运行时**找不到文件**（正确路径应为 `bbb.config/sql-map-config.xml`，目录名中的点不是路径分隔符）
- 逐目录对比两份配置看不出差异，进**构建产物目录**（如 `target/classes`）检查才发现真实结构

**排查与预防**：
1. 资源文件找不到时，先看报错信息，再到构建产物目录确认文件是否打包、打包后的真实目录结构——IDE 视图会骗人，构建产物不会
2. 需要嵌套包结构时**逐级创建目录**：先建 `bbb`，再在 `bbb` 下建 `config`，不要一次性输入 `bbb.config` 这类带点的目录名
3. 可在 Project 视图右上角关闭「折叠空中间包」（Compact Middle Packages），显示真实目录层级

## 阅读源码技巧

阅读源码遵循「先看整体、再看局部」的思路：

- **先看整体**：查看包的层级关系，分析包中类（接口）之间的关系——继承、实现、委托、方法调用；
- **再看局部**：查看某个类具体的属性（域）和方法实现。

IDEA 为整个阅读源码的过程提供了一系列快捷键支持，按用途分组如下：

**搜索定位**

1. **文件/类搜索**：根据文件名搜索文件/类（`Shift + Shift` 连按两次）
2. **字段搜索**：根据文件内容搜索并直接定位，支持局部（当前文件或选中代码段）和全局（项目/模块/目录/作用域等）
3. **跳转到上/下次光标位置**：查看源码时经常需要在多个类之间来回跳转，此功能非常实用

**关系分析**

4. **查看接口的实现类（或接口方法的实现）**：光标选中接口方法直接跳转到具体实现，有多个实现时可选择跳转到指定实现类
5. **查看方法调用树**：查看指定方法的所有调用方和被调方
6. **查看类关系图**：直观清晰地展现类的关系，便于分析
7. **查看类的继承树**：查看类的父类和子类继承关系

**变量追踪**

8. **查看变量声明/调用位置**：光标在声明处则查看使用该变量的代码，光标在使用处则查看变量的声明位置
9. **查看变量被调用位置**：功能与上类似，仅查看变量的调用位置

**结构与历史**

10. **查看类的结构**：查看属性、域、方法、继承方法、匿名类、Lambdas，并快速跳转到指定位置
11. **查看每行代码的提交信息**（需被 Git 管理）：在行号处右键，点击 Annotate 开启，可快速定位每一行代码的提交来源

快捷键汇总表：

| 功能 | Win | Mac |
| --- | --- | --- |
| 文件/类搜索 | `Shift + Shift`（连按两次） | `Shift + Shift`（连按两次） |
| 字段搜索（局部） | `Ctrl + F` | `Command + F` |
| 字段搜索（全局） | `Ctrl + Shift + F` | `Command + Shift + F` |
| 跳转上次光标位置 | `Alt + ←` | `Option + Command + ←` |
| 跳转下次光标位置 | `Alt + →` | `Option + Command + →` |
| 查看接口实现类 | `Ctrl + Alt + B` | `Option + Command + B` |
| 查看方法调用树 | `Ctrl + Alt + H` | `Control + Option + H` |
| 查看类关系图 | `Ctrl + Alt + U` | `Shift + Option + Command + U` |
| 查看类继承树 | `Ctrl + H` | `Control + H` |
| 查看变量声明/调用位置 | `Ctrl + B`（或按住 Ctrl 点击） | `Command + B`（或按住 Command 点击） |
| 查看变量被调用位置 | `Ctrl + Alt + F7` | `Option + Command + F7` |
| 查看类结构 | `Alt + 7` | `Command + 7` |
| 查看每行代码提交信息 | 行号处右键 → Annotate | 行号处右键 → Annotate |

> 来源：鱼皮·编程导航 / codefather
