---
title: "Git 02 - SSH与远程仓库"
date: 2024-01-01
tags: [Git]
---

# Git 02 - SSH 与远程仓库

## SSH 密钥配置

### 生成密钥

```bash
# 生成 ED25519 密钥（推荐）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 或 RSA 密钥
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### 添加密钥到 SSH Agent

```bash
# 启动 agent
eval "$(ssh-agent -s)"

# 添加密钥
ssh-add ~/.ssh/id_ed25519

# 列出已添加的密钥
ssh-add -l
```

### 添加到 GitHub/GitLab

```bash
# 复制公钥
cat ~/.ssh/id_ed25519.pub

# 测试连接
ssh -T git@github.com
# Hi username! You've successfully authenticated...
```

## 远程仓库管理

```bash
# 添加远程仓库
git remote add origin git@github.com:user/repo.git

# 查看远程仓库
git remote -v

# 修改远程仓库 URL
git remote set-url origin git@github.com:user/repo.git

# 删除远程仓库
git remote remove origin
```

### HTTP vs SSH

| 协议 | URL 格式 | 认证方式 | 推荐场景 |
|------|---------|---------|---------|
| HTTPS | `https://github.com/user/repo.git` | Token / 密码 | 公司代理环境 |
| SSH | `git@github.com:user/repo.git` | 密钥对 | 个人开发（推荐） |

## 多账号配置

```bash
# ~/.ssh/config
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work

Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
```

```bash
# 使用 personal 配置
git clone git@github-personal:username/repo.git

# 或改远程仓库
git remote set-url origin git@github-personal:username/repo.git
```

## 分支管理

```bash
# 推送本地分支到远程
git push -u origin main

# 删除远程分支
git push origin --delete feature/xxx

# 拉取远程分支（本地不存在）
git fetch origin feature/xxx
git checkout feature/xxx

# 查看本地与远程分支关系
git branch -vv
```

### 同步 Fork

```bash
# 添加上游仓库
git remote add upstream https://github.com/original/repo.git

# 拉取上游更新
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

## 常用远程操作

```bash
# 拉取并 rebase（推荐代替 merge）
git pull --rebase

# 强制推送（慎用）
git push --force-with-lease  # 比 --force 安全

# 推送 tags
git push origin --tags

# 删除远程 tag
git push origin :refs/tags/v1.0
```

### 报错排查

| 错误 | 原因 | 解决 |
|------|------|------|
| Permission denied (publickey) | SSH 密钥未添加 | `ssh-add ~/.ssh/id_ed25519` |
| Repository not found | 没有仓库访问权限 | 检查仓库 URL 和权限 |
| failed to push some refs | 远程有本地没有的提交 | `git pull --rebase` 后重试 |
| Updates were rejected | 强制推送被拒绝 | `--force-with-lease` 或先 pull |

## 多远程仓库管理

### 添加多个远程仓库

一个本地仓库可同时关联多个远程仓库（如 GitHub + Gitee），实现同时推送：

```bash
# 查看已有远程仓库
git remote -v

# 添加多个远程仓库（不同名称）
git remote add github https://github.com/user/repo.git
git remote add gitee https://gitee.com/user/repo.git
```

### 在 IDEA 中配置多远程仓库

1. 本地初始化 Git 仓库后，进入 **Git → Manage Remotes**
2. 添加多个远程地址，分别命名（如 `github`、`gitee`）
3. Push 时可选择推送到指定远程仓库
4. 也可分别推送：先 Push 到 GitHub，再 Push 到 Gitee

### 同时推送到所有远程

```bash
# 先设置两个 remote
git remote add github <url>
git remote add gitee <url>

# 推送时指定
git push github main
git push gitee main

# 或在 .git/config 中配置 push 所有 remote
git remote set-url --add --push origin <url1>
git remote set-url --add --push origin <url2>
```
