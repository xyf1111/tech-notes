---
title: "Linux 09 - Shell脚本学习路线"
date: 2026-08-05
tags:
  - Linux
  - Shell
  - 学习路线
source: "鱼皮·编程导航 / codefather"
---

# Linux 09 - Shell脚本学习路线

> Shell 是 Linux/Unix 系统的命令行解释器，Shell 脚本是由 Shell 命令组成的可执行文件，能将重复性工作自动化。本路线涵盖 Shell 基础、变量与参数、流程控制、函数与文件操作（文本处理三剑客）、实战应用、求职备战 6 个部分，从零基础到精通一条龙。

## 开篇介绍

### Shell 脚本是什么？

Shell 是 Linux/Unix 系统的命令行解释器，Shell 脚本就是由 Shell 命令组成的可执行文件。通过编写 Shell 脚本，可以将一系列命令组合起来，实现自动化任务，大大提高工作效率。Shell 脚本广泛应用于系统管理、自动化运维、数据处理、软件部署等场景：自动备份数据库、批量处理文件、定时执行任务、监控系统状态、自动化部署应用等。

### 为什么要学 Shell 脚本？

- **运维必备** — 对运维工程师来说，Shell 脚本是必备技能
- **开发提效** — 对后端开发工程师来说，Shell 脚本能快速完成自动化任务，提高开发效率
- **学习成本低** — 语法简单，几天时间就能掌握基础用法
- **AI 时代依然灵活** — Shell 脚本仍是最灵活、最高效的自动化方案，且可用 AI 工具（ChatGPT、Gemini、DeepSeek 等）辅助生成和调试脚本，进一步降低门槛

### 学习前提

需要基本的 Linux 命令行知识（文件、目录、权限、常用命令）。若不熟悉，可先参考 [[Linux 08 - 运维学习路线]] 中的系统管理部分。

### 就业方向

- **运维 / SRE** — 系统监控、自动化运维、日志分析、故障排查
- **后端开发** — 部署脚本、CI/CD 辅助、批处理任务
- **数据处理** — 文本提取、日志统计、报表生成

## 整体学习建议

