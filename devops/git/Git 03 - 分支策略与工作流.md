---
title: "Git 03 - 分支策略与工作流"
date: 2024-01-01
tags: [Git]
---

# Git 03 - 分支策略与工作流

## 分支模型

```bash
# 创建和切换
git branch feature/login          # 创建分支
git checkout feature/login        # 切换分支
git checkout -b feature/login     # 创建并切换

# 合并
git checkout main
git merge feature/login           # 合并到 main

# 变基（rebase）
git checkout feature/login
git rebase main                   # 将当前分支移到 main 之上
```

### merge vs rebase

```bash
# merge — 保留完整历史
#     A---B---C feature
#    /         \
# D---E---F---G--- main

# rebase — 线性历史
#                 A'---B'---C' feature
#                /
# D---E---F---G--- main
```

### squash merge

```bash
# 将多个提交压缩成一个
git merge --squash feature/login
git commit -m "feat: add login feature"
```

## 常用工作流

### GitHub Flow（简单）

```
main ← 始终可部署
  │
  └── feature/login  ← 开发
       │
       └── PR → Code Review → 合并到 main
```

### Git Flow（正式）

```
master    ← 生产发布
  │
  develop   ← 开发主线
  │   │
  │   └── feature/login  ← 功能开发
  │
  release-1.0  ← 发布准备（bugfix 只修不增）
  │
  hotfix-urgent  ← 紧急修复（从 master 分叉，修完合回 master+develop）
```

### 推荐：Trunk-Based（简约）

```
main ← 所有开发直接提交/短分支
  │
  └── short-lived-feature (1-2天)
```

## 冲突解决

```bash
# 冲突标记
<<<<<<< HEAD
console.log("old version");
=======
console.log("new version");
>>>>>>> feature/login

# 手动解决后
git add resolved_file
git commit  # merge 冲突
# 或 git rebase --continue （rebase 冲突）
```

## Tag 管理

```bash
# 创建 tag
git tag v1.0.0                    # 轻量 tag
git tag -a v1.0.0 -m "v1.0.0"    # 含附注的 tag

# 推送 tag
git push origin v1.0.0
git push origin --tags            # 推送所有 tag

# 查看 tag
git tag -l "v1.*"
git show v1.0.0

# 删除 tag
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

## 常用 Git 配置

```bash
# 别名
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.st status
git config --global alias.lg "log --oneline --graph --all"

# 自动补全
git config --global alias.undo "reset --soft HEAD~1"

# 用户信息
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# 换行符
git config --global core.autocrlf input  # macOS/Linux
# git config --global core.autocrlf true  # Windows
```
