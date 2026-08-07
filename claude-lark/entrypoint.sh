#!/bin/sh
set -e

# 初始化 claude 配置进持久卷: /data/.claude/settings.json 不存在才从镜像拷贝
mkdir -p /data/.claude
if [ ! -f /data/.claude/settings.json ]; then
  cp /opt/claude-lark/settings.json /data/.claude/settings.json
fi

exec "$@"
