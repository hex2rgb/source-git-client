#!/bin/sh
set -e

# 初始化 claude 配置进持久卷: /data/.claude 下文件不存在才从镜像拷贝
mkdir -p /data/.claude
for f in /opt/claude-lark/*; do
  base=$(basename "$f")
  if [ ! -f "/data/.claude/$base" ]; then
    cp "$f" "/data/.claude/$base"
  fi
done

exec "$@"
