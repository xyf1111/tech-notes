---
title: "Python 01 - 学习路线"
date: 2026-08-01
tags: [Python, 编程语言, 学习路线]
source: "鱼皮·编程导航 / codefather"
---

# Python 学习路线

> 本路线基于 codefather（鱼皮·编程导航）《2026 年最新 Python 学习路线》整理，去除商业推广内容，保留核心知识点、官方文档链接与学习建议。涵盖 Python 基础、Python 进阶、Web 开发、爬虫开发、数据分析、AI 开发、自动化运维/测试、项目实战与常用类库 9 个部分，零基础到精通一条龙。

## 开篇介绍

Python 诞生于 1991 年，由荷兰程序员 Guido van Rossum 创造。其设计哲学强调代码可读性和简洁性，语法接近自然语言，被称为"最适合人类阅读的编程语言"。

**为什么 Python 这么火？**

- 语法简单易学，开发效率极高，其他语言 5 行代码才能实现的功能，Python 一行搞定
- 类库生态极其丰富，想做什么功能基本都有现成的库可用
- 是数据科学、人工智能、机器学习的首选语言，几乎所有主流 AI 框架（TensorFlow、PyTorch、LangChain 等）都基于 Python

**学 Python 前要明确目标（"学了 Python 找不到工作"的说法要理性看待）：**

- 想快速找开发工作 → 不建议把 Python 作为主语言，建议主学 Java 或 Go，把 Python 当辅助工具（写脚本、自动化办公、小工具、爬虫）
- 目标是 AI / 数据科学 / 算法研究 → Python 必学且要深入学习，同时加强算法、数学、领域知识的学习
- 初学编程或出于兴趣 → 建议学 Python，语法简单、容易培养兴趣，有了编程基础再学其他语言很快