1. **边学边练** — Shell 脚本必须结合实践，多写脚本、多调试。建议在 Linux 或 macOS（内置 Bash）上练习，也可用 [Shell playground 在线工具](https://codapi.org/shell/) 随时练习
2. **从简单到复杂** — 不要一上来就写复杂脚本，先从打印文本、创建文件等简单任务开始，逐步增加复杂度
3. **善用 AI 工具** — 遇到不懂的命令或错误，可以让 AI 工具帮忙解释和调试
4. **重点学习 awk 和 sed** — 这是 Shell 脚本中最常用的文本处理工具，功能强大，建议重点投入
5. **注意 Shell 的选择** — 本路线以 Bash 为主（Linux 最常用），Zsh、Fish 等其他 Shell 语法略有差异
6. **重视调试能力** — 掌握 `bash -x` / `set -x` 跟踪执行、用 `$?` 检查命令退出状态，调试是脚本学习的核心环节

## 阶段 1：Shell 基础（1-5 天）

### 学习目标

理解 Shell 脚本的基本概念，掌握 Shell 脚本的编写和执行方法。

### 知识点

- **Shell 基础【必学】** — 什么是 Shell；常见 Shell 类型（Bash、Zsh、Ksh、Csh）；Shebang（`#!/bin/bash`）；脚本的执行方式（`bash script.sh`、`./script.sh`、`source script.sh`）；脚本权限（`chmod +x`）
- **注释【必学】** — 单行注释（`#`）；多行注释（`:<<'COMMENT' ... COMMENT`）
- **输出【必学】** — `echo` 命令、`printf` 命令
- **输入【必学】** — `read` 命令；命令行参数（`$1`、`$2`、`$@`、`$#`）

### 学习建议

1. Shebang（`#!/bin/bash`）必须放在脚本第一行，告诉系统使用哪个解释器执行脚本
2. 执行方式的区别：`bash script.sh` 创建新的子进程执行；`source script.sh` 在当前进程执行，变量会保留
3. 养成良好编码习惯：每个脚本添加注释，说明脚本功能、作者、日期等

### 学习资源

- [尚硅谷 Linux、Shell 教程（B站）](https://www.bilibili.com/video/BV1WY4y1H7d3)
- [Shell 编程从入门到精通（腾讯云开发者社区）](https://cloud.tencent.com/developer/article/1763225)

### 示例脚本

```bash
#!/bin/bash
# 第一个 Shell 脚本
echo "Hello, Shell!"
echo "当前用户：$USER"
echo "当前目录：$(pwd)"
```

## 阶段 2：变量和参数（1-5 天）

### 学习目标

掌握 Shell 变量的定义和使用，理解特殊变量的含义。

### 知识点

- **变量定义【必学】** — 变量定义（等号两边无空格：`name="value"`）；使用变量（`$name` 或 `${name}`）；只读变量（`readonly`）；删除变量（`unset`）
- **变量类型【必学】** — 局部变量；环境变量（`export`）；Shell 变量
- **特殊变量【必学】** — `$0` 脚本名称；`$1`、`$2`... 位置参数；`$#` 参数个数；`$@` 所有参数（列表形式）；`$*` 所有参数（字符串形式）；`$?` 上一条命令的退出状态（0 成功，非 0 失败）；`$$` 当前进程 ID
- **字符串操作【建议学】** — 字符串拼接；获取长度（`${#string}`）；提取子串（`${string:start:length}`）；字符串替换（`${string/old/new}`）
- **数组【建议学】** — 定义数组（`arr=(1 2 3)`）；访问元素（`${arr[0]}`）；数组长度（`${#arr[@]}`）；遍历数组

### 学习建议

1. 变量定义时等号两边不能有空格：`name="value"` 正确，`name = "value"` 报错
2. 使用变量建议加花括号 `${name}`，避免歧义，特别是字符串拼接时
3. 特殊变量很重要：`$?` 可判断命令是否执行成功（0 表示成功，非 0 表示失败）

## 阶段 3：流程控制（2-7 天）

### 学习目标

掌握 Shell 脚本的流程控制语句，能够编写包含条件判断和循环的脚本。

### 知识点

- **条件判断【必学】** — `test` 命令；`[ ]` 表达式；`[[ ]]` 表达式（推荐）；文件判断（`-e`、`-f`、`-d`、`-r`、`-w`、`-x`）；数值比较（`-eq`、`-ne`、`-gt`、`-lt`、`-ge`、`-le`）；字符串比较（`=`、`!=`、`-z`、`-n`）；逻辑运算（`-a`、`-o`、`!`）
- **if 语句【必学】** — `if...then...fi`；`if...then...else...fi`；`if...then...elif...else...fi`
- **case 语句【必学】** — `case...in...esac`
- **循环语句【必学】** — `for` 循环（`for i in list; do...done`）；`while` 循环（`while condition; do...done`）；`until` 循环（`until condition; do...done`）；`break` 和 `continue`

### 学习建议

1. 推荐使用 `[[ ]]` 而非 `[ ]`：`[[ ]]` 功能更强大，支持正则匹配，且变量无需加引号
2. 文件判断非常常用：`-f file` 判断存在且为普通文件，`-d dir` 判断目录是否存在
3. `for` 循环可遍历命令输出、数组、文件列表等，非常灵活

### 示例脚本

```bash
#!/bin/bash
# 流程控制示例
age=20
if [[ $age -ge 18 ]]; then echo "已成年"; else echo "未成年"; fi

read -p "请输入选择（1-3）：" choice
case $choice in
    1|2|3) echo "选项$choice" ;; *) echo "无效选择" ;;
esac

for i in {1..5}; do echo $i; done
count=5
while [[ $count -gt 0 ]]; do echo $count; ((count--)); sleep 1; done
```

## 阶段 4：函数、文件操作与文本处理（2-7 天）

### 学习目标

掌握 Shell 函数的定义和使用，学习常用文件操作与文本处理工具（grep、sed、awk），熟悉正则表达式的基本用法。

### 知识点

- **函数【必学】** — 函数定义（`function name() { }`）；函数调用；函数参数（`$1`、`$2`...）；函数返回值（`return`）
- **文件操作【必学】** — 读取文件（`cat`、`head`、`tail`、`less`、`more`）；写入文件（`>` 覆盖、`>>` 追加）；重定向（标准输入、标准输出、标准错误）
- **grep【必学】** — 搜索文本；基本用法（`grep pattern file`）；正则表达式匹配；常用选项（`-i` 忽略大小写、`-v` 反向匹配、`-n` 显示行号、`-r` 递归搜索）
- **sed【必学】** — 文本替换和编辑；替换（`sed 's/old/new/' file`）；删除行（`sed '/pattern/d' file`）；插入行（`sed 'i\text' file`）
- **awk【必学】** — 文本分析和处理；基本用法（`awk '{print $1}' file`）；内置变量（`$0` 整行、`$1` 第一列、`NR` 行号、`NF` 列数）；条件和循环
- **正则表达式【建议学】** — 元字符（`.`、`*`、`+`、`?`、`[]`、`^`、`$`）；字符类（`[0-9]`、`[a-z]`）；分组与扩展正则（`-E`：`|` 或、`+`、`?`）
- **其他常用命令【建议学】** — `find` 查找文件；`xargs` 构建命令行；`cut` 提取列；`sort` 排序；`uniq` 去重；`wc` 统计行数/单词数/字符数

### 学习建议

1. grep、sed、awk 是"文本处理三剑客"，是 Shell 脚本中最重要的工具，务必重点学习
2. awk 功能非常强大，可以当作一门编程语言来学习，特别适合处理结构化文本（日志文件、CSV 文件）
3. sed 主要用于文本替换和编辑，如批量替换文件内容、删除特定行
4. 这些工具通常通过管道（`|`）组合使用，实现复杂的文本处理任务

### 学习资源

- [Shell 自动化运维实战（百度 Comate）](https://comate.baidu.com/zh/page/ak43wjt9jkp)
- [运维三剑客实战（腾讯云开发者社区）](https://cloud.tencent.com/developer/article/2381804)
- [GNU Bash 参考手册（官方）](https://www.gnu.org/software/bash/manual/)

## 阶段 5：实战应用（3-10 天）

### 学习目标

通过实际案例掌握 Shell 脚本实战技巧，能够编写系统监控、日志分析、自动化部署等实用脚本。现在有 AI 辅助了，只要能看懂并改造下面的脚本，就已具备实战能力。

### 实战案例

**案例 1：系统监控脚本**

```bash
#!/bin/bash
# 系统监控脚本
echo "主机名：$(hostname)  内核：$(uname -r)  运行时间：$(uptime -p)"
top -bn1 | grep "Cpu(s)" | awk '{print "CPU使用率：" 100-$8 "%"}'
free -h | grep "Mem" | awk '{print "总内存：" $2 " 已用：" $3 " 可用：" $4}'
df -h | grep "^/dev"
```

**案例 2：自动备份脚本**

```bash
#!/bin/bash
# 数据库备份脚本
DB_NAME="mydb"; DB_USER="root"; DB_PASS="password"
BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${DATE}.sql"

mkdir -p $BACKUP_DIR
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE
if [[ $? -eq 0 ]]; then
    echo "备份成功：$BACKUP_FILE"
    gzip $BACKUP_FILE
    find $BACKUP_DIR -name "*.gz" -mtime +7 -delete  # 清理 7 天前备份
else
    echo "备份失败！"; exit 1
fi
```

**案例 3：批量处理文件**

```bash
#!/bin/bash
# 批量重命名图片文件（用法：$0 <目录>）
[[ $# -lt 1 ]] && { echo "用法：$0 <目录>"; exit 1; }
DIR=$1; count=1
for file in $DIR/*.jpg; do
    [[ -f $file ]] || continue
    mv "$file" "$DIR/image_$(printf "%03d" $count).jpg"
    ((count++))
done
echo "处理完成，共重命名 $((count-1)) 个文件"
```

**案例 4：日志分析脚本**

```bash
#!/bin/bash
# 分析 Nginx 访问日志
LOG_FILE="/var/log/nginx/access.log"
[[ -f $LOG_FILE ]] || { echo "错误：日志文件不存在"; exit 1; }

echo "总访问量：$(wc -l < $LOG_FILE)"
echo "访问最多的 IP Top 10：";  awk '{print $1}' $LOG_FILE | sort | uniq -c | sort -rn | head -10
echo "访问最多的 URL Top 10："; awk '{print $7}' $LOG_FILE | sort | uniq -c | sort -rn | head -10
echo "HTTP 状态码分布：";        awk '{print $9}' $LOG_FILE | sort | uniq -c | sort -rn
```

### 学习建议

1. 结合真实需求写脚本，思考工作中有哪些重复性任务可以用脚本自动化
2. 脚本要考虑错误处理：检查文件是否存在、命令是否执行成功、参数是否正确
3. 复杂脚本要添加注释，方便自己和他人理解
4. 定时执行使用 cron 定时任务，如每天凌晨 2 点执行备份脚本

## 补充：脚本调试技巧

### 知识点

- `bash -x script.sh` 或脚本内 `set -x`：逐行跟踪执行，打印每条命令
- `set -e`：命令出错立即退出；`set -u`：使用未定义变量时报错
- `$?`：检查上一条命令的退出状态，配合 `if` 做错误分支
- `trap '...' ERR`：捕获错误执行清理逻辑

### 学习建议

先写后调是常态：遇到脚本行为不符合预期，先用 `bash -x` 定位，再配合 `echo` 打印中间变量值，逐步缩小问题范围。

## 求职备战

### 学习建议

Shell 脚本一般不是单独的面试科目，而是作为 Linux 运维或后端开发岗位的一部分来考察，可能会要求现场编写简单脚本或询问相关知识。

1. **准备常用脚本** — 准备几个常用案例（系统监控、自动备份、日志分析），能快速说出功能和实现思路
2. **掌握文本处理三剑客** — grep、sed、awk 是高频考点，要能熟练使用
3. **理解脚本执行流程** — Shebang 的作用、变量作用域、管道工作原理等

### 经典面试题

1. Shell 脚本第一行 `#!/bin/bash` 有什么作用？
2. `source`、`sh`、`bash`、`./` 执行脚本有什么区别？
3. `$#` 和 `$@` 有什么区别？
4. 如何判断一个文件是否存在？
5. 如何在 Shell 脚本中捕获命令的输出？
6. grep、sed、awk 各有什么特点？如何选择？
7. 如何在 Shell 脚本中实现异常处理？

## 持续学习资源

### 官方文档

- [GNU Bash 参考手册](https://www.gnu.org/software/bash/manual/)

### 技术博客

- [Linux Journal](https://www.linuxjournal.com/)：Linux 和 Shell 技术
- [Red Hat Blog](https://www.redhat.com/en/blog)：Red Hat 系统管理
- [Ubuntu Blog](https://ubuntu.com/blog)：Ubuntu 官方博客

### Shell 脚本库与工具

- [awesome-shell](https://github.com/alebcay/awesome-shell)：Shell 资源大全
- [pure-bash-bible](https://github.com/dylanaraps/pure-bash-bible)：Bash 技巧集合
- [ShellCheck](https://github.com/koalaman/shellcheck)：Shell 脚本静态检查工具
- [Shell playground](https://codapi.org/shell/)：在线练习环境

## 总结

Shell 脚本是 Linux/Unix 系统管理和自动化运维的重要工具，语法相对简单但功能强大。学习时不需要掌握所有特性，掌握基础语法、流程控制、文本处理三剑客（grep、sed、awk）就足以应对大部分场景。关键是多写脚本、多实践，结合工作实际需求来学习。在 AI 时代，Shell 脚本仍是最灵活、最高效的自动化方案，配合 AI 工具辅助生成和调试，学习更加轻松。
