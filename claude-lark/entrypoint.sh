#!/bin/sh
set -e

# 错峰启动: 多实例同时起时按 START_DELAY 秒错开, 避免瞬时打爆上游
if [ -n "${START_DELAY:-}" ]; then
  echo "claude-lark-entrypoint: delaying start ${START_DELAY}s"
  sleep "$START_DELAY"
fi

# 初始化 claude 配置进持久卷: /data/.claude 下文件不存在才从镜像拷贝
mkdir -p /data/.claude
for f in /opt/claude-lark/*; do
  base=$(basename "$f")
  if [ ! -f "/data/.claude/$base" ]; then
    cp "$f" "/data/.claude/$base"
  fi
done

exec "$@"
