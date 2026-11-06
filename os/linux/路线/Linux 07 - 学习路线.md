---
title: "Linux 07 - 学习路线"
date: 2026-07-25
tags:
  - Linux
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# Linux 07 - 学习路线

> Linux 免费、开源、安全、灵活、稳定，90% 以上企业应用部署在 Linux 服务器。前端、后端、算法、测试、运维均建议学习。

## Linux 学习境界

1. **明劲**：了解基本概念，会用常用命令应对工作——绝大多数岗位够用
2. **暗劲**：理解内核设计思想（小圆满），能应用到系统架构设计（大圆满）——冲击大厂/架构师/底层开发
3. **化劲**：熟知使用、思想和细节，能自主创造新系统

## 基础知识

- 发展历史、特点与优势、应用场景
- 常见发行版：CentOS 7+（推荐）、Ubuntu、Debian、Fedora
- 开源理念

## 学习路线

### 1. Linux 环境搭建
- 搭建方式：虚拟机、云服务器（学生机几十元/年）、WSL、Docker 容器
- 远程连接：SSH、XShell、MobaXterm、SecureCRT、Putty

### 2. 常用命令

| 分类 | 命令 |
|------|------|
| 系统信息 | uname, hostname, top, df, du, free, uptime, iostat, env, lsmod |
| 系统操作 | shutdown, reboot, mount, umount |
| 用户管理 | su, sudo, who, ssh, useradd, userdel, usermod, groupadd, passwd, last |
| 文件操作 | cd, ls, tree, mkdir, rm, touch, cp, mv, ln, find, locate, chmod |
| 文件查看 | cat, more, less, tac, head, tail, paste |
| 压缩解压 | zip, unzip, tar, gzip |
| 文本处理 | grep, sed, awk, vim |
| 程序管理 | crontab, nohup, jobs, ps, kill, systemctl, yum, apt |

### 3. 进阶主题
- **用户管理**：用户、用户组、ACL 权限、sudo 配置
- **文件管理**：权限体系（rwx）、软硬链接、压缩解压
- **文本操作**：正则表达式、grep/sed/awk 三剑客
- **VIM 编辑器**：模式、快捷键、配置、插件
- **磁盘管理**：分区、挂载、使用情况查询
- **进程管理**：启动/杀死/查看/监控进程、前台/后台任务
- **计划任务**：crond 服务、crontab 命令
- **网络管理**：IP、端口、hosts、网络配置/状态/监控
- **系统管理**：日期时间、语言字符集、环境变量、日志、备份恢复
- **服务管理**：systemctl、开机自启、服务查看/启动/禁用
- **软件管理**：rpm、yum、apt、源码安装

### 4. 常用软件/服务搭建
HTTP、Mail、NFS、DNS、FTP、MySQL、LVS+Keepalived、Apache、Nginx、Redis、日志服务

### 5. Shell 脚本编程
- 默认变量、运算符、条件、循环、函数（系统/自定义）
- 执行、调试、管道、I/O 重定向
- 详见 Shell 脚本学习路线

### 6. Linux 启动过程
BIOS → 引导加载程序 → 内核加载 → 系统初始化（init） → 运行级别 → 执行初始化脚本 → 用户登录

### 7. Linux 内核（选学）
- 内核组成、目录结构、版本
- 模块、编译、裁剪

### 8. 第三方工具
Ansible（自动化运维）、Webmin（Web 管理面板）、宝塔 Linux（可视化管理）

## 后端工程师需要学到什么程度

1. **Linux 是后端必备技能**：绝大多数企业项目都部署在 Linux 服务器上，但实际工作中对后端工程师的 Linux 技能要求并不高
2. **做到 2 点就足够**：
   - 熟练运用 Linux 命令分析和解决问题：分析系统资源占用（CPU、内存、网络等）、查看项目日志
   - 能通过查阅资料完成软件安装、项目部署
3. **千万别背命令**：学编程和学英语不一样，能通过查阅资料完成诉求即可。可用命令行大全网站（linuxcool.com）或直接问 AI 生成脚本
4. **大学阶段性价比判断**：如果不打算从事系统底层开发、C++ 后端、Linux 运维等岗位，没必要深入 Linux（性价比不高）；想深入学习，Linux 内核是必学的，最好方法就是读经典书籍（可参考本文件「推荐资源」）

## 学习建议

1. **多动手**：买云服务器或搭建虚拟机，从 0 手敲命令安装软件、部署服务
2. **每个命令至少敲一遍**：通过自然练习熟悉，记不住查文档即可
3. **先会用，再理解**：不要一开始就深入内核，先把常用命令学会
4. **利用 AI 辅助**：让 AI 解释不懂的命令、生成完整命令
5. **时间紧看面试题**：通过面试题了解设计思想

## 推荐资源

| 类型 | 资源 |
|------|------|
| 视频 | 韩顺平一周学会 Linux（CentOS 7.6）、黑马 Linux 云计算运维 |
| 书籍 | 《鸟哥的 Linux 私房菜——基础篇》（必读）、《深入理解 Linux 内核》 |
| 在线实战 | 蓝桥云课 Linux 基础入门、腾讯云动手实验室、阿里云体验实验室 |
| 工具 | Linux 命令搜索（wangchujiang.com/linux-command）、宝塔面板 |

> 来源：鱼皮·编程导航 / codefather
