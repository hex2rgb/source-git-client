FROM ubuntu:22.04

ARG APT_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/ubuntu
ARG APT_SECURITY_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/ubuntu

ENV DEBIAN_FRONTEND=noninteractive

# APT 清华镜像源
RUN set -eux; \
  printf '%s\n' \
    "deb ${APT_MIRROR} jammy main restricted universe multiverse" \
    "deb ${APT_MIRROR} jammy-updates main restricted universe multiverse" \
    "deb ${APT_MIRROR} jammy-backports main restricted universe multiverse" \
    "deb ${APT_SECURITY_MIRROR} jammy-security main restricted universe multiverse" \
    > /etc/apt/sources.list

# 系统依赖
RUN set -eux; \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    python3 \
    python3-pip \
  && rm -rf /var/lib/apt/lists/*

# pip 清华镜像
RUN set -eux; \
  pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
  && pip3 config set global.trusted-host pypi.tuna.tsinghua.edu.cn

# Node.js 22 预编译包
RUN set -eux; \
  curl -fsSL "https://nodejs.org/dist/v22.14.0/node-v22.14.0-linux-x64.tar.xz" \
    | tar -xJ -C /usr/local --strip-components=1

# Claude Code CLI
RUN set -eux; \
  npm install -g @anthropic-ai/claude-code

WORKDIR /workspace

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
