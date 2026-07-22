#!/bin/bash
# 把当前 tunnel 地址写入跳转页并推送到 GitHub Pages 仓库
# 由 start-kanban.sh 在拿到公网地址后自动调用
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/.." && pwd)"
URL=$(cat "$ROOT/public-url.txt" 2>/dev/null)
if [ -z "$URL" ]; then echo "[redirect] 无 public-url.txt，跳过"; exit 0; fi

# 整行正则替换（无论之前是占位符还是旧地址，都能换成新地址，避免多次重启后失效）
sed -i '' -E "s#(var REDIRECT_TARGET=\")([^\"]*)(\";)#\1$URL\3#g" "$DIR/index.html"
echo "[redirect] 目标地址 -> $URL"

cd "$DIR"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git remote -v | grep -q origin; then
  git add -A
  git commit -m "redirect: $URL" >/dev/null 2>&1 || echo "[redirect] 无变更可提交"
  if git push origin HEAD 2>/dev/null; then
    echo "[redirect] 已推送，GitHub Pages 将在数十秒内更新"
  else
    echo "[redirect] 推送失败：请配置 git 凭证（SSH key 或 GitHub token）后手动 push"
  fi
else
  echo "[redirect] redirect/ 尚未关联 git remote，仅本地更新 index.html（未发布）"
fi
