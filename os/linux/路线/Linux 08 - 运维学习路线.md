---
title: "Linux 08 - 运维学习路线"
date: 2026-07-31
tags:
  - Linux
  - 运维
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# Linux 08 - 运维学习路线

> Linux 运维工程师是负责 Linux 服务器和系统的规划、部署、监控、优化、故障排查等工作的专业技术人员，是企业 IT 基础设施的守护者。本篇学习路线涵盖系统管理、Shell 脚本、网络管理、系统监控、日志分析、安全加固、自动化运维、面试备战 8 个阶段。

## 整体学习建议

1. **动手实践** — 安装 Linux 系统（虚拟机或云服务器），在真实环境中练习命令和操作
2. **系统化学习** — 从系统管理开始，逐步学习网络、监控、安全等各个方面
3. **生产环境思维** — 关注高可用、故障恢复、性能优化等生产环境最佳实践
4. **自动化意识** — 尽可能自动化，减少手动操作，培养自动化思维

## 阶段 1：Linux 系统管理

### 学习目标

掌握 Linux 系统管理，能够管理和维护 Linux 服务器。

### 知识点

- **用户和组管理** — 创建/删除用户、组管理、权限模型（所有者、所属组、其他用户）
- **权限管理** — chmod、chown、umask、特殊权限（SUID/SGID/Sticky Bit）
- **进程管理** — ps、top、htop、kill、nice/renice
- **系统服务管理** — Systemd、systemctl、journalctl
- **文件系统** — ext4、xfs 类型；挂载/卸载；fdisk、parted 分区工具
- **LVM 逻辑卷管理** — PV/VG/LV 概念、动态调整磁盘空间
- **软件包管理** — yum/dnf（RHEL/CentOS）、apt（Debian/Ubuntu）、源配置
- **系统优化** — 内核参数调优（sysctl）、系统资源限制（ulimit）

### 学习重点

- 用户和权限管理是基础，要熟练掌握 Linux 权限模型
- 进程管理和 Systemd 是日常运维的核心操作
- LVM 在生产环境中非常常用，支持动态调整磁盘空间

### 学习资源

