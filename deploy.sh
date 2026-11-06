#!/bin/bash
# 技术知识库：本地构建 + 推送到 gh-pages 分支（GitHub Pages 自动发布）
# 用法：bash ~/code/kb-public/deploy.sh
set -euo pipefail

REPO="$HOME/code/kb-public"
NM="/Users/chenjinhuang/code/ObsidianVault/quartz/node_modules"
QZ="/Users/chenjinhuang/code/ObsidianVault/quartz/.quartz"
OUT="/tmp/kbpub-site"
PAGES="/tmp/kbpages-build"

echo "▶ 1/4 准备构建环境"
ln -sfn "$NM" "$REPO/quartz/node_modules"
ln -sfn "$QZ" "$REPO/quartz/.quartz"

echo "▶ 2/4 构建站点"
cd "$REPO/quartz"
npx quartz build -d .. -o "$OUT"

echo "▶ 3/4 组装静态文件（排除 CNAME）"
rm -rf "$PAGES" 2>/dev/null || true
mkdir -p "$PAGES"
rsync -a --exclude 'CNAME' "$OUT"/ "$PAGES"/
touch "$PAGES/.nojekyll"

echo "▶ 4/4 推送到 gh-pages"
cd "$PAGES"
git init -q -b gh-pages
git add -A
git -c user.name=cecil777 -c user.email=chenjh20220103@163.com commit -qm "deploy: $(date '+%Y-%m-%d %H:%M')"
git remote add origin git@github.com:xyf1111/tech-notes.git 2>/dev/null || true
GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519_kb -o IdentitiesOnly=yes" \
  git push -u origin gh-pages --force

echo "✅ 完成：https://xyf1111.github.io/tech-notes/"
