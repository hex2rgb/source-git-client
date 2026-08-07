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
    zip \
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

# 5) 全局 CLI
RUN npm install -g @anthropic-ai/claude-code @larksuite/cli lark-channel-bridge

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh:en_US:en
ENV LC_ALL=zh_CN.UTF-8
ENV EDITOR=vim
WORKDIR /data
CMD ["lark-channel-bridge", "run"]
