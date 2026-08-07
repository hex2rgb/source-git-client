FROM node:22-bookworm-slim

ARG APT_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/debian
ARG APT_SECURITY_MIRROR=http://mirrors.tuna.tsinghua.edu.cn/debian-security

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 1) 系统层: 清华源 (同 git-client 写法) + python3.11 (lark-cli skills 用; 不建 venv, pip 按需装)
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
    locales \
    python3 \
    python3-pip \
    tzdata \
    vim-tiny \
  && rm -rf /var/lib/apt/lists/*

# 2) pip: 允许容器内按需安装 (bookworm 的 PEP 668 默认禁系统 pip) + 清华源
RUN pip config set global.break-system-packages true \
  && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 3) 运行时数据根: $HOME=/data 由挂载卷持久化。
#    claude / lark-cli / lark-channel-bridge 三者的配置都从 $HOME 解析, 统一落在挂载卷;
#    claude 额外用 CLAUDE_CONFIG_DIR 显式指定, 不依赖 $HOME 语义。
RUN mkdir -p /data
ENV HOME=/data
ENV CLAUDE_CONFIG_DIR=/data/.claude

# 4) 全局 CLI
RUN npm install -g @anthropic-ai/claude-code @larksuite/cli lark-channel-bridge

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh:en_US:en
ENV LC_ALL=zh_CN.UTF-8
ENV EDITOR=vim
WORKDIR /data
CMD ["lark-channel-bridge", "run"]
