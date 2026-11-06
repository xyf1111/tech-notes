---
title: "Dos 01 - 常用命令速查"
date: 2026-06-11
tags: [os, dos]
---

# Dos 01 - 常用命令速查

> Windows 命令行（CMD）常用操作，适合在 Windows 环境下快速操作文件系统。

## 目录操作

```cmd
:: 查看当前目录
dir

:: 切换盘符
c:
d:
e:

:: 切换目录
cd path
cd ..           :: 返回上级
cd /d d:\code   :: 跨盘符加 /d

:: 显示当前路径
cd

:: 创建目录
mkdir folder
md folder

:: 删除目录
rd folder       :: 空目录
rd /s folder    :: 递归删除（含文件）
rd /s /q folder :: 静默删除，不询问
```

## 文件操作

```cmd
:: 创建文件
echo content > file.txt
type nul > file.txt            :: 创建空文件

:: 查看文件
type file.txt
more file.txt                  :: 分页

:: 复制
copy source.txt dest.txt
copy *.txt D:\backup\

:: 移动
move file.txt D:\folder\

:: 删除
del file.txt
del *.log
del /s *.tmp                   :: 递归删除

:: 重命名
ren old.txt new.txt
```

## 网络命令

```cmd
:: 查看 IP 配置
ipconfig
ipconfig /all                  :: 详细信息

:: 查看 DNS 缓存
ipconfig /displaydns
ipconfig /flushdns             :: 刷新 DNS

:: 连通性测试
ping 192.168.1.1
ping -t baidu.com              :: 持续 ping（Ctrl+C 停止）

:: 路由追踪
tracert baidu.com

:: 查看网络连接
netstat -an
netstat -ano                   :: 显示 PID

:: 查看 ARP 表
arp -a
```

## 系统命令

```cmd
:: 查看系统信息
systeminfo

:: 查看进程
tasklist

:: 终止进程
taskkill /f /im notepad.exe   :: 强制结束
taskkill /pid 1234

:: 查看服务
sc query
net start                      :: 查看运行中的服务

:: 关机/重启
shutdown /s /t 0              :: 立即关机
shutdown /r /t 0              :: 立即重启
shutdown /a                   :: 取消关机

:: 查看磁盘
fsutil volume diskfree c:
chkdsk                        :: 磁盘检查
```

## 批处理基础

```batch
@echo off
echo Hello World

:: 变量
set name=Alice
echo %name%

:: 条件
if exist file.txt (
    echo 文件存在
) else (
    echo 不存在
)

:: 循环
for %%i in (*.txt) do echo %%i

:: 参数
echo %1 %2   :: 第1/2个参数
echo %0      :: 脚本名

pause        :: 暂停等待按键
```
