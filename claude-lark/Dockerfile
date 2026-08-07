FROM python:3.12-slim-bookworm

ARG APT_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/debian
ARG APT_SECURITY_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/debian-security
ARG NODE_VERSION=22.23.2

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 1) 系统层: 清华源 (同 git-client 写法) + 常用工具
#    python 3.12 由 python:3.12-slim 自带, 不需 apt 再装
RUN set -eux; \
  printf '%s\n' \
    "deb ${APT_MIRROR} bookworm main contrib non-free non-free-firmware" \
    "deb ${APT_MIRROR} bookworm-updates main contrib non-free non-free-firmware" \
    "deb ${APT_SECURITY_MIRROR} bookworm-security main contrib non-free non-free-firmware" \
    > /etc/apt/sources.list \
  && rm -f /etc/apt/sources.list.d/debian.sources \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    locales \
    nano \
    openssh-client \
    tzdata \
    unzip \
    vim-tiny \
    wget \
    xz-utils \
    zip \
  && sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && sed -i 's/^# *\(zh_CN.UTF-8 UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && rm -rf /var/lib/apt/lists/*

# 2) Node 22 (官方 tarball, 版本固定) -> /usr/local
RUN set -eux; \
  curl -fsSLo node.tar.xz "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" \
  && tar -xJf node.tar.xz -C /usr/local --strip-components=1 \
  && rm node.tar.xz

# 3) pip: 允许容器内按需安装 (PEP 668) + 清华源
RUN pip config set global.break-system-packages true \
  && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 4) 运行时数据根: $HOME=/data 由挂载卷持久化
#    claude / lark-cli / lark-channel-bridge 三者的配置都从 $HOME 解析;
#    claude 额外用 CLAUDE_CONFIG_DIR 显式指定, 不依赖 $HOME 语义。
RUN mkdir -p /data
ENV HOME=/data
ENV CLAUDE_CONFIG_DIR=/data/.claude

# 5) 全局 CLI (npm 走 npmmirror, 同清华源思路)
RUN set -eux; \
  npm config set registry https://registry.npmmirror.com \
  && npm install -g @anthropic-ai/claude-code @larksuite/cli lark-channel-bridge

# 6) 镜像内置 claude 配置默认, 启动时初始化进持久卷 (已有则不覆盖)
COPY .claude/settings.json /opt/claude-lark/settings.json
COPY entrypoint.sh /usr/local/bin/claude-lark-entrypoint
RUN chmod +x /usr/local/bin/claude-lark-entrypoint
ENTRYPOINT ["/usr/local/bin/claude-lark-entrypoint"]

# 7) 非 root 用户: claude-code 拒绝 root 用 --dangerously-skip-permissions
#    用宿主已有用户 serveradmin (uid/gid 1000), 卷权限对齐
RUN groupadd --gid 1000 serveradmin \
  && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash serveradmin \
  && chown -R serveradmin:serveradmin /data
USER serveradmin

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh:en_US:en
ENV LC_ALL=zh_CN.UTF-8
ENV EDITOR=vim
WORKDIR /data
CMD ["lark-channel-bridge", "run"]
