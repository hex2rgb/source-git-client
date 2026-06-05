---
title: 私有 Docker 工具集合 - 架构设计
date: 2026-06-05
status: draft
---

## 概述

将现有的 `source-git-client` 单项目改造为私有 Docker 工具集合仓库。每个工具独立子目录、独立 docker-compose.yml、无跨服务依赖。

## 目录结构

```
source-git-client/
├── git-client/                  # 工具 1：Git 客户端
│   ├── Dockerfile
│   └── docker-compose.yml
├── new-api/                     # 工具 2：AI 模型网关
│   └── docker-compose.yml
├── .../                         # 后续工具直接加目录
├── docs/
│   └── superpowers/
│       └── specs/
│           └── 2026-06-05-docker-tool-collection-design.md
├── README.md                    # 集合索引
└── .gitignore
```

## 设计原则

- **完全独立**：每个工具目录自包含，互不依赖
- **可扩展**：新增工具只需新建目录 + docker-compose.yml
- **统一规范**：遵循 dockerfile-compose-reference 最佳实践
- **独立启停**：`cd <tool> && docker compose up -d` 即可启动

## 工具 1：git-client（现有迁移）

### 变更

将根目录下的 Dockerfile、docker-compose.yml 移至 `git-client/` 子目录，同时按规范补充配置。

### Dockerfile 变更

在 `tzdata` 已安装的前提下，新增时区环境变量：

```dockerfile
ENV TZ=Asia/Shanghai
```

（`tzdata` 随 `locales` 等包一并安装，无需新增安装步骤）

### docker-compose.yml

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
    volumes:
      - /mnt/alonepool/alone/workspace-pro:/workspace
      - /mnt/user/appdata/source-git-client/ssh:/home/git/.ssh
    restart: unless-stopped
    networks:
      - my-service-net

networks:
  my-service-net:
    external: true
```

### 说明

- build.context 为 `.`，因 compose.yml 已与 Dockerfile 同目录
- 镜像标签遵循 `{name}:local` 规范
- 新增 `restart: unless-stopped` + `deploy.restart_policy.max_attempts: 3`
- 新增 `ENV TZ=Asia/Shanghai` 设置容器时区

## 工具 2：new-api（新增）

### 配置

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

### 参数汇总

| 项目 | 值 |
|------|-----|
| 镜像 | `calciumion/new-api:latest` |
| 容器名 | `new-api` |
| 外部端口 | `30000` → 容器 `3000` |
| 数据卷 | `/mnt/user/appdata/new-api:/data` |
| 时区 | `TZ=Asia/Shanghai` |
| 重启策略 | `unless-stopped`，失败重试最多 3 次 |
| 网络 | `my-service-net`，固定 IP `172.18.0.19` |

## README.md 结构

根 README 改为工具集合索引，每个工具一个章节，内容包含：
- 工具简介
- 启动方式
- 关键路径（数据卷、端口）

## 后续扩展

新增工具步骤：
1. 建目录 `mkdir <tool-name>`
2. 写 `docker-compose.yml`
3. 如需自定义镜像则加 `Dockerfile`
4. 在根 README 添加索引条目