> 📺 视频：[保姆级 Python 学习路线](https://www.bilibili.com/video/BV133411C7u5/)

### 就业方向

1. **Python 后端开发工程师** — Django、Flask、FastAPI 开发 Web 应用和后端服务（岗位相对 Java/Go 少，适用于对开发速度要求高、性能要求不极致的场景）
2. **数据分析师** — Pandas、NumPy、Matplotlib 数据处理与可视化，需统计学、业务分析知识（Python 岗位中需求较大）
3. **AI 算法工程师** — 机器学习、深度学习、NLP、CV 算法研究与开发；门槛高，需深厚数学与算法功底，一般要求研究生及以上学历
4. **AI 应用开发工程师** — 调用大模型 API 开发智能对话、内容生成等 AI 应用；AI 时代新兴方向，门槛相对算法岗低，需熟悉 LangChain 与大模型 API
5. **爬虫工程师** — requests、BeautifulSoup、Scrapy 抓取网络数据，需了解反爬虫技术
6. **自动化测试工程师** — pytest、selenium 编写接口测试、UI 测试脚本
7. **运维工程师** — Linux、Shell 脚本 + Python 运维脚本实现自动化运维
8. **数据工程师** — 数据采集、清洗、处理，需熟悉大数据技术（Spark、Hadoop）

---

## 整体学习建议

1. **明确学习目标** — Python 应用方向很多，学习前先明确自己的方向，不要什么都想学、最后什么都学不精
2. **先打好基础** — 无论选哪个方向，基础语法和常用库都要先学扎实，基础打牢后面学什么都快
3. **善用 AI 工具** — Python 与 AI 结合最紧密，学习时可大胆用 AI 辅助：不懂的问 AI、卡壳了让 AI 生成模板代码
4. **多动手实践** — 边学边做：学完基础写自动化脚本，学完爬虫爬点数据分析，学完 AI 做个聊天机器人
5. **工具属性** — 非 AI/数据方向的同学把 Python 当工具学，需要时查文档、用 AI 辅助写代码即可，不必过度深究

---

## 阶段 1：Python 基础（15-30 天，仅供参考）

### 学习目标

掌握 Python 基础语法与面向对象编程，能够编写简单的 Python 程序。

### 知识点

- **开发环境** — Python 安装；开发工具推荐 PyCharm 社区版（免费够用）或 VS Code + Python 插件
- **变量** — 定义变量、关键字、命名规则、基本数据类型、类型转换
- **运算符和表达式**
- **流程控制** — 条件分支、循环
- **基本数据结构** — 字符串、列表、元组、集合、字典
- **函数** — 定义、参数传递、作用域、lambda 表达式、常用内置函数
- **⭐ 面向对象编程** — 类和对象；三大特性：封装（self、属性、方法、访问控制）、继承（单继承、多继承）、多态（方法重写）；运算符重载、装饰器、反射
- **模块和包** — 导入/生成模块、导入/生成包；常用模块（文件处理、日期时间）
- **异常处理** — 捕获异常、try...else...finally 结构、自定义异常
- **文件操作** — 文件开闭、文件读写

### 学习重点

- 面向对象编程是 Python 基础的核心，务必学透
- 基础打牢再进入下一阶段，不要赶进度

### 学习资源

- ⭐ [黑马程序员 Python + AI 大模型零基础到项目实战](https://www.bilibili.com/video/BV1h1VbzHER2/)：涵盖 Python、Linux、LangChain、大模型应用开发
- ⭐ [千锋教育 700 集零基础 Python 教程](https://www.bilibili.com/video/BV1R7411F7JV)：基础、Web、爬虫、数据分析、AI 全覆盖
- [黑马程序员 600 集 Python 教程](https://www.bilibili.com/video/BV1ex411x7Em)：基于 Linux 环境
- [2025 最新 Python 全套教程](https://www.bilibili.com/video/BV1sSZ7Y1EiT/)：400 集，B 站最全最细
- ⭐ [Python 官方文档（中文）](https://docs.python.org/zh-cn/3/)：官方文档，必读

---

## 阶段 2：Python 进阶（15-20 天，仅供参考）

### 学习目标

掌握并发编程、网络编程、数据库编程等进阶能力，写出 Pythonic 的代码。

### 知识点

- **函数进阶** — 闭包、匿名函数、生成器函数、装饰器、高阶函数
- **正则表达式**
- **数据库编程** — 数据库基础、SQL 编写（查询：聚合/分组/关联/排序）、事务、数据库设计、数据库调优
- **并发编程** — 同步和异步、阻塞和非阻塞、多线程、多进程、协程、并发类库
- **网络编程** — 网络基础（七层模型、IP）、网络协议（TCP、UDP、HTTP、HTTPS、FTP、DNS）、WebSocket

### 学习重点

- 并发编程包含多线程、多进程、协程三种方式，各有应用场景；协程（asyncio）尤其重要，现代框架（如 FastAPI）基于协程实现
- 阅读 [PEP 8 代码规范](https://peps.python.org/pep-0008/) 学习如何写出 Pythonic 的代码

---

## 方向 1：Web 开发（选学，30-45 天）

### 学习目标

掌握 Django 框架开发 Web 应用的能力，了解 Flask / FastAPI。

### 知识点

- **Django 框架** — 安装和跑 Demo、MVT 分层、模型（ORM：单表/多表/聚合查询）、视图、模板（模板语法、静态资源）、路由、Django Admin 管理工具、测试、会话、鉴权、文件上传、中间件
- **Django 高级特性** — 分页、缓存（本地缓存、Redis 分布式缓存）、序列化、信号、Celery 任务调度
- **RESTful API 开发** — 概念、数据序列化、Django Rest Framework
- **部署与项目实战**
- **Flask 框架**
- **前端基础** — HTML、CSS、JavaScript

### 学习重点

- 新手建议从 Django 开始学（功能最全面）
- Python Web 岗位相对 Java/Go 少很多，若以 Web 开发求职建议主学 Java 或 Go，Python 作为辅助

### 学习资源

- ⭐ [Django 官方教程（中文）](https://docs.djangoproject.com/zh-hans/5.1/)
- [FastAPI 官方文档（中文）](https://fastapi.tiangolo.com/zh/)：现代 Python Web 框架

---

## 方向 2：爬虫开发（选学，20-30 天）

### 学习目标

掌握数据抓取、解析、导出的能力，能编写爬虫脚本与 Scrapy 爬虫项目。

### 知识点

- **概念与合法性** — 遵守 robots.txt 协议、不爬取个人隐私信息、不对网站造成压力；违法爬虫需承担法律责任
- **数据抓取** — HTTP/HTTPS 协议概念、请求（请求头、请求参数、请求类型）、响应（响应头、响应参数）、requests 模块、urllib 模块、模拟登录、静态/动态网站抓取、无头浏览器（selenium、puppeteer）
- **数据解析** — 常用标签、BeautifulSoup、正则表达式、xpath
- **数据导出** — 文件（Excel、CSV）、数据库（MongoDB、MySQL）、中间件（Redis）
- **Scrapy 框架** — 核心概念（命令行工具、Spiders、Selectors、Items、Item Loaders、管道、Scrapy Shell、Link Extractors）、调度器、分布式爬虫、部署
- **并发异步爬虫** — aioHttp、asyncio
- **高级** — IP 代理、验证码识别、APP 抓取、增量式爬虫
- **反爬虫** — 请求头限制、验证码、黑白名单、封禁 IP、数据加密、数据混淆、行为分析

### 学习重点

- 爬虫岗位少且存在法务风险，建议把爬虫当成一项技能来学，而不是作为主要求职方向
- 始终在合法范围内爬取数据

### 学习资源

- [2020 年 Python 爬虫全套课程](https://www.bilibili.com/video/BV1Yh411o7Sz)：学完可做项目
- [Python 爬虫编程基础 5 天速成](https://www.bilibili.com/video/BV12E411A7ZQ)：快速入门
- [Scrapy 官方文档](https://docs.scrapy.org/en/latest/)

---

## 方向 3：数据分析 / 数据科学（选学，45-60 天）

### 学习目标

掌握使用 Python 进行数据处理、分析与可视化的能力。

### 知识点

- **环境搭建** — Anaconda、Conda、Miniconda、Jupyter Notebook
- **常用类库** — NumPy（数组、索引、切片、多维数组、函数）、Pandas（Series、DataFrame、索引、对齐、函数、统计）
- **数据处理** — 数据清洗、层次化索引、数据连接、数据合并、分组聚合、轴向旋转
- **数据可视化** — matplotlib、seaborn、pyecharts

### 学习重点

- 需要一定数学基础（统计学、概率论、线性代数等），基本概念要理解
- 最好的学习方法是使用真实数据集练习，可从 [Kaggle](https://www.kaggle.com/)、UCI 等网站下载数据集做分析项目

### 学习资源

- [自学数据分析课程](https://www.bilibili.com/video/BV1ZM4y1u7uF)：数据分析 + 可视化，适合办公党
- [Pandas 官方文档](https://pandas.pydata.org/docs/)
- [NumPy 官方文档](https://numpy.org/doc/)

---

## 方向 4：AI 开发（选学，60+ 天）

### 学习目标

理解机器学习与深度学习基本概念，或掌握大模型 API 应用开发能力。

### 知识点

- **数学基础** — 高等数学、线性代数、概率论、统计分析
- **机器学习** — 特征工程、模型（模型分类、评估、训练、调优）、常用算法：
  - 回归（有监督）：线性回归、决策树、集成算法
  - 分类（有监督）：逻辑回归、决策树、支持向量机、集成算法、贝叶斯算法
  - 聚类（无监督）：k-means、dbscan
  - 降维：主成分分析（PCA）、线性判别分析（LDA）
  - 进阶：GBDT 提升算法、LightGBM、EM 算法、隐马尔科夫模型
  - 常用库：Scikit-learn
- **深度学习** — 数据预处理、神经网络、卷积神经网络（CNN）、递归神经网络（RNN）、对抗生成网络（GAN）、序列网络模型；框架：TensorFlow、PyTorch、Keras、Caffe
- **自然语言处理（NLP）**
- **图像处理 / 计算机视觉（CV）**
- **AI 应用开发** — 调用大模型 API（LangChain 等）开发 AI 应用

### 学习重点

- AI 分两个方向：算法研究（机器学习、深度学习，门槛极高）与应用开发（调用大模型 API，门槛低、机会多）
- 没有读研打算、数学基础不好、无相关专业背景 → 不建议选算法方向；AI 应用开发是当前新机会

### 学习资源

- ⭐ [黑马程序员 Python + AI 大模型实战](https://www.bilibili.com/video/BV1h1VbzHER2/)：从大模型私有化部署到应用开发
- [AI 大模型开发教程 2024](https://www.bilibili.com/video/BV1tE4m1d7Xy/)：3 天训练营，零基础可学
- [LLM Universe - 大模型应用开发教程](https://github.com/datawhalechina/llm-universe)：基于个人知识库的大模型应用开发
- [TensorFlow 官方教程](https://www.tensorflow.org/tutorials?hl=zh-cn)
- [PyTorch 官方教程](https://pytorch.org/tutorials/)

---

## 方向 5：自动化运维 / 测试（选学，15-20 天）

### 学习目标

掌握用 Python 编写运维脚本与自动化测试脚本的能力。

### 知识点

- **Linux 环境** 与 **Shell 脚本编写**
- **Python 运维库** — psutil（系统和进程管理）、paramiko（远程连接）、fabric（自动化部署）
- **自动化测试** — pytest（测试框架）、selenium（Web 自动化测试）、unittest（单元测试）
- **CI/CD** — Jenkins、GitLab CI

### 学习资源

- [Ansible 官方文档](https://docs.ansible.com/)：自动化运维工具
- [pytest 官方文档](https://docs.pytest.org/)：Python 测试框架
- [selenium 官方文档](https://www.selenium.dev/documentation/)：Web 自动化测试

---

## 项目实战

学完基础后一定要动手做项目，项目是简历上最有力的证明。

### 项目推荐

- ⭐ [2025 最新 42 个 Python 实战项目](https://www.bilibili.com/video/BV1fTW2zqEgA/)：从入门到进阶
- [2025 最新 32 个 Python 实战项目](https://www.bilibili.com/video/BV1VptEztEGc/)：附源码
- [2025 最新 108 个 Python 实战项目](https://www.bilibili.com/video/BV1zuRPYRERJ/)：从 0 到 1 完整开发教程
- ⭐ [Python - 100 天从新手到大师](https://github.com/jackfrued/Python-100-Days)：112k stars，系统学习项目
- [awesome-python-applications](https://github.com/mahmoud/awesome-python-applications)：开源 Python 应用程序大全

---

## 常用类库

Python 能被广泛应用，很大程度上得益于丰富的类库——基本你想做什么都能找到对应的现成库，看文档直接用即可。开源合集：[awesome-python](https://github.com/vinta/awesome-python) 与 [awesome-python-cn](https://github.com/jobbole/awesome-python-cn)。以下按方向整理常用库：

- **网络请求 & 解析** — requests、aiohttp、scrapy、pyspider、BeautifulSoup、you-get、wget
- **文件处理** — openpyxl（Excel）、python-docx（Word）、PyPDF2、pdfminer、html2text、xmltodict、moviepy
- **Web 开发** — Django、Django REST framework、FastAPI、Flask、Twisted
- **数据分析 & 数据科学** — NumPy、Pandas、SciPy、matplotlib、Seaborn、statsmodels、pyecharts、Dash
- **人工智能** — TensorFlow、Keras、PyTorch、scikit-learn、XGBoost、mmdetection、Gym
- **自然语言处理** — NLTK、Gensim、jieba、TextBlob、fuzzywuzzy
- **图像处理 & 计算机视觉** — Pillow、OpenCV、kornia、Mahotas
- **自动化运维** — psutil、supervisor、paramiko、Ansible、SaltStack、watchdog、scapy
- **界面开发** — PyQt、Pygame、wxPython、Manim、tqdm
- **通用工具** — Pipenv（包管理）、threading、multiprocessing、logging、chardet、PySnooper（调试）、sphinx（文档生成）、cryptography、dateutil（日期处理）

---

## 持续学习资源

### 官方资源

- ⭐ [Python 官方网站](https://www.python.org/)
- ⭐ [Python 官方文档（中文）](https://docs.python.org/zh-cn/3/)：必读
- [Python 官方教程](https://docs.python.org/zh-cn/3/tutorial/)
- [PEP 8 代码规范](https://peps.python.org/pep-0008/)
- [Python 常见问题 FAQ](https://docs.python.org/zh-cn/3/faq/general.html)

### 视频教程（按方向补充）

零基础与综合（各阶段已推荐的千锋 700 集、黑马 600 集等见上文「学习资源」）：

- [小甲鱼《零基础入门学习 Python》最新版](https://www.bilibili.com/video/av52080698)：经典入门系列（可惜未更完）
- [麻省理工学院 · Python 和计算机科学导论（中文字幕）](https://www.bilibili.com/video/BV1ty4y1x7xP)：适合外语不错的同学课外看，感受国外教学氛围
- [Python 全栈开发教程](https://www.bilibili.com/video/BV1wD4y1o7AS)：纯粹的 Python 基础教程，案例多，适合快速入门
- [阿里云 Python 工程师学习路径](https://developer.aliyun.com/graph/python)：含在线编程体验

按方向：

- Web 开发：[Python Django 项目实战教程](https://www.bilibili.com/video/BV1pq4y1W7a1)、[Python + 微信小程序实战开发](https://www.bilibili.com/video/BV1Xy4y1s792)（后台用 Django 框架，比较完整）
- 数据结构与算法：[Python 数据结构与算法全套 100 节](https://www.bilibili.com/video/BV1uA411N7c5)、[北京大学 · 数据结构与算法 Python 版（完整版）](https://www.bilibili.com/video/BV1VC4y1x7uv)
- 数据分析：[完整数据分析课程（数据分析 + 机器学习）](https://www.bilibili.com/video/BV1vV411p7D6)、[Python 数据分析入门视频合集](https://shimowendang.com/docs/36pykCPH6XCjKJcv/read)（图形化笔记）
- 实战练手：[一天搞定人脸识别项目（Python + OpenCV）](https://www.bilibili.com/video/BV1Lq4y1Z7dm)、[Python 自动化办公](https://www.bilibili.com/video/BV1uv411W7Fi)（主要处理 Excel）

### 在线教程与实战平台

- ⭐ [Python - 100 天从新手到大师](https://github.com/jackfrued/Python-100-Days)：112k star 系统教程
- [廖雪峰 Python 教程](https://www.liaoxuefeng.com/wiki/1016959663602400)：图文并茂的入门教程
- [莫烦 Python 教程](https://mofanpy.com/)：基础、数据处理、机器学习
- [Google Python 代码规范](https://google.github.io/styleguide/pyguide.html)
- ⭐ [蓝桥云课 Python 实战合集](https://www.lanqiao.cn/courses/?fee=free&tag=Python)：免费在线实战
- [CheckiO 游戏学 Python](https://py.checkio.org/)
- [Python 在线编程](https://www.online-python.com/)：在线运行 Python 代码
- [菜鸟教程 Python 3 教程](https://www.runoob.com/python3/python3-tutorial.html)：可在线写代码练习；[W3Cschool Python 教程](https://www.w3cschool.cn/python3/) 支持手机阅读（通用学习网站清单见 [[工具 34 - 编程学习网站与资源推荐]]）
- [Python 中文学习大本营](http://www.pythondoc.com/)：一系列文档教程的集合
- [A Byte of Python](https://python.swaroopch.com/)：英文入门教程
- [Python Guide（英文）](https://docs.python-guide.org/)：Python 项目工程化与最佳实践
- [Python Module of the Week](https://pymotw.com/3/)：常用模块逐个讲解，写脚本时很实用
- [Manim 动画引擎教程](https://docs.manim.org.cn/shaders/)：用代码做数学动画
- 云端实验环境（免本地配环境）：[腾讯云在线 Python 实验](https://cloud.tencent.com/developer/labs/gallery?tagId=23)、[阿里云 Python 入门实验](https://developer.aliyun.com/adc/scenario/e04fe73ad95d4782aef7aecca206196e)、[华为云沙箱实验室](https://lab.huaweicloud.com/testList.html)
- [Python123](https://python123.io/index)：在线编程练习平台（部分课程收费）
- 交互式 / 项目式学习（英文）：[python_koans](https://github.com/gregmalcolm/python_koans)、[interactive-coding-challenges](https://github.com/donnemartin/interactive-coding-challenges)、[project-based-learning#python](https://github.com/practical-tutorials/project-based-learning#python)、[learn-python3](https://github.com/jerry-git/learn-python3)

### 书籍

- ⭐ [《Python 编程：从入门到实践》](https://book.douban.com/subject/36365320/)：零基础入门
- [《Python 学习手册》](https://book.douban.com/subject/30364619/)：系统全面
- [《Python Cookbook 中文版》](https://book.douban.com/subject/26381341/)：实用技巧
- [《利用 Python 进行数据分析》](https://book.douban.com/subject/25779298/)：Pandas 作者编写
- [《Python 数据科学手册》](https://book.douban.com/subject/27667378/)：数据科学必读
- [《Python 深度学习》](https://book.douban.com/subject/36078304/)：深度学习入门
- [《Python 3 网络爬虫开发实战》](https://book.douban.com/subject/30175598/)：爬虫实战
- [《Python 编程快速上手（第 2 版）》](https://book.douban.com/subject/35387685/)：偏实用的自动化小工具入门

另有《笨办法学 Python 3》《父与子的编程之旅》《轻量级 Django》等入门书可选。

### 开源代码与资源合集

- [数据结构和算法 Python 实现](https://github.com/keon/algorithms)
- [Python Machine Learning 代码](https://github.com/rasbt/python-machine-learning-book-3rd-edition)
- [《剑指 Offer》算法面试题 Python 实现](https://github.com/JushuangQiao/Python-Offer)
- [设计模式 Python 实现](http://www.pythontip.com/python-patterns/detail/abstract_factory)
- [Python 小脚本集](https://github.com/RealHacker/python-gems)：一些有意思的练手小项目
- [Python 练习册](https://github.com/Yixiaohan/show-me-the-code)
- ⭐ [GitHub Python 专区](https://github.com/topics/python)：最新开源项目
- ⭐ [awesome-python](https://github.com/vinta/awesome-python)：类库大全
- [awesome-python-cn](https://github.com/jobbole/awesome-python-cn)：类库大全中文版
- [awesome-python-books](https://github.com/Junnplus/awesome-python-books)（[中文版](https://github.com/jobbole/awesome-python-books)）：Python 书单
- [awesome-jupyter](https://github.com/markusschanta/awesome-jupyter)：Jupyter 相关资源
- [awesome-machine-learning](https://github.com/josephmisiti/awesome-machine-learning#python)
- [awesome-asyncio](https://github.com/timofurrer/awesome-asyncio)：异步编程资源
- ⭐ [StackOverflow Python 专区](https://stackoverflow.com/questions/tagged/python)：解决问题必备
- [掘金 Python 专区](https://juejin.cn/tag/Python)：看技术文章

### 在线社区

- ⭐ [PythonTab](https://www.pythontab.com/)：中文 Python 开发者社区
- [LearnKu Python 技术论坛](https://learnku.com/python)
- [开源中国](https://www.oschina.net/)：综合开源社区（更多社区见 [[工具 34 - 编程学习网站与资源推荐]]）

### 在线工具与手册

- ⭐ [菜鸟教程 Python 在线编程](https://c.runoob.com/compile/6/)：浏览器里直接跑代码
- [腾讯云 Python 在线手册](https://cloud.tencent.com/developer/devdocs)
- [Python 在线手册汇总](https://docs.pythontab.com/)
- 更多在线 IDE 见 [[工具 33 - 在线编程网站与在线 IDE]]

### 面试题与专项练习

- ⭐ [牛客 Python 专项练习](https://www.nowcoder.com/intelligentTest)
- [牛客 Python 题库](https://www.nowcoder.com/search?query=python&type=question)、[机器学习面试题](https://www.nowcoder.com/search?type=question&query=%E6%9C%BA%E5%99%A8%E5%AD%A6%E4%B9%A0)、[机器学习笔试](https://www.nowcoder.com/search?type=paper&query=%E6%9C%BA%E5%99%A8%E5%AD%A6%E4%B9%A0)
- [Python 面试题整理（高星）](https://github.com/taizilongxu/interview_python)
- [Python 面试题整理](https://github.com/kenwoodjw/python_interview_question)
- [机器学习面试题](https://geektutu.com/post/qa-ml.html)

### 技术博客

- [Real Python Blog](https://realpython.com/)：Python 教程和最佳实践
- [Python Software Foundation Blog](https://pyfound.blogspot.com/)：Python 基金会官方博客
- [Google AI Blog](https://blog.google/technology/ai/)：谷歌 Python AI 应用

---

## 写在最后

Python 语法简洁、功能强大、应用广泛，无论做 AI 开发、数据分析，还是只想学个工具提高效率，都是很好的选择。但 Python 只是工具，重要的是用它做什么：目标是开发工作则主学 Java/Go、把 Python 当辅助；目标是 AI/数据科学则要在 Python 基础上深入算法、数学与领域知识。AI 时代几乎所有 AI 框架都基于 Python，掌握 Python + AI 将拥有更强竞争力。
