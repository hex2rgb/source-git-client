#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

docker compose -f docker-compose.nvidia.yml --env-file .env down --remove-orphans
docker compose -f docker-compose.nvidia.yml --env-file .env up -d --build