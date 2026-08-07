# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A private monorepo of independent Docker-based tools for Unraid. Each tool lives in its own directory with its own `docker-compose.yml` and optional `Dockerfile`/`deploy.sh`. No cross-dependencies, no build system, no tests.

## Services

| Directory | Description |
|-----------|-------------|
| `git-client/` | Debian 12 Git client container (Tsinghua apt mirror) |
| `comfy-ui/` | ComfyUI with NVIDIA GPU (Stable Diffusion) |
| `new-api/` | AI model gateway (calciumion/new-api) |
| `n8n/` | n8n workflow automation (SQLite, no external DB) |
| `smba-fs/` | Samba + FileBrowser file sharing |

## Common Commands

```sh
# Deploy/recreate a service (from its directory)
cd git-client && docker compose up -d --build

# Deploy using the convenience script
./git-client/deploy.sh

# Stop a service
docker compose -f git-client/docker-compose.yml down

# Tailing logs
docker compose -f n8n/docker-compose.yml logs -f

# Selective deploy (smba-fs only)
./smba-fs/deploy.sh filebrowser
./smba-fs/deploy.sh samba
```

## Conventions

- All services share the external Docker network `my-service-net` for inter-container communication.
- Services with fixed IPs: `new-api` (`172.18.0.19`), `comfy-ui` (`172.18.0.39`).
- Timezone is `Asia/Shanghai` everywhere.
- Data volumes mount Unraid host paths under `/mnt/user/appdata/` or `/mnt/alonepool/`.
- `deploy.sh` scripts follow the same pattern: down → remove orphans → up. `smba-fs/deploy.sh` additionally supports selective service restart.
- `restart: unless-stopped` with `on-failure` / `max_attempts: 3` is the standard restart policy.
- No `.codegraph/` index exists — use grep/find for code navigation.
