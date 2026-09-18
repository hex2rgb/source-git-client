#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# 1. 先打镜像，此时旧容器仍在正常运行（构建过程零停机）；构建失败则直接退出，不影响服务
# 2. 镜像构建成功后再替换容器：一步完成"停旧起新"，停机时间只有重启这几秒

SERVICES=("$@")

if [ ${#SERVICES[@]} -eq 0 ]; then
  # 默认只构建并启动主实例
  docker compose build --pull claude-lark
  docker compose up -d --no-build --remove-orphans claude-lark
elif [ "${SERVICES[0]}" = "all" ]; then
  # all: 全部构建，成功后一起替换
  docker compose build --pull
  docker compose up -d --no-build --remove-orphans
else
  # 只构建指定的 service，成功后替换
  docker compose build --pull "${SERVICES[@]}"
  docker compose up -d --no-build --remove-orphans "${SERVICES[@]}"
fi
