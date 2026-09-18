#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# 1. 先拉取镜像，此时旧容器仍在正常运行（拉取过程零停机）；拉取失败则直接退出，不影响服务
# 2. 镜像就绪后再替换容器：一步完成"停旧起新"，停机时间只有重启这几秒；

SERVICES=("$@")

if [ ${#SERVICES[@]} -eq 0 ]; then
  # 全部拉取镜像，成功后一起替换
  docker compose pull
  docker compose up -d --no-build --remove-orphans
else
  # 只拉取指定 service 的镜像，成功后替换
  docker compose pull "${SERVICES[@]}"
  docker compose up -d --no-build --remove-orphans "${SERVICES[@]}"
fi
