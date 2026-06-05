# 私有 Docker 工具集合 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure single-project repo into a private Docker tool collection with independent tool subdirectories, adding new-api as the second tool.

**Architecture:** Monorepo with each tool in its own subdirectory, each with self-contained docker-compose.yml. No cross-service dependencies. git-client gets moved to subdirectory with Dockerfile/compose improvements per dockerfile-compose-reference standards.

**Tech Stack:** Docker, docker-compose

---

### Task 1: Move git-client to subdirectory with standard updates

**Files:**
- Create: `git-client/` directory
- Move + Modify: `git-client/Dockerfile` (add `ENV TZ=Asia/Shanghai`)
- Move + Modify: `git-client/docker-compose.yml` (add restart policy)

- [ ] **Step 1: Create git-client directory and move files**

```bash
mkdir -p /Users/robert/SelfMine/MyProject/source-git-client/git-client
mv /Users/robert/SelfMine/MyProject/source-git-client/Dockerfile /Users/robert/SelfMine/MyProject/source-git-client/git-client/Dockerfile
mv /Users/robert/SelfMine/MyProject/source-git-client/docker-compose.yml /Users/robert/SelfMine/MyProject/source-git-client/git-client/docker-compose.yml
```

- [ ] **Step 2: Add ENV TZ=Asia/Shanghai to git-client/Dockerfile**

Edit `git-client/Dockerfile`, insert after the existing ENV block:

```dockerfile
ENV TZ=Asia/Shanghai
```

Insert after line 51 (`ENV LC_ALL=zh_CN.UTF-8`).

- [ ] **Step 3: Add restart policy to git-client/docker-compose.yml**

Edit `git-client/docker-compose.yml`, add `restart: unless-stopped` at service level:

```yaml
services:
  source-git-client:
    build:
      context: .
      dockerfile: Dockerfile
    image: z-my-source-git-client:local
    container_name: z-my-source-git-client
    tty: true
    stdin_open: true
    restart: unless-stopped
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 3
    volumes:
      - /mnt/alonepool/alone/workspace-pro:/workspace
      - /mnt/user/appdata/source-git-client/ssh:/home/git/.ssh
    networks:
      - my-service-net

networks:
  my-service-net:
    external: true
```

### Task 2: Create new-api service

**Files:**
- Create: `new-api/docker-compose.yml`

- [ ] **Step 1: Create new-api directory and docker-compose.yml**

```bash
mkdir -p /Users/robert/SelfMine/MyProject/source-git-client/new-api
```

Write `new-api/docker-compose.yml`:

```yaml
services:
  new-api:
    image: calciumion/new-api:latest
    container_name: new-api
    ports:
      - "30000:3000"
    volumes:
      - /mnt/user/appdata/new-api:/data
    environment:
      - TZ=Asia/Shanghai
    restart: unless-stopped
    deploy:
      restart_policy:
        condition: on-failure
        max_attempts: 3
    networks:
      my-service-net:
        ipv4_address: 172.18.0.19

networks:
  my-service-net:
    external: true
```

### Task 3: Clean up root and update README

**Files:**
- Delete: `deploy.sh` (root-level, no longer needed)
- Modify: `README.md` → rewrite as collection index

- [ ] **Step 1: Remove root deploy.sh**

```bash
rm /Users/robert/SelfMine/MyProject/source-git-client/deploy.sh
```

- [ ] **Step 2: Rewrite README.md as collection index**

Write new `README.md`:

```markdown
# 私有 Docker 工具集合

个人私有 Docker 工具集合仓库。每个工具独立目录、独立启动、互无依赖。

## 工具列表

### git-client — Git 客户端

基于 Debian 12 的 Git 客户端容器，用于 Unraid 环境。

```sh
cd git-client && docker compose up -d --build
```

- 数据卷：`/mnt/alonepool/alone/workspace-pro:/workspace`
- SSH 密钥：`/mnt/user/appdata/source-git-client/ssh:/home/git/.ssh`
- 进入容器：`docker exec -it z-my-source-git-client bash`

### new-api — AI 模型网关

基于 calciumion/new-api 的统一 AI 模型网关，支持多模型聚合与分发。

```sh
cd new-api && docker compose up -d
```

- 端口映射：`30000:3000`
- 数据卷：`/mnt/user/appdata/new-api:/data`
- 默认账号：`root` / `123456`
- 固定 IP：`172.18.0.19`

## 新增工具

新建目录，放入 `docker-compose.yml`，在本 README 添加索引即可。
```

### Task 4: Save design spec and commit

**Files:**
- Already created: `docs/superpowers/specs/2026-06-05-docker-tool-collection-design.md`

- [ ] **Step 1: Verify all changes and commit**

```bash
cd /Users/robert/SelfMine/MyProject/source-git-client
git add -A
git status
git commit -m "refactor: restructure into private Docker tool collection

- Move git-client to subdirectory with restart policy and TZ
- Add new-api service with fixed IP 172.18.0.19
- Root README becomes collection index

Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>"
```