- [Linux 服务器学习路线](https://www.codefather.cn/course/1789189862986850306/section/1990755996393320449)：面向开发者的 Linux 学习路线（来源原文引用）

## 阶段 2：Shell 脚本编程

Shell 脚本是运维自动化的基础，大部分运维任务都可以用 Shell 脚本自动化。

### 学习目标

掌握 Shell 脚本，能够编写自动化运维脚本。

### 知识点

- **Shell 基础** — 脚本语法、变量和数组、条件判断和循环、函数
- **自动化脚本** — 系统监控脚本、日志分析脚本、自动化部署脚本
- **定时任务** — Cron 配置与管理

### 学习建议

- 能看懂脚本，能结合 AI 生成正确可用的脚本即可
- 编写脚本时注意健壮性：错误处理、日志记录、参数检查

### 学习资源

- [Shell 脚本学习路线](https://www.codefather.cn/course/1789189862986850306/section/1990756051800076290)：完整的 Shell 学习路线（来源原文引用）

## 阶段 3：网络管理

### 学习目标

掌握 Linux 网络管理，能够配置网络和排查网络问题。

### 知识点

- **网络配置** — 网络接口配置、IP 地址/子网掩码/网关、DNS 配置、路由配置
- **网络工具** — ping、traceroute、netstat、ss、tcpdump、wireshark
- **防火墙** — iptables、firewalld
- **故障排查** — 连通性测试、网络性能分析、抓包分析

### 学习重点

- 理解 TCP/IP 协议、DNS 解析、路由等核心概念
- 掌握 ping、traceroute、tcpdump 等工具定位网络问题
- 防火墙配置是系统安全的重要部分，需掌握 iptables 或 firewalld

### 学习资源

- [Linux 网络故障排查](https://zhuanlan.zhihu.com/p/1937448425563074614)：诊断流程

## 阶段 4：系统监控

系统监控是运维的核心工作，要实时掌握系统状态，及时发现和处理问题。

### 学习目标

掌握系统监控技术，能够监控服务器和应用的健康状态。

### 知识点

- **系统资源监控** — CPU、内存、磁盘、网络监控
- **性能分析工具** — top、htop、iostat、vmstat
- **监控系统** — Prometheus + Grafana（推荐）、Zabbix（可选）
- **告警** — 告警规则配置、告警通知（邮件/短信/钉钉等）、告警处理流程

### 学习建议

- Prometheus + Grafana 是现代监控标配，云原生友好；Zabbix 是传统监控工具，功能全面
- 告警配置要合理，避免告警过多（疲劳）或过少（遗漏）

### 学习资源

- [Prometheus 官方文档](https://prometheus.io/docs/introduction/overview/)
- [Zabbix 官方文档](https://www.zabbix.com/documentation)
- [Prometheus + Grafana + ARMS 大厂级别监控视频教程](https://www.bilibili.com/video/BV1QPYDztEtW/)（B站）

## 阶段 5：日志分析和故障排查

### 学习目标

掌握日志工具和分析方法，能够快速定位和解决问题。

### 知识点

- **日志管理** — 系统日志（`/var/log`）、journalctl、日志轮转（logrotate）
- **日志分析** — grep、awk、sed、日志聚合（ELK Stack）、日志告警
- **故障排查** — 系统故障排查思路、性能瓶颈定位、网络故障排查、应用故障排查
- **应急响应** — 故障应急流程、故障复盘

### 学习重点

- `/var/log/messages` 是系统主日志，`/var/log/secure` 是安全日志
- 故障排查要有系统化思路：从现象入手，通过日志、监控、命令逐步缩小范围
- 常见故障：系统卡顿（CPU/内存不足）、磁盘满、网络不通、服务无法启动

### 学习资源

- [Linux 故障排查思路](https://zhuanlan.zhihu.com/p/1945135023364740753)：常见故障解决方案
- [Linux 日志分析](https://www.freebuf.com/articles/system/443606.html)：应急响应

## 阶段 6：安全加固

### 学习目标

掌握 Linux 安全技术，能够加固系统安全。

### 知识点

- **系统安全** — SSH 安全配置（修改默认端口、禁用 root 远程登录）、用户权限最小化、sudo 配置、密码策略
- **防火墙** — iptables/firewalld、端口管理、安全组配置（云平台）
- **入侵检测** — 异常登录检测、文件完整性检查、安全审计

### 学习建议

- 定期检查系统安全：异常登录、异常进程、文件权限检查
- 安全是持续过程，关注安全漏洞和补丁，及时更新系统

### 学习资源

- Red Hat 官方安全实践、Linux Foundation 安全指南

## 阶段 7：自动化运维

### 学习目标

通过脚本和工具实现运维工作的自动化，提高效率并减少人为错误。

### 知识点

- **配置管理** — Ansible（推荐）、Puppet/Chef（可选）
- **容器化** — Docker 基础、容器化部署
- **编排工具** — Kubernetes 基础、应用部署到 K8s

### 学习建议

- Ansible 是最流行的配置管理工具，应重点学习
- 容器化和 K8s 是云原生运维的基础，运维工程师需要了解

### 学习资源

- [Ansible 官方文档](https://docs.ansible.com/)
- [Docker 容器化学习路线](https://www.codefather.cn/course/1789189862986850306/section/1990754953097949186)（来源原文引用）
- [Kubernetes 学习路线](https://www.codefather.cn/course/1789189862986850306/section/1990754993086443521)（来源原文引用）

## 阶段 8：面试备战

### 学习目标

熟悉 Linux 运维常见面试题，准备好简历和项目经历。

### 学习建议

- 简历上要有运维项目经历（管理过多少台服务器、搭建过什么系统、处理过什么故障），尽量有可量化指标
- 准备故障案例：能清晰介绍故障现象、排查过程、解决方案

### 经典面试题

**Linux 基础：**
1. 常用的 Linux 命令有哪些？
2. 如何查看系统资源使用情况？
3. 如何查找文件？
4. 软链接和硬链接有什么区别？

**系统管理：**
1. 如何添加和删除用户？
2. 如何管理文件权限？
3. 如何管理系统服务（systemctl）？
4. 如何查看和管理进程？

**网络：**
1. 如何配置网络？
2. 如何排查网络问题？
3. 如何配置防火墙？
4. 如何查看网络连接？

**故障排查：**
1. 系统负载过高如何排查？
2. 磁盘满了如何处理？
3. 服务无法启动如何排查？
4. 网络不通如何排查？

**监控和日志：**
1. 如何监控系统？
2. 常用的监控工具有哪些？
3. 如何分析日志？
4. 如何配置告警？

## 拓展资源

### Linux 运维成长路径

- [Linux 运维工程师学习路径](https://github.com/mingongge/BestSRE)（GitHub）：打怪升级进阶
- [运维学习路线](https://cloud.tencent.com/developer/article/1647401)：从初级到资深
- [从运维到云架构](http://www.bilibili.com/read/cv43360748/)：2025 职业进阶

### 技术博客

- [Red Hat Blog](https://www.redhat.com/en/blog)：Red Hat 运维实践
- [Linux Foundation Blog](https://www.linuxfoundation.org/blog)：Linux 基金会博客
- [Netflix TechBlog](https://netflixtechblog.com/)：Netflix 运维架构
- [Google Cloud Blog](https://cloud.google.com/blog)：谷歌云运维

## 学习方向

学完 Linux 运维后，可从事以下岗位：

1. **Linux 运维工程师** — Linux 服务器管理和维护
2. **系统管理员** — 企业 IT 系统管理
3. **运维开发工程师** — 开发运维自动化工具
4. **DevOps 工程师** — DevOps 流程和工具链建设
5. **SRE 工程师** — 系统可靠性工程

> 来源：鱼皮·编程导航 / codefather「2026年最新Linux运维学习路线」，已去推广、去图片，保留核心技术内容。
