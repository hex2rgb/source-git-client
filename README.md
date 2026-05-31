# Source Git Client

这是一个给 Unraid 使用的专用 Git 客户端容器。

它的目标很简单：不在 Unraid 宿主机上安装或使用 Git，也不把 SSH key 放到宿主机用户目录里。Git、SSH、编辑器和交互环境都放在 Docker 容器里；源码统一写入宿主机指定目录。

## 功能

- 使用 SSH 访问私有 Git 仓库
- 执行 `git clone`、`git pull`、`git fetch`
- 使用真实 Linux 用户 `git`
- 固定用户 ID 为 `UID 99 / GID 100`
- 文件写入 `/workspace` 后，在标准 Unraid 环境中对应 `nobody:users`
- 提供 Bash、命令补全、Git 补全、Nano、Vim/Vi
- 支持中文 UTF-8 显示
- 容器常驻运行，方便随时 `docker exec` 进入使用

## 镜像

镜像基于：

```text
debian:bookworm-slim
```

默认使用清华 Debian 软件源：

```text
http://mirrors.tuna.tsinghua.edu.cn/debian
http://mirrors.tuna.tsinghua.edu.cn/debian-security
```

如果要改成阿里云源，可以在 `docker-compose.yml` 的 `build.args` 中传入：

```yaml
build:
  context: .
  dockerfile: Dockerfile
  args:
    APT_MIRROR: http://mirrors.aliyun.com/debian
    APT_SECURITY_MIRROR: http://mirrors.aliyun.com/debian-security
```

## 宿主机目录

源码目录：

```text
/mnt/alonepool/alone/workspace-pro
```

挂载到容器内：

```text
/workspace
```

SSH 目录：

```text
/mnt/user/appdata/source-git-home/ssh
```

挂载到容器内：

```text
/home/git/.ssh
```

预期 SSH 文件位置：

```text
/mnt/user/appdata/source-git-home/ssh/id_ed25519
/mnt/user/appdata/source-git-home/ssh/id_ed25519.pub
/mnt/user/appdata/source-git-home/ssh/known_hosts
```

## 构建并启动

```sh
docker compose up -d --build
```

也可以直接执行启动脚本：

```sh
bash start.sh
```

## 进入容器

```sh
docker exec -it source-git-client bash
```

## 拉取仓库

```sh
cd /workspace
git clone git@github.com:OWNER/REPO.git
```

## 更新仓库

```sh
cd /workspace/REPO
git pull
```

## 容器用户环境

- 用户：`git`
- UID：`99`
- GID：`100`
- Home：`/home/git`
- Shell：`/bin/bash`
- SSH 路径：`/home/git/.ssh`
- 工作目录：`/workspace`
- Locale：`zh_CN.UTF-8`
- 默认编辑器：`vim`

`Dockerfile` 会在构建时校验 `git` 用户是否确实为 `UID 99 / GID 100`。如果不满足，构建会直接失败。

## 说明

当前只持久化 SSH 目录 `/home/git/.ssh`，没有持久化整个 `/home/git`。这对 SSH key 和 `known_hosts` 已经足够。

如果以后需要持久化 Git 全局配置，例如 `/home/git/.gitconfig`，可以把整个 home 目录挂载出来。
