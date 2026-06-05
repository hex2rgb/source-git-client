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
