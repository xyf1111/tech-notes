---
title: "Linux 07 - 文件删除防护与数据安全"
date: 2026-09-02
tags: [Linux, 安全, 数据保护]
source: "鱼皮·编程导航 / codefather"
---

# Linux 07 - 文件删除防护与数据安全

> 防止误执行删除命令（如 `rm -rf /`）造成数据丢失的防护措施：好习惯、alias 别名、权限管理三层防线。

## 好习惯（个人防线）

服务器上操作最多的就是自己，先养成良好的使用习惯：

- **定期备份**：用定时脚本（crontab）或同步工具，把数据库、用户文件、配置文件等重要数据定期下载到本地或同步到其他存储
- **替代删除命令**：尽量少用 `rm`，用移动代替删除

```bash
# 手动回收站：新建目录，把要删的文件「扔」进去
mkdir trash
mv file.txt trash

# 需要保留的文件加 .bak 后缀
mv file.txt file.txt.bak
```

习惯再好也有疏忽的时候，还需要更保险的机制。

## Alias 别名防护

Linux 的 `alias` 为命令设置别名，很多系统默认已在 `/root/.bashrc` 配置了保护性别名：

```bash
alias rm='rm -i'    # -i 参数：删除前询问确认，输入 y 才执行
alias cp='cp -i'
alias mv='mv -i'
```

**手动回收站**：把 `rm` 别名重定向为移动文件到回收站目录（修改 `~/.bashrc` 末尾追加）：

```bash
mkdir ~/.trash
alias rm=del
del()
{
  mv $@ ~/.trash/
}
source ~/.bashrc   # 使配置生效
```

此后执行 `rm` 实际是移动文件到 `~/.trash`，误删可找回。

**开源工具 trash**：不想手写脚本可用现成方案，Mac 用户一行命令安装：[ali-rantakari/trash](https://github.com/ali-rantakari/trash)。

## 权限管理（团队防线）

多人共用一台服务器时，靠自觉不够，需要对文件做权限约束：

- **chmod 修改文件权限**：`chmod 700 file.txt` 仅创建者本人可读写，其他用户无权访问
- **chattr 设置不可变属性**：`chattr`（Change Attribute）可防止文件/目录被意外删除或修改

```bash
# +i = 不可修改：不能删除、改名、设定链接，不能写入或新增内容（root 也无法轻易绕过）
sudo chattr +i file.txt
# 保护整个目录
sudo chattr -R +i myDir
```

加 `+i` 后执行删除会提示「操作不被允许」。**解除**用 `chattr -i file.txt`。

- **visudo 限制 sudo 权限**：普通用户拿到 root 身份后能做任何事。用 `visudo` 编辑 `/etc/sudoers`，限制用户只能删除指定路径：

```
# 用户 dog 只能删除 /file 目录下的文件
dog localhost=/bin/rm /file/*
```

- **Lshell 受限环境**：开源受限 Shell（[ghantoos/lshell](https://github.com/ghantoos/lshell)），安装后改 `/etc/lshell.conf` 管理用户可用命令，如禁止用户 yupi 使用 rm：

```
[yupi]
allowed = 'all' - ['rm']
```

以上措施组合使用足够覆盖绝大多数场景。最后提醒：不要出于好奇在生产环境尝试危险命令——「一时好奇一时爽，明天要睡垃圾场」。

> 来源：鱼皮·编程导航 / codefather
