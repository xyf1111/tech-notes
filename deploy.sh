#!/bin/bash
# 技术知识库：本地构建 + 推送到 gh-pages 分支（GitHub Pages 自动发布）
# 用法：bash ~/code/kb-public/deploy.sh
set -euo pipefail

REPO="$HOME/code/kb-public"
NM="/Users/chenjinhuang/code/ObsidianVault/quartz/node_modules"
QZ="/Users/chenjinhuang/code/ObsidianVault/quartz/.quartz"
OUT="/tmp/kbpub-site"
DEP="/tmp/kbdeploy"
SSH_KEY="$HOME/.ssh/id_ed25519_kb"
REMOTE="git@github.com:xyf1111/tech-notes.git"

echo "▶ 1/5 准备构建环境"
ln -sfn "$NM" "$REPO/quartz/node_modules"
ln -sfn "$QZ" "$REPO/quartz/.quartz"

echo "▶ 2/5 构建站点"
cd "$REPO/quartz"
npx quartz build -d .. -o "$OUT"

echo "▶ 3/5 拉取 gh-pages 分支"
if [ -d "$DEP/.git" ]; then
  cd "$DEP" && GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes" git pull -q origin gh-pages
else
  rm -rf "$DEP"
  GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes" \
    git clone -q --branch gh-pages --single-branch "$REMOTE" "$DEP"
fi

echo "▶ 4/5 同步静态文件（排除 CNAME，清掉已删除页面）"
rsync -a --delete --exclude '.git' --exclude 'CNAME' "$OUT"/ "$DEP"/
touch "$DEP/.nojekyll"

echo "▶ 5/5 提交并推送"
cd "$DEP"
git add -A
if git diff --cached --quiet; then
  echo "（无变更，跳过推送）"
else
  git -c user.name=cecil777 -c user.email=chenjh20220103@163.com commit -qm "deploy: $(date '+%Y-%m-%d %H:%M')"
  GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes" git push -q origin gh-pages
fi

echo "✅ 完成：https://xyf1111.github.io/tech-notes/ （约 1 分钟后生效）"
