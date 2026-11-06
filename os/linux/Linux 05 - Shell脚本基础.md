---
title: "Linux 05 - Shell脚本基础"
date: 2026-06-11
tags: [os, linux]
---

# Linux 05 - Shell脚本基础

## 变量

```bash
# 定义变量（等号两侧不能有空格）
name="Alice"
age=25

# 使用变量
echo $name
echo ${name}_suffix     # 带后缀需 {} 包裹

# 环境变量
export PATH=$PATH:/usr/local/bin
echo $HOME
echo $SHELL

# 特殊变量
$0    # 脚本名
$1-$9 # 位置参数
$#    # 参数个数
$@    # 所有参数（数组）
$?    # 上条命令退出码（0=成功）
$$    # 当前进程 PID
```

## 条件判断

```bash
# if-else
if [ -f "$file" ]; then
    echo "文件存在"
elif [ -d "$file" ]; then
    echo "是目录"
else
    echo "不存在"
fi

# 文件判断
[ -f file ]  # 是否存在且为文件
[ -d dir ]   # 是否为目录
[ -x file ]  # 是否可执行
[ -z str ]   # 字符串是否为空
[ -n str ]   # 字符串是否非空

# 数值比较
[ "$a" -eq "$b" ]  # 等于
[ "$a" -ne "$b" ]  # 不等于
[ "$a" -gt "$b" ]  # 大于 (lt/le/ge)
```

## 循环

```bash
# for 循环
for i in {1..5}; do
    echo $i
done

for file in *.log; do
    echo "处理: $file"
done

# while 循环
count=0
while [ $count -lt 5 ]; do
    echo $count
    ((count++))
done

# 读取文件
while read line; do
    echo $line
done < input.txt
```

## 函数

```bash
# 定义
function log() {
    local msg="$1"     # local 定义局部变量
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg"
}

# 使用
log "脚本开始执行"

# 返回值
function add() {
    return $(($1 + $2))
}
add 3 5
echo $?    # 8
```

## 常用技巧

```bash
# 命令替换
files=$(ls)
date_str=`date +%Y%m%d`     # 旧语法

# 管道与重定向
command > output.log        # 覆盖写
command >> output.log       # 追加
command 2>&1                # 错误也输出到 stdout
command | grep "error"      # 管道

# 防误操作
set -e     # 遇到错误立即退出
set -x     # 调试模式（打印每条命令）

# trap 清理
trap "rm -f /tmp/tmpfile; exit" EXIT
```

## 示例：备份脚本

```bash
#!/bin/bash
set -e

BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

tar -czf "$BACKUP_DIR/app.tar.gz" /var/www/app
echo "备份完成: $BACKUP_DIR/app.tar.gz"
```
