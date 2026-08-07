#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

SERVICES=("$@")

if [ ${#SERVICES[@]} -eq 0 ]; then
  # 默认只构建并启动主实例
  docker compose rm -fs claude-lark
  docker compose up -d --build claude-lark
elif [ "${SERVICES[0]}" = "all" ]; then
  # all: 全部构建并启动
  docker compose down --remove-orphans
  docker compose up -d --build
else
  # 只构建并重启指定的 service
  docker compose rm -fs "${SERVICES[@]}"
  docker compose up -d --build "${SERVICES[@]}"
fi
